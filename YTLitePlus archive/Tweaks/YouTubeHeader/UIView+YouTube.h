#import <UIKit/UIView.h>

@interface UIView (YouTube)
- (BOOL)yt_isVisible;
- (void)yt_setOrigin:(CGPoint)origin;
- (void)yt_setSize:(CGSize)size;
- (void)yt_setWidth:(CGFloat)width;
- (void)yt_setHeight:(CGFloat)height;
- (void)goo_flipViewForRTL;
- (void)goo_relayoutSubviewsForRTL;
- (void)alignCenterBottomToCenterBottomOfView:(UIView *)view paddingY:(CGFloat)paddingY;
- (void)alignCenterTopToCenterBottomOfView:(UIView *)view paddingY:(CGFloat)paddingY;
- (void)alignCenterTopToCenterTopOfView:(UIView *)view paddingY:(CGFloat)paddingY;
- (void)alignCenterBottomToCenterTopOfView:(UIView *)view paddingY:(CGFloat)paddingY;
- (void)alignCenterLeadingToCenterLeadingOfView:(UIView *)view paddingX:(CGFloat)paddingX;
- (void)alignCenterLeadingToCenterTrailingOfView:(UIView *)view paddingX:(CGFloat)paddingX;
- (void)alignCenterTopToCenterBottomOfView:(UIView *)view paddingY:(CGFloat)paddingY;
- (void)alignCenterTopToCenterTopOfView:(UIView *)view paddingY:(CGFloat)paddingY;
- (void)alignCenterTrailingToCenterLeadingOfView:(UIView *)view paddingX:(CGFloat)paddingX;
- (void)alignCenterTrailingToCenterTrailingOfView:(UIView *)view paddingX:(CGFloat)paddingX;
- (void)alignTopLeadingToBottomLeadingOfView:(UIView *)view paddingX:(CGFloat)paddingX paddingY:(CGFloat)paddingY;
- (void)alignTopLeadingToBottomTrailingOfView:(UIView *)view paddingX:(CGFloat)paddingX paddingY:(CGFloat)paddingY;
- (void)alignTopTrailingToBottomLeadingOfView:(UIView *)view paddingX:(CGFloat)paddingX paddingY:(CGFloat)paddingY;
- (void)alignTopTrailingToBottomTrailingOfView:(UIView *)view paddingX:(CGFloat)paddingX paddingY:(CGFloat)paddingY;
@end
