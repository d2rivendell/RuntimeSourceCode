//
//  Student.m
//  runtimeTest
//
//  Created by leon on 2020/3/21.
//

#import "Student.h"
#include <objc/runtime.h>
#import "ForwardHanlde.h"
@implementation Student


- (void)test{
    
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
     NSLog(@"keyPath : %@, object : %@", keyPath, object);
}

void fooMethod(id obj, SEL _cmd)
{
    NSLog(@"Doing fooMethod");
}

- (void)fooMethod2{
    NSLog(@"Doing fooMethod2");
}

//1. 其他地方调用不存在的实例方法的时候，在转发之前有次机会，，首先会走这里动态添加方法来处理
+ (BOOL)resolveInstanceMethod:(SEL)sel{
    if(sel == @selector(foo)){
        Method method = class_getInstanceMethod(self, @selector(fooMethod2));
        // 下面两种方式都可以,第一个参数是self，因为实例方法在类对象中， +方法内object_getClass(self)是元类
//        class_addMethod(self, sel, (IMP)method_getImplementation(method), method_getTypeEncoding(method));
        class_addMethod(self, sel, (IMP)fooMethod, "v@:");
        return YES;
    }
    return [super resolveInstanceMethod:sel];
}


void bebeMethod(id obj, SEL _cmd){
    NSLog(@"Doing bebeMethod");
}
+ (void)bebeMethod2{
    NSLog(@"Doing bebeMethod");
}
//1. 其他地方调用不存在的类方法的时候，在转发之前有次机会，，首先会走这里动态添加方法来处理
+ (BOOL)resolveClassMethod:(SEL)sel{
    if(sel == @selector(bebo)){
        Method method = class_getInstanceMethod(self, @selector(bebeMethod2));
        // 下面两种方式都可以,第一个参数是self，因为类方法在类对象中， 第一个参数是元类
        //        class_addMethod(self, sel, (IMP)method_getImplementation(method), method_getTypeEncoding(method));
        class_addMethod(object_getClass(self), sel, (IMP)bebeMethod, "v@:");
        return YES;
    }
    return [super resolveInstanceMethod:sel];
}



//2.1 上面1没有处理的时候会再尝试调用这里
- (id)forwardingTargetForSelector:(SEL)aSelector{
    return nil;
}

//2.2 上面2.1没有处理的时候会再尝试调用这里
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector{
    NSLog(@"%s -- %@",__func__,NSStringFromSelector(aSelector));
    if (aSelector == @selector(getAgeWith:andHeight:)) {
        // 消息签名类型文档https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html
        //v:返回值类型是void
        //@: 两个是固定的，一个是id类型(发送消息的对象），一个是sel类型（该方法的sel）
        return [NSMethodSignature signatureWithObjCTypes:"i@:@i"];
    }
    return [super methodSignatureForSelector:aSelector];
}


- (void)forwardInvocation:(NSInvocation *)anInvocation{
    //只要不调用 [super forwardInvocation:anInvocation] 就不会报找不到方法的崩溃
    //在这里可以记录哪些方法没有调用却实现了
    NSLog(@"%s ",__func__);
    SEL aSelector = [anInvocation selector];
    //让ForwardHanlde去处理这个方法
    if ([[ForwardHanlde alloc] respondsToSelector:aSelector])
        [anInvocation invokeWithTarget:[ForwardHanlde alloc]];
    else
        [super forwardInvocation:anInvocation];// 这个会崩溃
}


- (void)dealloc
{
    NSLog(@"dealloc");
}

@end
