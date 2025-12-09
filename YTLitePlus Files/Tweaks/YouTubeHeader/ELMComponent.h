#import <Foundation/NSObject.h>

@class ELMNodeController;

@interface ELMComponent : NSObject
- (ELMNodeController *)materializedInstance;
- (ELMComponent *)owningComponent;
- (NSString *)templateURI;
@end
