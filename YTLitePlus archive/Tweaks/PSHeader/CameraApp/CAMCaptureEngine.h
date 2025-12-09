#import "CAMCaptureMovieFileOutput.h"
#import <AVFoundation/AVFoundation.h>

NS_CLASS_AVAILABLE_IOS(9_0)
@interface CAMCaptureEngine : NSObject

@property (retain, nonatomic) AVCaptureDevice *cameraDevice;
@property (retain, nonatomic) AVCaptureSession *_captureSession;

- (CAMCaptureMovieFileOutput *)movieFileOutput;
- (AVCaptureDeviceInput *)audioCaptureDeviceInput;

- (void)_handleSessionDidStartRunning:(id)arg1;

@end