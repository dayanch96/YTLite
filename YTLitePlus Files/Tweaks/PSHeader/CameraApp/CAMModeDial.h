#import "CAMModeDialItem.h"

NS_CLASS_AVAILABLE_IOS(7_0)
@interface CAMModeDial : UIView

@property (retain, nonatomic) NSMutableArray<CAMModeDialItem *> * _items;
@property (retain, nonatomic) UIView *_itemsContainerView;

@property (assign) NSUInteger selectedIndex;
@property (assign) NSInteger orientation;

+ (BOOL)wantsVerticalModeDialForTraitCollection:(UITraitCollection *)traitCollection NS_DEPRECATED_IOS(8_0, 9_3);
+ (BOOL)wantsVerticalModeDialForLayoutStyle:(NSInteger)style NS_AVAILABLE_IOS(10_0);

@end
