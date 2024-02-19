#import "YTLite.h"

// YouTube-X (https://github.com/PoomSmart/YouTube-X/)
// Background Playback
%hook YTIPlayabilityStatus
- (BOOL)isPlayableInBackground { return kBackgroundPlayback ? YES : NO; }
%end

%hook MLVideo
- (BOOL)playableInBackground { return kBackgroundPlayback ? YES : NO; }
%end

// Disable Ads
%hook YTIPlayerResponse
- (BOOL)isMonetized { return kNoAds ? NO : YES; }
%end

%hook YTDataUtils
+ (id)spamSignalsDictionary { return kNoAds ? nil : %orig; }
+ (id)spamSignalsDictionaryWithoutIDFA { return kNoAds ? nil : %orig; }
%end

%hook YTAdsInnerTubeContextDecorator
- (void)decorateContext:(id)context { if (!kNoAds) %orig; }
%end

%hook YTAccountScopedAdsInnerTubeContextDecorator
- (void)decorateContext:(id)context { if (!kNoAds) %orig; }
%end

%hook YTIElementRenderer
- (NSData *)elementData {
    if (self.hasCompatibilityOptions && self.compatibilityOptions.hasAdLoggingData && kNoAds) return nil;

    NSString *description = [self description];

    NSArray *ads = @[@"brand_promo", @"product_carousel", @"product_engagement_panel", @"product_item", @"text_search_ad", @"text_image_button_layout", @"carousel_headered_layout", @"carousel_footered_layout", @"square_image_layout", @"landscape_image_wide_button_layout", @"feed_ad_metadata"];
    if (kNoAds && [ads containsObject:description]) {
        return [NSData data];
    }

    NSArray *shortsToRemove = @[@"shorts_shelf.eml", @"shorts_video_cell.eml", @"6Shorts"];
    for (NSString *shorts in shortsToRemove) {
        if (kHideShorts && [description containsString:shorts] && ![description containsString:@"history*"]) {
            return nil;
        }
    }

    return %orig;
}
%end

%hook YTSectionListViewController
- (void)loadWithModel:(YTISectionListRenderer *)model {
    if (kNoAds) {
        NSMutableArray <YTISectionListSupportedRenderers *> *contentsArray = model.contentsArray;
        NSIndexSet *removeIndexes = [contentsArray indexesOfObjectsPassingTest:^BOOL(YTISectionListSupportedRenderers *renderers, NSUInteger idx, BOOL *stop) {
            YTIItemSectionRenderer *sectionRenderer = renderers.itemSectionRenderer;
            YTIItemSectionSupportedRenderers *firstObject = [sectionRenderer.contentsArray firstObject];
            return firstObject.hasPromotedVideoRenderer || firstObject.hasCompactPromotedVideoRenderer || firstObject.hasPromotedVideoInlineMutedRenderer;
        }];
        [contentsArray removeObjectsAtIndexes:removeIndexes];
    } %orig;
}
%end

// NOYTPremium (https://github.com/PoomSmart/NoYTPremium)
// Alert
%hook YTCommerceEventGroupHandler
- (void)addEventHandlers {}
%end

// Full-screen
%hook YTInterstitialPromoEventGroupHandler
- (void)addEventHandlers {}
%end

%hook YTPromosheetEventGroupHandler
- (void)addEventHandlers {}
%end

%hook YTPromoThrottleController
- (BOOL)canShowThrottledPromo { return NO; }
- (BOOL)canShowThrottledPromoWithFrequencyCap:(id)arg1 { return NO; }
- (BOOL)canShowThrottledPromoWithFrequencyCaps:(id)arg1 { return NO; }
%end

%hook YTIShowFullscreenInterstitialCommand
- (BOOL)shouldThrottleInterstitial { return YES; }
%end

// "Try new features" in settings
%hook YTSettingsSectionItemManager
- (void)updatePremiumEarlyAccessSectionWithEntry:(id)arg1 {}
%end

// Survey
%hook YTSurveyController
- (void)showSurveyWithRenderer:(id)arg1 surveyParentResponder:(id)arg2 {}
%end

// Navbar Stuff
// Disable Cast
%hook MDXPlaybackRouteButtonController
- (BOOL)isPersistentCastIconEnabled { return kNoCast ? NO : YES; }
- (void)updateRouteButton:(id)arg1 { if (!kNoCast) %orig; }
- (void)updateAllRouteButtons { if (!kNoCast) %orig; }
%end

%hook YTSettings
- (void)setDisableMDXDeviceDiscovery:(BOOL)arg1 { %orig(kNoCast); }
%end

// Hide Navigation Bar Buttons
%hook YTRightNavigationButtons
- (void)layoutSubviews {
    %orig;

    if (kNoNotifsButton) self.notificationButton.hidden = YES;
    if (kNoSearchButton) self.searchButton.hidden = YES;

    for (UIView *subview in self.subviews) {
        if (kNoVoiceSearchButton && [subview.accessibilityLabel isEqualToString:NSLocalizedString(@"search.voice.access", nil)]) subview.hidden = YES;
        if (kNoCast && [subview.accessibilityIdentifier isEqualToString:@"id.mdx.playbackroute.button"]) subview.hidden = YES;
    }
}
%end

%hook YTSearchViewController
- (void)viewDidLoad {
    %orig;

    if (kNoVoiceSearchButton) [self setValue:@(NO) forKey:@"_isVoiceSearchAllowed"];
}

- (void)setSuggestions:(id)arg1 { if (!kNoSearchHistory) %orig; }
%end

%hook YTPersonalizedSuggestionsCacheProvider
- (id)activeCache { return kNoSearchHistory ? nil : %orig; }
%end

// Remove Videos Section Under Player
%hook YTWatchNextResultsViewController
- (void)setVisibleSections:(NSInteger)arg1 {
    arg1 = (kNoRelatedWatchNexts) ? 1 : arg1;
    %orig(arg1);
}
%end

%hook YTHeaderView
// Stick Navigation bar
- (BOOL)stickyNavHeaderEnabled { return kStickyNavbar ? YES : %orig; }

// Hide YouTube Logo
- (void)setCustomTitleView:(UIView *)customTitleView { if (!kNoYTLogo) %orig; }
- (void)setTitle:(NSString *)title { kNoYTLogo ? %orig(@"") : %orig; }
%end

// Remove Subbar
%hook YTMySubsFilterHeaderView
- (void)setChipFilterView:(id)arg1 { if (!kNoSubbar) %orig; }
%end

%hook YTHeaderContentComboView
- (void)enableSubheaderBarWithView:(id)arg1 { if (!kNoSubbar) %orig; }
- (void)setFeedHeaderScrollMode:(int)arg1 { kNoSubbar ? %orig(0) : %orig; }
%end

%hook YTChipCloudCell
- (void)layoutSubviews {
    if (self.superview && kNoSubbar) {
        [self removeFromSuperview];
    } %orig;
}
%end

// Hide Autoplay Switch and Subs Button
%hook YTMainAppControlsOverlayView
- (void)setAutoplaySwitchButtonRenderer:(id)arg1 { if (!kHideAutoplay) %orig; }
- (void)setClosedCaptionsOrSubtitlesButtonAvailable:(BOOL)arg1 { kHideSubs ? %orig(NO) : %orig; }
%end

