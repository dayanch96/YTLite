#import "YTSlimVideoDetailsActionViewDelegate.h"

@interface YTSlimVideoScrollableDetailsActionsView : UIScrollView
@property (nonatomic, weak, readwrite) NSObject <YTSlimVideoDetailsActionViewDelegate> *videoActionsDelegate;
@end
