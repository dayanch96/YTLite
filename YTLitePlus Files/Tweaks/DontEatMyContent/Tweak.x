#import "Tweak.h"

static CGFloat videoAspectRatio = 16/9;
static BOOL isZoomedToFill = NO;
static BOOL isEngagementPanelVisible = NO;
static BOOL isEngagementPanelViewControllerRemoved = NO;
static UIView *renderingView; // MLHAMSBDLSampleBufferRenderingView *
static NSLayoutConstraint *widthConstraint, *heightConstraint, *centerXConstraint, *centerYConstraint;

static void DEMC_activateConstraints();
static void DEMC_deactivateConstraints();
static void DEMC_centerRenderingView();

%hook YTPlayerViewController
- (void)viewDidAppear:(BOOL)animated {
    YTPlayerView *playerView = [self playerView];
    UIView *renderingViewContainer = [playerView valueForKey:@"_renderingViewContainer"];
    renderingView = [playerView renderingView];
    if (IS_ENABLED(kDisableAmbientMode)) {
        playerView.backgroundColor = [UIColor blackColor];;
        renderingViewContainer.backgroundColor = [UIColor blackColor];
        renderingView.backgroundColor = [UIColor blackColor];
    } else {
        playerView.backgroundColor = [UIColor blackColor];
        renderingViewContainer.backgroundColor = nil;
        renderingView.backgroundColor = nil;
    }
    if (IS_ENABLED(kTweak)) {
        widthConstraint = [renderingView.widthAnchor constraintEqualToAnchor:renderingViewContainer.safeAreaLayoutGuide.widthAnchor constant:constant];
        heightConstraint = [renderingView.heightAnchor constraintEqualToAnchor:renderingViewContainer.safeAreaLayoutGuide.heightAnchor constant:constant];
        centerXConstraint = [renderingView.centerXAnchor constraintEqualToAnchor:renderingViewContainer.centerXAnchor];
        centerYConstraint = [renderingView.centerYAnchor constraintEqualToAnchor:renderingViewContainer.centerYAnchor];
        if (IS_ENABLED(kColorViews)) {
            playerView.backgroundColor = [UIColor blueColor];
            renderingViewContainer.backgroundColor = [UIColor greenColor];
            renderingView.backgroundColor = [UIColor redColor];
        }
        YTMainAppVideoPlayerOverlayViewController *activeVideoPlayerOverlay = [self activeVideoPlayerOverlay];
        // Must check class since YTInlineMutedPlaybackPlayerOverlayViewController doesn't have -(BOOL)isFullscreen
        if ([activeVideoPlayerOverlay isKindOfClass:%c(YTMainAppVideoPlayerOverlayViewController)] &&
            [activeVideoPlayerOverlay isFullscreen] && !isZoomedToFill && !isEngagementPanelVisible)
            DEMC_activateConstraints();
    }
    %orig;
}
// New video played
- (void)playbackController:(id)playbackController didActivateVideo:(id)video withPlaybackData:(id)playbackData {
    %orig;
    isEngagementPanelVisible = NO;
    isEngagementPanelViewControllerRemoved = NO;
    if ([[self activeVideoPlayerOverlay] isFullscreen])
        // New video played while in full screen (landscape)
        // Activate since new videos played in full screen aren't zoomed-to-fill by default
        // (i.e. the notch/Dynamic Island will cut into content when playing a new video in full screen)
        DEMC_activateConstraints();
    else if (![self isCurrentVideoVertical] && ((YTPlayerView *)[self playerView]).userInteractionEnabled)
        DEMC_deactivateConstraints();
}
- (void)setPlayerViewLayout:(int)layout {
    %orig;
    if (![[self activeVideoPlayerOverlay] isKindOfClass:%c(YTMainAppVideoPlayerOverlayViewController)])
        return;
    switch (layout) {
    case 1: // Mini bar
        break;
    case 2:
        DEMC_deactivateConstraints();
        break;
    case 3: // Fullscreen
        if (!isZoomedToFill && !isEngagementPanelVisible)
            DEMC_activateConstraints();
        break;
    default:
        break;
    }
}
%end

#pragma mark - Retrieve video aspect ratio

%hook YTPlayerView
- (void)setAspectRatio:(CGFloat)aspectRatio {
    %orig;
    videoAspectRatio = aspectRatio;
}
%end

#pragma mark - Detect zoom to fill

%hook YTVideoFreeZoomOverlayView // This hook will be used if pinch to zoom is available
- (void)didRecognizePinch:(UIPinchGestureRecognizer *)pinchGestureRecognizer {
    DEMC_deactivateConstraints();
    %orig;
}
- (void)showLabelForSnapState:(NSInteger)snapState {
    if (snapState == 0) { // Original
        isZoomedToFill = NO;
        DEMC_activateConstraints();
    } else if (snapState == 1) { // Zoomed to fill
        isZoomedToFill = YES;
        // No need to deactivate constraints as it's already done in -(void)didRecognizePinch:(UIPinchGestureRecognizer *)
    }
    %orig;
}
%end

