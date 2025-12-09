#import <CoreGraphics/CGGeometry.h>
#import "HAMFormat.h"
#import "HAMMIMEType.h"
#import "YTIAudioTrack.h"
#import "YTIFormatStream.h"

@interface MLFormat : NSObject <NSCopying, HAMFormat>
@property (nonatomic, readonly, strong) YTIAudioTrack *audioTrack;
- (instancetype)initWithFormatStream:(YTIFormatStream *)formatStream;
- (HAMMIMEType *)MIMEType;
- (YTIFormatStream *)formatStream;
- (NSURL *)URL;
- (NSString *)qualityLabel;
- (int)itag;
- (int)width;
- (int)height;
- (int)singleDimensionResolution;
- (int)qualityOrdinal;
- (CGFloat)FPS;
- (BOOL)isAudio;
- (BOOL)isVideo;
- (BOOL)isText;
- (NSInteger)compareByQuality:(MLFormat *)format;
- (NSInteger)bitrate;
@end
