#import "YTQTMButton.h"
#import "YTILikeButtonRenderer.h"

@interface YTReelWatchLikesController : NSObject
@property (nonatomic, strong, readwrite) YTQTMButton *likeButton;
@property (nonatomic, strong, readwrite) YTQTMButton *dislikeButton;
- (id)likeModelForLikeButtonRenderer:(YTILikeButtonRenderer *)renderer;
- (void)updateLikeButtonWithModel:(id)model animated:(BOOL)animated;
@end
