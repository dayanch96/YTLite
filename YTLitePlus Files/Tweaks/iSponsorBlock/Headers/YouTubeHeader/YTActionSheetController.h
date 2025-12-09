#import <UIKit/UIKit.h>

@interface YTActionSheetController : NSObject
+ (instancetype)actionSheetController;
- (void)addCancelActionIfNeeded;
- (void)presentFromViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)(void))completion;
@end