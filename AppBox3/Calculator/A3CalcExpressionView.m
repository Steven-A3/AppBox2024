//
//  A3CalcExpressionView.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 7/23/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import "A3CalcExpressionView.h"
#import "common.h"


@interface A3CalcExpressionView ()

@end

@implementation A3CalcExpressionView
@synthesize expression = _expression;
@synthesize style = _style;

- (void)initialize {
	self.backgroundColor = [UIColor clearColor];
}

- (id)initWithFrame:(CGRect)frame
{
	FNLOG(@"initWithFrame");

    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		[self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	FNLOG(@"initWithCoder");

	self = [super initWithCoder:aDecoder];
	if (self) {
		[self initialize];
	}

	return self;
}



- (BOOL)isStringMatchForPattern:(NSString *)pattern withString:(NSString *)string {
	NSError *error = NULL;
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
	NSRange range = [regex rangeOfFirstMatchInString:string options:0 range:NSMakeRange(0, [string length])];
	if (!NSEqualRanges(range, NSMakeRange(NSNotFound, 0))) {
		return YES;
	}
	return NO;
}

#define	CEV_REGEX_FLOAT_PATTERN			@"[-+]?((\\.[0-9]+|[0-9]+\\.[0-9]+)([eE][-+][0-9]+)?|[0-9]+)"

- (BOOL)isOperatorClassForString:(NSString *)string {
	return [self isStringMatchForPattern:@"\\+|\\-|x|/|=" withString:string];
}

- (BOOL)isNumberClassForString:(NSString *)string {
	return [self isStringMatchForPattern:CEV_REGEX_FLOAT_PATTERN withString:string];
}

/*
- (BOOL)isFunctionClassForString:(NSString *)string {
	return [self isStringMatchForPattern:@"^(sin|cos|tan|ln|sinh|cosh|tanh|ex)" withString:string];
}

- (BOOL)isTextClass:(NSString *)string {
	return [self isStringMatchForPattern:@"^(\d|sin|cos|tan|ln|sinh|cosh|tanh|ex)" withString:string];
}
*/

#define CEV_VIEW_HEIGHT						( ( self.style == CEV_FILL_BACKGROUND ) ? 25.0f : 20.0f)
#define	CEV_SIDE_MARGIN						( ( self.style == CEV_FILL_BACKGROUND ) ? 8.0f : 6.0f)
#define CEV_COLUMN_MARGIN					( ( self.style == CEV_FILL_BACKGROUND ) ? 6.0f : 4.0f)
#define CEV_OPERATOR_WIDTH					( ( self.style == CEV_FILL_BACKGROUND ) ? 22.0f : 18.0f)
#define CEV_OPERATOR_HEIGHT 				( ( self.style == CEV_FILL_BACKGROUND ) ? 16.0f : 12.0f)
#define CEV_VALUE_FONT    					[UIFont boldSystemFontOfSize:( ( self.style == CEV_FILL_BACKGROUND ) ? 20.0f : 14.0f)]
#define CEV_OPERATOR_FONT					[UIFont boldSystemFontOfSize:( ( self.style == CEV_FILL_BACKGROUND ) ? 20.0f : 13.0f)]
#define CEV_COLOR1							[UIColor whiteColor]
#define CEV_COLOR2							[UIColor colorWithRed:155.0f/255.0f green:155.0f/255.0f blue:155.0f/255.0f alpha:1.0f]
#define CEV_COLOR3							[UIColor colorWithRed:72.0f/255.0f green:74.0f/255.0f blue:64.0f/255.0f alpha:1.0f]
#define CEV_COLOR4							[UIColor colorWithRed:102.0f/255.0f green:102.0f/255.0f blue:102.0f/255.0f alpha:1.0f]
#define CEV_COLOR5							[UIColor colorWithRed:240.0f/255.0f green:242.0f/255.0f blue:243.0f/255.0f alpha:1.0f]
#define CEV_BACKGROUND_FILL_COLOR			(self.style == CEV_FILL_BACKGROUND ? CEV_COLOR3 : CEV_COLOR4)
#define CEV_VALUE_TEXT_COLOR				(self.style == CEV_FILL_BACKGROUND ? CEV_COLOR1 : CEV_COLOR2)
#define CEV_OPERATOR_TEXT_COLOR				(self.style == CEV_FILL_BACKGROUND ? CEV_COLOR3 : CEV_COLOR5)
#define	CEV_CORNER_RADIUS					(self.style == CEV_FILL_BACKGROUND ? 4.0f : 3.0f)
#define CEV_PATH_FOR_ROUNDED_RECT			CGRectMake(drawingPoint.x, \
											drawingPoint.y + operatorYOffset, \
											CEV_OPERATOR_WIDTH,	\
											CEV_OPERATOR_HEIGHT)
#define CEV_OPERATOR_TEXT_OFFSET			(self.style == CEV_FILL_BACKGROUND ? -1.0f : -2.0f)

- (UIBezierPath *)newOperatorPathWithRect:(CGRect)rect {
	return [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:CEV_CORNER_RADIUS];
}

