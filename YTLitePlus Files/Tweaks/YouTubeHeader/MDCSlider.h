#import <UIKit/UIKit.h>

@protocol MDCSliderDelegate <NSObject>
@end

@interface MDCSlider : UIControl
@property (nonatomic, assign, getter=isStatefulAPIEnabled) BOOL statefulAPIEnabled;
@property (nonatomic, assign, getter=isThumbHollowAtStart) BOOL thumbHollowAtStart;
@property (nonatomic, weak) id <MDCSliderDelegate> delegate;
@property (nonatomic, assign) CGFloat thumbRadius;
@property (nonatomic, assign) CGFloat value;
@property (nonatomic, assign) CGFloat minimumValue;
@property (nonatomic, assign) CGFloat maximumValue;
@property (nonatomic, assign, getter=isContinuous) BOOL continuous;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, strong) UIColor *valueLabelTextColor;
- (void)setThumbColor:(UIColor *)thumbColor forState:(UIControlState)state;
- (void)setTrackFillColor:(UIColor *)fillColor forState:(UIControlState)state;
- (void)setTrackBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state;
- (void)setValue:(CGFloat)value animated:(BOOL)animated;
@end
