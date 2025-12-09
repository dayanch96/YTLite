#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "YTRollingDigit.h"

@interface YTRollingDigitView : UIView
@property (nonatomic, strong, readwrite) NSMutableArray <YTRollingDigit *> *digits;
- (NSString *)text;
@end
