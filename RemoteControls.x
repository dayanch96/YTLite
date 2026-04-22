#import "YTLite.h"
#import <MediaPlayer/MediaPlayer.h>

static BOOL ytlDidSetSkipBackwardTarget = NO;
static BOOL ytlDidSetSkipForwardTarget = NO;

static NSInteger YTLRemoteControlInterval(NSString *key) {
    NSInteger interval = [[YTLUserDefaults standardUserDefaults] integerForKey:key];
    return interval > 0 ? interval : 10;
}

static void YTLConfigureRemoteControlCommands() {
    MPRemoteCommandCenter *commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
    BOOL skipBackwardEnabled = ytlBool(@"rcSkipBackward");
    BOOL skipForwardEnabled = ytlBool(@"rcSkipForward");

    commandCenter.skipBackwardCommand.preferredIntervals = @[@(YTLRemoteControlInterval(@"rcSkipBackwardSec"))];
    commandCenter.skipForwardCommand.preferredIntervals = @[@(YTLRemoteControlInterval(@"rcSkipForwardSec"))];

    commandCenter.skipBackwardCommand.enabled = skipBackwardEnabled;
    commandCenter.skipForwardCommand.enabled = skipForwardEnabled;
    commandCenter.previousTrackCommand.enabled = !skipBackwardEnabled;
    commandCenter.nextTrackCommand.enabled = !skipForwardEnabled;
}

%hook MPRemoteCommand
- (void)addTarget:(id)target action:(SEL)action {
    %orig;

    MPRemoteCommandCenter *commandCenter = [MPRemoteCommandCenter sharedCommandCenter];

    if (self == commandCenter.previousTrackCommand && !ytlDidSetSkipBackwardTarget) {
        [commandCenter.skipBackwardCommand addTarget:target action:action];
        ytlDidSetSkipBackwardTarget = YES;
    }

    if (self == commandCenter.nextTrackCommand && !ytlDidSetSkipForwardTarget) {
        [commandCenter.skipForwardCommand addTarget:target action:action];
        ytlDidSetSkipForwardTarget = YES;
    }

    YTLConfigureRemoteControlCommands();
}
%end

%hook MPNowPlayingInfoCenter
- (void)setNowPlayingInfo:(NSDictionary<NSString *, id> *)nowPlayingInfo {
    %orig;
    YTLConfigureRemoteControlCommands();
}
%end
