//
//  ReflexObjcTests.h
//  ReflexTests
//
//  Created by Tanner Bennett on 4/14/21.
//  Copyright © 2021 Tanner Bennett. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#ifdef __cplusplus
extern "C" {
#endif

BOOL isSwiftObjectOrClass(id objOrClass);

#ifdef __cplusplus
}
#endif


@interface RFView : NSObject

- (id)initWithColor:(UIColor *)color frame:(CGRect)frame;

@property (nonatomic, readonly) CGRect frame;
@property (nonatomic, readonly) UIColor *color;
@property (nonatomic, readonly) BOOL hidden;
@property (nonatomic, readonly) CGFloat alpha;

- (void)layoutSubviews;

@end

NS_ASSUME_NONNULL_END

