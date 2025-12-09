#import <YouTubeHeader/_ASCollectionViewCell.h>
#import <YouTubeHeader/_ASDisplayView.h>
#import <YouTubeHeader/ASCollectionView.h>
#import <YouTubeHeader/NSArray+YouTube.h>
#import <YouTubeHeader/ELMCellNode.h>
#import <YouTubeHeader/ELMContainerNode.h>
#import <YouTubeHeader/ELMNodeController.h>
#import <YouTubeHeader/ELMNodeFactory.h>
#import <YouTubeHeader/ELMTextNode.h>
#import <YouTubeHeader/UIView+AsyncDisplayKit.h>
#import <YouTubeHeader/YTAlertView.h>
#import <YouTubeHeader/YTAppDelegate.h>
#import <YouTubeHeader/YTAppViewController.h>
#import <YouTubeHeader/YTAsyncCollectionView.h>
#import <YouTubeHeader/YTColorPalette.h>
#import <YouTubeHeader/YTELMView.h>
#import <YouTubeHeader/YTFullscreenEngagementActionBarButtonRenderer.h>
#import <YouTubeHeader/YTFullscreenEngagementActionBarButtonView.h>
#import <YouTubeHeader/YTIButtonSupportedRenderers.h>
#import <YouTubeHeader/YTIFormattedString.h>
#import <YouTubeHeader/YTILikeButtonRenderer.h>
#import <YouTubeHeader/YTIToggleButtonRenderer.h>
#import <YouTubeHeader/YTPageStyleController.h>
#import <YouTubeHeader/YTPlayerViewController.h>
#import <YouTubeHeader/YTQTMButton.h>
#import <YouTubeHeader/YTReelElementAsyncComponentView.h>
#import <YouTubeHeader/YTReelModel.h>
#import <YouTubeHeader/YTReelWatchLikesController.h>
#import <YouTubeHeader/YTReelWatchPlaybackOverlayView.h>
#import <YouTubeHeader/YTRollingNumberNode.h>
#import <YouTubeHeader/YTRollingNumberView.h>
#import <YouTubeHeader/YTShortsPlayerViewController.h>
#import <YouTubeHeader/YTWatchController.h>

@interface YTRollingNumberNode (RYD)
@property (strong, nonatomic) NSString *updatedCount;
@property (strong, nonatomic) NSNumber *updatedCountNumber;
- (void)updateCount:(NSString *)updateCount color:(UIColor *)color;
@end

@interface YTReelWatchPlaybackOverlayView (RYD)
@property (assign, nonatomic) BOOL didGetVote;
@end
