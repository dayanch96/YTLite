#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import "Utils/NSBundle+YTLite.h"
#import "Utils/YTLUserDefaults.h"
#import "Utils/Reachability.h"
#import "YouTubeHeaders.h"

#define LOC(key) [NSBundle.ytl_defaultBundle localizedStringForKey:key value:nil table:nil]

#define ytlBool(key) [[YTLUserDefaults standardUserDefaults] boolForKey:key]
#define ytlInt(key) [[YTLUserDefaults standardUserDefaults] integerForKey:key]

#define ytlSetBool(value, key) [[YTLUserDefaults standardUserDefaults] setBool:(value) forKey:(key)]
#define ytlSetInt(value, key) [[YTLUserDefaults standardUserDefaults] setInteger:(value) forKey:(key)]

@interface YTTouchFeedbackController : YTCollectionViewCell
@property (nonatomic, strong, readwrite) UIColor *feedbackColor;
@end

@interface ABCSwitch : UIControl
@property (nonatomic, strong, readwrite) UIColor *onTintColor;
@end

@interface YTSettingsCell ()
- (void)setIndicatorIcon:(int)icon;
- (void)setTitleDescription:(id)titleDescription;
@end

@interface YTSettingsSectionItemManager (Custom)
- (YTSettingsSectionItem *)switchWithTitle:(NSString *)title key:(NSString *)key;
- (YTSettingsSectionItem *)linkWithTitle:(NSString *)title description:(NSString *)description link:(NSString *)link;
- (UIImage *)resizedImageNamed:(NSString *)iconName;
@end

@interface YTLightweightQTMButton ()
@property (nonatomic, assign, readwrite, getter=isShouldRaiseOnTouch) BOOL shouldRaiseOnTouch;
@end

@interface YTQTMButton ()
@property (nonatomic, strong, readwrite) YTIButtonRenderer *buttonRenderer;
- (void)setSizeWithPaddingAndInsets:(BOOL)sizeWithPaddingAndInsets;
- (BOOL)yt_isVisible;
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

@interface YTHeaderContentComboViewController : UIViewController
- (void)refreshPivotBar;
@end

@interface YTPivotBarViewController : UIViewController
@end

@interface YTAppViewController : UIViewController
@property (nonatomic, assign, readonly) YTPivotBarViewController *pivotBarViewController;
- (void)hidePivotBar;
- (void)showPivotBar;
@end

@interface YTPivotBarView : UIView
- (void)selectItemWithPivotIdentifier:(id)pivotIndentifier;
@end

@interface YTPivotBarViewController ()
@property (nonatomic, weak, readwrite) YTAppViewController *parentViewController;
@property (nonatomic, copy, readwrite) NSString *selectedPivotIdentifier;
- (YTPivotBarView *)pivotBarView;
- (void)selectItemWithPivotIdentifier:(id)pivotIndentifier;
@end

@interface YTPivotBarItemView : UIView
@property (nonatomic, strong, readwrite) YTIPivotBarItemRenderer *renderer;
@property (nonatomic, weak, readwrite) YTPivotBarViewController *delegate;
@property (nonatomic, strong, readwrite) YTQTMButton *navigationButton;
- (void)manageTab:(UILongPressGestureRecognizer *)gesture;
@end

@interface YTScrollableNavigationController : UINavigationController
@property (nonatomic, weak, readwrite) YTAppViewController *parentViewController;
@end

@interface YTTabsViewController : UIViewController
@property (nonatomic, weak, readwrite) YTScrollableNavigationController *navigationController;
@end

@interface YTIVideoDetails : NSObject
@property (nonatomic, copy, readwrite) NSString *title;
@property (nonatomic, copy, readwrite) NSString *shortDescription;
@end

@interface YTIPlayerResponse : NSObject
@property (nonatomic, assign, readonly) YTIVideoDetails *videoDetails;
@end

@interface YTPlayerResponse : NSObject
@property (nonatomic, assign, readonly) YTIPlayerResponse *playerData;
@end

@interface MLQuickMenuVideoQualitySettingFormatConstraint : NSObject
- (instancetype)initWithVideoQualitySetting:(int)settings formatSelectionReason:(NSInteger)reason qualityLabel:(NSString *)label;
@end

@interface MLFormat : NSObject
@property (nonatomic, assign, readonly) NSString *qualityLabel;
@property (nonatomic, assign, readonly) int singleDimensionResolution;
@end

