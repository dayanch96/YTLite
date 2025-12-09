#import "HAMChunk.h"
#import "HAMFormatSelection.h"

@interface HAMMediaChunk : HAMChunk
@property (nonatomic, assign, readonly) HAMFormatSelection *formatSelection;
@end
