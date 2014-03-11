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

@end
