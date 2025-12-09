#import <Foundation/NSUserDefaults.h>
#import <Foundation/NSValue.h>
#import "TweakSettings.h"

BOOL TweakEnabled() {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *value = [defaults objectForKey:EnabledKey];
    return value ? [value boolValue] : YES;
}

BOOL VoteSubmissionEnabled() {
    return [[NSUserDefaults standardUserDefaults] boolForKey:EnableVoteSubmissionKey];
}

BOOL ExactLikeNumber() {
    return [[NSUserDefaults standardUserDefaults] boolForKey:ExactLikeKey];
}

BOOL ExactDislikeNumber() {
    return [[NSUserDefaults standardUserDefaults] boolForKey:ExactDislikeKey];
}

BOOL UseRawData() {
    return [[NSUserDefaults standardUserDefaults] boolForKey:UseRawDataKey];
}

BOOL UseRYDLikeData() {
    return [[NSUserDefaults standardUserDefaults] boolForKey:UseRYDLikeDataKey];
}

void enableVoteSubmission(BOOL enabled) {
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:EnableVoteSubmissionKey];
}
