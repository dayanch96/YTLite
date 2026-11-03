#import "YTLSafeMode.h"
#import <UIKit/UIKit.h>

static NSString *const kCrashCountKey = @"YTLiteLaunchCrashCount";
static NSInteger const kCrashThreshold = 3;
static NSTimeInterval const kStableAfter = 15.0;

static BOOL safeMode = NO;

static void markStable(void) {
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:kCrashCountKey];
}

BOOL YTLSafeModeActive(void) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSInteger count = [defaults integerForKey:kCrashCountKey] + 1;
        safeMode = count > kCrashThreshold;
        [defaults setInteger:safeMode ? 0 : count forKey:kCrashCountKey];
        [defaults synchronize];

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kStableAfter * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            markStable();
        });

        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
            markStable();
        }];
    });
    return safeMode;
}

void YTLSafeModeExit(void) {
    safeMode = NO;
    markStable();
}
