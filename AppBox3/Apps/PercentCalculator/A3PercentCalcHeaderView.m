//
//  A3PercentCalcHeaderView.m
//  A3TeamWork
//
//  Created by jeonghwan kim on 13. 10. 26..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3PercentCalcHeaderView.h"
#import "A3PercentCalculator.h"
#import <QuartzCore/QuartzCore.h>
#import "A3DefaultColorDefines.h"
#import "NSNumberFormatter+Extension.h"
#import "A3UIDevice.h"

#define kX1Tag  1
#define kX2Tag  2
#define kY1Tag  3
#define kY2Tag  4
#define kAnswer1Tag 5
#define kAnswer2Tag 6
#define kOperator1Tag 7
#define kOperator2Tag 8
#define kAnswerGap  10.0
#define kValues1Tag 11
#define kValues2Tag 12
#define kValues1_1Tag 13

@interface A3PercentCalcHeaderView ()

@property (assign, nonatomic) CGFloat padding;
@property (strong, nonatomic) MASConstraint *sliderThumb1LeadingCenter;
@property (strong, nonatomic) MASConstraint *sliderThumb2LeadingCenter;
@property (strong, nonatomic) NSMutableArray *factorViews;
@property (strong, nonatomic) NSMutableArray *operators;
@property (strong, nonatomic) NSArray *slider1MeterViews;
@property (strong, nonatomic) NSArray *slider1MeterLabelViews;
@property (strong, nonatomic) NSArray *slider1MeterLeadingConstArray;
@property (strong, nonatomic) NSArray *slider2MeterViews;
@property (strong, nonatomic) NSArray *slider2MeterLabelViews;
@property (strong, nonatomic) NSArray *slider2MeterLeadingConstArray;

@property (strong, nonatomic) MASConstraint *sliderLine1TopConst;
@property (strong, nonatomic) MASConstraint *sliderLine2TopCont;

@end

@implementation A3PercentCalcHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initialize];
        [self setupContraints];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
        [self setupContraints];
    }
    return self;
}