// Remove HUD Messages
%hook YTHUDMessageView
- (id)initWithMessage:(id)arg1 dismissHandler:(id)arg2 { return kNoHUDMsgs ? nil : %orig; }
%end

%hook YTColdConfig
// Hide Next & Previous buttons
- (BOOL)removeNextPaddleForSingletonVideos { return kHidePrevNext ? YES : %orig; }
- (BOOL)removePreviousPaddleForSingletonVideos { return kHidePrevNext ? YES : %orig; }
// Replace Next & Previous with Fast Forward & Rewind buttons
- (BOOL)replaceNextPaddleWithFastForwardButtonForSingletonVods { return kReplacePrevNext ? YES : %orig; }
- (BOOL)replacePreviousPaddleWithRewindButtonForSingletonVods { return kReplacePrevNext ? YES : %orig; }
// Disable Free Zoom
- (BOOL)videoZoomFreeZoomEnabledGlobalConfig { return kNoFreeZoom ? NO : %orig; }
// Stick Sort Buttons in Comments Section
- (BOOL)enableHideChipsInTheCommentsHeaderOnScrollIos { return kStickSortComments ? NO : %orig; }
// Hide Sort Buttons in Comments Section
- (BOOL)enableChipsInTheCommentsHeaderIos { return kHideSortComments ? NO : %orig; }
// Use System Theme
- (BOOL)shouldUseAppThemeSetting { return YES; }
// Dismiss Panel By Swiping in Fullscreen Mode
- (BOOL)isLandscapeEngagementPanelSwipeRightToDismissEnabled { return YES; }
// Remove Video in Playlist By Swiping To The Right
- (BOOL)enableSwipeToRemoveInPlaylistWatchEp { return YES; }
// Enable Old-style Minibar For Playlist Panel
- (BOOL)queueClientGlobalConfigEnableFloatingPlaylistMinibar { return kPlaylistOldMinibar ? NO : %orig; }
%end

// Remove Dark Background in Overlay
%hook YTMainAppVideoPlayerOverlayView
- (void)setBackgroundVisible:(BOOL)arg1 isGradientBackground:(BOOL)arg2 { kNoDarkBg ? %orig(NO, arg2) : %orig; }
%end

// No Endscreen Cards
%hook YTCreatorEndscreenView
- (void)setHidden:(BOOL)arg1 { kEndScreenCards ? %orig(YES) : %orig; }
%end

// Disable Fullscreen Actions
%hook YTFullscreenActionsView
- (BOOL)enabled { return kNoFullscreenActions ? NO : YES; }
- (void)setEnabled:(BOOL)arg1 { kNoFullscreenActions ? %orig(NO) : %orig; }
%end

// Dont Show Related Videos on Finish
%hook YTFullscreenEngagementOverlayController
- (void)setRelatedVideosVisible:(BOOL)arg1 { kNoRelatedVids ? %orig(NO) : %orig; }
%end

// Hide Paid Promotion Cards
%hook YTMainAppVideoPlayerOverlayViewController
- (void)setPaidContentWithPlayerData:(id)data { if (!kNoPromotionCards) %orig; }
- (void)playerOverlayProvider:(YTPlayerOverlayProvider *)provider didInsertPlayerOverlay:(YTPlayerOverlay *)overlay {
    if ([[overlay overlayIdentifier] isEqualToString:@"player_overlay_paid_content"] && kNoPromotionCards) return;
    %orig;
}
%end

%hook YTInlineMutedPlaybackPlayerOverlayViewController
- (void)setPaidContentWithPlayerData:(id)data { if (!kNoPromotionCards) %orig; }
%end

%hook YTInlinePlayerBarContainerView
- (void)setPlayerBarAlpha:(CGFloat)alpha { kPersistentProgressBar ? %orig(1.0) : %orig; }
%end

// Remove Watermarks
%hook YTAnnotationsViewController
- (void)loadFeaturedChannelWatermark { if (!kNoWatermarks) %orig; }
%end

%hook YTMainAppVideoPlayerOverlayView
- (BOOL)isWatermarkEnabled { return kNoWatermarks ? NO : %orig; }
%end

// Forcibly Enable Miniplayer
%hook YTWatchMiniBarViewController
- (void)updateMiniBarPlayerStateFromRenderer { if (!kMiniplayer) %orig; }
%end

// Portrait Fullscreen
%hook YTWatchViewController
- (unsigned long long)allowedFullScreenOrientations { return kPortraitFullscreen ? UIInterfaceOrientationMaskAllButUpsideDown : %orig; }
%end

// Disable Autoplay
%hook YTPlaybackConfig
- (void)setStartPlayback:(BOOL)arg1 { kDisableAutoplay ? %orig(NO) : %orig; }
%end

// Skip Content Warning (https://github.com/qnblackcat/uYouPlus/blob/main/uYouPlus.xm#L452-L454)
%hook YTPlayabilityResolutionUserActionUIController
- (void)showConfirmAlert { kNoContentWarning ? [self confirmAlertDidPressConfirm] : %orig; }
%end

// Classic Video Quality (https://github.com/PoomSmart/YTClassicVideoQuality)
%hook YTVideoQualitySwitchControllerFactory
- (id)videoQualitySwitchControllerWithParentResponder:(id)responder {
    Class originalClass = %c(YTVideoQualitySwitchOriginalController);
    return kClassicQuality && originalClass ? [[originalClass alloc] initWithParentResponder:responder] : %orig;
}
%end

// Extra Speed Options (https://github.com/LillieH1000/YouTube-Reborn/blob/v4/Tweak.xm#L853) - Same code but for .x
%hook YTVarispeedSwitchController
- (void *)init {
    void *ret = (void *)%orig;
    if (kExtraSpeedOptions) {
        NSArray *speedOptions = @[@"0.1x", @"0.25x", @"0.5x", @"0.75x", @"1x", @"1.25x", @"1.5x", @"1.75x", @"2x", @"2.5x", @"3x", @"3.5x", @"4x", @"5x"];
        NSMutableArray *speedOptionsCopy = [NSMutableArray new];

        for (NSString *title in speedOptions) {
            float rate = [title floatValue];
            [speedOptionsCopy addObject:[[objc_lookUpClass("YTVarispeedSwitchControllerOption") alloc] initWithTitle:title rate:rate]];
        }

        Ivar optionsIvar = class_getInstanceVariable(object_getClass(self), "_options");
        object_setIvar(self, optionsIvar, [speedOptionsCopy copy]);

    } return ret;
}
%end

%hook MLHAMQueuePlayer
- (void)setRate:(float)rate {
    if (kExtraSpeedOptions) {
        Ivar rateIvar = class_getInstanceVariable([self class], "_rate");
        if (rateIvar) {
            float* ratePtr = (float *)((__bridge void *)self + ivar_getOffset(rateIvar));
            *ratePtr = rate;
        }

        id ytPlayer = object_getIvar(self, class_getInstanceVariable([self class], "_player"));
        if ([ytPlayer respondsToSelector:@selector(setRate:)]) {
            [ytPlayer setRate:rate];
        }

        [self.playerEventCenter broadcastRateChange:rate];
    } else {
        %orig(rate);
    }
}
%end

