//
//  A3LinedSlider.m
//  A3TeamWork
//
//  Created by coanyaa on 2013. 11. 20..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3LinedSlider.h"
#import "UIColor+A3Addition.h"

@implementation A3LinedSlider

- (UIImage*)createCircleThumbImage
{
    UIColor *outlineColor = [UIColor colorWithRGBRed:200 green:200 blue:200 alpha:255];
    UIColor *circleColor = [UIColor colorWithRGBRed:0 green:122 blue:255 alpha:255];
    UIColor *alphaColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.05];
    
    CGRect alphaCircleRect = CGRectMake(0, 0, 31.0, 31.0);
    CGRect outlineRect = CGRectMake(8, 8, 15, 15);
    CGRect inCircleRect = CGRectMake(12, 12, 7, 7);
    UIGraphicsBeginImageContextWithOptions(alphaCircleRect.size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [alphaColor setFill];
    CGContextFillEllipseInRect(context, alphaCircleRect);
    [[UIColor whiteColor] setFill];
    CGContextFillEllipseInRect(context, outlineRect);
    
    CGContextSetLineWidth(context, 1.0 / [[UIScreen mainScreen] scale]);
    CGContextSetStrokeColorWithColor(context, [outlineColor CGColor]);
    CGContextStrokeEllipseInRect(context, outlineRect);
    
    [circleColor setFill];
    CGContextFillEllipseInRect(context, inCircleRect);
    
    UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return retImage;
}


- (void)awakeFromNib
{
    [self setThumbImage:[self createCircleThumbImage] forState:UIControlStateNormal];
    [self setMaximumTrackTintColor:[UIColor colorWithRGBRed:191 green:191 blue:191 alpha:255]];
    [self setMinimumTrackTintColor:[UIColor colorWithRGBRed:0 green:122 blue:255 alpha:255]];
    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self awakeFromNib];
    }
    return self;
}

- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value
{
    UIImage *thumbImage = self.currentThumbImage;
    CGFloat distance = rect.size.width / (self.maximumValue - self.minimumValue);
    
//    NSLog(@"%s %@ / %@ / %f",__FUNCTION__,NSStringFromCGRect(bounds),NSStringFromCGRect(rect),value);
    return CGRectMake( rect.origin.x + ((value-self.minimumValue) * distance) - thumbImage.size.width * 0.5 , rect.origin.y + rect.size.height*0.5 - thumbImage.size.height*0.5, thumbImage.size.width, thumbImage.size.height);
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    NSInteger count = (NSInteger)(self.maximumValue - self.minimumValue);
    NSInteger lineCount = count+1;
    CGRect trackRect = [self trackRectForBounds:self.bounds];
    CGFloat distance = trackRect.size.width / count;
    CGFloat scale = [[UIScreen mainScreen] scale];
    
    CGFloat xPos = trackRect.origin.x;
    CGFloat yPos = self.bounds.size.height *0.5 - 4.0;
    
    CGContextSetStrokeColorWithColor(ctx, [self.maximumTrackTintColor CGColor]);
    CGContextSetLineWidth(ctx, 1.0 / scale);
    
    for(NSInteger i=0; i < lineCount; i++){
        CGContextMoveToPoint(ctx, xPos, yPos);
        CGContextAddLineToPoint(ctx, xPos, yPos+ 8.0);
        CGContextClosePath(ctx);
        CGContextStrokePath(ctx);
        xPos += distance;
    }
    
    [super drawRect:rect];
}

@end
