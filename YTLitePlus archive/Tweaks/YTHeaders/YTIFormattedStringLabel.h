#import <UIKit/UIKit.h>
#import "YTIFormattedString.h"

@interface YTIFormattedStringLabel : UILabel
@property (nonatomic, copy, readwrite) NSAttributedString *attributedText;
- (void)setFormattedString:(YTIFormattedString *)string;
@end
