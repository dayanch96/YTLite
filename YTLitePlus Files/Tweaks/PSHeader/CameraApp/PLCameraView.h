#import "PLVideoPreviewView.h"
#import "CAMModeDial.h"
#import "CAMTopBar.h"
#import "CAMBottomBar.h"
#import "CAMFlashButton.h"
#import "CAMFlipButton.h"
#import "CAMFilterButton.h"
#import "CAMHDRButton.h"
#import "CAMElapsedTimeView.h"
#import "CAMHDRBadge.h"
#import "CAMAvalancheSession.h"
#import "CAMApplicationSpec.h"
#import "CAMPreviewView.h"

NS_CLASS_DEPRECATED_IOS(5_0, 7_1)
@interface PLCameraView : UIView

@property (retain, nonatomic) UIToolbar *bottomButtonBar;
@property NSInteger photoFlashMode;
@property (assign, nonatomic) NSInteger videoFlashMode;
@property (assign, nonatomic) NSInteger flashMode;
@property (assign, nonatomic) NSInteger lastSelectedPhotoFlashMode;
@property (readonly, assign, nonatomic) CAMModeDial *_modeDial NS_AVAILABLE_IOS(7_0);
@property (readonly, assign, nonatomic) CAMTopBar *_topBar NS_AVAILABLE_IOS(7_0);
@property (readonly, assign, nonatomic) CAMBottomBar *_bottomBar NS_AVAILABLE_IOS(7_0);
@property (readonly, assign, nonatomic) CAMFlashButton *_flashButton NS_AVAILABLE_IOS(7_0);
@property (readonly, assign, nonatomic) CAMFlipButton *_flipButton NS_AVAILABLE_IOS(7_0);
@property (readonly, assign, nonatomic) CAMFilterButton *_filterButton;
@property (readonly, assign, nonatomic) CAMHDRButton *_HDRButton NS_AVAILABLE_IOS(7_0);
@property (readonly, assign, nonatomic) CAMShutterButton *_shutterButton NS_AVAILABLE_IOS(7_0);
@property (readonly, assign, nonatomic) CAMShutterButton *_stillDuringVideoButton NS_AVAILABLE_IOS(7_0);
@property (readonly, assign, nonatomic) CAMElapsedTimeView *_elapsedTimeView NS_AVAILABLE_IOS(7_0);
@property (assign, nonatomic, getter=isTallScreen) BOOL tallScreen;
@property (readonly, assign, nonatomic) BOOL isCameraReady;
@property (assign, nonatomic) NSInteger cameraDevice;
@property (assign, nonatomic) NSInteger cameraMode;
@property (readonly, assign, nonatomic) CAMAvalancheSession *_avalancheSession NS_DEPRECATED_IOS(7_0, 8_4);
@property (assign, nonatomic) BOOL HDRIsOn;
@property (readonly, assign, nonatomic) CGRect unzoomedPreviewFrame;
@property (getter=_isFlipping, setter = _setFlipping:) BOOL _flipping;
@property (getter=_numFilterSelectionsBeforeCapture, setter = _setNumFilterSelectionsBeforeCapture:) NSUInteger _numFilterSelectionsBeforeCapture;

- (BOOL)_didEverMoveToWindow;
- (BOOL)_isCapturing;
- (BOOL)_isHidingBadgesForFilterUI;
- (BOOL)_isStillImageMode:(NSInteger)mode NS_AVAILABLE_IOS(7_0);
- (BOOL)_isStillImageMode:(NSInteger)mode;
- (BOOL)_isVideoMode:(NSInteger)mode NS_AVAILABLE_IOS(7_0);
- (BOOL)_performingTimedCapture NS_AVAILABLE_IOS(7_0);
- (BOOL)_shouldEnableFlashButton;
- (BOOL)_shouldEnableModeDial NS_AVAILABLE_IOS(7_0);
- (BOOL)_shouldHideFilterButtonForMode:(NSInteger)mode NS_AVAILABLE_IOS(7_0);
- (BOOL)_shouldHideFlashButtonForMode:(NSInteger)mode NS_AVAILABLE_IOS(7_0);
- (BOOL)_shouldHideHDRBadgeForMode:(NSInteger)mode;
- (BOOL)_shouldHideModeDialForMode:(NSInteger)mode NS_AVAILABLE_IOS(7_0);
- (BOOL)_shouldHideTopBarForMode:(NSInteger)mode NS_AVAILABLE_IOS(7_0);

