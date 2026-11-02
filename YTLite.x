#import "YTLite.h"

static const char kYTLAutoSkipKey;
static const char kYTLGestureKey;
static const char kYTLShortsModeGestureKey;
static const char kYTLManageTabGestureKey;
static const char kYTLSpeedmasterGestureKey;

static UIImage *YTImageNamed(NSString *imageName) {
    return [UIImage imageNamed:imageName inBundle:[NSBundle mainBundle] compatibleWithTraitCollection:nil];
}

// YouTube-X (https://github.com/PoomSmart/YouTube-X/)
// Background Playback
%hook YTIPlayabilityStatus
- (BOOL)isPlayableInBackground { return ytlBool(@"backgroundPlayback") ? YES : NO; }
%end

%hook MLVideo
- (BOOL)playableInBackground { return ytlBool(@"backgroundPlayback") ? YES : NO; }
%end

// Disable Ads
%hook YTIPlayerResponse
- (BOOL)isMonetized { return ytlBool(@"noAds") ? NO : %orig; }
%end

%hook YTDataUtils
+ (id)spamSignalsDictionary { return ytlBool(@"noAds") ? nil : %orig; }
+ (id)spamSignalsDictionaryWithoutIDFA { return ytlBool(@"noAds") ? nil : %orig; }
%end

%hook YTAdsInnerTubeContextDecorator
- (void)decorateContext:(id)context { if (!ytlBool(@"noAds")) %orig; }
%end

%hook YTAccountScopedAdsInnerTubeContextDecorator
- (void)decorateContext:(id)context { if (!ytlBool(@"noAds")) %orig; }
%end

%hook YTIElementRenderer
- (NSData *)elementData {
    if (self.hasCompatibilityOptions && self.compatibilityOptions.hasAdLoggingData && ytlBool(@"noAds")) return nil;

    NSString *description = [self description];

    if (ytlBool(@"noAds")) {
        static NSArray *ads;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            ads = @[@"brand_promo", @"product_carousel", @"product_engagement_panel", @"product_item", @"text_search_ad", @"text_image_button_layout", @"carousel_headered_layout", @"carousel_footered_layout", @"square_image_layout", @"landscape_image_wide_button_layout", @"feed_ad_metadata"];
        });
        for (NSString *ad in ads) {
            if ([description containsString:ad]) return [NSData data];
        }
    }

    if (ytlBool(@"hideShorts") && ![description containsString:@"history*"]) {
        for (NSString *shorts in @[@"shorts_shelf.eml", @"shorts_video_cell.eml", @"6Shorts"]) {
            if ([description containsString:shorts]) return nil;
        }
    }

    return %orig;
}
%end

%hook YTSectionListViewController
- (void)loadWithModel:(YTISectionListRenderer *)model {
    if (ytlBool(@"noAds")) {
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
- (BOOL)isPersistentCastIconEnabled { return ytlBool(@"noCast") ? NO : YES; }
- (void)updateRouteButton:(id)arg1 { if (!ytlBool(@"noCast")) %orig; }
- (void)updateAllRouteButtons { if (!ytlBool(@"noCast")) %orig; }
%end

%hook YTSettings
- (void)setDisableMDXDeviceDiscovery:(BOOL)arg1 { ytlBool(@"noCast") ? %orig(YES) : %orig; }
%end

// Hide Navigation Bar Buttons
%hook YTRightNavigationButtons
- (void)layoutSubviews {
    %orig;

    if (ytlBool(@"noNotifsButton")) self.notificationButton.hidden = YES;
    if (ytlBool(@"noSearchButton")) self.searchButton.hidden = YES;

    for (UIView *subview in self.subviews) {
        if (ytlBool(@"noVoiceSearchButton") && [subview.accessibilityLabel isEqualToString:NSLocalizedString(@"search.voice.access", nil)]) subview.hidden = YES;
        if (ytlBool(@"noCast") && [subview.accessibilityIdentifier isEqualToString:@"id.mdx.playbackroute.button"]) subview.hidden = YES;
    }
}
%end

%hook YTSearchViewController
- (void)viewDidLoad {
    %orig;

    if (ytlBool(@"noVoiceSearchButton")) [self setValue:@(NO) forKey:@"_isVoiceSearchAllowed"];
}

- (void)setSuggestions:(id)arg1 { if (!ytlBool(@"noSearchHistory")) %orig; }
%end

%hook YTPersonalizedSuggestionsCacheProvider
- (id)activeCache { return ytlBool(@"noSearchHistory") ? nil : %orig; }
%end

// Remove Videos Section Under Player
%hook YTWatchNextResultsViewController
- (void)setVisibleSections:(NSInteger)arg1 {
    arg1 = (ytlBool(@"noRelatedWatchNexts")) ? 1 : arg1;
    %orig(arg1);
}
%end

%hook YTHeaderView
// Stick Navigation bar
- (BOOL)stickyNavHeaderEnabled { return ytlBool(@"stickyNavbar") ? YES : %orig; }

// Hide YouTube Logo
- (void)setCustomTitleView:(UIView *)customTitleView { if (!ytlBool(@"noYTLogo")) %orig; }
- (void)setTitle:(NSString *)title { ytlBool(@"noYTLogo") ? %orig(@"") : %orig; }
%end

// Premium logo
%hook UIImageView
- (void)setImage:(UIImage *)image {
    if (!ytlBool(@"premiumYTLogo")) return %orig;

    if (!image) return %orig;

    static NSBundle *frameworkBundle;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *resourcesPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Frameworks/Module_Framework.framework/Innertube_Resources.bundle"];
        frameworkBundle = [NSBundle bundleWithPath:resourcesPath];
    });

    NSString *imageDescription = [image description];
    UIImage *premiumImage = nil;

    if ([imageDescription containsString:@"Resources: youtube_logo)"]) {
        premiumImage = [UIImage imageNamed:@"youtube_premium_logo" inBundle:frameworkBundle compatibleWithTraitCollection:nil];
    } else if ([imageDescription containsString:@"Resources: youtube_logo_dark)"]) {
        premiumImage = [UIImage imageNamed:@"youtube_premium_logo_white" inBundle:frameworkBundle compatibleWithTraitCollection:nil];
    }

    %orig(premiumImage ?: image);
}
%end

// Remove Subbar
%hook YTMySubsFilterHeaderView
- (void)setChipFilterView:(id)arg1 { if (!ytlBool(@"noSubbar")) %orig; }
%end

%hook YTHeaderContentComboView
- (void)enableSubheaderBarWithView:(id)arg1 { if (!ytlBool(@"noSubbar")) %orig; }
- (void)setFeedHeaderScrollMode:(int)arg1 { ytlBool(@"noSubbar") ? %orig(0) : %orig; }
%end

%hook YTChipCloudCell
- (void)layoutSubviews {
    if (self.superview && ytlBool(@"noSubbar")) {
        [self removeFromSuperview];
    } %orig;
}
%end

%hook YTMainAppControlsOverlayView
// Hide Autoplay Switch
- (void)setAutoplaySwitchButtonRenderer:(id)arg1 { if (!ytlBool(@"hideAutoplay")) %orig; }

// Hide Subs Button
- (void)setClosedCaptionsOrSubtitlesButtonAvailable:(BOOL)arg1 { ytlBool(@"hideSubs") ? %orig(NO) : %orig; }

// Pause On Overlay
- (void)setOverlayVisible:(BOOL)visible {
    %orig;

    if (!ytlBool(@"pauseOnOverlay")) return;

    YTPlayerViewController *playerVC = self.playerViewController;
    if (!playerVC) return;
    visible ? [playerVC pause] : [playerVC play];
}
%end

// Remove HUD Messages
%hook YTHUDMessageView
- (id)initWithMessage:(id)arg1 dismissHandler:(id)arg2 { return ytlBool(@"noHUDMsgs") ? nil : %orig; }
%end

