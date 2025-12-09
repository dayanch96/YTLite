#import <Foundation/Foundation.h>

NS_CLASS_AVAILABLE_IOS(9_0)
@interface CAMCaptureCapabilities : NSObject

+ (instancetype)capabilities;

- (BOOL)isSupportedVideoConfiguration:(NSInteger)videoConfiguration forMode:(NSInteger)mode device:(NSInteger)device API_AVAILABLE(ios(10.0));
- (BOOL)isSupportedVideoModeConfiguration:(NSInteger)videoConfiguration forDevice:(NSInteger)device NS_DEPRECATED_IOS(9_0, 9_3);
- (BOOL)isSupportedSlomoModeConfiguration:(NSInteger)videoConfiguration forDevice:(NSInteger)device NS_DEPRECATED_IOS(9_0, 9_3);
- (BOOL)isFlashSupportedForDevice:(NSInteger)device;
- (BOOL)isTorchPatternSupportedForDevice:(NSInteger)device;
- (BOOL)isBackCameraSupported;
- (BOOL)isFrontCameraSupported;

@end
