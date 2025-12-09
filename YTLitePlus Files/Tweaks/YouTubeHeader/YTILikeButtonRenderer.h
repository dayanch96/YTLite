#import "YTLikeStatus.h"
#import "YTILikeTarget.h"
#import "YTIFormattedString.h"

@interface YTILikeButtonRenderer : NSObject
@property (nonatomic, strong, readwrite) YTILikeTarget *target;
@property (nonatomic, strong, readwrite) YTIFormattedString *likeCountText;
@property (nonatomic, strong, readwrite) YTIFormattedString *likeCountWithLikeText;
@property (nonatomic, strong, readwrite) YTIFormattedString *likeCountWithUnlikeText;
@property (nonatomic, strong, readwrite) YTIFormattedString *dislikeCountText;
@property (nonatomic, strong, readwrite) YTIFormattedString *dislikeCountWithDislikeText;
@property (nonatomic, strong, readwrite) YTIFormattedString *dislikeCountWithUndislikeText;
@property (nonatomic, assign, readwrite) BOOL hasLikeCountText;
@property (nonatomic, assign, readwrite) BOOL hasLikeCountWithLikeText;
@property (nonatomic, assign, readwrite) BOOL hasLikeCountWithUnlikeText;
@property (nonatomic, assign, readwrite) BOOL hasDislikeCountText;
@property (nonatomic, assign, readwrite) BOOL hasDislikeCountWithDislikeText;
@property (nonatomic, assign, readwrite) BOOL hasDislikeCountWithUndislikeText;
@property (nonatomic, assign, readwrite) BOOL likesAllowed;
@property (nonatomic, assign, readwrite) YTLikeStatus likeStatus;
@property (nonatomic, assign, readwrite) int likeCount;
@property (nonatomic, assign, readwrite) int dislikeCount;
@end
