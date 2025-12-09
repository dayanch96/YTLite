#import "YTIFormattedStringLabel.h"
#import "YTSlimVideoScrollableDetailsActionsView.h"

@interface YTSlimVideoDetailsActionView : UIView
@property (nonatomic, strong, readwrite) YTIFormattedStringLabel *label;
@property (nonatomic, weak, readwrite) YTSlimVideoScrollableDetailsActionsView *visibilityDelegate;
@property (nonatomic) __weak id delegate;
@property (nonatomic, assign, readwrite, getter=isToggled) BOOL toggled;
- (instancetype)initWithSlimMetadataButtonSupportedRenderer:(id)renderer;
@end
