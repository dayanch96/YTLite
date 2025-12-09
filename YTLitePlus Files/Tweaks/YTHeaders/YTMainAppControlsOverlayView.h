#import "YTQTMButton.h"
#import "YTPlayerViewController.h"

@interface YTMainAppControlsOverlayView : UIView
+ (CGFloat)topButtonAdditionalPadding;
@property (nonatomic, assign, readwrite, getter=isOverlayVisible) BOOL overlayVisible;
@property (nonatomic, strong, readwrite) YTPlayerViewController *playerViewController;
- (YTQTMButton *)buttonWithImage:(UIImage *)image accessibilityLabel:(NSString *)accessibilityLabel verticalContentPadding:(CGFloat)verticalContentPadding;
@end
