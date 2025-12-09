#import <Foundation/Foundation.h>

@protocol YTVideoPlayerOverlayDelegate <NSObject>
@required
- (void)serMuted:(BOOL)muted;
@end