// Temprorary Fix For 'Classic Video Quality' and 'Extra Speed Options'
%hook YTVersionUtils
+ (NSString *)appVersion {
    NSString *originalVersion = %orig;
    NSString *fakeVersion = @"18.18.2";

    return (!kClassicQuality && !kExtraSpeedOptions && [originalVersion compare:fakeVersion options:NSNumericSearch] == NSOrderedDescending) ? originalVersion : fakeVersion;
}
%end

// Show real version in YT Settings
%hook YTSettingsCell
- (void)setDetailText:(id)arg1 {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = infoDictionary[@"CFBundleShortVersionString"];

    if ([arg1 isEqualToString:@"18.18.2"]) {
        arg1 = appVersion;
    } %orig(arg1);
}
%end

// Disable Snap To Chapter (https://github.com/qnblackcat/uYouPlus/blob/main/uYouPlus.xm#L457-464)
%hook YTSegmentableInlinePlayerBarView
- (void)didMoveToWindow { %orig; if (kDontSnapToChapter) self.enableSnapToChapter = NO; }
%end

// Red Progress Bar and Gray Buffer Progress
%hook YTInlinePlayerBarContainerView
- (id)quietProgressBarColor { return kRedProgressBar ? [UIColor redColor] : %orig; }
%end

%hook YTSegmentableInlinePlayerBarView
- (void)setBufferedProgressBarColor:(id)arg1 { if (kRedProgressBar) %orig([UIColor colorWithRed:0.65 green:0.65 blue:0.65 alpha:0.60]); }
%end

// Disable Hints
%hook YTSettings
- (BOOL)areHintsDisabled { return kNoHints ? YES : NO; }
- (void)setHintsDisabled:(BOOL)arg1 { kNoHints ? %orig(YES) : %orig; }
%end

%hook YTUserDefaults
- (BOOL)areHintsDisabled { return kNoHints ? YES : NO; }
- (void)setHintsDisabled:(BOOL)arg1 { kNoHints ? %orig(YES) : %orig; }
%end

// Enter Fullscreen on Start (https://github.com/PoomSmart/YTAutoFullScreen)
%hook YTPlayerViewController
- (void)loadWithPlayerTransition:(id)arg1 playbackConfig:(id)arg2 {
    %orig;

    if (kAutoFullscreen) [NSTimer scheduledTimerWithTimeInterval:0.75 target:self selector:@selector(autoFullscreen) userInfo:nil repeats:NO];
    if (kShortsToRegular) [NSTimer scheduledTimerWithTimeInterval:0.75 target:self selector:@selector(shortsToRegular) userInfo:nil repeats:NO];
    if (kDisableAutoCaptions) [NSTimer scheduledTimerWithTimeInterval:0.75 target:self selector:@selector(turnOffCaptions) userInfo:nil repeats:NO];
}

%new
- (void)autoFullscreen {
    YTWatchController *watchController = [self valueForKey:@"_UIDelegate"];
    [watchController showFullScreen];
}

%new
- (void)shortsToRegular {
    if (self.contentVideoID != nil && [self.parentViewController isKindOfClass:NSClassFromString(@"YTShortsPlayerViewController")]) {
        NSString *vidLink = [NSString stringWithFormat:@"vnd.youtube://%@", self.contentVideoID];
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:vidLink]]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:vidLink] options:@{} completionHandler:nil];
        }
    }
}

%new
- (void)turnOffCaptions {
    [self setActiveCaptionTrack:nil];
}
%end

// Exit Fullscreen on Finish
%hook YTWatchFlowController
- (BOOL)shouldExitFullScreenOnFinish { return kExitFullscreen ? YES : NO; }
%end

%hook YTMainAppVideoPlayerOverlayViewController
// Disable Double Tap To Seek
- (BOOL)allowDoubleTapToSeekGestureRecognizer { return kNoDoubleTapToSeek ? NO : %orig; }

// Copy Timestamped Link by Pressing On Pause
- (void)didPressPause:(id)arg1 {
    %orig;

    if (kCopyWithTimestamp) {
        NSInteger mediaTimeInteger = (NSInteger)self.mediaTime;
        NSString *currentTimeLink = [NSString stringWithFormat:@"https://www.youtube.com/watch?v=%@&t=%lds", self.videoID, mediaTimeInteger];

        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = currentTimeLink;
    }
}
%end

// Fit 'Play All' Buttons Text For Localizations
%hook YTQTMButton
- (void)layoutSubviews {
    if ([self.accessibilityIdentifier isEqualToString:@"id.playlist.playall.button"]) {
        self.titleLabel.adjustsFontSizeToFitWidth = YES;
    } %orig;
}
%end

// Fit Shorts Button Labels For Localizations
%hook YTReelPlayerButton
- (void)layoutSubviews {
    %orig;

    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:[UILabel class]]) {
            UILabel *label = (UILabel *)subview;
            label.adjustsFontSizeToFitWidth = YES;
            break;
        }
    }
}
%end

// Fix Playlist Mini-bar Height For Small Screens
%hook YTPlaylistMiniBarView
- (void)setFrame:(CGRect)frame {
    if (frame.size.height < 54.0) frame.size.height = 54.0;
    %orig(frame);
}
%end

// Remove "Play next in queue" from the menu @PoomSmart (https://github.com/qnblackcat/uYouPlus/issues/1138#issuecomment-1606415080)
%hook YTMenuItemVisibilityHandler
- (BOOL)shouldShowServiceItemRenderer:(YTIMenuConditionalServiceItemRenderer *)renderer {
    if (kRemovePlayNext && renderer.icon.iconType == 251) {
        return NO;
    } return %orig;
}
%end

// Remove Premium Pop-up, Horizontal Video Carousel and Shorts (https://github.com/MiRO92/YTNoShorts)
%hook YTAsyncCollectionView
- (id)cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = %orig;

    if ([cell isKindOfClass:objc_lookUpClass("_ASCollectionViewCell")]) {
        _ASCollectionViewCell *cell = %orig;
        if ([cell respondsToSelector:@selector(node)]) {
            NSString *idToRemove = [[cell node] accessibilityIdentifier];
            if ([idToRemove isEqualToString:@"statement_banner.view"] ||
                (([idToRemove isEqualToString:@"eml.shorts-grid"] || [idToRemove isEqualToString:@"eml.shorts-shelf"]) && kHideShorts)) {
                [self removeCellsAtIndexPath:indexPath];
            }
        }
    } else if (([cell isKindOfClass:objc_lookUpClass("YTReelShelfCell")] && kHideShorts) ||
        ([cell isKindOfClass:objc_lookUpClass("YTHorizontalCardListCell")] && kNoContinueWatching)) {
        [self removeCellsAtIndexPath:indexPath];
    } return %orig;
}

%new
- (void)removeCellsAtIndexPath:(NSIndexPath *)indexPath {
    [self deleteItemsAtIndexPaths:@[indexPath]];
}
%end

