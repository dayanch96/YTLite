#import "YTIFormattedString.h"
#import "YTIThumbnailDetails.h"

@interface YTIIosSystemShareEndpoint : GPBMessage
@property (nonatomic, copy, readwrite) NSString *shareString;
@property (nonatomic, copy, readwrite) NSString *shareSubject;
@property (nonatomic, copy, readwrite) NSString *shareURL;
@property (nonatomic, strong, readwrite) YTIFormattedString *shareAttributedString;
@property (nonatomic, strong, readwrite) YTIThumbnailDetails *shareImage;
+ (GPBExtensionDescriptor *)iosSystemShareEndpoint;
@end
