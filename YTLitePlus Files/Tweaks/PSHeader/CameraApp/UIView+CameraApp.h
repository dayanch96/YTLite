NS_CLASS_AVAILABLE_IOS(8_0)
@interface UIView (CameraUI)
- (void)cam_setHidden:(BOOL)hidden animated:(BOOL)animated;
- (void)cam_ensureSubview:(UIView *)view;
@end

NS_CLASS_AVAILABLE_IOS(8_0)
@interface UIView (PhotoLibrary)
- (void)pl_setHidden:(BOOL)hidden animated:(BOOL)animated;
@end