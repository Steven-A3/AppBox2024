//
//  A3SalesCalcHeaderView.m
//  A3TeamWork
//
//  Created by jeonghwan kim on 13. 11. 17..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3SalesCalcHeaderView.h"
#import "A3OverlappedCircleView.h"
#import "A3DefaultColorDefines.h"
#import "UIImage+JHExtension.h"
#import "A3SalesCalcData.h"
#import "A3SalesCalcCalculator.h"
#import "A3AppDelegate+appearance.h"
#import "UIImage+imageWithColor.h"

@interface A3SalesCalcHeaderView()

@property (nonatomic, strong) MASConstraint *sliderThumbLeadingConst;
@property (nonatomic, strong) MASConstraint *savedPriceLabelTrailingConst;
@property (nonatomic, strong) A3SalesCalcData *calcData;
@end

@implementation A3SalesCalcHeaderView
{
    UIView *_sliderBaseLineView;
    UIView *_sliderRedLineView;
    UIView *_bottomGrayLineView;
    UILabel *_salesPricePrintLabel;     // 상단 금액 출력 레이블
    UILabel *_savedPricePrintLabel;     // 하단 결과 출력 레이블
    NSArray *_sliderMeterViews;
    NSArray *_sliderMeterLabelViews;
    A3OverlappedCircleView *_sliderThumbView;
    BOOL _isAdvance;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initializeSubviews];
        [self setupConstraintLayout];
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    [self setupMeterViews];
    //[self setResultWithAnimation:_result];
    [self setResultDataWithAnimation:_calcData];
    [self adjustConstraintLayout];
    [super layoutSubviews];
}

-(void)initializeSubviews
{
    self.backgroundColor = COLOR_HEADERVIEW_BG;
    
    _sliderBaseLineView = [[UIView alloc] initWithFrame:CGRectZero];
    _sliderRedLineView = [[UIView alloc] initWithFrame:CGRectZero];
    _bottomGrayLineView = [[UIView alloc] initWithFrame:CGRectZero];
    _salesPricePrintLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _savedPricePrintLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _detailInfoButton = [UIButton buttonWithType:UIButtonTypeCustom];

    _sliderBaseLineView.backgroundColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0];
    _sliderRedLineView.backgroundColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0];

    [self addSubview:_sliderBaseLineView];
    [self addSubview:_sliderRedLineView];
    [self addSubview:_bottomGrayLineView];
    [self addSubview:_salesPricePrintLabel];
    [self addSubview:_savedPricePrintLabel];
    [self addSubview:_detailInfoButton];

    _bottomGrayLineView.backgroundColor = COLOR_TABLE_SEPARATOR;
    [_detailInfoButton setImage:[[UIImage imageNamed:@"information"] tintedImageWithColor:[A3AppDelegate instance].themeColor] forState:UIControlStateNormal];
    [_detailInfoButton setImage:[UIImage getImageToGreyImage:[UIImage imageNamed:@"information"] grayColor:COLOR_DISABLE_POPOVER] forState:UIControlStateDisabled]; // 196, 196, 196
    
    _sliderThumbView = [[A3OverlappedCircleView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    _sliderThumbView.centerColor = COLOR_DEFAULT_GRAY;
    _sliderThumbView.alpha = 0.0;
    [self addSubview:_sliderThumbView];
}

-(void)setupConstraintLayout
{
    [_bottomGrayLineView makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@0.5);
        make.leading.equalTo(self.left);
        make.trailing.equalTo(self.right);
        make.bottom.equalTo(self.bottom);
    }];
    
    [_sliderBaseLineView makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.width);
        make.height.equalTo(@5.0);
        make.leading.equalTo(self.left);
        if (IS_IPAD) {
            make.top.equalTo(@65.0);
        } else {
            make.top.equalTo(@40.0);
        }
    }];
    
    [_sliderThumbView makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@44);
        make.height.equalTo(@44);
        make.centerY.equalTo(_sliderBaseLineView.centerY);
        _sliderThumbLeadingConst = make.leading.equalTo(self.left);
    }];
    
    [_sliderRedLineView makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(_sliderThumbView.left).with.offset(22.0);
        //make.trailing.equalTo(_sliderThumbView.centerY);
        make.height.equalTo(@5.0);
        make.leading.equalTo(self.left);
        make.centerY.equalTo(_sliderBaseLineView.centerY);
    }];
    
    [_salesPricePrintLabel makeConstraints:^(MASConstraintMaker *make) {
        if (IS_IPAD) {
			make.leading.equalTo(self.left).with.offset(28.0);
            make.baseline.equalTo(self.bottom).with.offset(-104.0);
            
        } else {
			make.leading.equalTo(self.left).with.offset(15.0);
            make.baseline.equalTo(self.bottom).with.offset(-73.0);
        }
    }];
    
    [_savedPricePrintLabel makeConstraints:^(MASConstraintMaker *make) {
        if (IS_IPAD) {
		   _savedPriceLabelTrailingConst = make.trailing.equalTo(self.right).with.offset(-15);
            make.leading.greaterThanOrEqualTo(@10);
            //make.top.equalTo(_sliderBaseLineView.bottom).with.offset(28.0);
            make.baseline.equalTo(self.bottom).with.offset(-47);
        } else {
			_savedPriceLabelTrailingConst = make.trailing.equalTo(self.right).with.offset(-15);
            make.leading.greaterThanOrEqualTo(@10);
            make.baseline.equalTo(self.bottom).with.offset(-28.0);
        }
    }];
    
    [_detailInfoButton makeConstraints:^(MASConstraintMaker *make) {
        if (IS_IPAD) {
            make.trailing.equalTo(self.right).with.offset(-4);
            make.centerY.equalTo(_savedPricePrintLabel.centerY);
        } else {
            make.trailing.equalTo(self.right).with.offset(-4);
            make.centerY.equalTo(_savedPricePrintLabel.centerY);
        }
        make.width.equalTo(@44);
        make.height.equalTo(@44);
    }];
}

