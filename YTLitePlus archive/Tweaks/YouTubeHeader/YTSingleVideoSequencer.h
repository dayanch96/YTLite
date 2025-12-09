#import <Foundation/NSObject.h>

@interface YTSingleVideoSequencer : NSObject
- (void)restartContentSequenceWithSeekSource:(int)seekSource;
- (void)restartContentSequence;
@end
