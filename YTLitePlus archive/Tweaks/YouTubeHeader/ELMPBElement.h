#import "ELMPBType.h"

@interface ELMPBElement : NSObject
@property (nonatomic, strong, readwrite) ELMPBType *type;
- (id)properties;
@end