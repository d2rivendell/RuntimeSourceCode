//
//  MyProtocol.h
//  runtimeTest
//
//  Created by leon on 2020/9/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MyProtocol <NSObject>

@property(nonatomic, copy)NSString *level;
- (void)superMe;
@end

NS_ASSUME_NONNULL_END
