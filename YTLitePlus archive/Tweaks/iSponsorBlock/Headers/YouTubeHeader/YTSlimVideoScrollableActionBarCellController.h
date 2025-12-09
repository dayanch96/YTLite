#import "YTSlimVideoScrollableActionBarCellControllerDelegate.h"
#import "YTInnerTubeCellController.h"

@interface YTSlimVideoScrollableActionBarCellController : YTInnerTubeCellController
@property (nonatomic, weak, readwrite) NSObject <YTSlimVideoScrollableActionBarCellControllerDelegate> *delegate;
@end