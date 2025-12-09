#import <Foundation/NSObject.h>

@protocol ELMController <NSObject>
- (id <ELMController>)materializedInstance;
@end
