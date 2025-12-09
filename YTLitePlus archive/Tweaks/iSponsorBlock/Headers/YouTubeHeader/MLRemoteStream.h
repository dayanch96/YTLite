#import "YTIFormatStream.h"
#import "MLFormat.h"

@interface MLRemoteStream : MLFormat
+ (instancetype)streamWithFormatStream:(YTIFormatStream *)formatStream;
@end