-(void)setupMeterViews
{
    if (IS_IPAD) {
        if (_sliderMeterViews) {
            for (UIView *aView in _sliderMeterViews) {
                [aView removeFromSuperview];
            }
            _sliderMeterViews = nil;
            for (UIView *aView in _sliderMeterLabelViews) {
                [aView removeFromSuperview];
            }
            _sliderMeterLabelViews = nil;
        }
        
        NSMutableArray *meterArray = [[NSMutableArray alloc] init];
        NSMutableArray *labelArray = [[NSMutableArray alloc] init];
        for (int i=0; i<5; i++) {
            UIView *aView = [[UIView alloc] initWithFrame:CGRectZero];
            UILabel *aLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            aView.backgroundColor = COLOR_DEFAULT_GRAY;
            aLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
            aLabel.textColor = COLOR_DEFAULT_GRAY;
//            [self addSubview:aView];
//            [self addSubview:aLabel];
            [self insertSubview:aView atIndex:0];
            [self insertSubview:aLabel atIndex:0];
            [meterArray addObject:aView];
            [labelArray addObject:aLabel];
        }
        _sliderMeterViews = [NSArray arrayWithArray:meterArray];
        _sliderMeterLabelViews = [NSArray arrayWithArray:labelArray];
        
        
        [_sliderMeterViews enumerateObjectsUsingBlock:^(UIView *aView, NSUInteger idx, BOOL *stop) {
            [aView removeConstraints:aView.constraints];
            [aView makeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo( @( self.frame.size.width / 5.0 * (idx+1) ) );
                make.width.equalTo(IS_RETINA? @0.5 : @1);
                make.height.equalTo(@18);
                make.top.equalTo(_sliderBaseLineView.bottom);
            }];
            
        }];
        
        [_sliderMeterLabelViews enumerateObjectsUsingBlock:^(UILabel *aLabel, NSUInteger idx, BOOL *stop) {
            aLabel.textColor = COLOR_DEFAULT_GRAY;
            [aLabel setText:[NSString stringWithFormat:@"%lu%%", (unsigned long)(idx + 1) * 20]];
            [aLabel removeConstraints:aLabel.constraints];
            [aLabel sizeToFit];
            [aLabel makeConstraints:^(MASConstraintMaker *make) {
                //make.leading.equalTo( @( self.frame.size.width / 5.0 * (idx+1) ) );
                //make.trailing.equalTo(((UIView *)_sliderMeterViews[idx]).left).with.offset(-6.0);
                //make.top.equalTo(_sliderBaseLineView.bottom).with.offset(6.0);
                make.trailing.equalTo(((UIView *)_sliderMeterViews[idx]).left).with.offset(IS_RETINA? -4.5 : -5);
                make.baseline.equalTo(self.bottom).with.offset(-75);//-> 75pt로 하면 slider와 겹치게 됩니다. 현재는 label의 상단이 slider에서 6pt 하단에 위치하게 되어 있습니다. 폰트는 Caption2 입니다.
            }];
        }];
    }
}

