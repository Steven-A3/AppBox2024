//
//  A3ColoredCircleView.m
//  A3TeamWork
//
//  Created by coanyaa on 2013. 11. 18..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3ColoredCircleView.h"

@implementation A3ColoredCircleView

- (void)awakeFromNib
{
	[super awakeFromNib];
	
    self.centerCircleColor = [UIColor redColor];
    self.outlineCircleColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self awakeFromNib];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [[UIColor whiteColor] setFill];
    CGContextFillEllipseInRect(context, CGRectMake(0.5, 0.5, self.bounds.size.width-0.5, self.bounds.size.height-0.5));
    CGContextSetStrokeColorWithColor(context, [_outlineCircleColor CGColor]);
    CGContextSetLineWidth(context, 1.0/[[UIScreen mainScreen] scale]);
    CGContextStrokeEllipseInRect(context,CGRectMake(0.5, 0.5, self.bounds.size.width-1.0, self.bounds.size.height-1.0));
    
    CGContextSetFillColorWithColor(context, [_centerCircleColor CGColor]);
    CGContextFillEllipseInRect(context, CGRectMake(self.bounds.size.width*0.25, self.bounds.size.height*0.25, self.bounds.size.width*0.5, self.bounds.size.height*0.5));
//    CGContextSetLineWidth(context, 1.0);
//    CGContextSetStrokeColorWithColor(context, [_outlineCircleColor CGColor]);
//    CGContextAddArc(context, self.frame.size.width*0.5, self.frame.size.height*0.5, self.frame.size.width*0.5-0.5, 0.0, M_PI*2.0, YES);
//    CGContextStrokePath(context);
//    
//    CGContextSetFillColorWithColor(context, [_centerCircleColor CGColor]);
//    CGContextAddEllipseInRect(context, CGRectInset(self.bounds, -self.bounds.size.width*0.5, -self.bounds.size.height*0.5));
//    CGContextFillPath(context);
}

- (void)setCenterCircleColor:(UIColor *)centerCircleColor
{
    _centerCircleColor = centerCircleColor;
    [self setNeedsDisplay];
}

- (void)setOutlineCircleColor:(UIColor *)outlineCircleColor
{
    _outlineCircleColor = outlineCircleColor;
    [self setNeedsDisplay];
}

- (void)setAlphaCircleColor:(UIColor *)alphaCircleColor
{
    _alphaCircleColor = alphaCircleColor;
    [self setNeedsDisplay];
}

@end
