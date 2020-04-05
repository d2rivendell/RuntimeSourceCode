//
//  Person+Person_category.m
//  runtimeTest
//
//  Created by leon on 2020/4/5.
//

#import "Person+Person_category.h"
#include <objc/runtime.h>
@implementation Person (Person_category)


- (void)setCategoryProperty:(NSString *)categoryProperty{
    objc_setAssociatedObject(self, @selector(categoryProperty), categoryProperty, OBJC_ASSOCIATION_COPY);
}

- (NSString *)categoryProperty{
    return objc_getAssociatedObject(self, _cmd);
}
@end
