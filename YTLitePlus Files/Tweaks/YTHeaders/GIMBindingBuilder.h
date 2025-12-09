#import <Foundation/Foundation.h>

@interface GIMBindingBuilder : NSObject
- (instancetype)bindType:(Class)typeClass;
- (instancetype)initializedWith:(id (^)(id))block;
@end