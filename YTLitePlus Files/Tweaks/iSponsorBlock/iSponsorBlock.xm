#import "Headers/iSponsorBlock.h"
#import <AudioToolbox/AudioToolbox.h>
#import <rootless.h>
#import "Headers/ColorFunctions.h"
#import "Headers/SponsorBlockSettingsController.h"
#import "Headers/SponsorBlockRequest.h"
#import "Headers/SponsorBlockViewController.h"

#define LOC(x) [tweakBundle localizedStringForKey:x value:nil table:nil]

extern "C" NSBundle *iSponsorBlockBundle() {
    static NSBundle *bundle = nil;
    static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
        NSString *tweakBundlePath = [[NSBundle mainBundle] pathForResource:@"iSponsorBlock" ofType:@"bundle"];
        bundle = [NSBundle bundleWithPath:(tweakBundlePath ?: ROOT_PATH_NS(@"/Library/Application Support/iSponsorBlock.bundle"))];
    });
    return bundle;
}

NSBundle *tweakBundle = iSponsorBlockBundle();

BOOL kIsEnabled;
NSString *kUserID;
NSString *kAPIInstance;
NSDictionary *kCategorySettings;
CGFloat kMinimumDuration;
BOOL kShowSkipNotice;
BOOL kShowButtonsInPlayer;
BOOL kHideStartEndButtonInPlayer;
BOOL kShowModifiedTime;
BOOL kSkipAudioNotification;
BOOL kEnableSkipCountTracking;
CGFloat kSkipNoticeDuration;
NSMutableArray <NSString *> *kWhitelistedChannels;

// Sound effect for skip segments
static void playSponsorAudio() {
    NSString *audioFilePath = [tweakBundle pathForResource:@"SponsorAudio" ofType:@"m4a"];
    NSURL *audioFileURL = [NSURL fileURLWithPath:audioFilePath];
    SystemSoundID soundID;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)audioFileURL, &soundID);
    AudioServicesPlaySystemSound(soundID);
}

// Check and translate segment title for HUD
NSDictionary *categoryLocalization = @{
    @"sponsor": LOC(@"sponsor"),
    @"intro": LOC(@"intro"),
    @"outro": LOC(@"outro"),
    @"interaction": LOC(@"interaction"),
    @"selfpromo": LOC(@"selfpromo"),
    @"music_offtopic": LOC(@"music_offtopic"),
    @"preview": LOC(@"preview"),
};

%group Main
NSString *modifiedTimeString;

void maybeCreateMarkerViewsISBInner(id <YTPlayerBarProtocol> object) {
    if ([object isKindOfClass:%c(YTSegmentableInlinePlayerBarView)])
        [(YTSegmentableInlinePlayerBarView *)object maybeCreateMarkerViewsISB];
    else if ([object isKindOfClass:%c(YTModularPlayerBarController)]) {
        YTModularPlayerBarView *view = ((YTModularPlayerBarController *)object).view;
        if ([view isKindOfClass:%c(YTModularPlayerBarView)])
            [view maybeCreateMarkerViewsISB];
    }
}

void maybeCreateMarkerViewsISB(YTPlayerViewController *self) {
    YTPlayerView *playerView = (YTPlayerView *)self.view;
    YTMainAppVideoPlayerOverlayView *overlayView = (YTMainAppVideoPlayerOverlayView *)playerView.overlayView;
    if ([overlayView isKindOfClass:%c(YTMainAppVideoPlayerOverlayView)]) {
        id <YTPlayerBarProtocol> object = [overlayView.playerBar respondsToSelector:@selector(modularPlayerBar)] ? overlayView.playerBar.modularPlayerBar : overlayView.playerBar.segmentablePlayerBar;
        maybeCreateMarkerViewsISBInner(object);
    }
}

