#import <Foundation/NSObject.h>

@interface GPBDescriptor : NSObject
- (void)setupOneofs:(const char **)oneofNames count:(uint32_t)count firstHasIndex:(int32_t)firstHasIndex;
@end
