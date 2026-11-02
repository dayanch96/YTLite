#import <Foundation/Foundation.h>
#if __has_include(<roothide.h>)
#import <roothide.h>
#else
#ifndef THEOS_PACKAGE_INSTALL_PREFIX
#define THEOS_PACKAGE_INSTALL_PREFIX ""
#endif
#define jbroot(path) [@THEOS_PACKAGE_INSTALL_PREFIX stringByAppendingString:(path)]
#endif

NS_ASSUME_NONNULL_BEGIN

@interface NSBundle (YTLite)

@property (class, nonatomic, readonly) NSBundle *ytl_defaultBundle;

+ (NSString *)ytl_localizedStringForKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
