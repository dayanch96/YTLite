#import "ASDisplayNode.h"

@interface ASNodeController : NSObject
@property (nonatomic, strong, readwrite) ASDisplayNode *node;
- (NSArray *)children;
@end