%hook YTColdConfig
// Hide Next & Previous buttons
- (BOOL)removeNextPaddleForSingletonVideos { return ytlBool(@"hidePrevNext") ? YES : %orig; }
- (BOOL)removePreviousPaddleForSingletonVideos { return ytlBool(@"hidePrevNext") ? YES : %orig; }
// Replace Next & Previous with Fast Forward & Rewind buttons
- (BOOL)replaceNextPaddleWithFastForwardButtonForSingletonVods { return ytlBool(@"replacePrevNext") ? YES : %orig; }
- (BOOL)replacePreviousPaddleWithRewindButtonForSingletonVods { return ytlBool(@"replacePrevNext") ? YES : %orig; }
// Disable Free Zoom
- (BOOL)videoZoomFreeZoomEnabledGlobalConfig { return ytlBool(@"noFreeZoom") ? NO : %orig; }
// Stick Sort Buttons in Comments Section
- (BOOL)enableHideChipsInTheCommentsHeaderOnScrollIos { return ytlBool(@"stickSortComments") ? NO : %orig; }
// Hide Sort Buttons in Comments Section
- (BOOL)enableChipsInTheCommentsHeaderIos { return ytlBool(@"hideSortComments") ? NO : %orig; }
// Use System Theme
- (BOOL)shouldUseAppThemeSetting { return YES; }
// Dismiss Panel By Swiping in Fullscreen Mode
- (BOOL)isLandscapeEngagementPanelSwipeRightToDismissEnabled { return YES; }
// Remove Video in Playlist By Swiping To The Right
- (BOOL)enableSwipeToRemoveInPlaylistWatchEp { return YES; }
// Enable Old-style Minibar For Playlist Panel
- (BOOL)queueClientGlobalConfigEnableFloatingPlaylistMinibar { return ytlBool(@"playlistOldMinibar") ? NO : %orig; }
%end

// Remove Dark Background in Overlay
%hook YTMainAppVideoPlayerOverlayView
- (void)setBackgroundVisible:(BOOL)arg1 isGradientBackground:(BOOL)arg2 { ytlBool(@"noDarkBg") ? %orig(NO, arg2) : %orig; }
%end

// No Endscreen Cards
%hook YTCreatorEndscreenView
- (void)setHidden:(BOOL)arg1 { ytlBool(@"endScreenCards") ? %orig(YES) : %orig; }
%end

// Disable Fullscreen Actions
%hook YTFullscreenActionsView
- (BOOL)enabled { return ytlBool(@"noFullscreenActions") ? NO : %orig; }
- (void)setEnabled:(BOOL)arg1 { ytlBool(@"noFullscreenActions") ? %orig(NO) : %orig; }
%end

// Dont Show Related Videos on Finish
%hook YTFullscreenEngagementOverlayController
- (void)setRelatedVideosVisible:(BOOL)arg1 { ytlBool(@"noRelatedVids") ? %orig(NO) : %orig; }
%end

// Hide Paid Promotion Cards
%hook YTMainAppVideoPlayerOverlayViewController
- (void)setPaidContentWithPlayerData:(id)data { if (!ytlBool(@"noPromotionCards")) %orig; }
- (void)playerOverlayProvider:(YTPlayerOverlayProvider *)provider didInsertPlayerOverlay:(YTPlayerOverlay *)overlay {
    if ([[overlay overlayIdentifier] isEqualToString:@"player_overlay_paid_content"] && ytlBool(@"noPromotionCards")) return;
    %orig;
}
%end

%hook YTInlineMutedPlaybackPlayerOverlayViewController
- (void)setPaidContentWithPlayerData:(id)data { if (!ytlBool(@"noPromotionCards")) %orig; }
%end

%hook YTInlinePlayerBarContainerView
- (void)setPlayerBarAlpha:(CGFloat)alpha { ytlBool(@"persistentProgressBar") ? %orig(1.0) : %orig; }
%end

// Remove Watermarks
%hook YTAnnotationsViewController
- (void)loadFeaturedChannelWatermark { if (!ytlBool(@"noWatermarks")) %orig; }
%end

%hook YTMainAppVideoPlayerOverlayView
- (BOOL)isWatermarkEnabled { return ytlBool(@"noWatermarks") ? NO : %orig; }
%end

// Forcibly Enable Miniplayer
%hook YTWatchMiniBarViewController
- (void)updateMiniBarPlayerStateFromRenderer { if (!ytlBool(@"miniplayer")) %orig; }
%end

// Portrait Fullscreen
%hook YTWatchViewController
- (unsigned long long)allowedFullScreenOrientations { return ytlBool(@"portraitFullscreen") ? UIInterfaceOrientationMaskAllButUpsideDown : %orig; }
%end

// Disable Autoplay
%hook YTPlaybackConfig
- (void)setStartPlayback:(BOOL)arg1 { ytlBool(@"disableAutoplay") ? %orig(NO) : %orig; }
%end

// Skip Content Warning (https://github.com/qnblackcat/uYouPlus/blob/main/uYouPlus.xm#L452-L454)
%hook YTPlayabilityResolutionUserActionUIController
- (void)showConfirmAlert { ytlBool(@"noContentWarning") ? [self confirmAlertDidPressConfirm] : %orig; }
%end

// Classic Video Quality (https://github.com/PoomSmart/YTClassicVideoQuality)
%hook YTVideoQualitySwitchControllerFactory
- (id)videoQualitySwitchControllerWithParentResponder:(id)responder {
    Class originalClass = %c(YTVideoQualitySwitchOriginalController);
    return ytlBool(@"classicQuality") && originalClass ? [[originalClass alloc] initWithParentResponder:responder] : %orig;
}
%end

// Extra Speed Options
%hook YTVarispeedSwitchController
- (void)setDelegate:(id)arg1 {
    if (ytlBool(@"extraSpeedOptions")) {
        NSArray *currentOptions = [self valueForKey:@"_options"];
        NSMutableArray *optionsCopy = currentOptions ? [currentOptions mutableCopy] : [NSMutableArray array];
        NSMutableSet *existingRates = [NSMutableSet set];

        for (YTVarispeedSwitchControllerOption *option in optionsCopy) {
            if ([option respondsToSelector:@selector(rate)]) [existingRates addObject:@(option.rate)];
        }

        for (NSString *title in @[@"2.5", @"3", @"3.5", @"4", @"5"]) {
            float rate = [title floatValue];
            if ([existingRates containsObject:@(rate)]) continue;
            YTVarispeedSwitchControllerOption *option = [[%c(YTVarispeedSwitchControllerOption) alloc] initWithTitle:title rate:rate];
            if (option) [optionsCopy addObject:option];
        }

        [self setValue:[optionsCopy copy] forKey:@"_options"];
    }

    %orig;
}
%end

// Temprorary Fix For 'Classic Video Quality' and 'Extra Speed Options'
%hook YTVersionUtils
+ (NSString *)appVersion {
    NSString *originalVersion = %orig;
    NSString *fakeVersion = @"18.18.2";

    return (!ytlBool(@"classicQuality") && !ytlBool(@"extraSpeedOptions") && [originalVersion compare:fakeVersion options:NSNumericSearch] == NSOrderedDescending) ? originalVersion : fakeVersion;
}
%end

// Show real version in YT Settings
%hook YTSettingsCell
- (void)setDetailText:(id)arg1 {
    if ([arg1 isKindOfClass:[NSString class]] && [arg1 isEqualToString:@"18.18.2"]) {
        NSString *appVersion = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
        if (appVersion) arg1 = appVersion;
    }
    %orig(arg1);
}
%end

// Disable Snap To Chapter (https://github.com/qnblackcat/uYouPlus/blob/main/uYouPlus.xm#L457-464)
%hook YTSegmentableInlinePlayerBarView
- (void)didMoveToWindow { %orig; if (ytlBool(@"dontSnapToChapter")) self.enableSnapToChapter = NO; }
%end

// Red Progress Bar and Gray Buffer Progress
%hook YTInlinePlayerBarContainerView
- (id)quietProgressBarColor { return ytlBool(@"redProgressBar") ? [UIColor redColor] : %orig; }
%end

%hook YTSegmentableInlinePlayerBarView
- (void)setBufferedProgressBarColor:(id)arg1 { ytlBool(@"redProgressBar") ? %orig([UIColor colorWithRed:0.65 green:0.65 blue:0.65 alpha:0.60]) : %orig; }
%end

// Disable Hints
%hook YTSettings
- (BOOL)areHintsDisabled { return ytlBool(@"noHints") ? YES : %orig; }
- (void)setHintsDisabled:(BOOL)arg1 { ytlBool(@"noHints") ? %orig(YES) : %orig; }
%end

%hook YTUserDefaults
- (BOOL)areHintsDisabled { return ytlBool(@"noHints") ? YES : %orig; }
- (void)setHintsDisabled:(BOOL)arg1 { ytlBool(@"noHints") ? %orig(YES) : %orig; }
%end

