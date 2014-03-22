//
//  UILabel+BaseAlignment.h
//  A3TeamWork
//
//  Created by kihyunkim on 2014. 2. 22..
//  Copyright (c) 2014년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (BaseAlignment)

- (void)adjustBaselineForContainView:(UIView *)containView fromBottomDistance:(float)distance;
- (void)adjustAscenderlineForContainView:(UIView *)containView fromTopDistance:(float)distance;

@end
