//
//  YTHFSTweak.x
//
//  Created by Joshua Seltzer on 12/5/22.
//
//

#import "YTHFSHeaders.h"
#import "YTHFSPrefsManager.h"

@interface YTPlayerViewController (YTHFS)

// the long press gesture that will be created and added to the player view
@property (nonatomic, retain) UILongPressGestureRecognizer *YTHFSLongPressGesture;

// boolean that determines if the auto-apply feature needs to be invoked for the current video
@property (nonatomic, assign) BOOL YTHFSNeedsAutoApply;

// switch between the user-selected playback rate and the normal playback rate, invoked either via the hold gesture or
// automatically when the video starts (dependent on settings)
- (void)YTHFSSwitchPlaybackRate;

@end

@interface YTMainAppVideoPlayerOverlayView (YTHFS)

// the original gesture objects that might need to be re-set if any of the tweak preferences are changed during runtime
@property (nonatomic, retain) UILongPressGestureRecognizer *YTHFSOriginalSeekAnywhereLongPressGesture;
@property (nonatomic, retain) UIPanGestureRecognizer *YTHFSOriginalSeekAnywherePanGesture;
@property (nonatomic, retain) UILongPressGestureRecognizer *YTHFSOriginalLongPressGesture;

// clears the original gestures on the overlay view
- (void)YTHFSClearOriginalGestures;

// re-sets the original gestures on the overlay view if they exist
- (void)YTHFSSetOriginalGestures;

@end

// define some non-configurable defaults for the long press gesture
#define kYTHFSNormalPlaybackRate        1.0
#define kYTHFSNumTouchesRequired        1
#define kYTHFSAllowableMovement         50

// enum to define the direction of the playback rate feedback indicator
typedef enum YTHFSFeedbackDirection : NSInteger {
    kYTHFSFeedbackDirectionForward,
    kYTHFSFeedbackDirectionBackward
} YTHFSFeedbackDirection;

%hook YTWatchLayerViewController

// invoked when the player view controller is either created or destroyed
- (void)watchController:(YTWatchController *)watchController didSetPlayerViewController:(YTPlayerViewController *)playerViewController
{
    if (playerViewController) {
        // check to see if the toggle rate should automatically be applied when the video starts
        playerViewController.YTHFSNeedsAutoApply = [YTHFSPrefsManager autoApplyRateEnabled];

        // add a long press gesture to configure the playback rate
        if ([YTHFSPrefsManager holdGestureEnabled]) {
            // check to see if the long press gesture is already created
            if (!playerViewController.YTHFSLongPressGesture) {
                playerViewController.YTHFSLongPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:playerViewController
                                                                                                           action:@selector(YTHFSHandleLongPressGesture:)];
                playerViewController.YTHFSLongPressGesture.numberOfTouchesRequired = kYTHFSNumTouchesRequired;
                playerViewController.YTHFSLongPressGesture.allowableMovement = kYTHFSAllowableMovement;
                [playerViewController.playerView addGestureRecognizer:playerViewController.YTHFSLongPressGesture];

                // ensure that the original gestures are properly disabled
                if ([playerViewController.playerView.overlayView isKindOfClass:objc_getClass("YTMainAppVideoPlayerOverlayView")]) {
                    YTMainAppVideoPlayerOverlayView *overlayView = (YTMainAppVideoPlayerOverlayView *)playerViewController.playerView.overlayView;
                    [overlayView YTHFSClearOriginalGestures];
                }
            }

            // update the minimum press duration with whatever the user set in the settings
            playerViewController.YTHFSLongPressGesture.minimumPressDuration = [YTHFSPrefsManager holdDuration];
        } else {
            // remove the custom hold gesture if it was previously created
            if (playerViewController.YTHFSLongPressGesture) {
                [playerViewController.playerView removeGestureRecognizer:playerViewController.YTHFSLongPressGesture];
                playerViewController.YTHFSLongPressGesture = nil;
            }

            // either re-set the stock gestures or ensure they are disabled depending on the tweak preferences
            if ([playerViewController.playerView.overlayView isKindOfClass:objc_getClass("YTMainAppVideoPlayerOverlayView")]) {
                YTMainAppVideoPlayerOverlayView *overlayView = (YTMainAppVideoPlayerOverlayView *)playerViewController.playerView.overlayView;
                if ([YTHFSPrefsManager disableStockGesturesEnabled]) {
                    [overlayView YTHFSClearOriginalGestures];
                } else {
                    [overlayView YTHFSSetOriginalGestures];
                }
            }
        }
    }

    %orig;
}

%end

%hook YTPlayerViewController

// the long press gesture that will be created and added to the player view
%property (nonatomic, retain) UILongPressGestureRecognizer *YTHFSLongPressGesture;

// boolean that determines if the auto-apply feature needs to be invoked for the current video
%property (nonatomic, assign) BOOL YTHFSNeedsAutoApply;

