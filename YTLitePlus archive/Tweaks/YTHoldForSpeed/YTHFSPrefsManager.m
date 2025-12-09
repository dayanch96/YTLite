//
//  YTHFSPrefsManager.m
//
//  Created by Joshua Seltzer on 12/5/22.
//  
//

#import "YTHFSPrefsManager.h"
#import <CoreHaptics/CoreHaptics.h>
#import <sys/utsname.h>
#import <rootless.h>

// define constants for the keys used to interact with the settings within user defaults
#define kYTHFSHoldGestureEnabledKey             @"YTHFSHoldGestureEnabled"
#define kYTHFSDisableStockGesturesEnabledKey    @"YTHFSDisableStockGesturesEnabled"
#define kYTHFSAutoApplyRateEnabledKey           @"YTHFSAutoApplyRateEnabled"
#define kYTHFSTogglePlaybackRateKey             @"YTHFSTogglePlaybackRate"
#define kYTHFSHoldDurationKey                   @"YTHFSHoldDuration"
#define kYTHFSHapticFeedbackEnabledKey          @"YTHFSHapticFeedbackEnabled"

// define some constants to define the default preference values
#define kYTHFSDefaultHoldGestureEnabled             NO
#define kYTHFSDefaultDisableStockGesturesEnabled    NO
#define kYTHFSDefaultAutoApplyRateEnabled           NO
#define kYTHFSDefaultTogglePlaybackRate             2.0
#define kYTHFSDefaultHoldDuration                   1.0

// create static variables that will be determined once
static NSBundle *sYTHFSBundle;
static BOOL sYTHFSSupportsHapticFeedback;
static NSNumberFormatter *sYTHFSDecimalNumberFormatter;

@implementation YTHFSPrefsManager

// return a localized string with a given default value from the localization files in the tweak bundle
+ (NSString *)localizedStringForKey:(NSString *)key withDefaultValue:(NSString *)defaultValue
{
    NSBundle *tweakBundle = [YTHFSPrefsManager bundle];
    if (tweakBundle != nil) {
        return [tweakBundle localizedStringForKey:key value:defaultValue table:@"Localizable"];
    } else {
        return defaultValue;
    }
}

// intended to be invoked when the tweak is initialized to ensure all of the default values are available
+ (void)registerDefaults
{
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{kYTHFSHoldGestureEnabledKey:[NSNumber numberWithBool:kYTHFSDefaultHoldGestureEnabled],
                                                              kYTHFSDisableStockGesturesEnabledKey:[NSNumber numberWithBool:kYTHFSDefaultDisableStockGesturesEnabled],
                                                              kYTHFSAutoApplyRateEnabledKey:[NSNumber numberWithBool:kYTHFSDefaultAutoApplyRateEnabled],
                                                              kYTHFSTogglePlaybackRateKey:[NSNumber numberWithFloat:kYTHFSDefaultTogglePlaybackRate],
                                                              kYTHFSHoldDurationKey:[NSNumber numberWithFloat:kYTHFSDefaultHoldDuration],
                                                              kYTHFSHapticFeedbackEnabledKey:[NSNumber numberWithBool:[YTHFSPrefsManager supportsHapticFeedback]]}];
}

// returns whether or not the device supports haptic feedback
+ (BOOL)supportsHapticFeedback
{
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        // determine if the current device is able to support haptic feedback
        if (!CHHapticEngine.capabilitiesForHardware.supportsHaptics) {
            // ensure we are not on an iPhone 7 family device, since those devices are not covered under
            // the supportsHaptics call as of 2022-12-08 / iOS 16.1 SDK
            struct utsname systemInfo;
            uname(&systemInfo);
            NSString *currentDeviceIdentifier = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
            if ([currentDeviceIdentifier isEqualToString:@"iPhone9,1"] ||
                [currentDeviceIdentifier isEqualToString:@"iPhone9,3"] ||
                [currentDeviceIdentifier isEqualToString:@"iPhone9,2"] ||
                [currentDeviceIdentifier isEqualToString:@"iPhone9,4"]) {
                sYTHFSSupportsHapticFeedback = YES;
            } else {
                sYTHFSSupportsHapticFeedback = NO;
            }
        } else {
            sYTHFSSupportsHapticFeedback = YES;
        }
    });
    return sYTHFSSupportsHapticFeedback;
}

// return the value that corresponds to the given hold duration option
+ (CGFloat)holdDurationValueForOption:(YTHFSHoldDurationOption)holdDurationOption
{
    return (holdDurationOption + 1) * 0.25;
}

