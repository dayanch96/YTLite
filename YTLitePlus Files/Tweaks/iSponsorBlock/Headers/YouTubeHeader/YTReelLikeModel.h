#import "YTILikeButtonRenderer.h"

@interface YTReelLikeModel : NSObject
@property (nonatomic, copy, readwrite) NSString *videoID;
@property (nonatomic, strong, readwrite) YTILikeButtonRenderer *likeButtonRenderer;
@property (nonatomic, assign, readwrite) int status;
@property (nonatomic, assign, readwrite) int lastStatus;
@end
