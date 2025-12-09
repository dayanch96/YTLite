#import <Foundation/NSObject.h>

@protocol YTResponder <NSObject>
@required
- (id)parentResponder;
@end
