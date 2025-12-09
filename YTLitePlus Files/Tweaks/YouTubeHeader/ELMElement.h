#import <Foundation/NSObject.h>

@interface ELMElement : NSObject
- (id)newChildElementWithInstance:(const void *)instance;
- (const void *)instance;
@end
