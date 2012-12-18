//
//  A3NotificationCell.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 12/10/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class A3YellowXButton;

@interface A3NotificationCell : UITableViewCell

@property (nonatomic, strong) UILabel *messageText;
@property (nonatomic, strong) UILabel *detailText;
@property (nonatomic, strong) UILabel *detailText2;
@property (nonatomic, strong) A3YellowXButton *xButton;

- (void)layoutDetailTexts;


@end
