#import "YTCommonButton.h"
#import "YTIButtonRenderer.h"
#import "YTLightweightQTMButton.h"

@interface YTQTMButton : YTLightweightQTMButton <YTCommonButton>
+ (instancetype)buttonWithImage:(UIImage *)image accessibilityLabel:(NSString *)accessibilityLabel accessibilityIdentifier:(NSString *)accessibilityIdentifier;
+ (instancetype)barButtonWithImage:(UIImage *)image accessibilityLabel:(NSString *)accessibilityLabel accessibilityIdentifier:(NSString *)accessibilityIdentifier;
+ (instancetype)button;
+ (instancetype)closeButton;
+ (instancetype)iconButton;
+ (instancetype)textButton;
@property (nonatomic, assign, readwrite) BOOL sizeWithPaddingAndInsets;
@property (nonatomic, strong, readwrite) UIColor *customTintColor;
- (UILabel *)titleLabel;
- (void)enableNewTouchFeedback;
- (void)setTitleTypeKind:(NSInteger)typeKind;
- (void)setTitleTypeKind:(NSInteger)typeKind typeVariant:(NSInteger)typeVariant;
- (void)setInnerTubeButtonStyle:(YTIButtonRenderer_Style)style;
- (void)setForegroundColor:(UIColor *)color backgroundColor:(UIColor *)backgroundColor;
@end
