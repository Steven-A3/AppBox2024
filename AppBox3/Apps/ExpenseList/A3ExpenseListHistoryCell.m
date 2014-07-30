//
//  A3ExpenseListHistoryCell.m
//  A3TeamWork
//
//  Created by jeonghwan kim on 13. 11. 21..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3ExpenseListHistoryCell.h"
#import "ExpenseListBudget.h"
#import "NSDate+formatting.h"
#import "A3DefaultColorDefines.h"
#import "NSDate+TimeAgo.h"

@interface A3ExpenseListHistoryCell()

@property (nonatomic, strong) UILabel *usedAmountLabel;     // 좌상단, 사용한 금액.
@property (nonatomic, strong) UILabel *dateLabel;           // 날짜
@property (nonatomic, strong) UILabel *resultAmountLabel;   // 좌하단, 남은 예산.

@end

@implementation A3ExpenseListHistoryCell

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
    _usedAmountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _dateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _resultAmountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    
    _usedAmountLabel.textColor = [UIColor blackColor];
    _dateLabel.textColor = [UIColor colorWithRed:142.0/255.0 green:142.0/255.0 blue:147.0/255.0 alpha:1.0];
    _resultAmountLabel.textColor = [UIColor colorWithRed:77.0/255.0 green:77.0/255.0 blue:77.0/255.0 alpha:1.0];
    
    [self.contentView addSubview:_usedAmountLabel];
    [self.contentView addSubview:_dateLabel];
    [self.contentView addSubview:_resultAmountLabel];

    _resultAmountLabel.adjustsFontSizeToFitWidth = YES;
}

-(void)setupConstraintLayout {
    [_usedAmountLabel makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(@15);
        make.trailing.equalTo(_dateLabel.left);
        make.top.equalTo(@10);
    }];
    [_dateLabel makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.contentView.right).with.offset(-15);
        make.top.equalTo(@10);
    }];
    [_resultAmountLabel makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(@15);
        make.bottom.equalTo(self.bottom).with.offset(-10.0);
        make.right.equalTo(self.right).with.offset(-15);
    }];
}

-(void)adjustConstraintLaout {
    _usedAmountLabel.font = [UIFont systemFontOfSize:15];
    _dateLabel.font = [UIFont systemFontOfSize:12];
    _resultAmountLabel.font = [UIFont systemFontOfSize:13];
    
    [_usedAmountLabel sizeToFit];
    [_dateLabel sizeToFit];
    [_resultAmountLabel sizeToFit];
}

- (void)setExpenseBudgetData:(ExpenseListBudget *)aBudget currencyFormatter:(NSNumberFormatter *)nFormatter {
    NSDateFormatter *dFormatter = [NSDateFormatter new];
    [dFormatter setDateStyle:NSDateFormatterShortStyle];
    [dFormatter setTimeStyle:NSDateFormatterNoStyle];
    
    _usedAmountLabel.text = [nFormatter stringFromNumber:aBudget.usedAmount];
    _dateLabel.text = [aBudget.updateDate timeAgo];
    
    NSArray *strings;
    if (aBudget.usedAmount.floatValue > aBudget.totalAmount.floatValue) {
		strings = @[
				[nFormatter stringFromNumber: @(aBudget.usedAmount.floatValue - aBudget.totalAmount.floatValue) ],
				NSLocalizedString(@" over of ", @" over of "),
				[nFormatter stringFromNumber: aBudget.totalAmount]
		];
        
        _resultAmountLabel.text = [strings componentsJoinedByString:@""];
        
        NSMutableAttributedString *savedPriceAttribute = [[NSMutableAttributedString alloc] initWithAttributedString:_resultAmountLabel.attributedText];
        [savedPriceAttribute addAttribute: NSForegroundColorAttributeName
                                    value: COLOR_NEGATIVE
                                    range: NSMakeRange(0, ((NSString *)strings[0]).length)];

        _resultAmountLabel.attributedText = savedPriceAttribute;
    } else {
        strings = @[
				[nFormatter stringFromNumber: @(aBudget.totalAmount.floatValue - aBudget.usedAmount.floatValue) ],
				NSLocalizedString(@" left of ", @" left of "),
				[nFormatter stringFromNumber: aBudget.totalAmount]];
        
        _resultAmountLabel.text = [strings componentsJoinedByString:@""];
        
        NSMutableAttributedString *savedPriceAttribute = [[NSMutableAttributedString alloc] initWithAttributedString:_resultAmountLabel.attributedText];
        [savedPriceAttribute addAttribute: NSForegroundColorAttributeName
                                    value: A3DefaultColorHistoryPositiveText
                                    range: NSMakeRange(0, ((NSString *)strings[0]).length)];
        
        _resultAmountLabel.attributedText = savedPriceAttribute;
    }
}

@end