void addEndTime(YTPlayerViewController *self, YTSingleVideoController *video, YTSingleVideoTime *time) {
    if (!ytlBool(@"videoEndTime")) return;

    if (video.totalMediaTime <= 0) return;

    YTPlayerView *playerView = (YTPlayerView *)self.view;
    if (![playerView respondsToSelector:@selector(overlayView)] || ![playerView.overlayView isKindOfClass:%c(YTMainAppVideoPlayerOverlayView)]) return;

    CGFloat rate = video.playbackRate > 0 ? video.playbackRate : 1.0;
    NSTimeInterval remainingTime = MAX(0, (lround(video.totalMediaTime) - lround(time.time)) / rate);

    NSDate *estimatedEndTime = [NSDate dateWithTimeIntervalSinceNow:remainingTime];

    static NSDateFormatter *dateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    });
    [dateFormatter setDateFormat:ytlBool(@"24hrFormat") ? @"HH:mm" : @"h:mm a"];

    NSString *formattedEndTime = [dateFormatter stringFromDate:estimatedEndTime];

    YTMainAppVideoPlayerOverlayView *overlay = (YTMainAppVideoPlayerOverlayView *)playerView.overlayView;
    YTLabel *durationLabel = overlay.playerBar.durationLabel;
    NSString *previousEndTime = overlay.playerBar.endTimeString;
    overlay.playerBar.endTimeString = formattedEndTime;

    NSString *text = durationLabel.text;
    if (!text || [text containsString:formattedEndTime]) return;

    if (previousEndTime.length) {
        NSRange range = [text rangeOfString:[NSString stringWithFormat:@" • %@", previousEndTime]];
        if (range.location != NSNotFound) text = [text substringToIndex:range.location];
    }

    durationLabel.text = [text stringByAppendingFormat:@" • %@", formattedEndTime];
    [durationLabel sizeToFit];
}

void autoSkipShorts(YTPlayerViewController *self, YTSingleVideoController *video, YTSingleVideoTime *time) {
    if (!ytlBool(@"autoSkipShorts")) return;

    if (video.totalMediaTime <= 0 || floor(time.time) < floor(video.totalMediaTime)) return;
    if (![self.parentViewController isKindOfClass:%c(YTShortsPlayerViewController)]) return;

    YTShortsPlayerViewController *shortsVC = (YTShortsPlayerViewController *)self.parentViewController;
    NSString *videoID = self.contentVideoID;
    if (!videoID || [objc_getAssociatedObject(self, &kYTLAutoSkipKey) isEqualToString:videoID]) return;

    if ([shortsVC respondsToSelector:@selector(reelContentViewRequestsAdvanceToNextVideo:)]) {
        objc_setAssociatedObject(self, &kYTLAutoSkipKey, videoID, OBJC_ASSOCIATION_COPY_NONATOMIC);
        [shortsVC performSelector:@selector(reelContentViewRequestsAdvanceToNextVideo:) withObject:nil];
    }
}

%hook YTPlayerViewController
- (void)loadWithPlayerTransition:(id)arg1 playbackConfig:(id)arg2 {
    %orig;

    NSArray *selectors = @[@"autoQuality", @"autoFullscreen", @"shortsToRegular", @"setAutoSpeed", @"turnOffCaptions"];
    for (NSString *selector in selectors) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:NSSelectorFromString(selector) object:nil];
    }

    if (ytlInt(@"wiFiQualityIndex") != 0 || ytlInt(@"cellQualityIndex") != 0) [self performSelector:@selector(autoQuality) withObject:nil afterDelay:1.0];
    if (ytlBool(@"autoFullscreen")) [self performSelector:@selector(autoFullscreen) withObject:nil afterDelay:0.75];
    if (ytlBool(@"shortsToRegular")) [self performSelector:@selector(shortsToRegular) withObject:nil afterDelay:0.75];
    if (ytlInt(@"autoSpeedIndex") != 3) [self performSelector:@selector(setAutoSpeed) withObject:nil afterDelay:0.75];
    if (ytlBool(@"disableAutoCaptions")) [self performSelector:@selector(turnOffCaptions) withObject:nil afterDelay:1.0];
}

%new
- (void)autoFullscreen {
    if (![self.view.superview isKindOfClass:NSClassFromString(@"YTWatchView")]) return;

    YTWatchController *watchController = [self valueForKey:@"_UIDelegate"];
    if ([watchController respondsToSelector:@selector(showFullScreen)]) [watchController showFullScreen];
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
    if ([self.view.superview isKindOfClass:NSClassFromString(@"YTWatchView")]) {
        [self setActiveCaptionTrack:nil];
    }
}

%new
- (void)setAutoSpeed {
    if ([self.activeVideoPlayerOverlay isKindOfClass:NSClassFromString(@"YTMainAppVideoPlayerOverlayViewController")]
        && [self.view.superview isKindOfClass:NSClassFromString(@"YTWatchView")]) {
        YTMainAppVideoPlayerOverlayViewController *overlayVC = (YTMainAppVideoPlayerOverlayViewController *)self.activeVideoPlayerOverlay;

        NSArray *speedLabels = @[@0.25, @0.5, @0.75, @1.0, @1.25, @1.5, @1.75, @2.0, @3.0, @4.0, @5.0];
        NSInteger index = ytlInt(@"autoSpeedIndex");
        if (index < 0 || index >= (NSInteger)speedLabels.count) return;
        [overlayVC setPlaybackRate:[speedLabels[index] floatValue]];
    }
}

%new
- (void)autoQuality {
    if (![self.view.superview isKindOfClass:NSClassFromString(@"YTWatchView")]) {
        return;
    }

    NetworkStatus status = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    NSInteger kQualityIndex = status == ReachableViaWiFi ? ytlInt(@"wiFiQualityIndex") : ytlInt(@"cellQualityIndex");
    if (kQualityIndex <= 0) return;

    NSArray *formats = self.activeVideo.selectableVideoFormats;
    if (formats.count == 0) return;

    NSString *bestQualityLabel;
    int highestResolution = 0;
    for (MLFormat *format in formats) {
        int reso = format.singleDimensionResolution;
        if (reso > highestResolution && format.qualityLabel) {
            highestResolution = reso;
            bestQualityLabel = format.qualityLabel;
        }
    }
    if (!bestQualityLabel) return;

    NSArray *qualityLabels = @[@"Default", bestQualityLabel, @"2160p60", @"2160p", @"1440p60", @"1440p", @"1080p60", @"1080p", @"720p60", @"720p", @"480p", @"360p"];
    if (kQualityIndex >= (NSInteger)qualityLabels.count) return;
    NSString *qualityLabel = qualityLabels[kQualityIndex];

    if (![qualityLabel isEqualToString:bestQualityLabel]) {
        BOOL exactMatch = NO;
        NSString *closestQualityLabel = qualityLabel;

        for (MLFormat *format in formats) {
            if ([format.qualityLabel isEqualToString:qualityLabel]) {
                exactMatch = YES;
                break;
            }
        }

        if (!exactMatch) {
            NSInteger bestQualityDifference = NSIntegerMax;

            for (MLFormat *format in formats) {
                NSArray *formatComponents = [format.qualityLabel componentsSeparatedByString:@"p"];
                NSArray *targetComponents = [qualityLabel componentsSeparatedByString:@"p"];
                if (formatComponents.count == 2) {
                    NSInteger formatQuality = [formatComponents.firstObject integerValue];
                    NSInteger targetQuality = [targetComponents.firstObject integerValue];
                    NSInteger difference = labs(formatQuality - targetQuality);
                    BOOL sameFps = [formatComponents.lastObject isEqualToString:targetComponents.lastObject ?: @""];
                    if (difference < bestQualityDifference || (difference == bestQualityDifference && sameFps)) {
                        bestQualityDifference = difference;
                        closestQualityLabel = format.qualityLabel;
                    }
                }
            }

            qualityLabel = closestQualityLabel;
        }
    }

    Class constraintClass = %c(MLQuickMenuVideoQualitySettingFormatConstraint);
    if ([constraintClass instancesRespondToSelector:@selector(initWithVideoQualitySetting:formatSelectionReason:qualityLabel:)]) {
        MLQuickMenuVideoQualitySettingFormatConstraint *fc = [[constraintClass alloc] initWithVideoQualitySetting:3 formatSelectionReason:2 qualityLabel:qualityLabel];
        if (fc) [self.activeVideo setVideoFormatConstraint:fc];
    }
}

- (void)singleVideo:(YTSingleVideoController *)video currentVideoTimeDidChange:(YTSingleVideoTime *)time {
    %orig;

    addEndTime(self, video, time);
    autoSkipShorts(self, video, time);
}

- (void)potentiallyMutatedSingleVideo:(YTSingleVideoController *)video currentVideoTimeDidChange:(YTSingleVideoTime *)time {
    %orig;

    addEndTime(self, video, time);
    autoSkipShorts(self, video, time);
}
%end

%hook YTInlinePlayerBarContainerView
%property (nonatomic, strong) NSString *endTimeString;
- (void)setPeekableViewVisible:(BOOL)visible {
    %orig;

    if (!ytlBool(@"videoEndTime")) return;

    if (self.endTimeString && self.durationLabel.text && ![self.durationLabel.text containsString:self.endTimeString]) {
        self.durationLabel.text = [self.durationLabel.text stringByAppendingString:[NSString stringWithFormat:@" • %@", self.endTimeString]];
        [self.durationLabel sizeToFit];
    }
}
%end

