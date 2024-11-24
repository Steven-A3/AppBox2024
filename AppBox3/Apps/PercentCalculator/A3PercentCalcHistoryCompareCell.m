//
//  A3PercentCalcHistoryCompareCell.m
//  A3TeamWork
//
//  Created by jeonghwan kim on 13. 10. 26..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3PercentCalcHistoryCompareCell.h"
#import <QuartzCore/QuartzCore.h>
#import "A3DefaultColorDefines.h"

@implementation A3PercentCalcHistoryCompareCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 100.0, 30.0)];
        _ALabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 20.0, 20.0)];
        _BLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 20.0, 20.0)];
        _factorALabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 100.0, 30.0)];
        _factorBLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 100.0, 30.0)];

        [self.contentView addSubview:_dateLabel];
        [self.contentView addSubview:_factorALabel];
        [self.contentView addSubview:_factorBLabel];
        [self.contentView addSubview:_ALabel];
        [self.contentView addSubview:_BLabel];
        
        [self setupConstraint];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setupConstraint
{
	NSNumber * leftInset = @(IS_IPHONE ? ([[UIScreen mainScreen] scale] > 2 ? 20 : 15) : 28);
	
    [_dateLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@10);
        make.leading.equalTo(leftInset);
    }];
    
    [_ALabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self->_dateLabel.bottom).with.offset(8.0);
        make.leading.equalTo(leftInset);
        make.width.equalTo(@20);
        make.height.equalTo(@20);
    }];
    
    [_BLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self->_ALabel.bottom).with.offset(2.0);
        make.leading.equalTo(leftInset);
        make.width.equalTo(@20);
        make.height.equalTo(@20);
    }];
    
    [_factorALabel makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self->_ALabel.centerY);
        make.left.equalTo(self->_ALabel.right).with.offset(10.0);
        make.right.equalTo(self.right);
    }];
    
    [_factorBLabel makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self->_BLabel.centerY);
        make.left.equalTo(self->_BLabel.right).with.offset(10.0);
        make.right.equalTo(self.right);
    }];

    _ALabel.layer.cornerRadius = _ALabel.bounds.size.width / 2.0;
    _ALabel.layer.masksToBounds = YES;
    _ALabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:11];
    _ALabel.adjustsFontSizeToFitWidth = NO;
    _ALabel.backgroundColor = [UIColor colorWithRed:123.0/255.0 green:123.0/255.0 blue:123.0/255.0 alpha:1.0];
    _ALabel.textColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
    _ALabel.textAlignment = NSTextAlignmentCenter;
    _ALabel.text = NSLocalizedString(@"Percent_Calc_SliderMarkLabel_for_A", @"A");
    _BLabel.layer.cornerRadius = _BLabel.bounds.size.width / 2.0;
    _BLabel.layer.masksToBounds = YES;
    _BLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:11];
    _BLabel.adjustsFontSizeToFitWidth = NO;
    _BLabel.backgroundColor = [UIColor colorWithRed:123.0/255.0 green:123.0/255.0 blue:123.0/255.0 alpha:1.0];
    _BLabel.textColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
    _BLabel.textAlignment = NSTextAlignmentCenter;
    _BLabel.text = NSLocalizedString(@"Percent_Calc_SliderMarkLabel_for_B", @"B");

    _dateLabel.textColor = COLOR_HISTORYCELL_DATE;
    _factorALabel.textColor = [UIColor colorWithRed:77.0/255.0 green:77.0/255.0 blue:77.0/255.0 alpha:1.0];
    _factorBLabel.textColor = [UIColor colorWithRed:77.0/255.0 green:77.0/255.0 blue:77.0/255.0 alpha:1.0];
    
    _dateLabel.font = [UIFont systemFontOfSize:12];
}

@end
