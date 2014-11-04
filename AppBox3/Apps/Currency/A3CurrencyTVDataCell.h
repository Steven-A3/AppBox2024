//
//  A3CurrencyTVDataCell.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 7/18/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3FMMoveTableViewController.h"
#import "A3CurrencyTableViewCell.h"

@protocol A3CurrencyMenuDelegate <NSObject>
- (void)menuAdded;
- (void)swapActionForCell:(UITableViewCell *)cell;
- (void)chartActionForCell:(UITableViewCell *)cell;
- (void)shareActionForCell:(UITableViewCell *)cell sender:(id)sender;
- (void)deleteActionForCell:(UITableViewCell *)cell;
@end

@interface A3CurrencyTVDataCell : A3CurrencyTableViewCell <A3FMMoveTableViewSwipeCellDelegate>

@property (nonatomic, strong) UITextField *valueField;
@property (nonatomic, strong) UILabel *codeLabel;
@property (nonatomic, strong) UILabel *rateLabel;
@property (nonatomic, strong) UIImageView *flagImageView;
@property (nonatomic, strong) UIView *separatorLineView;
@property (nonatomic, weak) id<A3CurrencyMenuDelegate>	menuDelegate;
@property (nonatomic, strong) MASConstraint *rightMargin;

@end
