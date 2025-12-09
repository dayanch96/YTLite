#import <Foundation/Foundation.h>

extern NSBundle *iSponsorBlockBundle();

static inline NSString *LOC(NSString *key) {
    NSBundle *tweakBundle = iSponsorBlockBundle();
    return [tweakBundle localizedStringForKey:key value:nil table:nil];
}