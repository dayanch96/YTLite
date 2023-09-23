#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <rootless.h>
#import "../YouTubeHeader/YTIGuideResponse.h"
#import "../YouTubeHeader/YTIGuideResponseSupportedRenderers.h"
#import "../YouTubeHeader/YTIPivotBarSupportedRenderers.h"
#import "../YouTubeHeader/YTIPivotBarRenderer.h"
#import "../YouTubeHeader/YTIBrowseRequest.h"
#import "../YouTubeHeader/YTISectionListRenderer.h"
#import "../YouTubeHeader/YTQTMButton.h"
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

extern NSBundle *YTLiteBundle();

static inline NSString *LOC(NSString *key) {
    NSBundle *tweakBundle = YTLiteBundle();
    return [tweakBundle localizedStringForKey:key value:nil table:nil];
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
BOOL kNoRelatedVids;
BOOL kNoPromotionCards;
BOOL kNoWatermarks;
BOOL kMiniplayer;
BOOL kPortraitFullscreen;
BOOL kDisableAutoplay;
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
BOOL kHideShorts;
BOOL kShortsProgress;
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
BOOL kHideShortsChannelName;
BOOL kHideShortsDescription;
BOOL kHideShortsAudioTrack;
BOOL kHideShortsPromoCards;
BOOL kRemoveLabels;
BOOL kReExplore;
BOOL kRemoveShorts;
BOOL kRemoveSubscriptions;
BOOL kRemoveUploads;
BOOL kRemoveLibrary;
BOOL kRemovePlayNext;
BOOL kNoContinueWatching;
BOOL kNoSearchHistory;
BOOL kNoCommentSection;
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

@interface YTPivotBarItemView : UIView
@end

@interface YTPivotBarIndicatorView : UIView
@end

@interface YTPivotBarViewController : UIViewController
- (void)selectItemWithPivotIdentifier:(id)pivotIndentifier;
@end

@interface YTRightNavigationButtons : UIView
@property (nonatomic, strong) YTQTMButton *notificationButton;
@property (nonatomic, strong) YTQTMButton *searchButton;
@end

@interface YTSearchView : UIView
@end

@interface YTSearchBarView : UIView
@end

@interface YTNavigationBarTitleView : UIView
@end

@interface YTChipCloudCell : UICollectionViewCell
@end

@interface YTPlayerViewController (YTAFS)
- (void)autoFullscreen;
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

@interface YTReelWatchPlaybackOverlayView : UIView
@end

@interface YTReelTransparentStackView : UIView
@end

@interface YTReelWatchHeaderView : UIView
@end

@interface YTELMView : UIView
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

@interface YTAlertView : UIView
@property (nonatomic, copy, readwrite) NSString *title;
@property (nonatomic, copy, readwrite) NSString *subtitle;
+ (instancetype)infoDialog;
+ (instancetype)confirmationDialogWithAction:(void (^)(void))action actionTitle:(NSString *)actionTitle cancelTitle:(NSString *)cancelTitle;
- (void)show;
@end