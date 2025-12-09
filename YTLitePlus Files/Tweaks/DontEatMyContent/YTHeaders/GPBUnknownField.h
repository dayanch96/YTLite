#import <Foundation/NSObject.h>

typedef NS_ENUM(uint8_t, GPBUnknownFieldType) {
    GPBUnknownFieldTypeVarint,
    GPBUnknownFieldTypeFixed32,
    GPBUnknownFieldTypeFixed64,
    GPBUnknownFieldTypeLengthDelimited,
    GPBUnknownFieldTypeGroup,
};

@interface GPBUnknownField : NSObject <NSCopying>
@property (nonatomic, readonly, assign) int32_t number;
@property (nonatomic, readonly, assign) GPBUnknownFieldType type;
@property (nonatomic, readonly, strong) NSData *lengthDelimited;
@end