-(void)initialize {

    _sliderLine1View = [[UIView alloc] initWithFrame:CGRectZero];
    _sliderLine2View = [[UIView alloc] initWithFrame:CGRectZero];
    _sliderLine1View.backgroundColor = COLOR_DEFAULT_GRAY;
    _sliderLine2View.backgroundColor = COLOR_DEFAULT_GRAY;
    [self addSubview:_sliderLine1View];
    [self addSubview:_sliderLine2View];

    _sliderLine1GaugeView = [[UIView alloc] initWithFrame:CGRectZero];
    _sliderLine2GaugeView = [[UIView alloc] initWithFrame:CGRectZero];
    _sliderLine1GaugeView.backgroundColor = COLOR_DEFAULT_GRAY;
    _sliderLine2GaugeView.backgroundColor = COLOR_DEFAULT_GRAY;
    [self addSubview:_sliderLine1GaugeView];
    [self addSubview:_sliderLine2GaugeView];
    [self setupMeterViews];
    
    _slider1AMarkLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _slider1AMarkLabel.hidden = NO;
    _slider1AMarkLabel.layer.cornerRadius = 10.0;
    _slider1AMarkLabel.layer.masksToBounds = YES;
    _slider1AMarkLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:11];
    _slider1AMarkLabel.adjustsFontSizeToFitWidth = NO;
    _slider1AMarkLabel.text = NSLocalizedString(@"Percent_Calc_SliderMarkLabel_for_A", @"A");
    _slider1AMarkLabel.textColor = [UIColor whiteColor];
    _slider1AMarkLabel.textAlignment = NSTextAlignmentCenter;
    [_slider1AMarkLabel setBackgroundColor:[UIColor colorWithRed:123.0/255.0 green:123.0/255.0 blue:123.0/255.0 alpha:1.0]];
    [self addSubview:_slider1AMarkLabel];
    _slider2BMarkLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _slider2BMarkLabel.hidden = NO;
    _slider2BMarkLabel.layer.cornerRadius = 10.0;
    _slider2BMarkLabel.layer.masksToBounds = YES;
    _slider2BMarkLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:11];
    _slider2BMarkLabel.adjustsFontSizeToFitWidth = NO;
    _slider2BMarkLabel.text = NSLocalizedString(@"Percent_Calc_SliderMarkLabel_for_B", @"B");
    _slider2BMarkLabel.textColor = [UIColor whiteColor];
    _slider2BMarkLabel.textAlignment = NSTextAlignmentCenter;
    [_slider2BMarkLabel setBackgroundColor:[UIColor colorWithRed:123.0/255.0 green:123.0/255.0 blue:123.0/255.0 alpha:1.0]];
    [self addSubview:_slider2BMarkLabel];
    
    _sliderThumb1Label = [[UILabel alloc] initWithFrame:CGRectZero];
    _sliderThumb1Label.textColor = [UIColor blackColor];
    _sliderThumb1Label.font = IS_IPAD ? [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline] : [UIFont systemFontOfSize:15.0];
    _sliderLine1Thumb = [[A3OverlappedCircleView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    _sliderLine1Thumb.centerColor = COLOR_DEFAULT_GRAY;
    _sliderThumb2Label = [[UILabel alloc] initWithFrame:CGRectZero];
    _sliderThumb2Label.textColor = [UIColor blackColor];
    _sliderThumb2Label.font = IS_IPAD ? [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline] : [UIFont systemFontOfSize:15.0];
    _sliderLine2Thumb = [[A3OverlappedCircleView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    _sliderLine2Thumb.centerColor = COLOR_DEFAULT_GRAY;
    [self addSubview:_sliderLine1Thumb];
    [self addSubview:_sliderLine2Thumb];
    [self addSubview:_sliderThumb1Label];
    [self addSubview:_sliderThumb2Label];
    
    if (IS_IPAD) {
        _sliderThumb1Label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        _sliderThumb2Label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    } else {
        _sliderThumb1Label.font = [UIFont systemFontOfSize:15.0];
        _sliderThumb2Label.font = [UIFont systemFontOfSize:15.0];
    }
    
    _bottomLineView = [[UIView alloc] initWithFrame:CGRectZero];
    [self addSubview:_bottomLineView];
    
    self.backgroundColor = COLOR_HEADERVIEW_BG;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    FNLOG(@"h0");
    _slider1AMarkLabel.hidden = YES;
    _slider2BMarkLabel.hidden = YES;
    if (IS_IPHONE) {
        _sliderLine1TopConst.equalTo(@40);
        _padding = 15.0;
    } else {
        _sliderLine1TopConst.equalTo(@65);
        _padding = 28.0;
    }


    if (IS_IPAD) {
        [self adjustMeterViews];
    }
    
    FNLOG(@"headerView: %ld", (long)_calcType);
    FNLOG(@"h1");
    [self setupLayoutForPercentCalcType:_calcType];
    FNLOG(@"h2");
    [self adjustOperatorsFontSize];

    [super layoutSubviews];
    
    [self adjustSliderThumbLabelLimitedPosition];

    [super layoutSubviews];
}

#pragma mark - Initialize Layout

- (void)setupLayoutForPercentCalcType:(PercentCalcType)calcType
{
	//CGFloat kResultCenterY = 71.0;
	CGFloat kResultCenterY = 76;
	CGFloat kResult2CenterY = 143;
	if (IS_IPAD) {
		//kResultCenterY = 106.0;
		//kResult2CenterY = 193.0;
		kResultCenterY = 111;
		kResult2CenterY = 198;
	}

	if (_factorViews==nil) {
		_factorViews = [[NSMutableArray alloc] init];
	}

	[_factorViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		[obj removeFromSuperview];
	}];
	[_factorViews removeAllObjects];


	if (_operators==nil) {
		_operators = [[NSMutableArray alloc] init];
	}

	[_operators removeAllObjects];

	NSArray *fViews1;
	NSArray *fViews2;

	if (calcType==PercentCalcType_5) {
		_sliderLine2View.hidden = NO;
		_sliderLine2Thumb.hidden = NO;
		_sliderLine2GaugeView.hidden = NO;
		_sliderThumb2Label.hidden = NO;
		for (UIView * aView in _slider2MeterViews) {
			aView.hidden = NO;
		}
		for (UIView * aView in _slider2MeterLabelViews) {
			aView.hidden = NO;
		}

	} else {
		_sliderLine2View.hidden = YES;
		_sliderLine2Thumb.hidden = YES;
		_sliderLine2GaugeView.hidden = YES;
		_sliderThumb2Label.hidden = YES;
		for (UIView * aView in _slider2MeterViews) {
			aView.hidden = YES;
		}
		for (UIView * aView in _slider2MeterLabelViews) {
			aView.hidden = YES;
		}
	}

	switch (calcType) {
		case PercentCalcType_1:
		{
			// X is Y% of What
			UILabel *answerLabel = [self labelWithFrame:CGRectZero];
			UILabel *values1Label = [self labelWithFrame:CGRectZero];
			UILabel *values2Label = [self labelWithFrame:CGRectZero];
			answerLabel.tag = kAnswer1Tag;
			values1Label.tag = kValues1Tag;
			values2Label.tag = kValues1_1Tag;

			values2Label.text = @"X = ";
			values1Label.text = @" × Y%";
			answerLabel.text = @"";

			fViews1 = [NSArray arrayWithObjects:values1Label, answerLabel, values2Label, nil];
		}
			break;

		case PercentCalcType_2:
		{
			// What is X% of Y
			UILabel *answerLabel = [self labelWithFrame:CGRectZero];
			UILabel *valuesLabel = [self labelWithFrame:CGRectZero];
			answerLabel.tag = kAnswer1Tag;
			valuesLabel.tag = kValues1Tag;
			valuesLabel.text = @" = Y × X%";

			fViews1 = [NSArray arrayWithObjects:valuesLabel, answerLabel, nil];
		}
			break;
		case PercentCalcType_3:
		{
			// X is What % of Y, (X = Y x ANSWER)
			UILabel *answerLabel = [self labelWithFrame:CGRectZero];
			UILabel *valuesLabel = [self labelWithFrame:CGRectZero];
			answerLabel.tag = kAnswer1Tag;
			valuesLabel.tag = kValues1Tag;
			valuesLabel.text = @"X = Y × ";

			fViews1 = [NSArray arrayWithObjects:answerLabel, valuesLabel, nil];
		}
			break;
		case PercentCalcType_4:
		{
			// % Change from X to Y
			UILabel *answerLabel = [self labelWithFrame:CGRectZero];
			UILabel *valuesLabel = [self labelWithFrame:CGRectZero];
			answerLabel.tag = kAnswer1Tag;
			valuesLabel.tag = kValues1Tag;

			valuesLabel.text = @" = ( Y − X ) ÷ X × 100";

			fViews1 = [NSArray arrayWithObjects:valuesLabel, answerLabel, nil];
		}
			break;
		case PercentCalcType_5:
		{
			// Compare % Change from X to Y
			_slider1AMarkLabel.hidden = NO;
            _slider1AMarkLabel.layer.cornerRadius = 10.0;
			_slider1AMarkLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:11];
			_slider1AMarkLabel.adjustsFontSizeToFitWidth = NO;
			[_slider1AMarkLabel setBackgroundColor:[UIColor colorWithRed:123.0/255.0 green:123.0/255.0 blue:123.0/255.0 alpha:1.0]];

			_slider2BMarkLabel.hidden = NO;
            _slider2BMarkLabel.layer.cornerRadius = 10.0;
			_slider2BMarkLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:11];
			_slider2BMarkLabel.adjustsFontSizeToFitWidth = NO;
			[_slider2BMarkLabel setBackgroundColor:[UIColor colorWithRed:123.0/255.0 green:123.0/255.0 blue:123.0/255.0 alpha:1.0]];


			UILabel *answerLabel = [self labelWithFrame:CGRectZero];
			UILabel *valuesLabel = [self labelWithFrame:CGRectZero];
			answerLabel.tag = kAnswer1Tag;
			valuesLabel.tag = kValues1Tag;
			valuesLabel.text = @" = ( Y − X ) ÷ X × 100";
			fViews1 = [NSArray arrayWithObjects:valuesLabel, answerLabel, nil];

			UILabel *answerLabel2 = [self labelWithFrame:CGRectZero];
			UILabel *valuesLabel2 = [self labelWithFrame:CGRectZero];
			answerLabel2.tag = kAnswer2Tag;
			valuesLabel2.tag = kValues2Tag;
			valuesLabel2.text = @" = ( Y − X ) ÷ X × 100";
			fViews2 = [NSArray arrayWithObjects:valuesLabel2, answerLabel2, nil];
		}
			break;

		default:
			break;
	}

	[self setValuesToFactorViewArray:fViews1];
	[self adjustFactorViewsFont:fViews1];
	[self adjustFactorViewsFrame:fViews1 centerY:kResultCenterY];


	if (self.calcType==PercentCalcType_5) {
		[self setValuesToFactorViewArray:fViews2];
		[self adjustFactorViewsFont:fViews2];
		[self adjustFactorViewsFrame:fViews2 centerY:kResult2CenterY];
	}

	[_factorViews addObjectsFromArray:fViews1];
	[_factorViews addObjectsFromArray:fViews2];
}