@interface YTSingleVideoTime : NSObject
@property (nonatomic, assign, readonly) CGFloat time;
@end

@interface YTSingleVideoController : NSObject
@property (nonatomic, assign, readonly) float playbackRate;
@property (nonatomic, assign, readonly) CGFloat totalMediaTime;
@property (nonatomic, assign, readonly) NSArray *selectableVideoFormats;
- (void)setVideoFormatConstraint:(MLQuickMenuVideoQualitySettingFormatConstraint *)formatConstraint;
@end

@interface YTPlayerViewController : UIViewController
@property (nonatomic, assign, readonly) YTPlayerResponse *playerResponse;
@property (nonatomic, assign, readonly) YTSingleVideoController *activeVideo;
@property (nonatomic, weak, readwrite) UIViewController *activeVideoPlayerOverlay;
@property (nonatomic, weak, readwrite) UIViewController *parentViewController;
@property (nonatomic, weak, readwrite) UIViewController *UIDelegate;
@property (nonatomic, readonly) NSString *contentVideoID;
- (void)setActiveCaptionTrack:(id)track;
- (void)setPlaybackRate:(CGFloat)rate;
- (void)shortsToRegular;
- (void)autoFullscreen;
- (void)turnOffCaptions;
- (void)setAutoSpeed;
- (void)autoQuality;
- (void)play;
- (void)pause;
@end

@interface YTPlayerView : UIView
@property (nonatomic, weak, readwrite) YTPlayerViewController *playerViewDelegate;
@property (nonatomic, strong, readwrite) UIView *overlayView;
@end

@interface YTMainAppControlsOverlayView : UIView
@property (nonatomic, strong, readwrite) YTPlayerViewController *playerViewController;
@end

@interface YTReelWatchRootViewController : UIViewController
@property (nonatomic, weak, readwrite) YTScrollableNavigationController *navigationController;
@end

@interface YTReelWatchPlaybackOverlayView : UIView
@end

@interface YTReelContentView : UIView
@property (nonatomic, assign, readonly) YTReelWatchPlaybackOverlayView *playbackOverlay;
- (void)turnShortsOnlyModeOff:(UILongPressGestureRecognizer *)gesture;
@end

@interface YTReelPlayerViewController : UIViewController
@property (nonatomic, strong, readwrite) YTPlayerViewController *player;
- (void)reelContentViewRequestsAdvanceToNextVideo:(id)video;
@end

@interface YTShortsPlayerViewController : YTReelPlayerViewController
@property (nonatomic, weak, readwrite) YTScrollableNavigationController *navigationController;
@end

@interface YTPivotBarViewController ()
@property (nonatomic, weak, readwrite) YTShortsPlayerViewController *scrubberDelegate;
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

@interface YTSegmentableInlinePlayerBarView : UIView
@property (nonatomic, assign, readwrite) BOOL enableSnapToChapter;
@end

@interface YTPlayabilityResolutionUserActionUIController : NSObject
- (void)confirmAlertDidPressConfirm;
@end

@interface YTReelPlayerButton : YTQTMButton
@end

@interface ELMCellNode
@end

@interface _ASCollectionViewCell : UICollectionViewCell
- (id)node;
@end

@interface YTAsyncCollectionView : UICollectionView
- (void)removeCellsAtIndexPath:(NSIndexPath *)indexPath;
@end

@interface YTReelTransparentStackView : UIStackView
@end

@interface YTELMView : UIView
@end

@interface ASNodeAncestryEnumerator : NSEnumerator
@property (atomic, assign, readonly) NSMutableArray *allObjects;
@end

@interface ASDisplayNode ()
@property (nonatomic, assign, readonly) UIViewController *closestViewController;
@property (atomic, assign, readonly) ASNodeAncestryEnumerator *supernodes;
// @property (atomic, copy, readwrite) NSArray *yogaChildren;
@property (atomic) CALayer *layer;
@end

@interface ELMContainerNode : ASDisplayNode
@property (nonatomic, strong, readwrite) NSString *copiedComment;
@property (nonatomic, strong, readwrite) NSURL *copiedURL;
@end

@interface ELMExpandableTextNode : ASDisplayNode
@property (atomic, assign, readonly) ASDisplayNode *currentTextNode;
@end

@interface ASNetworkImageNode : ASDisplayNode
@property (atomic, copy, readwrite) NSURL *URL;
@end

