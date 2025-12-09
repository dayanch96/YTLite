#import "HAMFormat.h"

@interface HAMChunk : NSObject
@property (nonatomic, assign, readonly) NSInteger loadStatus;
- (id <HAMFormat>)format;
@end
