#import <Foundation/Foundation.h>

@interface ELMNodeFactory : NSObject
+ (instancetype)sharedInstance;
- (id)nodeWithElement:(id)element materializationContext:(const void *)context;
@end
