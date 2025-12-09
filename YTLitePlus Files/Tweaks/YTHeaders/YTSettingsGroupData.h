#import <Foundation/Foundation.h>

@interface YTSettingsGroupData : NSObject
@property (nonatomic, readonly, strong) NSString *title;
@property (nonatomic, readonly, assign) NSUInteger type;
@property (nonatomic, readonly, strong) NSArray <NSNumber *> *orderedCategories;
- (instancetype)initWithGroupType:(NSUInteger)groupType;
- (NSString *)titleForSettingGroupType:(NSUInteger)groupType;
- (NSArray <NSNumber *> *)orderedCategoriesForGroupType:(NSUInteger)groupType;
- (NSArray <NSNumber *> *)accountCategories;
- (NSArray <NSNumber *> *)appPreferenceCategories;
- (NSArray <NSNumber *> *)videoPreferencesCategories;
- (NSArray <NSNumber *> *)privacyCategories;
- (NSArray <NSNumber *> *)miscellaneousCategories;
- (NSArray <NSNumber *> *)developmentCategories;
@end
