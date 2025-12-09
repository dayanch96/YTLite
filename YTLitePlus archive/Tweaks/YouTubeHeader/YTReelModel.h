#import "YTICommand.h"
#import "YTIPlayerResponse.h"
#import "YTReelContentModel.h"

@interface YTReelModel : YTReelContentModel
@property (nonatomic, readonly, assign) int videoType;
@property (nonatomic, copy, readwrite) NSString *joinVideoID;
@property (nonatomic, copy, readwrite) NSString *onesieVideoID; // Removed
- (YTIPlayerResponse *)playerResponseOverride;
- (YTICommand *)endpoint;
@end
