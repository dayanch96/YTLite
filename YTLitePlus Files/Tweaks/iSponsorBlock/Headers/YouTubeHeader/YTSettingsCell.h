#import "YTCollectionViewCell.h"

@interface YTSettingsCell : YTCollectionViewCell
@property (nonatomic, assign, readwrite) BOOL enabled;
- (void)setSwitchOn:(BOOL)on animated:(BOOL)animated;
- (void)toggleSwitch;
@end