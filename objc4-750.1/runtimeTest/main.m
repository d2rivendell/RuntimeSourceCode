//
//  main.m
//  runtimeTest
//
//

//Xcode 11.4 运行此demo会崩溃

#import <Foundation/Foundation.h>
//#import "objc-runtime-new.h"
#include <objc/runtime.h>
#include <objc/message.h>
#import "Person.h"
#import "Student.h"
#import "Person+Fly.h"
#import "Person+Person_category.h"
#import "HookPerson.h"
#import "Person+Ext.h"
// 把一个十进制的数转为二进制
NSString * binaryWithInteger(NSUInteger decInt){
    NSString *string = @"";
    NSUInteger x = decInt;
    while(x > 0){
        string = [[NSString stringWithFormat:@"%lu",x&1] stringByAppendingString:string];
        x = x >> 1;
    }
    return string;
}

int pow_int(int a, int b){
    int sum = 1;
    for (int i = 0; i < b; i++) {
        sum *= a;
    }
    return sum;
}

typedef unsigned char *byte_pointer;
void show_bytes(byte_pointer start, size_t len){
    //iOS 是小端，输出是反的
    size_t i;
    for (i = len; i > 0; i--){
        printf(" %.2x", start[i-1]);
    }
    printf("\n");
}


//通过runtime的方法获取当前类对象中的所有方法名
static NSArray *ClassMethodsNames(Class c)
{
    NSMutableArray *array = [NSMutableArray array];
    unsigned int methodCount = 0;
    Method *methodList = class_copyMethodList(c, &methodCount);
    unsigned int i;
    for(i = 0; i < methodCount; i++) {
        [array addObject:NSStringFromSelector(method_getName(methodList[i]))];
    }
    free(methodList);
    return array;
}

//打印对象的相关信息，主要是看传入对象实际上的类对象
static void PrintDescription(NSString *name, id obj)
{
    NSString *str = [NSString stringWithFormat:
                     @"%@: %@\n\tNSObject class %s\n\tlibobjc class %s\n\timplements methods <%@>",
                     name,
                     obj,
                     class_getName([obj class]),//KVO会修改中间类的class方法，返回的不是中间类而是源类达到欺骗使用者的目的
                     class_getName(object_getClass(obj)),//class方法会欺骗你，但isa指针不会，通过object_getClass获取isa指针的内容，实际指向的就是中间类
                     [ClassMethodsNames(object_getClass(obj)) componentsJoinedByString:@", "]];
    printf("%s\n", [str UTF8String]);
}

static void KVOTest(){
    Student *p = [[Student alloc] init];
    p.name = @"fan";
    PrintDescription(@"before", p);
    [p addObserver:p forKeyPath: @"name" options: 0 context:NULL];
    p.name = @"xx";
    PrintDescription(@"after", p);
}

static void isaTest(){
    Student *p = [[Student alloc] init];
    
    //方法1： 类调用 class
    Class cCls = [Student class];
    //方法2： 对象调用class 获取的是pCls的isa
    Class pCls = [p class];
    //方法3:  和方法2一样 获取的是pCls的isa
    Class p2 = object_getClass(p);
    
    printf("\n1 %s", class_getName(cCls));
    printf("\n2 %s", class_getName(pCls));
    printf("\n3 %s\n", class_getName(p2));
}


static void weakTest(){
    Student *p = [[Student alloc] init];
    p.name = @"xx";
    PrintDescription(@"after", p);
    Person *newP = nil;
//    newP = p;
    id __weak weak_p = p;
    p=nil;
}

static void read_attr(){
    unsigned int count;
    
    //类对象中存储着成员变量的信息ivar, 注意是“成员变量信息”，比如名字和编码
    //成员变量的值还是存在实例变量中
    
    //ivar 只存储了属性的名字和类型
    Ivar *ivarList =  class_copyIvarList([Student class], &count);
    NSLog(@"=======%s ivar========",class_getName([Student class]));
    for (int i = 0; i < count; i++) {
        Ivar ivar = ivarList[i];
        char *name = ivar_getName(ivar);
        char *encode = ivar_getTypeEncoding(ivar);
        NSLog(@"name: %s, encode: %s", name, encode);
    }
    NSLog(@"=======ivar========");
    //objc_property_t 存储了属性的名字、属性和Ivar一样只是信息，不是成员变量
    objc_property_t *pList =  class_copyPropertyList([Student class], &count);
    NSLog(@"=======%s objc_property_t========",class_getName([Student class]));
    for (int i = 0; i < count; i++) {
        objc_property_t p = pList[i];
        char *name = property_getName(p);
        char *att = property_getAttributes(p);
        NSLog(@"name: %s, att: %s", name, att);
    }
    NSLog(@"=======objc_property_t========");
    free(ivarList);
    free(pList);
}

