//
//  Person.h
//  runtimeTest
//
//

#import <Foundation/Foundation.h>
#import "MyProtocol.h"
NS_ASSUME_NONNULL_BEGIN

@interface Person : NSObject<MyProtocol>

@property(assign, nonatomic) int age;
@property(copy, nonatomic)void (^MyBlock)(void);

- (Person *)say;
- (void)doSomething;

- (void)func1;
- (void)func2;
@end

NS_ASSUME_NONNULL_END
