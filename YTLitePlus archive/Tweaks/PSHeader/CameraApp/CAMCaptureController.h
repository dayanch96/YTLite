#import "CAMCameraView.h"
#import "CAMAvalancheCaptureService.h"
#import "CAMEffectsRenderer.h"
#import <AVFoundation/AVFoundation.h>

NS_CLASS_AVAILABLE_IOS(8_0)
@interface CAMCaptureController : NSObject

@property (assign, nonatomic) AVCaptureDevice *currentDevice;
@property (assign, nonatomic) AVCaptureOutput *currentOutput;
@property (retain, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;
@property (readonly, assign, nonatomic) AVCaptureSession *currentSession;
@property (assign, nonatomic) NSInteger cameraDevice;
@property (assign, nonatomic) NSInteger cameraMode;
@property (assign, nonatomic) NSInteger flashMode;
@property (readonly, assign, nonatomic) NSInteger cameraOrientation;
@property (assign, nonatomic, getter=isHDREnabled) BOOL HDREnabled;
@property (getter=_isPreviewPaused, setter = _setPreviewPaused:) BOOL _previewPaused;
@property (retain, nonatomic) CAMEffectsRenderer *effectsRenderer;
@property (assign, nonatomic) CGFloat videoZoomFactor;
@property BOOL performingAvalancheCapture;

+ (BOOL)isStillImageMode:(NSInteger)mode;
+ (BOOL)isVideoMode:(NSInteger)mode;

- (BOOL)_isSessionReady;
- (BOOL)_isVideoMode:(NSInteger)mode;
- (BOOL)_lockCurrentDeviceForConfiguration;

- (BOOL)canCaptureVideo;
- (BOOL)flashWillFire;
- (BOOL)hasFrontCamera;
- (BOOL)hasRearCamera;
- (BOOL)isCameraApp;
- (BOOL)isCapturingPanorama;
- (BOOL)isCapturingTimelapse;
- (BOOL)isCapturingVideo;
- (BOOL)isChangingModes;
- (BOOL)isFocusLockSupported;
- (BOOL)isReady;

- (CAMAvalancheCaptureService *)_avalancheCaptureService NS_DEPRECATED_IOS(7_0, 8_4);
- (CAMCameraView *)delegate;
- (NSMutableArray<NSNumber *> *)supportedCameraModes;

- (CGFloat)maximumZoomFactorForDevice:(AVCaptureDevice *)device;
- (double)mogulFrameRate;

- (NSUInteger)_activeFilterIndex;
- (NSUInteger)effectFilterIndexForMode:(NSInteger)mode;

- (void)_lockFocus:(BOOL)focus lockExposure:(BOOL)exposure lockWhiteBalance:(BOOL)whiteBalance;
- (void)_setFlashMode:(NSInteger)mode force:(BOOL)force;
- (void)_suggestedHDRChanged;
- (void)_unlockCurrentDeviceForConfiguration;

- (void)pausePreview;
- (void)resumePreview;
- (void)setFaceDetectionEnabled:(BOOL)enabled forceDisableImageProcessing:(BOOL)disableIP;
- (void)setFaceDetectionEnabled:(BOOL)enabled;
- (void)setFocusDisabled:(BOOL)disabled;

@end
