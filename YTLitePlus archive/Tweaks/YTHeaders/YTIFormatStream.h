#import "YTIColorInfo.h"

@interface YTIFormatStream : NSObject
@property (nonatomic, strong, readwrite) YTIColorInfo *colorInfo;
@property (nonatomic, copy, readwrite) NSString *URL;
@property (nonatomic, copy, readwrite) NSString *qualityLabel;
@end