// Exit Fullscreen on Finish
%hook YTWatchFlowController
- (BOOL)shouldExitFullScreenOnFinish { return ytlBool(@"exitFullscreen") ? YES : %orig; }
%end

%hook YTMainAppVideoPlayerOverlayViewController
// Disable Double Tap To Seek
- (BOOL)allowDoubleTapToSeekGestureRecognizer { return ytlBool(@"noDoubleTapToSeek") ? NO : %orig; }

// Disable Two Finger Double Tap
- (BOOL)allowTwoFingerDoubleTapGestureRecognizer { return ytlBool(@"noTwoFingerSnapToChapter") ? NO : %orig; }

// Copy Timestamped Link by Pressing On Pause
- (void)didPressPause:(id)arg1 {
    %orig;

    if (ytlBool(@"copyWithTimestamp") && self.videoID.length) {
        NSInteger mediaTimeInteger = (NSInteger)self.mediaTime;
        NSString *currentTimeLink = [NSString stringWithFormat:@"https://www.youtube.com/watch?v=%@&t=%lds", self.videoID, mediaTimeInteger];

        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = currentTimeLink;
    }
}
%end

// Fit 'Play All' Buttons Text For Localizations
%hook YTQTMButton
- (UILabel *)titleLabel {
    UILabel *label = %orig;

    if ([self.accessibilityIdentifier isEqualToString:@"id.playlist.playall.button"]) {
        label.adjustsFontSizeToFitWidth = YES;
    }

    return label;
}
%end

// Fit Shorts Button Labels For Localizations
%hook YTReelPlayerButton
- (UILabel *)titleLabel {
    UILabel *label = %orig;
    label.adjustsFontSizeToFitWidth = YES;

    return label;
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
    if (ytlBool(@"removePlayNext") && renderer.icon.iconType == 251) {
        return NO;
    } return %orig;
}
%end

// Remove Download button from the menu
%hook YTDefaultSheetController
- (void)addAction:(YTActionSheetAction *)action {
    static NSDictionary <NSString *, NSString *> *actionsToRemove;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        actionsToRemove = @{
            @"7": @"removeDownloadMenu",
            @"1": @"removeWatchLaterMenu",
            @"3": @"removeSaveToPlaylistMenu",
            @"5": @"removeShareMenu",
            @"12": @"removeNotInterestedMenu",
            @"31": @"removeDontRecommendMenu",
            @"58": @"removeReportMenu"
        };
    });

    id identifier = nil;
    @try {
        identifier = [action valueForKey:@"_accessibilityIdentifier"];
    } @catch (NSException *exception) {}

    NSString *key = [identifier isKindOfClass:[NSString class]] ? actionsToRemove[identifier] : nil;
    if (key && ytlBool(key)) return;

    %orig;
}
%end

// Hide buttons under the video player (@PoomSmart)
static BOOL findCell(ASNodeController *nodeController, NSArray <NSString *> *identifiers) {
    for (id child in [nodeController children]) {
        if ([child isKindOfClass:%c(ELMNodeController)]) {
            NSArray <ELMComponent *> *elmChildren = [(ELMNodeController *)child children];
            for (ELMComponent *elmChild in elmChildren) {
                NSString *description = [elmChild description];
                for (NSString *identifier in identifiers) {
                    if ([description containsString:identifier])
                        return YES;
                }
            }
        }

        if ([child isKindOfClass:%c(ASNodeController)]) {
            ASDisplayNode *childNode = ((ASNodeController *)child).node;
            for (ASDisplayNode *displayNode in childNode.yogaChildren) {
                if (displayNode.accessibilityIdentifier && [identifiers containsObject:displayNode.accessibilityIdentifier])
                    return YES;
            }

            if (findCell(child, identifiers))
                return YES;
        }
    }
    return NO;
}

%hook ASCollectionView
- (CGSize)sizeForElement:(ASCollectionElement *)element {
    if ([self.accessibilityIdentifier isEqualToString:@"id.video.scrollable_action_bar"]) {
        ASCellNode *node = [element node];
        ASNodeController *nodeController = [node controller];

        if (ytlBool(@"noPlayerRemixButton") && findCell(nodeController, @[@"id.video.remix.button"])) {
            return CGSizeZero;
        }

        if (ytlBool(@"noPlayerClipButton") && findCell(nodeController, @[@"clip_button.eml"])) {
            return CGSizeZero;
        }

        if (ytlBool(@"noPlayerDownloadButton") && findCell(nodeController, @[@"id.ui.add_to.offline.button"])) {
            return CGSizeZero;
        }
    }

    return %orig;
}
%end

// Remove Premium Pop-up, Horizontal Video Carousel and Shorts (https://github.com/MiRO92/YTNoShorts)
%hook YTAsyncCollectionView
- (id)cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = %orig;
    BOOL shouldRemove = NO;

    if ([cell isKindOfClass:objc_lookUpClass("_ASCollectionViewCell")]) {
        _ASCollectionViewCell *asCell = (_ASCollectionViewCell *)cell;
        if ([asCell respondsToSelector:@selector(node)]) {
            NSString *idToRemove = [[asCell node] accessibilityIdentifier];
            shouldRemove = [idToRemove isEqualToString:@"statement_banner.view"] ||
                (([idToRemove isEqualToString:@"eml.shorts-grid"] || [idToRemove isEqualToString:@"eml.shorts-shelf"]) && ytlBool(@"hideShorts"));
        }
    } else {
        shouldRemove = ([cell isKindOfClass:objc_lookUpClass("YTReelShelfCell")] && ytlBool(@"hideShorts")) ||
            ([cell isKindOfClass:objc_lookUpClass("YTHorizontalCardListCell")] && ytlBool(@"noContinueWatching"));
    }

    if (shouldRemove) [self removeCellsAtIndexPath:indexPath];

    return cell;
}

%new
- (void)removeCellsAtIndexPath:(NSIndexPath *)indexPath {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        if (indexPath.section >= [strongSelf numberOfSections]) return;
        if (indexPath.item >= [strongSelf numberOfItemsInSection:indexPath.section]) return;
        @try {
            [strongSelf deleteItemsAtIndexPaths:@[indexPath]];
        } @catch (NSException *exception) {}
    });
}
%end

// Shorts Progress Bar (https://github.com/PoomSmart/YTShortsProgress)
%hook YTReelPlayerViewController
- (BOOL)shouldEnablePlayerBar { return ytlBool(@"shortsProgress") ? YES : %orig; }
- (BOOL)shouldAlwaysEnablePlayerBar { return ytlBool(@"shortsProgress") ? YES : %orig; }
- (BOOL)shouldEnablePlayerBarOnlyOnPause { return ytlBool(@"shortsProgress") ? NO : %orig; }
%end

%hook YTReelPlayerViewControllerSub
- (BOOL)shouldEnablePlayerBar { return ytlBool(@"shortsProgress") ? YES : %orig; }
- (BOOL)shouldAlwaysEnablePlayerBar { return ytlBool(@"shortsProgress") ? YES : %orig; }
- (BOOL)shouldEnablePlayerBarOnlyOnPause { return ytlBool(@"shortsProgress") ? NO : %orig; }
%end

%hook YTShortsPlayerViewController
- (BOOL)shouldAlwaysEnablePlayerBar { return ytlBool(@"shortsProgress") ? YES : %orig; }
- (BOOL)shouldEnablePlayerBarOnlyOnPause { return ytlBool(@"shortsProgress") ? NO : %orig; }
%end

%hook YTColdConfig
- (BOOL)iosEnableVideoPlayerScrubber { return ytlBool(@"shortsProgress") ? YES : %orig; }
- (BOOL)mobileShortsTabInlined { return ytlBool(@"shortsProgress") ? YES : %orig; }
- (BOOL)iosUseSystemVolumeControlInFullscreen { return ytlBool(@"stockVolumeHUD") ? YES : %orig; }
%end

%hook YTHotConfig
- (BOOL)enablePlayerBarForVerticalVideoWhenControlsHiddenInFullscreen { return ytlBool(@"shortsProgress") ? YES : %orig; }
%end

// Dont Startup Shorts
%hook YTShortsStartupCoordinator
- (id)evaluateResumeToShorts { return ytlBool(@"resumeShorts") ? nil : %orig; }
%end

// Hide Shorts Elements
%hook YTReelPausedStateCarouselView
- (void)setPausedStateCarouselVisible:(BOOL)arg1 animated:(BOOL)arg2 { ytlBool(@"hideShortsSubscriptions") ? %orig(NO, arg2) : %orig; }
%end

