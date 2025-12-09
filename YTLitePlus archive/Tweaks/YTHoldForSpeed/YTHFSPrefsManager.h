//
//  YTHFSPrefsManager.h
//
//  Created by Joshua Seltzer on 12/5/22.
//  
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// enum to define the options for the hold duration
typedef enum YTHFSHoldDurationOption : NSInteger {
    kYTHFSHoldDurationOption025,
    kYTHFSHoldDurationOption050,
    kYTHFSHoldDurationOption075,
    kYTHFSHoldDurationOption100,
    kYTHFSHoldDurationOption125,
    kYTHFSHoldDurationOption150,
    kYTHFSHoldDurationOption175,
    kYTHFSHoldDurationOption200
} YTHFSHoldDurationOption;

// enum to define the options for the playback rate
typedef enum YTHFSPlaybackRateOption : NSInteger {
    kYTHFSPlaybackRateOption025,
    kYTHFSPlaybackRateOption050,
    kYTHFSPlaybackRateOption075,
    kYTHFSPlaybackRateOption125,
    kYTHFSPlaybackRateOption150,
    kYTHFSPlaybackRateOption175,
    kYTHFSPlaybackRateOption200,
    kYTHFSPlaybackRateOption225,
    kYTHFSPlaybackRateOption250,
    kYTHFSPlaybackRateOption275,
    kYTHFSPlaybackRateOption300,
    kYTHFSPlaybackRateOption325,
    kYTHFSPlaybackRateOption350,
    kYTHFSPlaybackRateOption375,
    kYTHFSPlaybackRateOption400,
    kYTHFSPlaybackRateOption425,
    kYTHFSPlaybackRateOption450,
    kYTHFSPlaybackRateOption475,
    kYTHFSPlaybackRateOption500
} YTHFSPlaybackRateOption;

// manager that manages the preferences for the tweak
@interface YTHFSPrefsManager : NSObject

// return a localized string with a given default value from the localization files in the tweak bundle
+ (NSString *)localizedStringForKey:(NSString *)key withDefaultValue:(NSString *)defaultValue;

// intended to be invoked when the tweak is initialized to ensure all of the default values are available
+ (void)registerDefaults;

// returns whether or not the device supports haptic feedback
+ (BOOL)supportsHapticFeedback;

// return the value that corresponds to the given hold duration option
+ (CGFloat)holdDurationValueForOption:(YTHFSHoldDurationOption)holdDurationOption;

// return the value that corresponds to the given playback rate option
+ (CGFloat)playbackRateValueForOption:(YTHFSPlaybackRateOption)playbackRateOption;

// return the hold playback option for the given value
+ (YTHFSHoldDurationOption)holdDurationOptionForValue:(CGFloat)value;

// return the playback rate option for the given value
+ (YTHFSPlaybackRateOption)playbackRateOptionForValue:(CGFloat)value;

// return the appropriate string representation of the hold duration for the given value
+ (NSString *)holdDurationStringForValue:(CGFloat)value;

// return the appropriate string representation of the playback rate for the given value
+ (NSString *)playbackRateStringForValue:(CGFloat)value;

// setters and getters for the tweak preferences
+ (BOOL)holdGestureEnabled;
+ (void)setHoldGestureEnabled:(BOOL)enabled;
+ (BOOL)disableStockGesturesEnabled;
+ (void)setDisableStockGesturesEnabled:(BOOL)enabled;
+ (BOOL)autoApplyRateEnabled;
+ (void)setAutoApplyRateEnabled:(BOOL)enabled;
+ (CGFloat)togglePlaybackRate;
+ (void)setTogglePlaybackRate:(CGFloat)playbackRate;
+ (CGFloat)holdDuration;
+ (void)setHoldDuration:(CGFloat)holdDuration;
+ (BOOL)hapticFeedbackEnabled;
+ (void)setHapticFeedbackEnabled:(BOOL)enabled;

@end
