//
//  Student.h
//  runtimeTest
//
//  Created by leon on 2020/3/21.
//

#import "Person.h"

NS_ASSUME_NONNULL_BEGIN

@interface Student : Person

@property(copy, nonatomic) NSString *name;

@property(copy, nonatomic) NSString *gener;

@property(strong, nonatomic) Person *girlFriend;

@property(assign, nonatomic) int style;
@end

NS_ASSUME_NONNULL_END
