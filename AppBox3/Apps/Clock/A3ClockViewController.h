//
//  A3ClockViewController.h
//  A3TeamWork
//
//  Created by Sanghyun Yu on 2013. 11. 20..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class A3ClockInfo;
@class A3ClockDataManager;
@protocol A3ClockDataManagerDelegate;

@interface A3ClockViewController : UIViewController <A3ClockDataManagerDelegate>

@property (nonatomic, strong) A3ClockInfo *clockInfo;
@property (nonatomic, strong) UIColor* clrCurrent;
@property (nonatomic, weak) A3ClockDataManager *clockDataManager;

- (instancetype)initWithClockDataManager:(A3ClockDataManager *)clockDataManager;

- (void)setupSubviews;

- (void)changeColor:(UIColor *)color;
@end
