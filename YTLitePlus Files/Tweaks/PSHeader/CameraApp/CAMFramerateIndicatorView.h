#import <UIKit/UIKit.h>

NS_CLASS_AVAILABLE_IOS(9_0)
@interface CAMFramerateIndicatorView : UIView

@property (nonatomic, readonly) UIImageView *_borderImageView;
@property (nonatomic, readonly) UILabel *_label;
@property (assign, nonatomic) NSInteger layoutStyle;
@property (assign, nonatomic) NSInteger style;  

- (NSInteger)_framesPerSecond;

- (NSString *)_labelText;

- (UILabel *)_bottomLabel;
- (UILabel *)_topLabel;

- (void)_updateForAppearanceChange;
- (void)_updateLabels;

@end
