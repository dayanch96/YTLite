#import <YouTubeHeader/YTIIcon.h>
#import <YouTubeHeader/YTSettingsGroupData.h>
#import <PSHeader/Misc.h>

#define LOC(x) [tweakBundle localizedStringForKey:x value:nil table:nil]

@interface YTSettingsGroupData (YouGroupSettings)
+ (NSMutableArray <NSNumber *> *)tweaks;
@end

static const NSInteger TweakGroup = 'psyt';
static const NSInteger YTIcons = 'ytic';
static const NSInteger YouChooseQuality = 'ycql';
static const NSInteger YTUHD = 'ythd';
static const NSInteger YouSlider = 'ytsl';

NSBundle *TweakBundle() {
    static NSBundle *bundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *tweakBundlePath = [[NSBundle mainBundle] pathForResource:@"YouGroupSettings" ofType:@"bundle"];
        bundle = [NSBundle bundleWithPath:tweakBundlePath ?: PS_ROOT_PATH_NS(@"/Library/Application Support/YouGroupSettings.bundle")];
    });
    return bundle;
}

%hook YTAppSettingsGroupPresentationData

+ (NSArray <YTSettingsGroupData *> *)orderedGroups {
    NSArray <YTSettingsGroupData *> *groups = %orig;
    NSMutableArray <YTSettingsGroupData *> *mutableGroups = [groups mutableCopy];
    YTSettingsGroupData *tweakGroup = [[%c(YTSettingsGroupData) alloc] initWithGroupType:TweakGroup];
    [mutableGroups insertObject:tweakGroup atIndex:0];
    return mutableGroups;
}

%end

%hook YTSettingsGroupData

%new(@@:)
+ (NSMutableArray <NSNumber *> *)tweaks {
    static NSMutableArray <NSNumber *> *tweaks = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tweaks = [NSMutableArray new];
        [tweaks addObjectsFromArray:@[
            @(404), // YTABConfig
            @(YTIcons), // YTIcons
            @(2002), // Gonerino
            @(500), // uYou+,
            @(517), // DontEatMyContent
            @(1080), // Return YouTube Dislike
            @(YTUHD),
            @(YouChooseQuality),
            @(200), // YouPiP
            @(YouSlider),
            @(2168), // YTHoldForSpeed
            @(1222), // YTVideoOverlay
        ]];
    });
    return tweaks;
}

- (NSString *)titleForSettingGroupType:(NSUInteger)type {
    if (type == TweakGroup) {
        NSBundle *tweakBundle = TweakBundle();
        return LOC(@"TWEAKS");
    }
    return %orig;
}

- (NSArray <NSNumber *> *)orderedCategoriesForGroupType:(NSUInteger)type {
    if (type == TweakGroup)
        return [[self class] tweaks];
    return %orig;
}

%end

%hook YTSettingsViewController

- (void)setSectionItems:(NSMutableArray *)sectionItems forCategory:(NSInteger)category title:(NSString *)title icon:(YTIIcon *)icon titleDescription:(NSString *)titleDescription headerHidden:(BOOL)headerHidden {
    if (icon == nil && [[%c(YTSettingsGroupData) tweaks] containsObject:@(category)]) {
        icon = [%c(YTIIcon) new];
        icon.iconType = YT_SETTINGS;
    }
    %orig;
}

%end
