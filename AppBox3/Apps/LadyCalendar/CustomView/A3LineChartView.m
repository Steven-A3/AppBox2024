//
//  A3LineChartView.m
//  A3TeamWork
//
//  Created by coanyaa on 2013. 11. 22..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3LineChartView.h"
#import "UIColor+A3Addition.h"
#import "A3UIDevice.h"

@interface A3LineChartView ()

@end

@implementation A3LineChartView {
	CGFloat yAxisWidth;
	CGRect xAxisLineRect;
	CGFloat xAxisSeparatorHeight;
	CGFloat xAxisSeparatorInterval;
	CGSize pointSize;
	CGFloat _yAxisInterval;
	CGSize yLabelMaxSize;
	NSMutableArray *pointArray;
	CGFloat yStartCenterPosition;
	CGPoint valueTotal;
	CGFloat _averageLineYPos;
	CGSize xLabelMaxSize;
	CGFloat xAxisLineHeight;
}

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		[self awakeFromNib];
	}
	return self;
}

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	self.xAxisColor = [UIColor colorWithRGBRed:200 green:200 blue:200 alpha:255];
	self.xLabelColor = [UIColor colorWithRGBRed:142 green:142 blue:147 alpha:255];
	self.yLabelColor = [UIColor colorWithRGBRed:142 green:142 blue:147 alpha:255];
	self.lineColor = [UIColor colorWithRGBRed:200 green:200 blue:200 alpha:255];
	self.pointColor = [UIColor colorWithRGBRed:200 green:200 blue:200 alpha:255];
	self.averageColor = [UIColor colorWithRGBRed:167 green:232 blue:183 alpha:255];
	self.showXLabel = YES;
	self.showYLabel = NO;
	self.xAxisFont = [UIFont systemFontOfSize:(IS_IPHONE ? 11.0 : 13.0)];
	self.yAxisFont = [UIFont systemFontOfSize:(IS_IPHONE ? 11.0 : 13.0)];
	self.xLabelDisplayInterval = 1;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    [self setNeedsDisplay];
}

- (void)drawXAxisWithContext:(CGContextRef)context
{
    CGContextSetFillColorWithColor(context, [self.xAxisColor CGColor]);
    CGContextFillRect(context, xAxisLineRect);
    
    CGContextSetLineWidth(context, 0.5);
    CGContextSetStrokeColorWithColor(context, [_xAxisColor CGColor] );
    CGContextSetTextDrawingMode(context, kCGTextFill);
    
    NSDictionary *attr = @{NSForegroundColorAttributeName : _xLabelColor,NSFontAttributeName : _xAxisFont};
    for (NSInteger idx = 0; idx < [_xLabelItems count]; idx++) {
        if ( idx > 0 && (idx + 1) < [_xLabelItems count] ) {
            CGPoint ptLine[] = {CGPointMake(xAxisLineRect.origin.x + (idx * xAxisSeparatorInterval), xAxisLineRect.origin.y + xAxisLineRect.size.height),CGPointMake(xAxisLineRect.origin.x + (idx * xAxisSeparatorInterval), xAxisLineRect.origin.y + xAxisLineRect.size.height+ xAxisSeparatorHeight)};
            CGContextStrokeLineSegments(context, ptLine, 2);
        }
        
        if ( _showXLabel && !(idx % _xLabelDisplayInterval)) {
            NSString *str = [_xLabelItems objectAtIndex:idx];
            CGSize strSize = [str sizeWithAttributes:attr];
            
            
            if (idx == 0) {
                [str drawAtPoint:CGPointMake(0.0, xAxisLineRect.origin.y + xAxisLineRect.size.height +  xAxisSeparatorHeight) withAttributes:attr];
            }
            else if (idx == [_xLabelItems count] - 1) {
                [str drawAtPoint:CGPointMake(self.bounds.size.width - strSize.width, xAxisLineRect.origin.y + xAxisLineRect.size.height +  xAxisSeparatorHeight) withAttributes:attr];
            }
            else {
                [str drawAtPoint:CGPointMake(xAxisLineRect.origin.x + (idx * xAxisSeparatorInterval) - strSize.width * 0.5, xAxisLineRect.origin.y + xAxisLineRect.size.height +  xAxisSeparatorHeight) withAttributes:attr];
            }
        }
    }
}

