//
//  Person.m
//  runtimeTest
//
//

#import "Person.h"

@implementation Person

+ (void)load{
    NSLog(@"load");
}
- (void)say
{
    NSLog(@"hello,world!");
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    NSLog(@"keyPath : %@, object : %@", keyPath, object);
    
}
@end
