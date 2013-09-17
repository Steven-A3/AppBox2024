//
//  A3HolidaysPageContentViewController.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 9/15/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "A3HolidaysPageViewController.h"

@interface A3HolidaysPageContentViewController : UIViewController

@property (nonatomic, copy) NSString *countryCode;
@property (nonatomic, weak) id<A3HolidaysPageViewControllerDelegate> pageViewController;

- (instancetype)initWithCountryCode:(NSString *)countryCode;

- (void)reloadDataRedrawImage:(BOOL)redrawImage;

- (void)updateTableHeaderView;
@end
