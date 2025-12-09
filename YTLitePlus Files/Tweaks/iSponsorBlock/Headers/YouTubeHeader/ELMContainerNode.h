#import "ELMElement.h"
#import "ASDisplayNode.h"

@interface ELMContainerNode : ASDisplayNode
@property (atomic, strong, readwrite) ELMElement *element;
@end
