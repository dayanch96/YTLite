#import "CAMShutterButtonSpec.h"

NS_CLASS_AVAILABLE_IOS(7_0)
@interface CAMShutterButton : UIButton
+ (instancetype)shutterButton;
+ (instancetype)smallShutterButton;
+ (instancetype)tinyShutterButton NS_AVAILABLE_IOS(8_0);

@property (getter=isPulsing) BOOL pulsing;
@property (getter=isSpinning) BOOL spinning;

@property NSInteger mode;

- (UIColor *)_colorForMode:(NSInteger)mode;
- (UIView *)_innerView;
- (UIView *)_outerView;

- (void)_updateOuterAndInnerLayers;
- (void)_setSpec:(CAMShutterButtonSpec)spec;

@end
