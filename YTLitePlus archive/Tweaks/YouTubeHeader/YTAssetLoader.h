#import <Foundation/NSObject.h>

@interface YTAssetLoader : NSObject
- (instancetype)initWithBundle:(NSBundle *)bundle;
- (UIImage *)imageNamed:(NSString *)image;
@end
