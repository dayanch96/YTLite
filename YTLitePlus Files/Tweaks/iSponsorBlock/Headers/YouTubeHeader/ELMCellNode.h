#import "ASCellNode.h"
#import "ELMElement.h"

@interface ELMCellNode : ASCellNode
@property (atomic, strong, readwrite) ELMElement *element;
@end
