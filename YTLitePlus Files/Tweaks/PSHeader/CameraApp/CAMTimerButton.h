#import "CAMExpandableMenuButton.h"

NS_CLASS_AVAILABLE_IOS(8_0)
@interface CAMTimerButton : CAMExpandableMenuButton

@property NSInteger duration;

- (NSString *)titleForMenuItemAtIndex:(NSUInteger)index;

- (NSInteger)numberOfMenuItems;

@end