%hook YTReelWatchPlaybackOverlayView
- (void)setReelLikeButton:(id)arg1 { if (!ytlBool(@"hideShortsLike")) %orig; }
- (void)setReelDislikeButton:(id)arg1 { if (!ytlBool(@"hideShortsDislike")) %orig; }
- (void)setViewCommentButton:(id)arg1 { if (!ytlBool(@"hideShortsComments")) %orig; }
- (void)setRemixButton:(id)arg1 { if (!ytlBool(@"hideShortsRemix")) %orig; }
- (void)setShareButton:(id)arg1 { if (!ytlBool(@"hideShortsShare")) %orig; }
- (void)setNativePivotButton:(id)arg1 { if (!ytlBool(@"hideShortsAvatars")) %orig; }
- (void)setPivotButtonElementRenderer:(id)arg1 { if (!ytlBool(@"hideShortsAvatars")) %orig; }
%end

%hook YTReelHeaderView
- (void)setTitleLabelVisible:(BOOL)arg1 animated:(BOOL)arg2 { ytlBool(@"hideShortsLogo") ? %orig(NO, arg2) : %orig; }
%end

%hook YTReelTransparentStackView
- (void)layoutSubviews {
    %orig;

    BOOL hideSearch = ytlBool(@"hideShortsSearch");
    BOOL hideCamera = ytlBool(@"hideShortsCamera");
    BOOL hideMore = ytlBool(@"hideShortsMore");
    if (!hideSearch && !hideCamera && !hideMore) return;

    for (UIView *subview in self.subviews) {
        if (![subview isKindOfClass:%c(YTQTMButton)] || ![subview respondsToSelector:@selector(buttonRenderer)]) continue;
        YTQTMButton *button = (YTQTMButton *)subview;
        int iconType = button.buttonRenderer.icon.iconType;
        if ((hideSearch && iconType == 1045) || (hideCamera && iconType == 1046) || (hideMore && iconType == 1047)) button.hidden = YES;
    }
}
%end

%hook YTReelWatchHeaderView
- (void)setChannelBarElementRenderer:(id)renderer { if (!ytlBool(@"hideShortsChannelName")) %orig; }
- (void)setHeaderRenderer:(id)renderer { if (!ytlBool(@"hideShortsDescription")) %orig; }
- (void)setShortsVideoTitleElementRenderer:(id)renderer { if (!ytlBool(@"hideShortsDescription")) %orig; }
- (void)setSoundMetadataElementRenderer:(id)renderer { if (!ytlBool(@"hideShortsAudioTrack")) %orig; }
- (void)setActionElement:(id)renderer { if (!ytlBool(@"hideShortsPromoCards")) %orig; }
- (void)setBadgeRenderer:(id)renderer { if (!ytlBool(@"hideShortsThanks")) %orig; }
- (void)setMultiFormatLinkElementRenderer:(id)renderer { if (!ytlBool(@"hideShortsSource")) %orig; }
%end

static BOOL isOverlayShown = YES;

%hook YTPlayerView
- (void)didPinch:(UIPinchGestureRecognizer *)gesture {
    %orig;

    if (ytlBool(@"pinchToFullscreenShorts") && [self.playerViewDelegate.parentViewController isKindOfClass:NSClassFromString(@"YTShortsPlayerViewController")]) {
        if (gesture.state != UIGestureRecognizerStateEnded) return;

        YTShortsPlayerViewController *shortsPlayerVC = (YTShortsPlayerViewController *)self.playerViewDelegate.parentViewController;
        if (![shortsPlayerVC.view isKindOfClass:%c(YTReelContentView)]) return;
        YTReelContentView *contentView = (YTReelContentView *)shortsPlayerVC.view;
        UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
        YTAppViewController *appVC = [mainWindow.rootViewController isKindOfClass:%c(YTAppViewController)] ? (YTAppViewController *)mainWindow.rootViewController : nil;

        if (gesture.scale > 1) {
            if (!ytlBool(@"shortsOnlyMode")) [appVC hidePivotBar];

            [UIView animateWithDuration:0.3 animations:^{
                contentView.playbackOverlay.alpha = 0;
                isOverlayShown = contentView.playbackOverlay.alpha;
            }];
        } else {
            if (!ytlBool(@"shortsOnlyMode")) [appVC showPivotBar];

            [UIView animateWithDuration:0.3 animations:^{
                contentView.playbackOverlay.alpha = 1;
                isOverlayShown = contentView.playbackOverlay.alpha;
            }];
        }
    }
}
%end

%hook YTReelContentView
- (void)setPlaybackView:(id)arg1 {
    %orig;

    self.playbackOverlay.alpha = isOverlayShown;

    if (ytlBool(@"shortsOnlyMode") && !objc_getAssociatedObject(self, &kYTLShortsModeGestureKey)) {
        UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(turnShortsOnlyModeOff:)];
        longPressGesture.numberOfTouchesRequired = 2;
        longPressGesture.minimumPressDuration = 0.5;

        [self addGestureRecognizer:longPressGesture];
        objc_setAssociatedObject(self, &kYTLShortsModeGestureKey, longPressGesture, OBJC_ASSOCIATION_ASSIGN);
    }
}

%new
- (void)turnShortsOnlyModeOff:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        ytlSetBool(NO, @"shortsOnlyMode");

        [[%c(YTToastResponderEvent) eventWithMessage:LOC(@"ShortsModeTurnedOff") firstResponder:[%c(YTUIUtils) topViewControllerForPresenting]] send];

        UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
        YTAppViewController *appVC = (YTAppViewController *)mainWindow.rootViewController;
        [appVC performSelector:@selector(showPivotBar) withObject:nil afterDelay:1.0];
    }
}
%end

static void showToast(NSString *message, UIResponder *responder) {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[%c(YTToastResponderEvent) eventWithMessage:message firstResponder:responder ?: [%c(YTUIUtils) topViewControllerForPresenting]] send];
    });
}

static NSString *errorMessage(NSError *error) {
    return [NSString stringWithFormat:LOC(@"%@: %@"), LOC(@"Error"), error.localizedDescription ?: @"?"];
}

static void saveImageDataToPhotos(NSData *data, UIResponder *responder) {
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetCreationRequest *request = [PHAssetCreationRequest creationRequestForAsset];
        [request addResourceWithType:PHAssetResourceTypePhoto data:data options:nil];
    } completionHandler:^(BOOL success, NSError *error) {
        showToast(success ? LOC(@"Saved") : errorMessage(error), responder);
    }];
}

static void saveImageToPhotos(UIImage *image, UIResponder *responder) {
    if (!image) return;
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetCreationRequest *request = [PHAssetCreationRequest creationRequestForAssetFromImage:image];
        request.creationDate = [NSDate date];
    } completionHandler:^(BOOL success, NSError *error) {
        showToast(success ? LOC(@"Saved") : errorMessage(error), responder);
    }];
}

static void downloadImageFromURL(UIResponder *responder, NSURL *URL, BOOL download) {
    NSString *URLString = URL.absoluteString;
    if (!URLString) return;

    if (ytlBool(@"fixAlbums") && [URLString hasPrefix:@"https://yt3."]) {
        URLString = [URLString stringByReplacingOccurrencesOfString:@"https://yt3." withString:@"https://yt4."];
    }

    NSRange croppedURL = [URLString rangeOfString:@"c-fcrop"];
    if (croppedURL.location != NSNotFound) {
        URLString = [[URLString substringToIndex:croppedURL.location] stringByAppendingString:@"nd-v1"];
    }

    NSURL *downloadURL = [NSURL URLWithString:URLString] ?: URL;

    [[[NSURLSession sharedSession] dataTaskWithURL:downloadURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        UIImage *image = data ? [UIImage imageWithData:data] : nil;
        if (!image) {
            showToast(errorMessage(error), responder);
            return;
        }

        if (download) {
            saveImageDataToPhotos(data, responder);
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIPasteboard generalPasteboard].image = image;
            });
            showToast(LOC(@"Copied"), responder);
        }
    }] resume];
}

static void genImageFromLayer(CALayer *layer, UIColor *backgroundColor, void (^completionHandler)(UIImage *)) {
    CGSize size = layer.bounds.size;
    if (!layer || size.width <= 0 || size.height <= 0) return;

    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:size];
    UIImage *image = [renderer imageWithActions:^(UIGraphicsImageRendererContext *rendererContext) {
        CGContextRef context = rendererContext.CGContext;
        CGContextSetFillColorWithColor(context, (backgroundColor ?: [UIColor systemBackgroundColor]).CGColor);
        CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
        [layer renderInContext:context];
    }];

    if (completionHandler) completionHandler(image);
}

