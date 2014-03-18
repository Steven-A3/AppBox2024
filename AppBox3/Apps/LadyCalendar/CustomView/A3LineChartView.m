//
//  A3LineChartView.m
//  A3TeamWork
//
//  Created by coanyaa on 2013. 11. 22..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3LineChartView.h"
#import "UIColor+A3Addition.h"

@interface A3LineChartView ()

- (void)calculateComponentsSizeWithContext:(CGContextRef)context;
- (void)drawXAxisWithContext:(CGContextRef)context;
- (void)drawYAxisWithContext:(CGContextRef)context;
- (void)drawLineWithContext:(CGContextRef)context;
- (void)drawPointWithContext:(CGContextRef)context;
- (void)drawAverageLineWithContext:(CGContextRef)context;
- (void)drawAverageValueWithContext:(CGContextRef)context;

@end

@implementation A3LineChartView
- (void)drawXAxisWithContext:(CGContextRef)context
{
    CGContextSetFillColorWithColor(context, [self.xAxisColor CGColor]);
    CGContextFillRect(context, xAxisLineRect);
    
    CGContextSetLineWidth(context, 0.5);
    CGContextSetStrokeColorWithColor(context, [_xAxisColor CGColor] );
    CGContextSetTextDrawingMode(context, kCGTextFill);
    
    NSDictionary *attr = @{NSForegroundColorAttributeName : _xLabelColor,NSFontAttributeName : _xAxisFont};
    for(NSInteger i=0; i < [_xLabelItems count]; i++){
        if( i > 0 && (i+1) < [_xLabelItems count] ){
            CGPoint ptLine[] = {CGPointMake(xAxisLineRect.origin.x + (i*xAxisSeperatorInterval), xAxisLineRect.origin.y + xAxisLineRect.size.height),CGPointMake(xAxisLineRect.origin.x + (i*xAxisSeperatorInterval), xAxisLineRect.origin.y + xAxisLineRect.size.height+xAxisSeperatorHeight)};
            CGContextStrokeLineSegments(context, ptLine, 2);
        }
        
        if( _showXLabel && !(i % _xLabelDisplayInterval)){
            NSString *str = [_xLabelItems objectAtIndex:i];
            CGSize strSize = [str sizeWithAttributes:attr];
            [str drawAtPoint:CGPointMake(xAxisLineRect.origin.x + (i*xAxisSeperatorInterval) - strSize.width*0.5, xAxisLineRect.origin.y + xAxisLineRect.size.height+xAxisSeperatorHeight) withAttributes:attr];
        }
    }
}

- (void)drawYAxisWithContext:(CGContextRef)context
{
    CGPoint yLabelPos = CGPointMake(0, yStartCenterPosition);
    for(NSInteger i=0; i < [_yLabelItems count]; i++){
        CGRect drawRect = CGRectMake(yLabelPos.x, yLabelPos.y - (i * yAxisInterval), yLabelMaxSize.width, yLabelMaxSize.height);
        NSString *str = [_yLabelItems objectAtIndex:i];
        [str drawWithRect:drawRect options:NSLineBreakByCharWrapping|NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.yAxisFont,NSForegroundColorAttributeName:_yLabelColor} context:nil];
    }
}

