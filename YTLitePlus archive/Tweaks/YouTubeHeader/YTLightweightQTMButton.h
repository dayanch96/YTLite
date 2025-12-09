#import <UIKit/UIButton.h>

@interface YTLightweightQTMButton : UIButton
@property (nonatomic, assign, readwrite, getter=isUppercaseTitle) BOOL uppercaseTitle;
@property (nonatomic, assign, readwrite) BOOL flatButtonHasOpaqueBackground;
@property (nonatomic, strong, readwrite) UIColor *customTitleColor;
@property (nonatomic, strong, readwrite) UIColor *enabledBackgroundColor;
@end
