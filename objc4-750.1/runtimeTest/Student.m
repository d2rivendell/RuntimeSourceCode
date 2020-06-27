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


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
     NSLog(@"keyPath : %@, object : %@", keyPath, object);
}

void fooMethod(id obj, SEL _cmd)
{
    NSLog(@"Doing foo");
}

//1. 其他地方调用不存在的方法的时候，首先会走这里
+ (BOOL)resolveInstanceMethod:(SEL)sel{
    if(sel == @selector(foo:)){
        class_addMethod([self class], sel, (IMP)fooMethod, "v@:");
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
    if (aSelector == @selector(saySomething)) {
        // 消息签名类型文档https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html
        //v:返回值类型是void
        //@: 两个是固定的，一个是id类型(发送消息的对象），一个是sel类型（该方法的sel）
        return [NSMethodSignature signatureWithObjCTypes:"v@:"];
    }
    return [super methodSignatureForSelector:aSelector];
}


- (void)forwardInvocation:(NSInvocation *)anInvocation{
    NSLog(@"%s ",__func__);
    SEL aSelector = [anInvocation selector];
    //让ForwardHanlde去处理这个方法
    if ([[ForwardHanlde alloc] respondsToSelector:aSelector])
        [anInvocation invokeWithTarget:[ForwardHanlde alloc]];
    else
        [super forwardInvocation:anInvocation];
}


- (void)dealloc
{
    NSLog(@"dealloc");
}

@end
