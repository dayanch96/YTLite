#import <CoreMedia/CoreMedia.h>

NS_CLASS_AVAILABLE_IOS(7_0)
@interface PFVideoAdjustments : NSObject

+ (CMTimeRange)defaultSlowMotionTimeRangeForDuration:(CMTime)duration;
+ (float)defaultSlowMotionRateForNominalFrameRate:(float)framerate;

@property CMTimeRange slowMotionTimeRange;

- (id)initWithURL:(NSURL *)url;
- (id)initWithSlowMotionTimeRange:(CMTimeRange)range rate:(float)rate;

- (BOOL)isRecognizedFormat;

@end
