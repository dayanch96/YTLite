#import "../YTVideoOverlay/Header.h"
#import "../YTVideoOverlay/Init.x"
#import <YouTubeHeader/QTMIcon.h>
#import <YouTubeHeader/YTColor.h>
#import <YouTubeHeader/YTMainAppVideoPlayerOverlayViewController.h>
#import <YouTubeHeader/YTSingleVideoController.h>

#define TweakKey @"YouMute"

@interface YTMainAppControlsOverlayView (YouMute)
- (void)didPressMute:(id)arg;
@end

@interface YTInlinePlayerBarContainerView (YouMute)
- (void)didPressMute:(id)arg;
@end

static BOOL isMutedTop(YTMainAppControlsOverlayView *self) {
    YTMainAppVideoPlayerOverlayViewController *c = [self valueForKey:@"_eventsDelegate"];
    YTSingleVideoController *video = [c valueForKey:@"_currentSingleVideoObservable"];
    return [video isMuted];
}

static BOOL isMutedBottom(YTInlinePlayerBarContainerView *self) {
    YTSingleVideoController *video = [self.delegate valueForKey:@"_currentSingleVideo"];
    return [video isMuted];
}

static UIImage *muteImage(BOOL muted) {
    return [%c(QTMIcon) imageWithName:muted ? @"ic_volume_off" : @"ic_volume_up" color:[%c(YTColor) white1]];
}

%group Top

%hook YTMainAppControlsOverlayView

- (UIImage *)buttonImage:(NSString *)tweakId {
    return [tweakId isEqualToString:TweakKey] ? muteImage(isMutedTop(self)) : %orig;
}

%new(v@:@)
- (void)didPressMute:(id)arg {
    YTMainAppVideoPlayerOverlayViewController *c = [self valueForKey:@"_eventsDelegate"];
    YTSingleVideoController *video = [c valueForKey:@"_currentSingleVideoObservable"];
    [video setMuted:![video isMuted]];
    [self.overlayButtons[TweakKey] setImage:muteImage([video isMuted]) forState:UIControlStateNormal];
}

%end

%end

%group Bottom

%hook YTInlinePlayerBarContainerView

- (UIImage *)buttonImage:(NSString *)tweakId {
    return [tweakId isEqualToString:TweakKey] ? muteImage(isMutedBottom(self)) : %orig;
}

%new(v@:@)
- (void)didPressMute:(id)arg {
    YTSingleVideoController *video = [self.delegate valueForKey:@"_currentSingleVideo"];
    [video setMuted:![video isMuted]];
    [self.overlayButtons[TweakKey] setImage:muteImage([video isMuted]) forState:UIControlStateNormal];
}

%end

%end

%ctor {
    initYTVideoOverlay(TweakKey, @{
        AccessibilityLabelKey: @"Mute",
        SelectorKey: @"didPressMute:",
        UpdateImageOnVisibleKey: @YES
    });
    %init(Top);
    %init(Bottom);
}