static void msg_send(){
    Student *p = [[Student alloc] init];
    SEL sel = @selector(shabi);
//    BOOL (*msg)(Class, SEL, SEL) = (typeof(msg))objc_msgSend;
    NSString* (*aTestFunc)(id, SEL, NSString*) = (NSString* (*)(id, SEL, NSString*)) objc_msgSend;
    aTestFunc(p, sel, @"sb");
//    [p performSelector:sel withObject:nil];
}


void test(id self, SEL _cmd, NSString *name, NSNumber *age){
    NSLog(@"name: %@, age: %@", name, age);
}

void test2(id self, SEL _cmd, NSString *name, NSNumber *age, NSNumber * money){
    NSLog(@"name: %@, age: %@, money: %@", name, age, money);
}

static void dynamicAdd(){

    //创建新类，会同时创建类对象和元类对象。 --创建MyClass类，它继承自NSObject
    Class MyClass = objc_allocateClassPair([NSObject class], "MyClass", 0);
    //class_addIvar要在注册 class之前，否者添加失败，因为注册后类的布局已经确定，不能再添加Ivar
    class_addIvar(MyClass, "money", sizeof(NSString *), log2(sizeof(NSString*)), "d");//添加double类型变量
    //添加到gdb_objc_realized_classes表中

    objc_registerClassPair(MyClass);
    
    //类型表格https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html
    //给MyClass类对象添加属性
    char *str = @encode(NSNumber*);
    char *str2 = @encode(int);
    char *str3 = @encode(double);
    char *str4 = @encode(BOOL);//BOOL类型本质是signed char
    NSLog(@"%s, %s, %s, %s", str, str2, str3, str4);//@, i, @
    
    //Ivar只是添加变量 Property添加变量又会生成setter、getter方法
    //对于已经存在的类，class_addIvar是不能够添加属性的
  
    id my  = [[MyClass alloc] init];
    [my setValue:@"1234" forKey:@"money"];
    NSLog(@"%@", [my valueForKey:@"money"]);
    /*
     属性类型  name值：T  value：变化
     编码类型  name值：C(copy) &(strong) W(weak) 空(assign) 等 value：无
     非/原子性 name值：空(atomic) N(Nonatomic)  value：无
     变量名称  name值：V  value：变化
     */
    objc_property_attribute_t type = { "T", "@\"NSNumber\"" };//设置属性类型
    objc_property_attribute_t policy  = { "&", nil };//
    objc_property_attribute_t backingivar  = { "V", "_age" };//设置变量的名字
    //顺序很重要 Type encoding must be first，Backing ivar must be last。
    objc_property_attribute_t attrs[] = { type, policy, backingivar };
    class_addProperty(MyClass, "age", attrs, 2);
    
    //第一个是返回值类型， 后面是参数类型其中"@:"是固定的，表示调用的类，sel类型
    class_addMethod(MyClass, @selector(test), (IMP)test, "v@:@@");
   
    id custom =  [[MyClass alloc] init];
    // 该方法最多能传2个参数， 如果要传多个 可使用以下方式
    //1.字典 2.使用objc_msgSend()传递 3.使用NSInvocation
    [custom performSelector:@selector(test) withObject: @"jack" withObject:@(22)];
   
    
    SEL test2Selector = @selector(test2);
    //传递多个参数
    class_addMethod(MyClass, test2Selector, (IMP)test2, "v@:@@@");
    NSMethodSignature *signature = [MyClass instanceMethodSignatureForSelector: test2Selector];
    if (signature == nil) {
        NSLog(@"opps!, can not find %s signature", (char *)test2Selector);
    }else{
        NSLog(@"NSInvocation 传递多个参数:");
        id custom2 =  [[MyClass alloc] init];
        //利用一个NSInvocation对象包装一次方法调用
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        invocation.target = custom2;
        invocation.selector = test2Selector;
        // 设置参数
        NSInteger paramsCount = signature.numberOfArguments - 2; // 除self、_cmd以外的参数个数
        NSArray *objects = @[@"jack", @(21), @(20200)];
        paramsCount = MIN(paramsCount, objects.count);
        for (int i = 0; i < paramsCount; i++) {
            id object = objects[i];
            if ([object isKindOfClass:[NSNull class]]) continue;
            //前两个参数已经固定 在第三个参数开始添加
            [invocation setArgument:&object atIndex:i + 2];
        }
        // 调用方法
        [invocation invoke];
        // 获取返回值
        id returnValue = nil;
        if (signature.methodReturnLength) { // 有返回值类型，才去获得返回值
            [invocation getReturnValue:&returnValue];
        }
    }
    NSLog(@"imp 传递多个参数:");
    id custom2_1 =  [[MyClass alloc] init];
    SEL selector = NSSelectorFromString(@"test2");
    IMP imp = [custom2_1 methodForSelector:selector];
    void(*customFunc)(id,SEL,NSString *,NSNumber *,NSNumber *) = (void *)imp;
    customFunc(custom2_1,selector,@"Lily", @(23), @(2222222));
}

