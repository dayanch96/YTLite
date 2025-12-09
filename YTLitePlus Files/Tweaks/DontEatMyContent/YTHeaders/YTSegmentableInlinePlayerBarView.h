#import "YTPlayerBarProtocol.h"
#import "YTPlayerViewController.h"

@interface YTSegmentableInlinePlayerBarView : UIView <YTPlayerBarProtocol>
@property (nonatomic, readonly, assign) CGFloat totalTime;
@property (nonatomic, readwrite, strong) YTPlayerViewController *playerViewController;
@end