%new
- (void)YTHFSHandleLongPressGesture:(UILongPressGestureRecognizer *)longPressGestureRecognizer
{
    if (longPressGestureRecognizer.state == UIGestureRecognizerStateBegan && [self.contentVideoPlayerOverlay isKindOfClass:objc_getClass("YTMainAppVideoPlayerOverlayViewController")]) {
        YTMainAppVideoPlayerOverlayViewController *overlayViewController = (YTMainAppVideoPlayerOverlayViewController *)self.contentVideoPlayerOverlay;
        if (overlayViewController.isVarispeedAvailable) {
            [self YTHFSSwitchPlaybackRate];
        }
    }
}

%new
- (void)YTHFSSwitchPlaybackRate
{
    NSString *feedbackTitle = nil;
    YTHFSFeedbackDirection feedbackDirection = kYTHFSFeedbackDirectionForward;
    CGFloat currentPlaybackRate = [self currentPlaybackRateForVarispeedSwitchController:self.varispeedController];
    CGFloat togglePlaybackRate = [YTHFSPrefsManager togglePlaybackRate];
    if (currentPlaybackRate != togglePlaybackRate) {
        // change to the toggle rate if the current playback rate is any other speed
        [self varispeedSwitchController:self.varispeedController didSelectRate:togglePlaybackRate];
        feedbackTitle = [YTHFSPrefsManager playbackRateStringForValue:togglePlaybackRate];
        if (currentPlaybackRate > togglePlaybackRate) {
            feedbackDirection = kYTHFSFeedbackDirectionBackward;
        }
    } else {
        // otherwise switch back to the default rate
        [self varispeedSwitchController:self.varispeedController didSelectRate:kYTHFSNormalPlaybackRate];
        feedbackTitle = [YTHFSPrefsManager localizedStringForKey:@"NORMAL" withDefaultValue:@"Normal"];
        if (currentPlaybackRate > kYTHFSNormalPlaybackRate) {
            feedbackDirection = kYTHFSFeedbackDirectionBackward;
        }
    }

    // if the overlay controls are displayed, ensure to hide them before displaying the visual indicator
    if (![self arePlayerControlsHidden] && [self.contentVideoPlayerOverlay isKindOfClass:objc_getClass("YTMainAppVideoPlayerOverlayViewController")]) {
        YTMainAppVideoPlayerOverlayViewController *overlayViewController = (YTMainAppVideoPlayerOverlayViewController *)self.contentVideoPlayerOverlay;
        [overlayViewController hidePlayerControlsAnimated:YES];
    }

    // trigger the double tap to seek view to visibly indicate that the playback rate has changed
    if ([self.playerView.overlayView isKindOfClass:objc_getClass("YTMainAppVideoPlayerOverlayView")]) {
        YTMainAppVideoPlayerOverlayView *overlayView = (YTMainAppVideoPlayerOverlayView *)self.playerView.overlayView;
        [overlayView.doubleTapToSeekView showCenteredSeekFeedbackWithTitle:feedbackTitle direction:feedbackDirection];
    }

    // fire off haptic feedback to indicate that the playback rate changed (only applies to supported devices if enabled)
    if ([YTHFSPrefsManager hapticFeedbackEnabled]) {
        UINotificationFeedbackGenerator *feedbackGenerator = [[UINotificationFeedbackGenerator alloc] init];
        [feedbackGenerator notificationOccurred:UINotificationFeedbackTypeSuccess];
        feedbackGenerator = nil;
    }
}

// invoked when a video (or ad) is activated inside the player
- (void)playbackController:(id)localPlaybackController didActivateVideo:(id)singleVideoController withPlaybackData:(id)playbackData
{
    %orig;

    if ([YTHFSPrefsManager autoApplyRateEnabled] && self.YTHFSNeedsAutoApply && [self.contentVideoPlayerOverlay isKindOfClass:objc_getClass("YTMainAppVideoPlayerOverlayViewController")]) {
        YTMainAppVideoPlayerOverlayViewController *overlayViewController = (YTMainAppVideoPlayerOverlayViewController *)self.contentVideoPlayerOverlay;
        if (overlayViewController.isVarispeedAvailable) {
            // regardless of the current playback rate, at this point we know that the toggle rate will be applied
            self.YTHFSNeedsAutoApply = NO;

            // compare whether or not the current playback rate is what the user selected and if not, change to it now
            if ([self currentPlaybackRateForVarispeedSwitchController:self.varispeedController] != [YTHFSPrefsManager togglePlaybackRate]) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self YTHFSSwitchPlaybackRate];
                });
            }
        }
    }
}

// Prior to YouTube v18.43.4, these methods were implemented in this class (YTPlayerViewController) but have since moved to the YTPlayerOverlayManager class.
// Re-implement these methods to simply call the same methods from the overlay manager. For previous versions of the app, this custom implementation will not be used
// since %new will have no affect on the methods that already exist.
%new
- (float)currentPlaybackRateForVarispeedSwitchController:(YTVarispeedSwitchController *)varispeedSwitchController
{
    return [self.overlayManager currentPlaybackRateForVarispeedSwitchController:varispeedSwitchController];
}
%new
- (void)varispeedSwitchController:(YTVarispeedSwitchController *)varispeedSwitchController didSelectRate:(float)rate
{
    [self.overlayManager varispeedSwitchController:varispeedSwitchController didSelectRate:rate];
}

