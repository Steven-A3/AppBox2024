//
//  A3CalcExpressionView.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 7/23/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3CalcExpressionView.h"
#import "common.h"

@implementation A3CalcExpressionView {
    UIFont *_valueFont;
    UIColor *_valueColor;
	UIFont *_operatorFont;
	UIColor *_operatorColor;
	UIColor *_backgroundColor;
	CGFloat _fullWidth, _operatorWidth, _operatorHeight;
}

- (void)initialize {
	self.backgroundColor = [UIColor clearColor];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		[self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
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
	return [self isStringMatchForPattern:@"(\\+|\\-|x|/|=|of)" withString:string];
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

//#define CEV_VIEW_HEIGHT						( ( self.style == CEV_FILL_BACKGROUND ) ? 25.0f : 20.0f)
#define	CEV_SIDE_MARGIN						( ( self.style == CEV_FILL_BACKGROUND ) ? 8.0f : 6.0f)
#define CEV_COLUMN_MARGIN					( ( self.style == CEV_FILL_BACKGROUND ) ? 6.0f : 4.0f)
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
											_operatorWidth,	\
											_operatorHeight)
#define CEV_OPERATOR_TEXT_OFFSET			(self.style == CEV_FILL_BACKGROUND ? -2.0f : -2.0f)

- (UIBezierPath *)newOperatorPathWithRect:(CGRect)rect {
	return [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:CEV_CORNER_RADIUS];
}

- (void)setOperatorTextColorForContext:(CGContextRef)context {
	CGContextSetStrokeColorWithColor(context, _operatorColor.CGColor);
	CGContextSetFillColorWithColor(context, _operatorColor.CGColor);
	CGContextSetTextDrawingMode(context, kCGTextFill);
}

- (UIFont *)fontAtIndex:(NSInteger)index forValue:(BOOL)forValue {
	UIFont *font;
	if (_attributes && (index < [_attributes count]) && [[_attributes objectAtIndex:index] objectForKey:A3ExpressionAttributeFont]) {
		font = [[_attributes objectAtIndex:index] objectForKey:A3ExpressionAttributeFont];
	}
	if (![font isKindOfClass:[UIFont class]]) {
		font = forValue ? _valueFont : _operatorFont;
	}
	return font;
}

- (UIColor *)colorAtIndex:(NSInteger)index forValue:(BOOL)forValue {
	UIColor *color;
	if (_attributes && (index < [_attributes count]) && [[_attributes objectAtIndex:index] objectForKey:A3ExpressionAttributeTextColor]) {
		color = [[_attributes objectAtIndex:index] objectForKey:A3ExpressionAttributeTextColor];
	}
	if (![color isKindOfClass:[UIColor class]]) {
		color = forValue ? _valueColor : _operatorColor;
	}
	return color;
}

- (NSArray *)calcDrawingPositions {
	NSMutableArray *drawingPositions = [[NSMutableArray alloc] initWithCapacity:[self.expression count]];

	CGFloat coordinateX = CEV_SIDE_MARGIN;
	UIFont *valueFont;
	for (NSInteger index = 0; index < [self.expression count];index++) {
		[drawingPositions addObject:[NSNumber numberWithFloat:coordinateX]];

		NSString *textToDisplay = [self.expression objectAtIndex:index];
		if ([self isOperatorClassForString:textToDisplay]) {
			coordinateX += _operatorWidth;
		} else {
			valueFont = [self fontAtIndex:index forValue:YES];
			CGSize sizeOfText = [textToDisplay sizeWithFont:valueFont];
			coordinateX += sizeOfText.width;
		}
		coordinateX += CEV_COLUMN_MARGIN;
	}
	_fullWidth = coordinateX + CEV_SIDE_MARGIN - CEV_COLUMN_MARGIN;
	return drawingPositions;
}

- (void)prepareAttributesWithRect:(CGRect)rect {
	CGFloat fontSize = CGRectGetHeight(rect) - 4.0;
	_valueFont = [UIFont boldSystemFontOfSize:fontSize];
	_valueColor = CEV_VALUE_TEXT_COLOR;
	_operatorFont = [UIFont boldSystemFontOfSize:fontSize];
	_operatorColor = CEV_OPERATOR_TEXT_COLOR;
	_backgroundColor = CEV_BACKGROUND_FILL_COLOR;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
	if (nil == self.expression)
		return;

	[self prepareAttributesWithRect:rect];

	CGFloat drawingOffset = 0.0;

	// Drawing for operator.
	// Draw operator first for clipping.
	CGContextRef context = UIGraphicsGetCurrentContext();

	CGPoint drawingPoint = {0.0f, 0.0f};
	CGFloat viewHeight = CGRectGetHeight(rect);
	_operatorWidth = ceilf(viewHeight * 20.0/25.0);
	_operatorHeight = ceilf((viewHeight * 19.0 / 25.0));
	FNLOG(@"%f", _operatorHeight);

	NSArray *drawingPositions = [self calcDrawingPositions];

	UIBezierPath *backgroundPath = nil;
	if (self.style == CEV_FILL_BACKGROUND) {
		backgroundPath = [UIBezierPath bezierPathWithRect:CGRectMake(drawingPoint.x + drawingOffset, drawingPoint.y, _fullWidth, viewHeight)];
		[backgroundPath setUsesEvenOddFillRule:YES];
	}

	CGFloat operatorYOffset = (viewHeight - _operatorHeight)/2.0;
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

				CGSize textSize = [textToDisplay sizeWithFont:[self fontAtIndex:index forValue:NO]];
				[textToDisplay drawAtPoint:
						CGPointMake(drawingPoint.x + (_operatorWidth - textSize.width) / 2.0f,
								drawingPoint.y + (_operatorHeight - textSize.height) / 2.0f + operatorYOffset + CEV_OPERATOR_TEXT_OFFSET)
								  withFont:[self fontAtIndex:index forValue:NO]];
			}
		}
		CGContextSetFillColorWithColor(context, _backgroundColor.CGColor);
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
		CGContextSetFillColorWithColor(context, _backgroundColor.CGColor);
		[backgroundPath fill];

		[self setOperatorTextColorForContext:context];

		for (NSInteger index = 0; index < [self.expression count]; index++) {
			NSString *textToDisplay = [self.expression objectAtIndex:index];
			if ([self isOperatorClassForString:textToDisplay]) {
				drawingPoint.x = [[drawingPositions objectAtIndex:index] floatValue] + drawingOffset;

				CGFloat offset = CEV_OPERATOR_TEXT_OFFSET;
				if ([textToDisplay isEqualToString:@"of"]) {
					offset = 0.0;
				}
				CGSize textSize = [textToDisplay sizeWithFont:[self fontAtIndex:index forValue:NO]];
				[textToDisplay drawAtPoint:
						CGPointMake(drawingPoint.x + (_operatorWidth - textSize.width) / 2.0f,
								drawingPoint.y + (_operatorHeight - textSize.height) / 2.0f + operatorYOffset + offset)
								  withFont:[self fontAtIndex:index forValue:NO]];
			}
		}
	}

	// Drawing for numbers and functions.
	CGContextSetTextDrawingMode(context, kCGTextFill);

	drawingPoint = CGPointMake(CEV_SIDE_MARGIN, 0.0f);
	for (NSInteger index = 0; index < [self.expression count]; index++) {
		NSString *textToDisplay = [self.expression objectAtIndex:index];
		if (![self isOperatorClassForString:textToDisplay]) {
			_valueFont = [self fontAtIndex:index forValue:YES];

			_valueColor = [self colorAtIndex:index forValue:YES];
			CGContextSetStrokeColorWithColor(context, [self colorAtIndex:index forValue:YES].CGColor);
			CGContextSetFillColorWithColor(context, [self colorAtIndex:index forValue:YES].CGColor);

			drawingPoint.x = [[drawingPositions objectAtIndex:index] floatValue] + drawingOffset;
			CGSize size = [textToDisplay sizeWithFont:[self fontAtIndex:index forValue:YES]];
			drawingPoint.y = CGRectGetHeight(self.bounds)/2.0 - size.height / 2.0;
			[textToDisplay drawAtPoint:drawingPoint withFont:[self fontAtIndex:index forValue:YES]];
		}
	}
}

@end
