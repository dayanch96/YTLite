#import "PLManagedAsset.h"

@interface PLVideoView : UIView

@property (readonly) PLManagedAsset *videoCameraImage;

- (BOOL)isPlaying;
- (BOOL)canEdit;
- (BOOL)_canAccessVideo;
- (BOOL)_mediaIsPlayable;
- (BOOL)_mediaIsVideo;
- (BOOL)_shouldShowSlalomEditor NS_AVAILABLE_IOS(7_0);

@end
