#import <Foundation/Foundation.h>

@protocol YTPlainLabel <NSObject>
@property (nonatomic, readwrite, assign) NSInteger numberOfLines;
@property (nonatomic, readwrite, assign) NSInteger lineBreakMode;
@property (nonatomic, readwrite, assign) NSInteger textAlignment;
- (void)setTypeKind:(NSInteger)typeKind;
- (void)setTypeKind:(NSInteger)typeKind typeVariant:(NSInteger)typeVariant;
@end
