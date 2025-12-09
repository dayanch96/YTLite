#import <Foundation/NSObject.h>

@interface ELMNodeFactory : NSObject
+ (instancetype)sharedInstance;
- (id)nodeWithElement:(id)element materializationContext:(const void *)context;
- (void)registerNodeClass:(Class)cls forTypeExtension:(unsigned int)typeExtension;
@end
