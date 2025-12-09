#import "GPBMessage.h"

@interface YTIUrlEndpoint : GPBMessage
@property (nonatomic, copy, readwrite) NSString *URL;
@property (nonatomic, assign, readwrite) int target;
@property (nonatomic, assign, readwrite) BOOL nofollow;
@end
