#import <version.h>
#import <PSHeader/Misc.h>
#import <YouTubeHeader/ASCollectionView.h>
#import <YouTubeHeader/ELMCellNode.h>
#import <YouTubeHeader/ELMContainerNode.h>
#import <YouTubeHeader/MLDefaultPlayerViewFactory.h>
#import <YouTubeHeader/MLPIPController.h>
#import <YouTubeHeader/QTMIcon.h>
#import <YouTubeHeader/YTAppDelegate.h>
#import <YouTubeHeader/YTAppViewControllerImpl.h>
#import <YouTubeHeader/YTBackgroundabilityPolicy.h>
#import <YouTubeHeader/YTColor.h>
#import <YouTubeHeader/YTColorPalette.h>
#import <YouTubeHeader/YTCommonColorPalette.h>
#import <YouTubeHeader/YTIIcon.h>
#import <YouTubeHeader/YTLocalPlaybackController.h>
#import <YouTubeHeader/YTMainAppControlsOverlayView.h>
#import <YouTubeHeader/YTMainAppVideoPlayerOverlayViewController.h>
#import <YouTubeHeader/YTPageStyleController.h>
#import <YouTubeHeader/YTPlaybackStrippedWatchController.h>
#import <YouTubeHeader/YTPlayerPIPController.h>
#import <YouTubeHeader/YTPlayerStatus.h>
#import <YouTubeHeader/YTSettingsSectionItemManager.h>
#import <YouTubeHeader/YTSystemNotifications.h>
#import <YouTubeHeader/YTTouchFeedbackController.h>
#import <YouTubeHeader/YTUIResources.h>
#import <YouTubeHeader/YTWatchViewController.h>
#import "Header.h"
#import "../YTVideoOverlay/Header.h"
#import "../YTVideoOverlay/Init.x"

@interface YTMainAppControlsOverlayView (YouPiP)
- (void)didPressPiP:(id)arg;
@end

@interface YTInlinePlayerBarContainerView (YouPiP)
- (void)didPressPiP:(id)arg;
@end

@interface ASCollectionView (YP)
@property (retain, nonatomic) UIButton *pipButton;
@property (retain, nonatomic) YTTouchFeedbackController *pipTouchController;
- (void)didPressPiP:(UIButton *)button event:(UIEvent *)event;
@end

BOOL FromUser = NO;
BOOL PiPDisabled = NO;

extern BOOL LegacyPiP();

BOOL TweakEnabled() {
    return [[NSUserDefaults standardUserDefaults] boolForKey:EnabledKey];
}

BOOL UsePiPButton() {
    return [[NSUserDefaults standardUserDefaults] boolForKey:PiPActivationMethodKey];
}

BOOL UseTabBarPiPButton() {
    return [[NSUserDefaults standardUserDefaults] boolForKey:PiPActivationMethod2Key];
}

BOOL UseAllPiPMethod() {
    return [[NSUserDefaults standardUserDefaults] boolForKey:PiPAllActivationMethodKey];
}

BOOL NoMiniPlayerPiP() {
    return [[NSUserDefaults standardUserDefaults] boolForKey:NoMiniPlayerPiPKey];
}

BOOL NonBackgroundable() {
    return [[NSUserDefaults standardUserDefaults] boolForKey:NonBackgroundableKey];
}

BOOL isPictureInPictureActive(MLPIPController *pip) {
    return [pip respondsToSelector:@selector(pictureInPictureActive)] ? [pip pictureInPictureActive] : [pip isPictureInPictureActive];
}

static NSString *PiPIconPath;
static NSString *TabBarPiPIconPath;

