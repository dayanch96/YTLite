#import <Foundation/Foundation.h>

@interface YTAppSettingsStore : NSObject
+ (NSUInteger)valueTypeForSetting:(int)setting;
- (void)setValue:(NSNumber *)value forSetting:(int)setting;
- (void)setBool:(BOOL)value forSetting:(int)setting;
- (NSNumber *)valueForSetting:(int)setting;
- (BOOL)boolForSetting:(int)setting;
@end