- (void)drawYAxisWithContext:(CGContextRef)context
{
    CGPoint yLabelPos = CGPointMake(0, yStartCenterPosition);
    for (NSInteger idx=0; idx < [_yLabelItems count]; idx++) {
        CGRect drawRect = CGRectMake(yLabelPos.x, yLabelPos.y - (idx * _yAxisInterval) - (yLabelMaxSize.height / 2), yLabelMaxSize.width, yLabelMaxSize.height);
        NSString *str = [_yLabelItems objectAtIndex:idx];
        [str drawWithRect:drawRect options:NSLineBreakByCharWrapping|NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.yAxisFont,NSForegroundColorAttributeName:_yLabelColor} context:nil];
//        CGContextMoveToPoint(context, 0, yLabelPos.y - (idx * _yAxisInterval) - (yLabelMaxSize.height / 2));
//        CGContextAddLineToPoint(context, yLabelMaxSize.width, yLabelPos.y - (idx * _yAxisInterval) - (yLabelMaxSize.height / 2));
//        CGContextSetLineWidth(context, 1.0);
//        CGContextSetStrokeColorWithColor(context, [_lineColor CGColor]);
//        CGContextStrokePath(context);
    }
}

- (void)drawLineWithContext:(CGContextRef)context
{
    for (NSInteger i=0; i < [pointArray count]; i++) {
        CGPoint pos = [[pointArray objectAtIndex:i] CGPointValue];
        if ( i == 0 )
            CGContextMoveToPoint(context, pos.x, pos.y+pointSize.height*0.5);
        else
            CGContextAddLineToPoint(context, pos.x, pos.y+pointSize.height*0.5);
    }
    CGContextSetLineWidth(context, 1.0);
    CGContextSetStrokeColorWithColor(context, [_lineColor CGColor]);
    CGContextStrokePath(context);
}

- (void)drawPointWithContext:(CGContextRef)context
{
    for (NSInteger i=0; i < [pointArray count]; i++) {
        CGPoint pos = [[pointArray objectAtIndex:i] CGPointValue];
        CGRect outRect = CGRectMake(pos.x-pointSize.width*0.5, pos.y, pointSize.width, pointSize.height);
        CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
        CGContextFillEllipseInRect(context, outRect);
        CGContextSetLineWidth(context, 1.0);
        CGContextSetStrokeColorWithColor(context, [_pointColor CGColor]);
        CGContextStrokeEllipseInRect(context, outRect);
        CGContextSetFillColorWithColor(context, [_pointColor CGColor]);
        CGContextFillEllipseInRect(context, CGRectMake(pos.x-pointSize.width*0.25, pos.y+pointSize.height*0.25, pointSize.width*0.5, pointSize.height *0.5));
    }
}

- (void)drawAverageLineWithContext:(CGContextRef)context
{
    if ( [_valueArray count] < 1 )
        return;
    CGFloat averageValue =  valueTotal.y / [_valueArray count];
    _averageLineYPos = [self getYAxisPointForValueY:averageValue withYLabelIndex:0 yAxisInterval:_yAxisInterval];
    _averageLineYPos = _averageLineYPos + pointSize.height / 2.0;
    
    CGContextSetStrokeColorWithColor(context, [_averageColor CGColor]);
    CGContextSetLineWidth(context, 1.0);
    CGContextMoveToPoint(context, xAxisLineRect.origin.x, _averageLineYPos );
    CGContextAddLineToPoint(context, xAxisLineRect.origin.x+xAxisLineRect.size.width, _averageLineYPos);
    CGContextStrokePath(context);
}

