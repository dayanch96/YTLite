#import "PLCameraView.h"
#import "PLCameraEffectsRenderer.h"
#import <AVFoundation/AVFoundation.h>

NS_CLASS_DEPRECATED_IOS(5_0, 7_1)
@interface PLCameraController : NSObject

@property (assign, nonatomic)AVCaptureDevice *currentDevice;
@property (assign, nonatomic) AVCaptureOutput *currentOutput;
@property (retain, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;
@property (readonly, assign, nonatomic) AVCaptureSession *currentSession;
@property (assign, nonatomic) NSInteger cameraDevice;
@property (assign, nonatomic) NSInteger cameraMode;
@property (assign, nonatomic) NSInteger flashMode;
@property (readonly, assign, nonatomic) NSInteger cameraOrientation;
@property (assign, nonatomic, getter=isHDREnabled) BOOL HDREnabled;
@property (retain, nonatomic) PLCameraEffectsRenderer *effectsRenderer NS_AVAILABLE_IOS(7_0);
@property (assign, nonatomic) CGFloat videoZoomFactor;
@property (getter=_isPreviewPaused, setter = _setPreviewPaused:) BOOL _previewPaused;
@property BOOL performingTimedCapture NS_AVAILABLE_IOS(7_0);

+ (BOOL)isStillImageMode:(NSInteger)mode;

- (BOOL)_isSessionReady;
- (BOOL)_isVideoMode:(NSInteger)mode;
- (BOOL)_lockCurrentDeviceForConfiguration;

- (BOOL)canCaptureVideo;
- (BOOL)flashWillFire;
- (BOOL)hasFrontCamera;
- (BOOL)hasRearCamera;
- (BOOL)isCameraApp;
- (BOOL)isCapturingVideo;
- (BOOL)isChangingModes;
- (BOOL)isFocusLockSupported;
- (BOOL)isReady;

- (CGFloat)maximumZoomFactorForDevice:(AVCaptureDevice *)device;
- (double)mogulFrameRate;

- (NSMutableArray<NSNumber *> *)supportedCameraModes;
- (PLCameraView *)delegate;

- (NSUInteger)_activeFilterIndex;
- (NSUInteger)effectFilterIndexForMode:(NSInteger)mode;

- (void)_lockFocus:(BOOL)focus lockExposure:(BOOL)exposure lockWhiteBalance:(BOOL)whiteBalance;
- (void)_setFlashMode:(NSInteger)mode force:(BOOL)force;
- (void)_suggestedHDRChanged;
- (void)_unlockCurrentDeviceForConfiguration;

- (void)pausePreview;
- (void)resumePreview;
- (void)setFaceDetectionEnabled:(BOOL)enabled;
- (void)setFocusDisabled:(BOOL)disabled;
@end
