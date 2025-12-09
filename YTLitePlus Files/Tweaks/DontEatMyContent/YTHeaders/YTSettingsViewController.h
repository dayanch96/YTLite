#import "YTIIcon.h"
#import "YTSettingsSectionController.h"
#import "YTSettingsSectionItem.h"
#import "YTStyledViewController.h"

@interface YTSettingsViewController : YTStyledViewController
- (NSMutableDictionary <NSNumber *, YTSettingsSectionController *> *)settingsSectionControllers;
- (void)setSectionItems:(NSMutableArray <YTSettingsSectionItem *> *)sectionItems forCategory:(NSInteger)category title:(NSString *)title titleDescription:(NSString *)titleDescription headerHidden:(BOOL)headerHidden;
- (void)setSectionItems:(NSMutableArray <YTSettingsSectionItem *> *)sectionItems forCategory:(NSInteger)category title:(NSString *)title icon:(YTIIcon *)icon titleDescription:(NSString *)titleDescription headerHidden:(BOOL)headerHidden; // 19.03.2+
- (void)pushViewController:(UIViewController *)viewController;
- (void)reloadData;
@end
