#import "Headers/SponsorSegment.h"

@implementation SponsorSegment
- (instancetype)initWithStartTime:(CGFloat)startTime endTime:(CGFloat)endTime category:(NSString *)category UUID:(NSString *)UUID {
    self = [super init];
    if (self) {
        self.startTime = startTime;
        self.endTime = endTime;
        self.category = category;
        self.UUID = UUID;
    }
    return self;
}
- (void)setEndTime:(CGFloat)endTime {
    if (endTime < self.startTime) {
        _endTime = -1;
        return;
    }
    _endTime = endTime;
}
@end