-(void)adjustConstraintLayout
{
    if (_calcData != nil) {
        NSNumber *salePrice = [A3SalesCalcCalculator salePriceWithoutTaxForCalcData:_calcData];
        NSNumber *originalPrice = [A3SalesCalcCalculator originalPriceBeforeTaxAndDiscountForCalcData:_calcData];
        
        if ( [originalPrice isEqualToNumber:@0] && [salePrice isEqualToNumber:@0] ) {
            _sliderThumbView.centerColor = COLOR_DEFAULT_GRAY;
            _sliderBaseLineView.backgroundColor = COLOR_DEFAULT_GRAY;
            [self setResultDataWithAnimation:nil];
            
            _sliderThumbLeadingConst.equalTo(@-22);
            _sliderThumbView.alpha = 0.0;
            
            return;
        }
        
        float costGauge = (self.frame.size.width / 100.0) * (salePrice.doubleValue / originalPrice.doubleValue * 100.0);
		if (isnan(costGauge) || !isfinite(costGauge)) {
			costGauge = 0.0;
		}
        
        if (([originalPrice doubleValue] > 0 || [salePrice doubleValue] > 0) && (!_calcData.discount || [_calcData.discount doubleValue] == 0) && (!_calcData.additionalOff || [_calcData.additionalOff doubleValue] == 0)) {
            costGauge = 0.0;
        }
        
        
        if (costGauge > self.frame.size.width) {
            costGauge = self.frame.size.width;
        }
        else if (costGauge < 0.0) {
            costGauge = 0.0;
        }
        
        if (salePrice.doubleValue <= 0) {
            _sliderThumbView.alpha = 0.0;
            _sliderRedLineView.alpha = 0.0;
        }
        else {
            _sliderThumbView.alpha = 1.0;
            _sliderRedLineView.alpha = 1.0;
        }
        
        if (costGauge > self.frame.size.width) {
            _sliderThumbLeadingConst.equalTo(@(self.frame.size.width));
        } else {
            _sliderThumbLeadingConst.equalTo(@(costGauge-22.0));
        }
        
        if (([originalPrice doubleValue] > 0 || [salePrice doubleValue] > 0) && (!_calcData.discount || [_calcData.discount doubleValue] == 0) && (!_calcData.additionalOff || [_calcData.additionalOff doubleValue] == 0)) {
            _sliderThumbView.centerColor = COLOR_DEFAULT_GRAY;
            _sliderBaseLineView.backgroundColor = COLOR_DEFAULT_GRAY;
            _sliderRedLineView.backgroundColor = COLOR_DEFAULT_GRAY;
        }
        else {
            _sliderThumbView.centerColor = COLOR_NEGATIVE;
            _sliderBaseLineView.backgroundColor = COLOR_POSITIVE;
            _sliderRedLineView.backgroundColor = COLOR_NEGATIVE;
        }
    }
    else {
        [self setResultDataWithAnimation:nil];

        _sliderThumbView.centerColor = COLOR_DEFAULT_GRAY;
        _sliderRedLineView.backgroundColor = COLOR_DEFAULT_GRAY;
        _sliderBaseLineView.backgroundColor = COLOR_DEFAULT_GRAY;
        _sliderThumbView.alpha = 0.0;
        _sliderRedLineView.alpha = 0.0;
    }
    
    if (IS_IPAD) {
        [_sliderMeterLabelViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            UILabel *aLabel = (UILabel *)obj;
            aLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
            [aLabel sizeToFit];
        }];
    }
}

