#import <UIKit/UIKit.h>

@interface YTDefaultTypeStyle : NSObject
- (UIFont *)fontForFontRole:(NSInteger)role size:(CGFloat)size weight:(UIFontWeight)weight;
- (UIFont *)ytSansFontOfSize:(CGFloat)size weight:(UIFontWeight)weight;
- (UIFont *)fontOfSize:(CGFloat)size weight:(UIFontWeight)weight;
@end
