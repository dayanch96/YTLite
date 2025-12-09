//
//  SpringBoard.xm
//  FLEXing
//  
//  Created by Tanner Bennett on 2019-11-25
//  Copyright © 2019 Tanner Bennett. All rights reserved.
//

//-------------------------------//
// This file is for iOS 13+ only //
//    Credit:  DGh0st/FLEXall    //
//-------------------------------//

#import "Interfaces.h"

%group iOS13StatusBar
// Runs in SpringBoard; forwards status bar events to app
%hook SBMainDisplaySceneLayoutStatusBarView
- (void)_addStatusBarIfNeeded {
	%orig;

	UIView *statusBar = [self valueForKey:@"_statusBar"];
	[statusBar addGestureRecognizer:[[UILongPressGestureRecognizer alloc]
        initWithTarget:self action:@selector(flexGestureHandler:)
    ]];
}

%new(v@:@)
- (void)flexGestureHandler:(UILongPressGestureRecognizer *)recognizer {
	if (recognizer.state == UIGestureRecognizerStateBegan) {
		[self _statusBarTapped:recognizer type:kFLEXLongPressGesture];
	}
}
%end // SBMainDisplaySceneLayoutStatusBarView

// Runs in apps; receives status bar events
%hook UIStatusBarManager
- (void)handleTapAction:(UIStatusBarTapAction *)action {
    if (action.type == kFLEXLongPressGesture) {
        [manager performSelector:show];
    } else {
        %orig(action);
    }
}
%end // UIStatusBarManager
%end // iOS13StatusBar

#if TARGET_OS_SIMULATOR
%hook SpringBoard
- (void)applicationDidFinishLaunching:(id)arg {
    %orig;
    [manager performSelector:show];
}
%end
#endif

%ctor {
    if (@available(iOS 13, *)) {
        %init(iOS13StatusBar);
    }
#if TARGET_OS_SIMULATOR
    %init;
#endif
}
