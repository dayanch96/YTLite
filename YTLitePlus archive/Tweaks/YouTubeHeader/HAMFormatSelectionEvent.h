#import "HAMEvent.h"
#import "HAMFormatSelection.h"

@interface HAMFormatSelectionEvent : HAMEvent
@property (nonatomic, readonly, strong) HAMFormatSelection *formatSelection;
@end
