#import "YTIHamplayerSoftwareStreamFilter.h"

@interface YTIHamplayerStreamFilter : NSObject
@property (nonatomic, strong, readwrite) YTIHamplayerSoftwareStreamFilter *av1;
@property (nonatomic, strong, readwrite) YTIHamplayerSoftwareStreamFilter *vp9;
@property (nonatomic, assign, readwrite) BOOL enableVideoCodecSplicing;
@end