- (BOOL)setValuesToFactorViewArray:(NSArray *)aViews
{
    if (aViews==nil || self.factorValues.values==nil) {
        _sliderThumb1Label.text = @"";
        _sliderThumb2Label.text = @"";
        
        _sliderLine1Thumb.hidden = YES;
        _sliderLine2Thumb.hidden = YES;
        _sliderLine1GaugeView.hidden = YES;
        _sliderLine2GaugeView.hidden = YES;
        
        self.factorValues.values = @[@0, @0, @0, @0];
    }
    
    __block NSArray *results;
    
    if (self.calcType == PercentCalcType_5) {
        if (self.factorValues.values.count < 4)
            return NO;
        
        if (![self.factorValues.values[0] isEqualToNumber:@0] && ![self.factorValues.values[1] isEqualToNumber:@0]) {
            _sliderLine1Thumb.hidden = NO;
            _sliderLine1GaugeView.hidden = NO;
        }
        if (![self.factorValues.values[2] isEqualToNumber:@0] && ![self.factorValues.values[3] isEqualToNumber:@0]) {
            _sliderLine2Thumb.hidden = NO;
            _sliderLine2GaugeView.hidden = NO;
        }
        
        results = [A3PercentCalculator percentCalculateFor:self.factorValues];
        
        NSArray *formattedValues = [self.factorValues formattedStringValuesByCalcType];
        
        [aViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            UILabel *aLabel = (UILabel *)obj;
            switch (aLabel.tag) {
                case kValues1Tag:
                {
                    aLabel.textColor = [UIColor blackColor];
                    aLabel.font = IS_IPAD ? [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline] : [UIFont systemFontOfSize:15.0];
                    
                    NSNumber * factorX1 = [self.factorValues.values objectAtIndex:0];
                    NSNumber * factorY1 = [self.factorValues.values objectAtIndex:1];
                    NSMutableArray * factorString = [NSMutableArray new];
                    [factorString addObject:[NSString stringWithFormat:@" = "]];//0
                    [factorString addObject:[NSString stringWithFormat:@"( "]];//1
                    [factorString addObject:[NSString stringWithFormat:@"%@", [factorY1 isEqualToNumber:@0] ? @"Y" : [formattedValues objectAtIndex:1]]];//2
                    [factorString addObject:[NSString stringWithFormat:@" - "]];//3
                    [factorString addObject:[NSString stringWithFormat:@"%@", [factorX1 isEqualToNumber:@0] ? @"X" : [formattedValues objectAtIndex:0]]];//4
                    [factorString addObject:[NSString stringWithFormat:@" )"]];//5
                    [factorString addObject:[NSString stringWithFormat:@" ÷ "]];//6
                    [factorString addObject:[NSString stringWithFormat:@"%@", [factorX1 isEqualToNumber:@0] ? @"X" : [formattedValues objectAtIndex:0]]];//7
                    [factorString addObject:[NSString stringWithFormat:@" × 100"]];//8
                    
                    aLabel.text = [factorString componentsJoinedByString:@""];
                }
                    break;
                case kValues2Tag:
                {
                    aLabel.textColor = [UIColor blackColor];
                    aLabel.font = IS_IPAD ? [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline] : [UIFont systemFontOfSize:15.0];
                    
                    NSNumber * factorX2 = [self.factorValues.values objectAtIndex:2];
                    NSNumber * factorY2 = [self.factorValues.values objectAtIndex:3];
                    NSMutableArray * factorString = [NSMutableArray new];
                    [factorString addObject:[NSString stringWithFormat:@" = "]];//0
                    [factorString addObject:[NSString stringWithFormat:@"( "]];//1
                    [factorString addObject:[NSString stringWithFormat:@"%@", [factorY2 isEqualToNumber:@0] ? @"Y" : [formattedValues objectAtIndex:3]]];//2
                    [factorString addObject:[NSString stringWithFormat:@" - "]];//3
                    [factorString addObject:[NSString stringWithFormat:@"%@", [factorX2 isEqualToNumber:@0] ? @"X" : [formattedValues objectAtIndex:2]]];//4
                    [factorString addObject:[NSString stringWithFormat:@" )"]];//5
                    [factorString addObject:[NSString stringWithFormat:@" ÷ "]];//6
                    [factorString addObject:[NSString stringWithFormat:@"%@", [factorX2 isEqualToNumber:@0] ? @"X" : [formattedValues objectAtIndex:2]]];//7
                    [factorString addObject:[NSString stringWithFormat:@" × 100"]];//8
                    
                    aLabel.text = [factorString componentsJoinedByString:@""];
                }
                    break;
                case kAnswer1Tag:
                {
                    if (results==nil || results.count==0) {
                        self.sliderThumb1Label.text = @"";
                        self.sliderThumb2Label.text = @"";
                        self.sliderLine1GaugeView.backgroundColor = COLOR_DEFAULT_GRAY;
                        self.sliderLine2GaugeView.backgroundColor = COLOR_DEFAULT_GRAY;
                        break;
                    }
                    
                    NSNumber *rNumber = [results objectAtIndex:0];
                    
                    // 초기화 되는 경우.
                    if ([rNumber isEqual:[NSNull null]]) {
                        [self showMeterViews:YES lineIndex:1];
                        // 애니메이션 적용.
                        [UIView animateWithDuration:0.4 animations:^{
                            self.sliderLine1Thumb.alpha = 0.0;
                            self.sliderThumb1Label.alpha = 0.0;
                        }];
                        // 위치조정.
                        self.sliderThumb1LeadingCenter.equalTo(@(-22));
                        [self.sliderLine1Thumb setNeedsUpdateConstraints];
                        [self.sliderThumb1Label setNeedsUpdateConstraints];
                        [self.sliderLine1GaugeView setNeedsUpdateConstraints];
                        [UIView animateWithDuration:0.3 animations:^{
                            [self.sliderLine1Thumb layoutIfNeeded];
                            [self.sliderThumb1Label layoutIfNeeded];
                            [self.sliderLine1GaugeView layoutIfNeeded];
                        }];
                        
                        break;
                    }
                    
                    aLabel.text = [NSString stringWithFormat:@"%@%%", [NSNumberFormatter exponentStringFromNumber:@(rNumber.doubleValue)]];
                    
                    if ([rNumber doubleValue] > 0.0) {
                        aLabel.layer.borderColor = [COLOR_POSITIVE CGColor];
                        aLabel.textColor = COLOR_POSITIVE;
                        self.sliderThumb1Label.text = NSLocalizedString(@"Increase", @"Increase");
                        self.sliderLine1GaugeView.backgroundColor = COLOR_POSITIVE;
                        self.sliderLine1Thumb.centerColorType = CenterColorType_Positive;
                    } else {
                        aLabel.layer.borderColor = [COLOR_NEGATIVE CGColor];
                        aLabel.textColor = COLOR_NEGATIVE;
                        self.sliderThumb1Label.text = NSLocalizedString(@"Decrease", @"Decrease");
                        self.sliderLine1GaugeView.backgroundColor = COLOR_NEGATIVE;
                        self.sliderLine1Thumb.centerColorType = CenterColorType_Negative;
                    }
                    
                    if (fabsl(rNumber.doubleValue) > 100.0) {
                        self.sliderThumb1LeadingCenter.equalTo(@(self.frame.size.width - 22.0));
                        [self showMeterViews:NO lineIndex:1];
                    } else {
                        CGFloat leading = (self.frame.size.width / 100.0) * fabsl(rNumber.doubleValue);
                        self.sliderThumb1LeadingCenter.equalTo(@(leading-22));
                        [self showMeterViews:YES lineIndex:1];
                    }

                    [self.sliderLine1Thumb setNeedsUpdateConstraints];
                    [self.sliderThumb1Label setNeedsUpdateConstraints];
                    [self.sliderLine1GaugeView setNeedsUpdateConstraints];
                    [UIView animateWithDuration:0.3 animations:^{
                        self.sliderLine1Thumb.alpha = 1.0;
                        self.sliderThumb1Label.alpha = 1.0;
                        [self.sliderLine1Thumb layoutIfNeeded];
                        [self.sliderThumb1Label layoutIfNeeded];
                        [self.sliderLine1GaugeView layoutIfNeeded];
                    }];
                }
                    break;
                case kAnswer2Tag:
                {
                    if (results==nil || results.count==0) {
                        self.sliderThumb1Label.text = @"";
                        self.sliderThumb2Label.text = @"";
                        break;
                    }
                    
                    NSNumber *rNumber = [results objectAtIndex:1];
                    
                    // 초기화 되는 경우.
                    if ([rNumber isEqual:[NSNull null]]) {
                        [self showMeterViews:YES lineIndex:2];
                        // 애니메이션 적용.
                        [UIView animateWithDuration:0.4 animations:^{
                            self.sliderThumb2Label.alpha = 0.0;
                            self.sliderLine2Thumb.alpha = 0.0;
                        }];
                        
                        // 위치 조정.
                        self.sliderThumb2LeadingCenter.equalTo(@(-22));
                        [self.sliderLine2Thumb setNeedsUpdateConstraints];
                        [self.sliderThumb2Label setNeedsUpdateConstraints];
                        [self.sliderLine2GaugeView setNeedsUpdateConstraints];
                        [UIView animateWithDuration:0.3 animations:^{
                            [self.sliderLine2Thumb layoutIfNeeded];
                            [self.sliderThumb2Label layoutIfNeeded];
                            [self.sliderLine2GaugeView layoutIfNeeded];
                        }];
                        
                        break;
                    }
                    
                    aLabel.text = [NSString stringWithFormat:@"%@%%", [NSNumberFormatter exponentStringFromNumber:@(rNumber.doubleValue)]];
                    
                    if (rNumber.doubleValue > 0.0) {
                        aLabel.layer.borderColor = [COLOR_POSITIVE CGColor];
                        aLabel.textColor = COLOR_POSITIVE;
                        self.sliderThumb2Label.text = NSLocalizedString(@"Increase", @"Increase");
                        self.sliderLine2GaugeView.backgroundColor = COLOR_POSITIVE;
                        self.sliderLine2Thumb.centerColorType = CenterColorType_Positive;
                    } else {
                        aLabel.layer.borderColor = [COLOR_NEGATIVE CGColor];
                        aLabel.textColor = COLOR_NEGATIVE;
                        self.sliderThumb2Label.text = NSLocalizedString(@"Decrease", @"Decrease");
                        self.sliderLine2GaugeView.backgroundColor = COLOR_NEGATIVE;
                        self.sliderLine2Thumb.centerColorType = CenterColorType_Negative;
                    }
                    
                    if (fabsl(rNumber.doubleValue) > 100.0) {
                        self.sliderThumb2LeadingCenter.equalTo(@(self.frame.size.width-22));
                        [self showMeterViews:NO lineIndex:2];
                    } else {
                        CGFloat leading = (self.frame.size.width / 100.0) * fabsl(rNumber.doubleValue);
                        self.sliderThumb2LeadingCenter.equalTo(@(leading-22));
                        [self showMeterViews:YES lineIndex:2];
                    }

//                    [self adjustSliderThumbLimitedPosition];

                    [self.sliderLine2Thumb setNeedsUpdateConstraints];
                    [self.sliderThumb2Label setNeedsUpdateConstraints];
                    [self.sliderLine2GaugeView setNeedsUpdateConstraints];
                    [UIView animateWithDuration:0.3 animations:^{
                        self.sliderThumb2Label.alpha = 1.0;
                        self.sliderLine2Thumb.alpha = 1.0;
                        self.sliderThumb2Label.alpha = 1.0;
                        [self.sliderLine2Thumb layoutIfNeeded];
                        [self.sliderThumb2Label layoutIfNeeded];
                        [self.sliderLine2GaugeView layoutIfNeeded];
                    }];
                }
                    break;
                    
                default:
                    break;
            }
            
        }];
        
    } else {
        
        if (self.factorValues.values.count<2)
            return NO;
        
        if (self.factorValues.values.count==2) {
            _sliderLine1Thumb.hidden = NO;
            _sliderLine1GaugeView.hidden = NO;
        }
        
        
        NSNumber * factorX1 = self.factorValues.values[0];
        NSNumber * factorY1 = self.factorValues.values[1];
        A3PercentCalcData *aData = [A3PercentCalcData new];
        aData.dataType = self.calcType;
        aData.values = self.factorValues.values;
        results = [A3PercentCalculator percentCalculateFor:aData];
        
        [_sliderLine1Thumb setNeedsUpdateConstraints];
        [_sliderThumb1Label setNeedsUpdateConstraints];
        [_sliderLine1GaugeView setNeedsUpdateConstraints];

        
        NSArray *formattedValues = [self.factorValues formattedStringValuesByCalcType];
        // Set Factors Number
        for (UILabel *aLabel in aViews) {
            switch (aLabel.tag) {
                case kValues1Tag:
                {
                    aLabel.textColor = [UIColor blackColor];
                    aLabel.font = IS_IPAD ? [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline] : [UIFont systemFontOfSize:15.0];
                    
                    if (self.calcType==PercentCalcType_1) {
                        NSMutableArray * factorString = [NSMutableArray new];
                        [factorString addObject:[NSString stringWithFormat:@" × "]];//0
                        [factorString addObject:[NSString stringWithFormat:@"%@", [factorY1 isEqualToNumber:@0]? @"Y%" : [formattedValues objectAtIndex:1]]];//1
                        aLabel.text = [factorString componentsJoinedByString:@""];
                        
                    } else if (self.calcType==PercentCalcType_2) {
                        NSMutableArray * factorString = [NSMutableArray new];
                        [factorString addObject:[NSString stringWithFormat:@" = "]];//0
                        [factorString addObject:[NSString stringWithFormat:@"%@", [factorY1 isEqualToNumber:@0]? @"Y" : [formattedValues objectAtIndex:1]]];//1
                        [factorString addObject:[NSString stringWithFormat:@" × "]];//2
                        [factorString addObject:[NSString stringWithFormat:@"%@", [factorX1 isEqualToNumber:@0]? @"X" : [formattedValues objectAtIndex:0]]];//3
                        aLabel.text = [factorString componentsJoinedByString:@""];
                        
                    } else if (self.calcType==PercentCalcType_3) {
                        NSMutableArray * factorString = [NSMutableArray new];
                        [factorString addObject:[NSString stringWithFormat:@"%@", [factorX1 isEqualToNumber:@0]? @"X" : [formattedValues objectAtIndex:0]]];//0
                        [factorString addObject:[NSString stringWithFormat:@" = "]];//1
                        [factorString addObject:[NSString stringWithFormat:@"%@", [factorY1 isEqualToNumber:@0]? @"Y" : [formattedValues objectAtIndex:1]]];//2
                        [factorString addObject:[NSString stringWithFormat:@" × "]];//3
                        aLabel.text = [factorString componentsJoinedByString:@""];
                        
                    } else if (self.calcType==PercentCalcType_4) {
                        aLabel.text = [NSString stringWithFormat:@" = ( %@ − %@ ) ÷ %@ × 100", [factorY1 isEqualToNumber:@0]? @"Y" : [formattedValues objectAtIndex:1],
                                       [factorX1 isEqualToNumber:@0]? @"X" : [formattedValues objectAtIndex:0],
                                       [factorX1 isEqualToNumber:@0]? @"X" : [formattedValues objectAtIndex:0]];
                        NSMutableArray * factorString = [NSMutableArray new];
                        [factorString addObject:[NSString stringWithFormat:@" = "]];//0
                        [factorString addObject:[NSString stringWithFormat:@"( "]];//1
                        [factorString addObject:[NSString stringWithFormat:@"%@", [factorY1 isEqualToNumber:@0] ? @"Y" : [formattedValues objectAtIndex:1]]];//2
                        [factorString addObject:[NSString stringWithFormat:@" - "]];//3
                        [factorString addObject:[NSString stringWithFormat:@"%@", [factorX1 isEqualToNumber:@0] ? @"X" : [formattedValues objectAtIndex:0]]];//4
                        [factorString addObject:[NSString stringWithFormat:@" )"]];//5
                        [factorString addObject:[NSString stringWithFormat:@" ÷ "]];//6
                        [factorString addObject:[NSString stringWithFormat:@"%@", [factorX1 isEqualToNumber:@0] ? @"X" : [formattedValues objectAtIndex:0]]];//7
                        [factorString addObject:[NSString stringWithFormat:@" × 100"]];//8
                        aLabel.text = [factorString componentsJoinedByString:@""];
                    }
                }
                    break;
                    
                case kValues1_1Tag:
                {
                    aLabel.textColor = [UIColor blackColor];
                    aLabel.font = IS_IPAD ? [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline] : [UIFont systemFontOfSize:15.0];
                    NSMutableArray * factorString = [NSMutableArray new];
                    [factorString addObject:[NSString stringWithFormat:@"%@", [factorX1 isEqualToNumber:@0]? @"X" : [formattedValues objectAtIndex:0]]];//0
                    [factorString addObject:[NSString stringWithFormat:@" = "]];//1
                    aLabel.text = [factorString componentsJoinedByString:@""];
                }
                    break;
                    
                case kAnswer1Tag:
                {
                    if (results==nil || results.count==0) {
                        //_sliderThumb1Label.text = @"";
                        //_sliderLine1GaugeView.backgroundColor = COLOR_DEFAULT_GRAY;
                        break;
                    }
                    [UIView animateWithDuration:0.4 animations:^{
                        [self setAnswerLabel:aLabel forFactorData:aData orResultData:results];
                    }];
                }
                    break;
                default:
                    break;
            }
        }
        
        
        // 결과 반영.
        NSNumber *rNumber;
        if (aData.dataType == PercentCalcType_1) {
            rNumber = self.factorValues.values[ValueIdx_Y1];
        } else if (aData.dataType == PercentCalcType_2) {
            rNumber = self.factorValues.values[ValueIdx_X1];
        } else {
            rNumber = [results objectAtIndex:0];
        }
        
        // 애니메이션 적용.
        if (results.count == 0 || [rNumber isEqualToNumber:@0]) {
            _sliderThumb1LeadingCenter.equalTo(@(-22));
            [self showMeterViews:YES lineIndex:1];
            [UIView animateWithDuration:0.4 animations:^{
                self.sliderLine1Thumb.alpha = 0.0;
                self.sliderThumb1Label.alpha = 0.0;
            }];
            [UIView animateWithDuration:0.3 animations:^{
                [self.sliderLine1Thumb layoutIfNeeded];
                [self.sliderThumb1Label layoutIfNeeded];
                [self.sliderLine1GaugeView layoutIfNeeded];
            }];
            
        } else {
            // 결과 라인 상단 레이블, 결과 % or 텍스트 출력
            if (_calcType == PercentCalcType_4) {
                if ([rNumber doubleValue] > 0.0) {
                    _sliderThumb1Label.text = NSLocalizedString(@"Increase", @"Increase");
                } else {
                    _sliderThumb1Label.text = NSLocalizedString(@"Decrease", @"Decrease");
                }
            } else {
                _sliderThumb1Label.text = [NSString stringWithFormat:@"%@%%", [NSNumberFormatter exponentStringFromNumber:rNumber]];
            }
            
            [_sliderThumb1Label sizeToFit];
            
            if (fabs(rNumber.doubleValue) > 100.0) {
                _sliderThumb1LeadingCenter.equalTo(@(self.frame.size.width - 22));
                [self showMeterViews:NO lineIndex:1];
            } else {
                CGFloat leading = (self.frame.size.width / 100.0) * fabsl(rNumber.doubleValue);
                _sliderThumb1LeadingCenter.equalTo(@(leading - 22.0));
                //_sliderThumb1LeadingCenter.equalTo(@(leading < 22 ? leading : (leading - 22)));
                [self showMeterViews:YES lineIndex:1];
            }

            [UIView animateWithDuration:0.3 animations:^{
                self.sliderLine1Thumb.alpha = 1.0;
                self.sliderThumb1Label.alpha = 1.0;
                [self.sliderLine1Thumb layoutIfNeeded];
                [self.sliderThumb1Label layoutIfNeeded];
                [self.sliderLine1GaugeView layoutIfNeeded];
            }];
        }
    }
    
    return YES;
}

