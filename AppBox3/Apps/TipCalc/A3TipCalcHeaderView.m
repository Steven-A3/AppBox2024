//
//  A3TipCalcHeaderView.m
//  A3TeamWork
//
//  Created by Sanghyun Yu on 2013. 11. 5..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3TipCalcHeaderView.h"
#import "A3TipCalcDataManager.h"
#import "UIViewController+A3AppCategory.h"
#import "NSUserDefaults+A3Defaults.h"
#import "A3RoundedSideButton.h"
#import "A3OverlappedCircleView.h"
#import "A3DefaultColorDefines.h"
#import "UIImage+JHExtension.h"
#import "A3AppDelegate+appearance.h"

@implementation A3TipCalcHeaderView
{
    UIView *_sliderBaseLineView;
    UIView *_sliderGaugeLineView;
    UIView *_bottomGrayLineView;
    NSArray *_sliderMeterViews;
    NSArray *_sliderMeterLabelViews;
    A3OverlappedCircleView *_sliderThumbView;
    UILabel *_tipLabel;
    UILabel *_totalLabel;
    // Constraints
    MASConstraint *_sliderThumbLeadingConst;
    MASConstraint *_totalLabelTrailingConst;
    NSArray *_meterViewLeadingConstArray;
    NSArray *_meterLabelBaselineConstArray;
}

#pragma mark - initialize

