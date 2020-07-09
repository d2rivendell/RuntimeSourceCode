//
//  Person+Person_category.h
//  runtimeTest
//
//  Created by leon on 2020/4/5.
//

#import "Person.h"

NS_ASSUME_NONNULL_BEGIN

@interface Person (Person_category)

@property (nonatomic, strong) NSString *categoryProperty;
@property(nonatomic, copy) NSString *school;
@end

NS_ASSUME_NONNULL_END
