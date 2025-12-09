#import <Foundation/NSObject.h>

@protocol YTPageStyling <NSObject>
@required
- (void)pageStyleDidChange:(NSInteger)pageStyle;
@end
