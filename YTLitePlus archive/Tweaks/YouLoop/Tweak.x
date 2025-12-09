#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

#import "../YTVideoOverlay/Header.h"
#import "../YTVideoOverlay/Init.x"
#import "../YouTubeHeader/YTColor.h"
#import "../YouTubeHeader/YTMainAppVideoPlayerOverlayViewController.h"
#import "../YouTubeHeader/YTMainAppVideoPlayerOverlayView.h"
#import "../YouTubeHeader/YTMainAppControlsOverlayView.h"
#import "../YouTubeHeader/YTPlayerViewController.h"
#import "../YouTubeHeader/QTMIcon.h"

#define TweakKey @"YouLoop"
#define IS_ENABLED(k) [[NSUserDefaults standardUserDefaults] boolForKey:k]

@interface YTMainAppVideoPlayerOverlayViewController (YouLoop)
@property (nonatomic, assign) YTPlayerViewController *parentViewController; // for accessing YTPlayerViewController
@end

@interface YTMainAppVideoPlayerOverlayView (YouLoop)
@property (nonatomic, weak, readwrite) YTMainAppVideoPlayerOverlayViewController *delegate;
@end

@interface YTPlayerViewController (YouLoop)
- (void)didPressYouLoop; // contains actual logic for enabling/disabling loop
@end

@interface YTAutoplayAutonavController : NSObject
- (NSInteger)loopMode; // for reading loop state
- (void)setLoopMode:(NSInteger)loopMode; // for setting loop state
@end

@interface YTMainAppControlsOverlayView (YouLoop)
@property (nonatomic, assign) YTPlayerViewController *playerViewController; // for accessing YTPlayerViewController
- (void)didPressYouLoop:(id)arg; // for custom button press
@end

// For accessing YTPlayerViewController
@interface YTInlinePlayerBarController : NSObject
@end

@interface YTInlinePlayerBarContainerView (YouLoop)
@property (nonatomic, strong) YTInlinePlayerBarController *delegate; // for accessing YTPlayerViewController
- (void)didPressYouLoop:(id)arg; // for custom button press
@end

@interface YTColor (YouLoop)
+ (UIColor *)lightRed; // for tinting the loop button when enabled
@end

// For displaying snackbars - @theRealfoxster
@interface YTHUDMessage : NSObject
+ (id)messageWithText:(id)text;
- (void)setAction:(id)action;
@end
@interface GOOHUDManagerInternal : NSObject
- (void)showMessageMainThread:(id)message;
+ (id)sharedInstance;
@end

// Retrieves the bundle for the tweak
NSBundle *YouLoopBundle() {
    static NSBundle *bundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *tweakBundlePath = [[NSBundle mainBundle] pathForResource:TweakKey ofType:@"bundle"];
        if (tweakBundlePath)
            bundle = [NSBundle bundleWithPath:tweakBundlePath];
        else
            bundle = [NSBundle bundleWithPath:[NSString stringWithFormat:ROOT_PATH_NS(@"/Library/Application Support/%@.bundle"), TweakKey]];
    });
    return bundle;
}
static NSBundle *tweakBundle = nil; // not sure why I need to store tweakBundle

// Get the image for the loop button based on the given state and size
static UIImage *getYouLoopImage(NSString *imageSize) {
    UIColor *tintColor = IS_ENABLED(@"defaultLoop_enabled") ? [%c(YTColor) lightRed] : [%c(YTColor) white1];
    NSString *imageName = [NSString stringWithFormat:@"PlayerLoop@%@", imageSize];
    return [%c(QTMIcon) tintImage:[UIImage imageNamed:imageName inBundle:YouLoopBundle() compatibleWithTraitCollection:nil] color:tintColor];
}

