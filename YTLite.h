#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <rootless.h>
#import <Photos/Photos.h>
#import "../YouTubeHeader/YTAlertView.h"
#import "../YouTubeHeader/YTIGuideResponse.h"
#import "../YouTubeHeader/YTIGuideResponseSupportedRenderers.h"
#import "../YouTubeHeader/YTIPivotBarSupportedRenderers.h"
#import "../YouTubeHeader/YTIPivotBarRenderer.h"
#import "../YouTubeHeader/YTIBrowseRequest.h"
#import "../YouTubeHeader/YTISectionListRenderer.h"
#import "../YouTubeHeader/YTQTMButton.h"
#import "../YouTubeHeader/YTIButtonRenderer.h"
#import "../YouTubeHeader/YTVideoQualitySwitchOriginalController.h"
#import "../YouTubeHeader/YTPlayerViewController.h"
#import "../YouTubeHeader/YTWatchController.h"
#import "../YouTubeHeader/YTPlayerOverlay.h"
#import "../YouTubeHeader/YTPlayerOverlayProvider.h"
#import "../YouTubeHeader/YTSettingsViewController.h"
#import "../YouTubeHeader/YTSettingsSectionItem.h"
#import "../YouTubeHeader/YTSettingsSectionItemManager.h"
#import "../YouTubeHeader/YTSettingsPickerViewController.h"
#import "../YouTubeHeader/YTUIUtils.h"
#import "../YouTubeHeader/YTIMenuConditionalServiceItemRenderer.h"
#import "../YouTubeHeader/YTToastResponderEvent.h"
#import "../YouTubeHeader/YTPageStyleController.h"

static inline NSBundle *YTLiteBundle() {
    static NSBundle *bundle = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        NSString *tweakBundlePath = [[NSBundle mainBundle] pathForResource:@"YTLite" ofType:@"bundle"];
        NSString *rootlessBundlePath = ROOT_PATH_NS("/Library/Application Support/YTLite.bundle");

        bundle = [NSBundle bundleWithPath:tweakBundlePath ?: rootlessBundlePath];
    });

    return bundle;
}

static inline NSString *LOC(NSString *key) {
    return [YTLiteBundle() localizedStringForKey:key value:nil table:nil];
}

BOOL kNoAds;
BOOL kBackgroundPlayback;
BOOL kNoCast;
BOOL kNoNotifsButton;
BOOL kNoSearchButton;
BOOL kNoVoiceSearchButton;
BOOL kStickyNavbar;
BOOL kNoSubbar;
BOOL kNoYTLogo;
BOOL kHideAutoplay;
BOOL kHideSubs;
BOOL kNoHUDMsgs;
BOOL kHidePrevNext;
BOOL kReplacePrevNext;
BOOL kNoDarkBg;
BOOL kEndScreenCards;
BOOL kNoFullscreenActions;
BOOL kPersistentProgressBar;
BOOL kNoRelatedVids;
BOOL kNoPromotionCards;
BOOL kNoWatermarks;
BOOL kMiniplayer;
BOOL kPortraitFullscreen;
BOOL kCopyWithTimestamp;
BOOL kDisableAutoplay;
BOOL kDisableAutoCaptions;
BOOL kNoContentWarning;
BOOL kClassicQuality;
BOOL kExtraSpeedOptions;
BOOL kDontSnapToChapter;
BOOL kRedProgressBar;
BOOL kNoHints;
BOOL kNoFreeZoom;
BOOL kAutoFullscreen;
BOOL kExitFullscreen;
BOOL kNoDoubleTapToSeek;
BOOL kShortsOnlyMode;
BOOL kHideShorts;
BOOL kShortsProgress;
BOOL kPinchToFullscreenShorts;
BOOL kShortsToRegular;
BOOL kResumeShorts;
BOOL kHideShortsLogo;
BOOL kHideShortsSearch;
BOOL kHideShortsCamera;
BOOL kHideShortsMore;
BOOL kHideShortsSubscriptions;
BOOL kHideShortsLike;
BOOL kHideShortsDislike;
BOOL kHideShortsComments;
BOOL kHideShortsRemix;
BOOL kHideShortsShare;
BOOL kHideShortsAvatars;
BOOL kHideShortsThanks;
BOOL kHideShortsSource;
BOOL kHideShortsChannelName;
BOOL kHideShortsDescription;
BOOL kHideShortsAudioTrack;
BOOL kHideShortsPromoCards;
BOOL kRemoveLabels;
BOOL kRemoveIndicators;
BOOL kReExplore;
BOOL kAddExplore;
BOOL kRemoveShorts;
BOOL kRemoveSubscriptions;
BOOL kRemoveUploads;
BOOL kRemoveLibrary;
BOOL kCopyVideoInfo;
BOOL kPostManager;
BOOL kSavePostImage;
BOOL kSaveProfilePhoto;
BOOL kCopyCommentText;
BOOL kSavePost;
BOOL kFixAlbums;
BOOL kRemovePlayNext;
BOOL kNoContinueWatching;
BOOL kNoSearchHistory;
BOOL kNoRelatedWatchNexts;
BOOL kStickSortComments;
BOOL kHideSortComments;
BOOL kPlaylistOldMinibar;
BOOL kDisableRTL;
BOOL kAdvancedMode;
BOOL kAdvancedModeReminder;
int kPivotIndex;

