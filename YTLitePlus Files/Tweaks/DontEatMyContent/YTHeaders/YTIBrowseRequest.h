#import "GPBMessage.h"

@interface YTIBrowseRequest : GPBMessage
+ (NSString *)browseIDForExploreTab;
+ (NSString *)browseIDForAccountTab;
+ (NSString *)browseIDForActivityTab;
+ (NSString *)browseIDForHomeTab;
+ (NSString *)browseIDForLibraryTab;
+ (NSString *)browseIDForTrendingTab;
+ (NSString *)browseIDForSubscriptionsTab;
+ (NSString *)browseIDForWhatToWatch;
@end