%group Main
%hook YTPlayerViewController
// New method to enable looping on the current video, also stores state
// for all future videos
%new
- (void)didPressYouLoop {
    id mainAppController = self.activeVideoPlayerOverlay;
    // Check if type is YTMainAppVideoPlayerOverlayViewController
    if ([mainAppController isKindOfClass:objc_getClass("YTMainAppVideoPlayerOverlayViewController")]) {
        // Get the autoplay navigation controller
        YTMainAppVideoPlayerOverlayViewController *playerOverlay = (YTMainAppVideoPlayerOverlayViewController *)mainAppController;
        YTAutoplayAutonavController *autoplayController = (YTAutoplayAutonavController *)[playerOverlay valueForKey:@"_autonavController"];
        // Get the current loop state from the controller's method
        BOOL isLoopEnabled = ([autoplayController loopMode] == 0);
        // Update the key for later use
        [[NSUserDefaults standardUserDefaults] setBool:isLoopEnabled forKey:@"defaultLoop_enabled"];
        // Set the loop mode to the opposite of the current state
        [autoplayController setLoopMode:isLoopEnabled ? 2 : 0];
        // Display snackbar
        [[%c(GOOHUDManagerInternal) sharedInstance] showMessageMainThread:[%c(YTHUDMessage) messageWithText:LOC(isLoopEnabled ? @"Loop enabled" : @"Loop disabled")]];
    }
}
%end

%hook YTAutoplayAutonavController
// Modify the initializer to set the loop mode to the user's preference
- (id)initWithParentResponder:(id)arg1 {
    self = %orig(arg1);
    if (self) {
        if (IS_ENABLED(@"defaultLoop_enabled")) {
            [self setLoopMode:2];
        }
    }
    return self;
}
// Modify the setter to always follow the user's preference. This breaks normal functionality
- (void)setLoopMode:(NSInteger)arg1 {
    if (IS_ENABLED(@"defaultLoop_enabled")) {
        arg1 = 2;
    }
    %orig;
}
%end
%end

/**
  * Adds a button to the top area in the video player overlay
  */
%group Top
%hook YTMainAppControlsOverlayView

- (UIImage *)buttonImage:(NSString *)tweakId {
    return [tweakId isEqualToString:TweakKey] ? getYouLoopImage(@"3") : %orig;
}

// Custom method to handle the button press
%new(v@:@)
- (void)didPressYouLoop:(id)arg {
    // Call our custom method in the YTPlayerViewController class
    YTMainAppVideoPlayerOverlayView *mainOverlayView = (YTMainAppVideoPlayerOverlayView *)self.superview;
    YTMainAppVideoPlayerOverlayViewController *mainOverlayController = (YTMainAppVideoPlayerOverlayViewController *)mainOverlayView.delegate;
    YTPlayerViewController *playerViewController = mainOverlayController.parentViewController;
    if (playerViewController) {
        [playerViewController didPressYouLoop];
    }
    // Update button color
    [self.overlayButtons[TweakKey] setImage:getYouLoopImage(@"3") forState:0];
}

%end
%end

/**
  * Adds a button to the bottom area next to the fullscreen button
  */
%group Bottom
%hook YTInlinePlayerBarContainerView

- (UIImage *)buttonImage:(NSString *)tweakId {
    return [tweakId isEqualToString:TweakKey] ? getYouLoopImage(@"3") : %orig;
}

// Custom method to handle the button press
%new(v@:@)
- (void)didPressYouLoop:(id)arg {
    // Navigate to the YTPlayerViewController class from here
    YTInlinePlayerBarController *delegate = self.delegate; // for @property
    YTMainAppVideoPlayerOverlayViewController *_delegate = [delegate valueForKey:@"_delegate"]; // for ivars
    YTPlayerViewController *parentViewController = _delegate.parentViewController;
    // Call our custom method in the YTPlayerViewController class
    if (parentViewController) {
        [parentViewController didPressYouLoop];
    }
    // Update button color
    [self.overlayButtons[TweakKey] setImage:getYouLoopImage(@"3") forState:0];
}

%end
%end

%ctor {
    tweakBundle = YouLoopBundle(); // not sure why I need to store tweakBundle
    // Setup as defined in the example from YTVideoOverlay
    initYTVideoOverlay(TweakKey, @{
        AccessibilityLabelKey: @"Toggle Loop",
        SelectorKey: @"didPressYouLoop:"
    });
    %init(Main);
    %init(Top);
    %init(Bottom);
}
