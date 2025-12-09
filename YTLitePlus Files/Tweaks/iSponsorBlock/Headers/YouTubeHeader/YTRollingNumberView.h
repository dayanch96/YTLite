#import <UIKit/UIKit.h>
#import "YTFontAttributes.h"

@interface YTRollingNumberView : UIView
@property (nonatomic, strong, readwrite) NSMutableArray *digitViews;
@property (nonatomic, readonly, strong) UIFont *font;
@property (nonatomic, readonly, strong) UIColor *color;
@property (nonatomic, readonly, strong) NSString *updatedCount;
@property (nonatomic, readonly, strong) NSNumber *updatedCountNumber;
@property (nonatomic, readonly, strong) YTFontAttributes *fontAttributes;
- (instancetype)initWithDelegate:(id)delegate;
- (void)setUpdatedCount:(NSString *)updatedCount updatedCountNumber:(NSNumber *)updatedCountNumber font:(UIFont *)font color:(UIColor *)color skipAnimation:(BOOL)skipAnimation;
- (void)setUpdatedCount:(NSString *)updatedCount updatedCountNumber:(NSNumber *)updatedCountNumber font:(UIFont *)font fontAttributes:(YTFontAttributes *)fontAttributes color:(UIColor *)color skipAnimation:(BOOL)skipAnimation; // 19.14.2+
@end