-(id)initWithFrame:(CGRect)frame dataManager:(A3TipCalcDataManager *)dataManager {
    self = [super initWithFrame:frame];
    
    if (self) {
		self.dataManager = dataManager;

        [self initializeSubViews];
        [self setupConstraints];
        [self setResult:nil];
    }
    
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    [self setResult:self.dataManager.tipCalcData];
    [self adjustMeterViewConstraints];
    
    _beforeSplitButton.hidden = [self.dataManager isSplitOptionOn] == YES ? NO : YES;
    _perPersonButton.hidden = [self.dataManager isSplitOptionOn] == YES ? NO : YES;
    _beforeSplitButton.titleLabel.font = IS_IPHONE ? [UIFont systemFontOfSize:12] : [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    _perPersonButton.titleLabel.font = IS_IPHONE ? [UIFont systemFontOfSize:12] : [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    
    [super layoutSubviews];
    
    if ([self.dataManager tipSplitOption] == TipSplitOption_BeforeSplit) {
        _beforeSplitButton.selected = YES;
        _perPersonButton.selected = NO;
    }
    else {
        _beforeSplitButton.selected = NO;
        _perPersonButton.selected = YES;
    }
}

- (void)initializeSubViews {
    
    self.backgroundColor = COLOR_HEADERVIEW_BG;
    
    // Buttons
    _beforeSplitButton = [A3RoundedSideButton buttonWithType:UIButtonTypeCustom];
    _perPersonButton = [A3RoundedSideButton buttonWithType:UIButtonTypeCustom];
    _detailInfoButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[self addSubview:_beforeSplitButton];
	[self addSubview:_perPersonButton];
	[self addSubview:_detailInfoButton];
	[_beforeSplitButton setTitle:@"Before Split" forState:UIControlStateNormal];
	[_beforeSplitButton setTitleColor:[A3AppDelegate instance].themeColor forState:UIControlStateNormal];
	[_perPersonButton setTitle:@"Per Person" forState:UIControlStateNormal];
	[_perPersonButton setTitleColor:[A3AppDelegate instance].themeColor forState:UIControlStateNormal];
    _detailInfoButton.frame = CGRectMake(0.0, 0.0, 44.0, 44.0);
    [_detailInfoButton setImage:[UIImage imageNamed:@"information"] forState:UIControlStateNormal];
    [_detailInfoButton setImage:[UIImage getImageToGreyImage:[UIImage imageNamed:@"information"] grayColor:COLOR_DISABLE_POPOVER] forState:UIControlStateDisabled];
    
    // Layout Views
    _sliderBaseLineView = [[UIView alloc] initWithFrame:CGRectZero];
    _sliderGaugeLineView = [[UIView alloc] initWithFrame:CGRectZero];
    _bottomGrayLineView = [[UIView alloc] initWithFrame:CGRectZero];
    [self addSubview:_sliderBaseLineView];
    [self addSubview:_sliderGaugeLineView];
    [self addSubview:_bottomGrayLineView];
    _sliderBaseLineView.backgroundColor = COLOR_DEFAULT_GRAY;
    _bottomGrayLineView.backgroundColor = COLOR_TABLE_SEPARATOR;
    _sliderGaugeLineView.backgroundColor = COLOR_NEGATIVE;
    if (IS_IPAD) {
        NSMutableArray *meterArray = [[NSMutableArray alloc] init];
        NSMutableArray *labelArray = [[NSMutableArray alloc] init];
        for (int i=0; i<5; i++) {
            UIView *aView = [[UIView alloc] initWithFrame:CGRectZero];
            UILabel *aLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            aView.backgroundColor = COLOR_DEFAULT_GRAY;
            aLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
            aLabel.text = [NSString stringWithFormat:@"%u%%", (i + 1) * 20];
            aLabel.textColor = COLOR_DEFAULT_GRAY;
            [self addSubview:aView];
            [self addSubview:aLabel];
            [meterArray addObject:aView];
            [labelArray addObject:aLabel];
        }
        _sliderMeterViews = [NSArray arrayWithArray:meterArray];
        _sliderMeterLabelViews = [NSArray arrayWithArray:labelArray];
    }
    
    _sliderThumbView = [[A3OverlappedCircleView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    _sliderThumbView.centerColor = COLOR_NEGATIVE;
    [self addSubview:_sliderThumbView];
    
    // Labels
    _tipLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _totalLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self addSubview:_tipLabel];
    [self addSubview:_totalLabel];
}

- (void)setupConstraints {
    // Buttons
    [_beforeSplitButton makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(IS_IPHONE ? @45 : @220);
        make.bottom.equalTo(self.bottom).with.offset(-16);
        make.width.equalTo(IS_IPHONE ? @80 : @110);
        make.height.equalTo(@20);
    }];
    
    [_perPersonButton makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(IS_IPHONE ? @-45 : @-220);
        make.bottom.equalTo(self.bottom).with.offset(-16);
        make.width.equalTo(IS_IPHONE ? @80 : @110);
        make.height.equalTo(@20);
    }];
    
    [_detailInfoButton makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.right).with.offset(-4);
        make.centerY.equalTo(_totalLabel.centerY);
        make.width.equalTo(@44);
        make.height.equalTo(@44);
    }];
    
    // Layout Views
    [_sliderBaseLineView makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.left);
        make.trailing.equalTo(self.right);
        make.top.equalTo(IS_IPHONE ? @40 : @65);
        make.height.equalTo(@5);
    }];
    
    [_sliderGaugeLineView makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.left);
        make.trailing.equalTo(_sliderThumbView.centerX);
        make.top.equalTo(IS_IPHONE ? @40 : @65);
        make.height.equalTo(@5);
    }];
    
    [_bottomGrayLineView makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.left);
        make.trailing.equalTo(self.right);
        make.bottom.equalTo(self.bottom);
        make.height.equalTo(IS_RETINA ? @0.5 : @1);
    }];
    
    if (IS_IPAD) {
        NSMutableArray *conts = [NSMutableArray new];
        [_sliderMeterViews enumerateObjectsUsingBlock:^(UIView *aView, NSUInteger idx, BOOL *stop) {
            [aView makeConstraints:^(MASConstraintMaker *make) {
                [conts addObject:make.leading.equalTo( @(self.frame.size.width / 5.0 * (idx+1)) )];
                make.width.equalTo(IS_RETINA? @0.5 : @1);
                make.height.equalTo(@18);
                make.top.equalTo(_sliderBaseLineView.bottom);
            }];
        }];
        _meterViewLeadingConstArray = conts;
        
        NSMutableArray *baselineConsts = [NSMutableArray new];
        [_sliderMeterLabelViews enumerateObjectsUsingBlock:^(UILabel *aLabel, NSUInteger idx, BOOL *stop) {
            [aLabel makeConstraints:^(MASConstraintMaker *make) {
                make.trailing.equalTo(((UIView *)_sliderMeterViews[idx]).left).with.offset(IS_RETINA ? -4.5 : -5);
                //[baselineConsts addObject: make.baseline.equalTo(self.top).with.offset(IS_RETINA ? 83: 82) ];
                [baselineConsts addObject: make.baseline.equalTo(self.top).with.offset(83) ];
                //[baselineConsts addObject: make.baseline.equalTo(self.top).with.offset(IS_RETINA ? 93.5 : 93 ) ];
            }];
        }];
        _meterLabelBaselineConstArray = baselineConsts;
    }
    
    [_sliderThumbView makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@44);
        make.height.equalTo(@44);
        make.centerY.equalTo(_sliderBaseLineView.centerY);
        _sliderThumbLeadingConst = make.leading.equalTo(self.left).with.offset(-22);
    }];
    
    // Labels
    [_tipLabel makeConstraints:^(MASConstraintMaker *make) {
		//make.baseline.equalTo(self.top).with.offset(IS_IPHONE ? 30: (IS_RETINA? 53.5 : 53) );
        make.baseline.equalTo(self.top).with.offset(IS_IPHONE ? 31 : 54 );
		make.leading.equalTo(self.left).with.offset(IS_IPHONE ? 15.0 : 28.0); }];
    [_totalLabel makeConstraints:^(MASConstraintMaker *make) {
        if (IS_IPHONE) {
            //make.baseline.equalTo(self.top).with.offset(75);
            make.baseline.equalTo(self.top).with.offset(76);
        } else {
			make.baseline.equalTo(self.top).with.offset(IS_RETINA? 110.5 : 111);
        }
        //make.baseline.equalTo(self.bottom).with.offset(IS_IPHONE ? -58 : -82);
        
        
        //make.right.equalTo(_detailInfoButton.left);
        //_totalLabelTrailingConst = make.trailing.equalTo(self.right).with.offset(-15);
        
        //_totalLabelTrailingConst = make.trailing.equalTo(_detailInfoButton.left);
        _totalLabelTrailingConst = make.trailing.equalTo(self.right);
    }];
}

