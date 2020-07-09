//
//  Person.h
//  runtimeTest
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Person : NSObject

@property(assign, nonatomic) int age;

- (Person *)say;


- (void)func1;
- (void)func2;
@end

NS_ASSUME_NONNULL_END
