//
//  A3TipCalcCircle.m
//  A3TeamWork
//
//  Created by Sanghyun Yu on 2013. 11. 7..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3TipCalcCircle.h"



@implementation A3TipCalcCircle

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0]];
}

- (void)drawRect:(CGRect)rect
{
    {
        CGRect borderRect = rect;
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetRGBFillColor(context, 0, 0, 0, 0.1);
        CGContextFillEllipseInRect (context, borderRect);
        CGContextFillPath(context);
    }
    {
        CGRect borderRect = CGRectMake((rect.size.width - (rect.size.width/2.5))/2,
                                       (rect.size.height - (rect.size.height/2.5))/2,
                                       rect.size.width / 2.5,
                                       rect.size.height / 2.5);
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextSetRGBFillColor(context, 1, 1, 1, 1.0);
        CGContextFillEllipseInRect (context, borderRect);
        CGContextFillPath(context);
    }
    {
        CGRect borderRect = CGRectMake((rect.size.width - (rect.size.width/5.0))/2,
                                       (rect.size.height - (rect.size.height/5.0))/2,
                                       rect.size.width / 5.0,
                                       rect.size.height / 5.0);
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextSetRGBFillColor(context, 235.0/255.0, 45.0/255.0, 87.0/255.0, 1.0);
        CGContextFillEllipseInRect (context, borderRect);
        CGContextFillPath(context);
    }
}

@end
