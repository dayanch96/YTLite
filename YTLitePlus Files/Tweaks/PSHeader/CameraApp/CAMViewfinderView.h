#import "CAMPreviewView.h"
#import "CAMTopBar.h"
#import "CAMBottomBar.h"
#import "CAMZoomSlider.h"

NS_CLASS_AVAILABLE_IOS(9_0)
@interface CAMViewfinderView : UIView
- (CAMPreviewView *)previewView;
- (CAMTopBar *)topBar;
- (CAMBottomBar *)bottomBar;
- (CAMZoomSlider *)zoomSlider;
- (CGFloat)_interpolatedTopBarHeight;
- (CGSize)_topBarSizeForTraitCollection:(UITraitCollection *)traitCollection NS_DEPRECATED_IOS(9_0, 9_3);
- (CGSize)_topBarSizeForLayoutStyle:(NSInteger)layoutStyle NS_AVAILABLE_IOS(10_0);
@end
