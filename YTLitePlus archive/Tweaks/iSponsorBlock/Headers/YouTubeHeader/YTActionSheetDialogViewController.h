#import "GOODialogView.h"
#import "YTActionSheetDialogViewControllerDelegate.h"

@interface YTActionSheetDialogViewController : UIViewController
@property (nonatomic, weak, readwrite) id <YTActionSheetDialogViewControllerDelegate> delegate;
- (GOODialogView *)actionSheetView;
@end