- (void)adjustFactorViewsFont:(NSArray *)views {
    // 결과 뷰들 폰트 사이즈 지정.
    for (UILabel * aView in views) {
        if (aView.tag == kAnswer1Tag || aView.tag == kAnswer2Tag) {
            // border line 결과Label.
            if (IS_IPAD) {
                aView.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
            } else {
                //aView.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:17];
                aView.font = [UIFont boldSystemFontOfSize:17];
            }
            
            aView.layer.bounds = aView.bounds;
            aView.layer.borderWidth = IS_RETINA? 0.5 : 1.0;
            aView.layer.borderColor = [COLOR_POSITIVE CGColor];
            
        } else {
            if (IS_IPAD) {
                aView.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
            } else {
                aView.font = [UIFont systemFontOfSize:15];
            }
        }
        
        [aView sizeToFit];
    }
}

#pragma mark Adjust Subviews Position

- (void)adjustFactorViewsFrame:(NSArray *)views centerY:(CGFloat)centerY {
    
    CGFloat factorViewsWidth = 0.0;
    
    for (UIView * aView in views) {
        factorViewsWidth += aView.bounds.size.width;
    }
    
    if (factorViewsWidth > self.frame.size.width - 30) {
        for (int i=0; i < views.count; i++) {
            UIView * aView = [views objectAtIndex:i];
            CGRect rect = aView.frame;
            rect.size.width -= (factorViewsWidth - (self.bounds.size.width-30)) * ((aView.bounds.size.width) / factorViewsWidth);
            // Answer 뷰 사이즈 조정.
            [self addSubview:aView];
            // 결과 뷰 위치 지정.
            if (i==0) {
                // 0 번째 뷰
                if (aView.tag==kAnswer1Tag || aView.tag==kAnswer2Tag) {
                    UILabel *nextView = [views objectAtIndex:1];
                    [aView makeConstraints:^(MASConstraintMaker *make) {
                        make.width.lessThanOrEqualTo(@(rect.size.width));
                        make.height.greaterThanOrEqualTo(@25);
                        make.right.equalTo(self.right).with.offset(-self.padding);
                        make.centerY.equalTo(nextView.centerY);
                    }];
                } else {
                    [aView makeConstraints:^(MASConstraintMaker *make) {
                        make.width.lessThanOrEqualTo(@(rect.size.width));
                        make.right.equalTo(self.right).with.offset(-self.padding);
                        make.baseline.equalTo(self.top).with.offset(centerY);
                    }];
                }
            } else {
                // 1 ~ n 번째 뷰
                UILabel *preView = [views objectAtIndex:i-1];
                if (aView.tag==kAnswer1Tag || aView.tag==kAnswer2Tag) {
                    [aView makeConstraints:^(MASConstraintMaker *make) {
                        make.width.lessThanOrEqualTo(@(rect.size.width));
                        make.height.greaterThanOrEqualTo(@25);
                        make.right.equalTo(preView.left).with.offset(0);
                        make.centerY.equalTo(preView.centerY);
                    }];
                } else {
                    [aView makeConstraints:^(MASConstraintMaker *make) {
                        make.width.lessThanOrEqualTo(@(rect.size.width));
                        make.right.equalTo(preView.left).with.offset(0);
                        make.baseline.equalTo(self.top).with.offset(centerY);
                    }];
                }
            }
        }
        
    } else {
        
        for (int i=0; i < views.count; i++) {
            UIView * aView = [views objectAtIndex:i];
            [self addSubview:aView];
        }
        
        for (int i=0; i < views.count; i++) {
            UIView * aView = [views objectAtIndex:i];
//            CGRect rect = aView.frame;
//            rect.size.width -= (factorViewsWidth - self.bounds.size.width) * (aView.bounds.size.width / factorViewsWidth);

            // Answer 뷰 사이즈 조정.
//            if (aView.tag==kAnswer1Tag || aView.tag==kAnswer2Tag) {
//                [aView makeConstraints:^(MASConstraintMaker *make) {
//                    if (aView.frame.size.width > 52.0) {
//                        make.width.equalTo(@(aView.frame.size.width + 20.0));
//                    } else {
//                        make.width.greaterThanOrEqualTo(@72);
//                    }
//                    make.height.greaterThanOrEqualTo(@25);
//                }];
//            }
//            
//            [self addSubview:aView];
            
            // 결과 뷰 위치 지정.
            if (i==0) {
                [aView makeConstraints:^(MASConstraintMaker *make) {
                    make.right.equalTo(self.right).with.offset(-self.padding);

                    if (aView.tag==kAnswer1Tag || aView.tag==kAnswer2Tag) {
                        UILabel *nextView = [views objectAtIndex:1];
                        if (aView.frame.size.width > 52.0) {
                            make.width.equalTo(@(aView.frame.size.width + 20.0));
                        } else {
                            make.width.greaterThanOrEqualTo(@72);
                        }
                        make.height.greaterThanOrEqualTo(@25);
                        make.centerY.equalTo(nextView.centerY);
                        
                    } else {
//                        if (IS_IPHONE) {
//                            make.baseline.equalTo(self.top).with.offset(centerY);
//                        } else {
//                            make.centerY.equalTo(self.top).with.offset(centerY);
//                        }
                        make.baseline.equalTo(self.top).with.offset(centerY);
                    }
                }];
                
            } else {
                UILabel *preView = [views objectAtIndex:i-1];
                
                [aView makeConstraints:^(MASConstraintMaker *make) {
                    if (i == views.count-1) {
                        make.leading.greaterThanOrEqualTo(@(self.padding));
                    }
                    make.right.equalTo(preView.left).with.offset(0);
                    
                    if (aView.tag==kAnswer1Tag || aView.tag==kAnswer2Tag) {
                        if (aView.frame.size.width > 52.0) {
                            make.width.equalTo(@(aView.frame.size.width + 20.0));
                        } else {
                            make.width.greaterThanOrEqualTo(@72);
                        }
                        make.height.greaterThanOrEqualTo(@25);
                        make.centerY.equalTo(preView.centerY);
                    } else {
//                        if (IS_IPHONE) {
//                            make.baseline.equalTo(self.top).with.offset(centerY);
//                        } else {
//                            make.centerY.equalTo(self.top).with.offset(centerY);
//                        }
                        make.baseline.equalTo(self.top).with.offset(centerY);
                    }
                }];
            }
        }
    }
}