static void activatePiPBase(YTPlayerPIPController *controller) {
    YTBackgroundabilityPolicy *backgroundabilityPolicy = [controller valueForKey:@"_backgroundabilityPolicy"];
    if (!backgroundabilityPolicy.playableInPiPByUserSettings) return;
    MLPIPController *pip = [controller valueForKey:@"_pipController"];
    if ([controller respondsToSelector:@selector(maybeEnablePictureInPicture)])
        [controller maybeEnablePictureInPicture];
    else if ([controller respondsToSelector:@selector(maybeInvokePictureInPicture)])
        [controller maybeInvokePictureInPicture];
    else {
        BOOL canPiP = [controller respondsToSelector:@selector(canEnablePictureInPicture)] && [controller canEnablePictureInPicture];
        if (!canPiP)
            canPiP = [controller respondsToSelector:@selector(canInvokePictureInPicture)] && [controller canInvokePictureInPicture];
        if (canPiP) {
            if ([pip respondsToSelector:@selector(activatePiPController)])
                [pip activatePiPController];
            else
                [pip startPictureInPicture];
        }
    }
    AVPictureInPictureController *avpip = [pip valueForKey:@"_pictureInPictureController"];
    if (avpip.pictureInPicturePossible)
        [avpip startPictureInPicture];
}

static void activatePiP(YTLocalPlaybackController *local) {
    if (![local isKindOfClass:%c(YTLocalPlaybackController)])
        return;
    YTPlayerPIPController *controller = [local valueForKey:@"_playerPIPController"];
    activatePiPBase(controller);
}

static void bootstrapPiP(YTPlayerViewController *self) {
    YTLocalPlaybackController *local = [self valueForKey:@"_playbackController"];
    activatePiP(local);
}

static YTCommonColorPalette *currentColorPalette() {
    Class YTPageStyleControllerClass = %c(YTPageStyleController);
    if (YTPageStyleControllerClass)
        return [YTPageStyleControllerClass currentColorPalette];
    YTAppDelegate *delegate = (YTAppDelegate *)[UIApplication sharedApplication].delegate;
    YTAppViewControllerImpl *appViewController = [delegate valueForKey:@"_appViewController"];
    NSInteger pageStyle = [appViewController pageStyle];
    Class YTCommonColorPaletteClass = %c(YTCommonColorPalette);
    if (YTCommonColorPaletteClass)
        return pageStyle == 1 ? [YTCommonColorPaletteClass darkPalette] : [YTCommonColorPaletteClass lightPalette];
    return [%c(YTColorPalette) colorPaletteForPageStyle:pageStyle];
}

%group Icon

BOOL shouldUseNewSettingIcon = NO;

%hook YTIIcon

- (UIImage *)iconImageWithColor:(UIColor *)color {
    if (self.iconType == YT_PICTURE_IN_PICTURE) {
        UIColor *color = [currentColorPalette() textPrimary];
        NSString *iconPath = shouldUseNewSettingIcon ? PiPIconPath : TabBarPiPIconPath;
        UIImage *image = [%c(QTMIcon) tintImage:[UIImage imageWithContentsOfFile:iconPath] color:color];
        if ([image respondsToSelector:@selector(imageFlippedForRightToLeftLayoutDirection)])
            image = [image imageFlippedForRightToLeftLayoutDirection];
        return image;
    }
    return %orig;
}

%end

%hook YTAppDelegate

- (void)performPostCriticalInitializationWithApplication:(UIApplication *)application withOptions:(NSDictionary *)launchOptions {
    %orig;
    Class YTUIResourcesClass = %c(YTUIResources);
    shouldUseNewSettingIcon = [YTUIResourcesClass respondsToSelector:@selector(delhiIconsEnabled)] ? [YTUIResourcesClass delhiIconsEnabled] : NO;
}

%end

%end

#pragma mark - Video tab bar PiP Button (17.01.4 and up)

