//
//  A3CurrencyTVDataCell.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 7/18/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "UITableViewController+swipeMenu.h"

@interface A3CurrencyTVDataCell : UITableViewCell <A3TableViewSwipeCellDelegate>

@property (nonatomic, strong) UITextField *valueField;
@property (nonatomic, strong) UILabel *codeLabel;
@property (nonatomic, strong) UILabel *rateLabel;
@property (nonatomic, strong) UIImageView *flagImageView;
@property (nonatomic, strong) UIView *separatorLineView;

@end