-(void)adjustMeterViews {
    if (IS_IPHONE) {
        return;
    }
    
    [_slider1MeterLeadingConstArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        MASConstraint *leading = obj;
        leading.equalTo(@((self.sliderLine1View.frame.size.width / 5.0)  * (idx+1)));
    }];
    
    [_slider2MeterLeadingConstArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        MASConstraint *leading = obj;
        leading.equalTo(@((self.sliderLine1View.frame.size.width / 5.0)  * (idx+1)));
    }];
    
    
    [_slider1MeterLabelViews enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger idx, BOOL *stop) {
        label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
    }];
    
    [_slider2MeterLabelViews enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger idx, BOOL *stop) {
        label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
    }];
    

}

- (void)adjustOperatorsFontSize {
    [_operators enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UILabel * aLabel = (UILabel *) obj;
        if (IS_IPAD) {
            aLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        } else {
            aLabel.adjustsFontSizeToFitWidth = NO;
            aLabel.font = [UIFont systemFontOfSize:15];
        }
        [aLabel sizeToFit];
    }];
    
    if (IS_IPAD) {
        _sliderThumb1Label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        _sliderThumb2Label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    }
    
    [_sliderThumb1Label sizeToFit];
    [_sliderThumb2Label sizeToFit];
}

