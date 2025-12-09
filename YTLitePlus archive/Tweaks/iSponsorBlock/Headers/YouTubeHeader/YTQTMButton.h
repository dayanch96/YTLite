#import "YTCommonButton.h"
#import "YTLightweightQTMButton.h"

@interface YTQTMButton : YTLightweightQTMButton <YTCommonButton>
+ (instancetype)barButtonWithImage:(UIImage *)image accessibilityLabel:(NSString *)accessibilityLabel accessibilityIdentifier:(NSString *)accessibilityIdentifier;
+ (instancetype)button;
+ (instancetype)closeButton;
+ (instancetype)iconButton;
+ (instancetype)textButton;
@property (nonatomic, assign, readwrite) BOOL sizeWithPaddingAndInsets;
- (UILabel *)titleLabel;
- (void)enableNewTouchFeedback;
@end
