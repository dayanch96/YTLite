#import "ASTextNode.h"
#import "ELMElement.h"

@interface ELMTextNode : ASTextNode
@property (atomic, strong, readwrite) ELMElement *element;
- (instancetype)initWithElement:(ELMElement *)element context:(id)context;
@end
