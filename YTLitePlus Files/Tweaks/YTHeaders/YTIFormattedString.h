#import "YTIFormattedStringSupportedAccessibilityDatas.h"
#import "YTIStringRun.h"

@interface YTIFormattedString : GPBMessage
+ (instancetype)formattedStringWithString:(NSString *)string;
@property (nonatomic, strong, readwrite) NSMutableArray <YTIStringRun *> *runsArray;
@property (nonatomic, strong, readwrite) YTIFormattedStringSupportedAccessibilityDatas *accessibility;
- (NSString *)stringWithFormattingRemoved;
@end
