//
//  A3StatisticsViewCellController.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 10/19/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface A3StatisticsViewCellController : UIViewController

@property (nonatomic, strong) IBOutlet UIImageView *titleImage;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *dateLabel;
@property (nonatomic, strong) IBOutlet UILabel *valueLabel;
@property (nonatomic, strong) UIView *valueView;

@end