- (BOOL)bottomBarShouldHideFilterButton:(id)arg1 NS_AVAILABLE_IOS(7_0);
- (BOOL)hasInFlightCaptures;
- (BOOL)HDRIsOn;

- (CAMApplicationSpec *)spec NS_AVAILABLE_IOS(7_0);
- (CAMHDRBadge *)_HDRBadge NS_AVAILABLE_IOS(7_0);

- (CGRect)_bottomBarFrame;

- (NSInteger)_currentFlashMode;
- (NSInteger)_glyphOrientationForCameraOrientation:(NSInteger)cameraOrientation;
- (NSInteger)_photoFlashMode;

- (NSString *)modeDial:(CAMModeDial *)modeDial titleForItemAtIndex:(NSUInteger)index NS_AVAILABLE_IOS(7_0);

- (PLVideoPreviewView *)videoPreviewView;

- (void)_addZoomAnimationDisplayLinkWithSelector:(SEL)selector;
- (void)_beginZooming;
- (void)_captureStillDuringVideo;
- (void)_checkDiskSpaceAfterCapture;
- (void)_clearFocusViews;
- (void)_createHDRBadgeIfNecessary;
- (void)_createZoomSliderIfNecessary;
- (void)_disableBottomBarForContinuousCapture;
- (void)_endZooming;
- (void)_handleVolumeUpEvents:(NSUInteger)events;
- (void)_layoutTopBarForOrientation:(NSInteger)orientation NS_AVAILABLE_IOS(7_0);
- (void)_loadZoomSliderResources;
- (void)_rotateCameraControlsAndInterface;
- (void)_setBottomBarEnabled:(BOOL)enabled;
- (void)_setBottomBarEnabled:(BOOL)enabled;
- (void)_setFlashMode:(NSInteger)mode;
- (void)_setOverlayControlsEnabled:(BOOL)enabled;
- (void)_setSettingsButtonAlpha:(CGFloat)alpha duration:(NSTimeInterval)duration NS_DEPRECATED_IOS(5_0, 6_1);
- (void)_setShouldShowFocus:(BOOL)focus;
- (void)_setShouldShowFocus:(BOOL)show;
- (void)_setSwipeToModeSwitchEnabled:(BOOL)enabled;
- (void)_setZoomFactor:(CGFloat)factor;
- (void)_shutterButtonClicked;
- (void)_switchFromCameraModeAtIndex:(NSUInteger)fromIndex toCameraModeAtIndex:(NSUInteger)toIndex;
- (void)_updateHDRBadge;
- (void)_updatePreviewWellImage:(UIImage *)image;
- (void)_updateTopBarStyleForDeviceOrientation:(NSInteger)orientation NS_AVAILABLE_IOS(7_0);

- (void)cameraShutterReleased:(id)arg1;
- (void)closeIrisWithDidFinishSelector:(SEL)closeIrisWith withDuration:(NSTimeInterval)duration;
- (void)flashButtonDidChangeFlashMode:(id)arg1;
- (void)flashButtonModeDidChange:(NSInteger)mode;
- (void)hideStaticClosedIris;
- (void)openIrisWithDidFinishSelector:(SEL)openIrisWith withDuration:(NSTimeInterval)duration;
- (void)pausePreview;
- (void)resumePreview;
- (void)setCameraButtonsEnabled:(BOOL)enabled;
- (void)showZoomSlider;
- (void)takePicture;
- (void)takePictureOpenIrisAnimationFinished;

@end
