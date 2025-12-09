#import <UIKit/UIKit.h>

@interface YTPlayerBarSegmentedProgressView : UIView
@property (nonatomic, readwrite, assign) CGFloat totalTime;
@property (nonatomic, readwrite, assign) int playerViewLayout;
- (void)maybeCreateMarkerViews;
- (void)setChapters:(NSArray *)chapters;
- (void)createAndAddMarker:(CGFloat)arg1 type:(NSInteger)type width:(CGFloat)width;
- (void)createAndAddMarker:(CGFloat)arg1 type:(NSInteger)type clusterType:(NSInteger)clusterType width:(CGFloat)width; // Deprecated
- (NSMutableArray *)segmentViews;
@end
