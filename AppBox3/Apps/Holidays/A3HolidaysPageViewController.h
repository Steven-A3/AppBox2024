//
//  A3HolidaysPageViewController.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 9/15/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol A3HolidaysPageViewControllerProtocol <NSObject>
- (void)setNavigationBarHidden:(BOOL)hidden;
- (void)updatePhotoLabelText;
- (NSString *)stringFromDate:(NSDate *)date;
- (NSString *)lunarStringFromDate:(NSDate *)date;

@end

@interface A3HolidaysPageViewController : UIViewController

@end
