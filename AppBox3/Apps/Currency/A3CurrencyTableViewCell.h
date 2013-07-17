//
//  A3CurrencyTableViewCell.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 7/6/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface A3CurrencyTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UITextField *valueField;
@property (nonatomic, weak) IBOutlet UILabel *codeLabel;
@property (nonatomic, weak) IBOutlet UILabel *rateLabel;
@property (nonatomic, weak) IBOutlet UIImageView *flagImageView;
@property (nonatomic, strong) UIView *separatorLineView;

@end