- (void)showDetailInfoButton {
    //if ([self.dataManager hasCalcData] && [self.dataManager isTaxOptionOn] && ![self.dataManager isSplitOptionOn]) {
    if ([self.dataManager hasCalcData] && [self.dataManager isTaxOptionOn]) {
        self.detailInfoButton.hidden = NO;
        //_totalLabelTrailingConst.equalTo(@(-CGRectGetWidth(_detailInfoButton.bounds)));
        
        _totalLabelTrailingConst.equalTo(@(IS_RETINA ? -45 : -46));
    }
    else {
        self.detailInfoButton.hidden = YES;
        _totalLabelTrailingConst.equalTo(@(-13));
    }
}

#pragma mark - adjust Layout

- (void)adjustMeterViewConstraints {
    [_meterViewLeadingConstArray enumerateObjectsUsingBlock:^(MASConstraint *leadingConst, NSUInteger idx, BOOL *stop) {
        leadingConst.equalTo( @(self.frame.size.width / 5.0 * (idx+1)) );
    }]; } - (void)adjustConstraintLayout {
        
    }

#pragma mark -

- (void)setResult:(TipCalcRecently *)result {

    // tipLabel
    double dTip = 0.0;
    if (result) {
        if ([self.dataManager tipSplitOption] == TipSplitOption_PerPerson) {
            dTip = [[self.dataManager tipValueWithSplit] doubleValue];
        }
        else {
            dTip = [[self.dataManager tipValue] doubleValue];
        }
    }
    
    NSString *tip = [self.dataManager currencyStringFromDouble:dTip];
    NSArray * strings = @[tip, @"  Tip"];
    _tipLabel.text = [strings componentsJoinedByString:@""];
    NSMutableAttributedString *tipAttributeText = [[NSMutableAttributedString alloc] initWithAttributedString:_tipLabel.attributedText];
    [tipAttributeText addAttribute: NSFontAttributeName
                             value: IS_IPHONE ? [UIFont systemFontOfSize:15] : [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline]
                             range: NSMakeRange(0, [strings[0] length])];
    [tipAttributeText addAttribute: NSForegroundColorAttributeName
                             value: [UIColor blackColor]
                             range: NSMakeRange(0, [strings[0] length])];
    
    [tipAttributeText addAttribute: NSFontAttributeName
                             value: IS_IPHONE ? [UIFont systemFontOfSize:13] : [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote]
                             range: NSMakeRange([strings[0] length], [strings[1] length])];
    [tipAttributeText addAttribute: NSForegroundColorAttributeName
                             value: COLOR_DEFAULT_TEXT_GRAY
                             range: NSMakeRange([strings[0] length], [strings[1] length])];
    _tipLabel.attributedText = tipAttributeText;
    
    
    
    // totalLabel
    double dTotal = 0.0;
    if (result) {
        if ([self.dataManager isSplitOptionOn]) {
            if ([self.dataManager tipSplitOption] == TipSplitOption_PerPerson) {
                dTotal = [[self.dataManager totalPerPersonWithTax] doubleValue];
//                if (self.dataManager.roundingMethodValue == TCRoundingMethodValue_TotalPerPerson) {
//                    dTotal = [[self.dataManager totalPerPerson] doubleValue];
//                }
//                else {
//                    dTotal = [[self.dataManager totalPerPerson] doubleValue] + ([[self.dataManager taxValue] doubleValue]  / [[self.dataManager.tipCalcData split] doubleValue]);
//                }
                
                NSString *total = [self.dataManager currencyStringFromDouble:dTotal];
                strings = @[total, @" Total Per Person"];
            }
            else {
                dTotal = [[self.dataManager totalBeforeSplitWithTax] doubleValue];
//                if (self.dataManager.roundingMethodValue == TCRoundingMethodValue_Total) {
//                    dTotal = [[self.dataManager totalBeforeSplit] doubleValue];
//                }
//                else {
//                    dTotal = [[self.dataManager totalBeforeSplit] doubleValue] + [[self.dataManager taxValue] doubleValue];
//                }
                
                NSString *total = [self.dataManager currencyStringFromDouble:dTotal];
                strings = @[total, @" Total Before Split"];
            }
        }
        else {
            dTotal = [[self.dataManager totalBeforeSplitWithTax] doubleValue];
//            dTotal = [[self.dataManager totalBeforeSplit] doubleValue] + [[self.dataManager taxValue] doubleValue];
            NSString *total = [self.dataManager currencyStringFromDouble:dTotal];
            strings = @[total, @" Total"];
        }
    }

    _totalLabel.text = [strings componentsJoinedByString:@""];
    NSMutableAttributedString *totalAttributeText = [[NSMutableAttributedString alloc] initWithAttributedString:_totalLabel.attributedText];
    [totalAttributeText addAttribute: NSFontAttributeName
                               value: IS_IPHONE ? [UIFont boldSystemFontOfSize:17] : [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]
                               range: NSMakeRange(0, [strings[0] length])];
    [totalAttributeText addAttribute: NSForegroundColorAttributeName
                               value: [UIColor blackColor]
                               range: NSMakeRange(0, [strings[0] length])];
    
    [totalAttributeText addAttribute: NSFontAttributeName
                               value: IS_IPHONE ? [UIFont systemFontOfSize:17] : [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline]
                               range: NSMakeRange([strings[0] length], [strings[1] length])];
    [totalAttributeText addAttribute: NSForegroundColorAttributeName
                               value: [UIColor blackColor]
                               range: NSMakeRange([strings[0] length], [strings[1] length])];
    _totalLabel.attributedText = totalAttributeText;
    
    float fWidthRate = 0.0;
    dTotal = [self.dataManager tipSplitOption] == TipSplitOption_BeforeSplit ? [self.dataManager.costBeforeTax doubleValue] : [self.dataManager.costBeforeTaxWithSplit doubleValue];
    
    if (dTip > 0.0 && dTotal > 0.0) {
        if (dTotal == 0 || dTip == 0) {
            fWidthRate = 0.0;
        }
        else {
            fWidthRate = dTip / dTotal;
        }
    }
    
    float fBarWidth = (fWidthRate * CGRectGetWidth(self.frame));

    if (result == nil || [result.costs isEqualToNumber:@0] || [result.tip isEqualToNumber:@0]) {
        _sliderThumbLeadingConst.equalTo(@(-50));
        _sliderThumbView.alpha = 0.0;
    }
    else {
        _sliderThumbLeadingConst.equalTo(@(fBarWidth - 22));
        _sliderThumbView.alpha = 1.0;
    }
}

- (void)setResult:(TipCalcRecently *)result withAnimation:(BOOL)animate {
    if (animate) {
        [UIView beginAnimations:@"KeyboardWillShow" context:nil];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationCurve:7];
        [UIView setAnimationDuration:0.25];
        [UIView setAnimationDidStopSelector:@selector(setNeedsLayout)];
        [self adjustConstraintLayout];
        [self setResult:result];
        [_sliderBaseLineView layoutIfNeeded];
        [_sliderGaugeLineView layoutIfNeeded];
        [_bottomGrayLineView layoutIfNeeded];
        [_sliderThumbView layoutIfNeeded];
        [UIView commitAnimations];
    }
    else {
        [self setResult:result];
    }
}

@end
