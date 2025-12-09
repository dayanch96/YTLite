#import "CAMTopBar.h"
#import "CAMBottomBar.h"
#import "CAMViewfinderView.h"
#import "CAMZoomSlider.h"
#import "CAMElapsedTimeView.h"
#import "CAMFramerateIndicatorView.h"
#import "CAMFlashButton.h"
#import "CUShutterButton.h"
#import "CAMPreviewViewController.h"
#import "CUCaptureController.h"
#import "CAMCaptureGraphConfiguration.h"
#import "CAMVideoConfigurationStatusIndicator.h"

NS_CLASS_AVAILABLE_IOS(9_0)
@interface CAMViewfinderViewController : UIViewController

@property NSInteger _desiredFlashMode;
@property NSInteger flashMode;
@property NSInteger _flashMode;
@property NSInteger _desiredTorchMode;
@property NSInteger torchMode NS_AVAILABLE_IOS(10_0);
@property NSInteger _torchMode NS_DEPRECATED_IOS(9_0, 9_3);
@property NSInteger _currentMode;
@property NSInteger _currentDevice;
@property NSInteger _desiredCaptureDevice;
@property (assign, setter=_setLayoutStyle:, nonatomic) NSInteger _layoutStyle;
@property (nonatomic, assign, readwrite, setter=_setResolvedLowLightMode:) NSInteger _resolvedLowLightMode;
@property (getter=_numFilterSelectionsBeforeCapture, setter = _setNumFilterSelectionsBeforeCapture:) NSUInteger _numFilterSelectionsBeforeCapture;

@property (nonatomic, strong) CAMViewfinderView *view;
@property (retain, nonatomic) CAMFramerateIndicatorView *_framerateIndicatorView;
@property (readonly, assign, nonatomic) CAMModeDial *_modeDial;
@property (readonly, assign, nonatomic) CAMTopBar *_topBar;
@property (readonly, assign, nonatomic) CAMBottomBar *_bottomBar;
@property (readonly, assign, nonatomic) CAMFlashButton *_flashButton;
@property (readonly, assign, nonatomic) CAMFlipButton *_flipButton;
@property (readonly, assign, nonatomic) CAMTimerButton *_timerButton;
@property (readonly, assign, nonatomic) CAMFilterButton *_filterButton;
@property (readonly, assign, nonatomic) CAMZoomSlider *_zoomSlider;
@property (readonly, assign, nonatomic) CAMHDRButton *_HDRButton;
@property (readonly, assign, nonatomic) CUShutterButton *_shutterButton;
@property (readonly, assign, nonatomic) CUShutterButton *_stillDuringVideoButton;
@property (readonly, assign, nonatomic) CAMElapsedTimeView *_elapsedTimeView;

- (BOOL)_isCapturingFromTimer;
- (BOOL)_isCapturingTimelapse;
- (BOOL)_shouldEnableFlashButton;
- (BOOL)_shouldCreateAndEmbedControls API_AVAILABLE(ios(10.0));
- (BOOL)_shouldHideFlashButtonForGraphConfiguration:(CAMCaptureGraphConfiguration *)configuration API_AVAILABLE(ios(10.0));
- (BOOL)_shouldHideStillDuringVideoButtonForGraphConfiguration:(CAMCaptureGraphConfiguration *)configuration API_AVAILABLE(ios(10.0));
- (BOOL)_shouldHideStillDuringVideoButtonForMode:(NSInteger)mode device:(NSInteger)device NS_DEPRECATED_IOS(9_0, 9_3);
- (BOOL)_shouldHideFlashButtonForMode:(NSInteger)mode device:(NSInteger)device NS_DEPRECATED_IOS(9_0, 9_3);
- (BOOL)_shouldHideModeDialForMode:(NSInteger)mode device:(NSInteger)device NS_DEPRECATED_IOS(9_0, 9_3);
- (BOOL)_shouldHideTopBarForGraphConfiguration:(CAMCaptureGraphConfiguration *)configuration API_AVAILABLE(ios(10.0));
- (BOOL)_shouldHideTopBarForMode:(NSInteger)mode device:(NSInteger)device NS_DEPRECATED_IOS(9_0, 9_3);
- (BOOL)isEmulatingImagePicker;
- (BOOL)_isSpatialVideoInVideoModeActiveForMode:(NSInteger)mode devicePosition:(NSInteger)devicePosition; // iOS 16+ ?

- (CAMCaptureGraphConfiguration *)_currentGraphConfiguration API_AVAILABLE(ios(10.0));
- (CAMPreviewViewController *)_previewViewController;
- (CUCaptureController *)_captureController;
- (CAMVideoConfigurationStatusIndicator *)_targetVideoConfigurationStatusIndicator API_AVAILABLE(ios(14.0));
- (CAMViewfinderView *)viewfinderView;

- (NSInteger)_effectFilterTypeForMode:(NSInteger)mode;
- (NSInteger)_remainingCaptureTimerTicks;
- (NSInteger)_resolvedTimerDuration;
- (NSInteger)_timerDuration;
- (NSInteger)timerDuration;

- (NSMutableArray <NSNumber *> *)modesForModeDial:(id)arg;

- (void)_captureStillImageWithCurrentSettings;
- (void)_collapseExpandedButtonsAnimated:(BOOL)animated;
- (void)_flashButtonDidChangeFlashMode:(CAMFlashButton *)flashButton;
- (void)_handleUserChangedToFlashMode:(NSInteger)flashMode;
- (void)_handleShutterButtonPressed:(id)arg1;
- (void)_handleShutterButtonReleased:(id)arg1;
- (void)_handleUserChangedFromDevice:(NSInteger)from toDevice:(NSInteger)to;
- (void)_readUserPreferencesAndHandleChanges NS_DEPRECATED_IOS(9_0, 12_4);
- (void)_setCurrentMode:(NSInteger)mode NS_DEPRECATED_IOS(9_0, 9_3);
- (void)_stopCapturingVideo;
- (void)_writeUserPreferences;

- (void)captureController:(id)arg1 didChangeToMode:(NSInteger)mode device:(NSInteger)device NS_DEPRECATED_IOS(9_0, 9_3);
- (void)readUserPreferencesAndHandleChangesWithOverrides:(id)arg1 NS_AVAILABLE_IOS(13_0);

- (NSInteger)_videoConfigurationResolutionForGraphConfiguration:(CAMCaptureGraphConfiguration *)configuration;
- (NSInteger)_videoConfigurationFramerateForGraphConfiguration:(CAMCaptureGraphConfiguration *)configuration;

@end
