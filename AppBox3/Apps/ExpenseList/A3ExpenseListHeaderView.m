//
//  A3ExpenseListHeaderView.m
//  A3TeamWork
//
//  Created by jeonghwan kim on 13. 11. 21..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3ExpenseListHeaderView.h"
#import "A3OverlappedCircleView.h"
#import "A3CommonColorDefine.h"
#import "A3DefaultColorDefines.h"
#import "UIImage+JHExtension.h"
#import "UIImage+imageWithColor.h"
#import "A3UIDevice.h"
#import "A3UserDefaults+A3Addition.h"

@interface A3ExpenseListHeaderView()

@property (nonatomic, strong) MASConstraint *sliderThumbLeadingConst;
@property (nonatomic, strong) MASConstraint *savedPriceLabelTrailingConst;
@property (nonatomic, strong) NSMutableArray *sliderMeterViewsConst;

@end

@implementation A3ExpenseListHeaderView
{
    ExpenseListBudget_ *_budget;
    
    UIView *_sliderBaseLineView;                // 베이스 라인. (회색,녹색)
    UIView *_sliderRedLineView;                 // 사용금액 적색 라인.
    UILabel *_usedAmountLabel;                  // 상단 사용된 금액 결과 출력.
    UILabel *_resultLabel;                      // 하단 남은 예산 출력.
    NSArray *_sliderMeterViews;                 // 눈금 뷰.
    NSArray *_sliderMeterLabelViews;            // 눈금 퍼센트 레이블.
    A3OverlappedCircleView *_sliderThumbView;    // 슬라이더 커서.
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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void)layoutSubviews
{
    [super layoutSubviews];
    [self adjustConstraintLayout];
    [super layoutSubviews];
}

