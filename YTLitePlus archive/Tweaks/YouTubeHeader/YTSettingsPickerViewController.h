#import "YTStyledViewController.h"

@interface YTSettingsPickerViewController : YTStyledViewController
- (instancetype)initWithNavTitle:(NSString *)navTitle pickerSectionTitle:(NSString *)pickerSectionTitle rows:(NSArray *)rows selectedItemIndex:(NSUInteger)selectedItemIndex parentResponder:(id)parentResponder;
@end
