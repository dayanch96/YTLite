#import "CAMEffectsRenderer.h"

NS_CLASS_AVAILABLE_IOS(8_0)
@interface CAMPreviewViewController : UIViewController

- (CAMEffectsRenderer *)effectsRenderer;

- (BOOL)_userLockedFocusAndExposure;

- (void)updateIndicatorVisibilityAnimated:(BOOL)animated;

@end