// return the value that corresponds to the given playback rate option
+ (CGFloat)playbackRateValueForOption:(YTHFSPlaybackRateOption)playbackRateOption
{
    CGFloat playbackRateOffset = 0.25;
    if (playbackRateOption > kYTHFSPlaybackRateOption075) {
        playbackRateOffset = playbackRateOffset * 2;
    }
    return playbackRateOption * 0.25 + playbackRateOffset;
}

// return the hold playback option for the given value
+ (YTHFSHoldDurationOption)holdDurationOptionForValue:(CGFloat)value
{
    return MAX(MIN((NSInteger)(value / 0.25) - 1, kYTHFSHoldDurationOption200), kYTHFSHoldDurationOption025);
}

// return the playback rate option for the given value
+ (YTHFSPlaybackRateOption)playbackRateOptionForValue:(CGFloat)value
{
    NSInteger playbackRateOptionOffset = 1;
    if (value > 1.00) {
        ++playbackRateOptionOffset;
    }
    return MAX(MIN((NSInteger)(value / 0.25) - playbackRateOptionOffset, kYTHFSPlaybackRateOption500), kYTHFSPlaybackRateOption025);
}

// return the appropriate string representation of the hold duration for the given value
+ (NSString *)holdDurationStringForValue:(CGFloat)value
{
    return [NSString stringWithFormat:[YTHFSPrefsManager localizedStringForKey:@"X_SECONDS" withDefaultValue:@"%@ seconds"], [[YTHFSPrefsManager decimalNumberFormatter] stringFromNumber:[NSNumber numberWithFloat:value]]];
}

// return the appropriate string representation of the playback rate for the given value
+ (NSString *)playbackRateStringForValue:(CGFloat)value
{
    return [NSString stringWithFormat:@"%@x", [[YTHFSPrefsManager decimalNumberFormatter] stringFromNumber:[NSNumber numberWithFloat:value]]];
}

// setters and getters for the tweak preferences
+ (BOOL)holdGestureEnabled
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kYTHFSHoldGestureEnabledKey];
}
+ (void)setHoldGestureEnabled:(BOOL)enabled
{
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:kYTHFSHoldGestureEnabledKey];
}
+ (BOOL)disableStockGesturesEnabled
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kYTHFSDisableStockGesturesEnabledKey];
}
+ (void)setDisableStockGesturesEnabled:(BOOL)enabled
{
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:kYTHFSDisableStockGesturesEnabledKey];
}
+ (BOOL)autoApplyRateEnabled
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kYTHFSAutoApplyRateEnabledKey];
}
+ (void)setAutoApplyRateEnabled:(BOOL)enabled
{
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:kYTHFSAutoApplyRateEnabledKey];
}
+ (CGFloat)togglePlaybackRate
{
    return [[NSUserDefaults standardUserDefaults] floatForKey:kYTHFSTogglePlaybackRateKey];
}
+ (void)setTogglePlaybackRate:(CGFloat)playbackRate
{
    [[NSUserDefaults standardUserDefaults] setFloat:playbackRate forKey:kYTHFSTogglePlaybackRateKey];
}
+ (CGFloat)holdDuration
{
    return [[NSUserDefaults standardUserDefaults] floatForKey:kYTHFSHoldDurationKey];
}
+ (void)setHoldDuration:(CGFloat)holdDuration
{
    [[NSUserDefaults standardUserDefaults] setFloat:holdDuration forKey:kYTHFSHoldDurationKey];
}
+ (BOOL)hapticFeedbackEnabled
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kYTHFSHapticFeedbackEnabledKey];
}
+ (void)setHapticFeedbackEnabled:(BOOL)hapticFeedbackEnabled
{
    [[NSUserDefaults standardUserDefaults] setBool:hapticFeedbackEnabled forKey:kYTHFSHapticFeedbackEnabledKey];
}

// return the bundle for the tweak which can be different depending on the jailbreak / installation method
+ (NSBundle *)bundle
{
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"YTHoldForSpeed" ofType:@"bundle"];
        if (bundlePath) {
            sYTHFSBundle = [NSBundle bundleWithPath:bundlePath];
        } else {
            sYTHFSBundle = [NSBundle bundleWithPath:ROOT_PATH_NS(@"/Library/Application Support/YTHoldForSpeed.bundle")];
        }
    });
    return sYTHFSBundle;
}

// return the number formatter that will be used to create strings for the playback rate and hold duration
+ (NSNumberFormatter *)decimalNumberFormatter
{
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        sYTHFSDecimalNumberFormatter = [[NSNumberFormatter alloc] init];
        [sYTHFSDecimalNumberFormatter setMinimumFractionDigits:1];
        [sYTHFSDecimalNumberFormatter setMaximumFractionDigits:2];
    });
    return sYTHFSDecimalNumberFormatter;
}

@end