@interface YTSettingsSectionItemManager (Custom)
@property (nonatomic, strong) NSMutableDictionary *prefs;
@property (nonatomic, strong) NSString *prefsPath;
- (void)updatePrefsForKey:(NSString *)key enabled:(BOOL)enabled;
- (void)updateIntegerPrefsForKey:(NSString *)key intValue:(NSInteger)intValue;
@end

@interface YTPivotBarView : UIView
@end

@interface YTLightweightQTMButton ()
@property (nonatomic, assign, readwrite, getter=isShouldRaiseOnTouch) BOOL shouldRaiseOnTouch;
@end

@interface YTQTMButton ()
@property (nonatomic, strong, readwrite) YTIButtonRenderer *buttonRenderer;
- (void)setSizeWithPaddingAndInsets:(BOOL)sizeWithPaddingAndInsets;
@end

@interface YTPivotBarItemView : UIView
@property (nonatomic, strong, readwrite) YTQTMButton *navigationButton;
@end

@interface YTRightNavigationButtons : UIView
@property (nonatomic, strong) YTQTMButton *notificationButton;
@property (nonatomic, strong) YTQTMButton *searchButton;
@end

@interface YTSearchViewController : UIViewController
@end

@interface YTNavigationBarTitleView : UIView
@end

@interface YTChipCloudCell : UICollectionViewCell
@end

@interface YTAppViewController : UIViewController
- (void)hidePivotBar;
- (void)showPivotBar;
@end

@interface YTPivotBarViewController : UIViewController
@property (nonatomic, weak, readwrite) YTAppViewController *parentViewController;
- (void)selectItemWithPivotIdentifier:(id)pivotIndentifier;
@end

@interface YTScrollableNavigationController : UINavigationController
@property (nonatomic, weak, readwrite) YTAppViewController *parentViewController;
@end

@interface YTReelWatchRootViewController : UIViewController
@property (nonatomic, weak, readwrite) YTScrollableNavigationController *navigationController;
@end

@interface YTTabsViewController : UIViewController
@property (nonatomic, weak, readwrite) YTScrollableNavigationController *navigationController;
@end

@interface YTReelWatchPlaybackOverlayView : UIView
@end

@interface YTReelContentView : UIView
@property (nonatomic, assign, readonly) YTReelWatchPlaybackOverlayView *playbackOverlay;
@end

@interface YTShortsPlayerViewController : UIViewController
@property (nonatomic, weak, readwrite) YTScrollableNavigationController *navigationController;
@end

@interface YTIVideoDetails ()
@property (nonatomic, copy, readwrite) NSString *title;
@property (nonatomic, copy, readwrite) NSString *shortDescription;
@end

@interface YTPlayerViewController (YTAFS)
@property (nonatomic, assign, readonly) YTPlayerResponse *playerResponse;
@property (nonatomic, weak, readwrite) UIViewController *parentViewController;
@property (readonly, nonatomic) NSString *contentVideoID;
- (void)setActiveCaptionTrack:(id)arg1;
- (void)shortsToRegular;
- (void)autoFullscreen;
- (void)turnOffCaptions;
@end

@interface YTPlayerView : UIView
@property (nonatomic, weak, readwrite) YTPlayerViewController *playerViewDelegate;
- (void)turnShortsOnlyModeOff:(UILongPressGestureRecognizer *)gesture;
@end

