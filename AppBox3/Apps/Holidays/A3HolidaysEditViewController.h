//
//  A3HolidaysEditViewController.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 9/1/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol A3HolidaysEditViewControllerDelegate;

@interface A3HolidaysEditViewController : UITableViewController

@property (nonatomic, weak) id<A3HolidaysEditViewControllerDelegate> delegate;
@property (nonatomic, copy) NSString *countryCode;

@end

@protocol A3HolidaysEditViewControllerDelegate <NSObject>

- (void)editViewController:(UIViewController *)viewController willDismissViewControllerWithDataUpdated:(BOOL)updated;

@end
