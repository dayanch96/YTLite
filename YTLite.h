#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <rootless.h>
#import "../YouTubeHeader/YTIPivotBarSupportedRenderers.h"
#import "../YouTubeHeader/YTIPivotBarRenderer.h"
#import "../YouTubeHeader/YTISectionListRenderer.h"
#import "../YouTubeHeader/YTQTMButton.h"
#import "../YouTubeHeader/YTSettingsViewController.h"
#import "../YouTubeHeader/YTSettingsSectionItem.h"
#import "../YouTubeHeader/YTSettingsSectionItemManager.h"
#import "../YouTubeHeader/YTSettingsPickerViewController.h"
#import "../YouTubeHeader/YTUIUtils.h"

extern NSBundle *YTLiteBundle();

static inline NSString *LOC(NSString *key) {
    NSBundle *tweakBundle = YTLiteBundle();
    return [tweakBundle localizedStringForKey:key value:nil table:nil];
}

BOOL kNoAds;
BOOL kBackgroundPlayback;
BOOL kNoCast;
BOOL kNoNotifsButton;
BOOL kNoSearchButton;
BOOL kRemoveLabels;
BOOL kRemoveShorts;
BOOL kRemoveSubscriptions;
BOOL kRemoveUploads;
BOOL kRemoveLibrary;

@interface YTPivotBarView : UIView
@end

@interface YTPivotBarItemView : UIView
@end

@interface YTRightNavigationButtons : UIView
@property (nonatomic, strong) YTQTMButton *notificationButton;
@property (nonatomic, strong) YTQTMButton *searchButton;
@end
