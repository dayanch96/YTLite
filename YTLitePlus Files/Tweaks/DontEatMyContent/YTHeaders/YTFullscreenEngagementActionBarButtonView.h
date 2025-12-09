#import "Block.h"
#import "YTIFormattedStringLabel.h"

@interface YTFullscreenEngagementActionBarButtonView : UIView
@property (nonatomic, assign, readwrite, getter=isToggled) BOOL toggled;
@property (nonatomic, strong, readwrite) YTIFormattedStringLabel *label;
@end
