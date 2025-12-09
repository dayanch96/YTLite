#import "YTIFormattedStringSupportedAccessibilityDatas.h"

@interface YTIFormattedString : NSObject
+ (instancetype)formattedStringWithString:(NSString *)string;
@property (nonatomic, strong, readwrite) NSMutableArray *runsArray;
@property (nonatomic, strong, readwrite) YTIFormattedStringSupportedAccessibilityDatas *accessibility;
- (NSString *)stringWithFormattingRemoved;
@end
