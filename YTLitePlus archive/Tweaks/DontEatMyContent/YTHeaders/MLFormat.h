#import <CoreGraphics/CoreGraphics.h>
#import "HAMMIMEType.h"
#import "YTIAudioTrack.h"
#import "YTIFormatStream.h"

@interface MLFormat : NSObject <NSCopying>
@property (nonatomic, readonly, strong) YTIAudioTrack *audioTrack;
- (HAMMIMEType *)MIMEType;
- (YTIFormatStream *)formatStream;
- (NSURL *)URL;
- (NSString *)qualityLabel;
- (int)itag;
- (int)width;
- (int)height;
- (int)singleDimensionResolution;
- (CGFloat)FPS;
- (BOOL)isAudio;
- (BOOL)isVideo;
- (BOOL)isText;
- (NSInteger)compareByQuality:(MLFormat *)format;
- (NSInteger)bitrate;
@end
