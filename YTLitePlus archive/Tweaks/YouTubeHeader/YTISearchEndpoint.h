#import "GPBMessage.h"

@interface YTISearchEndpoint : GPBMessage
@property (nonatomic, copy, readwrite) NSString *query;
@property (nonatomic, copy, readwrite) NSString *params;
@end
