#import "PLGLView.h"

NS_CLASS_DEPRECATED_IOS(7_0, 7_1)
@interface PLEffectsGridView : PLGLView
- (NSUInteger)_cellCount;
- (NSUInteger)_filterIndexForGridIndex:(NSUInteger)index;
- (BOOL)isBlackAndWhite;
- (BOOL)isSquare;
- (CGRect)rectForFilterIndex:(NSUInteger)index;
- (CGRect)_squareCropFromRect:(CGRect)rect;
@end
