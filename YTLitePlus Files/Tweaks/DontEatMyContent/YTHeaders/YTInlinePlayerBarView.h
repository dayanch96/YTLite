#import "YTPlayerViewController.h"

@interface YTInlinePlayerBarView : UIView
@property (nonatomic, readonly, assign) CGFloat totalTime;
@property (nonatomic, readwrite, strong) YTPlayerViewController *playerViewController;
@end
