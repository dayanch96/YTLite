#import <UIKit/UIKit.h>
#import "ASLayoutElementStyleYoga.h"

@interface ASDisplayNode : NSObject
@property (atomic, copy, readwrite) NSArray *yogaChildren;
@property (atomic, copy, readwrite) NSString *accessibilityIdentifier;
@property (atomic, copy, readwrite) UIColor *backgroundColor;
@property (atomic, weak) ASDisplayNode *yogaParent;
@property (atomic, strong, readwrite) id contents;
@property (atomic, assign, readwrite) CGFloat alpha;
@property (atomic, assign, readwrite) CGRect frame;
@property (atomic, assign, readwrite) CGRect bounds;
@property (atomic, assign, readonly) CGSize calculatedSize;
@property (atomic, assign, readonly) unsigned char interfaceState;
@property (atomic, assign, readwrite, getter=isHidden) BOOL hidden;
@property (atomic, assign, readwrite, getter=isLayerBacked) BOOL layerBacked;
@property (atomic, assign, readwrite) BOOL automaticallyManagesSubnodes;
- (id)controller; // Usually ELMNodeController
- (ASLayoutElementStyleYoga *)style;
- (UIViewController *)closestViewController;
- (UIView *)view;
- (BOOL)isNodeLoaded;
- (void)setNeedsLayout;
- (void)addSubnode:(id)subnode;
- (void)addYogaChild:(id)child;
@end