%hook ELMContainerNode
%property (nonatomic, strong) NSString *copiedComment;
%property (nonatomic, strong) NSURL *copiedURL;
%end

%hook ASDisplayNode
- (void)setFrame:(CGRect)frame {
    %orig;

    if (ytlBool(@"commentManager") && [[self valueForKey:@"_accessibilityIdentifier"] isEqualToString:@"id.comment.content.label"]) {
        if ([self isKindOfClass:NSClassFromString(@"ASTextNode")]) {
            ASTextNode *textNode = (ASTextNode *)self;

            NSString *comment;
            if ([textNode respondsToSelector:@selector(attributedText)]) {
                if (textNode.attributedText) comment = textNode.attributedText.string;
            }

            NSMutableArray *allObjects = self.supernodes.allObjects;
            for (ELMContainerNode *containerNode in allObjects) {
                if (comment && [containerNode isKindOfClass:%c(ELMContainerNode)] && [containerNode.description containsString:@"id.ui.comment_cell"]) {
                    containerNode.copiedComment = comment;
                    break;
                }
            }
        }
    }

    if (ytlBool(@"postManager") && [self isKindOfClass:NSClassFromString(@"ELMExpandableTextNode")]) {
        ELMExpandableTextNode *expandableTextNode = (ELMExpandableTextNode *)self;

        if ([expandableTextNode.currentTextNode isKindOfClass:NSClassFromString(@"ASTextNode")]) {
            ASTextNode *textNode = (ASTextNode *)expandableTextNode.currentTextNode;

            NSString *text;
            if ([textNode respondsToSelector:@selector(attributedText)]) {
                if (textNode.attributedText) text = textNode.attributedText.string;
            }

            NSMutableArray *allObjects = self.supernodes.allObjects;
            for (ELMContainerNode *containerNode in allObjects) {
                if (text && [containerNode isKindOfClass:%c(ELMContainerNode)] && [containerNode.description containsString:@"id.ui.backstage.original_post"]) {
                    containerNode.copiedComment = text;
                    break;
                }
            }
        }
    }
}
%end

%hook YTImageZoomNode
- (BOOL)gestureRecognizer:(id)arg1 shouldRecognizeSimultaneouslyWithGestureRecognizer:(id)arg2 {
    BOOL isImageLoaded = NO;
    @try {
        isImageLoaded = [[self valueForKey:@"_didLoadImage"] boolValue];
    } @catch (NSException *exception) {}
    if (ytlBool(@"postManager") && isImageLoaded) {
        ASDisplayNode *displayNode = (ASDisplayNode *)self;
        ASNetworkImageNode *imageNode = (ASNetworkImageNode *)self;
        NSURL *URL = imageNode.URL;

        NSMutableArray *allObjects = displayNode.supernodes.allObjects;
        for (ELMContainerNode *containerNode in allObjects) {
            if (URL && [containerNode isKindOfClass:%c(ELMContainerNode)] && [containerNode.description containsString:@"id.ui.backstage.original_post"]) {
                containerNode.copiedURL = URL;
                break;
            }
        }
    }

    return %orig;
}
%end

%hook _ASDisplayView
- (void)setKeepalive_node:(id)arg1 {
    %orig;

    NSArray *gesturesInfo = @[
        @{@"selector": @"postManager:", @"text": @"id.ui.backstage.original_post", @"key": @(ytlBool(@"postManager"))},
        @{@"selector": @"savePFP:", @"text": @"ELMImageNode-View", @"key": @(ytlBool(@"saveProfilePhoto"))},
        @{@"selector": @"commentManager:", @"text": @"id.ui.comment_cell", @"key": @(ytlBool(@"commentManager"))}
    ];

    if (![gesturesInfo[0][@"key"] boolValue] && ![gesturesInfo[1][@"key"] boolValue] && ![gesturesInfo[2][@"key"] boolValue]) return;

    NSString *description = [self description];
    for (NSDictionary *gestureInfo in gesturesInfo) {
        SEL selector = NSSelectorFromString(gestureInfo[@"selector"]);

        if ([gestureInfo[@"key"] boolValue] && [description containsString:gestureInfo[@"text"]]) {
            for (UIGestureRecognizer *recognizer in self.gestureRecognizers) {
                if ([recognizer isKindOfClass:[UILongPressGestureRecognizer class]] && [objc_getAssociatedObject(recognizer, &kYTLGestureKey) isEqualToString:gestureInfo[@"selector"]]) return;
            }

            UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:selector];
            longPress.minimumPressDuration = 0.3;
            objc_setAssociatedObject(longPress, &kYTLGestureKey, gestureInfo[@"selector"], OBJC_ASSOCIATION_COPY_NONATOMIC);
            [self addGestureRecognizer:longPress];
            break;
        }
    }
}

%new
- (void)savePFP:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {

        if (![self.keepalive_node respondsToSelector:@selector(URL)]) return;
        ASNetworkImageNode *imageNode = (ASNetworkImageNode *)self.keepalive_node;
        NSString *URLString = imageNode.URL.absoluteString;
        if (URLString) {
            NSRange sizeRange = [URLString rangeOfString:@"=s"];
            if (sizeRange.location != NSNotFound) {
                NSRange dashRange = [URLString rangeOfString:@"-" options:0 range:NSMakeRange(sizeRange.location, URLString.length - sizeRange.location)];
                if (dashRange.location != NSNotFound) {
                    NSString *newURLString = [URLString stringByReplacingCharactersInRange:NSMakeRange(sizeRange.location + 2, dashRange.location - sizeRange.location - 2) withString:@"1024"];
                    NSURL *PFPURL = [NSURL URLWithString:newURLString] ?: imageNode.URL;
                    UIViewController *presentingVC = self.keepalive_node.closestViewController;

                    [[[NSURLSession sharedSession] dataTaskWithURL:PFPURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                        UIImage *image = data ? [UIImage imageWithData:data] : nil;
                        if (!image) {
                            showToast(errorMessage(error), presentingVC);
                            return;
                        }

                        dispatch_async(dispatch_get_main_queue(), ^{
                            YTDefaultSheetController *sheetController = [%c(YTDefaultSheetController) sheetControllerWithParentResponder:nil];

                            [sheetController addAction:[%c(YTActionSheetAction) actionWithTitle:LOC(@"SaveProfilePicture") iconImage:YTImageNamed(@"yt_outline_image_24pt") style:0 handler:^ {
                                saveImageDataToPhotos(data, presentingVC);
                            }]];

                            [sheetController addAction:[%c(YTActionSheetAction) actionWithTitle:LOC(@"CopyProfilePicture") iconImage:YTImageNamed(@"yt_outline_library_image_24pt") style:0 handler:^ {
                                [UIPasteboard generalPasteboard].image = image;
                                showToast(LOC(@"Copied"), presentingVC);
                            }]];

                            [sheetController presentFromViewController:presentingVC animated:YES completion:nil];
                        });
                    }] resume];
                }
            }
        }
    }
}

%new
- (void)postManager:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        NSArray *yogaChildren = self.keepalive_node.yogaChildren;
        if (yogaChildren.count == 0) return;
        ELMContainerNode *nodeForLayer = (ELMContainerNode *)yogaChildren.firstObject;
        if (![self.keepalive_node isKindOfClass:%c(ELMContainerNode)]) return;
        ELMContainerNode *containerNode = (ELMContainerNode *)self.keepalive_node;
        NSString *text = containerNode.copiedComment;
        NSURL *URL = containerNode.copiedURL;
        CALayer *layer = nodeForLayer.layer;
        UIColor *backgroundColor = containerNode.closestViewController.view.backgroundColor;

        YTDefaultSheetController *sheetController = [%c(YTDefaultSheetController) sheetControllerWithParentResponder:nil];
        
        [sheetController addAction:[%c(YTActionSheetAction) actionWithTitle:LOC(@"CopyPostText") iconImage:YTImageNamed(@"yt_outline_message_bubble_right_24pt") style:0 handler:^ {
            if (text) {
                [UIPasteboard generalPasteboard].string = text;
                [[%c(YTToastResponderEvent) eventWithMessage:LOC(@"Copied") firstResponder:containerNode.closestViewController] send];
            }
        }]];

        if (URL) {
            [sheetController addAction:[%c(YTActionSheetAction) actionWithTitle:LOC(@"SaveCurrentImage") iconImage:YTImageNamed(@"yt_outline_image_24pt") style:0 handler:^ {
                downloadImageFromURL(containerNode.closestViewController, URL, YES);
            }]];

            [sheetController addAction:[%c(YTActionSheetAction) actionWithTitle:LOC(@"CopyCurrentImage") iconImage:YTImageNamed(@"yt_outline_library_image_24pt") style:0 handler:^ {
                downloadImageFromURL(containerNode.closestViewController, URL, NO);
            }]];
        }

        [sheetController addAction:[%c(YTActionSheetAction) actionWithTitle:LOC(@"SavePostAsImage") titleColor:[UIColor colorWithRed:0.75 green:0.50 blue:0.90 alpha:1.0] iconImage:YTImageNamed(@"yt_outline_image_24pt") iconColor:[UIColor colorWithRed:0.75 green:0.50 blue:0.90 alpha:1.0] disableAutomaticButtonColor:YES accessibilityIdentifier:nil handler:^ {
            genImageFromLayer(layer, backgroundColor, ^(UIImage *image) {
                saveImageToPhotos(image, containerNode.closestViewController);
            });
        }]];

        [sheetController addAction:[%c(YTActionSheetAction) actionWithTitle:LOC(@"CopyPostAsImage") titleColor:[UIColor colorWithRed:0.75 green:0.50 blue:0.90 alpha:1.0] iconImage:YTImageNamed(@"yt_outline_library_image_24pt") iconColor:[UIColor colorWithRed:0.75 green:0.50 blue:0.90 alpha:1.0] disableAutomaticButtonColor:YES accessibilityIdentifier:nil handler:^ {
            genImageFromLayer(layer, backgroundColor, ^(UIImage *image) {
                [UIPasteboard generalPasteboard].image = image;
                [[%c(YTToastResponderEvent) eventWithMessage:LOC(@"Copied") firstResponder:containerNode.closestViewController] send];
            });
        }]];

        [sheetController presentFromViewController:containerNode.closestViewController animated:YES completion:nil];
    }
}

