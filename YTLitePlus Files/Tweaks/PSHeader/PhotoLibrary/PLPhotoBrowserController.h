#import "PLVideoView.h"
#import "PLManagedAsset.h"

NS_CLASS_AVAILABLE_IOS(5_0)
@interface PLPhotoBrowserController : UIViewController <UIActionSheetDelegate>
@property (assign, nonatomic) BOOL isCameraApp;
@property (readonly, assign, nonatomic) PLVideoView *currentVideoView;
- (PLManagedAsset *)currentAsset;
- (UINavigationBar *)navigationBar;
- (BOOL)isEditingVideo;
- (id)_toolbarButtonForIdentifier:(NSString *)identifier;
@end