@interface YTImageZoomNode : ASNetworkImageNode
@end

@interface ASTextNode : ASDisplayNode
@property (atomic, copy, readwrite) NSAttributedString *attributedText;
@end

@interface _ASDisplayView : UIView
@property (nonatomic, strong, readwrite) ASDisplayNode *keepalive_node;
- (void)postManager:(UILongPressGestureRecognizer *)sender;
- (void)savePFP:(UILongPressGestureRecognizer *)sender;
- (void)commentManager:(UILongPressGestureRecognizer *)sender;
@end

@interface YTVarispeedSwitchControllerOption : NSObject
- (id)initWithTitle:(NSString *)title rate:(float)rate;
@end

@interface YTVarispeedSwitchController : NSObject
- (void)addActionForOption:(YTVarispeedSwitchControllerOption *)option;
@end

@interface YTLabel : UILabel
- (void)setFontAttributes:(id)attributes text:(NSString *)text;
@end

@interface YTInlinePlayerScrubUserEducationView : UIView
@property (nonatomic, assign, readwrite) NSUInteger labelType;
- (YTLabel *)userEducationLabel;
- (void)setVisible:(BOOL)visible;
@end

@interface YTMainAppVideoPlayerOverlayViewController : UIViewController
@property (nonatomic, weak, readwrite) YTPlayerViewController *parentViewController;
- (CGFloat)currentPlaybackRate;
@end

@interface YTInlinePlayerBarContainerView : UIView
@property (nonatomic, strong, readwrite) YTLabel *durationLabel;
@property (nonatomic, strong, readwrite) NSString *endTimeString;
@end

@interface YTMainAppVideoPlayerOverlayView : UIView
@property (nonatomic, assign, readonly) YTInlinePlayerScrubUserEducationView *scrubUserEducationView;
@property (nonatomic, strong, readwrite) YTInlinePlayerBarContainerView *playerBar;
@property (nonatomic, weak, readwrite) YTMainAppVideoPlayerOverlayViewController *delegate;
- (void)speedmasterYtLite:(UILongPressGestureRecognizer *)sender;
@end

@interface YTMainAppVideoPlayerOverlayViewController ()
@property (nonatomic, assign, readonly) YTMainAppVideoPlayerOverlayView * videoPlayerOverlayView;
@property (readonly, nonatomic) CGFloat mediaTime;
@property (readonly, nonatomic) NSString *videoID;
- (void)setPlaybackRate:(CGFloat)rate;
- (CGFloat)currentPlaybackRate;
@end

@interface YTSpeedmasterController : NSObject
@end

@interface YTFormattedStringLabel : UILabel
@end

@interface YTActionSheetHeaderView : UIView
- (void)showHeaderDivider;
@end

@interface YTActionSheetAction : NSObject
+ (instancetype)actionWithTitle:(NSString *)title iconImage:(UIImage *)image style:(NSInteger)style handler:(void (^)(void))handler;
+ (instancetype)actionWithTitle:(NSString *)title iconImage:(UIImage *)image secondaryIconImage:(UIImage *)secondaryIconImage accessibilityIdentifier:(NSString *)identifier handler:(void (^)(void))handler;
+ (instancetype)actionWithTitle:(NSString *)title titleColor:(UIColor *)titleColor iconImage:(UIImage *)image iconColor:(UIColor *)iconColor disableAutomaticButtonColor:(BOOL)autoColor accessibilityIdentifier:(NSString *)identifier handler:(void (^)(void))handler;
@end

@interface YTDefaultSheetController : NSObject
- (void)addAction:(YTActionSheetAction *)action;
- (void)presentFromView:(UIView *)view animated:(BOOL)animated completion:(void(^)(void))completion;
- (void)presentFromViewController:(UIViewController *)vc animated:(BOOL)animated completion:(void(^)(void))completion;
- (void)dismissViewControllerAnimated:(BOOL)animated completion:(void(^)(void))completion;

+ (instancetype)sheetControllerWithParentResponder:(id)parentResponder;
+ (instancetype)sheetControllerWithParentResponder:(id)parentResponder forcedSheetStyle:(NSInteger)style;
+ (instancetype)sheetControllerWithMessage:(NSString *)message delegate:(id)delegate parentResponder:(id)parentResponder;
+ (instancetype)sheetControllerWithMessage:(NSString *)message subMessage:(NSString *)subMessage delegate:(id)delegate parentResponder:(id)parentResponder;
@end