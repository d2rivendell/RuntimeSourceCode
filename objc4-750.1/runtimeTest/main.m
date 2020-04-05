//
//  main.m
//  runtimeTest
//
//

#import <Foundation/Foundation.h>
//#import "objc-runtime.h"
#include <objc/runtime.h>
#include <objc/message.h>
#import "Person.h"
#import "Student.h"
#import "Person+Fly.h"

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
//        id p = [[Student alloc] init];
       
//        p.name = @"fan";
//        p.age = 22;
//        NSLog(@"%d, %@",p.age, p.name);
//        [p fly];
        
//        NSLog(@"Student address = %p",pcls);
//        const char * className = object_getClassName(p);
//        Class metaClass = objc_getMetaClass(className);
//        NSLog(@"className is %s,MetaClass is %s",className, class_getName(metaClass));
        
        weakTest();
       
    }
    return 0;
}