// Shorts Progress Bar (https://github.com/PoomSmart/YTShortsProgress)
%hook YTReelPlayerViewController
- (BOOL)shouldEnablePlayerBar { return kShortsProgress ? YES : NO; }
- (BOOL)shouldAlwaysEnablePlayerBar { return kShortsProgress ? YES : NO; }
- (BOOL)shouldEnablePlayerBarOnlyOnPause { return kShortsProgress ? NO : YES; }
%end

%hook YTReelPlayerViewControllerSub
- (BOOL)shouldEnablePlayerBar { return kShortsProgress ? YES : NO; }
- (BOOL)shouldAlwaysEnablePlayerBar { return kShortsProgress ? YES : NO; }
- (BOOL)shouldEnablePlayerBarOnlyOnPause { return kShortsProgress ? NO : YES; }
%end

%hook YTShortsPlayerViewController
- (BOOL)shouldAlwaysEnablePlayerBar { return kShortsProgress ? YES : NO; }
- (BOOL)shouldEnablePlayerBarOnlyOnPause { return kShortsProgress ? NO : YES; }
%end

%hook YTColdConfig
- (BOOL)iosEnableVideoPlayerScrubber { return kShortsProgress ? YES : NO; }
- (BOOL)mobileShortsTabInlined { return kShortsProgress ? YES : NO; }
%end

%hook YTHotConfig
- (BOOL)enablePlayerBarForVerticalVideoWhenControlsHiddenInFullscreen { return kShortsProgress ? YES : NO; }
%end

// Dont Startup Shorts
%hook YTShortsStartupCoordinator
- (id)evaluateResumeToShorts { return kResumeShorts ? nil : %orig; }
%end

// Hide Shorts Elements
%hook YTReelPausedStateCarouselView
- (void)setPausedStateCarouselVisible:(BOOL)arg1 animated:(BOOL)arg2 { kHideShortsSubscriptions ? %orig(arg1 = NO, arg2) : %orig; }
%end

%hook YTReelWatchPlaybackOverlayView
- (void)setReelLikeButton:(id)arg1 { if (!kHideShortsLike) %orig; }
- (void)setReelDislikeButton:(id)arg1 { if (!kHideShortsDislike) %orig; }
- (void)setViewCommentButton:(id)arg1 { if (!kHideShortsComments) %orig; }
- (void)setRemixButton:(id)arg1 { if (!kHideShortsRemix) %orig; }
- (void)setShareButton:(id)arg1 { if (!kHideShortsShare) %orig; }
- (void)setNativePivotButton:(id)arg1 { if (!kHideShortsAvatars) %orig; }
%end

%hook YTReelHeaderView
- (void)setTitleLabelVisible:(BOOL)arg1 animated:(BOOL)arg2 { kHideShortsLogo ? %orig(arg1 = NO, arg2) : %orig; }
%end

%hook YTReelTransparentStackView
- (void)layoutSubviews {
    %orig;

    for (YTQTMButton *button in self.subviews) {
        if ([button respondsToSelector:@selector(buttonRenderer)]) {
            if (kHideShortsSearch && button.buttonRenderer.icon.iconType == 1045) button.hidden = YES;
            if (kHideShortsCamera && button.buttonRenderer.icon.iconType == 1046) button.hidden = YES;
            if (kHideShortsMore && button.buttonRenderer.icon.iconType == 1047) button.hidden = YES;
        }
    }
}
%end

%hook YTReelWatchHeaderView
- (void)setChannelBarElementRenderer:(id)renderer { if (!kHideShortsChannelName) %orig; }
- (void)setHeaderRenderer:(id)renderer { if (!kHideShortsDescription) %orig; }
- (void)setSoundMetadataElementRenderer:(id)renderer { if (!kHideShortsAudioTrack) %orig; }
- (void)setActionElement:(id)renderer { if (!kHideShortsPromoCards) %orig; }
- (void)setBadgeRenderer:(id)renderer { if (!kHideShortsThanks) %orig; }
- (void)setMultiFormatLinkElementRenderer:(id)renderer { if (!kHideShortsSource) %orig; }
%end

static BOOL isOverlayShown = YES;

%hook YTPlayerView
- (void)didPinch:(UIPinchGestureRecognizer *)gesture {
    %orig;

    if (kPinchToFullscreenShorts && [self.playerViewDelegate.parentViewController isKindOfClass:NSClassFromString(@"YTShortsPlayerViewController")]) {
        YTShortsPlayerViewController *shortsPlayerVC = (YTShortsPlayerViewController *)self.playerViewDelegate.parentViewController;
        YTReelContentView *contentView = (YTReelContentView *)shortsPlayerVC.view;

        if (gesture.scale > 1) {
            if (!kShortsOnlyMode) [shortsPlayerVC.navigationController.parentViewController hidePivotBar];

            [UIView animateWithDuration:0.3 animations:^{
                contentView.playbackOverlay.alpha = 0;
                isOverlayShown = contentView.playbackOverlay.alpha;
            }];
        } else {
            if (!kShortsOnlyMode) [shortsPlayerVC.navigationController.parentViewController showPivotBar];

            [UIView animateWithDuration:0.3 animations:^{
                contentView.playbackOverlay.alpha = 1;
                isOverlayShown = contentView.playbackOverlay.alpha;
            }];
        }
    }
}

- (void)layoutSubviews {
    %orig;

    if (kShortsOnlyMode && [self.playerViewDelegate.parentViewController isKindOfClass:NSClassFromString(@"YTShortsPlayerViewController")]) {
        UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(turnShortsOnlyModeOff:)];
        longPressGesture.numberOfTouchesRequired = 2;
        longPressGesture.minimumPressDuration = 0.5;

        [self addGestureRecognizer:longPressGesture];
    }
}

%new
- (void)turnShortsOnlyModeOff:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"YTLite.plist"];
        NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:path];

        [prefs setObject:@NO forKey:@"shortsOnlyMode"];
        [prefs writeToFile:path atomically:NO];

        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.dvntm.ytlite.prefschanged"), NULL, NULL, YES);

        UIResponder *responder = self.nextResponder;
        while (responder && ![responder isKindOfClass:[UIViewController class]]) responder = responder.nextResponder;
        if (responder) [[%c(YTToastResponderEvent) eventWithMessage:LOC(@"ShortsModeTurnedOff") firstResponder:responder] send];

        YTShortsPlayerViewController *shortsPlayerVC = (YTShortsPlayerViewController *)self.playerViewDelegate.parentViewController;
        [shortsPlayerVC.navigationController.parentViewController performSelector:@selector(showPivotBar) withObject:nil afterDelay:1.0];

    }
}
%end

%hook YTReelWatchPlaybackOverlayView
- (void)layoutSubviews {
    %orig;

    self.alpha = isOverlayShown;
}
%end

%hook ELMContainerNode
%property (nonatomic, strong) NSString *copiedComment;
%end

