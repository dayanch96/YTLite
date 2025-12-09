#import <UIKit/UIKit.h>

NS_CLASS_AVAILABLE_IOS(7_0)
@interface CAMElapsedTimeView : UIView
@property (readonly) UILabel *_timeLabel;
@property (readonly) UIImageView *_recordingImageView;
@property (readonly) NSTimer *_updateTimer;
@property (readonly) NSDate *_startTime;
- (void)_beginRecordingAnimation;
- (void)_endRecordingAnimation;
- (void)startTimer;
- (void)endTimer;
- (void)resetTimer;
- (void)_update:(NSTimer *)timer;
- (BOOL)usingBadgeAppearance;
- (UIColor *)_backgroundRedColor;
@end