%new
- (void)commentManager:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        if (![self.keepalive_node isKindOfClass:%c(ELMContainerNode)]) return;
        ELMContainerNode *containerNode = (ELMContainerNode *)self.keepalive_node;
        NSString *comment = containerNode.copiedComment;

        CALayer *layer = self.layer;
        UIColor *backgroundColor = containerNode.closestViewController.view.backgroundColor;

        YTDefaultSheetController *sheetController = [%c(YTDefaultSheetController) sheetControllerWithParentResponder:nil];

        [sheetController addAction:[%c(YTActionSheetAction) actionWithTitle:LOC(@"CopyCommentText") iconImage:YTImageNamed(@"yt_outline_message_bubble_right_24pt") style:0 handler:^ {
            if (comment) {
                [UIPasteboard generalPasteboard].string = comment;
                [[%c(YTToastResponderEvent) eventWithMessage:LOC(@"Copied") firstResponder:containerNode.closestViewController] send];
            }
        }]];

        [sheetController addAction:[%c(YTActionSheetAction) actionWithTitle:LOC(@"SaveCommentAsImage") iconImage:YTImageNamed(@"yt_outline_image_24pt") style:0 handler:^ {
            genImageFromLayer(layer, backgroundColor, ^(UIImage *image) {
                saveImageToPhotos(image, containerNode.closestViewController);
            });
        }]];

        [sheetController addAction:[%c(YTActionSheetAction) actionWithTitle:LOC(@"CopyCommentAsImage") iconImage:YTImageNamed(@"yt_outline_library_image_24pt") style:0 handler:^ {
            genImageFromLayer(layer, backgroundColor, ^(UIImage *image) {
                [UIPasteboard generalPasteboard].image = image;
                [[%c(YTToastResponderEvent) eventWithMessage:LOC(@"Copied") firstResponder:containerNode.closestViewController] send];
            });
        }]];

        [sheetController presentFromViewController:containerNode.closestViewController animated:YES completion:nil];
    }
}
%end

// Remove Tabs
%hook YTPivotBarView
- (void)setRenderer:(YTIPivotBarRenderer *)renderer {
    NSMutableArray <YTIPivotBarSupportedRenderers *> *items = [renderer itemsArray];
    if (!items) return %orig;

    NSDictionary <NSString *, NSNumber *> *identifiersToRemove = @{
        @"FEshorts": @((ytlBool(@"removeShorts") || ytlBool(@"reExplore")) && !ytlBool(@"shortsOnlyMode")),
        @"FEsubscriptions": @(ytlBool(@"removeSubscriptions")),
        @"FEuploads": @(ytlBool(@"removeUploads")),
        @"FElibrary": @(ytlBool(@"removeLibrary"))
    };

    for (NSString *identifier in identifiersToRemove) {
        if (![identifiersToRemove[identifier] boolValue]) continue;

        NSIndexSet *indexes = [items indexesOfObjectsPassingTest:^BOOL(YTIPivotBarSupportedRenderers *item, NSUInteger idx, BOOL *stop) {
            return [[[item pivotBarItemRenderer] pivotIdentifier] isEqualToString:identifier] ||
                   [[[item pivotBarIconOnlyItemRenderer] pivotIdentifier] isEqualToString:identifier];
        }];

        if (indexes.count) [items removeObjectsAtIndexes:indexes];
    }

    NSString *exploreID = [%c(YTIBrowseRequest) browseIDForExploreTab];
    if (exploreID && (ytlBool(@"reExplore") || ytlBool(@"addExplore"))) {
        NSUInteger exploreIndex = [items indexOfObjectPassingTest:^BOOL(YTIPivotBarSupportedRenderers *item, NSUInteger idx, BOOL *stop) {
            return [[[item pivotBarItemRenderer] pivotIdentifier] isEqualToString:exploreID];
        }];

        if (exploreIndex == NSNotFound) {
            YTIPivotBarSupportedRenderers *exploreTab = [%c(YTIPivotBarRenderer) pivotSupportedRenderersWithBrowseId:exploreID title:LOC(@"Explore") iconType:292];
            if (exploreTab) [items insertObject:exploreTab atIndex:MIN((NSUInteger)1, items.count)];
        }
    }

    %orig;
}
%end

// Hide Tab Bar Indicators
%hook YTPivotBarIndicatorView
- (void)setFillColor:(id)arg1 { %orig(ytlBool(@"removeIndicators") ? [UIColor clearColor] : arg1); }
- (void)setBorderColor:(id)arg1 { %orig(ytlBool(@"removeIndicators") ? [UIColor clearColor] : arg1); }
%end

// Hide Tab Labels
%hook YTPivotBarItemView
- (void)setRenderer:(YTIPivotBarRenderer *)renderer {
    %orig;

    if (ytlBool(@"removeLabels")) {
        [self.navigationButton setTitle:@"" forState:UIControlStateNormal];
        [self.navigationButton setSizeWithPaddingAndInsets:NO];
    }

    if ([self.renderer.pivotIdentifier isEqualToString:@"FEwhat_to_watch"] && !objc_getAssociatedObject(self, &kYTLManageTabGestureKey)) {
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(manageTab:)];
        longPress.minimumPressDuration = 0.3;
        [self addGestureRecognizer:longPress];
        objc_setAssociatedObject(self, &kYTLManageTabGestureKey, longPress, OBJC_ASSOCIATION_ASSIGN);
    }
}

%new
- (void)manageTab:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        ytlSetBool(!ytlBool(@"removeLibrary"), @"removeLibrary");
        [[[%c(YTHeaderContentComboViewController) alloc] init] refreshPivotBar];
        [[%c(YTToastResponderEvent) eventWithMessage:ytlBool(@"removeLibrary") ? LOC(@"LibraryRemoved") : LOC(@"LibraryAdded") firstResponder:self.delegate] send];
    }
}
%end

// Startup Tab
static BOOL isTabSelected = NO;
%hook YTPivotBarViewController
- (void)viewDidAppear:(BOOL)animated {
    %orig;

    if (!isTabSelected && !ytlBool(@"shortsOnlyMode")) {
        NSArray *pivotIdentifiers = @[@"FEwhat_to_watch", @"FEexplore", @"FEshorts", @"FEsubscriptions", @"FElibrary"];
        NSInteger pivotIndex = ytlInt(@"pivotIndex");
        if (pivotIndex > 0 && pivotIndex < (NSInteger)pivotIdentifiers.count) [self selectItemWithPivotIdentifier:pivotIdentifiers[pivotIndex]];
        isTabSelected = YES;
    }

    if (ytlBool(@"shortsOnlyMode")) {
        [self selectItemWithPivotIdentifier:@"FEshorts"];
        [self.parentViewController hidePivotBar];
    }
}
%end

%hook YTAppViewController
- (void)showPivotBar {
    if (!ytlBool(@"shortsOnlyMode")) {
        %orig;

        isOverlayShown = YES;
    }
}
%end

%hook YTReelWatchRootViewController
- (void)viewDidAppear:(BOOL)animated {
    %orig;

    if (ytlBool(@"shortsOnlyMode")) {
        [self.navigationController.parentViewController hidePivotBar];
    }
}
%end

