//
//  HBColorPickerSectionHeaderView.m
//  Alderis Demo
//
//  Created by Adam Demasi on 31/3/19.
//  Copyright © 2019 HASHBANG Productions. All rights reserved.
//

#import "HBColorPickerSectionHeaderView.h"
#import "CompactConstraint.h"

@implementation HBColorPickerSectionHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];

	if (self) {
		_titleLabel = [[UILabel alloc] init];
		_titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
		_titleLabel.font = [UIFont boldSystemFontOfSize:18.f];
		[self addSubview:_titleLabel];

		[self hb_addCompactConstraints:@[
																		 @"titleLabel.left = self.left + horizontalMargin",
																		 @"titleLabel.right = self.right - horizontalMargin",
																		 @"titleLabel.top = self.top + topMargin",
																		 @"titleLabel.bottom = self.bottom - bottomMargin"
																		 ]
													 metrics:@{
																		 @"horizontalMargin": @15.f,
																		 @"topMargin": @10.f,
																		 @"bottomMargin": @0.f
																		 }
														 views:@{
																		 @"self": self,
																		 @"titleLabel": _titleLabel
																		 }];
	}
	
	return self;
}

@end
