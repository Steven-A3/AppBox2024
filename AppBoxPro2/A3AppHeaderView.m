//
//  A3AppHeaderView.m
//  AppBoxPro2
//
//  Created by Byeong Kwon Kwak on 7/12/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "A3AppHeaderView.h"
#import "common.h"

@interface A3AppHeaderView ()
- (void)buildView;

@property(nonatomic, readonly) UIView *glossyLayeredView;

@end

@implementation A3AppHeaderView
@synthesize titleLabel = _titleLabel;
@synthesize title = _title;
@synthesize glossyLayeredView = _glossyLayeredView;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		[self buildView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self buildView];
	}

	return self;
}

- (void)awakeFromNib {
	[super awakeFromNib];

	if ([self.title length]) {
		self.titleLabel.text = self.title;
	}
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)buildView {
	[self setBackgroundColor:[UIColor scrollViewTexturedBackgroundColor]];

	CGRect bounds;
	bounds = self.layer.bounds;

	CALayer *darkGlossyLayer = [CALayer layer];
	darkGlossyLayer.bounds = bounds;
	darkGlossyLayer.anchorPoint = CGPointMake(0.0f, 0.0f);
	darkGlossyLayer.borderWidth = 0.5f;
	darkGlossyLayer.borderColor = [UIColor colorWithRed:66.0f/255.0f green:66.0f/255.0f blue:67.0f/255.0f alpha:1.0].CGColor;
	darkGlossyLayer.backgroundColor = [UIColor colorWithWhite:0.07f alpha:0.9].CGColor;

	CAGradientLayer *leftGradientLayer = [CAGradientLayer layer];
	leftGradientLayer.colors = 			[NSArray arrayWithObjects:
			(__bridge id)[UIColor colorWithRed:33.0f/255.0f green:33.0f/255.0f blue:34.0f/255.0f alpha:1.0f].CGColor,
			(__bridge id)[UIColor colorWithRed:29.0f/255.0f green:29.0f/255.0f blue:29.0f/255.0f alpha:1.0f].CGColor,
			nil];
	leftGradientLayer.anchorPoint = CGPointMake(0.0f, 0.0f);
	leftGradientLayer.bounds = CGRectMake(CGRectGetMinX(bounds), CGRectGetMinY(bounds), 4.0f, CGRectGetHeight(bounds) - 4.0f);
	leftGradientLayer.position = CGPointMake(0.0f, 4.0f);
	leftGradientLayer.startPoint = CGPointMake(0.0f, 0.5f);
	leftGradientLayer.endPoint = CGPointMake(1.0f, 0.5f);
	[darkGlossyLayer addSublayer:leftGradientLayer];

	CAGradientLayer *topGradientLayer = [CAGradientLayer layer];
	topGradientLayer.colors = [NSArray arrayWithObjects:
			(__bridge id)[UIColor colorWithRed:48.0f/255.0f green:48.0f/255.0f blue:48.0f/255.0f alpha:1.0f].CGColor,
			(__bridge id)[UIColor colorWithRed:24.0f/255.0f green:25.0f/255.0f blue:27.0f/255.0f alpha:1.0f].CGColor,
			nil];
	topGradientLayer.bounds = CGRectMake(CGRectGetMinX(bounds), CGRectGetMinY(bounds), CGRectGetWidth(bounds), 8.0f);
	topGradientLayer.anchorPoint = CGPointMake(0.0f, 0.0f);
	topGradientLayer.startPoint = CGPointMake(0.5f, 0.0f);
	topGradientLayer.endPoint = CGPointMake(0.5f, 1.0f);
	[darkGlossyLayer addSublayer:topGradientLayer];

	[self.glossyLayeredView.layer addSublayer:darkGlossyLayer];
}


- (UIView *)glossyLayeredView {
	if (nil == _glossyLayeredView) {
		_glossyLayeredView = [[UIView alloc] init];
		_glossyLayeredView.frame = self.bounds;
		_glossyLayeredView.backgroundColor = [UIColor clearColor];
		_glossyLayeredView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
		[self insertSubview:_glossyLayeredView atIndex:0];
	}
	return _glossyLayeredView;
}


- (void)layoutSubviews {
	[super layoutSubviews];

	FNLOG(@"Passed");
	CGRect bounds = self.glossyLayeredView.layer.bounds;
	NSArray *sublayers = [self.glossyLayeredView.layer sublayers];
	for (CALayer *sublayer in sublayers) {
		sublayer.bounds = bounds;
	}
}

- (UILabel *)titleLabel {
	if (!_titleLabel) {
		_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.bounds), CGRectGetMinY(self.bounds), CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))];
		_titleLabel.textColor = [UIColor colorWithRed:202.0f/255.0f green:202.0f/255.0f blue:202.0f/255.0f alpha:1.0f];
		_titleLabel.font = [UIFont boldSystemFontOfSize:22.0];
		_titleLabel.minimumFontSize = 8.0;
		_titleLabel.adjustsFontSizeToFitWidth = YES;
		_titleLabel.backgroundColor = [UIColor clearColor];
		_titleLabel.textAlignment = UITextAlignmentCenter;
		_titleLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
		[self addSubview:_titleLabel];
	}
	return _titleLabel;
}

@end
