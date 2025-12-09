#import <Foundation/NSObject.h>

@protocol MLPlayerDelegate <NSObject>
- (void)playerRateDidChange:(float)rate;
@end