#pragma mark -
- (void)setResultData:(A3SalesCalcData *)resultData withAnimation:(BOOL)animate {
    
    self.calcData = resultData;
    
    if (animate) {
        [UIView beginAnimations:A3AnimationIDKeyboardWillShow context:nil];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationCurve:7];
        [UIView setAnimationDuration:0.25];
        //[UIView setAnimationDidStopSelector:@selector(setNeedsLayout)];

        [self adjustConstraintLayout];

        [_sliderBaseLineView layoutIfNeeded];
        [_sliderRedLineView layoutIfNeeded];
        [_bottomGrayLineView layoutIfNeeded];
        [_salesPricePrintLabel layoutIfNeeded];
        [_savedPricePrintLabel layoutIfNeeded];
        [_sliderThumbView layoutIfNeeded];
        
        [UIView commitAnimations];
    }
    else {
        [self adjustConstraintLayout];
    }
    
    [self setNeedsLayout];
}

- (void)setResultDataWithAnimation:(A3SalesCalcData *)resultData {
    
    if (!resultData) {
        resultData = [A3SalesCalcData new];
        resultData.price = @0;
        resultData.discount = @0;
        resultData.additionalOff = @0;
        resultData.tax = @0;
    }
    if (!resultData.price) {
        resultData.price = @0;
    }
    
    NSArray *strings;
    NSNumber *salePrice;
    NSNumber *salePriceTax;
    
    if (resultData.tax && [resultData.tax doubleValue] > 0) {
        // 세금 있는 경우
        if (resultData.shownPriceType == ShowPriceType_Origin) {
            salePrice = [A3SalesCalcCalculator salePriceWithoutTaxForCalcData:resultData];
            salePriceTax = [A3SalesCalcCalculator salePriceTaxForCalcData:resultData];
            strings = @[[_currencyFormatter stringFromNumber:@([salePrice doubleValue] + [salePriceTax doubleValue])], IS_IPAD ? NSLocalizedString(@"  Sale Price with Tax", @"  Sale Price with Tax") : NSLocalizedString(@"  Sale Price w/Tax", @"  Sale Price w/Tax")];
        }
        else if (resultData.shownPriceType == ShowPriceType_SalePriceWithTax) {
            salePrice = resultData.price;
            strings = @[[_currencyFormatter stringFromNumber:@([salePrice doubleValue])], IS_IPAD? NSLocalizedString(@"  Sale Price with Tax", @"  Sale Price with Tax") : NSLocalizedString(@"  Sale Price w/Tax", @"  Sale Price w/Tax")];
        }
        
        _detailInfoButton.hidden = NO;
        
        if (IS_IPAD) {
            _savedPriceLabelTrailingConst.equalTo(@(0)).with.offset(-(2+_detailInfoButton.frame.size.width));
        }
        else {
            _savedPriceLabelTrailingConst.equalTo(@(0)).with.offset(-(2+_detailInfoButton.frame.size.width));
        }
    } else {
        // 세금 없는 경우
        if (resultData.shownPriceType == ShowPriceType_Origin) {
            salePrice = [A3SalesCalcCalculator salePriceWithoutTaxForCalcData:resultData];
            strings = @[[_currencyFormatter stringFromNumber:salePrice], NSLocalizedString(@"  Sale Price", @"  Sale Price")];
        }
        else if (resultData.shownPriceType == ShowPriceType_SalePriceWithTax) {
            salePrice = resultData.price;
            if (!resultData.tax || [resultData.tax isEqualToNumber:@0]) {
                strings = @[[_currencyFormatter stringFromNumber:salePrice], NSLocalizedString(@"  Sale Price", @"  Sale Price")];
            }
            else {
                strings = @[[_currencyFormatter stringFromNumber:salePrice], IS_IPAD? NSLocalizedString(@"  Sale Price with Tax", @"  Sale Price with Tax") : NSLocalizedString(@"  Sale Price w/Tax", @"  Sale Price w/Tax")];
            }
        }
        
        _detailInfoButton.hidden = YES;
        if (IS_IPAD) {
            //_savedPriceLabelTrailingConst.equalTo(@-28);
			_savedPriceLabelTrailingConst.equalTo(@(0)).with.offset(-15);
        } else {
            //_savedPriceLabelTrailingConst.equalTo(@-10);
			_savedPriceLabelTrailingConst.equalTo(@(0)).with.offset(-15);
		}
    }
    
    // SalePrice 금액 출력 레이블.
    
    _salesPricePrintLabel.text = [strings componentsJoinedByString:@""];
    NSMutableAttributedString *salePriceAttribute = [[NSMutableAttributedString alloc] initWithAttributedString:_salesPricePrintLabel.attributedText];
    
    [salePriceAttribute addAttribute: NSForegroundColorAttributeName
                               value: [UIColor blackColor]
                               range: NSMakeRange(0, ((NSString *)strings[0]).length) ];
    [salePriceAttribute addAttribute: NSFontAttributeName
                               value: IS_IPHONE ? [UIFont systemFontOfSize:15] : [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline]
                               range: NSMakeRange( 0, ((NSString *)strings[0]).length) ];
    
    [salePriceAttribute addAttribute: NSFontAttributeName
                               value: IS_IPHONE ? [UIFont systemFontOfSize:13] : [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote]
                               range: NSMakeRange( ((NSString *)strings[0]).length, ((NSString *)strings[1]).length)];
    [salePriceAttribute addAttribute: NSForegroundColorAttributeName
                               value: COLOR_DEFAULT_TEXT_GRAY
                               range: NSMakeRange( ((NSString *)strings[0]).length, ((NSString *)strings[1]).length)];
    _salesPricePrintLabel.attributedText = salePriceAttribute;
    [_salesPricePrintLabel sizeToFit];
    
    
    
    // 하단 결과, Saved Amount
    CGFloat fontSize = 17.0;
    NSNumber *originalPriceWithTax;
    NSNumber *savedTotalAmount;
    
    originalPriceWithTax = [A3SalesCalcCalculator originalPriceWithTax:resultData];
    savedTotalAmount = [A3SalesCalcCalculator savedTotalAmountForCalcData:resultData];

    strings = @[[_currencyFormatter stringFromNumber:savedTotalAmount], NSLocalizedString(@" saved of ", @" saved of "), [_currencyFormatter stringFromNumber:originalPriceWithTax]];
    _savedPricePrintLabel.text = [strings componentsJoinedByString:@""];
    
    if (IS_IPHONE) {
        _savedPricePrintLabel.font = [UIFont systemFontOfSize:fontSize];
        CGSize size = [_savedPricePrintLabel sizeThatFits:CGSizeMake(320, CGFLOAT_MAX)];
        if (size.width > 275) {
            fontSize = fontSize * 0.8;
            _savedPricePrintLabel.font = [UIFont systemFontOfSize:fontSize];
        }
    }
    NSMutableAttributedString *savedPriceAttribute = [[NSMutableAttributedString alloc] initWithAttributedString:_savedPricePrintLabel.attributedText];
    [savedPriceAttribute addAttribute: NSForegroundColorAttributeName
                                value: [UIColor blackColor]
                                range: NSMakeRange(0, ((NSString *)strings[0]).length)];
    [savedPriceAttribute addAttribute: NSFontAttributeName
                                value: IS_IPHONE ? [UIFont boldSystemFontOfSize:fontSize] : [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]
                                range: NSMakeRange(0, ((NSString *)strings[0]).length)];
    
    [savedPriceAttribute addAttribute: NSForegroundColorAttributeName
                                value: COLOR_DEFAULT_TEXT_GRAY
                                range: NSMakeRange( ((NSString *)strings[0]).length, ((NSString *)strings[1]).length )];
    [savedPriceAttribute addAttribute: NSFontAttributeName
                                value: IS_IPHONE ? [UIFont systemFontOfSize:fontSize] : [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline]
                                range: NSMakeRange( ((NSString *)strings[0]).length, ((NSString *)strings[1]).length )];
    
    [savedPriceAttribute addAttribute: NSForegroundColorAttributeName
                                value: [UIColor blackColor]
                                range: NSMakeRange( ((NSString *)strings[0]).length + ((NSString *)strings[1]).length, ((NSString *)strings[2]).length )];
    [savedPriceAttribute addAttribute: NSFontAttributeName
                                value: IS_IPHONE ? [UIFont systemFontOfSize:fontSize] : [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline]
                                range: NSMakeRange( ((NSString *)strings[0]).length + ((NSString *)strings[1]).length, ((NSString *)strings[2]).length )];
    
    _savedPricePrintLabel.attributedText = savedPriceAttribute;
    [_savedPricePrintLabel sizeToFit];
}

@end
