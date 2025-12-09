//
//  HBColorPickerSwatchCell.m
//  Alderis Demo
//
//  Created by Adam Demasi on 4/3/19.
//  Copyright © 2019 HASHBANG Productions. All rights reserved.
//

#import "HBColorPickerSwatchCell.h"

@implementation HBColorPickerSwatchCell

- (instancetype)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	
	if (self) {
		self.clipsToBounds = YES;
//		self.layer.cornerRadius = 22.f;
//		self.layer.borderColor = [UIColor grayColor].CGColor;
	}
	
	return self;
}

- (void)didMoveToWindow {
	[super didMoveToWindow];

//	CGFloat scale = self.window.screen.scale ?: 1.f;
//	self.layer.borderWidth = scale > 2.f ? 2.f / scale : 1.f / scale;
}

@end
