#import <CoreImage/CoreImage.h>

NS_CLASS_AVAILABLE_IOS(5_0)
@interface PLEditPhotoController : UIViewController <UIActionSheetDelegate>

@property (readonly) CGRect normalizedCropRect;

- (UINavigationItem *)navigationItem;
- (CIImage *)_newCIImageFromUIImage:(UIImage *)image;
- (NSArray *)_currentNonGeometryFiltersWithEffectFilters:(NSArray *)filters;
- (NSArray *)_cropAndStraightenFiltersForImageSize:(CGSize)size forceSquareCrop:(BOOL)crop forceUseGeometry:(BOOL)geometry;

- (void)_setControlsEnabled:(BOOL)enabled animated:(BOOL)animated;
- (void)_presentSavingHUD;
- (void)_dismissSavingHUD;
- (void)save:(UIBarButtonItem *)item;
- (void)cancel:(UIBarButtonItem *)item;
- (void)saveAdjustments;
@end
