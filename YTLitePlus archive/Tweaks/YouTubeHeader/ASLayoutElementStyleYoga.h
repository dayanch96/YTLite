#import <CoreGraphics/CGBase.h>
#import <Foundation/NSObject.h>

@interface ASLayoutElementStyleYoga : NSObject
@property (nonatomic, assign, readwrite) CGFloat spacingBefore;
@property (nonatomic, assign, readwrite) CGFloat spacingAfter;
@property (nonatomic, assign, readwrite) CGFloat flexGrow;
@property (nonatomic, assign, readwrite) CGFloat flexShrink;
@end
