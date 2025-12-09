#import "PHAsset.h"

NS_CLASS_AVAILABLE_IOS(8_0)
@interface PUVideoEditViewController : UIViewController <UIActionSheetDelegate>
- (PHAsset *)_videoAsset;
- (void)_handleMainActionButton:(id)arg1;
- (void)_handleSaveButton:(id)arg1;
@end
