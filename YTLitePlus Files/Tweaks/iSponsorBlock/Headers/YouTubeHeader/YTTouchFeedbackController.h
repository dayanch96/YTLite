#import "YTTouchFeedbackView.h"

@interface YTTouchFeedbackController : NSObject <UIGestureRecognizerDelegate>
@property (nonatomic, strong, readwrite) YTTouchFeedbackView *touchFeedbackView;
- (instancetype)initWithView:(id)view;
@end
