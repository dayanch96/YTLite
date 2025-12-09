#import "MLStreamSelectorDelegate.h"

@interface MLStreamSelector : NSObject
@property (nonatomic, weak, readwrite) id <MLStreamSelectorDelegate> delegate;
@end
