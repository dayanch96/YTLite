#import "MLAVPlayerLayerView.h"
#import "MLAVPlayer.h"
#import "MLAVPlayerViewDelegate.h"

@interface MLAVPIPPlayerLayerView : MLAVPlayerLayerView
@property (nonatomic, readonly, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, readwrite, weak) NSObject <MLAVPlayerViewDelegate> *delegate;
@end