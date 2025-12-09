#import <UIKit/UIKit.h>

@interface YTReelContentView : UIView
@property (nonatomic, assign, readwrite) BOOL alwaysShowShortsProgressBar;
- (void)setEmptyStateVisible:(BOOL)visible;
@end