- (void)drawAverageValueWithContext:(CGContextRef)context
{
    if ( [_valueArray count] < 1 )
        return;
	UIFont *font = IS_IPHONE ? [UIFont systemFontOfSize:15] : [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    NSDictionary *attribute = @{NSFontAttributeName : font, NSForegroundColorAttributeName : _averageColor};
    
    CGFloat averageValueYPos = _averageLineYPos + 10;
    CGFloat lastValuePos = [self getYAxisPointForValueY:[[_valueArray lastObject] CGPointValue].y withYLabelIndex:0 yAxisInterval:_yAxisInterval];
    if (lastValuePos >= _averageLineYPos) {
        averageValueYPos = _averageLineYPos - 10 - 26;
    }
    if (averageValueYPos < self.bounds.origin.y) {
        averageValueYPos = self.bounds.origin.y + 2;
        if (averageValueYPos < (lastValuePos + 13)) {
            averageValueYPos += 19;
        }
    }
    else if ((averageValueYPos + 26) > self.bounds.size.height) {
        averageValueYPos = self.bounds.size.height - 28;
        if ((averageValueYPos + 28) < lastValuePos) {
            averageValueYPos = lastValuePos - 28 - 5;
        }
    }
    averageValueYPos = ceilf(averageValueYPos);
    
    NSString *labelStr = [NSString stringWithFormat:@"%@ %g",(IS_IPAD ? NSLocalizedString(@"Average", @"Average") : NSLocalizedString(@"Avg.", @"Avg.")),roundf((valueTotal.y /( [_valueArray count] > 0 ? [_valueArray count] : 1))*100.0)*0.01];
    CGRect bounds = [labelStr boundingRectWithSize:CGSizeMake(xAxisLineRect.size.width,26.0) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingTruncatesLastVisibleLine attributes:attribute context:nil];
    
    CGSize markSize = CGSizeMake(bounds.size.width+24.0, 26.0);
    CGRect shapeFrame = CGRectMake(xAxisLineRect.origin.x+xAxisLineRect.size.width - markSize.width, /*(self.frame.size.height - (self.frame.size.height-xAxisLineRect.origin.y))*0.5 - markSize.height*0.5*/averageValueYPos, markSize.width, markSize.height);
    // draw shape
    CGContextMoveToPoint(context, shapeFrame.origin.x, shapeFrame.origin.y + shapeFrame.size.height*0.5);
    CGContextAddLineToPoint(context, shapeFrame.origin.x+10.0, shapeFrame.origin.y);
    CGContextAddLineToPoint(context, shapeFrame.origin.x+shapeFrame.size.width, shapeFrame.origin.y);
    CGContextAddLineToPoint(context, shapeFrame.origin.x+shapeFrame.size.width, shapeFrame.origin.y + shapeFrame.size.height);
    CGContextAddLineToPoint(context, shapeFrame.origin.x+10.0, shapeFrame.origin.y+shapeFrame.size.height);
    CGContextAddLineToPoint(context, shapeFrame.origin.x, shapeFrame.origin.y + shapeFrame.size.height*0.5);


    CGContextMoveToPoint(context, shapeFrame.origin.x, shapeFrame.origin.y + shapeFrame.size.height*0.5);
    CGContextAddLineToPoint(context, shapeFrame.origin.x+10.0, shapeFrame.origin.y);
    CGContextAddLineToPoint(context, shapeFrame.origin.x+shapeFrame.size.width, shapeFrame.origin.y);
    CGContextAddLineToPoint(context, shapeFrame.origin.x+shapeFrame.size.width, shapeFrame.origin.y + shapeFrame.size.height);
    CGContextAddLineToPoint(context, shapeFrame.origin.x+10.0, shapeFrame.origin.y+shapeFrame.size.height);
    CGContextAddLineToPoint(context, shapeFrame.origin.x, shapeFrame.origin.y + shapeFrame.size.height*0.5);
    CGContextSetLineWidth(context, 1.0);
    CGContextSetStrokeColorWithColor(context, [_averageColor CGColor] );
    CGContextStrokePath(context);
    
    [labelStr drawInRect:CGRectMake(shapeFrame.origin.x+14.0, shapeFrame.origin.y+shapeFrame.size.height*0.5 - bounds.size.height*0.5, bounds.size.width, bounds.size.height) withAttributes:attribute];
}

- (void)calculateComponentsSizeWithContext:(CGContextRef)context
{
    pointSize = CGSizeMake(15.0, 15.0);
    xAxisSeparatorHeight = 7.0;
    xAxisLineHeight = 5.0;
    
    // yValue중 가장 크기가 큰 값을 찾는다.
    CGFloat maxYLabelWidth = 0;
    for (NSString *str in _yLabelItems) {
        CGRect rect = [str boundingRectWithSize:CGSizeMake(self.frame.size.width, 99999.0) options:NSLineBreakByCharWrapping|NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.yAxisFont} context:nil];
        maxYLabelWidth = MAX(maxYLabelWidth, rect.size.width);
        yLabelMaxSize = CGSizeMake(maxYLabelWidth, rect.size.height);
    }
    
    
    xLabelMaxSize = CGSizeZero;
    if ( _showXLabel ) {
        CGFloat maxXLabelHeight = 0.0;
        CGFloat maxXLabelWidth = 0.0;
        for (NSString *str in _xLabelItems) {
            CGRect rect = [str boundingRectWithSize:CGSizeMake(self.frame.size.width, 99999.0) options:NSLineBreakByCharWrapping|NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.xAxisFont} context:nil];
            maxXLabelHeight = MAX(maxXLabelHeight, rect.size.height);
            maxXLabelWidth = MAX(maxXLabelWidth, rect.size.width);
            xLabelMaxSize = CGSizeMake(maxXLabelWidth, ceilf(maxXLabelHeight));
        }
    }
    
    yAxisWidth = maxYLabelWidth + 5.0;
    xAxisLineRect = CGRectMake(yAxisWidth + pointSize.width*0.5, self.bounds.size.height - xAxisSeparatorHeight - xLabelMaxSize.height - xAxisLineHeight, self.bounds.size.width - (yAxisWidth+pointSize.width*0.5) - pointSize.width*0.5, xAxisLineHeight);

    xAxisSeparatorInterval = xAxisLineRect.size.width / ([_xLabelItems count] -1 < 1 ? 1 : [_xLabelItems count]-1);
    
    _yAxisInterval = (self.bounds.size.height - xAxisLineRect.size.height - xAxisSeparatorHeight - xLabelMaxSize.height - pointSize.height *0.5) / ([_yLabelItems count] < 1 ? 1 : [_yLabelItems count]);
    
    pointArray = [NSMutableArray array];
    // 정점좌표 계산
    yStartCenterPosition = xAxisLineRect.origin.y - _yAxisInterval + 1.0;
    valueTotal = CGPointZero;
    for (NSInteger i=0; i < [_valueArray count]; i++) {
        CGPoint value = [[_valueArray objectAtIndex:i] CGPointValue];
        CGFloat xpos = xAxisLineRect.origin.x + (value.x - _minXValue) * xAxisSeparatorInterval - (i + 1 == [_valueArray count] ? 1.0 : 0.0);
        CGFloat ypos = [self getYAxisPointForValueY:value.y withYLabelIndex:0 yAxisInterval:_yAxisInterval];
        
        CGPoint pos = CGPointMake(xpos, ypos);
        [pointArray addObject:[NSValue valueWithCGPoint:pos]];
        valueTotal.x += value.x;
        valueTotal.y += value.y;
    }
}

