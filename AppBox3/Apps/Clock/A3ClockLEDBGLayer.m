//
//  A3ClockLEDBGLayer.m
//  A3TeamWork
//
//  Created by Sanghyun Yu on 2013. 11. 29..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3ClockLEDBGLayer.h"

@implementation A3ClockLEDBGLayer

+ (CAGradientLayer*) whiteGradient {
    
    UIColor *colorOne = [UIColor colorWithRed:(255.f/255.f) green:(255.f/255.f) blue:(255.f/255.f) alpha:0.f];
    UIColor *colorTwo = [UIColor colorWithRed:(255.f/255.f)  green:(255.f/255.f)  blue:(255.f/255.f)  alpha:0.05f];
    UIColor *colorThree = [UIColor colorWithRed:(255.f/255.f)  green:(255.f/255.f)  blue:(255.f/255.f)  alpha:0.f];
    
    NSArray *colors = [NSArray arrayWithObjects:(id)colorOne.CGColor, colorTwo.CGColor,colorThree, nil];
    NSNumber *stopOne = [NSNumber numberWithFloat:0.0f];
    NSNumber *stopTwo = [NSNumber numberWithFloat:0.5f];
    NSNumber *stopThree = [NSNumber numberWithFloat:1.0f];
    
    
    NSArray *locations = [NSArray arrayWithObjects:stopOne, stopTwo,stopThree, nil];
    
    CAGradientLayer *headerLayer = [CAGradientLayer layer];
    headerLayer.colors = colors;
    headerLayer.locations = locations;
    //
    return headerLayer;
    
}

@end