- (void)drawLineWithContext:(CGContextRef)context
{
    for(NSInteger i=0; i < [pointArray count]; i++){
        CGPoint pos = [[pointArray objectAtIndex:i] CGPointValue];
        if( i == 0 )
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
    for(NSInteger i=0; i < [pointArray count]; i++){
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
    if( [_valueArray count] < 1 )
        return;
    CGFloat averageValue =  valueTotal.y / [_valueArray count];
    averageLineYPos = yStartCenterPosition - ((averageValue - _minYValue) * yAxisInterval)*0.5 + pointSize.height*0.5;
    
    CGContextSetStrokeColorWithColor(context, [_averageColor CGColor]);
    CGContextSetLineWidth(context, 1.0);
    CGContextMoveToPoint(context, xAxisLineRect.origin.x, averageLineYPos );
    CGContextAddLineToPoint(context, xAxisLineRect.origin.x+xAxisLineRect.size.width, averageLineYPos);
    CGContextStrokePath(context);
    
}

- (void)drawAverageValueWithContext:(CGContextRef)context
{
    if( [_valueArray count] < 1 )
        return;
    NSDictionary *attribute = @{NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline],NSForegroundColorAttributeName : _averageColor};
    
    NSString *labelStr = [NSString stringWithFormat:@"%@ %g",(IS_IPAD ? @"Average" : @"Avg."),roundf((valueTotal.y /( [_valueArray count] > 0 ? [_valueArray count] : 1))*100.0)*0.01];
    CGRect bounds = [labelStr boundingRectWithSize:CGSizeMake(xAxisLineRect.size.width,26.0) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingTruncatesLastVisibleLine attributes:attribute context:nil];
    
    CGSize markSize = CGSizeMake(bounds.size.width+24.0, 26.0);
    CGRect shapeFrame = CGRectMake(xAxisLineRect.origin.x+xAxisLineRect.size.width - markSize.width, /*(self.frame.size.height - (self.frame.size.height-xAxisLineRect.origin.y))*0.5 - markSize.height*0.5*/averageLineYPos+20.0, markSize.width, markSize.height);
    // draw shape
    CGContextMoveToPoint(context, shapeFrame.origin.x, shapeFrame.origin.y + shapeFrame.size.height*0.5);
    CGContextAddLineToPoint(context, shapeFrame.origin.x+10.0, shapeFrame.origin.y);
    CGContextAddLineToPoint(context, shapeFrame.origin.x+shapeFrame.size.width, shapeFrame.origin.y);
    CGContextAddLineToPoint(context, shapeFrame.origin.x+shapeFrame.size.width, shapeFrame.origin.y + shapeFrame.size.height);
    CGContextAddLineToPoint(context, shapeFrame.origin.x+10.0, shapeFrame.origin.y+shapeFrame.size.height);
    CGContextAddLineToPoint(context, shapeFrame.origin.x, shapeFrame.origin.y + shapeFrame.size.height*0.5);
    
    
    CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
    CGContextFillPath(context);
    
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
    xAxisSeperatorHeight = 7.0;
    xAxisLineHeight = 5.0;
    
    // yValue중 가장 크기가 큰 값을 찾는다.
    CGFloat maxYLabelWidth = 0;
    for(NSString *str in _yLabelItems){
        CGRect rect = [str boundingRectWithSize:CGSizeMake(self.frame.size.width, 99999.0) options:NSLineBreakByCharWrapping|NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.yAxisFont} context:nil];
        maxYLabelWidth = MAX(maxYLabelWidth, rect.size.width);
        yLabelMaxSize = CGSizeMake(maxYLabelWidth, rect.size.height);
    }
    
    
    xLabelMaxSize = CGSizeZero;
    if( _showXLabel ){
        CGFloat maxXLabelHeight = 0.0;
        CGFloat maxXLabelWidth = 0.0;
        for(NSString *str in _xLabelItems){
            CGRect rect = [str boundingRectWithSize:CGSizeMake(self.frame.size.width, 99999.0) options:NSLineBreakByCharWrapping|NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.xAxisFont} context:nil];
            maxXLabelHeight = MAX(maxXLabelHeight, rect.size.height);
            maxXLabelWidth = MAX(maxXLabelWidth, rect.size.width);
            xLabelMaxSize = CGSizeMake(maxXLabelWidth, ceilf(maxXLabelHeight));
        }
    }
    
    yAxisWidth = maxYLabelWidth + 5.0;
    xAxisLineRect = CGRectMake(yAxisWidth + pointSize.width*0.5, self.bounds.size.height - xAxisSeperatorHeight - xLabelMaxSize.height - xAxisLineHeight, self.bounds.size.width - (yAxisWidth+pointSize.width*0.5) - pointSize.width*0.5, xAxisLineHeight);

    xAxisSeperatorInterval = xAxisLineRect.size.width / ([_xLabelItems count] -1 < 1 ? 1 : [_xLabelItems count]-1);
    
    yAxisInterval = (self.bounds.size.height - xAxisLineRect.size.height - xAxisSeperatorHeight - xLabelMaxSize.height - pointSize.height *0.5) / ([_yLabelItems count] < 1 ? 1 : [_yLabelItems count] );
    
    pointArray = [NSMutableArray array];
    // 정점좌표 계산
    yStartCenterPosition = xAxisLineRect.origin.y-(yAxisInterval + pointSize.height*0.5) + 1.0;
    valueTotal = CGPointZero;
    for(NSInteger i=0; i < [_valueArray count]; i++){
        CGPoint value = [[_valueArray objectAtIndex:i] CGPointValue];
        CGPoint pos = CGPointMake(xAxisLineRect.origin.x + (value.x - _minXValue) * xAxisSeperatorInterval - (i+1 == [_valueArray count] ? 1.0 : 0.0), yStartCenterPosition - (value.y - _minYValue) * yAxisInterval);
        [pointArray addObject:[NSValue valueWithCGPoint:pos]];
        valueTotal.x += value.x;
        valueTotal.y += value.y;
    }
}

- (void)awakeFromNib
{
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

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self awakeFromNib];
    }
    return self;
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
