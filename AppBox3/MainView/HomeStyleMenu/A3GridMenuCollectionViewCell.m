//
//  A3GridMenuCollectionViewCell.m
//  HexagonMenu
//
//  Created by Byeong Kwon Kwak on 2/20/16.
//  Copyright © 2016 ALLABOUTAPPS. All rights reserved.
//

#import "A3GridMenuCollectionViewCell.h"

@interface A3GridMenuCollectionViewCell ()

@property (nonatomic, strong) UIView *roundedRectView;
@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation A3GridMenuCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
	if ((self = [super initWithFrame:frame])) {
		[self setupSubviews];
	}
	return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
	if ((self = [super initWithCoder:coder])) {
		[self setupSubviews];
	}
	return self;
}

- (void)setupSubviews {
	if (!_roundedRectView) {
		_roundedRectView = [UIView new];
		_roundedRectView.layer.cornerRadius = 15.0;
		_roundedRectView.layer.borderWidth = 3.0;
		[self addSubview:_roundedRectView];

		[_roundedRectView makeConstraints:^(MASConstraintMaker *make) {
			make.left.equalTo(self.left);
			make.top.equalTo(self.top);
			make.right.equalTo(self.right);
			make.height.equalTo(self.width);
		}];

		_imageView = [UIImageView new];
		[_roundedRectView addSubview:_imageView];

		[_imageView makeConstraints:^(MASConstraintMaker *make) {
			make.centerX.equalTo(_roundedRectView.centerX);
			make.centerY.equalTo(_roundedRectView.centerY);
		}];

		_titleLabel = [UILabel new];
		_titleLabel.textColor = [UIColor whiteColor];
		_titleLabel.font = [UIFont systemFontOfSize:13];
		_titleLabel.textAlignment = NSTextAlignmentCenter;
		_titleLabel.text = @"Unassigned";
		[self addSubview:_titleLabel];

		[_titleLabel makeConstraints:^(MASConstraintMaker *make) {
			make.centerX.equalTo(self.centerX);
			make.bottom.equalTo(self.bottom);
		}];
	}
}

- (void)setBorderColor:(UIColor *)borderColor {
	_borderColor = [borderColor copy];

	_roundedRectView.layer.borderColor = borderColor.CGColor;
	CGFloat red, green, blue, alpha;
	[borderColor getRed:&red green:&green blue:&blue alpha:&alpha];
	_roundedRectView.backgroundColor = [UIColor colorWithRed:red green:green blue:blue alpha:0.6];
}

- (void)setImageName:(NSString *)imageName {
	_imageName = [imageName copy];

	_imageView.image = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
	_imageView.tintColor = [UIColor colorWithWhite:1.0 alpha:0.8];
}

@end
