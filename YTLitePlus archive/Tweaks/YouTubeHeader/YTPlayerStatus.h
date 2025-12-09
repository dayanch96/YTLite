#import <Foundation/NSObject.h>

@interface YTPlayerStatus : NSObject
- (BOOL)externalPlayback;
- (BOOL)backgroundPlayback;
- (BOOL)isInlinePlaybackActive;
- (BOOL)pictureInPicture;
- (int)visibility;
- (int)layout;
@end