static UIButton *makeUnderNewPlayerButton(ELMCellNode *node, NSString *title, NSString *accessibilityLabel) {
    YTCommonColorPalette *palette = currentColorPalette();
    UIColor *textColor = [palette textPrimary];

    ELMContainerNode *containerNode = (ELMContainerNode *)[[[[node yogaChildren] firstObject] yogaChildren] firstObject]; // To get node container properties
    UIButton *buttonView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 64, containerNode.calculatedSize.height)];
    buttonView.center = CGPointMake(CGRectGetMaxX([node.layoutAttributes frame]) + 65 / 2, CGRectGetMidY([node.layoutAttributes frame]));
    buttonView.backgroundColor = containerNode.backgroundColor;
    buttonView.accessibilityLabel = accessibilityLabel;
    buttonView.layer.cornerRadius = 16;

    UIImageView *buttonImage = [[UIImageView alloc] initWithFrame:CGRectMake(12, ([buttonView frame].size.height - 15) / 2, 15, 15)];
    buttonImage.image = [%c(QTMIcon) tintImage:[UIImage imageWithContentsOfFile:TabBarPiPIconPath] color:textColor];

    UIFontMetrics *metrics = [UIFontMetrics metricsForTextStyle:UIFontTextStyleBody];
    UIFont *font = [metrics scaledFontForFont:[UIFont boldSystemFontOfSize:12]];
    CGFloat fontSize = font.pointSize;
    UILabel *buttonTitle = [[UILabel alloc] initWithFrame:CGRectMake(33, ([buttonView frame].size.height - fontSize - 1) / 2, 20, fontSize)];
    buttonTitle.font = font;
    buttonTitle.textColor = textColor;
    buttonTitle.text = title;
    [buttonTitle sizeToFit];

    [buttonView addSubview:buttonImage];
    [buttonView addSubview:buttonTitle];
    return buttonView;
}

%hook ASCollectionView

%property (retain, nonatomic) UIButton *pipButton;
%property (retain, nonatomic) YTTouchFeedbackController *pipTouchController;

- (ELMCellNode *)nodeForItemAtIndexPath:(NSIndexPath *)indexPath {
    ELMCellNode *node = %orig;
    if ([self.accessibilityIdentifier isEqualToString:@"id.video.scrollable_action_bar"] && UseTabBarPiPButton() && !self.pipButton) {
        self.contentInset = UIEdgeInsetsMake(0, 0, 0, 73);
        if ([self collectionView:self numberOfItemsInSection:0] - 1 == indexPath.row) {
            self.pipButton = makeUnderNewPlayerButton(node, @"PiP", @"Play in PiP");
            [self addSubview:self.pipButton];

            [self.pipButton addTarget:self action:@selector(didPressPiP:event:) forControlEvents:UIControlEventTouchUpInside];
            YTTouchFeedbackController *controller = [[%c(YTTouchFeedbackController) alloc] initWithView:self.pipButton];
            controller.touchFeedbackView.customCornerRadius = 16;
            self.pipTouchController = controller;
        }
    }
    return %orig;
}

- (void)nodesDidRelayout:(NSArray <ELMCellNode *> *)nodes {
    if ([self.accessibilityIdentifier isEqualToString:@"id.video.scrollable_action_bar"] && UseTabBarPiPButton() && [nodes count] == 1) {
        CGFloat offset = nodes[0].calculatedSize.width - [nodes[0].layoutAttributes frame].size.width;
        [UIView animateWithDuration:0.3 animations:^{
            self.pipButton.center = CGPointMake(self.pipButton.center.x + offset, self.pipButton.center.y);
        }];
    }
    %orig;
}

%new(v@:@@)
- (void)didPressPiP:(UIButton *)button event:(UIEvent *)event {
    CGPoint location = [[[event allTouches] anyObject] locationInView:button];
    if (CGRectContainsPoint(button.bounds, location)) {
        UIViewController *controller = [self.collectionNode closestViewController];
        YTPlaybackStrippedWatchController *provider;
        @try {
            provider = [controller valueForKey:@"_metadataPanelStateProvider"];
        } @catch (id ex) {
            provider = [controller valueForKey:@"_ngwMetadataPanelStateProvider"];
        }
        YTWatchViewController *watchViewController = [provider valueForKey:@"_watchViewController"];
        YTPlayerViewController *playerViewController = [watchViewController valueForKey:@"_playerViewController"];
        FromUser = YES;
        bootstrapPiP(playerViewController);
    }
}

- (void)dealloc {
    self.pipButton = nil;
    self.pipTouchController = nil;
    %orig;
}

%end

#pragma mark - Overlay PiP Button

static UIImage *pipImage() {
    static UIImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIColor *color = [%c(YTColor) white1];
        image = [%c(QTMIcon) tintImage:[UIImage imageWithContentsOfFile:PiPIconPath] color:color];
        if ([image respondsToSelector:@selector(imageFlippedForRightToLeftLayoutDirection)])
            image = [image imageFlippedForRightToLeftLayoutDirection];
    });
    return image;
}

