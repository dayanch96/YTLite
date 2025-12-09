#import "CAMShutterButtonSpec.h"

NS_CLASS_AVAILABLE_IOS(9_0)
@interface CUShutterButton : UIButton
+ (instancetype)shutterButton;
+ (instancetype)smallShutterButton;
+ (instancetype)smallShutterButtonWithLayoutStyle:(NSInteger)style NS_AVAILABLE_IOS(10_0);
+ (instancetype)tinyShutterButton;
+ (instancetype)tinyShutterButtonWithLayoutStyle:(NSInteger)style NS_AVAILABLE_IOS(10_0);

@property (getter=isPulsing) BOOL pulsing;
@property (getter=isSpinning) BOOL spinning;
@property NSInteger mode;  
@property (assign, nonatomic) UIEdgeInsets tappableEdgeInsets;

- (UIColor *)_colorForMode:(NSInteger)mode;
- (UIColor *)_innerCircleColorForMode:(NSInteger)mode spinning:(BOOL)spinning;

- (UIView *)_innerView;
- (UIView *)_outerView;

- (void)_updateOuterAndInnerLayers;
- (void)_setSpec:(CAMShutterButtonSpec)spec;

@end
