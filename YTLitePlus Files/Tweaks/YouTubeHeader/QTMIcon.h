#import <UIKit/UIKit.h>

@interface QTMIcon : NSObject
+ (UIImage *)imageWithName:(NSString *)name color:(UIColor *)color;
+ (UIImage *)tintImage:(UIImage *)image color:(UIColor *)color;
@end