void currentVideoTimeDidChange(YTPlayerViewController *self, YTSingleVideoTime *arg2) {
    YTPlayerView *playerView = (YTPlayerView *)self.view;
    YTMainAppVideoPlayerOverlayView *overlayView = (YTMainAppVideoPlayerOverlayView *)playerView.overlayView;
    if (!self.channelID) self.channelID = @"";
    if (self.skipSegments.count > 0 && [overlayView isKindOfClass:%c(YTMainAppVideoPlayerOverlayView)] && ![kWhitelistedChannels containsObject:self.channelID]) {
        if (kShowModifiedTime) {
            UILabel *durationLabel = overlayView.playerBar.durationLabel;
            if (![durationLabel.text containsString:modifiedTimeString]) durationLabel.text = [NSString stringWithFormat:@"%@ (%@)", durationLabel.text, modifiedTimeString];
            [durationLabel sizeToFit];
        }
        
        SponsorSegment *sponsorSegment = [[SponsorSegment alloc] initWithStartTime:-1 endTime:-1 category:nil UUID:nil];
        if (self.currentSponsorSegment <= self.skipSegments.count-1) {
            sponsorSegment = self.skipSegments[self.currentSponsorSegment];
        } else if (self.unskippedSegment != self.currentSponsorSegment-1) {
            sponsorSegment = self.skipSegments[self.currentSponsorSegment-1];
        }
        
        if ((lroundf(arg2.time) == ceil(sponsorSegment.startTime) && arg2.time >= sponsorSegment.startTime) || (lroundf(arg2.time) >= ceil(sponsorSegment.startTime) && arg2.time < sponsorSegment.endTime)) {

            if ([[kCategorySettings objectForKey:sponsorSegment.category] intValue] == 3) {
                if (self.hud.superview != self.view && self.hudDisplayed == NO) {
                    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                    self.hudDisplayed = YES; // Set yes to make sure that HUD is not persistent (Issue #62)
                    self.hud.mode = MBProgressHUDModeCustomView;
                    NSString *localizedSegment = categoryLocalization[sponsorSegment.category] ?: sponsorSegment.category;
                    NSString *localizedManualSkip = LOC(@"ManuallySkipReminder");
                    NSString *formattedManualSkip = [NSString stringWithFormat:localizedManualSkip, localizedSegment, lroundf(sponsorSegment.startTime)/60, lroundf(sponsorSegment.startTime)%60, lroundf(sponsorSegment.endTime)/60, lroundf(sponsorSegment.endTime)%60];
                    self.hud.label.text = formattedManualSkip;
                    self.hud.label.numberOfLines = 0;
                    [self.hud.button setTitle:LOC(@"Skip") forState:UIControlStateNormal];
                    [self.hud.button addTarget:self action:@selector(manuallySkipSegment:) forControlEvents:UIControlEventTouchUpInside];
                    // Add custom button to hide HUD
                    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
                    UIImage *cancelImage = [[UIImage systemImageNamed:@"x.circle"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                    [cancelButton setImage:cancelImage forState:UIControlStateNormal];
                    [cancelButton setTintColor:[[UIColor blackColor] colorWithAlphaComponent:0.7]];
                    [cancelButton addTarget:self action:@selector(cancelHUD:) forControlEvents:UIControlEventTouchUpInside];

                    UIView *buttonSuperview = self.hud.button.superview;
                    [buttonSuperview addSubview:cancelButton];

                    CGFloat buttonSpacing = 10.0;
                    cancelButton.translatesAutoresizingMaskIntoConstraints = NO;
                    [NSLayoutConstraint activateConstraints:@[
                        [cancelButton.topAnchor constraintEqualToAnchor:self.hud.button.topAnchor],
                        [cancelButton.leadingAnchor constraintEqualToAnchor:self.hud.button.trailingAnchor constant:buttonSpacing],
                        [cancelButton.heightAnchor constraintEqualToAnchor:self.hud.button.heightAnchor]
                    ]];
                    self.hud.offset = CGPointMake(self.view.frame.size.width, -MBProgressMaxOffset);

                    // Use a delay equal to the length of the sponsored segment to avoid HUD call
                    double delayInSeconds = sponsorSegment.endTime - sponsorSegment.startTime;
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [MBProgressHUD hideHUDForView:self.view animated:YES]; // Hide HUD if user is not interacting with buttons
                        self.hudDisplayed = NO; // Reset flag to make it work for the next segment
                    });
                }
            }
            //edge case where segment end time is longer than the video
            else if (sponsorSegment.endTime > self.currentVideoTotalMediaTime) {
                [self isb_scrubToTime:self.currentVideoTotalMediaTime];
                if (kEnableSkipCountTracking) [SponsorBlockRequest viewedVideoSponsorTime:sponsorSegment];
            }
            else {
                [self isb_scrubToTime:sponsorSegment.endTime];
                if (kEnableSkipCountTracking) [SponsorBlockRequest viewedVideoSponsorTime:sponsorSegment];
            }
            if ([[kCategorySettings objectForKey:sponsorSegment.category] intValue] == 1) {
                if (self.hud.superview != self.view && kShowSkipNotice) {
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                    self.hud.mode = MBProgressHUDModeCustomView;
                    // Translate and add segment name to the skipped HUD (issue #70)
                    NSString *localizedSegment = categoryLocalization[sponsorSegment.category] ?: sponsorSegment.category;
                    self.hud.label.text = [NSString stringWithFormat:LOC(@"SkippedSegment"), localizedSegment];
                    self.hud.label.numberOfLines = 0;
                    [self.hud.button setTitle:LOC(@"Unskip") forState:UIControlStateNormal];
                    [self.hud.button addTarget:self action:@selector(unskipSegment:) forControlEvents:UIControlEventTouchUpInside];
                    self.hud.offset = CGPointMake(self.view.frame.size.width, -MBProgressMaxOffset);
                    [self.hud hideAnimated:YES afterDelay:kSkipNoticeDuration];

                    // Play sound effect if option enabled
                    if (kSkipAudioNotification) {
                        playSponsorAudio();
                    }
                }
            }
                                                                                                         
            if (self.currentSponsorSegment <= self.skipSegments.count-1 && [[kCategorySettings objectForKey:sponsorSegment.category] intValue] != 3) self.currentSponsorSegment ++;
        }
        else if (lroundf(arg2.time) > sponsorSegment.startTime && self.currentSponsorSegment != self.skipSegments.count && self.currentSponsorSegment != self.skipSegments.count-1) {
            self.currentSponsorSegment ++;
        }
        else if (self.currentSponsorSegment == 0 && self.unskippedSegment != -1) {
            self.currentSponsorSegment ++;
        }
        else if (self.currentSponsorSegment > 0 && lroundf(arg2.time) < self.skipSegments[self.currentSponsorSegment-1].startTime-0.01) {
            if ([self isMDXActive]) {

            }
            else if (self.unskippedSegment != self.currentSponsorSegment-1) {
                self.currentSponsorSegment--;
            }
            else if (arg2.time < self.skipSegments[self.currentSponsorSegment-1].startTime-0.01) {
                self.unskippedSegment = -1;
            }
        }
    }
    if ([overlayView isKindOfClass:%c(YTMainAppVideoPlayerOverlayView)]) {
        id <YTPlayerBarProtocol> playerBarView = [overlayView.playerBar respondsToSelector:@selector(modularPlayerBar)] ? overlayView.playerBar.modularPlayerBar : overlayView.playerBar.segmentablePlayerBar;
        
        maybeCreateMarkerViewsISBInner(playerBarView);

        NSArray *subviews;
        if ([playerBarView isKindOfClass:%c(YTSegmentableInlinePlayerBarView)]) {
            subviews = ((YTSegmentableInlinePlayerBarView *)playerBarView).subviews;
        } else if ([playerBarView isKindOfClass:%c(YTModularPlayerBarController)]) {
            playerBarView = (YTSegmentableInlinePlayerBarView *)((YTModularPlayerBarController *)playerBarView).view;
            subviews = ((YTSegmentableInlinePlayerBarView *)playerBarView).subviews;
        }
        
        for (UIView *markerView in subviews) {
            YTModularPlayerBarView *castedPlayerBarView = (YTModularPlayerBarView *)playerBarView;
            if (![castedPlayerBarView.sponsorMarkerViews containsObject:markerView] && castedPlayerBarView.skipSegments.count == 0) {
                maybeCreateMarkerViewsISBInner(playerBarView);
                return;
            }
        }
    }
}

%hook YTPlayerViewController
%property (strong, nonatomic) NSMutableArray *skipSegments;
%property (nonatomic, assign) NSInteger currentSponsorSegment;
%property (strong, nonatomic) MBProgressHUD *hud;
%property (nonatomic, assign) NSInteger unskippedSegment;
%property (strong, nonatomic) NSMutableArray *userSkipSegments;
%property (strong, nonatomic) NSString *channelID;
%property (nonatomic, assign) BOOL hudDisplayed;

// used to keep support for older versions, as seekToTime is new
%new(v@:d)
- (void)isb_scrubToTime:(CGFloat)time {
    // YT v17.30.1 switched scrubToTime to seekToTime
    [self respondsToSelector:@selector(scrubToTime:)] ? [self scrubToTime:time] : [self seekToTime:time];
}

- (void)singleVideo:(id)arg1 currentVideoTimeDidChange:(YTSingleVideoTime *)arg2 {
    %orig;
    currentVideoTimeDidChange(self, arg2);
}

- (void)potentiallyMutatedSingleVideo:(id)arg1 currentVideoTimeDidChange:(YTSingleVideoTime *)arg2 {
    %orig;
    currentVideoTimeDidChange(self, arg2);
}

- (void)playbackController:(id)arg1 didActivateVideo:(id)arg2 withPlaybackData:(id)arg3 {
    %orig;
    if (self.isPlayingAd) return;
    YTPlayerView *playerView = (YTPlayerView *)self.view;
    YTMainAppVideoPlayerOverlayView *overlayView = (YTMainAppVideoPlayerOverlayView *)playerView.overlayView;
    if ([overlayView isKindOfClass:%c(YTMainAppVideoPlayerOverlayView)]) {
        [MBProgressHUD hideHUDForView:playerView animated:YES]; //fix manual skip popup not disappearing when changing videos
        self.hudDisplayed = NO;  // Reset flag when changing videos

        self.skipSegments = [NSMutableArray array];
        self.userSkipSegments = [NSMutableArray array];
        [SponsorBlockRequest getSponsorTimes:self.currentVideoID completionTarget:self completionSelector:@selector(setSkipSegments:) apiInstance:kAPIInstance];
        self.currentSponsorSegment = 0;
        self.unskippedSegment = -1;
        overlayView.controlsOverlayView.playerViewController = self;
        overlayView.controlsOverlayView.isDisplayingSponsorBlockViewController = NO;
        
        YTSingleVideoController *activeVideo = self.activeVideo;
        if ([activeVideo isKindOfClass:%c(YTSingleVideoController)]) {
            if ([self.activeVideo.singleVideo respondsToSelector:@selector(video)]) self.channelID = self.activeVideo.singleVideo.video.videoDetails.channelId;
            else self.channelID = self.activeVideo.singleVideo.playbackData.video.videoDetails.channelId;
        }
    }
}
- (void)setSkipSegments:(NSMutableArray <SponsorSegment *> *)arg1 {
    %orig;
    NSInteger totalSavedTime = 0;
    for (SponsorSegment *segment in arg1) totalSavedTime += lroundf(segment.endTime) - lroundf(segment.startTime);
    if (arg1.count > 0) {
        NSInteger seconds = lroundf(self.currentVideoTotalMediaTime - totalSavedTime);
        NSInteger hours = seconds / 3600;
        NSInteger  minutes = (seconds - (hours * 3600)) / 60;
        seconds = seconds % 60;
        
        if (hours >= 1) modifiedTimeString = [NSString stringWithFormat:@"%ld:%02ld:%02ld",hours, minutes, seconds];
        else modifiedTimeString = [NSString stringWithFormat:@"%ld:%02ld", minutes, seconds];
    }

    else {
        modifiedTimeString = nil;
    }
}

