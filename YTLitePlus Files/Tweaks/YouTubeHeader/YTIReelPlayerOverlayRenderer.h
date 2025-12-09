#import "YTILikeButtonSupportedRenderers.h"
#import "YTIReelPlayerHeaderSupportedRenderers.h"
#import "YTIRenderer.h"

@interface YTIReelPlayerOverlayRenderer : GPBMessage
@property (nonatomic, strong, readwrite) YTILikeButtonSupportedRenderers *likeButton;
@property (nonatomic, strong, readwrite) YTILikeButtonSupportedRenderers *doubleTapLikeButton;
@property (nonatomic, strong, readwrite) YTIReelPlayerHeaderSupportedRenderers *reelPlayerHeaderSupportedRenderers;
@property (nonatomic, strong, readwrite) YTIRenderer *buttonBar;
@property (nonatomic, strong, readwrite) YTIRenderer *shareButton;
@property (nonatomic, strong, readwrite) YTIRenderer *viewCommentsButton;
@end
