#import <AVKit/AVKit.h>
#import "MLAVAssetPlayerDelegate.h"

@interface MLAVAssetPlayer : NSObject
- (AVPlayerItem *)playerItem;
@property (nonatomic, weak, readwrite) id <MLAVAssetPlayerDelegate> delegate;
@end