- (void)setOperatorTextColorForContext:(CGContextRef)context {
	UIColor *operatorTextColor = CEV_OPERATOR_TEXT_COLOR;

	CGContextSetStrokeColorWithColor(context, operatorTextColor.CGColor);
	CGContextSetFillColorWithColor(context, operatorTextColor.CGColor);
	CGContextSetTextDrawingMode(context, kCGTextFill);
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
	if (nil == self.expression)
		return;

	// Calculate full width and each drawing position for given expression to determine does it fit in bounds
	CGFloat	fullWidth;

	NSMutableArray *drawingPositions = [[NSMutableArray alloc] initWithCapacity:[self.expression count]];

	CGFloat coordinateX = CEV_SIDE_MARGIN;
	UIFont *valueFont = CEV_VALUE_FONT;
	for (NSInteger index = 0; index < [self.expression count];index++) {
		[drawingPositions addObject:[NSNumber numberWithFloat:coordinateX]];

		NSString *textToDisplay = [self.expression objectAtIndex:index];
		if ([self isOperatorClassForString:textToDisplay]) {
			coordinateX += CEV_OPERATOR_WIDTH;
		} else {
			CGSize sizeOfText = [textToDisplay sizeWithFont:valueFont];
			coordinateX += sizeOfText.width;
		}
		coordinateX += CEV_COLUMN_MARGIN;
	}
	fullWidth = coordinateX + CEV_SIDE_MARGIN - CEV_COLUMN_MARGIN;
	CGFloat drawingOffset = MAX(CGRectGetWidth(self.bounds) - fullWidth, 0.0f);

	// Drawing for operator.
	// Draw operator first for clipping.
	CGContextRef context = UIGraphicsGetCurrentContext();

	UIColor *backgroundColor = CEV_BACKGROUND_FILL_COLOR;
	UIFont *operatorFont = CEV_OPERATOR_FONT;

	CGPoint drawingPoint = {0.0f, 0.0f};

	UIBezierPath *backgroundPath = nil;
	if (self.style == CEV_FILL_BACKGROUND) {
		backgroundPath = [UIBezierPath bezierPathWithRect:CGRectMake(drawingPoint.x + drawingOffset, drawingPoint.y, fullWidth, CEV_VIEW_HEIGHT)];
		[backgroundPath setUsesEvenOddFillRule:YES];
	}

	CGFloat operatorYOffset = (CEV_VIEW_HEIGHT - CEV_OPERATOR_HEIGHT)/2.0;
	if (self.style == CEV_FILL_BACKGROUND) {
		// Colors for operator text
		[self setOperatorTextColorForContext:context];
		for (NSInteger index = 0; index < [self.expression count]; index++) {
			NSString *textToDisplay = [self.expression objectAtIndex:index];
			if ([self isOperatorClassForString:textToDisplay]) {
				drawingPoint.x = [[drawingPositions objectAtIndex:index] floatValue] + drawingOffset;

				if (nil == backgroundPath) {
					backgroundPath = [self newOperatorPathWithRect:CEV_PATH_FOR_ROUNDED_RECT];
				} else {
					[backgroundPath appendPath:[self newOperatorPathWithRect:CEV_PATH_FOR_ROUNDED_RECT]];
				}

				CGSize textSize = [textToDisplay sizeWithFont:operatorFont];
				[textToDisplay drawAtPoint:
						CGPointMake(drawingPoint.x + (CEV_OPERATOR_WIDTH - textSize.width) / 2.0f,
								drawingPoint.y + (CEV_OPERATOR_HEIGHT - textSize.height) / 2.0f + operatorYOffset + CEV_OPERATOR_TEXT_OFFSET)
								  withFont:operatorFont];
			}
		}
		CGContextSetFillColorWithColor(context, backgroundColor.CGColor);
		[backgroundPath fill];
	} else {
		for (NSInteger index = 0; index < [self.expression count]; index++) {
			NSString *textToDisplay = [self.expression objectAtIndex:index];
			if ([self isOperatorClassForString:textToDisplay]) {
				drawingPoint.x = [[drawingPositions objectAtIndex:index] floatValue] + drawingOffset;

				if (nil == backgroundPath) {
					backgroundPath = [self newOperatorPathWithRect:CEV_PATH_FOR_ROUNDED_RECT];
				} else {
					[backgroundPath appendPath:[self newOperatorPathWithRect:CEV_PATH_FOR_ROUNDED_RECT]];
				}
			}
		}
		CGContextSetFillColorWithColor(context, backgroundColor.CGColor);
		[backgroundPath fill];

		[self setOperatorTextColorForContext:context];

		for (NSInteger index = 0; index < [self.expression count]; index++) {
			NSString *textToDisplay = [self.expression objectAtIndex:index];
			if ([self isOperatorClassForString:textToDisplay]) {
				drawingPoint.x = [[drawingPositions objectAtIndex:index] floatValue] + drawingOffset;

				CGSize textSize = [textToDisplay sizeWithFont:operatorFont];
				[textToDisplay drawAtPoint:
						CGPointMake(drawingPoint.x + (CEV_OPERATOR_WIDTH - textSize.width) / 2.0f,
								drawingPoint.y + (CEV_OPERATOR_HEIGHT - textSize.height) / 2.0f + operatorYOffset + CEV_OPERATOR_TEXT_OFFSET)
								  withFont:operatorFont];
			}
		}
	}

	// Drawing for numbers and functions.
	UIColor *valueColor = CEV_VALUE_TEXT_COLOR;
	CGContextSetStrokeColorWithColor(context, valueColor.CGColor);
	CGContextSetFillColorWithColor(context, valueColor.CGColor);
	CGContextSetTextDrawingMode(context, kCGTextFill);

	drawingPoint = CGPointMake(CEV_SIDE_MARGIN, 0.0f);
	for (NSInteger index = 0; index < [self.expression count]; index++) {
		NSString *textToDisplay = [self.expression objectAtIndex:index];
		if (![self isOperatorClassForString:textToDisplay]) {
			drawingPoint.x = [[drawingPositions objectAtIndex:index] floatValue] + drawingOffset;
			[textToDisplay drawAtPoint:drawingPoint withFont:valueFont];
		}
	}
}

@end
