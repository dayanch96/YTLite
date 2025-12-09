#import "YTPlayerViewController.h"
#import "YTReelContentView.h"

@interface YTReelPlayerViewController : UIViewController
@property (nonatomic, strong, readwrite) YTPlayerViewController *player;
- (YTReelContentView *)contentView;
- (NSString *)videoId;
@end
