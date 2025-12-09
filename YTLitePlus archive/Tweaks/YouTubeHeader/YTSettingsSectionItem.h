#import "YTIFormattedString.h"
#import "YTIIcon.h"
#import "YTSettingsCell.h"

@interface YTSettingsSectionItem : NSObject
@property (nonatomic, copy, readwrite) NSString *title;
@property (nonatomic, strong, readwrite) YTIIcon *settingIcon;
@property (nonatomic, strong, readwrite) YTIFormattedString *formattedSettingSummary;
@property (nonatomic, assign, readwrite) BOOL hasSwitch;
@property (nonatomic, assign, readwrite) BOOL switchVisible;
@property (nonatomic, assign, readwrite) BOOL on;
@property (nonatomic, assign, readwrite) BOOL enabled;
@property (nonatomic, assign, readwrite, getter=isInkEnabled) BOOL inkEnabled;
@property (nonatomic, assign, readwrite) int settingItemId;
@property (nonatomic, assign, readwrite) int indicatorIconType;
@property (nonatomic, copy, readwrite) BOOL (^selectBlock)(YTSettingsCell *, NSUInteger);
@property (nonatomic, copy, readwrite) BOOL (^switchBlock)(YTSettingsCell *, BOOL);
+ (instancetype)itemWithTitle:(NSString *)title accessibilityIdentifier:(NSString *)accessibilityIdentifier detailTextBlock:(NSString *(^)(void))detailTextBlock selectBlock:(BOOL (^)(YTSettingsCell *, NSUInteger))selectBlock;
+ (instancetype)itemWithTitle:(NSString *)title titleDescription:(NSString *)titleDescription accessibilityIdentifier:(NSString *)accessibilityIdentifier detailTextBlock:(id)detailTextBlock selectBlock:(BOOL (^)(YTSettingsCell *, NSUInteger))selectBlock;
+ (instancetype)checkmarkItemWithTitle:(NSString *)title selectBlock:(BOOL (^)(YTSettingsCell *, NSUInteger))selectBlock;
+ (instancetype)checkmarkItemWithTitle:(NSString *)title titleDescription:(NSString *)titleDescription selectBlock:(BOOL (^)(YTSettingsCell *, NSUInteger))selectBlock;
+ (instancetype)checkmarkItemWithTitle:(NSString *)title titleDescription:(NSString *)titleDescription selectBlock:(BOOL (^)(YTSettingsCell *, NSUInteger))selectBlock disabledSelectBlock:(BOOL (^)(YTSettingsCell *, NSUInteger))disabledSelectBlock;
+ (instancetype)switchItemWithTitle:(NSString *)title switchOn:(BOOL)switchOn switchBlock:(BOOL (^)(YTSettingsCell *, BOOL))switchBlock;
+ (instancetype)switchItemWithTitle:(NSString *)title titleDescription:(NSString *)titleDescription accessibilityIdentifier:(NSString *)accessibilityIdentifier switchOn:(BOOL)switchOn switchBlock:(BOOL (^)(YTSettingsCell *, BOOL))switchBlock settingItemId:(int)settingItemId;
+ (instancetype)switchItemWithTitle:(NSString *)title titleDescription:(NSString *)titleDescription accessibilityIdentifier:(NSString *)accessibilityIdentifier switchOn:(BOOL)switchOn switchBlock:(BOOL (^)(YTSettingsCell *, BOOL))switchBlock selectBlock:(BOOL (^)(YTSettingsCell *, NSUInteger))selectBlock settingItemId:(int)settingItemId;
- (instancetype)initWithTitle:(NSString *)title titleDescription:(NSString *)titleDescription;
@end
