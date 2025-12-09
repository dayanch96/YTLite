#import <Foundation/Foundation.h>

@class ELMNodeController;

@interface ELMComponent : NSObject
- (ELMNodeController *)materializedInstance;
- (NSString *)templateURI;
@end
