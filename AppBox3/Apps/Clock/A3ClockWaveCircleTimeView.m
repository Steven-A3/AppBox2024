//
//  A3ClockWaveCircleTimeView.m
//  A3TeamWork
//
//  Created by Sanghyun Yu on 2013. 11. 21..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3ClockWaveCircleTimeView.h"
#import "NSUserDefaults+A3Defaults.h"


@interface A3ClockWaveCircleTimeView ()

@property (nonatomic, strong) UIView *upperLeftCircle, *upperRightCircle, *lowerLeftCircle, *lowerRightCircle;
@property (nonatomic, strong) UIView *upperCircle, *lowerCircle;

@end

@implementation A3ClockWaveCircleTimeView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.nLineWidth = 2;


    }
    return self;
}

- (void)setBounds:(CGRect)bounds {
	[super setBounds:bounds];

	self.layer.cornerRadius = bounds.size.width * 0.5f;

	if (self.isShowWave) {
		[self setFillPercent:self.fillPercent];
	} else {
		self.textLabelCenterY.offset(bounds.size.height / 2);
		[self.textLabel setTextColor:self.superview.backgroundColor];
	}

	[self layoutIfNeeded];
}

- (void)addColonView {
	[_upperLeftCircle removeFromSuperview]; _upperLeftCircle = nil;
	[_lowerLeftCircle removeFromSuperview]; _lowerLeftCircle = nil;
	[_upperRightCircle removeFromSuperview]; _upperRightCircle = nil;
	[_lowerRightCircle removeFromSuperview]; _lowerRightCircle = nil;
	[_upperCircle removeFromSuperview]; _upperCircle = nil;
	[_lowerCircle removeFromSuperview]; _lowerCircle = nil;
	[self.colonView removeFromSuperview]; self.colonView = nil;


	self.colonView = [UIView new];
	BOOL showSeconds = [[NSUserDefaults standardUserDefaults] clockTheTimeWithSeconds];
	if (showSeconds) {
		_upperLeftCircle = [UIView new];
		[self.colonView addSubview:_upperLeftCircle];

		_lowerLeftCircle = [UIView new];
		[self.colonView addSubview:_lowerLeftCircle];

		_upperRightCircle = [UIView new];
		[self.colonView addSubview:_upperRightCircle];

		_lowerRightCircle = [UIView new];
		[self.colonView addSubview:_lowerRightCircle];
	} else {
		_upperCircle = [UIView new];
		[self.colonView addSubview:_upperCircle];

		_lowerCircle = [UIView new];
		[self.colonView addSubview:_lowerCircle];
	}

	[self.textLabel addSubview:self.colonView];

	[self setNeedsUpdateConstraints];
}

- (void)updateConstraints {
	[super updateConstraints];

	BOOL showSeconds = [[NSUserDefaults standardUserDefaults] clockTheTimeWithSeconds];
	BOOL bigCircle = self.position == ClockWaveLocationBig;

	CGFloat cornerRadius;
	CGFloat width;
	if (bigCircle) {
		width = 3;
		cornerRadius = width / 2;
	} else {
		width = 1;
		cornerRadius = width / 2;
	}

	[self.colonView removeConstraints:self.colonView.constraints];

	if (showSeconds) {
		_upperLeftCircle.layer.cornerRadius = cornerRadius;
		_lowerLeftCircle.layer.cornerRadius = cornerRadius;
		_upperRightCircle.layer.cornerRadius = cornerRadius;
		_lowerRightCircle.layer.cornerRadius = cornerRadius;

		[_upperLeftCircle removeConstraints:_upperLeftCircle.constraints];
		[_lowerLeftCircle removeConstraints:_lowerLeftCircle.constraints];
		[_upperRightCircle removeConstraints:_upperRightCircle.constraints];
		[_lowerRightCircle removeConstraints:_lowerRightCircle.constraints];

		[_upperLeftCircle makeConstraints:^(MASConstraintMaker *make) {
			make.left.equalTo(self.colonView.left);
			make.top.equalTo(self.colonView.top);
			make.width.equalTo(@(width));
			make.height.equalTo(@(width));
		}];

		[_lowerLeftCircle makeConstraints:^(MASConstraintMaker *make) {
			make.left.equalTo(self.colonView.left);
			make.bottom.equalTo(self.colonView.bottom);
			make.width.equalTo(@(width));
			make.height.equalTo(@(width));
		}];

		[_upperRightCircle makeConstraints:^(MASConstraintMaker *make) {
			make.right.equalTo(self.colonView.right);
			make.top.equalTo(self.colonView.top);
			make.width.equalTo(@(width));
			make.height.equalTo(@(width));
		}];

		[_lowerRightCircle makeConstraints:^(MASConstraintMaker *make) {
			make.right.equalTo(self.colonView.right);
			make.bottom.equalTo(self.colonView.bottom);
			make.width.equalTo(@(width));
			make.height.equalTo(@(width));
		}];
	} else {
		_upperCircle.layer.cornerRadius = cornerRadius;
		_lowerCircle.layer.cornerRadius = cornerRadius;

		[_upperCircle removeConstraints:_upperCircle.constraints];
		[_lowerCircle removeConstraints:_lowerCircle.constraints];

		[_upperCircle makeConstraints:^(MASConstraintMaker *make) {
			make.centerX.equalTo(self.colonView.centerX);
			make.top.equalTo(self.colonView.top);
			make.width.equalTo(@(width));
			make.height.equalTo(@(width));
		}];

		[_lowerCircle makeConstraints:^(MASConstraintMaker *make) {
			make.centerX.equalTo(self.colonView.centerX);
			make.bottom.equalTo(self.colonView.bottom);
			make.width.equalTo(@(width));
			make.height.equalTo(@(width));
		}];
	}

	[self.colonView makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(self.textLabel.centerX).with.offset(-1);
		make.centerY.equalTo(self.textLabel.centerY).with.offset(bigCircle ? 3 : 0);
		if (self.position == ClockWaveLocationBig) {
			make.width.equalTo(showSeconds ? @94 : @(width));
			make.height.equalTo(showSeconds ? @35 : @49);
		} else {
			make.width.equalTo(showSeconds ? @19 : @(width));
			make.height.equalTo(showSeconds ? @7 : @10);
		}
	}];
}


- (void)setColonColor:(UIColor *)color {
	for (UIView *dot in self.colonView.subviews) {
		dot.backgroundColor = color;
	}
}

@end