- (CGFloat)getYAxisPointForValueY:(CGFloat)valueY withYLabelIndex:(NSInteger)idx yAxisInterval:(CGFloat)yAxisInterval
{
    CGFloat resultYAxis = 0.0;
    CGFloat yAxisValue = [[_yLabelItems objectAtIndex:idx] floatValue];
    
    if (valueY == yAxisValue) {
        resultYAxis = yAxisInterval * ([_yLabelItems count] - idx) - yAxisInterval;
        if (resultYAxis == 0) {
            resultYAxis = 1;
        }
        return roundf(resultYAxis);
    }
    else {
        CGFloat nextYAxisValue = [[_yLabelItems objectAtIndex:idx + 1] floatValue];
        if (valueY < nextYAxisValue) {
            CGFloat yValueGap =  (nextYAxisValue - valueY) / (CGFloat)(nextYAxisValue - yAxisValue);
            resultYAxis = (yAxisInterval * ([_yLabelItems count] - idx)) - (yAxisInterval - (yAxisInterval * yValueGap)) - yAxisInterval;
            if (resultYAxis == 0) {
                resultYAxis = 1;
            }
            return roundf(resultYAxis);
        }
    }
    
    return [self getYAxisPointForValueY:valueY withYLabelIndex:(idx + 1) yAxisInterval:yAxisInterval];
}

- (void)drawRect:(CGRect)rect
{
    // 틀을 그린다.
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    [self calculateComponentsSizeWithContext:ctx];
    [self drawXAxisWithContext:ctx];
    [self drawYAxisWithContext:ctx];
    [self drawLineWithContext:ctx];
    [self drawPointWithContext:ctx];
    [self drawAverageLineWithContext:ctx];
    [self drawAverageValueWithContext:ctx];
}

@end
