#import <UIKit/UIVisualEffectView.h>

@interface YTFrostedGlassView : UIView
+ (NSInteger)frostedGlassBlurEffectStyle;
@property (nonatomic, strong, readwrite) UIVisualEffectView *blurEffectView;
@property (nonatomic, strong, readwrite) UIView *overlayView;
@property (nonatomic, assign, readwrite) CGFloat cornerRadius;
- (instancetype)initWithBlurEffectStyle:(NSInteger)style;
- (instancetype)initWithBlurEffectStyle:(NSInteger)style alpha:(CGFloat)alpha;
- (instancetype)initWithFallbackEffect;
- (void)setOverlayColor:(UIColor *)color;
- (void)maybeApplyToView:(UIView *)view;
@end
