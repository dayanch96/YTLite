#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SponsorSegment : NSObject
@property (nonatomic, assign) CGFloat startTime;
@property (nonatomic, assign) CGFloat endTime;
@property (strong, nonatomic) NSString *category;
@property (strong, nonatomic) NSString *UUID;
- (instancetype)initWithStartTime:(CGFloat)startTime endTime:(CGFloat)endTime category:(NSString *)category UUID:(NSString *)UUID;
@end 