%hook YTMainAppControlsOverlayView

- (UIImage *)buttonImage:(NSString *)tweakId {
    return [tweakId isEqualToString:TweakName] ? pipImage() : %orig;
}

%new(v@:@)
- (void)didPressPiP:(id)arg {
    YTMainAppVideoPlayerOverlayViewController *c = [self valueForKey:@"_eventsDelegate"];
    YTPlayerViewController *pvc = (YTPlayerViewController *)c.parentViewController;
    FromUser = YES;
    bootstrapPiP(pvc);
}

%end

%hook YTInlinePlayerBarContainerView

- (UIImage *)buttonImage:(NSString *)tweakId {
    return [tweakId isEqualToString:TweakName] ? pipImage() : %orig;
}

%new(v@:@)
- (void)didPressPiP:(id)arg {
    YTMainAppVideoPlayerOverlayViewController *c = [self.delegate valueForKey:@"_delegate"];
    YTPlayerViewController *pvc = (YTPlayerViewController *)c.parentViewController;
    FromUser = YES;
    bootstrapPiP(pvc);
}

%end

#pragma mark - PiP Support

%hook MLPIPController

- (void)activatePiPController {
    %orig;
    BOOL blockPiP = !UseAllPiPMethod() && (UsePiPButton() || UseTabBarPiPButton());
    AVPictureInPictureController *avpip = [self valueForKey:@"_pictureInPictureController"];
    if (blockPiP && [avpip respondsToSelector:@selector(canStartPictureInPictureAutomaticallyFromInline)])
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability-new"
        avpip.canStartPictureInPictureAutomaticallyFromInline = NO;
    if ([avpip respondsToSelector:@selector(canStartAutomaticallyWhenEnteringBackground)])
        avpip.canStartAutomaticallyWhenEnteringBackground = !blockPiP;
#pragma clang diagnostic pop
    if (IS_IOS_OR_NEWER(iOS_15_0) || LegacyPiP()) return;
    MLHAMSBDLSampleBufferRenderingView *view = [self valueForKey:@"_HAMPlayerView"];
    CGSize size = [self renderSizeForView:view];
    [avpip sampleBufferDisplayLayerRenderSizeDidChangeToSize:size];
    [avpip sampleBufferDisplayLayerDidAppear];
}

%new(B@:@)
- (BOOL)pictureInPictureControllerPlaybackPaused:(AVPictureInPictureController *)pictureInPictureController {
    return [self pictureInPictureControllerIsPlaybackPaused:pictureInPictureController];
}

%new(v@:@)
- (void)pictureInPictureControllerStartPlayback:(id)arg1 {
    [self pictureInPictureControllerStartPlayback];
}

%new(v@:@)
- (void)pictureInPictureControllerStopPlayback:(id)arg1 {
    [self pictureInPictureControllerStopPlayback];
}

%new(v@:{CGSize=dd})
- (void)renderingViewSampleBufferFrameSizeDidChange:(CGSize)size {
    if (IS_IOS_OR_NEWER(iOS_15_0) || !size.width || !size.height) return;
    AVPictureInPictureController *avpip = [self valueForKey:@"_pictureInPictureController"];
    [avpip sampleBufferDisplayLayerRenderSizeDidChangeToSize:size];
}

%new(v@:@)
- (void)appWillEnterForeground:(id)arg1 {
    if (IS_IOS_OR_NEWER(iOS_15_0) || LegacyPiP()) return;
    AVPictureInPictureController *avpip = [self valueForKey:@"_pictureInPictureController"];
    [avpip sampleBufferDisplayLayerDidAppear];
}

%new(v@:@)
- (void)appWillEnterBackground:(id)arg1 {
    if (IS_IOS_OR_NEWER(iOS_15_0) || LegacyPiP()) return;
    AVPictureInPictureController *avpip = [self valueForKey:@"_pictureInPictureController"];
    [avpip sampleBufferDisplayLayerDidDisappear];
}

%end

%hook YTIIosMediaHotConfig

%new(B@:)
- (BOOL)enablePictureInPicture {
    return YES;
}

