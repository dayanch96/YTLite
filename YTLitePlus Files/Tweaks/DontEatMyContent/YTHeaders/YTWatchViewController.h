#import "YTPlayerViewController.h"
#import "YTWatchPullToFullController.h"
#import "YTWatchPlayerViewLayoutSource.h"

@interface YTWatchViewController : UIViewController <YTWatchPlayerViewLayoutSource>
@property (nonatomic, weak, readwrite) YTPlayerViewController *playerViewController;
@property (nonatomic, strong, readwrite) YTWatchPullToFullController *pullToFullController;
- (NSUInteger)allowedFullScreenOrientations;
@end
