//
//  libFLEX.m
//  libflex
//  
//  Created by Tanner Bennett on 2019-08-16
//  Copyright © 2019 Tanner Bennett. All rights reserved.
//

#import "libFLEX.h"
#import "FLEXWindow.h"
#import "FLEXManager.h"

id FLXGetManager() {
	return [FLEXManager sharedManager];
}

SEL FLXRevealSEL() {
	return @selector(showExplorer);
}

Class FLXWindowClass() {
	return [FLEXWindow class];
}
