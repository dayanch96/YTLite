#import "CAMCaptureConfiguration.h"

NS_CLASS_AVAILABLE_IOS(10_0)
@interface CAMCaptureGraphConfiguration : NSObject <NSCoding>

+ (instancetype)captureGraphConfigurationUsingConfiguration:(CAMCaptureConfiguration *)configuration;

- (NSInteger)flashMode;
- (NSInteger)torchMode;
- (NSInteger)HDRMode;
- (NSInteger)timerDuration;
- (NSInteger)irisMode;
- (NSInteger)photoModeEffectFilterType;
- (NSInteger)squareModeEffectFilterType;
- (NSInteger)mode;
- (NSInteger)device;
- (NSInteger)devicePosition;
- (NSInteger)videoEncodingBehavior;

@end
