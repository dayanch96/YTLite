#import "MLFormat.h"

@interface MLPlatypusABRLoader : NSObject
- (NSArray <MLFormat *> *)formatsForFormatIDs:(const void *)formatIDs;
@end
