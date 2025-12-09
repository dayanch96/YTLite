#import "CAMModeDial.h"
#import "CAMTopBar.h"
#import "CAMBottomBar.h"
#import "CAMFlashButton.h"
#import "CAMFlipButton.h"
#import "CAMTimerButton.h"
#import "CAMFilterButton.h"
#import "CAMHDRButton.h"
#import "CAMElapsedTimeView.h"
#import "CAMHDRBadge.h"
#import "CAMAvalancheSession.h"
#import "CAMApplicationSpec.h"
#import "CAMTorchPatternController.h"
#import "CAMPreviewView.h"
#import "CAMZoomSlider.h"

NS_CLASS_AVAILABLE_IOS(8_0)
@interface CAMCameraView : UIView

@property (assign, nonatomic) NSInteger videoFlashMode;
@property (assign, nonatomic) NSInteger flashMode;
@property (assign, nonatomic) NSInteger lastSelectedPhotoFlashMode;
@property (assign, nonatomic) NSInteger cameraDevice;
@property (assign, nonatomic) NSInteger cameraMode;
@property (getter=_numFilterSelectionsBeforeCapture, setter = _setNumFilterSelectionsBeforeCapture:) NSUInteger _numFilterSelectionsBeforeCapture;

@property (assign, nonatomic, getter=isTallScreen) BOOL tallScreen;
@property (getter=_isFlipping, setter = _setFlipping:) BOOL _flipping;
@property (readonly, assign, nonatomic) BOOL isCameraReady;
@property (assign, nonatomic) BOOL HDRIsOn;

@property (readonly, assign, nonatomic) CGRect unzoomedPreviewFrame;

@property (readonly, assign, nonatomic) CAMModeDial *_modeDial;
@property (readonly, assign, nonatomic) CAMZoomSlider *_zoomSlider;
@property (readonly, assign, nonatomic) CAMTopBar *_topBar;
@property (readonly, assign, nonatomic) CAMBottomBar *_bottomBar;
@property (readonly, assign, nonatomic) CAMFlashButton *_flashButton;
@property (readonly, assign, nonatomic) CAMFlipButton *_flipButton;
@property (readonly, assign, nonatomic) CAMTimerButton *_timerButton;
@property (readonly, assign, nonatomic) CAMFilterButton *_filterButton;
@property (readonly, assign, nonatomic) CAMHDRButton *_HDRButton;
@property (readonly, assign, nonatomic) CAMHDRBadge *_HDRBadge;
@property (readonly, assign, nonatomic) CAMShutterButton *_shutterButton;
@property (readonly, assign, nonatomic) CAMShutterButton *_stillDuringVideoButton;
@property (readonly, assign, nonatomic) CAMElapsedTimeView *_elapsedTimeView;
@property (readonly, assign, nonatomic) CAMAvalancheSession *_avalancheSession NS_DEPRECATED_IOS(7_0, 8_4);
@property (readonly, assign, nonatomic) CAMTorchPatternController *_torchPatternController;

- (BOOL)_avalancheCaptureInProgress;
- (BOOL)_didEverMoveToWindow;
- (BOOL)_isCapturing;
- (BOOL)_isHidingBadgesForFilterUI;
- (BOOL)_isStillImageMode:(NSInteger)mode;
- (BOOL)_isVideoMode:(NSInteger)mode;
- (BOOL)_performingDelayedCapture;
- (BOOL)_performingTimedCapture;
- (BOOL)_shouldEnableFlashButton;
- (BOOL)_shouldEnableModeDial;
- (BOOL)_shouldHideFilterButtonForMode:(NSInteger)mode;
- (BOOL)_shouldHideFlashButtonForMode:(NSInteger)mode;
- (BOOL)_shouldHideHDRBadgeForMode:(NSInteger)mode;
- (BOOL)_shouldHideModeDialForMode:(NSInteger)mode;
- (BOOL)_shouldHideTopBarForMode:(NSInteger)mode;
- (BOOL)_shouldUseAvalancheForDelayedCapture;
- (BOOL)bottomBarShouldHideFilterButton:(id)sender;
- (BOOL)hasInFlightCaptures;
- (BOOL)HDRIsOn;

- (CAMApplicationSpec *)spec;
- (CAMPreviewView *)previewView;

- (CGRect)_bottomBarFrame;

- (NSInteger)_currentFlashMode;
- (NSInteger)_currentTimerDuration;
- (NSInteger)_glyphOrientationForCameraOrientation:(NSInteger)cameraOrientation;
- (NSInteger)_HDRMode;
- (NSInteger)_photoFlashMode;
- (NSInteger)_remainingDelayedCaptureTicks;
- (NSString *)modeDial:(CAMModeDial *)modeDial titleForItemAtIndex:(NSUInteger)index;

- (void)_addZoomAnimationDisplayLinkWithSelector:(SEL)selector;
- (void)_beginZooming;
- (void)_captureStillDuringVideo;
- (void)_clearFocusViews;
- (void)_collapseExpandedButtonsAnimated:(BOOL)animated;
- (void)_createHDRBadgeIfNecessary;
- (void)_createZoomSliderIfNecessary;
- (void)_endZooming;
- (void)_handleVolumeUpEvents:(NSUInteger)events;
- (void)_layoutTopBarForOrientation:(NSInteger)orientation;
- (void)_rotateCameraControlsAndInterface;
- (void)_setBottomBarEnabled:(BOOL)enabled;
- (void)_setFlashMode:(NSInteger)mode;
- (void)_setOverlayControlsEnabled:(BOOL)enabled;
- (void)_setShouldShowFocus:(BOOL)focus;
- (void)_setSwipeToModeSwitchEnabled:(BOOL)enabled;
- (void)_setZoomFactor:(CGFloat)factor;
- (void)_shutterButtonClicked;
- (void)_startDelayedCapture;
- (void)_switchFromCameraModeAtIndex:(NSUInteger)fromIndex toCameraModeAtIndex:(NSUInteger)toIndex;
- (void)_teardownAvalancheCaptureTimer;
- (void)_updateForFocusCapabilities;
- (void)_updateHDRBadge;
- (void)_updatePreviewWellImage:(UIImage *)image;
- (void)_updateTopBarStyleForDeviceOrientation:(NSInteger)orientation;

- (void)cameraShutterReleased:(id)arg1;
- (void)flashButtonDidChangeFlashMode:(id)arg1;
- (void)flashButtonModeDidChange:(NSInteger)mode;
- (void)hideStaticClosedIris;
- (void)pausePreview;
- (void)resumePreview;
- (void)setCameraButtonsEnabled:(BOOL)enabled;
- (void)showZoomSlider;
- (void)takePicture;
- (void)takePictureOpenIrisAnimationFinished;

@end
