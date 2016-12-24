//
//  A3GradientView.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 10/23/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface A3GradientView : UIView

@property (nonatomic, strong) 	NSArray *gradientColors;
@property (nonatomic, strong)	NSArray *locations;
@property (nonatomic)			IBInspectable BOOL vertical;
@property (nonatomic, strong)	UIColor	*startColor, *endColor;

@end
