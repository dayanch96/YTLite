#import "MLHAMPlayer.h"
#import "MLPlayerDelegate.h"

@interface MLHAMQueuePlayer : MLHAMPlayer
@property (nonatomic, weak, readwrite) id <MLPlayerDelegate> delegate;
- (void)internalSetRate;
@end