#import <Foundation/Foundation.h>

@protocol MLStreamSelectorDelegate <NSObject>
@required
- (void)streamSelectorHasSelectableAudioFormats:(NSArray *)formats;
- (void)streamSelectorHasSelectableVideoFormats:(NSArray *)formats;
@end
