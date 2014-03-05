//
//  A3HolidaysCountryViewCell.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/30/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMMoveTableViewCell.h"

@protocol A3HolidaysPageViewControllerProtocol;

@interface A3HolidaysCountryViewCell : FMMoveTableViewCell

@property (nonatomic, copy) NSString *countryCode;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIImageView *locationImageView;
@property (nonatomic, weak) id<A3HolidaysPageViewControllerProtocol> pageViewController;

@end
