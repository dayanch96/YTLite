#import <UIKit/UIKit.h>

NS_CLASS_AVAILABLE_IOS(7_0)
@interface CAMFilterButton : UIButton <NSCoding>

@property (readonly) UIImageView *_circlesImageView;
@property (getter=isOn) BOOL on;
@property UIEdgeInsets tappableEdgeInsets;

+ (instancetype)filterButton;

- (void)_commonCAMFilterButtonInitialization;

- (UIImage *)_filterImage;
- (UIImage *)_filterOnImage;

- (CGFloat)_selectedIndicatorAlpha;

@end
