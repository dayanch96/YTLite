#import "YTIFormattedString.h"
#import "YTPlainLabel.h"

@protocol YTAttributedLabel <YTPlainLabel>
@property (nonatomic, readonly, strong) NSAttributedString *attributedText;
- (void)setFormattedString:(YTIFormattedString *)formattedString;
@end