%hook YTEngagementPanelView
- (void)layoutSubviews {
    %orig;

    if (ytlBool(@"copyVideoInfo") && self.headerView && ![self.headerView viewWithTag:999] && [self.panelIdentifier.identifierString isEqualToString:@"video-description-ep-identifier"]) {
        YTQTMButton *copyInfoButton = [%c(YTQTMButton) iconButton];
        copyInfoButton.accessibilityLabel = LOC(@"CopyVideoInfo");
        [copyInfoButton setTag:999];
        [copyInfoButton enableNewTouchFeedback];
        [copyInfoButton setImage:YTImageNamed(@"yt_outline_copy_24pt") forState:UIControlStateNormal];
        [copyInfoButton setTintColor:[UIColor labelColor]];
        [copyInfoButton setTranslatesAutoresizingMaskIntoConstraints:false];
        [copyInfoButton addTarget:self action:@selector(didTapCopyInfoButton:) forControlEvents:UIControlEventTouchUpInside];

        [self.headerView addSubview:copyInfoButton];

        [NSLayoutConstraint activateConstraints:@[
            [copyInfoButton.trailingAnchor constraintEqualToAnchor:self.headerView.trailingAnchor constant:-48],
            [copyInfoButton.centerYAnchor constraintEqualToAnchor:self.headerView.centerYAnchor],
            [copyInfoButton.widthAnchor constraintEqualToConstant:40.0],
            [copyInfoButton.heightAnchor constraintEqualToConstant:40.0],
        ]];
    }
}

%new
- (void)didTapCopyInfoButton:(UIButton *)sender {
    YTPlayerViewController *playerVC = self.resizeDelegate.parentViewController.parentViewController.parentViewController.playerViewController;
    NSString *title = playerVC.playerResponse.playerData.videoDetails.title;
    NSString *shortDescription = playerVC.playerResponse.playerData.videoDetails.shortDescription;

    if (!title.length && !shortDescription.length) return;

    YTDefaultSheetController *sheetController = [%c(YTDefaultSheetController) sheetControllerWithParentResponder:nil];

    [sheetController addAction:[%c(YTActionSheetAction) actionWithTitle:LOC(@"CopyTitle") iconImage:YTImageNamed(@"yt_outline_text_box_24pt") style:0 handler:^ {
        [UIPasteboard generalPasteboard].string = title ?: @"";
        [[%c(YTToastResponderEvent) eventWithMessage:LOC(@"Copied") firstResponder:self.resizeDelegate] send];
    }]];

    [sheetController addAction:[%c(YTActionSheetAction) actionWithTitle:LOC(@"CopyDescription") iconImage:YTImageNamed(@"yt_outline_message_bubble_right_24pt") style:0 handler:^ {
        [UIPasteboard generalPasteboard].string = shortDescription ?: @"";
        [[%c(YTToastResponderEvent) eventWithMessage:LOC(@"Copied") firstResponder:self.resizeDelegate] send];
    }]];

    [sheetController presentFromViewController:self.resizeDelegate animated:YES completion:nil];
}
%end

static CGFloat rateBeforeSpeedmaster = 1.0;

static void manageSpeedmasterYTLite(UILongPressGestureRecognizer *gesture, YTMainAppVideoPlayerOverlayViewController *delegate, YTInlinePlayerScrubUserEducationView *edu) {
    NSArray *speedLabels = @[@0, @2.0, @0.25, @0.5, @0.75, @1.0, @1.25, @1.5, @1.75, @2.0, @3.0, @4.0, @5.0];
    NSInteger speedIndex = ytlInt(@"speedIndex");
    if (!delegate || speedIndex <= 0 || speedIndex >= (NSInteger)speedLabels.count) return;

    if (gesture.state == UIGestureRecognizerStateBegan) {
        @try {
            YTLabel *label = [edu valueForKey:@"_userEducationLabel"];
            edu.labelType = 1;
            [label setValue:[NSString stringWithFormat:@"%@: %@×", LOC(@"PlaybackSpeed"), speedLabels[speedIndex]] forKey:@"text"];
        } @catch (NSException *exception) {}

        rateBeforeSpeedmaster = delegate.currentPlaybackRate > 0 ? delegate.currentPlaybackRate : 1.0;
        [delegate setPlaybackRate:[speedLabels[speedIndex] floatValue]];
        [edu setVisible:YES];
    }

    else if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled || gesture.state == UIGestureRecognizerStateFailed) {
        [delegate setPlaybackRate:rateBeforeSpeedmaster];
        [edu setVisible:NO];
    }
}

%hook YTMainAppVideoPlayerOverlayView
- (void)setSeekAnywherePanGestureRecognizer:(id)arg1 {
    if (ytlInt(@"speedIndex") == 0) return %orig;

    if (objc_getAssociatedObject(self, &kYTLSpeedmasterGestureKey)) return;

    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(speedmasterYtLite:)];
    longPress.minimumPressDuration = 0.3;
    [self addGestureRecognizer:longPress];
    objc_setAssociatedObject(self, &kYTLSpeedmasterGestureKey, longPress, OBJC_ASSOCIATION_ASSIGN);
}

%new
- (void)speedmasterYtLite:(UILongPressGestureRecognizer *)gesture {
    YTInlinePlayerScrubUserEducationView *edu = self.scrubUserEducationView;
    manageSpeedmasterYTLite(gesture, self.delegate, edu);
}
%end

%hook YTSpeedmasterController
- (void)speedmasterDidLongPressWithRecognizer:(UILongPressGestureRecognizer *)gesture {
    if (ytlInt(@"speedIndex") == 0) return;
    if (ytlInt(@"speedIndex") == 1) return %orig;

    YTMainAppVideoPlayerOverlayViewController *delegate = [self valueForKey:@"_delegate"];
    YTInlinePlayerScrubUserEducationView *edu = (YTInlinePlayerScrubUserEducationView *)delegate.videoPlayerOverlayView.scrubUserEducationView;
    manageSpeedmasterYTLite(gesture, delegate, edu);
}
%end

// Disable Right-To-Left Formatting
%hook NSParagraphStyle
+ (NSWritingDirection)defaultWritingDirectionForLanguage:(id)lang { return ytlBool(@"disableRTL") ? NSWritingDirectionLeftToRight : %orig; }
+ (NSWritingDirection)_defaultWritingDirection { return ytlBool(@"disableRTL") ? NSWritingDirectionLeftToRight : %orig; }
%end

// Fix Albums For Russian Users
static NSURL *newCoverURL(NSURL *originalURL) {
    NSDictionary <NSString *, NSString *> *hostsToReplace = @{
        @"yt3.ggpht.com": @"yt4.ggpht.com",
        @"yt3.googleusercontent.com": @"yt4.googleusercontent.com",
    };

    if (!originalURL.host) return originalURL;
    NSString *const replacement = hostsToReplace[originalURL.host];
    if (ytlBool(@"fixAlbums") && replacement) {
        NSURLComponents *components = [NSURLComponents componentsWithURL:originalURL resolvingAgainstBaseURL:NO];
        components.host = replacement;
        return components.URL;
    }
    return originalURL;
}

%hook YTImageSelectionStrategyImageURLs
- (id)initWithSelectedImageURL:(NSURL *)selectedImageURL updatedImageURL:(NSURL *)updatedImageURL {
    return %orig(newCoverURL(selectedImageURL), newCoverURL(updatedImageURL));
}
%end

// %hook ELMImageDownloader
// - (id)downloadImageWithURL:(id)arg1 targetSize:(CGSize)arg2 callbackQueue:(id)arg3 downloadProgress:(id)arg4 completion:(id)arg5 {
//     return %orig(newCoverURL(arg1), arg2, arg3, arg4, arg5);
// }
// %end

%ctor {
    if (ytlBool(@"shortsOnlyMode") && (ytlBool(@"removeShorts") || ytlBool(@"reExplore"))) {
        ytlSetBool(NO, @"removeShorts");
        ytlSetBool(NO, @"reExplore");
    }

    if (!ytlBool(@"advancedMode") && !ytlBool(@"advancedModeReminder")) {
        ytlSetBool(YES, @"advancedModeReminder");

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            YTAlertView *alertView = [%c(YTAlertView) confirmationDialogWithAction:^{
                ytlSetBool(YES, @"advancedMode");
            }
            actionTitle:LOC(@"Yes")
            cancelTitle:LOC(@"No")];
            alertView.title = @"YTLite";
            alertView.subtitle = [NSString stringWithFormat:LOC(@"AdvancedModeReminder"), @"YTLite", LOC(@"Version"), LOC(@"Advanced")];
            [alertView show];
        });
    }
}