-(void)initializeSubviews
{
    self.backgroundColor = COLOR_HEADERVIEW_BG;
    
    _sliderBaseLineView = [[UIView alloc] initWithFrame:CGRectZero];
    _sliderRedLineView = [[UIView alloc] initWithFrame:CGRectZero];
    _usedAmountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _resultLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    
    _detailInfoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _detailInfoButton.frame = CGRectMake(0.0, 0.0, 44.0, 44.0);//19
    [_detailInfoButton setImage:[[UIImage imageNamed:@"add02"] tintedImageWithColor:[[A3UserDefaults standardUserDefaults] themeColor]] forState:UIControlStateNormal];
     [_detailInfoButton setImage:[[UIImage imageNamed:@"add01"] tintedImageWithColor:[[A3UserDefaults standardUserDefaults] themeColor]] forState:UIControlStateHighlighted];
    [_detailInfoButton setImage:[UIImage getImageToGreyImage:[UIImage imageNamed:@"add02"] grayColor:COLOR_DISABLE_POPOVER] forState:UIControlStateDisabled];
    
    _sliderBaseLineView.backgroundColor = COLOR_DEFAULT_GRAY;
    _sliderRedLineView.backgroundColor = COLOR_NEGATIVE;

    _resultLabel.adjustsFontSizeToFitWidth = YES;
    
    [self addSubview:_sliderBaseLineView];
    [self addSubview:_sliderRedLineView];
    [self addSubview:_usedAmountLabel];
    [self addSubview:_resultLabel];
    [self addSubview:_detailInfoButton];
    
    if (IS_IPAD) {
        NSMutableArray *meterArray = [[NSMutableArray alloc] init];
        NSMutableArray *labelArray = [[NSMutableArray alloc] init];
        for (int i=0; i<5; i++) {
            UIView *aView = [[UIView alloc] initWithFrame:CGRectZero];
            UILabel *aLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            aView.backgroundColor = COLOR_DEFAULT_GRAY;
            aLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
            [self addSubview:aView];
            [self addSubview:aLabel];
            [meterArray addObject:aView];
            [labelArray addObject:aLabel];
        }
        _sliderMeterViews = [NSArray arrayWithArray:meterArray];
        _sliderMeterLabelViews = [NSArray arrayWithArray:labelArray];
    }
    
    _sliderThumbView = [[A3OverlappedCircleView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [self addSubview:_sliderThumbView];
}

-(void)setupConstraintLayout
{    
    [_sliderBaseLineView makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.width);
        make.height.equalTo(@5.0);
        make.left.equalTo(self.left);
        if (IS_IPAD) {
            make.top.equalTo(@65);
        } else {
            make.top.equalTo(@40.0);
        }
    }];
    
    [_sliderThumbView makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@44);
        make.height.equalTo(@44);
        make.centerY.equalTo(_sliderBaseLineView.centerY);
        _sliderThumbLeadingConst = make.left.equalTo(self.left);
    }];
    
    [_sliderRedLineView makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_sliderThumbView.centerX);
        make.height.equalTo(@5.0);
        make.left.equalTo(self.left);
        make.centerY.equalTo(_sliderBaseLineView.centerY);
    }];
    
    [_usedAmountLabel makeConstraints:^(MASConstraintMaker *make) {
        if (IS_IPAD) {
            make.left.equalTo(self.left).with.offset(28.0);
            //make.bottom.equalTo(_sliderBaseLineView.top).with.offset(-10.0);
            make.baseline.equalTo(self.bottom).with.offset(IS_RETINA? -103.5 : -103.0);
        }
        else {
            make.left.equalTo(self.left).with.offset(15.0);
            make.baseline.equalTo(self.bottom).with.offset(-72.5);
        }
    }];
    
    [_resultLabel makeConstraints:^(MASConstraintMaker *make) {
        if (IS_IPAD) {
            _savedPriceLabelTrailingConst = make.right.equalTo(_detailInfoButton.left).with.offset(2);
            make.left.greaterThanOrEqualTo(@10);
            make.baseline.equalTo(self.bottom).with.offset(IS_RETINA? -46.5 : -46);
            
        } else {
            _savedPriceLabelTrailingConst = make.right.equalTo(_detailInfoButton.left).with.offset(2);
            make.leading.greaterThanOrEqualTo(@10);
            make.baseline.equalTo(self.bottom).with.offset(-27.5);
        }
    }];
    
    [_detailInfoButton makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.right).with.offset(-4);
        make.centerY.equalTo(_resultLabel.centerY);
        make.width.equalTo(@44);
        make.height.equalTo(@44);
    }];
    
    _sliderMeterViewsConst = [NSMutableArray new];
    if (IS_IPAD) {
        [_sliderMeterViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            UIView *aView = (UIView *)obj;
            [aView removeConstraints:aView.constraints];
            [aView makeConstraints:^(MASConstraintMaker *make) {
                MASConstraint *leading = make.leading.equalTo( @( self.frame.size.width / 5.0 * (idx+1) ) );
                [_sliderMeterViewsConst addObject:leading];
                make.width.equalTo(IS_RETINA? @0.5 : @1);
                make.height.equalTo(@18);
                make.top.equalTo(_sliderBaseLineView.bottom);
            }];
        }];
        
        [_sliderMeterLabelViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            UILabel *aLabel = (UILabel *)obj;
            [aLabel setText:[NSString stringWithFormat:@"%ld%%", (long)(idx + 1) * 20]];
            [aLabel setTextColor:COLOR_DEFAULT_GRAY];
            [aLabel sizeToFit];
            [aLabel removeConstraints:aLabel.constraints];
            [aLabel makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(((UIView *)_sliderMeterViews[idx]).left).with.offset(IS_RETINA ? -4.5 : -5.0);
                make.baseline.equalTo(self.bottom).with.offset(IS_RETINA ? -74.5 : -74);
            }];
        }];
    }
}

