//
//  A3QRCodeScanLineView.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 4/12/16.
//  Copyright © 2016 ALLABOUTAPPS. All rights reserved.
//

#import "A3QRCodeScanLineView.h"

@interface A3QRCodeScanLineView ()

@property (nonatomic, strong) UIView *topGreenLine;
@property (nonatomic, strong) CAGradientLayer *gradientLayer;

@end

@implementation A3QRCodeScanLineView

- (instancetype)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		[self setupSubviews];
	}

	return self;
}

- (void)setFrame:(CGRect)frame {
	[super setFrame:frame];

	_gradientLayer.bounds = self.bounds;
}

- (void)setBounds:(CGRect)bounds {
	[super setBounds:bounds];

	_gradientLayer.bounds = self.bounds;
}

- (void)setupSubviews {
	_topGreenLine = [UIView new];
	//98	253	48
	_topGreenLine.backgroundColor = [UIColor colorWithRed:98.0/255.0 green:253.0/255.0 blue:49.0/255.0 alpha:1.0];
	[self addSubview:_topGreenLine];

	[_topGreenLine makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(self.top);
		make.left.equalTo(self.left);
		make.right.equalTo(self.right);
		make.height.equalTo(@1.5);
	}];

	_gradientLayer = [CAGradientLayer layer];
	_gradientLayer.bounds = self.bounds;
	_gradientLayer.position = CGPointMake(0,0);
	_gradientLayer.anchorPoint = CGPointMake(0,0);
	_gradientLayer.startPoint = CGPointMake(0, 0);
	_gradientLayer.endPoint = CGPointMake(0, 1);
	_gradientLayer.locations = @[@0, @1];
	_gradientLayer.colors = @[
			(id)[UIColor colorWithRed:98.0/255.0 green:253.0/255.0 blue:49.0/255.0 alpha:0.5].CGColor,
			(id)[UIColor clearColor].CGColor
	];
	[self.layer addSublayer:_gradientLayer];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
