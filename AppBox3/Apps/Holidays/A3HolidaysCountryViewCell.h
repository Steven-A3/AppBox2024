//
//  A3HolidaysCountryViewCell.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/30/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMMoveTableViewCell.h"

@interface A3HolidaysCountryViewCell : FMMoveTableViewCell

@property (nonatomic, copy) NSString *countryCode;
@property (nonatomic, strong) UIImageView *backgroundImageView;

@property (nonatomic, strong) UIImageView *locationImageView;
@end
