#import "ASControlNode.h"

@interface ASTextNode : ASControlNode <UIGestureRecognizerDelegate>
@property (atomic, copy, readwrite) NSAttributedString *attributedText;
@end
