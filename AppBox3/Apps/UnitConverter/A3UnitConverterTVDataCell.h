//
//  A3UnitConverterTVDataCell.h
//  A3TeamWork
//
//  Created by kihyunkim on 13. 10. 13..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "UITableViewController+swipeMenu.h"

typedef NS_ENUM(NSInteger, UnitInputType) {
    UnitInput_Normal = 0,
    UnitInput_Fraction,
    UnitInput_FeetInch,
};

@protocol A3UnitConverterMenuDelegate <NSObject>
- (void)menuAdded;
- (void)swapActionForCell:(UITableViewCell *)cell;
- (void)shareActionForCell:(UITableViewCell *)cell sender:(id)sender;
- (void)deleteActionForCell:(UITableViewCell *)cell;
@end

@interface A3UnitConverterTVDataCell : UITableViewCell <A3TableViewSwipeCellDelegate>

@property (nonatomic, assign) UnitInputType inputType;
@property (nonatomic, strong) UITextField *valueField;
@property (nonatomic, strong) UITextField *value2Field;
@property (nonatomic, strong) UILabel *valueLabel;
@property (nonatomic, strong) UILabel *value2Label;
@property (nonatomic, strong) UILabel *codeLabel;
@property (nonatomic, strong) UILabel *rateLabel;
@property (nonatomic, strong) UIImageView *flagImageView;
@property (nonatomic, strong) UIView *separatorLineView;
@property (nonatomic, weak) id<A3UnitConverterMenuDelegate>	menuDelegate;

@end
