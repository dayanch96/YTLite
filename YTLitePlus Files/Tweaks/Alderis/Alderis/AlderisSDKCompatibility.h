//
//  AlderisSDKCompatibility.h
//  Alderis
//
//  Created by Adam Demasi on 3/10/20.
//  Copyright © 2020 HASHBANG Productions. All rights reserved.
//

@import UIKit;

#ifndef __IPHONE_14_0
// Allows building with the iOS 13 SDK while retaining iOS 14 compatibility.

@interface UIControl ()

- (void)addAction:(UIAction *)action forControlEvents:(UIControlEvents)controlEvents NS_SWIFT_NAME(addAction(_:for:)) API_AVAILABLE(ios(14.0));
- (void)removeAction:(UIAction *)action forControlEvents:(UIControlEvents)controlEvents NS_SWIFT_NAME(removeAction(_:for:)) API_AVAILABLE(ios(14.0));
- (void)removeActionForIdentifier:(UIActionIdentifier)actionIdentifier forControlEvents:(UIControlEvents)controlEvents NS_SWIFT_NAME(removeAction(identifiedBy:for:)) API_AVAILABLE(ios(14.0));

@end
#endif
