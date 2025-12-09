#import "ASNodeController.h"
#import "ELMComponent.h"

@interface ELMNodeController : ASNodeController
- (const void *)materializationContext;
- (ELMComponent *)owningComponent;
- (NSArray <ELMComponent *> *)children;
@end