%hook _ASDisplayView
- (void)setKeepalive_node:(id)arg1 {
    %orig;

    NSArray *gesturesInfo = @[
        @{@"selector": @"copyText:", @"text": @"ELMExpandableTextNode-View", @"key": @(kCopyPostText)},
        @{@"selector": @"saveImage:", @"text": @"YTImageZoomNode-View", @"key": @(kSavePostImage)},
        @{@"selector": @"savePFP:", @"text": @"ELMImageNode-View", @"key": @(kSaveProfilePhoto)},
        @{@"selector": @"copyComment:", @"text": @"id.ui.comment_cell", @"key": @(kCopyCommentText)}
    ];

    for (NSDictionary *gestureInfo in gesturesInfo) {
        SEL selector = NSSelectorFromString(gestureInfo[@"selector"]);

        if ([gestureInfo[@"key"] boolValue] && [[self description] containsString:gestureInfo[@"text"]]) {
            UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:selector];
            longPress.minimumPressDuration = 0.3;
            [self addGestureRecognizer:longPress];
            break;
        }
    }

    if ([[self description] containsString:@"id.comment.content.label"]) {
        ASTextNode *textNode = (ASTextNode *)self.keepalive_node;
        ASDisplayNode *displayNode = (ASDisplayNode *)self.keepalive_node;

        NSMutableArray *allObjects = displayNode.supernodes.allObjects;
        for (ELMContainerNode *containerNode in allObjects) {
            if ([containerNode.description containsString:@"id.ui.comment_cell"]) {
                containerNode.copiedComment = textNode.attributedText.string;
                break;
            }
        }
    }
}

%new
- (void)savePFP:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {

        ASNetworkImageNode *imageNode = (ASNetworkImageNode *)self.keepalive_node;
        NSString *URLString = imageNode.URL.absoluteString;
        if (URLString) {
            NSRange sizeRange = [URLString rangeOfString:@"=s"];
            if (sizeRange.location != NSNotFound) {
                NSRange dashRange = [URLString rangeOfString:@"-" options:0 range:NSMakeRange(sizeRange.location, URLString.length - sizeRange.location)];
                if (dashRange.location != NSNotFound) {
                    NSString *newURLString = [URLString stringByReplacingCharactersInRange:NSMakeRange(sizeRange.location + 2, dashRange.location - sizeRange.location - 2) withString:@"1024"];
                    NSURL *PFPURL = [NSURL URLWithString:newURLString];

                    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:PFPURL]];
                    if (image) {
                        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);

                        UIResponder *responder = self.nextResponder;
                        while (responder && ![responder isKindOfClass:[UIViewController class]]) responder = responder.nextResponder;
                        if (responder) [[%c(YTToastResponderEvent) eventWithMessage:LOC(@"Saved") firstResponder:responder] send];
                    }
                }
            }
        }
    }
}

%new
- (void)copyText:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        [UIPasteboard generalPasteboard].string = self.accessibilityLabel;

        UIResponder *responder = self.nextResponder;
        while (responder && ![responder isKindOfClass:[UIViewController class]]) responder = responder.nextResponder;
        if (responder) [[%c(YTToastResponderEvent) eventWithMessage:LOC(@"Copied") firstResponder:responder] send];
    }
}

%new
- (void)saveImage:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {

        ASNetworkImageNode *imageNode = (ASNetworkImageNode *)self.keepalive_node;
        NSURL *imageURL = imageNode.URL;
        if (imageURL) {
            NSString *URLString = imageURL.absoluteString;

            if (kFixAlbums && [URLString hasPrefix:@"https://yt3."]) {
                URLString = [URLString stringByReplacingOccurrencesOfString:@"https://yt3." withString:@"https://yt4."];
            }

            NSURL *downloadURL = nil;
            if ([URLString containsString:@"c-fcrop"]) {
                NSRange croppedURL = [URLString rangeOfString:@"c-fcrop"];
                if (croppedURL.location != NSNotFound) {
                    NSString *newURL = [URLString stringByReplacingOccurrencesOfString:[URLString substringFromIndex:croppedURL.location] withString:@"nd-v1"];
                    downloadURL = [NSURL URLWithString:newURL];
                }
            } else {
                downloadURL = imageURL;
            }

            UIResponder *responder = self.nextResponder;
            while (responder && ![responder isKindOfClass:[UIViewController class]]) responder = responder.nextResponder;

            NSURLSession *session = [NSURLSession sharedSession];
            [[session dataTaskWithURL:downloadURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                if (data) {
                    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                        PHAssetCreationRequest *request = [PHAssetCreationRequest creationRequestForAsset];
                        [request addResourceWithType:PHAssetResourceTypePhoto data:data options:nil];
                    } completionHandler:^(BOOL success, NSError *error) {
                    if (responder) [[%c(YTToastResponderEvent) eventWithMessage:success ? LOC(@"Saved") : [NSString stringWithFormat:LOC(@"%@: %@"), LOC(@"Error"), error.localizedDescription] firstResponder:responder] send];
                    }];
                } else {
                    if (responder) [[%c(YTToastResponderEvent) eventWithMessage:[NSString stringWithFormat:LOC(@"%@: %@"), LOC(@"Error"), error.localizedDescription] firstResponder:responder] send];
                }
            }] resume];
        }
    }
}

%new
- (void)copyComment:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        ELMContainerNode *containerNode = (ELMContainerNode *)self.keepalive_node;
        [UIPasteboard generalPasteboard].string = containerNode.copiedComment;

        UIResponder *responder = self.nextResponder;
        while (responder && ![responder isKindOfClass:[UIViewController class]]) responder = responder.nextResponder;
        if (responder) [[%c(YTToastResponderEvent) eventWithMessage:LOC(@"Copied") firstResponder:responder] send];
    }
}
%end

// Remove Tabs
%hook YTPivotBarView
- (void)setRenderer:(YTIPivotBarRenderer *)renderer {
    NSMutableArray <YTIPivotBarSupportedRenderers *> *items = [renderer itemsArray];

    NSDictionary *identifiersToRemove = @{
        @"FEshorts": @[@(kRemoveShorts), @(kReExplore)],
        @"FEsubscriptions": @[@(kRemoveSubscriptions)],
        @"FEuploads": @[@(kRemoveUploads)],
        @"FElibrary": @[@(kRemoveLibrary)]
    };

    for (NSString *identifier in identifiersToRemove) {
        NSArray *removeValues = identifiersToRemove[identifier];
        BOOL shouldRemoveItem = [removeValues containsObject:@(YES)];

        NSUInteger index = [items indexOfObjectPassingTest:^BOOL(YTIPivotBarSupportedRenderers *renderer, NSUInteger idx, BOOL *stop) {
            if ([identifier isEqualToString:@"FEuploads"]) {
                return shouldRemoveItem && [[[renderer pivotBarIconOnlyItemRenderer] pivotIdentifier] isEqualToString:identifier];
            } else {
                return shouldRemoveItem && [[[renderer pivotBarItemRenderer] pivotIdentifier] isEqualToString:identifier];
            }
        }];

        if (index != NSNotFound) {
            [items removeObjectAtIndex:index];
        }
    }
    
    NSUInteger exploreIndex = [items indexOfObjectPassingTest:^BOOL(YTIPivotBarSupportedRenderers *renderers, NSUInteger idx, BOOL *stop) {
        return [[[renderers pivotBarItemRenderer] pivotIdentifier] isEqualToString:[%c(YTIBrowseRequest) browseIDForExploreTab]];
    }];

    if (exploreIndex == NSNotFound && (kReExplore || kAddExplore)) {
        YTIPivotBarSupportedRenderers *exploreTab = [%c(YTIPivotBarRenderer) pivotSupportedRenderersWithBrowseId:[%c(YTIBrowseRequest) browseIDForExploreTab] title:LOC(@"Explore") iconType:292];
        [items insertObject:exploreTab atIndex:1];
    }

    %orig;
}
%end

