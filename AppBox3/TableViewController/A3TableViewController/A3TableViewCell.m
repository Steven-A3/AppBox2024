//
//  A3TableViewCell.m
//  AppBox3
//
//  Created by A3 on 11/2/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3TableViewCell.h"
#import "A3UIDevice.h"

@interface A3TableViewCell ()
@property (nonatomic, strong) MASConstraint *separatorLeft;
@end

@implementation A3TableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
		// Initialization code
		_customSeparator = [UIView new];
		_customSeparator.backgroundColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0];
		[self addSubview:_customSeparator];

		[_customSeparator makeConstraints:^(MASConstraintMaker *make) {
			_separatorLeft = make.left.equalTo(self.left).with.offset(0);
			make.right.equalTo(self.right);
			make.bottom.equalTo(self.bottom);
			make.height.equalTo(IS_RETINA ? @0.5 : @1.0);
		}];
		self.textLabel.font = [UIFont systemFontOfSize:17];
	}
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
	[super layoutSubviews];

	CGRect frame = self.textLabel.frame;
	frame.origin.x = self.contentInset;
	self.textLabel.frame = frame;
	
	frame = self.imageView.frame;
	frame.origin.x = IS_IPHONE ? ([[UIScreen mainScreen] scale] > 2 ? 20 : 15) : 28;
	self.imageView.frame = frame;
}

- (void)prepareForReuse {
	[super prepareForReuse];

	self.imageView.image = nil;

	[self setBottomSeparatorForMiddleRow];
	[_customTopSeparator removeFromSuperview];
	_customTopSeparator = nil;
}

- (void)showTopSeparator {
	if (!_customTopSeparator) {
		_customTopSeparator = [UIView new];
		_customTopSeparator.backgroundColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0];
		[self addSubview:_customTopSeparator];

		[_customTopSeparator makeConstraints:^(MASConstraintMaker *make) {
			make.left.equalTo(self.left);
			make.right.equalTo(self.right);
			make.top.equalTo(self.top);
			make.height.equalTo(IS_RETINA ? @0.5 : @1.0);
		}];
	}
}

- (void)setBottomSeparatorForBottomRow {
	_separatorLeft.offset(0);
	[self layoutIfNeeded];
}

- (void)setBottomSeparatorForMiddleRow {
	_separatorLeft.offset(self.contentInset);
	[self layoutIfNeeded];
}

- (void)setBottomSeparatorForExpandableBottom {
	_separatorLeft.offset(IS_IPHONE ? ([[UIScreen mainScreen] scale] > 2 ? 20 : 15) : 28);
	[self layoutIfNeeded];
}

- (CGFloat)contentInset {
	CGFloat inset = IS_IPHONE ? ([[UIScreen mainScreen] scale] > 2 ? 20 : 15) : 28;
	inset += self.imageView.image ? self.imageView.image.size.width + inset : 0;
	return inset;
}

@end
