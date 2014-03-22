//
//  UILabel+BaseAlignment.m
//  A3TeamWork
//
//  Created by kihyunkim on 2014. 2. 22..
//  Copyright (c) 2014년 ALLABOUTAPPS. All rights reserved.
//

#import "UILabel+BaseAlignment.h"

@implementation UILabel (BaseAlignment)

- (void)adjustBaselineForContainView:(UIView *)containView fromBottomDistance:(float)distance
{
    [self sizeToFit];

//    // KJH
//    CGFloat scale = [[UIScreen mainScreen] scale];
//    CGFloat baseline = CGRectGetHeight(containView.frame) - distance;
//    CGPoint baselinePoint = CGPointMake(0, baseline);
//    baselinePoint = [containView convertPoint:baselinePoint toView:[self superview]];
//
//    CGFloat labelHeightWithoutDescender = CGRectGetHeight(self.frame) - self.font.descender;
//    CGFloat labelOriginY = ceilf((baselinePoint.y - labelHeightWithoutDescender) * scale) / scale;
//
//    CGRect rect = self.frame;
//    rect.origin.y = labelOriginY;
//    self.frame = rect;
    
    CGPoint bottomCenter = CGPointMake(self.bounds.size.width/2.0, self.bounds.size.height);
    
    CGPoint convertedCenter = [self convertPoint:bottomCenter  toView:containView];
    float distanceCurrent = containView.bounds.size.height - convertedCenter.y;
    float offset = distanceCurrent - distance;
    
    CGRect rect = self.frame;
    rect.origin.y += offset;
    self.frame = rect;
    
    // adjust font baseline
    CGRect newFrame = self.frame;
    newFrame.origin.y -= floor(self.font.descender);
    self.frame = newFrame;

}

- (void)adjustAscenderlineForContainView:(UIView *)containView fromTopDistance:(float)topline {
    [self sizeToFit];
    
    // KJH
    CGPoint toplinePoint = CGPointMake(0, topline);
    toplinePoint = [containView convertPoint:toplinePoint toView:[self superview]];
    
    CGRect rect = self.frame;
    rect.origin.y = toplinePoint.y - self.font.ascender;
    self.frame = rect;
}

@end
