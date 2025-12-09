#import "GPBExtensionDescriptor.h"
#import "GPBUnknownFieldSet.h"

@interface GPBMessage : NSObject
@property (nonatomic, copy, readwrite) GPBUnknownFieldSet *unknownFields;
+ (instancetype)parseFromData:(NSData *)data;
+ (instancetype)parseFromData:(NSData *)data error:(NSError **)error;
+ (instancetype)deserializeFromString:(NSString *)str;
+ (GPBExtensionDescriptor *)descriptor;
- (instancetype)messageForFieldNumber:(NSUInteger)fieldNumber;
- (instancetype)messageForFieldNumber:(NSUInteger)fieldNumber messageClass:(Class)messageClass;
- (NSData *)data;
- (id)firstSubmessage;
- (id)getExtension:(GPBExtensionDescriptor *)extension;
- (BOOL)hasExtension:(GPBExtensionDescriptor *)extension;
- (void)clear;
- (void)setExtension:(GPBExtensionDescriptor *)extension value:(id)value;
- (void)mergeFrom:(GPBMessage *)other;
@end
