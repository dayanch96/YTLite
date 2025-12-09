#import <UIKit/UIKit.h>

@interface GOOModalView : UIView
@property (nonatomic, readwrite, weak) id target;
@property (nonatomic, readwrite, assign) BOOL shouldDismissOnBackgroundTap;
@property (nonatomic, readwrite, assign) BOOL shouldDismissOnApplicationBackground;
- (instancetype)initWithTarget:(id)target;
- (void)addTitle:(NSString *)title withAction:(void (^)(void))action;
- (void)addTitle:(NSString *)title withCancelAction:(void (^)(void))action;
- (void)addTitle:(NSString *)title withDestructiveAction:(void (^)(void))action;
- (void)addTitle:(NSString *)title withSelector:(SEL)selector;
- (void)addTitle:(NSString *)title withCancelSelector:(SEL)cancelSelector;
- (void)addTitle:(NSString *)title withDestructiveSelector:(SEL)cancelSelector;
- (void)addTitle:(NSString *)title iconImage:(UIImage *)iconImage withAction:(void (^)(void))action;
- (void)addTitle:(NSString *)title iconImage:(UIImage *)iconImage withSelector:(SEL)selector;
- (void)show;
- (void)cancel;
- (void)dismiss;
@end
