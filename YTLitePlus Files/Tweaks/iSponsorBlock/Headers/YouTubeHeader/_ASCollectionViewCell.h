#import <UIKit/UIKit.h>
#import "ASCollectionElement.h"
#import "ASCellNode.h"

@interface _ASCollectionViewCell : UICollectionViewCell
@property (nonatomic, strong, readwrite) ASCollectionElement *element;
- (ASCellNode *)node; // Usually ELMCellNode
@end
