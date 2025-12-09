#import <Foundation/Foundation.h>

@interface GPBMessage : NSObject
+ (id)parseFromData:(id)data;
+ (id)parseFromData:(id)data error:(NSError **)error;
- (id)firstSubmessage;
- (void)clear;
@end
