#import "GPBMessage.h"

@interface YTIShareVideoEndpoint : GPBMessage
@property (nonatomic, copy, readwrite) NSString *videoId;
@property (nonatomic, copy, readwrite) NSString *videoShareURL;
@property (nonatomic, copy, readwrite) NSString *videoTitle;
+ (GPBExtensionDescriptor *)shareVideoEndpoint;
@end
