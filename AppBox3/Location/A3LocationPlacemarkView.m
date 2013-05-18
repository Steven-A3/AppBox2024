//
//  A3LocationPlacemarkView.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 05/15/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3LocationPlacemarkView.h"
#import "A3PlacemarkBackgroundView.h"
#import "CommonUIDefinitions.h"

#define	A3LocationPlacemarkViewMargin	10.0

@implementation A3LocationPlacemarkView {
	A3PlacemarkBackgroundView *nameView, *addressView, *contactView;
}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		[self configureSubViews];
		self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
	}

	return self;
}

- (void)configureSubViews {
	CGSize size = [self sizeThatFits:CGSizeZero];

	CGRect bounds = self.bounds;
	bounds.size = size;
	CGRect frame = bounds;
	frame.origin.x += A3LocationPlacemarkViewMargin;
	frame.size.width -= A3LocationPlacemarkViewMargin * 2.0;
	frame.size.height = A3_NORMAL_ROW_HEIGHT;
	CGRect labelFrame = frame;
	labelFrame.origin.x += 5.0;
	labelFrame.size.width -= 10.0;

	nameView = [[A3PlacemarkBackgroundView alloc] initWithFrame:frame];
	[self addSubview:nameView];
	self.nameLabel.frame = labelFrame;
	[nameView addSubview:self.nameLabel];

	frame.origin.y += A3_NORMAL_ROW_HEIGHT + A3LocationPlacemarkViewMargin;
	frame.size.height = 70.0;
	addressView = [[A3PlacemarkBackgroundView alloc] initWithFrame:frame];
	[self addSubview:addressView];

	labelFrame.origin.y = 5.0;
	labelFrame.size.height = 20.0;
	self.addressLabel1.frame = labelFrame;
	[addressView addSubview:self.addressLabel1];

	labelFrame.origin.y += labelFrame.size.height;
	self.addressLabel2.frame = labelFrame;
	[addressView addSubview:self.addressLabel2];

	labelFrame.origin.y += labelFrame.size.height;
	self.addressLabel3.frame = labelFrame;
	[addressView addSubview:self.addressLabel3];

	frame.origin.y += frame.size.height - 1.0;
	frame.size.height = 34.0;
	contactView = [[A3PlacemarkBackgroundView alloc] initWithFrame:frame];
	[self addSubview:contactView];

	labelFrame.origin.y = 0.0;
	labelFrame.size.height = frame.size.height;
	self.contactLabel.frame = labelFrame;
	[contactView addSubview:self.contactLabel];
}

- (void)layoutSubviews {
	[super layoutSubviews];

	nameView.hidden = [self.nameLabel.text length] == 0;
	addressView.hidden = !([self.addressLabel1.text length] > 0 || [self.addressLabel2.text length] || [self.addressLabel2.text length]);
	contactView.hidden = [self.contactLabel.text length] == 0;
}

- (CGSize)sizeThatFits:(CGSize)size {
	return CGSizeMake(SIDE_VIEW_WIDTH, A3_NORMAL_ROW_HEIGHT + 10.0 + 70.0 + 34.0 + 10.0);	// Height = 168.0
}

- (UILabel *)newLabel {
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
	label.backgroundColor = [UIColor clearColor];
	return label;
}

- (UILabel *)nameLabel {
	if (nil == _nameLabel) {
		_nameLabel = [self newLabel];
		_nameLabel.font = [UIFont boldSystemFontOfSize:18.0];
		_nameLabel.textColor = [UIColor blackColor];
	}
	return _nameLabel;
}

- (UILabel *)newAddressLabel {
	UILabel *label = [self newLabel];
	label.font = [UIFont systemFontOfSize:14.0];
	label.textColor = [UIColor colorWithRed:115.0 / 255.0 green:115.0 / 255.0 blue:115.0 / 255.0 alpha:1.0];
	return label;
}
- (UILabel *)addressLabel1 {
	if (nil == _addressLabel1) {
		_addressLabel1 = [self newAddressLabel];
	}
	return _addressLabel1;
}

- (UILabel *)addressLabel2 {
	if (nil == _addressLabel2) {
		_addressLabel2 = [self newAddressLabel];
	}
	return _addressLabel2;
}

- (UILabel *)addressLabel3 {
	if (nil == _addressLabel3) {
		_addressLabel3 = [self newAddressLabel];
	}
	return _addressLabel3;
}

- (UILabel *)contactLabel {
	if (nil == _contactLabel) {
		_contactLabel = [self newAddressLabel];

	}
	return _contactLabel;
}

@end
