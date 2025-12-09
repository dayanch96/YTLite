#import <Foundation/Foundation.h>

@protocol YTCommonButton <NSObject>
@property (nonatomic, assign, readwrite) BOOL refreshRendererAfterPageStyling;
@property (nonatomic, assign, readwrite) CGFloat buttonImageTitlePadding;
@property (nonatomic, assign, readwrite) CGFloat minHitTargetSize;
@property (nonatomic, assign, readwrite) CGFloat verticalContentPadding;
@property (nonatomic, assign, readwrite) NSInteger buttonLayoutStyle;
- (void)setTitleTypeKind:(NSInteger)titleTypeKind;
- (void)setTitleTypeKind:(NSInteger)titleTypeKind typeVariant:(NSInteger)typeVariant;
@end
