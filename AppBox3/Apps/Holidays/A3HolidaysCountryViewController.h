//
//  A3HolidaysCountryViewController.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/30/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol A3HolidaysCountryViewControllerDelegate;
@protocol A3HolidaysPageViewControllerProtocol;

@interface A3HolidaysCountryViewController : UIViewController

@property (nonatomic, weak) id<A3HolidaysPageViewControllerProtocol> pageViewController;
@property (nonatomic, weak) id<A3HolidaysCountryViewControllerDelegate> delegate;

@end

@protocol A3HolidaysCountryViewControllerDelegate <NSObject>

- (void)viewController:(UIViewController *)viewController didFinishPickingCountry:(NSString *)countryCode dataChanged:(BOOL)dataChanged;

@end
