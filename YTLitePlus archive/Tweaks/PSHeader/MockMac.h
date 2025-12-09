#if TARGET_OS_OSX

typedef NSInteger UIImageOrientation;

@protocol UITextInputTraits
@end

@protocol UITableViewDataSource
@end

@protocol UITableViewDelegate
@end

@protocol UIScrollViewDelegate
@end

@interface UIViewController : NSObject
@end

@interface UIResponder : NSObject
@end

@interface UIColor : NSObject
@end

@interface UIView : UIResponder
@end

@interface UITableView : UIView
@end

@interface UISlider : UIView
@end

@interface UILabel : UIView
@end

@interface UIButton : UIView
@end

@interface UIToolbar : NSObject
@end

@interface UIImage : UIView
@end

@interface UIImageView : UIView
@end

@interface UICollectionView : UIView
@end

@interface UICollectionViewCell : UIView
@end

@interface UIPageControl : NSObject
@end

#endif