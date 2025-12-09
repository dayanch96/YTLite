#import "GIMMe.h"
#import "YTSingleVideoController.h"

@interface YTPlayerPIPController : NSObject
@property (nonatomic, readonly, assign, getter=isPictureInPictureActive) BOOL pictureInPuctureActive;
@property (nonatomic, readonly, assign, getter=isPictureInPicturePossible) BOOL pictureInPucturePossible;
@property (retain, nonatomic) YTSingleVideoController *activeSingleVideo;
- (instancetype)initWithPlayerView:(id)playerView delegate:(id)delegate; // Deprecated, use initWithDelegate:
- (instancetype)initWithDelegate:(id)delegate;
- (GIMMe *)gimme; // Deprecated
- (BOOL)canInvokePictureInPicture; // Deprecated, use canEnablePictureInPicture
- (BOOL)canEnablePictureInPicture;
- (void)maybeInvokePictureInPicture; // Deprecated, use maybeEnablePictureInPicture
- (void)maybeEnablePictureInPicture;
- (void)play;
- (void)pause;
@end
