#import "YTMultiSizeViewController.h"
#import "YTServiceSectionController.h"

@interface YTCollectionViewController : YTMultiSizeViewController
@property (nonatomic, strong, readwrite) NSArray <YTSectionController *> *sectionControllers; // Normally YTServiceSectionController
- (YTSectionController *)sectionControllerAtIndexPath:(NSIndexPath *)indexPath;
@end
