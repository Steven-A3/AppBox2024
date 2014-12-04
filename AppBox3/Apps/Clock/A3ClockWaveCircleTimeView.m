//
//  A3ClockWaveCircleTimeView.m
//  A3TeamWork
//
//  Created by Sanghyun Yu on 2013. 11. 21..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3ClockWaveCircleTimeView.h"
#import "A3UserDefaults+A3Defaults.h"


@interface A3ClockWaveCircleTimeView ()

@property (nonatomic, strong) UIView *upperLeftCircle, *upperRightCircle, *lowerLeftCircle, *lowerRightCircle;
@property (nonatomic, strong) UIView *upperCircle, *lowerCircle;

@end

@implementation A3ClockWaveCircleTimeView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.lineWidth = 2;


    }
    return self;
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
	BOOL showSeconds = [[A3UserDefaults standardUserDefaults] clockTheTimeWithSeconds];
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

	[self addSubview:self.colonView];

	[self setNeedsUpdateConstraints];
}

- (void)updateConstraints {
	[super updateConstraints];

	BOOL showSeconds = [[A3UserDefaults standardUserDefaults] clockTheTimeWithSeconds];
	BOOL bigCircle = self.position == ClockWaveLocationBig;

	CGFloat cornerRadius;
	CGFloat width;
	if (bigCircle) {
		width = IS_IPHONE ? 3 : 7;
		cornerRadius = width / 2;
	} else {
		width = IS_IPHONE ? 1 : 2;
		cornerRadius = width / 2;
	}

	if (showSeconds) {
		_upperLeftCircle.layer.cornerRadius = cornerRadius;
		_lowerLeftCircle.layer.cornerRadius = cornerRadius;
		_upperRightCircle.layer.cornerRadius = cornerRadius;
		_lowerRightCircle.layer.cornerRadius = cornerRadius;

		[_upperLeftCircle remakeConstraints:^(MASConstraintMaker *make) {
			make.left.equalTo(self.colonView.left);
			make.top.equalTo(self.colonView.top);
			make.width.equalTo(@(width));
			make.height.equalTo(@(width));
		}];

		[_lowerLeftCircle remakeConstraints:^(MASConstraintMaker *make) {
			make.left.equalTo(self.colonView.left);
			make.bottom.equalTo(self.colonView.bottom);
			make.width.equalTo(@(width));
			make.height.equalTo(@(width));
		}];

		[_upperRightCircle remakeConstraints:^(MASConstraintMaker *make) {
			make.right.equalTo(self.colonView.right);
			make.top.equalTo(self.colonView.top);
			make.width.equalTo(@(width));
			make.height.equalTo(@(width));
		}];

		[_lowerRightCircle remakeConstraints:^(MASConstraintMaker *make) {
			make.right.equalTo(self.colonView.right);
			make.bottom.equalTo(self.colonView.bottom);
			make.width.equalTo(@(width));
			make.height.equalTo(@(width));
		}];
	} else {
		_upperCircle.layer.cornerRadius = cornerRadius;
		_lowerCircle.layer.cornerRadius = cornerRadius;

		[_upperCircle remakeConstraints:^(MASConstraintMaker *make) {
			make.centerX.equalTo(self.colonView.centerX);
			make.top.equalTo(self.colonView.top);
			make.width.equalTo(@(width));
			make.height.equalTo(@(width));
		}];

		[_lowerCircle remakeConstraints:^(MASConstraintMaker *make) {
			make.centerX.equalTo(self.colonView.centerX);
			make.bottom.equalTo(self.colonView.bottom);
			make.width.equalTo(@(width));
			make.height.equalTo(@(width));
		}];
	}

	[self.colonView remakeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(self.centerX);
		self.colonViewCenterY = make.centerY.equalTo(self.top).with.offset(self.frame.size.height / 2);
		if (self.position == ClockWaveLocationBig) {
			make.width.equalTo(showSeconds ? (IS_IPHONE ? @94 : @187) : @(width));
			make.height.equalTo(showSeconds ? (IS_IPHONE ? @35 : @78) : (IS_IPHONE ? @49: @110));
		} else {
			make.width.equalTo(showSeconds ? (IS_IPHONE ? @19 : @35) : @(width));
			make.height.equalTo(showSeconds ? (IS_IPHONE ? @7 : @13) : (IS_IPHONE ? @10 : @17));
		}
	}];
}

- (void)setColonColor:(UIColor *)color {
	for (UIView *dot in self.colonView.subviews) {
		dot.backgroundColor = color;
	}
}

@end
