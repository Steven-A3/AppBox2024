//
//  A3CalcHistoryViewCell.m
//  AppBoxPro2
//
//  Created by Byeong Kwon Kwak on 7/28/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3CalcHistoryViewCell.h"
#import "common.h"
#import "A3Utilities.h"

@implementation A3CalcHistoryContentsView
@synthesize dateLabel = _dateLabel;
@synthesize resultLabel = _resultLabel;
@synthesize expressionView = _expressionView;

@end

@implementation A3CalcHistoryViewCell
@synthesize contentsView1 = _contentsView1;
@synthesize contentsView2 = _contentsView2;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	FNLOG(@"");

    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
		self.backgroundColor = [UIColor colorWithRed:245.0f/255.0f green:245.0f/255.0f blue:245.0f/255.0f alpha:1.0f];
		[self addSubview:self.contentsView1];
		[self addSubview:self.contentsView2];
	}
    return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	if (UserInterfacePortrait()) {
		CGFloat viewWidth = CGRectGetWidth(self.bounds)/2.0f;

		[self.contentsView1 setFrame:CGRectMake(CGRectGetMinX(self.bounds), CGRectGetMinY(self.bounds), viewWidth, CGRectGetHeight(self.bounds) - 1.0f )];

		[self.contentsView2 setHidden:NO];
		[self.contentsView2 setFrame:CGRectMake(viewWidth + 1.0f, CGRectGetMinY(self.bounds), viewWidth, CGRectGetHeight(self.bounds) - 1.0f)];
	} else {
		self.contentsView1.frame = CGRectMake(CGRectGetMinX(self.bounds), CGRectGetMinY(self.bounds), CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) - 1.0f);
		[self.contentsView2 setHidden:YES];
	}
}

static float pattern[] = {2.0f, 2.0f};

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];

	CGContextRef context;
	context = UIGraphicsGetCurrentContext();

	CGContextSetAllowsAntialiasing(context, false);

	// Drawing lines with a light gray stroke color
	CGContextSetRGBStrokeColor(context, 217.0f/255.0f, 217.0f/255.0f, 217.0f/255.0f, 1.0f);

	// Each dash entry is a run-length in the current coordinate system
	// The concept is first you determine how many points in the current system you need to fill.
	// Then you start consuming that many pixels in the dash pattern for each element of the pattern.
	// So for example, if you have a dash pattern of {10, 10}, then you will draw 10 points, then skip 10 points, and repeat.
	// As another example if your dash pattern is {10, 20, 30}, then you draw 10 points, skip 20 points, draw 30 points,
	// skip 10 points, draw 20 points, skip 30 points, and repeat.
	// The dash phase factors into this by stating how many points into the dash pattern to skip.
	// So given a dash pattern of {10, 10} with a phase of 5, you would draw 5 points (since phase plus 5 yields 10 points),
	// then skip 10, draw 10, skip 10, draw 10, etc.

	CGContextSetLineDash(context, 1.0f, pattern, 2);

	// Draw a horizontal line, vertical line, rectangle and circle for comparison
	CGContextMoveToPoint(context, CGRectGetMinX(self.bounds), CGRectGetMaxY(self.bounds));
	CGContextAddLineToPoint(context, CGRectGetMaxX(self.bounds), CGRectGetMaxY(self.bounds));

	if (UserInterfacePortrait()) {
		CGFloat location_X = CGRectGetWidth(self.bounds)/2.0;
		CGContextMoveToPoint(context, location_X, CGRectGetMinY(self.bounds));
		CGContextAddLineToPoint(context, location_X, CGRectGetMaxX(self.bounds));
	}
	CGContextSetLineWidth(context, 1.0f);
	CGContextStrokePath(context);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
	[super setSelected:selected animated:animated];

	// Configure the view for the selected state
}

- (A3CalcHistoryContentsView *)contentsView1 {
	if (nil == _contentsView1) {
		NSArray *viewArray = [[NSBundle mainBundle] loadNibNamed:@"A3CalcHistoryViewCellContentsView" owner:self options:nil];
		for (id view in viewArray) {
			if ([view isKindOfClass:[A3CalcHistoryContentsView class]]) {
				_contentsView1 = view;
				[_contentsView1.expressionView setStyle:CEV_TRANSPARENT_BACKGROUND];
				[_contentsView1.expressionView setExpression:[NSArray arrayWithObjects:@"36,000,000,000", @"x",@"1000", @"=", nil]];
			}
		}
	}
	return _contentsView1;
}

- (A3CalcHistoryContentsView *)contentsView2 {
	if (nil == _contentsView2) {
		NSArray *viewArray = [[NSBundle mainBundle] loadNibNamed:@"A3CalcHistoryViewCellContentsView" owner:self options:nil];
		for (id view in viewArray) {

			if ([view isKindOfClass:[A3CalcHistoryContentsView class]]) {
				_contentsView2 = view;
				[_contentsView2.expressionView setStyle:CEV_TRANSPARENT_BACKGROUND];
				[_contentsView2.expressionView setExpression:[NSArray arrayWithObjects:@"36,000,000,000", @"x",@"1000", @"=", nil]];
			}
		}
	}
	return _contentsView2;
}

@end