-(void)adjustSliderThumbLabelLimitedPosition
{
    if (_sliderThumb1Label.frame.size.width + _sliderThumb1Label.frame.origin.x > self.bounds.size.width) {
        CGRect rect = _sliderThumb1Label.frame;
        rect.origin.x = self.bounds.size.width - _sliderThumb1Label.frame.size.width;
        _sliderThumb1Label.frame = rect;
    }
    else if (_sliderThumb1Label.frame.origin.x < 0) {
        CGRect rect = _sliderThumb1Label.frame;
        rect.origin.x = 0.0;
        _sliderThumb1Label.frame = rect;
    }
    
    if (_sliderThumb2Label.frame.size.width + _sliderThumb2Label.frame.origin.x > self.bounds.size.width) {
        CGRect rect = _sliderThumb2Label.frame;
        rect.origin.x = self.bounds.size.width - _sliderThumb2Label.frame.size.width;
        _sliderThumb2Label.frame = rect;
    }
    else if (_sliderThumb2Label.frame.origin.x < 0) {
        CGRect rect = _sliderThumb2Label.frame;
        rect.origin.x = 0.0;
        _sliderThumb2Label.frame = rect;
    }
}

#pragma mark - Extracted Methods

-(void)setAnswerLabel:(UILabel *)aLabel forFactorData:(A3PercentCalcData *)aData orResultData:(NSArray *)results
{
    switch (aData.dataType) {
        case PercentCalcType_3: // What is X% of Y
        case PercentCalcType_4: // % Change from X to Y
        {
            NSNumber *rNumber = [results objectAtIndex:0];


            aLabel.text = [NSString stringWithFormat:@"%@%%", [NSNumberFormatter exponentStringFromNumber:rNumber]];
            
            if ([[results objectAtIndex:0] doubleValue] > 0.0) {
                aLabel.layer.borderColor = [COLOR_POSITIVE CGColor];
                aLabel.textColor = COLOR_POSITIVE;
                _sliderLine1GaugeView.backgroundColor = COLOR_POSITIVE;
                _sliderLine1Thumb.centerColorType = CenterColorType_Positive;
            } else {
                aLabel.layer.borderColor = [COLOR_NEGATIVE CGColor];
                aLabel.textColor = COLOR_NEGATIVE;
                _sliderLine1GaugeView.backgroundColor = COLOR_NEGATIVE;
                _sliderLine1Thumb.centerColorType = CenterColorType_Negative;
            }
        }
            break;
            
        default:
        {
            NSNumber *rNumber = [results objectAtIndex:0];
            aLabel.text = [NSNumberFormatter exponentStringFromNumber:rNumber];
            
            if ([[results objectAtIndex:0] doubleValue] > 0.0) {
                aLabel.layer.borderColor = [COLOR_POSITIVE CGColor];
                aLabel.textColor = COLOR_POSITIVE;
                [aLabel setNeedsDisplay];
                _sliderLine1GaugeView.backgroundColor = COLOR_POSITIVE;
                _sliderLine1Thumb.centerColorType = CenterColorType_Positive;
            } else {
                aLabel.layer.borderColor = [COLOR_NEGATIVE CGColor];
                aLabel.textColor = COLOR_NEGATIVE;
                _sliderLine1GaugeView.backgroundColor = COLOR_NEGATIVE;
                _sliderLine1Thumb.centerColorType = CenterColorType_Negative;
            }
        }
            break;
    }
}

