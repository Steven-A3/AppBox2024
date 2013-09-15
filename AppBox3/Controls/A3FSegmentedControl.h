//
//  A3FSegmentedControl.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 9/15/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface A3FSegmentedControl : UIControl

@property (nonatomic, strong) NSArray *items;
@property (nonatomic)	NSUInteger selectedSegmentIndex;
@property (nonatomic, strong) NSArray *states;

@end
