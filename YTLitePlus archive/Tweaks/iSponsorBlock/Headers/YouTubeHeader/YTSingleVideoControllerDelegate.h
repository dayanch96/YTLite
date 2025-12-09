#import <Foundation/Foundation.h>

@protocol YTSingleVideoControllerDelegate <NSObject>
- (void)singleVideoController:(id)controller requiresReloadWithContext:(id)context;
- (void)singleVideoController:(id)controller externalPlaybackActiveStateDidChange:(id)arg2;
@end
