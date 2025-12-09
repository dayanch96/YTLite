#include "YTQTMButton.h"
#import "YTQTMButton.h"

@protocol YTSlimVideoDetailsActionViewDelegate <NSObject>
- (void)didTapButton:(YTQTMButton *)button fromRect:(CGRect)rect inView:(UIView *)view;
- (void)handleLongPressOnButton:(YTQTMButton *)button fromRect:(CGRect)rect inView:(UIView *)view;
@end