// Hide Tab Bar Indicators
%hook YTPivotBarIndicatorView
- (void)setFillColor:(id)arg1 { %orig(kRemoveIndicators ? [UIColor clearColor] : arg1); }
- (void)setBorderColor:(id)arg1 { %orig(kRemoveIndicators ? [UIColor clearColor] : arg1); }
%end

// Hide Tab Labels
%hook YTPivotBarItemView
- (void)setRenderer:(YTIPivotBarRenderer *)renderer {
    %orig;

    if (kRemoveLabels) {
        [self.navigationButton setTitle:@"" forState:UIControlStateNormal];
        [self.navigationButton setSizeWithPaddingAndInsets:NO];
    }
}
%end

// Startup Tab
BOOL isTabSelected = NO;
%hook YTPivotBarViewController
- (void)viewDidAppear:(BOOL)animated {
    %orig;

    if (!isTabSelected && !kShortsOnlyMode) {
        NSString *pivotIdentifier;
        switch (kPivotIndex) {
            case 0:
                pivotIdentifier = @"FEwhat_to_watch";
                break;
            case 1:
                pivotIdentifier = @"FEexplore";
                break;
            case 2:
                pivotIdentifier = @"FEshorts";
                break;
            case 3:
                pivotIdentifier = @"FEsubscriptions";
                break;
            case 4:
                pivotIdentifier = @"FElibrary";
                break;
            default:
                return;
        }
        [self selectItemWithPivotIdentifier:pivotIdentifier];
        isTabSelected = YES;
    }

    if (kShortsOnlyMode) {
        [self selectItemWithPivotIdentifier:@"FEshorts"];
        [self.parentViewController hidePivotBar];
    }
}
%end

%hook YTTabsViewController
- (void)viewDidAppear:(BOOL)animated {
    %orig;

    isOverlayShown = YES;

    if (kShortsOnlyMode) {
        [self.navigationController.parentViewController hidePivotBar];
    }
}
%end

%hook YTAppViewController
- (void)showPivotBar { if (!kShortsOnlyMode) %orig; }
%end

%hook YTReelWatchRootViewController
- (void)viewDidAppear:(BOOL)animated {
    %orig;

    if (kShortsOnlyMode) {
        [self.navigationController.parentViewController hidePivotBar];
    }
}
%end

%hook YTEngagementPanelView
- (void)layoutSubviews {
    %orig;

    if ([self.panelIdentifier.identifierString isEqualToString:@"video-description-ep-identifier"]) {
        YTQTMButton *copyInfoButton = [%c(YTQTMButton) iconButton];
        copyInfoButton.accessibilityLabel = LOC(@"CopyVideoInfo");
        [copyInfoButton setTag:999];
        [copyInfoButton enableNewTouchFeedback];
        [copyInfoButton setImage:[UIImage imageNamed:@"yt_outline_copy_24pt" inBundle:[NSBundle mainBundle] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        [copyInfoButton setTintColor:[UIColor labelColor]];
        [copyInfoButton setTranslatesAutoresizingMaskIntoConstraints:false];
        [copyInfoButton addTarget:self action:@selector(didTapCopyInfoButton:) forControlEvents:UIControlEventTouchUpInside];

        if (kCopyVideoInfo && self.headerView && self.headerView.closeButton && ![self.headerView viewWithTag:999]) {
            [self.headerView addSubview:copyInfoButton];

            [NSLayoutConstraint activateConstraints:@[
                [copyInfoButton.trailingAnchor constraintEqualToAnchor:self.headerView.closeButton.leadingAnchor],
                [copyInfoButton.centerYAnchor constraintEqualToAnchor:self.headerView.closeButton.centerYAnchor],
                [copyInfoButton.widthAnchor constraintEqualToConstant:40.0],
                [copyInfoButton.heightAnchor constraintEqualToConstant:40.0],
            ]];
        }
    }
}

%new
- (void)didTapCopyInfoButton:(UIButton *)sender {
    YTPlayerViewController *playerVC = self.resizeDelegate.parentViewController.parentViewController.parentViewController.playerViewController;
    NSString *title = playerVC.playerResponse.playerData.videoDetails.title;
    NSString *shortDescription = playerVC.playerResponse.playerData.videoDetails.shortDescription;

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LOC(@"SelectAction") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    alertController.view.tintColor = [UIColor labelColor];

    [alertController addAction:[UIAlertAction actionWithTitle:LOC(@"CopyTitle") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [UIPasteboard generalPasteboard].string = title;
        [[%c(YTToastResponderEvent) eventWithMessage:LOC(@"Copied") firstResponder:self.resizeDelegate] send];
    }]];

    [alertController addAction:[UIAlertAction actionWithTitle:LOC(@"CopyDescription") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [UIPasteboard generalPasteboard].string = shortDescription;
        [[%c(YTToastResponderEvent) eventWithMessage:LOC(@"Copied") firstResponder:self.resizeDelegate] send];
    }]];

    [alertController addAction:[UIAlertAction actionWithTitle:LOC(@"Cancel") style:UIAlertActionStyleCancel handler:nil]];

    [self.resizeDelegate presentViewController:alertController animated:YES completion:nil];
}
%end

// Disable Right-To-Left Formatting
%hook NSParagraphStyle
+ (NSWritingDirection)defaultWritingDirectionForLanguage:(id)lang { return kDisableRTL ? NSWritingDirectionLeftToRight : %orig; }
+ (NSWritingDirection)_defaultWritingDirection { return kDisableRTL ? NSWritingDirectionLeftToRight : %orig; }
%end

// Fix Albums For Russian Users
static NSURL *newCoverURL(NSURL *originalURL) {
    NSDictionary <NSString *, NSString *> *hostsToReplace = @{
        @"yt3.ggpht.com": @"yt4.ggpht.com",
        @"yt3.googleusercontent.com": @"yt4.googleusercontent.com",
    };

    NSString *const replacement = hostsToReplace[originalURL.host];
    if (kFixAlbums && replacement) {
        NSURLComponents *components = [NSURLComponents componentsWithURL:originalURL resolvingAgainstBaseURL:NO];
        components.host = replacement;
        return components.URL;
    }
    return originalURL;
}

%hook ELMImageDownloader
- (id)downloadImageWithURL:(id)arg1 targetSize:(CGSize)arg2 callbackQueue:(id)arg3 downloadProgress:(id)arg4 completion:(id)arg5 {
    return %orig(newCoverURL(arg1), arg2, arg3, arg4, arg5);
}
%end

// Not necessary but preferred
%hook ASBasicImageDownloader
- (id)downloadImageWithURL:(id)arg1 shouldRetry:(BOOL)arg2 callbackQueue:(id)arg3 downloadProgress:(id)arg4 completion:(id)arg5 {
    return %orig(newCoverURL(arg1), arg2, arg3, arg4, arg5);
}
%end

