#import <Foundation/NSURL.h>
#import <UIKit/UIImage.h>

@interface UIImage (YouTube)
+ (UIImage *)imageWithContentsOfURL:(NSURL *)URL cachePolicy:(NSURLRequestCachePolicy)cachePolicy error:(NSError **)error;
- (instancetype)yt_imageScaledToSize:(CGSize)size;
@end
