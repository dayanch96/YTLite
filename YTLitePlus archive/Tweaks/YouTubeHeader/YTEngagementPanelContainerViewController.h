#import <UIKit/UIKit.h>

@interface YTEngagementPanelContainerViewController : UIViewController
@property (nonatomic, assign, readwrite, getter=isWatchLandscapeEngagementPanel) BOOL watchLandscapeEngagementPanel; // YouTube 20.08.3+
@property (nonatomic, assign, readwrite, getter=isLandscapeEngagementPanel) BOOL landscapeEngagementPanel; // Removed in YouTube 20.08.3
- (BOOL)isPeekingSupported;
@end