%hook YTVideoZoomOverlayView // This hook will be used if pinch to zoom is unavailable
- (void)didRecognizePinch:(UIPinchGestureRecognizer *)pinchGestureRecognizer {
    DEMC_deactivateConstraints();
    %orig;
}
- (void)showLabelForSnapState:(NSInteger)snapState {
    if (snapState == 0) {
        isZoomedToFill = NO;
        DEMC_activateConstraints();
    } else if (snapState == 1) {
        isZoomedToFill = YES;
    }
    %orig;
}
%end

#pragma mark - Mini bar dismiss

%hook YTWatchMiniBarViewController
- (void)dismissMiniBarWithVelocity:(CGFloat)velocity gestureType:(int)gestureType {
    %orig;
    isZoomedToFill = NO; // YouTube undoes zoom-to-fill when mini bar is dismissed
}
- (void)dismissMiniBarWithVelocity:(CGFloat)velocity gestureType:(int)gestureType skipShouldDismissCheck:(BOOL)skipShouldDismissCheck {
    %orig;
    isZoomedToFill = NO;
}
%end

#pragma mark - Engagement panels

%hook YTMainAppEngagementPanelViewController
// Engagement panel (comment, description, etc.) about to show up
- (void)viewWillAppear:(BOOL)animated {
    if ([self isPeekingSupported]) {
        // Shorts (only Shorts support peeking, I think)
    } else {
        // Everything else
        isEngagementPanelVisible = YES;
        if ([self isLandscapeEngagementPanel]) {
            DEMC_deactivateConstraints();
        }
    }
    %orig;
}
%end

%hook YTEngagementPanelContainerViewController
// Engagement panel about to dismiss
- (void)notifyEngagementPanelContainerControllerWillHideFinalPanel {
    // Crashes if plays new video while in full screen causing engagement panel dismissal
    // Must check if engagement panel was dismissed because new video played
    // (i.e. if -(void)removeEngagementPanelViewControllerWithIdentifier:(id) was called prior)
    if (![self isPeekingSupported] && !isEngagementPanelViewControllerRemoved) {
        isEngagementPanelVisible = NO;
        if (([self respondsToSelector:@selector(isWatchLandscapeEngagementPanel)] ? self.watchLandscapeEngagementPanel : self.landscapeEngagementPanel) && !isZoomedToFill) {
            DEMC_activateConstraints();
        }
    }
    %orig;
}
- (void)removeEngagementPanelViewControllerWithIdentifier:(id)identifier {
    // Usually called when engagement panel is open & new video is played or mini bar is dismissed
    isEngagementPanelViewControllerRemoved = YES;
    %orig;
}
%end

#pragma mark - Constructor

%ctor {
    constant = [[NSUserDefaults standardUserDefaults] floatForKey:kSafeAreaConstant];
    if (constant == 0) { // First launch probably
        constant = DEFAULT_CONSTANT;
        [[NSUserDefaults standardUserDefaults] setFloat:constant forKey:kSafeAreaConstant];
    }
    %init;
}

#pragma mark - Functions

static void DEMC_activateConstraints() {
    if (!IS_ENABLED(kTweak)) return;
    if (videoAspectRatio < THRESHOLD && !IS_ENABLED(kEnableForAllVideos)) {
        DEMC_deactivateConstraints();
        return;
    }
    // NSLog(@"activate");
    DEMC_centerRenderingView();
    renderingView.translatesAutoresizingMaskIntoConstraints = NO;
    widthConstraint.active = YES;
    heightConstraint.active = YES;
}

static void DEMC_deactivateConstraints() {
    if (!IS_ENABLED(kTweak)) return;
    // NSLog(@"deactivate");
    renderingView.translatesAutoresizingMaskIntoConstraints = YES;
}

static void DEMC_centerRenderingView() {
    centerXConstraint.active = YES;
    centerYConstraint.active = YES;
}

void DEMC_showSnackBar(NSString *text) {
    YTHUDMessage *message = [%c(YTHUDMessage) messageWithText:text];
    GOOHUDManagerInternal *manager = [%c(GOOHUDManagerInternal) sharedInstance];
    [manager showMessageMainThread:message];
}

NSBundle *DEMC_getTweakBundle() {
    static NSBundle *bundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"DontEatMyContent" ofType:@"bundle"];
        if (bundlePath)
            bundle = [NSBundle bundleWithPath:bundlePath];
        else // Rootless
            bundle = [NSBundle bundleWithPath:ROOT_PATH_NS(@"/Library/Application Support/DontEatMyContent.bundle")];
    });
    return bundle;
}