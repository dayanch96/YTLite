#import "GIMMe.h"
#import "YTSingleVideoController.h"
#import "YTSystemNotificationsObserver.h"

@interface YTPlayerPIPController : NSObject <YTSystemNotificationsObserver>
@property (nonatomic, readonly, assign, getter=isPictureInPictureActive) BOOL pictureInPictureActive;
@property (nonatomic, readonly, assign, getter=isPictureInPicturePossible) BOOL pictureInPicturePossible;
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
