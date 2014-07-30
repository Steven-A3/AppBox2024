//
//  A3SalesCalcHistoryCell.m
//  A3TeamWork
//
//  Created by jeonghwan kim on 13. 11. 17..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3SalesCalcHistoryCell.h"
#import "A3SalesCalcCalculator.h"
#import "A3SalesCalcData.h"
#import "NSDate+formatting.h"
#import "A3DefaultColorDefines.h"
#import "NSDate+TimeAgo.h"

@interface A3SalesCalcHistoryCell()

@property (nonatomic, strong) UILabel *salePriceLabel;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UILabel *resultPriceLabel;

@end

@implementation A3SalesCalcHistoryCell

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
    [self adjustConstraintLaout];
    [super layoutSubviews];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)initializeSubviews {
    _salePriceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _dateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _resultPriceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    
    _salePriceLabel.textColor = [UIColor blackColor];
    _dateLabel.textColor = COLOR_HISTORYCELL_DATE;
    _resultPriceLabel.textColor = [UIColor colorWithRed:77.0/255.0 green:77.0/255.0 blue:77.0/255.0 alpha:1.0];
    
    [self.contentView addSubview:_salePriceLabel];
    [self.contentView addSubview:_salePriceLabel];
    [self.contentView addSubview:_dateLabel];
    [self.contentView addSubview:_resultPriceLabel];
    
    _resultPriceLabel.adjustsFontSizeToFitWidth = YES;
}

-(void)setupConstraintLayout {
    [_salePriceLabel makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(@15);
        make.baseline.equalTo(self.bottom).with.offset(-40);
    }];
    
    [_dateLabel makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(@-15);
        make.baseline.equalTo(self.bottom).with.offset(-40);
    }];
    
    [_resultPriceLabel makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(@15);
        make.trailing.equalTo(@-15);
        make.baseline.equalTo(self.bottom).with.offset(-13);
        make.right.equalTo(@-15);
    }];
}

-(void)adjustConstraintLaout {
    _salePriceLabel.font = [UIFont systemFontOfSize:15];
    _dateLabel.font = [UIFont systemFontOfSize:12];
    _resultPriceLabel.font = [UIFont systemFontOfSize:13];
    
    [_salePriceLabel sizeToFit];
    [_dateLabel sizeToFit];
    [_resultPriceLabel sizeToFit];
}

-(void)setSalesCalcData:(A3SalesCalcData *)aData {
    NSNumberFormatter *nFormatter = [NSNumberFormatter new];
    [nFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    NSNumber *salePriceWithTax = @([[A3SalesCalcCalculator salePriceWithoutTaxForCalcData:aData] doubleValue] + [[A3SalesCalcCalculator salePriceTaxForCalcData:aData] doubleValue]);
    NSNumber *originalPriceWithTax = [A3SalesCalcCalculator originalPriceWithTax:aData];
    NSNumber *savedAmount = [A3SalesCalcCalculator savedTotalAmountForCalcData:aData];
    
    _salePriceLabel.text = [nFormatter stringFromNumber:salePriceWithTax];
    _dateLabel.text = [aData.historyDate timeAgo];
    
    NSArray *strings;
    strings = @[[nFormatter stringFromNumber:savedAmount],
			NSLocalizedString(@" saved of ", @" saved of "),
                [nFormatter stringFromNumber:originalPriceWithTax]];
    _resultPriceLabel.text = [strings componentsJoinedByString:@""];
    NSMutableAttributedString *savedPriceAttribute = [[NSMutableAttributedString alloc] initWithAttributedString:_resultPriceLabel.attributedText];
    [savedPriceAttribute addAttribute: NSForegroundColorAttributeName
                                value: A3DefaultColorHistoryPositiveText
                                range: NSMakeRange(0, ((NSString *)strings[0]).length)];
    [savedPriceAttribute addAttribute: NSForegroundColorAttributeName
                                value: [UIColor colorWithRed:77.0/255.0 green:77.0/255.0 blue:77.0/255.0 alpha:1.0]
								range: NSMakeRange(((NSString *)strings[0]).length, ((NSString *)strings[1]).length+((NSString *)strings[2]).length)];

    _resultPriceLabel.attributedText = savedPriceAttribute;
}

@end
