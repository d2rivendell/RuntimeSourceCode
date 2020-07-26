//
//  Person.m
//  runtimeTest
//
//

#import "Person.h"
#include <objc/runtime.h>
#import "Person+Ext.h"
@implementation Person

+ (void)load{
    NSLog(@"load");
    Method mt1 = class_getInstanceMethod(self, @selector(func1));
    Method mt2 = class_getInstanceMethod(self, @selector(func2));
    //交换方法会清空缓存，防止缓存出错
    method_exchangeImplementations(mt1, mt2);
}
- (void)doSomething{
    NSLog(@"Person doSomething");
}

- (Person *)say
{
  
    
    NSLog(@"hello,world!");
    return [Person new];
}
//
//- (int)getAgeWith: (NSString *)name andHeight: (int)height{
//    return 20;
//}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    NSLog(@"keyPath : %@, object : %@", keyPath, object);
    
}


- (void)testExt{
    self->count = 3;
    NSLog(@"testExt - %d", self->count);
}





- (void)func1{
    NSLog(@"I am func1");
}

- (void)func2{
    NSLog(@"I am func2");
}
@end
