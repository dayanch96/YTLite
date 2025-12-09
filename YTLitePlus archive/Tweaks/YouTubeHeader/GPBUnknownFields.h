#import <Foundation/NSArray.h>
#import "GPBMessage.h"
#import "GPBUnknownField.h"

@interface GPBUnknownFields : NSObject <NSCopying, NSFastEnumeration>
- (instancetype)initFromMessage:(GPBMessage *)message;
- (NSArray <GPBUnknownField *> *)fields:(int32_t)fieldNumber;
- (void)addFieldNumber:(int32_t)fieldNumber fixed32:(uint32_t)value;
- (void)addFieldNumber:(int32_t)fieldNumber fixed64:(uint64_t)value;
- (void)addFieldNumber:(int32_t)fieldNumber lengthDelimited:(NSData *)value;
@end
