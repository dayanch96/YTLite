#import "YTSlimVideoDetailsActionViewDelegate.h"

@interface YTSlimVideoDetailsActionsView : UIScrollView
@property (nonatomic, weak, readwrite) NSObject <YTSlimVideoDetailsActionViewDelegate> *videoActionsDelegate;
@end