#import <AVKit/AVKit.h>
#import "MLAVAssetPlayerDelegate.h"

@interface MLAVAssetPlayer : NSObject
@property (nonatomic, assign, readwrite) float rate;
@property (nonatomic, weak, readwrite) id <MLAVAssetPlayerDelegate> delegate;
- (AVPlayerItem *)playerItem;
@end