#import "_PLManagedAsset.h"

@interface PLManagedAsset : _PLManagedAsset
@property (readonly, nonatomic) NSString *pathForImageFile;
@property (readonly, nonatomic) NSString *pathForOriginalFile;
@property (readonly, nonatomic) NSString *pathForAdjustmentFile;
@property short kindSubtype;
@property short savedAssetType;
@property BOOL hasAdjustments;
- (BOOL)isMogul NS_AVAILABLE_IOS(7_0);
- (BOOL)isVideo;
@end
