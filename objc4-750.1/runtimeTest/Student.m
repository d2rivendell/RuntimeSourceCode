//
//  Student.m
//  runtimeTest
//
//  Created by leon on 2020/3/21.
//

#import "Student.h"

@implementation Student


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
     NSLog(@"keyPath : %@, object : %@", keyPath, object);
}


@end
