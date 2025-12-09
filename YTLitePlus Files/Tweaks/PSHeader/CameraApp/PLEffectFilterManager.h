#import <CoreImage/CoreImage.h>

NS_CLASS_DEPRECATED_IOS(7_0, 7_1)
@interface PLEffectFilterManager : NSObject

+ (instancetype)sharedInstance;

- (NSUInteger)blackAndWhiteFilterStartIndex;
- (NSUInteger)filterCount;

- (CIFilter *)filterForIndex:(NSUInteger)index;

- (void)_addEffectNamed:(NSString *)name aggdName:(NSString *)aggdName filter:(CIFilter *)filter;

@end
