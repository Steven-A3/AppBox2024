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

-(void)layoutSubviews
{
    [super layoutSubviews];

//    _factorALabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
//    _factorBLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
//    _factorALabel.adjustsFontSizeToFitWidth = YES;
//    _factorBLabel.adjustsFontSizeToFitWidth = YES;
//    [_factorALabel sizeToFit];
//    [_factorBLabel sizeToFit];
    
    [super layoutSubviews];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setupConstraint
{
    NSNumber * leftInset = @15;
//    if (IS_IPAD) {
//        leftInset = @28;
//    }
    
    [_dateLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@10);
        make.leading.equalTo(leftInset);
    }];
    
    [_ALabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_dateLabel.bottom).with.offset(8.0);
        make.leading.equalTo(leftInset);
        make.width.equalTo(@20);
        make.height.equalTo(@20);
    }];
    
    [_BLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_ALabel.bottom).with.offset(2.0);
        make.leading.equalTo(leftInset);
        make.width.equalTo(@20);
        make.height.equalTo(@20);
    }];
    
    [_factorALabel makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_ALabel.centerY);
        make.leading.equalTo(_ALabel.right).with.offset(10.0);
        make.trailing.equalTo(self.right);
    }];
    
    [_factorBLabel makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_BLabel.centerY);
        make.leading.equalTo(_BLabel.right).with.offset(10.0);
        make.trailing.equalTo(self.right);
        //make.trailing.equalTo(self.right).with.offset(-15.0);
    }];

    _ALabel.layer.cornerRadius = _ALabel.bounds.size.width / 2.0;
    _ALabel.layer.masksToBounds = YES;
    _ALabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:11];
    _ALabel.adjustsFontSizeToFitWidth = NO;
    _ALabel.backgroundColor = [UIColor colorWithRed:123.0/255.0 green:123.0/255.0 blue:123.0/255.0 alpha:1.0];
    _ALabel.textColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
    _ALabel.textAlignment = NSTextAlignmentCenter;
    _ALabel.text = @"A";
    _BLabel.layer.cornerRadius = _BLabel.bounds.size.width / 2.0;
    _BLabel.layer.masksToBounds = YES;
    _BLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:11];
    _BLabel.adjustsFontSizeToFitWidth = NO;
    _BLabel.backgroundColor = [UIColor colorWithRed:123.0/255.0 green:123.0/255.0 blue:123.0/255.0 alpha:1.0];
    _BLabel.textColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
    _BLabel.textAlignment = NSTextAlignmentCenter;
    _BLabel.text = @"B";

    _dateLabel.textColor = COLOR_HISTORYCELL_DATE;
    _factorALabel.textColor = [UIColor colorWithRed:77.0/255.0 green:77.0/255.0 blue:77.0/255.0 alpha:1.0];
    _factorBLabel.textColor = [UIColor colorWithRed:77.0/255.0 green:77.0/255.0 blue:77.0/255.0 alpha:1.0];
    
    _dateLabel.font = [UIFont systemFontOfSize:12];
//    _factorALabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
//    _factorBLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
//    _factorALabel.adjustsFontSizeToFitWidth = YES;
//    _factorBLabel.adjustsFontSizeToFitWidth = YES;
    
}

@end
