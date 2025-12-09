#import "CAMFilterButton.h"
#import "CAMFlashButton.h"
#import "CAMFlipButton.h"
#import "CAMHDRButton.h"
#import "CAMTimerButton.h"
#import "CAMShutterButton.h"
#import "CAMImageWell.h"
#import "CAMModeDial.h"
#import "CAMSlalomIndicatorView.h"

NS_CLASS_AVAILABLE_IOS(7_0)
@interface CAMBottomBar : UIView
@property (readonly, assign, nonatomic) UIView *backgroundView;
@property (retain, nonatomic) CAMFilterButton *filterButton;
@property (retain, nonatomic) CAMFlashButton *flashButton;
@property (retain, nonatomic) CAMFlipButton *flipButton;
@property (retain, nonatomic) CAMHDRButton *HDRButton;
@property (retain, nonatomic) CAMTimerButton *timerButton API_AVAILABLE(ios(8.0));
@property (retain, nonatomic) CAMShutterButton *shutterButton;
@property (retain, nonatomic) CAMShutterButton *stillDuringVideoButton;
@property (retain, nonatomic) CAMImageWell *imageWell;
@property (retain, nonatomic) CAMModeDial *modeDial;
@property (retain, nonatomic) CAMSlalomIndicatorView *slalomIndicatorView;
@property (assign) NSInteger layoutStyle;

+ (BOOL)wantsVerticalBarForTraitCollection:(UITraitCollection *)traitCollection API_AVAILABLE(ios(8.0));
+ (BOOL)wantsVerticalBarForLayoutStyle:(NSInteger)style API_AVAILABLE(ios(10.0));

- (CGRect)alignmentRectForFrame:(CGRect)frame;

- (NSObject *)delegate;
- (UIButton *)_expandedMenuButton;
- (UIView *)backgroundView;
- (UIView *)_shutterButtomBottomLayoutSpacer;
- (UIView *)_filterButtonBottomLayoutSpacer;

- (void)_layoutStillDuringVideoButtonForTraitCollection:(UITraitCollection *)traitCollection;
- (void)_setupHorizontalFilterButtonConstraints;
- (void)_setupVerticalFilterButtonConstraints;

- (BOOL)_isTimerButtonExpanded API_AVAILABLE(ios(8.0));
- (BOOL)shouldHideFlashButtonForMode:(NSInteger)mode device:(NSInteger)device;
- (BOOL)shouldHideFlipButtonForMode:(NSInteger)mode device:(NSInteger)device;

@end