- (void)dealloc
{
    // remove and destroy the gesture recognizer if it exists
    if (self.YTHFSLongPressGesture) {
        [self.playerView removeGestureRecognizer:self.YTHFSLongPressGesture];
        self.YTHFSLongPressGesture = nil;
    }

    %orig;
}

%end

%hook YTMainAppVideoPlayerOverlayView

// the original gesture objects that might need to be re-set if any of the tweak preferences are changed during runtime
%property (nonatomic, retain) UILongPressGestureRecognizer *YTHFSOriginalSeekAnywhereLongPressGesture;
%property (nonatomic, retain) UIPanGestureRecognizer *YTHFSOriginalSeekAnywherePanGesture;
%property (nonatomic, retain) UILongPressGestureRecognizer *YTHFSOriginalLongPressGesture;

// override the long press gesture recognizer that is used to invoke the seek gesture
- (void)setSeekAnywhereLongPressGestureRecognizer:(UILongPressGestureRecognizer *)longPressGestureRecognizer
{
    if (self.YTHFSOriginalSeekAnywhereLongPressGesture == nil && longPressGestureRecognizer != nil) {
        // keep track of the original gesture in case the preference is changed during runtime
        self.YTHFSOriginalSeekAnywhereLongPressGesture = longPressGestureRecognizer;
    }

    if ((![YTHFSPrefsManager holdGestureEnabled] && ![YTHFSPrefsManager disableStockGesturesEnabled]) || longPressGestureRecognizer == nil) {
        %orig;
    }
}

// override the pan gesture recognizer that is used to invoke the seek gesture
- (void)setSeekAnywherePanGestureRecognizer:(UIPanGestureRecognizer *)panGestureRecognzier
{
    if (self.YTHFSOriginalSeekAnywherePanGesture == nil && panGestureRecognzier != nil) {
        // keep track of the original gesture in case the preference is changed during runtime
        self.YTHFSOriginalSeekAnywherePanGesture = panGestureRecognzier;
    }

    if ((![YTHFSPrefsManager holdGestureEnabled] && ![YTHFSPrefsManager disableStockGesturesEnabled]) || panGestureRecognzier == nil) {
        %orig;
    }
}

// override the long press gesture recognizer that is used to invoke the seek gesture (introduced with YouTube 18.05.2)
- (void)setLongPressGestureRecognizer:(UILongPressGestureRecognizer *)longPressGestureRecognizer
{
    if (self.YTHFSOriginalLongPressGesture == nil && longPressGestureRecognizer != nil) {
        // keep track of the original gesture in case the preference is changed during runtime
        self.YTHFSOriginalLongPressGesture = longPressGestureRecognizer;
    }

    if ((![YTHFSPrefsManager holdGestureEnabled] && ![YTHFSPrefsManager disableStockGesturesEnabled]) || longPressGestureRecognizer == nil) {
        %orig;
    }
}

// clears the original gestures on the overlay view
%new
- (void)YTHFSClearOriginalGestures
{
    if ([self respondsToSelector:@selector(setSeekAnywhereLongPressGestureRecognizer:)]) {
        [self setSeekAnywhereLongPressGestureRecognizer:nil];
    }
    if ([self respondsToSelector:@selector(setSeekAnywherePanGestureRecognizer:)]) {
        [self setSeekAnywherePanGestureRecognizer:nil];
    }
    if ([self respondsToSelector:@selector(setLongPressGestureRecognizer:)]) {
        [self setLongPressGestureRecognizer:nil];
    }
}

// re-sets the original gestures on the overlay view if they exist
%new
- (void)YTHFSSetOriginalGestures
{
    if ([self respondsToSelector:@selector(setSeekAnywhereLongPressGestureRecognizer:)] && self.YTHFSOriginalSeekAnywhereLongPressGesture != nil) {
        [self setSeekAnywhereLongPressGestureRecognizer:self.YTHFSOriginalSeekAnywhereLongPressGesture];
    }
    if ([self respondsToSelector:@selector(setSeekAnywherePanGestureRecognizer:)] && self.YTHFSOriginalSeekAnywherePanGesture != nil) {
        [self setSeekAnywherePanGestureRecognizer:self.YTHFSOriginalSeekAnywherePanGesture];
    }
    if ([self respondsToSelector:@selector(setLongPressGestureRecognizer:)] && self.YTHFSOriginalLongPressGesture != nil) {
        [self setLongPressGestureRecognizer:self.YTHFSOriginalLongPressGesture];
    }
}

%end

%ctor {
    // ensure that the default preferences are available
    [YTHFSPrefsManager registerDefaults];
}