@interface YTEngagementPanelIdentifier : NSObject
@property (nonatomic, copy, readonly) NSString *identifierString;
@end

@interface YTEngagementPanelHeaderView : UIView
@property (nonatomic, assign, readonly) YTQTMButton *closeButton;
@end

@interface YTWatchViewController : UIViewController
@property (nonatomic, weak, readwrite) YTPlayerViewController *playerViewController;
@end

@interface YTEngagementPanelContainerController : UIViewController
@property (nonatomic, weak, readwrite) YTWatchViewController *parentViewController;
@end

@interface YTEngagementPanelNavigationController : UIViewController
@property (nonatomic, weak, readwrite) YTEngagementPanelContainerController *parentViewController;
@end

@interface YTMainAppEngagementPanelViewController : UIViewController
@property (nonatomic, weak, readwrite) YTEngagementPanelNavigationController *parentViewController;
@end

@interface YTEngagementPanelView : UIView
@property (nonatomic, weak, readwrite) YTMainAppEngagementPanelViewController *resizeDelegate;
@property (nonatomic, copy, readwrite) YTEngagementPanelIdentifier *panelIdentifier;
@property (nonatomic, assign, readonly) YTEngagementPanelHeaderView *headerView;
- (void)didTapCopyInfoButton:(UIButton *)sender;
@end

@interface YTSegmentableInlinePlayerBarView
@property (nonatomic, assign, readwrite) BOOL enableSnapToChapter;
@end

@interface YTPlayabilityResolutionUserActionUIController : NSObject
- (void)confirmAlertDidPressConfirm;
@end

@interface YTReelPlayerButton : UIButton
@end

@interface ELMCellNode
@end

@interface _ASCollectionViewCell : UICollectionViewCell
- (id)node;
@end

@interface YTAsyncCollectionView : UICollectionView
- (void)removeCellsAtIndexPath:(NSIndexPath *)indexPath;
@end

// @interface YTReelWatchPlaybackOverlayView : UIView
// @end

// @interface YTReelWatchHeaderView : UIView
// @end

@interface YTReelTransparentStackView : UIStackView
@end

@interface YTELMView : UIView
@end

@interface ASNodeAncestryEnumerator : NSEnumerator
@property (atomic, assign, readonly) NSMutableArray *allObjects;
@end

@interface ASDisplayNode : NSObject
@property (nonatomic, assign, readonly) UIViewController *closestViewController;
@property (atomic, assign, readonly) ASNodeAncestryEnumerator *supernodes;
@property (atomic, copy, readwrite) NSArray *yogaChildren;
@property (atomic) CALayer *layer;
@end

@interface ELMContainerNode : ASDisplayNode
@property (nonatomic, strong, readwrite) NSString *copiedComment;
@end

@interface ELMExpandableTextNode : ASDisplayNode
@property (atomic, assign, readonly) ASDisplayNode *currentTextNode;
@end

@interface ASNetworkImageNode : ASDisplayNode
@property (atomic, copy, readwrite) NSURL *URL;
@end

@interface ASTextNode : ASDisplayNode
@property (atomic, copy, readwrite) NSAttributedString *attributedText;
@end

@interface _ASDisplayView : UIView
@property (nonatomic, strong, readwrite) ASDisplayNode *keepalive_node;
- (void)postManager:(UILongPressGestureRecognizer *)sender;
- (void)saveImage:(UILongPressGestureRecognizer *)sender;
- (void)savePFP:(UILongPressGestureRecognizer *)sender;
- (void)copyComment:(UILongPressGestureRecognizer *)sender;
@end

@interface MLHAMQueuePlayer : NSObject
@property id playerEventCenter;
-(void)setRate:(float)rate;
@end

@interface YTVarispeedSwitchControllerOption : NSObject
- (id)initWithTitle:(id)title rate:(float)rate;
@end

@interface HAMPlayerInternal : NSObject
- (void)setRate:(float)rate;
@end

@interface MLPlayerEventCenter : NSObject
- (void)broadcastRateChange:(float)rate;
@end

@interface YTMainAppVideoPlayerOverlayViewController : UIViewController
@property (readonly, nonatomic) CGFloat mediaTime;
@property (readonly, nonatomic) NSString *videoID;
@end