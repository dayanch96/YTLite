#import <Foundation/NSObject.h>

@protocol YTVideoPlayerOverlayDelegate <NSObject>
@required
- (void)serMuted:(BOOL)muted;
@end
