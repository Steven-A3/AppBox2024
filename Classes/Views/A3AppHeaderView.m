//
//  A3AppHeaderView.m
//  AppBoxPro2
//
//  Created by Byeong Kwon Kwak on 7/12/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3AppHeaderView.h"
#import "A3Utilities.h"

@interface A3AppHeaderView ()
- (void)buildView;

@end

@implementation A3AppHeaderView
@synthesize titleLabel = _titleLabel;
@synthesize title = _title;


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

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
	CGContextRef context = UIGraphicsGetCurrentContext();

	CGContextSetRGBStrokeColor(context, 66.0f/255.0f, 66.0f/255.0f, 67.0f/255.0f, 1.0f);
	CGContextAddRect(context, rect);
	CGContextStrokePath(context);

	CGContextSetRGBFillColor(context, 0.0f, 0.0f, 0.0f, 0.8f);
	CGContextAddRect(context, rect);
	CGContextFillPath(context);

	NSArray *leftColors = [NSArray arrayWithObjects:
			(__bridge id)[UIColor colorWithRed:33.0f/255.0f green:33.0f/255.0f blue:34.0f/255.0f alpha:1.0f].CGColor,
			(__bridge id)[UIColor colorWithRed:29.0f/255.0f green:29.0f/255.0f blue:29.0f/255.0f alpha:1.0f].CGColor,
			nil];
	drawLinearGradient(context, CGRectMake(CGRectGetMinX(rect), CGRectGetMinY(rect), 4.0f, CGRectGetHeight(rect) - 4.0f), leftColors);

	NSArray *colors = [NSArray arrayWithObjects:
			(__bridge id)[UIColor colorWithRed:48.0f/255.0f green:48.0f/255.0f blue:48.0f/255.0f alpha:1.0f].CGColor,
			(__bridge id)[UIColor colorWithRed:24.0f/255.0f green:25.0f/255.0f blue:27.0f/255.0f alpha:1.0f].CGColor,
			nil];
	drawLinearGradient(context, CGRectMake(CGRectGetMinX(rect), CGRectGetMinY(rect), CGRectGetWidth(rect), 8.0f), colors);
}

- (void)buildView {
	[self setBackgroundColor:[UIColor scrollViewTexturedBackgroundColor]];
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