-(void)changeAnswerLabelColor:(A3PercentCalcData *)aData orResultData:(NSArray *)results
{
    
}

- (UILabel *)labelWithFrame:(CGRect)frame {
	UILabel *label = [[UILabel alloc] initWithFrame:frame];
	label.textColor = [UIColor blackColor];
	label.textAlignment = NSTextAlignmentCenter;
	label.adjustsFontSizeToFitWidth = YES;
	label.minimumScaleFactor = 0.5;
	return label;
}

-(void)setupContraints {
    [_sliderLine1View makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@5);
        make.left.equalTo(self.left);
        make.right.equalTo(self.right);
        if (IS_IPHONE) {
            self.sliderLine1TopConst = make.top.equalTo(@40);
        } else {
            self.sliderLine1TopConst = make.top.equalTo(@65);
        }
    }];
    [_sliderLine1Thumb makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@44);
        make.height.equalTo(@44);
        make.centerY.equalTo(self.sliderLine1View.centerY);
        //_sliderThumb1LeadingCenter = make.leading.equalTo(@0);
        _sliderThumb1LeadingCenter = make.left.equalTo(self.left);
    }];
    [_sliderLine1GaugeView makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.left);
        make.right.equalTo(self.sliderLine1Thumb.left).with.offset(22.0);
        make.centerY.equalTo(self.sliderLine1View.centerY);
        make.height.equalTo(self.sliderLine1View.height);
    }];
    [_slider1AMarkLabel makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@20);
        make.height.equalTo(@20);
        make.centerY.equalTo(self.sliderLine1View.centerY);
        make.right.equalTo(self.right).with.offset(-15);
    }];
    [_sliderThumb1Label makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.sliderLine1Thumb.centerX);
        if (IS_IPHONE) {
            //make.baseline.equalTo(self.bottom).with.offset(-135.0);
            //make.baseline.equalTo(self.bottom).with.offset(-135.0);
            make.baseline.equalTo(self.top).with.offset(31.0);
        } else {
            //make.bottom.equalTo(_sliderLine1Thumb.top).with.offset(14);
            make.baseline.equalTo(self.top).with.offset(54);
        }
    }];
    
    
    [_sliderLine2View makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@5);
        make.left.equalTo(self.left);
        make.right.equalTo(self.right);
        if (IS_IPHONE) {
            self.sliderLine2TopCont = make.top.equalTo(@107);
        } else {
            self.sliderLine2TopCont = make.top.equalTo(@152);
        }
    }];
    [_sliderLine2GaugeView makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(self.sliderLine2View.height);
        make.leading.equalTo(@0);
        make.right.equalTo(self.sliderLine2Thumb.centerX);
        make.centerY.equalTo(self.sliderLine2View.centerY);
    }];
    [_slider2BMarkLabel makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@20);
        make.height.equalTo(@20);
        make.centerY.equalTo(self.sliderLine2View.centerY);
        make.right.equalTo(self.right).with.offset(-15);
    }];
    [_sliderLine2Thumb makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@44);
        make.height.equalTo(@44);
        make.centerY.equalTo(self.sliderLine2View.centerY);
        self.sliderThumb2LeadingCenter = make.leading.equalTo(@0);
    }];
    [_sliderThumb2Label makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.sliderLine2Thumb.centerX);
        if (IS_IPHONE) {
            make.baseline.equalTo(self.top).with.offset(98);
        } else {
            make.baseline.equalTo(self.top).with.offset(141);
        }
    }];
    
    [_bottomLineView makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.left);
        make.right.equalTo(self.right);
        if (IS_RETINA) {
            make.height.equalTo(@0.5);
        } else {
            make.height.equalTo(@1);
        }
        make.bottom.equalTo(self.bottom);
    }];
    
    _sliderLine1Thumb.centerColorType = CenterColorType_Neutral;
    _sliderLine1GaugeView.backgroundColor = COLOR_DEFAULT_GRAY;
    _sliderLine2Thumb.centerColorType = CenterColorType_Neutral;
    _sliderLine2GaugeView.backgroundColor = COLOR_DEFAULT_GRAY;

}

