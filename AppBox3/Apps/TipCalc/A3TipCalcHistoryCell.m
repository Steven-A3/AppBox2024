//
//  A3TipCalcHistoryCell.m
//  A3TeamWork
//
//  Created by dotnetguy83 on 2/23/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "A3TipCalcHistoryCell.h"
#import "NSDate+TimeAgo.h"
#import "A3DefaultColorDefines.h"
#import "TipCalcHistory.h"
#import "TipCalcRecent.h"
#import "A3TipCalcDataManager.h"

@interface A3TipCalcHistoryCell ()

@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UILabel *resultLabel;
@property (nonatomic, strong) TipCalcHistory *historyData;

@end


@implementation A3TipCalcHistoryCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initializeSubviews];
        [self setupConstraintLayout];
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    [self adjustConstraintLayoutForData:_historyData];
    [super layoutSubviews];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)initializeSubviews {
    _dateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _resultLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    
    _dateLabel.textColor = COLOR_HISTORYCELL_DATE;
    _resultLabel.textColor = [UIColor colorWithRed:77.0/255.0 green:77.0/255.0 blue:77.0/255.0 alpha:1.0];

    [self.contentView addSubview:_dateLabel];
    [self.contentView addSubview:_resultLabel];

    _resultLabel.adjustsFontSizeToFitWidth = YES;
}

-(void)setupConstraintLayout {
    [_dateLabel makeConstraints:^(MASConstraintMaker *make) {
        //make.trailing.equalTo(@-15);
        make.leading.equalTo(@15);
        make.baseline.equalTo(self.bottom).with.offset(-41);
    }];
    
    [_resultLabel makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(@15);
        make.trailing.equalTo(@-15);
        make.baseline.equalTo(self.bottom).with.offset(-13);
    }];
}

-(void)adjustConstraintLayoutForData:(TipCalcHistory *)aHistory {
    if (![aHistory labelTip] || ![aHistory labelTotal]) {
        return;
    }
    
    NSNumberFormatter *nFormatter = [NSNumberFormatter new];
    [nFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    A3TipCalcDataManager *dataManager = [[A3TipCalcDataManager alloc] init];
    [dataManager setTipCalcDataForHistoryData:aHistory];
    
    double dTip = 0.0;
    dTip = [[dataManager tipValueWithRounding] doubleValue];

    NSString *tip = [dataManager currencyStringFromDouble:dTip];
    

    double dTotal = 0.0;
    dTotal = [[dataManager totalBeforeSplitWithTax] doubleValue];
    
    NSString *total = [dataManager currencyStringFromDouble:dTotal];
    NSArray *strings = @[tip, NSLocalizedString(@" of ", @" of "), total];
    
    _dateLabel.text = [aHistory.updateDate timeAgo];
    _resultLabel.text = [strings componentsJoinedByString:@""];
    _dateLabel.textColor = COLOR_HISTORYCELL_DATE;
    _dateLabel.font = [UIFont systemFontOfSize:12];
    
    NSMutableAttributedString *resultAttribute = [[NSMutableAttributedString alloc] initWithAttributedString:_resultLabel.attributedText];
    [resultAttribute addAttribute: NSFontAttributeName
                            value: [UIFont systemFontOfSize:15]
                            range: NSMakeRange(0, ((NSString *)strings[0]).length)];
    [resultAttribute addAttribute: NSForegroundColorAttributeName
                            value: COLOR_NEGATIVE
                            range: NSMakeRange(0, ((NSString *)strings[0]).length)];
    
    [resultAttribute addAttribute: NSFontAttributeName
                            value: [UIFont systemFontOfSize:13]
                            range: NSMakeRange(((NSString *)strings[0]).length, ((NSString *)strings[1]).length + ((NSString *)strings[2]).length)];
    [resultAttribute addAttribute: NSForegroundColorAttributeName
                            value: [UIColor colorWithRed:77/255.0 green:77/255.0 blue:77/255.0 alpha:1.0]
                            range: NSMakeRange(((NSString *)strings[0]).length, ((NSString *)strings[1]).length + ((NSString *)strings[2]).length)];
    
    _resultLabel.attributedText = resultAttribute;
}

#pragma mark -

-(void)setHistoryData:(TipCalcHistory *)aHistory {
    _historyData = aHistory;
}

@end
