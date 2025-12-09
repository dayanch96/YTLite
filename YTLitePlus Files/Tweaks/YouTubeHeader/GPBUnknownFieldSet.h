#import "GPBUnknownField.h"

@interface GPBUnknownFieldSet : NSObject <NSCopying>
- (GPBUnknownField *)getField:(int32_t)number;
@end