-(void)setupMeterViews
{
    if (IS_IPAD) {
        if (_slider1MeterViews) {
            return;
        }
        
        if (!_slider1MeterViews) {
            NSMutableArray *aViews = [[NSMutableArray alloc] init];
            NSMutableArray *aLabels = [[NSMutableArray alloc] init];
            for (int i=0; i<5; i++) {
                UIView *aView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, IS_RETINA? 0.5 : 1.0, 0.0)];
                UILabel *aLabel = [[UILabel alloc] initWithFrame:CGRectZero];
                aView.backgroundColor = COLOR_DEFAULT_GRAY;
                aLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
                [aViews addObject:aView];
                [aLabels addObject:aLabel];
                [self addSubview:aView];
                [self addSubview:aLabel];
            }
            _slider1MeterViews = aViews;
            _slider1MeterLabelViews = aLabels;
            
            aViews = [[NSMutableArray alloc] init];
            aLabels = [[NSMutableArray alloc] init];
            for (int i=0; i<5; i++) {
                UIView *aView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, IS_RETINA? 0.5 : 1.0, 0.0)];
                UILabel *aLabel = [[UILabel alloc] initWithFrame:CGRectZero];
                aLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
                aView.backgroundColor = COLOR_DEFAULT_GRAY;
                [aViews addObject:aView];
                [aLabels addObject:aLabel];
                [self addSubview:aView];
                [self addSubview:aLabel];
            }
            _slider2MeterViews = aViews;
            _slider2MeterLabelViews = aLabels;
            
            NSMutableArray *meterLeadings = [NSMutableArray new];
            [_slider1MeterViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                UIView *meterView = (UIView *) obj;
                [meterView makeConstraints:^(MASConstraintMaker *make) {
                    make.width.equalTo(IS_RETINA? @0.5 : @1.0);
                    make.height.equalTo(@18);
                    make.top.equalTo(self.sliderLine1View.bottom);
                    MASConstraint *leading = make.leading.equalTo(@((self.sliderLine1View.frame.size.width / 5.0)  * (idx+1)));
                    [meterLeadings addObject:leading];
                }];
                self.slider1MeterLeadingConstArray = meterLeadings;
                
                UILabel *meterLabel = _slider1MeterLabelViews[idx];
                meterLabel.text = [NSString stringWithFormat:@"%ld%%", (long)20 * (idx+1)];
                meterLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
                meterLabel.textColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0];
                [meterLabel sizeToFit];
                [meterLabel makeConstraints:^(MASConstraintMaker *make) {
                    make.baseline.equalTo(self.sliderLine1View.bottom).with.offset(13);
                    make.right.equalTo(meterView.left).with.offset(IS_RETINA ? -4.5 : -5);
                }];
            }];
            
            meterLeadings = [NSMutableArray new];
            [_slider2MeterViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                UIView *meterView = (UIView *) obj;
                [meterView makeConstraints:^(MASConstraintMaker *make) {
                    make.width.equalTo(IS_RETINA? @0.5 : @1.0);
                    make.height.equalTo(@18);
                    make.top.equalTo(self.sliderLine2View.bottom);
                    MASConstraint *leading = make.leading.equalTo(@((self.sliderLine2View.frame.size.width / 5.0)  * (idx+1)));
                    [meterLeadings addObject:leading];
                }];
                self.slider2MeterLeadingConstArray = meterLeadings;
                
                UILabel *meterLabel = self.slider2MeterLabelViews[idx];
                meterLabel.text = [NSString stringWithFormat:@"%ld%%", (long)20 * (idx+1)];
                meterLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
                meterLabel.textColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0];
                [meterLabel sizeToFit];
                [meterLabel makeConstraints:^(MASConstraintMaker *make) {
                    make.baseline.equalTo(self.sliderLine2View.bottom).with.offset(13);
                    make.right.equalTo(meterView.left).with.offset(IS_RETINA ? -4.5 : -5);
                }];

                if (self.calcType != PercentCalcType_5) {
                    meterView.hidden = YES;
                    meterLabel.hidden = YES;
                }
            }];
        }
    }
}

-(void)showMeterViews:(BOOL)bShow lineIndex:(NSInteger)lineIndex
{
    if (lineIndex==1) {
        [_slider1MeterLabelViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            ((UILabel *)obj).hidden = bShow ? NO : YES;
        }];
        [_slider1MeterViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            ((UIView *)obj).hidden = bShow ? NO : YES;
        }];
    } else {
        [_slider2MeterLabelViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            ((UILabel *)obj).hidden = bShow ? NO : YES;
        }];
        [_slider2MeterViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            ((UIView *)obj).hidden = bShow ? NO : YES;
        }];
    }
}

@end
