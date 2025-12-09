#import <Foundation/Foundation.h>

@interface HAMAsyncVTVideoDecoder : NSObject
- (instancetype)initWithDelegate:(id)delegate delegateQueue:(id)delegateQueue decodeQueue:(id)decodeQueue formatDescription:(id)formatDescription pixelBufferAttributes:(id)pixelBufferAttributes;
@end
