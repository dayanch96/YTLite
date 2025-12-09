#import <AVFoundation/AVFoundation.h>

@interface AVCaptureDeviceFormat (CameraUI)

- (BOOL)cam_supportsVideoConfiguration:(NSInteger)videoConfiguration;

@end