%new(B@:)
- (BOOL)enablePipForNonBackgroundableContent {
    return NonBackgroundable();
}

%new(B@:)
- (BOOL)enablePipForNonPremiumUsers {
    return YES;
}

%end

#pragma mark - Hacks

BOOL YTSingleVideo_isLivePlayback_override = NO;

%hook YTSingleVideo

- (BOOL)isLivePlayback {
    return YTSingleVideo_isLivePlayback_override ? NO : %orig;
}

%end

%hook YTPlayerPIPController

- (BOOL)canInvokePictureInPicture {
    YTSingleVideo_isLivePlayback_override = YES;
    BOOL value = %orig;
    YTSingleVideo_isLivePlayback_override = NO;
    return value;
}

- (BOOL)canEnablePictureInPicture {
    YTSingleVideo_isLivePlayback_override = YES;
    BOOL value = %orig;
    YTSingleVideo_isLivePlayback_override = NO;
    return value;
}

- (void)didStopPictureInPicture {
    FromUser = NO;
    %orig;
}

- (void)appWillResignActive:(id)arg1 {
    if (!UseAllPiPMethod()) {
        // If PiP button on, PiP doesn't activate on app resign unless it's from user
        BOOL hasPiPButton = UsePiPButton() || UseTabBarPiPButton();
        BOOL disablePiP = hasPiPButton && !FromUser;
        if (disablePiP) return;
    }
    if (LegacyPiP())
        activatePiPBase(self);
    %orig;
}

%end

%hook YTSingleVideoController

- (void)playerStatusDidChange:(YTPlayerStatus *)playerStatus {
    %orig;
    PiPDisabled = NoMiniPlayerPiP() && playerStatus.visibility == 1;
}

%end

%hook AVPictureInPicturePlatformAdapter

- (BOOL)isSystemPictureInPicturePossible {
    return PiPDisabled ? NO : %orig;
}

%end

%hook YTIPlayabilityStatus

- (BOOL)isPlayableInPictureInPicture {
    return YES;
}

- (BOOL)hasPictureInPicture {
    return YES;
}

%end

%hook YTHotConfig

- (BOOL)iosPlayerClientSharedConfigSkipPipToggleOnStateChange {
    return NO;
}

- (BOOL)iosPlayerClientSharedConfigOffsetPipControllerTimeRangeWithSbdlCurrentTime {
    return NO;
}

%end

#pragma mark - App background event

@protocol YTSystemNotificationsObserverExtended <YTSystemNotificationsObserver>
- (void)appWillEnterBackground:(UIApplication *)application;
@end

%hook YTSystemNotifications

- (void)registerForNotifications {
    %orig;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

%new(v@:@)
- (void)appWillEnterBackground:(id)arg {
    [self callBlockForEveryObserver:^(id <YTSystemNotificationsObserver> observer) {
        id <YTSystemNotificationsObserverExtended> observerExtended = (id <YTSystemNotificationsObserverExtended>)observer;
        if ([observerExtended respondsToSelector:@selector(appWillEnterBackground:)])
            [observerExtended appWillEnterBackground:UIApplication.sharedApplication];
    }];
}

%end

NSBundle *YouPiPBundle() {
    static NSBundle *bundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *tweakBundlePath = [[NSBundle mainBundle] pathForResource:@"YouPiP" ofType:@"bundle"];
        bundle = [NSBundle bundleWithPath:tweakBundlePath ?: PS_ROOT_PATH_NS(@"/Library/Application Support/" TweakName ".bundle")];
    });
    return bundle;
}

%ctor {
    NSBundle *tweakBundle = YouPiPBundle();
    TabBarPiPIconPath = [tweakBundle pathForResource:@"yt-pip-tabbar" ofType:@"png"];
    %init(Icon);
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{
        EnabledKey: @YES,
    }];
    if (!TweakEnabled()) return;
    PiPIconPath = [tweakBundle pathForResource:@"yt-pip-overlay" ofType:@"png"];
    initYTVideoOverlay(TweakName, @{
        AccessibilityLabelKey: @"PiP",
        SelectorKey: @"didPressPiP:",
        ToggleKey: PiPActivationMethodKey
    });
    %init;
}
