#import <Foundation/Foundation.h>

#if __has_include(<roothide.h>)
#import <roothide.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface NSBundle (YTLite)

// Returns YTLite default bundle. Supports rootless if defined in compilation parameters
@property (class, nonatomic, readonly) NSBundle *ytl_defaultBundle;

@end

NS_ASSUME_NONNULL_END
