#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

API_AVAILABLE(ios(7.0))
@interface CAMModeDialItem : UIView
@property (nonatomic, copy, readwrite) NSString *title;
- (BOOL)isSelected;
- (CAShapeLayer *)_scalableTextLayer;
@end
