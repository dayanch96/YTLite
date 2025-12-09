#import "YTHeaderContentComboViewController.h"

@interface YTWrapperSplitViewController : YTHeaderContentComboViewController
- (void)updateSplitPane;
- (void)updateSplitPane_compact;
- (void)updateSplitPane_regular;
- (void)maybeSendContentUpdateWithType:(NSUInteger)type;
@end
