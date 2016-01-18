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
	CGFloat leading = IS_IPHONE ? ([[UIScreen mainScreen] scale] > 2 ? 20 : 15) : 28;

    [_usedAmountLabel makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(self.left).with.offset(leading);
        make.right.equalTo(_dateLabel.left);
        make.top.equalTo(@10);
    }];
    [_dateLabel makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.right).with.offset(-leading);
        make.top.equalTo(@10);
    }];
    [_resultAmountLabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.left).with.offset(leading);
        make.bottom.equalTo(self.bottom).with.offset(-10.0);
        make.right.equalTo(self.right).with.offset(-leading);
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
    if (aBudget.usedAmount.doubleValue > aBudget.totalAmount.doubleValue) {
		strings = @[
				[nFormatter stringFromNumber: @(aBudget.usedAmount.doubleValue - aBudget.totalAmount.doubleValue) ],
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
				[nFormatter stringFromNumber: @(aBudget.totalAmount.doubleValue - aBudget.usedAmount.doubleValue) ],
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
