#import <Foundation/Foundation.h>
#import <roothide.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSBundle (YTLite)

@property (class, nonatomic, readonly) NSBundle *ytl_defaultBundle;

+ (NSString *)ytl_localizedStringForKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
