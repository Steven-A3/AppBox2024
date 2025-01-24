//
//  A3TipCalcHeaderView.m
//  A3TeamWork
//
//  Created by Sanghyun Yu on 2013. 11. 5..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3TipCalcHeaderView.h"
#import "A3TipCalcDataManager.h"
#import "A3RoundedSideButton.h"
#import "A3OverlappedCircleView.h"
#import "UIImage+JHExtension.h"
#import "UIImage+imageWithColor.h"
#import "UIViewController+tableViewStandardDimension.h"
#import "A3UIDevice.h"
#import "A3UserDefaults+A3Addition.h"

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
    
    UIColor *themeColor = [[A3UserDefaults standardUserDefaults] themeColor];
    // Buttons
    _beforeSplitButton = [A3RoundedSideButton buttonWithType:UIButtonTypeCustom];
    _perPersonButton = [A3RoundedSideButton buttonWithType:UIButtonTypeCustom];
    _detailInfoButton = [UIButton buttonWithType:UIButtonTypeSystem];
	[self addSubview:_beforeSplitButton];
	[self addSubview:_perPersonButton];
	[self addSubview:_detailInfoButton];
	[_beforeSplitButton setTitle:NSLocalizedString(@"Before Split", @"Before Split") forState:UIControlStateNormal];
	[_beforeSplitButton setTitleColor:themeColor forState:UIControlStateNormal];
	[_perPersonButton setTitle:NSLocalizedString(@"Per Person", @"Per Person") forState:UIControlStateNormal];
	[_perPersonButton setTitleColor:themeColor forState:UIControlStateNormal];
    _detailInfoButton.frame = CGRectMake(0.0, 0.0, 44.0, 44.0);
    [_detailInfoButton setImage:[[UIImage imageNamed:@"information"] tintedImageWithColor:themeColor] forState:UIControlStateNormal];
    [_detailInfoButton setImage:[UIImage getImageToGreyImage:[UIImage imageNamed:@"information"] grayColor:COLOR_DISABLE_POPOVER] forState:UIControlStateDisabled];
    
    // Layout Views
    _sliderBaseLineView = [[UIView alloc] initWithFrame:CGRectZero];
    _sliderGaugeLineView = [[UIView alloc] initWithFrame:CGRectZero];
    _bottomGrayLineView = [[UIView alloc] initWithFrame:CGRectZero];
    [self addSubview:_sliderBaseLineView];
    [self addSubview:_sliderGaugeLineView];
    [self addSubview:_bottomGrayLineView];
    _sliderBaseLineView.backgroundColor = COLOR_DEFAULT_GRAY;
    _bottomGrayLineView.backgroundColor = A3UITableViewSeparatorColor;
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
	_totalLabel.textAlignment = NSTextAlignmentRight;
    [self addSubview:_tipLabel];
    [self addSubview:_totalLabel];
}

- (void)setupConstraints {
    // Buttons
    [_beforeSplitButton makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(IS_IPHONE ? @40 : @220);
        make.bottom.equalTo(self.bottom).with.offset(-16);
        make.width.equalTo(IS_IPHONE ? @110 : @110);
        make.height.equalTo(@20);
    }];
    
    [_perPersonButton makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(IS_IPHONE ? @-40 : @-220);
        make.bottom.equalTo(self.bottom).with.offset(-16);
        make.width.equalTo(IS_IPHONE ? @110 : @110);
        make.height.equalTo(@20);
    }];
    
    [_detailInfoButton makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.right).with.offset(-4);
        make.centerY.equalTo(_totalLabel.centerY);
        make.width.equalTo(@44);
        make.height.equalTo(@44);
    }];
    
    // Layout Views
    [_sliderBaseLineView makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.left);
        make.right.equalTo(self.right);
        make.top.equalTo(IS_IPHONE ? @40 : @65);
        make.height.equalTo(@5);
    }];
    
    [_sliderGaugeLineView makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.left);
        make.right.equalTo(_sliderThumbView.centerX);
        make.top.equalTo(IS_IPHONE ? @40 : @65);
        make.height.equalTo(@5);
    }];
    
    [_bottomGrayLineView makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.left);
        make.right.equalTo(self.right);
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
                make.right.equalTo(((UIView *)_sliderMeterViews[idx]).left).with.offset(IS_RETINA ? -4.5 : -5);
                [baselineConsts addObject: make.baseline.equalTo(self.top).with.offset(83) ];
            }];
        }];
        _meterLabelBaselineConstArray = baselineConsts;
    }
    
    [_sliderThumbView makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@44);
        make.height.equalTo(@44);
        make.centerY.equalTo(_sliderBaseLineView.centerY);
        _sliderThumbLeadingConst = make.left.equalTo(self.left).with.offset(-22);
    }];
    
    // Labels
    [_tipLabel makeConstraints:^(MASConstraintMaker *make) {
        make.baseline.equalTo(self.top).with.offset(IS_IPHONE ? 31 : 54 );
		make.left.equalTo(self.left).with.offset(IS_IPHONE ? 15.0 : 28.0); }];
    [_totalLabel makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(self.left);
        if (IS_IPHONE) {
            //make.baseline.equalTo(self.top).with.offset(75);
            make.baseline.equalTo(self.top).with.offset(76);
        } else {
			make.baseline.equalTo(self.top).with.offset(IS_RETINA? 110.5 : 111);
        }
        _totalLabelTrailingConst = make.right.equalTo(self.right);
    }];
}

- (void)showDetailInfoButton {
    if ([self.dataManager hasCalcData] && [self.dataManager isTaxOptionOn]) {
        self.detailInfoButton.hidden = NO;
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
	}];
}

#pragma mark -

- (void)setResult:(TipCalcRecent *)result {

    // tipLabel
    double dTip = 0.0;
    if (result) {
        if ([self.dataManager tipSplitOption] == TipSplitOption_PerPerson) {
            dTip = [[self.dataManager tipValueWithSplitWithRounding:YES] doubleValue];
        }
        else {
            dTip = [[self.dataManager tipValueWithRounding] doubleValue];
        }
    }
    
    NSString *tip = [self.dataManager currencyStringFromDouble:dTip];
    NSArray * strings = @[tip, NSLocalizedString(@"  Tip", @"  Tip")];
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
                NSString *total = [self.dataManager currencyStringFromDouble:dTotal];
                strings = @[total, NSLocalizedString(@" Total Per Person", @" Total Per Person")];
            }
            else {
                dTotal = [[self.dataManager totalBeforeSplitWithTax] doubleValue];
                NSString *total = [self.dataManager currencyStringFromDouble:dTotal];
                strings = @[total, NSLocalizedString(@" Total Before Split", @" Total Before Split")];
            }
        }
        else {
            dTotal = [[self.dataManager totalBeforeSplitWithTax] doubleValue];
            NSString *total = [self.dataManager currencyStringFromDouble:dTotal];
            strings = @[total, NSLocalizedString(@" Total", @" Total")];
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

- (void)setResult:(TipCalcRecent *)result withAnimation:(BOOL)animate {
    if (animate) {
        [UIView animateWithDuration:0.25
                              delay:0
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
            [self setResult:result];
            [self->_sliderBaseLineView layoutIfNeeded];
            [self->_sliderGaugeLineView layoutIfNeeded];
            [self->_bottomGrayLineView layoutIfNeeded];
            [self->_sliderThumbView layoutIfNeeded];
        } completion:^(BOOL finished) {
            [self setNeedsLayout];
        }];
    }
    else {
        [self setResult:result];
    }
}

@end
