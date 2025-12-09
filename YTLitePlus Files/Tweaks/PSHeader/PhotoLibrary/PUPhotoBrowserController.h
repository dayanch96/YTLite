#import "PUPhotoEditViewController.h"
#import "PLVideoView.h"
#import "PLManagedAsset.h"

NS_CLASS_AVAILABLE_IOS(8_0)
@interface PUPhotoBrowserController : UIViewController <UIActionSheetDelegate>

@property (assign, nonatomic) BOOL isCameraApp;
@property (readonly, assign, nonatomic) PLVideoView *currentVideoView;

- (PLManagedAsset *)currentAsset;
- (UINavigationBar *)navigationBar;

- (BOOL)isEditingVideo;

- (id)_toolbarButtonForIdentifier:(NSString *)identifier;

- (void)photoEditController:(PUPhotoEditViewController *)controller didFinishWithSavedChanges:(BOOL)change;

@end
