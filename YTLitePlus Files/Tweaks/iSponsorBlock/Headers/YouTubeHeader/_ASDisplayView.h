#import "ASDisplayNode.h"

@interface _ASDisplayView : UIView
@property (nonatomic, copy, readwrite) NSString *accessibilityLabel;
@property (nonatomic) ASDisplayNode *keepalive_node;
@end
