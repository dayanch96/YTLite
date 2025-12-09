#import <YouTubeHeader/YTSettingsSectionItemManager.h>
#import <PSHeader/Misc.h>

#define AccessibilityLabelKey @"accessibilityLabel"
#define ToggleKey @"toggle"
#define AsTextKey @"asText"
#define SelectorKey @"selector"
#define UpdateImageOnVisibleKey @"updateImageOnVisible"
#define ExtraBooleanKeys @"extraBooleanKeys"

@interface YTSettingsSectionItemManager (YTVideoOverlayInit)
+ (void)registerTweak:(NSString *)tweakId metadata:(NSDictionary *)metadata;
@end
