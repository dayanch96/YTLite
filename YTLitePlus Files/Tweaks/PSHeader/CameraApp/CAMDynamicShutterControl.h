#import <UIKit/UIKit.h>

typedef struct CAMShutterColor {
    CGFloat r;
    CGFloat g;
    CGFloat b;
    CGFloat a;
} CAMShutterColor;

NS_CLASS_AVAILABLE_IOS(10_0)
@interface CAMDynamicShutterControl : UIControl
- (CAMShutterColor)_innerShapeColor;
- (UIView *)_centerOuterView;
- (void)_updateRendererShapes;
@end
