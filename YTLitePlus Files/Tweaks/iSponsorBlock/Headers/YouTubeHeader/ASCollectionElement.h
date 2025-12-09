#import "ASCellNode.h"
#import "ASDimension.h"

@interface ASCollectionElement : NSObject
@property (nonatomic, assign) ASSizeRange constrainedSize;
- (ASCellNode *)node;
@end
