//
//  Student.h
//  runtimeTest
//
//  Created by leon on 2020/3/21.
//

#import "Person.h"

NS_ASSUME_NONNULL_BEGIN

@interface Student : Person
{
@public
    int _height;
}
@property(strong, nonatomic) NSString *name;

@property(copy, nonatomic) NSString *gener;

@property(strong, nonatomic) Person *girlFriend;

@property(assign, nonatomic) int style;

@property(strong, nonatomic) NSArray *array;

- (void)test;
- (void)foo;
+ (void)bebo;
- (int)getAgeWith: (NSString *)name andHeight: (int)height;
@end

NS_ASSUME_NONNULL_END
