//
//  A3WalletItemTitleCell.h
//  AppBox3
//
//  Created by A3 on 4/19/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface A3WalletItemTitleCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UITextField *titleTextField;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) UIButton *favoriteButton;

@end
