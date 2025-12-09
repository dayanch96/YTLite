#import "GPBMessage.h"

@interface YTIBrowseEndpoint : GPBMessage
@property (nonatomic, copy, readwrite) NSString *browseId;
@property (nonatomic, copy, readwrite) NSString *params;
@property (nonatomic, copy, readwrite) NSString *canonicalBaseURL;
@end
