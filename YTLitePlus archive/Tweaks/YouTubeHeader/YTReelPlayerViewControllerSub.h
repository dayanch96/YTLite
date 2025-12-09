#import <UIKit/UIViewController.h>
#import "YTReelContentView.h"
#import "YTSingleVideoController.h"

@interface YTReelPlayerViewControllerSub : UIViewController
- (YTSingleVideoController *)currentVideo;
- (YTReelContentView *)contentView;
@end
