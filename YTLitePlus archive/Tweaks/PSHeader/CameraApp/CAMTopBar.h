#import "CAMFilterButton.h"
#import "CAMHDRButton.h"
#import "CAMFlashButton.h"
#import "CAMTimerButton.h"
#import "CAMFlipButton.h"
#import "CAMElapsedTimeView.h"
#import "CAMCaptureGraphConfiguration.h"

NS_CLASS_AVAILABLE_IOS(7_0)
@interface CAMTopBar : UIView
@property (readonly, assign, nonatomic) UIView *_backgroundView;
@property (retain, nonatomic) CAMFilterButton *filterButton;
@property (retain, nonatomic) CAMHDRButton *HDRButton;
@property (retain, nonatomic) CAMFlashButton *flashButton;
@property (retain, nonatomic) CAMTimerButton *timerButton NS_AVAILABLE_IOS(8_0);
@property (retain, nonatomic) CAMFlipButton *flipButton;
@property (retain, nonatomic) CAMElapsedTimeView *elapsedTimeView;
@property (readonly, assign, nonatomic, getter=isFloating) BOOL floating;
@property (assign, nonatomic) NSInteger orientation;
@property (assign, nonatomic) NSInteger style;
@property (assign, nonatomic) NSInteger backgroundStyle;

- (UIButton *)_expandedMenuButton NS_AVAILABLE_IOS(8_0);
- (NSObject *)delegate;

- (NSMutableArray<NSNumber *> *)_allowedControlsForVideoMode NS_AVAILABLE_IOS(8_0);
- (NSMutableArray<NSNumber *> *)_allowedControlsForStillImageMode NS_AVAILABLE_IOS(8_0);
- (NSMutableArray<NSNumber *> *)_allowedControlsForPanoramaMode NS_AVAILABLE_IOS(8_0);
- (NSMutableArray<NSNumber *> *)_allowedControlsForTimelapseMode NS_AVAILABLE_IOS(8_0);

- (BOOL)_isFlashButtonExpanded;
- (BOOL)_shouldHideFlashButton;
- (BOOL)shouldHideFlipButtonForMode:(NSInteger)mode device:(NSInteger)device NS_DEPRECATED_IOS(9_0, 9_3);
- (BOOL)shouldHideFlashButtonForMode:(NSInteger)mode device:(NSInteger)device NS_DEPRECATED_IOS(9_0, 9_3);
- (BOOL)shouldHideFlashButtonForGraphConfiguration:(CAMCaptureGraphConfiguration *)configuration NS_AVAILABLE_IOS(10_0);
- (BOOL)shouldHideFramerateIndicatorForGraphConfiguration:(CAMCaptureGraphConfiguration *)configuration NS_AVAILABLE_IOS(10_0);

- (void)setBackgroundStyle:(NSInteger)style animated:(BOOL)animated;
- (void)setStyle:(NSInteger)style animated:(BOOL)animated;
- (void)expandMenuButton:(UIButton *)button animated:(BOOL)animated;
- (void)collapseMenuButton:(UIButton *)button animated:(BOOL)animated;

@end
