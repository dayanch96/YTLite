#import "CAMGLView.h"

NS_CLASS_AVAILABLE_IOS(8_0)
@interface CAMEffectsGridView : CAMGLView
- (NSUInteger)_cellCount;
- (NSUInteger)_filterIndexForGridIndex:(NSUInteger)index;
- (BOOL)isBlackAndWhite;
- (BOOL)isSquare;
- (CGRect)rectForFilterType:(NSInteger)type;
- (CGRect)_squareCropFromRect:(CGRect)rect;
@end
