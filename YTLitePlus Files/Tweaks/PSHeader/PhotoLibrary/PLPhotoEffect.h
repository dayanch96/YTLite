NS_CLASS_AVAILABLE_IOS(8_0)
@interface PLPhotoEffect : NSObject
+ (NSArray<PLPhotoEffect *> *)allEffects;
+ (instancetype)_effectWithIdentifier:(NSString *)identifier CIFilterName:(NSString *)filterName displayName:(NSString *)displayName;
+ (instancetype)_effectWithIdentifier:(NSString *)identifier;
+ (instancetype)_effectWithCIFilterName:(NSString *)identifier;
+ (NSUInteger)indexOfEffectWithIdentifier:(NSString *)identifier;
- (NSString *)displayName;
- (NSString *)filterIdentifier;
- (NSString *)CIFilterName;
@end