static void reloadPrefs() {
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"YTLite.plist"];
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:path];

    kNoAds = (prefs[@"noAds"] != nil) ? [prefs[@"noAds"] boolValue] : YES;
    kBackgroundPlayback = (prefs[@"backgroundPlayback"] != nil) ? [prefs[@"backgroundPlayback"] boolValue] : YES;
    kNoCast = [prefs[@"noCast"] boolValue] ?: NO;
    kNoNotifsButton = [prefs[@"removeNotifsButton"] boolValue] ?: NO;
    kNoSearchButton = [prefs[@"removeSearchButton"] boolValue] ?: NO;
    kNoVoiceSearchButton = [prefs[@"removeVoiceSearchButton"] boolValue] ?: NO;
    kStickyNavbar = [prefs[@"stickyNavbar"] boolValue] ?: NO;
    kNoSubbar = [prefs[@"noSubbar"] boolValue] ?: NO;
    kNoYTLogo = [prefs[@"noYTLogo"] boolValue] ?: NO;
    kHideAutoplay = [prefs[@"hideAutoplay"] boolValue] ?: NO;
    kHideSubs = [prefs[@"hideSubs"] boolValue] ?: NO;
    kNoHUDMsgs = [prefs[@"noHUDMsgs"] boolValue] ?: NO;
    kHidePrevNext = [prefs[@"hidePrevNext"] boolValue] ?: NO;
    kReplacePrevNext = [prefs[@"replacePrevNext"] boolValue] ?: NO;
    kNoDarkBg = [prefs[@"noDarkBg"] boolValue] ?: NO;
    kEndScreenCards = [prefs[@"endScreenCards"] boolValue] ?: NO;
    kNoFullscreenActions = [prefs[@"noFullscreenActions"] boolValue] ?: NO;
    kPersistentProgressBar = [prefs[@"persistentProgressBar"] boolValue] ?: NO;
    kNoRelatedVids = [prefs[@"noRelatedVids"] boolValue] ?: NO;
    kNoPromotionCards = [prefs[@"noPromotionCards"] boolValue] ?: NO;
    kNoWatermarks = [prefs[@"noWatermarks"] boolValue] ?: NO;
    kMiniplayer = [prefs[@"miniplayer"] boolValue] ?: NO;
    kPortraitFullscreen = [prefs[@"portraitFullscreen"] boolValue] ?: NO;
    kCopyWithTimestamp = [prefs[@"copyWithTimestamp"] boolValue] ?: NO;
    kDisableAutoplay = [prefs[@"disableAutoplay"] boolValue] ?: NO;
    kDisableAutoCaptions = [prefs[@"disableAutoCaptions"] boolValue] ?: NO;
    kNoContentWarning = [prefs[@"noContentWarning"] boolValue] ?: NO;
    kClassicQuality = [prefs[@"classicQuality"] boolValue] ?: NO;
    kExtraSpeedOptions = [prefs[@"extraSpeedOptions"] boolValue] ?: NO;
    kDontSnapToChapter = [prefs[@"dontSnapToChapter"] boolValue] ?: NO;
    kRedProgressBar = [prefs[@"redProgressBar"] boolValue] ?: NO;
    kNoHints = [prefs[@"noHints"] boolValue] ?: NO;
    kNoFreeZoom = [prefs[@"noFreeZoom"] boolValue] ?: NO;
    kAutoFullscreen = [prefs[@"autoFullscreen"] boolValue] ?: NO;
    kExitFullscreen = [prefs[@"exitFullscreen"] boolValue] ?: NO;
    kNoDoubleTapToSeek = [prefs[@"noDoubleTapToSeek"] boolValue] ?: NO;
    kShortsOnlyMode = [prefs[@"shortsOnlyMode"] boolValue] ?: NO;
    kHideShorts = [prefs[@"hideShorts"] boolValue] ?: NO;
    kShortsProgress = [prefs[@"shortsProgress"] boolValue] ?: NO;
    kPinchToFullscreenShorts = [prefs[@"pinchToFullscreenShorts"] boolValue] ?: NO;
    kShortsToRegular = [prefs[@"shortsToRegular"] boolValue] ?: NO;
    kResumeShorts = [prefs[@"resumeShorts"] boolValue] ?: NO;
    kHideShortsLogo = [prefs[@"hideShortsLogo"] boolValue] ?: NO;
    kHideShortsSearch = [prefs[@"hideShortsSearch"] boolValue] ?: NO;
    kHideShortsCamera = [prefs[@"hideShortsCamera"] boolValue] ?: NO;
    kHideShortsMore = [prefs[@"hideShortsMore"] boolValue] ?: NO;
    kHideShortsSubscriptions = [prefs[@"hideShortsSubscriptions"] boolValue] ?: NO;
    kHideShortsLike = [prefs[@"hideShortsLike"] boolValue] ?: NO;
    kHideShortsDislike = [prefs[@"hideShortsDislike"] boolValue] ?: NO;
    kHideShortsComments = [prefs[@"hideShortsComments"] boolValue] ?: NO;
    kHideShortsRemix = [prefs[@"hideShortsRemix"] boolValue] ?: NO;
    kHideShortsShare = [prefs[@"hideShortsShare"] boolValue] ?: NO;
    kHideShortsAvatars = [prefs[@"hideShortsAvatars"] boolValue] ?: NO;
    kHideShortsThanks = [prefs[@"hideShortsThanks"] boolValue] ?: NO;
    kHideShortsSource = [prefs[@"hideShortsSource"] boolValue] ?: NO;
    kHideShortsChannelName = [prefs[@"hideShortsChannelName"] boolValue] ?: NO;
    kHideShortsDescription = [prefs[@"hideShortsDescription"] boolValue] ?: NO;
    kHideShortsAudioTrack = [prefs[@"hideShortsAudioTrack"] boolValue] ?: NO;
    kHideShortsPromoCards = [prefs[@"hideShortsPromoCards"] boolValue] ?: NO;
    kRemoveLabels = [prefs[@"removeLabels"] boolValue] ?: NO;
    kRemoveIndicators = [prefs[@"removeIndicators"] boolValue] ?: NO;
    kReExplore = [prefs[@"reExplore"] boolValue] ?: NO;
    kAddExplore = [prefs[@"addExplore"] boolValue] ?: NO;
    kRemoveShorts = [prefs[@"removeShorts"] boolValue] ?: NO;
    kRemoveSubscriptions = [prefs[@"removeSubscriptions"] boolValue] ?: NO;
    kRemoveUploads = (prefs[@"removeUploads"] != nil) ? [prefs[@"removeUploads"] boolValue] : YES;
    kRemoveLibrary = [prefs[@"removeLibrary"] boolValue] ?: NO;
    kCopyVideoInfo = [prefs[@"copyVideoInfo"] boolValue] ?: NO;
    kCopyPostText = [prefs[@"copyPostText"] boolValue] ?: NO;
    kSavePostImage = [prefs[@"savePostImage"] boolValue] ?: NO;
    kSaveProfilePhoto = [prefs[@"savePostImage"] boolValue] ?: NO;
    kCopyCommentText = [prefs[@"copyCommentText"] boolValue] ?: NO;
    kFixAlbums = [prefs[@"fixAlbums"] boolValue] ?: NO;
    kRemovePlayNext = [prefs[@"removePlayNext"] boolValue] ?: NO;
    kNoContinueWatching = [prefs[@"noContinueWatching"] boolValue] ?: NO;
    kNoSearchHistory = [prefs[@"noSearchHistory"] boolValue] ?: NO;
    kNoRelatedWatchNexts = [prefs[@"noRelatedWatchNexts"] boolValue] ?: NO;
    kStickSortComments = [prefs[@"stickSortComments"] boolValue] ?: NO;
    kHideSortComments = [prefs[@"hideSortComments"] boolValue] ?: NO;
    kPlaylistOldMinibar = [prefs[@"playlistOldMinibar"] boolValue] ?: NO;
    kDisableRTL = [prefs[@"disableRTL"] boolValue] ?: NO;
    kPivotIndex = (prefs[@"pivotIndex"] != nil) ? [prefs[@"pivotIndex"] intValue] : 0;
    kAdvancedMode = [prefs[@"advancedMode"] boolValue] ?: NO;
    kAdvancedModeReminder = [prefs[@"advancedModeReminder"] boolValue] ?: NO;

    NSDictionary *newSettings = @{
        @"noAds" : @(kNoAds),
        @"backgroundPlayback" : @(kBackgroundPlayback),
        @"noCast" : @(kNoCast),
        @"removeNotifsButton" : @(kNoNotifsButton),
        @"removeSearchButton" : @(kNoSearchButton),
        @"removeVoiceSearchButton" : @(kNoVoiceSearchButton),
        @"stickyNavbar" : @(kStickyNavbar),
        @"noSubbar" : @(kNoSubbar),
        @"noYTLogo" : @(kNoYTLogo),
        @"hideAutoplay" : @(kHideAutoplay),
        @"hideSubs" : @(kHideSubs),
        @"noHUDMsgs" : @(kNoHUDMsgs),
        @"hidePrevNext" : @(kHidePrevNext),
        @"replacePrevNext" : @(kReplacePrevNext),
        @"noDarkBg" : @(kNoDarkBg),
        @"endScreenCards" : @(kEndScreenCards),
        @"noFullscreenActions" : @(kNoFullscreenActions),
        @"persistentProgressBar" : @(kPersistentProgressBar),
        @"noRelatedVids" : @(kNoRelatedVids),
        @"noPromotionCards" : @(kNoPromotionCards),
        @"noWatermarks" : @(kNoWatermarks),
        @"miniplayer" : @(kMiniplayer),
        @"portraitFullscreen" : @(kPortraitFullscreen),
        @"copyWithTimestamp" : @(kCopyWithTimestamp),
        @"disableAutoplay" : @(kDisableAutoplay),
        @"disableAutoCaptions" : @(kDisableAutoCaptions),
        @"noContentWarning" : @(kNoContentWarning),
        @"classicQuality" : @(kClassicQuality),
        @"extraSpeedOptions" : @(kExtraSpeedOptions),
        @"dontSnapToChapter" : @(kDontSnapToChapter),
        @"redProgressBar" : @(kRedProgressBar),
        @"noHints" : @(kNoHints),
        @"noFreeZoom" : @(kNoFreeZoom),
        @"autoFullscreen" : @(kAutoFullscreen),
        @"exitFullscreen" : @(kExitFullscreen),
        @"noDoubleTapToSeek" : @(kNoDoubleTapToSeek),
        @"shortsOnlyMode" : @(kShortsOnlyMode),
        @"hideShorts" : @(kHideShorts),
        @"shortsProgress" : @(kShortsProgress),
        @"pinchToFullscreenShorts" : @(kPinchToFullscreenShorts),
        @"shortsToRegular" : @(kShortsToRegular),
        @"resumeShorts" : @(kResumeShorts),
        @"hideShortsLogo" : @(kHideShortsLogo),
        @"hideShortsSearch" : @(kHideShortsSearch),
        @"hideShortsCamera" : @(kHideShortsCamera),
        @"hideShortsMore" : @(kHideShortsMore),
        @"hideShortsSubscriptions" : @(kHideShortsSubscriptions),
        @"hideShortsLike" : @(kHideShortsLike),
        @"hideShortsDislike" : @(kHideShortsDislike),
        @"hideShortsComments" : @(kHideShortsComments),
        @"hideShortsRemix" : @(kHideShortsRemix),
        @"hideShortsShare" : @(kHideShortsShare),
        @"hideShortsAvatars" : @(kHideShortsAvatars),
        @"hideShortsThanks" : @(kHideShortsThanks),
        @"hideShortsSource" : @(kHideShortsSource),
        @"hideShortsChannelName" : @(kHideShortsChannelName),
        @"hideShortsDescription" : @(kHideShortsDescription),
        @"hideShortsAudioTrack" : @(kHideShortsAudioTrack),
        @"hideShortsPromoCards" : @(kHideShortsPromoCards),
        @"removeLabels" : @(kRemoveLabels),
        @"removeIndicators" : @(kRemoveIndicators),
        @"reExplore" : @(kReExplore),
        @"addExplore" : @(kAddExplore),
        @"removeShorts" : @(kRemoveShorts),
        @"removeSubscriptions" : @(kRemoveSubscriptions),
        @"removeUploads" : @(kRemoveUploads),
        @"removeLibrary" : @(kRemoveLibrary),
        @"copyVideoInfo" : @(kCopyVideoInfo),
        @"copyPostText" : @(kCopyPostText),
        @"savePostImage" : @(kSavePostImage),
        @"saveProfilePhoto" : @(kSaveProfilePhoto),
        @"copyCommentText" : @(kCopyCommentText),
        @"fixAlbums" : @(kFixAlbums),
        @"removePlayNext" : @(kRemovePlayNext),
        @"noContinueWatching" : @(kNoContinueWatching),
        @"noSearchHistory" : @(kNoSearchHistory),
        @"noRelatedWatchNexts" : @(kNoRelatedWatchNexts),
        @"stickSortComments" : @(kStickSortComments),
        @"hideSortComments" : @(kHideSortComments),
        @"playlistOldMinibar" : @(kPlaylistOldMinibar),
        @"disableRTL" : @(kDisableRTL),
        @"pivotIndex" : @(kPivotIndex),
        @"advancedMode" : @(kAdvancedMode),
        @"advancedModeReminder" : @(kAdvancedModeReminder)
    };

    if (![newSettings isEqualToDictionary:prefs]) [newSettings writeToFile:path atomically:NO];
}

static void prefsChanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    reloadPrefs();
}

%ctor {
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"YTLite.plist"];
    NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:path];

    if ([prefs[@"shortsOnlyMode"] boolValue] && ([prefs[@"removeShorts"] boolValue] || [prefs[@"reExplore"] boolValue])) {
        [prefs setObject:@NO forKey:@"removeShorts"];
        [prefs setObject:@NO forKey:@"reExplore"];
        [prefs writeToFile:path atomically:NO];
    }

    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)prefsChanged, CFSTR("com.dvntm.ytlite.prefschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
    reloadPrefs();
}
