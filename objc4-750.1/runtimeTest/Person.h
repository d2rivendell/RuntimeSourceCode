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

@end

NS_ASSUME_NONNULL_END