-(void)adjustConstraintLayout
{
    if (IS_IPAD) {
        for (int i=0; i<_sliderMeterViewsConst.count; i++) {
            MASConstraint *leading = _sliderMeterViewsConst[i];
            leading.equalTo( @( self.frame.size.width / 5.0 * (i+1) ) );
        }

        [_sliderMeterLabelViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            UILabel *aLabel = (UILabel *)obj;
            aLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
        }];
    }
    
    if (_budget) {
        NSNumber *usedAmount = _budget.usedAmount;
        NSNumber *totalAmount = _budget.totalAmount;
        
        if ( !usedAmount || !totalAmount || [usedAmount isEqualToNumber:@0] || [totalAmount isEqualToNumber:@0] ) {
            _sliderThumbView.centerColor = COLOR_DEFAULT_GRAY;
            _sliderRedLineView.backgroundColor = COLOR_DEFAULT_GRAY;
            _sliderThumbLeadingConst.equalTo(@(-44.0));
            _sliderBaseLineView.backgroundColor = [totalAmount isEqualToNumber:@0] ? COLOR_DEFAULT_GRAY : COLOR_POSITIVE;
            return;
        }
        
        double usedGaugeOffset = (self.frame.size.width / 100.0) * (usedAmount.doubleValue / totalAmount.doubleValue * 100.0);
        
        if ( (usedGaugeOffset+_sliderThumbView.frame.size.width) > self.frame.size.width ) {
            usedGaugeOffset = self.frame.size.width - (_sliderThumbView.frame.size.width / 2.0);//self.frame.size.width - _sliderThumbView.frame.size.width;
            _sliderThumbLeadingConst.equalTo(@(usedGaugeOffset));
        }
        else {
            _sliderThumbLeadingConst.equalTo(@(usedGaugeOffset-22));
        }
        
        _sliderThumbView.centerColor = COLOR_NEGATIVE;
        _sliderRedLineView.backgroundColor = COLOR_NEGATIVE;
        _sliderBaseLineView.backgroundColor = COLOR_POSITIVE;
        
    }
    else {
        _sliderThumbView.centerColor = COLOR_DEFAULT_GRAY;
        _sliderRedLineView.backgroundColor = COLOR_DEFAULT_GRAY;
        _sliderBaseLineView.backgroundColor = COLOR_DEFAULT_GRAY;
    }
}