%new(v@:)
- (void)isb_fixVisualGlitch {
    if (!self.isPlayingAd) {
        maybeCreateMarkerViewsISB(self);
    }
}

- (void)scrubToTime:(CGFloat)arg1 {
    %orig;
    [self isb_fixVisualGlitch];
}

- (void)seekToTime:(CGFloat)arg1 {
    %orig;
    [self isb_fixVisualGlitch];
}

%new(v@:@)
- (void)unskipSegment:(UIButton *)sender {
    if (self.currentSponsorSegment > 0) {
        [self isb_scrubToTime:self.skipSegments[self.currentSponsorSegment-1].startTime];
        self.unskippedSegment = self.currentSponsorSegment-1;
    } else {
        [self isb_scrubToTime:self.skipSegments[self.currentSponsorSegment].startTime];
        self.unskippedSegment = self.currentSponsorSegment;
    }
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

%new(v@:@)
- (void)manuallySkipSegment:(UIButton *)sender {
    SponsorSegment *sponsorSegment = [[SponsorSegment alloc] initWithStartTime:-1 endTime:-1 category:nil UUID:nil];
    if (self.currentSponsorSegment <= self.skipSegments.count-1) {
        sponsorSegment = self.skipSegments[self.currentSponsorSegment];
    } else if (self.unskippedSegment != self.currentSponsorSegment-1) {
        sponsorSegment = self.skipSegments[self.currentSponsorSegment-1];
    }
    
    if (sponsorSegment.endTime > self.currentVideoTotalMediaTime) {
        [self isb_scrubToTime:self.currentVideoTotalMediaTime];
        if (kEnableSkipCountTracking) [SponsorBlockRequest viewedVideoSponsorTime:sponsorSegment];
    }
    else {
        [self isb_scrubToTime:sponsorSegment.endTime];
        if (kEnableSkipCountTracking) [SponsorBlockRequest viewedVideoSponsorTime:sponsorSegment];
    }
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    // Prevent app crashing if segment was already skipped once
    if (self.currentSponsorSegment < 0) {
        self.currentSponsorSegment++;
    }

    // Reset flag immediately if segment was skipped
    if (self.hudDisplayed != NO) {
        self.hudDisplayed = NO;
    }

    // Play sound effect if option enabled
    if (kSkipAudioNotification) {
        playSponsorAudio();
    }
}

%new(v@:@)
- (void)cancelHUD:(UIButton *)sender {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)setPlayerViewLayout:(NSInteger)arg1 {
    %orig;
    maybeCreateMarkerViewsISB(self);
}

- (void)updateViewportSizeProvider {
    %orig;
    maybeCreateMarkerViewsISB(self);
}
%end

%hook YTMainAppVideoPlayerOverlayViewController

- (void)updateTopRightButtonAvailability {
    %orig;
    YTMainAppVideoPlayerOverlayView *v = [self videoPlayerOverlayView];
    YTMainAppControlsOverlayView *c = [v valueForKey:@"_controlsOverlayView"];
    c.sponsorBlockButton.hidden = !kShowButtonsInPlayer;
    c.sponsorStartedEndedButton.hidden = !kShowButtonsInPlayer || kHideStartEndButtonInPlayer;
    [c setNeedsLayout];
}

%end

%hook YTMainAppControlsOverlayView
%property (retain, nonatomic) YTQTMButton *sponsorBlockButton;
%property (retain, nonatomic) YTQTMButton *sponsorStartedEndedButton;
%property (retain, nonatomic) YTPlayerViewController *playerViewController;
%property (nonatomic, assign) BOOL isDisplayingSponsorBlockViewController;

- (id)initWithDelegate:(id)delegate {
    self = %orig;
    if (kShowButtonsInPlayer) {
        CGFloat padding = [[self class] topButtonAdditionalPadding];
        self.sponsorBlockButton = [self buttonWithImage:[UIImage imageWithContentsOfFile:[tweakBundle pathForResource:@"PlayerInfoIconSponsorBlocker256px-20@2x" ofType:@"png"]] accessibilityLabel:@"iSponsorBlock" verticalContentPadding:padding];
        [self.sponsorBlockButton addTarget:self action:@selector(sponsorBlockButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        self.sponsorBlockButton.hidden = YES;
        self.sponsorBlockButton.alpha = 0;

        if (!kHideStartEndButtonInPlayer) {
            BOOL isStart = self.playerViewController.userSkipSegments.lastObject.endTime != -1;
            NSString *startedEndedImagePath = isStart ? [tweakBundle pathForResource:@"sponsorblockstart-20@2x" ofType:@"png"] : [tweakBundle pathForResource:@"sponsorblockend-20@2x" ofType:@"png"];
            self.sponsorStartedEndedButton = [self buttonWithImage:[UIImage imageWithContentsOfFile:startedEndedImagePath] accessibilityLabel:isStart ? @"iSponsorBlock start" : @"iSponsorBlock end" verticalContentPadding:padding];
            [self.sponsorStartedEndedButton addTarget:self action:@selector(sponsorStartedEndedButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            self.sponsorStartedEndedButton.hidden = YES;
            self.sponsorStartedEndedButton.alpha = 0;
        }

        @try {
            UIView *containerView = [self valueForKey:@"_topControlsAccessibilityContainerView"];
            [containerView addSubview:self.sponsorBlockButton];
            if (!kHideStartEndButtonInPlayer) {
                [containerView addSubview:self.sponsorStartedEndedButton];
            }
        } @catch (id ex) {
            [self addSubview:self.sponsorBlockButton];
            if (!kHideStartEndButtonInPlayer) {
                [self addSubview:self.sponsorStartedEndedButton];
            }
        }
    }
    return self;
}

- (NSMutableArray *)topControls {
    NSMutableArray <UIView *> *topControls = %orig;
    if (kShowButtonsInPlayer) {
        [topControls insertObject:self.sponsorBlockButton atIndex:0];
        if (!kHideStartEndButtonInPlayer) {
            [topControls insertObject:self.sponsorStartedEndedButton atIndex:0];
        }
    }
    return topControls;
}

- (void)setTopOverlayVisible:(BOOL)visible isAutonavCanceledState:(BOOL)canceledState {
    if (self.isDisplayingSponsorBlockViewController) {
        %orig(NO, canceledState);
        self.sponsorBlockButton.imageView.hidden = YES;
        self.sponsorStartedEndedButton.imageView.hidden = YES;
        return;
    }

    self.sponsorBlockButton.alpha = canceledState || !visible ? 0:1;
    self.sponsorStartedEndedButton.alpha = canceledState || !visible ? 0:1;
    %orig;
}

%new(v@:@)
- (void)sponsorBlockButtonPressed:(YTQTMButton *)sender {
    self.isDisplayingSponsorBlockViewController = YES;
    self.sponsorBlockButton.hidden = YES;
    self.sponsorStartedEndedButton.hidden = YES;
    YTPlayerViewController *pvc = self.playerViewController;
    if ([pvc playerViewLayout] == 3) {
        if ([pvc respondsToSelector:@selector(didPressToggleFullscreen)])
            [pvc didPressToggleFullscreen];
        else {
            YTPlayerOverlayManager *overlayManager = pvc.overlayManager;
            [overlayManager didPressToggleFullscreen];
        }
    }
    [self presentSponsorBlockViewController];
}
%new(v@:@)
- (void)sponsorStartedEndedButtonPressed:(YTQTMButton *)sender {
    if (self.playerViewController.userSkipSegments.lastObject.endTime != -1) {
        [self.playerViewController.userSkipSegments addObject:[[SponsorSegment alloc] initWithStartTime:self.playerViewController.currentVideoMediaTime endTime:-1 category:nil UUID:nil]];
        [self.sponsorStartedEndedButton setImage:[UIImage imageWithContentsOfFile:[tweakBundle pathForResource:@"sponsorblockend-20@2x" ofType:@"png"]] forState:UIControlStateNormal];
    }
    else {
        self.playerViewController.userSkipSegments.lastObject.endTime = self.playerViewController.currentVideoMediaTime;
        if (self.playerViewController.userSkipSegments.lastObject.endTime != self.playerViewController.currentVideoMediaTime) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:[NSString stringWithFormat:@"End Time That You Set Was Less Than the Start Time, Please Select a Time After %ld:%02ld",lroundf(self.playerViewController.userSkipSegments.lastObject.startTime)/60, lroundf(self.playerViewController.userSkipSegments.lastObject.startTime)%60] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
            handler:^(UIAlertAction * action) {}];
            [alert addAction:defaultAction];
            [[[UIApplication sharedApplication] delegate].window.rootViewController presentViewController:alert animated:YES completion:nil];
            return;
        }
        [self.sponsorStartedEndedButton setImage:[UIImage imageWithContentsOfFile:[tweakBundle pathForResource:@"sponsorblockstart-20@2x" ofType:@"png"]] forState:UIControlStateNormal];
    }
}
%new(v@:)
- (void)presentSponsorBlockViewController {
    SponsorBlockViewController *addSponsorViewController = [[SponsorBlockViewController alloc] init];
    addSponsorViewController.playerViewController = self.playerViewController;
    addSponsorViewController.previousParentViewController = self.playerViewController.parentViewController;
    addSponsorViewController.overlayView = self;
    addSponsorViewController.preferredContentSize = CGSizeMake(CGRectGetWidth(self.playerViewController.view.frame), 0.9 * CGRectGetHeight(UIScreen.mainScreen.bounds));
    [[[UIApplication sharedApplication] delegate].window.rootViewController presentViewController:addSponsorViewController animated:YES completion:nil];
    self.isDisplayingSponsorBlockViewController = YES;
    [self setOverlayVisible:NO];

}
%end

%hook YTInlinePlayerBarView
%property (strong, nonatomic) NSMutableArray *sponsorMarkerViews;
%property (strong, nonatomic) NSMutableArray *skipSegments;
%property (strong, nonatomic) YTPlayerViewController *playerViewController;
%new(v@:)
- (void)maybeCreateMarkerViewsISB {
    [self removeSponsorMarkers];
    self.skipSegments = self.skipSegments;
}
- (void)setSkipSegments:(NSMutableArray <SponsorSegment *> *)arg1 {
    %orig;
    [self removeSponsorMarkers];
    if ([kWhitelistedChannels containsObject:self.playerViewController.channelID]) {
        return;
    }
    self.sponsorMarkerViews = [NSMutableArray array];
    for (SponsorSegment *segment in arg1) {
        CGFloat startTime = segment.startTime;
        CGFloat endTime = segment.endTime;
        CGFloat beginX = (startTime * self.frame.size.width) / self.totalTime;
        CGFloat endX = (endTime * self.frame.size.width) / self.totalTime;
        CGFloat markerWidth = MAX(endX - beginX, 0);
        
        UIColor *color;
        if ([segment.category isEqualToString:@"sponsor"]) color = colorWithHexString([kCategorySettings objectForKey:@"sponsorColor"]);
        else if ([segment.category isEqualToString:@"intro"]) color = colorWithHexString([kCategorySettings objectForKey:@"introColor"]);
        else if ([segment.category isEqualToString:@"outro"]) color = colorWithHexString([kCategorySettings objectForKey:@"outroColor"]);
        else if ([segment.category isEqualToString:@"interaction"]) color = colorWithHexString([kCategorySettings objectForKey:@"interactionColor"]);
        else if ([segment.category isEqualToString:@"selfpromo"]) color = colorWithHexString([kCategorySettings objectForKey:@"selfpromoColor"]);
        else if ([segment.category isEqualToString:@"music_offtopic"]) color = colorWithHexString([kCategorySettings objectForKey:@"music_offtopicColor"]);
        else if ([segment.category isEqualToString:@"preview"]) color = colorWithHexString([kCategorySettings objectForKey:@"previewColor"]);
        UIView *newMarkerView = [[UIView alloc] initWithFrame:CGRectZero];
        newMarkerView.backgroundColor = color;
        [self addSubview:newMarkerView];
        newMarkerView.translatesAutoresizingMaskIntoConstraints = NO;
        if (isnan(markerWidth) || !isfinite(beginX)) {
            return;
        }
        [newMarkerView.widthAnchor constraintEqualToConstant:markerWidth].active = YES;
        [newMarkerView.heightAnchor constraintEqualToConstant:2].active = YES;
        [newMarkerView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:beginX].active = YES;
        [newMarkerView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;

        [self.sponsorMarkerViews addObject:newMarkerView];
    }
}

%new(v@:)
- (void)removeSponsorMarkers {
    for (UIView *markerView in self.sponsorMarkerViews) {
        [markerView removeFromSuperview];
    }
    self.sponsorMarkerViews = [NSMutableArray array];
}
%end

static void setSkipSegments(YTModularPlayerBarView *self, NSMutableArray <SponsorSegment *> *arg1) {
    [self removeSponsorMarkers];
    UIViewController *delegate = [self valueForKey:@"_accessibilityDelegate"];
    YTPlayerViewController *playerViewController = (YTPlayerViewController *)delegate.parentViewController;
    if ([kWhitelistedChannels containsObject:playerViewController.channelID]) {
        return;
    }
    self.sponsorMarkerViews = [NSMutableArray array];
    UIView *scrubber = [self valueForKey:@"_scrubberCircle"];
    UIView *referenceView;
    @try {
        referenceView = [[self valueForKey:@"_segmentViews"] firstObject];
    } @catch (id ex) {
        for (UIView *subview in self.subviews) {
            if ([subview isKindOfClass:NSClassFromString(@"YTPlayerBarRectangleDecorationView")]) {
                referenceView = subview;
                break;
            }
        }
    }
    if (referenceView == nil) return;
    CGFloat totalTime = [self respondsToSelector:@selector(totalTime)] ? self.totalTime : 0;
    if (totalTime == 0) {
        @try {
            YTIModularPlayerBarModel *model = [self valueForKey:@"_model"];
            totalTime = model.playingState.totalTimeSec;
        } @catch (id ex) {}
    }
    if (totalTime == 0) return;
    CGFloat originY = referenceView.frame.origin.y;
    for (SponsorSegment *segment in arg1) {
        CGFloat startTime = segment.startTime;
        CGFloat endTime = segment.endTime;
        CGFloat beginX = (startTime * self.frame.size.width) / totalTime;
        CGFloat endX = (endTime * self.frame.size.width) / totalTime;
        CGFloat markerWidth = MAX(endX - beginX, 0);
        
        UIColor *color;
        if ([segment.category isEqualToString:@"sponsor"]) color = colorWithHexString([kCategorySettings objectForKey:@"sponsorColor"]);
        else if ([segment.category isEqualToString:@"intro"]) color = colorWithHexString([kCategorySettings objectForKey:@"introColor"]);
        else if ([segment.category isEqualToString:@"outro"]) color = colorWithHexString([kCategorySettings objectForKey:@"outroColor"]);
        else if ([segment.category isEqualToString:@"interaction"]) color = colorWithHexString([kCategorySettings objectForKey:@"interactionColor"]);
        else if ([segment.category isEqualToString:@"selfpromo"]) color = colorWithHexString([kCategorySettings objectForKey:@"selfpromoColor"]);
        else if ([segment.category isEqualToString:@"music_offtopic"]) color = colorWithHexString([kCategorySettings objectForKey:@"music_offtopicColor"]);
        else if ([segment.category isEqualToString:@"preview"]) color = colorWithHexString([kCategorySettings objectForKey:@"previewColor"]);

        if (isnan(markerWidth) || !isfinite(beginX)) {
            return;
        }

        UIView *newMarkerView = [[UIView alloc] initWithFrame:CGRectMake(beginX, originY, markerWidth, 2)];
        newMarkerView.userInteractionEnabled = NO;
        newMarkerView.backgroundColor = color;
        [self insertSubview:newMarkerView belowSubview:scrubber];
        [self.sponsorMarkerViews addObject:newMarkerView];
    }
}

static void updateSkipSegments(YTInlinePlayerBarContainerView *self) {
    UIView *playerBar = [self playerBar];
    if ([playerBar isKindOfClass:%c(YTModularPlayerBarController)])
        playerBar = ((YTModularPlayerBarController *)playerBar).view;
    NSUInteger index = [playerBar.subviews indexOfObjectPassingTest:^BOOL(UIView *view, NSUInteger idx, BOOL *stop) {
        return [view isKindOfClass:NSClassFromString(@"YTPlayerBarRectangleDecorationView")];
    }];
    if (index == NSNotFound) return;
    UIView *referenceView = playerBar.subviews[index];
    CGFloat originY = referenceView.frame.origin.y;
    for (UIView *sponsorMarkerView in ((YTModularPlayerBarView *)playerBar).sponsorMarkerViews) {
        CGRect frame = sponsorMarkerView.frame;
        frame.origin.y = originY;
        sponsorMarkerView.frame = frame;
    }
}

%hook YTSegmentableInlinePlayerBarView
%property (strong, nonatomic) NSMutableArray *sponsorMarkerViews;
%property (strong, nonatomic) NSMutableArray *skipSegments;
%new(v@:)
- (void)maybeCreateMarkerViewsISB {
    [self removeSponsorMarkers];
    self.skipSegments = self.skipSegments;
}
- (void)setSkipSegments:(NSMutableArray <SponsorSegment *> *)arg1 {
    %orig;
    setSkipSegments((YTModularPlayerBarView *)self, arg1);
}

%new(v@:)
- (void)removeSponsorMarkers {
    for (UIView *markerView in self.sponsorMarkerViews) {
        [markerView removeFromSuperview];
    }
    self.sponsorMarkerViews = [NSMutableArray array];
}
%end

%hook YTModularPlayerBarView
%property (strong, nonatomic) NSMutableArray *sponsorMarkerViews;
%property (strong, nonatomic) NSMutableArray *skipSegments;
%new(v@:)
- (void)maybeCreateMarkerViewsISB {
    [self removeSponsorMarkers];
    self.skipSegments = self.skipSegments;
}
- (void)setSkipSegments:(NSMutableArray <SponsorSegment *> *)arg1 {
    %orig;
    setSkipSegments(self, arg1);
}

%new(v@:)
- (void)removeSponsorMarkers {
    for (UIView *markerView in self.sponsorMarkerViews) {
        [markerView removeFromSuperview];
    }
    self.sponsorMarkerViews = [NSMutableArray array];
}
%end

%hook YTInlinePlayerBarContainerView
- (instancetype)initWithScrubbedTimeLabelsDisplayBelowStoryboard:(BOOL)arg1 enableSegmentedProgressView:(BOOL)arg2 {
    return %orig(arg1, YES);
}
//does the same thing as the method above on youtube v. 16.0x
- (instancetype)initWithEnableSegmentedProgressView:(BOOL)arg1 {
    return %orig(YES);
}
- (BOOL)alwaysEnableSegmentedProgressView {
    return YES;
}

- (void)setPeekableViewVisible:(BOOL)arg1 {
    %orig;
    if (kShowModifiedTime && modifiedTimeString && ![self.durationLabel.text containsString:modifiedTimeString]) {
        NSString *text = [NSString stringWithFormat:@"%@ (%@)", self.durationLabel.text, modifiedTimeString];
        self.durationLabel.text = text;
        [self.durationLabel sizeToFit];
    }
}

- (void)layoutSubviews {
    %orig;
    updateSkipSegments(self);
}

//thanks @iCraze >>
%new(@@:)
- (id)playerBar {
    return [self respondsToSelector:@selector(modularPlayerBar)] && self.modularPlayerBar ? [self modularPlayerBar] : [self segmentablePlayerBar];
}
%end

%hook YTNGWatchLayerViewController

- (void)didCompleteFullscreenDismissAnimation {
    %orig;
    YTPlayerView *playerView = (YTPlayerView *)self.playerViewController.view;
    YTMainAppVideoPlayerOverlayView *overlayView = (YTMainAppVideoPlayerOverlayView *)playerView.overlayView;
    if (!self.playerViewController.isPlayingAd && overlayView.controlsOverlayView.isDisplayingSponsorBlockViewController && [overlayView isKindOfClass:%c(YTMainAppVideoPlayerOverlayView)]) {
        [overlayView.controlsOverlayView presentSponsorBlockViewController];
    }
}
%end

//For newer versions of YT the class name changed
%hook YTWatchLayerViewController

- (void)didCompleteFullscreenDismissAnimation {
    %orig;
    YTPlayerView *playerView = (YTPlayerView *)self.playerViewController.view;
    YTMainAppVideoPlayerOverlayView *overlayView = (YTMainAppVideoPlayerOverlayView *)playerView.overlayView;
    if (!self.playerViewController.isPlayingAd && overlayView.controlsOverlayView.isDisplayingSponsorBlockViewController && [overlayView isKindOfClass:%c(YTMainAppVideoPlayerOverlayView)]) {
        [overlayView.controlsOverlayView presentSponsorBlockViewController];
    }
}
%end


%hook YTPlayerView
//https://stackoverflow.com/questions/11770743/capturing-touches-on-a-subview-outside-the-frame-of-its-superview-using-hittest
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (self.clipsToBounds || self.hidden || self.alpha == 0) {
        return nil;
    }
    
    for (UIView *subview in self.subviews.reverseObjectEnumerator) {
        CGPoint subPoint = [subview convertPoint:point fromView:self];
        UIView *result = [subview hitTest:subPoint withEvent:event];
        if (result) return result;
    }
    return nil;
}
%end
%end

%group Cercube
//ew global variables
NSArray <SponsorSegment *> *skipSegments;
AVQueuePlayer *queuePlayer;

%hook CADownloadObject
+ (id)modelWithMetadata:(id)arg1 format:(id)arg2 context:(id)arg3 type:(id)arg4 audioOnly:(_Bool)arg5 directory:(id)arg6 {
    CADownloadObject *downloadObject = %orig;
    [SponsorBlockRequest getSponsorTimes:downloadObject.videoId completionTarget:downloadObject completionSelector:@selector(setSkipSegments:) apiInstance:kAPIInstance];
    return downloadObject;
}

%new(v@:@)
- (void)setSkipSegments:(NSMutableArray <SponsorSegment *> *)skipSegments {
    NSString *path = [self.filePath.stringByDeletingLastPathComponent stringByAppendingPathComponent:[[self.fileName stringByDeletingPathExtension] stringByAppendingPathExtension:@"plist"]];
    [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
    NSMutableArray *segments = [NSMutableArray array];
    for (SponsorSegment *segment in skipSegments) {
        [segments addObject:@{
            @"startTime" : @(segment.startTime),
            @"endTime" : @(segment.endTime),
            @"category" : segment.category,
            @"UUID" : segment.UUID
        }];
    }
    NSDictionary *dict = @{
        @"skipSegments" : segments
    };
    [dict writeToURL:[NSURL fileURLWithPath:path isDirectory:NO] error:nil];
}
%end
%hook AVPlayerViewController
- (void)viewDidLoad {
    %orig;
    [(AVQueuePlayer *)self.player setPlayerViewController:self];
}
%end

%hook AVScrubber
//this is bad but i don't feel like finding a better way
- (void)layoutSubviews {
    %orig;
    [queuePlayer updateMarkerViews];
}
%end

%hook AVQueuePlayer
%property (strong, nonatomic) NSMutableArray *skipSegments;
%property (nonatomic, assign) NSInteger currentSponsorSegment;
%property (strong, nonatomic) MBProgressHUD *hud;
%property (nonatomic, assign) NSInteger unskippedSegment;
%property (nonatomic, assign) BOOL isSeeking;
%property (nonatomic, assign) NSInteger currentPlayerItem;
%property (strong, nonatomic) id timeObserver;
%property (strong, nonatomic) AVPlayerViewController *playerViewController;
%property (strong, nonatomic) NSMutableArray *markerViews;
%property (nonatomic, assign) BOOL hudDisplayed;
- (instancetype)initWithItems:(NSArray<AVPlayerItem *> *)items {
    self.currentPlayerItem = 0;
    queuePlayer = self;
    return %orig;
}
- (void)seekToTime:(CMTime)time {
    %orig;
    self.isSeeking = YES;
     [NSTimer scheduledTimerWithTimeInterval:1.0f repeats:NO block:^(NSTimer *timer) {
        self.isSeeking = NO;
    }];
}
- (void)_itemIsReadyToPlay:(id)arg1 {
    %orig;
    self.isSeeking = NO;
    [self sponsorBlockSetup];
}
- (void)_advanceCurrentItemAccordingToFigPlaybackItem:(id)arg1 {
    %orig;
    if (self.currentPlayerItem + 1 < [self items].count) self.currentPlayerItem ++;
}
- (void)_removeItem:(id)arg1 {
    %orig;
    [self removeTimeObserver:self.timeObserver];
    self.timeObserver = nil;
    if (self.currentPlayerItem != 0) self.currentPlayerItem --;
    [self sponsorBlockSetup];
}
%new(v@:)
- (void)updateMarkerViews {
    if (self.skipSegments.count > 0) {
        CGFloat totalTime = [@([self items][self.currentPlayerItem].duration.value) floatValue] / [self items][self.currentPlayerItem].duration.timescale;
        for (UIView *markerView in self.markerViews) {
            AVScrubber *scrubber = self.playerViewController.contentView.playbackControlsView.scrubber;
            CGFloat startTime = self.skipSegments[[self.markerViews indexOfObject:markerView]].startTime;
            CGFloat endTime = self.skipSegments[[self.markerViews indexOfObject:markerView]].endTime;
            CGFloat beginX = (startTime * scrubber.frame.size.width) / totalTime;
            CGFloat endX = (endTime * scrubber.frame.size.width) / totalTime;
            CGFloat markerWidth = endX - beginX;
            markerView.frame = CGRectMake(beginX, scrubber.frame.size.height/2-2, markerWidth, 5);
        }
    }
}
%new(v@:)
- (void)sponsorBlockSetup {
    if ([self items].count <= 0) return;
    NSString *path = [[[[self items][self.currentPlayerItem] _URL].path stringByDeletingPathExtension] stringByAppendingPathExtension:@"plist"];
    NSDictionary *segmentsDict = [NSDictionary dictionaryWithContentsOfFile:path];
    NSDictionary *segments = [segmentsDict objectForKey:@"skipSegments"];
    self.skipSegments = [NSMutableArray array];
    CGFloat totalTime = [@([self items][self.currentPlayerItem].duration.value) floatValue] / [self items][self.currentPlayerItem].duration.timescale;
    for (UIView *markerView in self.markerViews) {
        [markerView removeFromSuperview];
    }
    self.markerViews = [NSMutableArray array];
    for (NSDictionary *dict in segments) {
        SponsorSegment *segment = [[SponsorSegment alloc] initWithStartTime:[[dict objectForKey:@"startTime"] floatValue] endTime:[[dict objectForKey:@"endTime"] floatValue] category:[dict objectForKey:@"category"] UUID:[dict objectForKey:@"UUID"]];
        [self.skipSegments addObject:segment];
        AVScrubber *scrubber = self.playerViewController.contentView.playbackControlsView.scrubber;
        CGFloat startTime = segment.startTime;
        CGFloat endTime = segment.endTime;
        CGFloat beginX = (startTime * scrubber.frame.size.width) / totalTime;
        CGFloat endX = (endTime * scrubber.frame.size.width) / totalTime;
        CGFloat markerWidth = endX - beginX;
        UIView *markerView = [[UIView alloc] initWithFrame:CGRectMake(beginX, 2, markerWidth, 5)];

        if ([segment.category isEqualToString:@"sponsor"]) markerView.backgroundColor = colorWithHexString([kCategorySettings objectForKey:@"sponsorColor"]);
        else if ([segment.category isEqualToString:@"intro"]) markerView.backgroundColor = colorWithHexString([kCategorySettings objectForKey:@"introColor"]);
        else if ([segment.category isEqualToString:@"outro"]) markerView.backgroundColor = colorWithHexString([kCategorySettings objectForKey:@"outroColor"]);
        else if ([segment.category isEqualToString:@"interaction"]) markerView.backgroundColor = colorWithHexString([kCategorySettings objectForKey:@"interactionColor"]);
        else if ([segment.category isEqualToString:@"selfpromo"]) markerView.backgroundColor = colorWithHexString([kCategorySettings objectForKey:@"selfpromoColor"]);
        else if ([segment.category isEqualToString:@"music_offtopic"]) markerView.backgroundColor = colorWithHexString([kCategorySettings objectForKey:@"music_offtopicColor"]);
        else if ([segment.category isEqualToString:@"preview"]) markerView.backgroundColor = colorWithHexString([kCategorySettings objectForKey:@"previewColor"]);
        [scrubber addSubview:markerView];
        [self.markerViews addObject:markerView];
    }
    skipSegments = self.skipSegments;
    self.currentSponsorSegment = 0;
    self.unskippedSegment = -1;
    CMTime timeInterval = CMTimeMake(1,10);
    __weak AVQueuePlayer *weakSelf = self;
    [self removeTimeObserver:self.timeObserver];
    self.timeObserver = nil;

    self.timeObserver = [self addPeriodicTimeObserverForInterval:timeInterval queue:nil usingBlock:^(CMTime time) {
        CGFloat timeFloat = [@(time.value) floatValue] / time.timescale;
        if (weakSelf.skipSegments.count > 0) {
            SponsorSegment *sponsorSegment = [[SponsorSegment alloc] initWithStartTime:-1 endTime:-1 category:nil UUID:nil];
            if (weakSelf.currentSponsorSegment <= weakSelf.skipSegments.count-1) {
                sponsorSegment = weakSelf.skipSegments[weakSelf.currentSponsorSegment];
            }
            else if (weakSelf.unskippedSegment != weakSelf.currentSponsorSegment-1) {
                sponsorSegment = weakSelf.skipSegments[weakSelf.currentSponsorSegment-1];
            }
            
            if ((lroundf(timeFloat) == ceil(sponsorSegment.startTime) && timeFloat >= sponsorSegment.startTime) || (lroundf(timeFloat) >= ceil(sponsorSegment.startTime) && timeFloat < sponsorSegment.endTime)) {
                if ([[kCategorySettings objectForKey:sponsorSegment.category] intValue] == 3) {
                    if (weakSelf.hud.superview != weakSelf.playerViewController.view && weakSelf.hudDisplayed == NO) {
                        weakSelf.hud = [MBProgressHUD showHUDAddedTo:weakSelf.playerViewController.view animated:YES];
                        weakSelf.hudDisplayed = YES; // Set yes to make sure that HUD is not persistent (Issue #62)
                        weakSelf.hud.mode = MBProgressHUDModeCustomView;
                        NSString *localizedSegment = categoryLocalization[sponsorSegment.category] ?: sponsorSegment.category;
                        NSString *localizedManualSkip = LOC(@"ManuallySkipReminder");
                        NSString *formattedManualSkip = [NSString stringWithFormat:localizedManualSkip, localizedSegment, lroundf(sponsorSegment.startTime)/60, lroundf(sponsorSegment.startTime)%60, lroundf(sponsorSegment.endTime)/60, lroundf(sponsorSegment.endTime)%60];
                        weakSelf.hud.label.text = formattedManualSkip;
                        weakSelf.hud.label.numberOfLines = 0;
                        [weakSelf.hud.button setTitle:LOC(@"Skip") forState:UIControlStateNormal];
                        [weakSelf.hud.button addTarget:weakSelf action:@selector(manuallySkipSegment:) forControlEvents:UIControlEventTouchUpInside];
                        // Add custom button to hide HUD
                        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
                        UIImage *cancelImage = [[UIImage systemImageNamed:@"x.circle"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                        [cancelButton setImage:cancelImage forState:UIControlStateNormal];
                        [cancelButton setTintColor:[[UIColor blackColor] colorWithAlphaComponent:0.7]];
                        [cancelButton addTarget:weakSelf action:@selector(cancelHUD:) forControlEvents:UIControlEventTouchUpInside];

                        UIView *buttonSuperview = weakSelf.hud.button.superview;
                        [buttonSuperview addSubview:cancelButton];

                        CGFloat buttonSpacing = 10.0;
                        cancelButton.translatesAutoresizingMaskIntoConstraints = NO;
                        [NSLayoutConstraint activateConstraints:@[
                            [cancelButton.topAnchor constraintEqualToAnchor:weakSelf.hud.button.topAnchor],
                            [cancelButton.leadingAnchor constraintEqualToAnchor:weakSelf.hud.button.trailingAnchor constant:buttonSpacing],
                            [cancelButton.heightAnchor constraintEqualToAnchor:weakSelf.hud.button.heightAnchor]
                        ]];
                        weakSelf.hud.offset = CGPointMake(weakSelf.playerViewController.view.frame.size.width, -MBProgressMaxOffset);
                        double delayInSeconds = sponsorSegment.endTime - sponsorSegment.startTime;

                        // Use a delay equal to the length of the sponsored segment to avoid HUD call
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [MBProgressHUD hideHUDForView:weakSelf.playerViewController.view animated:YES]; // Hide HUD if user is not interacting with buttons
                            weakSelf.hudDisplayed = NO; // Reset flag to make it work for the next segment
                        });
                    }
                }
                
                else if (sponsorSegment.endTime > totalTime) {
                    [weakSelf seekToTime:CMTimeMake(totalTime,1) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
                }
                else {
                    [weakSelf seekToTime:CMTimeMake(sponsorSegment.endTime,1)];
                }

                if ([[kCategorySettings objectForKey:sponsorSegment.category] intValue] == 1) {
                    if (weakSelf.hud.superview != weakSelf.playerViewController.view && kShowSkipNotice) {
                        [MBProgressHUD hideHUDForView:weakSelf.playerViewController.view animated:YES];
                        weakSelf.hud = [MBProgressHUD showHUDAddedTo:weakSelf.playerViewController.view animated:YES];
                        weakSelf.hud.mode = MBProgressHUDModeCustomView;
                        // Translate and add segment name to the skipped HUD (issue #70)
                        NSString *localizedSegment = categoryLocalization[sponsorSegment.category] ?: sponsorSegment.category;
                        weakSelf.hud.label.text = [NSString stringWithFormat:LOC(@"SkippedSegment"), localizedSegment];
                        weakSelf.hud.label.numberOfLines = 0;
                        [weakSelf.hud.button setTitle:LOC(@"Unskip") forState:UIControlStateNormal];
                        [weakSelf.hud.button addTarget:weakSelf action:@selector(unskipSegment:) forControlEvents:UIControlEventTouchUpInside];
                        weakSelf.hud.offset = CGPointMake(weakSelf.playerViewController.view.frame.size.width, -MBProgressMaxOffset);
                        [weakSelf.hud hideAnimated:YES afterDelay:kSkipNoticeDuration];

                        // Play sound effect if option enabled
                        if (kSkipAudioNotification) {
                            playSponsorAudio();
                        }
                    }
                }
                
                if (weakSelf.currentSponsorSegment <= weakSelf.skipSegments.count-1) weakSelf.currentSponsorSegment ++;
            }
            else if (lroundf(timeFloat) > sponsorSegment.startTime && weakSelf.currentSponsorSegment < weakSelf.skipSegments.count-1) {
                weakSelf.currentSponsorSegment ++;
            }
            else if (weakSelf.currentSponsorSegment == 0 && weakSelf.unskippedSegment != -1) {
                weakSelf.currentSponsorSegment ++;
            }
            else if (weakSelf.currentSponsorSegment > 0 && lroundf(timeFloat) < weakSelf.skipSegments[weakSelf.currentSponsorSegment-1].startTime-0.01) {
                if (weakSelf.unskippedSegment != weakSelf.currentSponsorSegment-1) {
                    weakSelf.currentSponsorSegment--;
                }
                else if (timeFloat < weakSelf.skipSegments[weakSelf.currentSponsorSegment-1].startTime-0.01) {
                    weakSelf.unskippedSegment = -1;
                }
            }
        }
    }];
}
%new(v@:@)
- (void)unskipSegment:(UIButton *)sender {
    if (self.currentSponsorSegment > 0) {
        [self seekToTime:CMTimeMake(self.skipSegments[self.currentSponsorSegment-1].startTime,1)];
        self.unskippedSegment = self.currentSponsorSegment-1;
    } else {
        [self seekToTime:CMTimeMake(self.skipSegments[self.currentSponsorSegment].startTime,1)];
        self.unskippedSegment = self.currentSponsorSegment;
    }
    [MBProgressHUD hideHUDForView:self.playerViewController.view animated:YES];
}
%end
%end

%group JustSettings
%hook YTRightNavigationButtons
%property (retain, nonatomic) YTQTMButton *sponsorBlockButton;
- (NSMutableArray *)buttons {
    NSMutableArray *retVal = %orig.mutableCopy;
    [self.sponsorBlockButton removeFromSuperview];
    [self addSubview:self.sponsorBlockButton];
    NSInteger pageStyle;
    Class YTPageStyleControllerClass = %c(YTPageStyleController);
    if (YTPageStyleControllerClass)
        pageStyle = [YTPageStyleControllerClass pageStyle];
    else {
        YTAppDelegate *delegate = (YTAppDelegate *)[UIApplication sharedApplication].delegate;
        YTAppViewControllerImpl *appViewController = [delegate valueForKey:@"_appViewController"];
        pageStyle = [appViewController pageStyle];
    }
    UIImage *image;
    if (!self.sponsorBlockButton) {
        self.sponsorBlockButton = [%c(YTQTMButton) iconButton];

        [self.sponsorBlockButton enableNewTouchFeedback];
        self.sponsorBlockButton.frame = CGRectMake(0, 0, 40, 40);

        image = [UIImage imageWithContentsOfFile:[tweakBundle pathForResource:@"sponsorblocksettings-20@2x" ofType:@"png"]];
        [self.sponsorBlockButton addTarget:self action:@selector(sponsorBlockButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [retVal insertObject:self.sponsorBlockButton atIndex:0];
    } else {
        image = [%c(QTMIcon) tintImage:self.sponsorBlockButton.currentImage color:pageStyle ? UIColor.whiteColor : UIColor.blackColor];
    }
    [self.sponsorBlockButton setImage:image forState:UIControlStateNormal];
    return retVal;
}
- (NSMutableArray *)visibleButtons {
    NSMutableArray *retVal = %orig.mutableCopy;
    
    //fixes button overlapping yt logo on smaller devices
    [self setLeadingPadding:-10];
    if (self.sponsorBlockButton) {
        [self.sponsorBlockButton removeFromSuperview];
        [self addSubview:self.sponsorBlockButton];
        [retVal insertObject:self.sponsorBlockButton atIndex:0];
    }
    return retVal;
}
%new(v@:@)
- (void)sponsorBlockButtonPressed:(UIButton *)sender {
    SponsorBlockSettingsController *settingsController = [[SponsorBlockSettingsController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:settingsController];
    [[[UIApplication sharedApplication] delegate].window.rootViewController presentViewController:navigationController animated:YES completion:nil];
}
%end
%end

static void loadPrefs() {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"iSponsorBlock.plist"];
    NSMutableDictionary *settings = [NSMutableDictionary dictionary];
    [settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:path]];
    kIsEnabled = [settings objectForKey:@"enabled"] ? [[settings objectForKey:@"enabled"] boolValue] : YES;

    kUserID = [settings objectForKey:@"userID"] ? [settings objectForKey:@"userID"] : [[NSUUID UUID] UUIDString];
    // reset to uuid if user set to an empty string
    if ([kUserID isEqualToString:@""]) kUserID = [[NSUUID UUID] UUIDString];

    kAPIInstance =  [settings objectForKey:@"apiInstance"] ? [settings objectForKey:@"apiInstance"] : @"https://sponsor.ajay.app/api";
    // reset to official if user set to an empty string
    if ([kAPIInstance isEqualToString:@""]) kAPIInstance = @"https://sponsor.ajay.app/api";

    kCategorySettings = [settings objectForKey:@"categorySettings"] ? [settings objectForKey:@"categorySettings"] : @{
        @"sponsor" : @1,
        @"sponsorColor" : hexFromUIColor(UIColor.greenColor),
        @"intro" : @0,
        @"introColor" : hexFromUIColor(UIColor.systemTealColor),
        @"outro" : @0,
        @"outroColor" : hexFromUIColor(UIColor.blueColor),
        @"interaction" : @0,
        @"interactionColor" : hexFromUIColor(UIColor.systemPinkColor),
        @"selfpromo" : @0,
        @"selfpromoColor" : hexFromUIColor(UIColor.yellowColor),
        @"music_offtopic" : @0,
        @"music_offtopicColor" : hexFromUIColor(UIColor.orangeColor),
        @"preview": @0,
        @"previewColor" : hexFromUIColor(UIColor.systemPurpleColor)
    };
    kMinimumDuration = [settings objectForKey:@"minimumDuration"] ? [[settings objectForKey:@"minimumDuration"] floatValue] : 0.0f;
    kShowSkipNotice = [settings objectForKey:@"showSkipNotice"] ? [[settings objectForKey:@"showSkipNotice"] boolValue] : YES;
    kShowButtonsInPlayer = [settings objectForKey:@"showButtonsInPlayer"] ? [[settings objectForKey:@"showButtonsInPlayer"] boolValue] : YES;
    kHideStartEndButtonInPlayer = [settings objectForKey:@"hideStartEndButtonInPlayer"] ? [[settings objectForKey:@"hideStartEndButtonInPlayer"] boolValue] : NO;
    kShowModifiedTime = [settings objectForKey:@"showModifiedTime"] ? [[settings objectForKey:@"showModifiedTime"] boolValue] : YES;
    kSkipAudioNotification = [settings objectForKey:@"skipAudioNotification"] ? [[settings objectForKey:@"skipAudioNotification"] boolValue] : NO;
    kEnableSkipCountTracking = [settings objectForKey:@"enableSkipCountTracking"] ? [[settings objectForKey:@"enableSkipCountTracking"] boolValue] : YES;
    kSkipNoticeDuration = [settings objectForKey:@"skipNoticeDuration"] ? [[settings objectForKey:@"skipNoticeDuration"] floatValue] : 3.0f;
    kWhitelistedChannels = [settings objectForKey:@"whitelistedChannels"] ? [(NSArray *)[settings objectForKey:@"whitelistedChannels"] mutableCopy] : [NSMutableArray array];
    
    NSDictionary *newSettings = @{
      @"enabled" : @(kIsEnabled),
      @"userID" : kUserID,
      @"apiInstance" : kAPIInstance,
      @"categorySettings" : kCategorySettings,
      @"minimumDuration" : @(kMinimumDuration),
      @"showSkipNotice" : @(kShowSkipNotice),
      @"showButtonsInPlayer" : @(kShowButtonsInPlayer),
      @"hideStartEndButtonInPlayer" : @(kHideStartEndButtonInPlayer),
      @"showModifiedTime" : @(kShowModifiedTime),
      @"skipAudioNotification" : @(kSkipAudioNotification),
      @"enableSkipCountTracking" : @(kEnableSkipCountTracking),
      @"skipNoticeDuration" : @(kSkipNoticeDuration),
      @"whitelistedChannels" : kWhitelistedChannels
    };
    if (![newSettings isEqualToDictionary:settings]) {
        [newSettings writeToURL:[NSURL fileURLWithPath:path isDirectory:NO] error:nil];
    }

}

%group LateLoad

%hook YTAppDelegate

- (BOOL)application:(id)arg1 didFinishLaunchingWithOptions:(id)arg2 {
    BOOL orig = %orig;
    loadPrefs();
    if (kIsEnabled) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        if (dlopen(ROOT_PATH("/Library/MobileSubstrate/DynamicLibraries/Cercube.dylib"), RTLD_LAZY)) {
            %init(Cercube)
            NSString *downloadsDirectory = [documentsDirectory stringByAppendingPathComponent:@"Carida_Files"];
            NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:downloadsDirectory error:nil];
            for (NSString *path in files) {
                if ([path.pathExtension isEqualToString:@"plist"]) {
                    NSString *mp4Path = [downloadsDirectory stringByAppendingPathComponent:[[path stringByDeletingPathExtension] stringByAppendingPathExtension:@"mp4"]];
                    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:mp4Path];
                    if (!fileExists) {
                        [[NSFileManager defaultManager] removeItemAtPath:[downloadsDirectory stringByAppendingPathComponent:path] error:nil];
                    }
                }
            }
        }
        %init(Main);
    }
    return orig;
}

%end

%end

static void prefsChanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    loadPrefs();
}

%ctor {
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)prefsChanged, CFSTR("com.galacticdev.isponsorblockprefs.changed"), NULL, CFNotificationSuspensionBehaviorCoalesce);
    %init(LateLoad);
    %init(JustSettings);
}

%dtor {
    if (dlopen(ROOT_PATH("/Library/MobileSubstrate/DynamicLibraries/Cercube.dylib"), RTLD_LAZY)) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *downloadsDirectory = [documentsDirectory stringByAppendingPathComponent:@"Carida_Files"];
        NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:downloadsDirectory error:nil];
        for (NSString *path in files) {
            if ([path.pathExtension isEqualToString:@"plist"]) {
                NSString *mp4Path = [downloadsDirectory stringByAppendingPathComponent:[[path stringByDeletingPathExtension] stringByAppendingPathExtension:@"mp4"]];
                BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:mp4Path];
                if (!fileExists) {
                    [[NSFileManager defaultManager] removeItemAtPath:[downloadsDirectory stringByAppendingPathComponent:path] error:nil];
                }
            }
        }
    }
}
