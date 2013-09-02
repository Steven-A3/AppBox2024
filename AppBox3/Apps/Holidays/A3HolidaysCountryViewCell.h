//
//  A3HolidaysCountryViewCell.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/30/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMMoveTableViewCell.h"

@class A3FlickrImageView;

@interface A3HolidaysCountryViewCell : FMMoveTableViewCell

@property (nonatomic, copy) NSString *countryCode;
@property (nonatomic, strong) A3FlickrImageView *backgroundImageView;

@end
