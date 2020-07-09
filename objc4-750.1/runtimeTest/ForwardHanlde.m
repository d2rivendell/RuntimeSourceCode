//
//  ForwardHanlde.m
//  runtimeTest
//
//  Created by leon on 2020/4/19.
//

#import "ForwardHanlde.h"

@implementation ForwardHanlde

- (int)getAgeWith: (NSString *)name andHeight: (int)height{
    NSLog(@"我是转发第二阶段的帮手");
    return height + 10; 
}
@end