void autorelease(){
   __autoreleasing Person *jack = [[Person alloc] init];
    
}


void msgForward(){
    Student *p = [[Student alloc] init];
    int res = [p getAgeWith:@"vivi" andHeight:180];
          [p foo];
          [p test];
          [Student bebo];
    NSLog(@"返回： %d", res);
}

//交换方法
void exchange(){
    Person *p = [[Person alloc] init];
    [p func1];
    [p func2];
}


void rumtime_api(){
    //把p指向新的类对象， 达到只是hook某个实例对象而不是所有类的实例
    //的目的
    Person *p = [[Person alloc] init];
    object_setClass(p, [HookPerson class]);
    [p doSomething];
}

void atomicTest(){
    Student *stu = [[Student alloc] init];
    for (int i = 0; i < 100000; i++) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //array是atomic的时候不会崩， 在nonatomic的时候会崩！
            stu.array = @[[NSString stringWithFormat:@"那卡女款释放能量释放能量可能拉风呢拉萨v出门啦v释放能量可能拉风呢拉萨v出门啦v释放能量可能拉风呢拉萨v出门啦v可能拉风呢拉萨v出门啦v%d", i]];
        });
    }
    for (int i = 0; i < 100; i++) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSLog(@"%@",stu.array);
        });
    }
    sleep(100);
}
int main(int argc, const char * argv[]) {
    // 整个程序都包含在一个@autoreleasepool中
    @autoreleasepool {
    
        // insert code here...
       
        //        show_bytes(&x, sizeof(int));
        //        show_bytes(&sx, sizeof(short));
        
        //        unsigned x = 53191;//            -12345: ff ff cf c7
        //        unsigned short sx = x;//      53191: 00 00 cf c7
        //        printf("x: %u\n", x);
        //        printf("sx: %d\n", sx);
        //        show_bytes(&x, sizeof(unsigned));
        //        show_bytes(&sx, sizeof(short));
        //返回值是对象的时候编译器会做优化
//        [p performSelector:@selector(say) withObject:nil];
        uint32_t s = sizeof(id);
        printf("%d",s);
//        p.name = @"fan";
//        p.age = 22;
//        NSLog(@"%d, %@",p.age, p.name);
//        [p fly];
        
//        NSLog(@"Student address = %p",pcls);
//        const char * className = object_getClassName(p);
//        Class metaClass = objc_getMetaClass(className);
//        NSLog(@"className is %s,MetaClass is %s",className, class_getName(metaClass));
        
//        weakTest();
//        msg_send();
//        read_attr();
//        NSProcessInfo *info =  [NSProcessInfo processInfo];
//        NSLog(@"processorCount: %ld", info.processorCount);
//        NSLog(@"processName: %@", info.processName);
//        NSLog(@"physicalMemory: %llu", info.physicalMemory);
//        NSLog(@"arguments: %@", info.arguments);
//         isaTest();
//        msgForward();
//        exchange();
//        dynamicAdd();
//        rumtime_api();
//         atomicTest();
         Student *stu = [[Student alloc] init];
         stu.name = @"savalvjalsfasdbvamdg;amgas;g;ag,;a,,g;a,gga";
         NSLog(@"%@", stu.name);
    }
    return 0;
}