-(void)setResult:(ExpenseListBudget_ *)budget withAnimation:(BOOL)animation
{
    NSNumber *usedAmount;
    NSNumber *totalAmount;
    NSNumber *resultAmount;
    NSNumber *remainAmount;
    
    _budget = budget;
    
    _usedAmountLabel.font = IS_IPHONE ? [UIFont systemFontOfSize:15.0] : [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    _resultLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    
    UIColor *themeColor = [[A3UserDefaults standardUserDefaults] themeColor];
    if (!budget || budget.category==nil) {  // 아직 값이 AddBudget을 통해 초기화되지 않은 상태인 경우.
        //usedAmount = @0;
        usedAmount = budget.usedAmount == nil ? @0 : budget.usedAmount;
        totalAmount = @0;
        resultAmount = @0;
        remainAmount = @0;

        [_detailInfoButton setImage:[[UIImage imageNamed:@"add02"] tintedImageWithColor:themeColor] forState:UIControlStateNormal];
        [_detailInfoButton setImage:[[UIImage imageNamed:@"add01"] tintedImageWithColor:themeColor] forState:UIControlStateHighlighted];
        [_detailInfoButton setImage:[UIImage getImageToGreyImage:[UIImage imageNamed:@"add02"] grayColor:COLOR_DISABLE_POPOVER] forState:UIControlStateDisabled];
    }
    else {
        usedAmount = budget.usedAmount ? budget.usedAmount : @0;
        totalAmount = budget.totalAmount ? budget.totalAmount : @0;
        
        if (budget.totalAmount.doubleValue == 0 || !budget.totalAmount) {
            resultAmount = nil;
        } else {
            resultAmount = @(budget.usedAmount.doubleValue / budget.totalAmount.doubleValue * 100.0);
        }
        
        remainAmount = @(budget.totalAmount.doubleValue - budget.usedAmount.doubleValue);
        [_detailInfoButton setImage:[[UIImage imageNamed:@"information"] tintedImageWithColor:themeColor] forState:UIControlStateNormal];
        [_detailInfoButton setImage:[[UIImage imageNamed:@"information"] tintedImageWithColor:themeColor] forState:UIControlStateHighlighted];
        [_detailInfoButton setImage:[UIImage getImageToGreyImage:[UIImage imageNamed:@"information"] grayColor:COLOR_DISABLE_POPOVER] forState:UIControlStateDisabled];
    }
    
    // 상단 사용된 금액 결과 출력.
    NSMutableArray *usedBudgetStringArray = [[NSMutableArray alloc] init];
    [usedBudgetStringArray addObject:[self.currencyFormatter stringFromNumber:usedAmount]];
    [usedBudgetStringArray addObject:@"  "];
    [usedBudgetStringArray addObject: (!budget || budget.category == nil || resultAmount == nil) ? @" " : [NSString stringWithFormat:@"%@%%", [self.decimalFormatter stringFromNumber:resultAmount]]];
    
    _usedAmountLabel.text = [usedBudgetStringArray componentsJoinedByString:@""];
    
    NSMutableAttributedString *usedAmountAttribute = [[NSMutableAttributedString alloc] initWithAttributedString:_usedAmountLabel.attributedText];
    [usedAmountAttribute addAttribute: NSForegroundColorAttributeName
                                value: COLOR_DEFAULT_TEXT_GRAY
                                range: NSMakeRange(((NSString *)usedBudgetStringArray[0]).length + ((NSString *)usedBudgetStringArray[1]).length,
                                                   ((NSString *)usedBudgetStringArray[2]).length)];
    [usedAmountAttribute addAttribute: NSFontAttributeName
                                value: IS_IPHONE ? [UIFont systemFontOfSize:13.0] : [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote]
                                range: NSMakeRange(((NSString *)usedBudgetStringArray[0]).length + ((NSString *)usedBudgetStringArray[1]).length,
                                                   ((NSString *)usedBudgetStringArray[2]).length)];
    
    _usedAmountLabel.attributedText = usedAmountAttribute;
    
    
    // 하단 남은 예산 출력.
    NSMutableArray *resultBudgetStringArray = [[NSMutableArray alloc] init];

    if (!budget || budget.category == nil) {
        [resultBudgetStringArray addObject:[self.currencyFormatter stringFromNumber:usedAmount]];
		[resultBudgetStringArray addObject:[totalAmount compare:usedAmount] == NSOrderedAscending ? NSLocalizedString(@" over of ", @" over of ") : NSLocalizedString(@" left of ", @" left of ")];
        [resultBudgetStringArray addObject:[self.currencyFormatter stringFromNumber:totalAmount]];
    }
    else {
        [resultBudgetStringArray addObject:[self.currencyFormatter stringFromNumber: @(fabs(remainAmount.doubleValue)) ]];
		[resultBudgetStringArray addObject:remainAmount.doubleValue >= 0.0 ? NSLocalizedString(@" left of ", @" left of ") : NSLocalizedString(@" over of ", @" over of ") ];
        [resultBudgetStringArray addObject:[self.currencyFormatter stringFromNumber:totalAmount]];
    }

    _resultLabel.text = [resultBudgetStringArray componentsJoinedByString:@""];
    
    NSMutableAttributedString *resultAttribute = [[NSMutableAttributedString alloc] initWithAttributedString:_resultLabel.attributedText];
    [resultAttribute addAttribute: NSFontAttributeName
                            value: IS_IPHONE ? [UIFont boldSystemFontOfSize:17.0] : [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]
                            range: NSMakeRange(0, ((NSString *)resultBudgetStringArray[0]).length)];
    [resultAttribute addAttribute: NSForegroundColorAttributeName
                            value: [UIColor colorWithRed:123.0/255.0 green:123.0/255.0 blue:123.0/255.0 alpha:1.0]
                            range: NSMakeRange( ((NSString *)resultBudgetStringArray[0]).length, ((NSString *)resultBudgetStringArray[1]).length )];
    [resultAttribute addAttribute: NSFontAttributeName
                            value: IS_IPHONE ? [UIFont systemFontOfSize:17.0] : [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline]
                            range: NSMakeRange(((NSString *)resultBudgetStringArray[0]).length, ((NSString *)resultBudgetStringArray[1]).length+((NSString *)resultBudgetStringArray[2]).length)];

    _resultLabel.attributedText = resultAttribute;
    
    
    if (animation) {
        [self setNeedsUpdateConstraints];
        
        [UIView beginAnimations:A3AnimationIDKeyboardWillShow context:nil];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationCurve:7];
        [UIView setAnimationDuration:0.25];
        [UIView setAnimationDidStopSelector:@selector(setNeedsLayout)];
        
        [self adjustConstraintLayout];
        
        [_sliderBaseLineView layoutIfNeeded];
        [_sliderRedLineView layoutIfNeeded];
        [_usedAmountLabel layoutIfNeeded];
        [_resultLabel layoutIfNeeded];
        [_sliderThumbView layoutIfNeeded];
        
        [UIView commitAnimations];
        
    }
    else {
        [self adjustConstraintLayout];
    }
}

@end
