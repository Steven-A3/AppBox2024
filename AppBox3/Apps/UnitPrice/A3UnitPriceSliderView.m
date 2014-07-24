//
//  A3UnitPriceSliderView.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 10. 30..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3UnitPriceSliderView.h"
#import "A3TripleCircleView.h"
#import "A3UIDevice.h"
#import "common.h"

@interface A3UnitPriceSliderView ()

@property (nonatomic, strong) A3TripleCircleView *thumbView;

@end

@implementation A3UnitPriceSliderView

@synthesize progressBarHidden = _progressBarHidden;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
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

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    _unitPriceValue = 0;
    _priceValue = 0;
    _maxValue = 0;

	_unitPriceLabel.text = NSLocalizedString(@"Unit Price", nil);
	_priceLabel.text = NSLocalizedString(@"Price", nil);
    [self labelFontSetting];
    [self initialize];
}

- (CGSize)sizeThatFits:(CGSize)size {
	return [self intrinsicContentSize];
}

- (CGSize)intrinsicContentSize {
	if (IS_IPAD) {
		return CGSizeMake(704.0, 64.0);
	} else {
        return CGSizeMake(320.0, 64.0);
    }
}

- (void)setLayoutWithAnimated
{
    [self updateSliderWithAnimation:YES];
}

- (void)setLayoutWithNoAnimated
{
    [self updateSliderWithAnimation:NO];
}

- (void)initialize
{
    self.thumbView = [[A3TripleCircleView alloc] init];
    _thumbView.frame = CGRectMake(0, 0, 31, 31);
    _thumbView.center = CGPointMake(0, _lineView.center.y);
    [self addSubview:_thumbView];
    
    _markLabel.layer.cornerRadius = _markLabel.bounds.size.width/2;
    
    _markLabel.font = [UIFont systemFontOfSize:11];
    _markLabel.backgroundColor = [UIColor colorWithRed:123.0/255.0 green:123.0/255.0 blue:123.0/255.0 alpha:1.0];
}

- (void)labelFontSetting {
    // text size
    if (IS_IPAD) {
        self.unitPriceLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
        //self.unitPriceNumLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        self.unitPriceNumLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        self.priceNumLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        self.priceLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    }
    else {
        self.unitPriceLabel.font = [UIFont systemFontOfSize:13];
        //self.unitPriceNumLabel.font = [UIFont systemFontOfSize:15];
        self.unitPriceNumLabel.font = [UIFont boldSystemFontOfSize:17];
        self.priceNumLabel.font = [UIFont boldSystemFontOfSize:17];
        self.priceLabel.font = [UIFont systemFontOfSize:17];
    }
    
    // color
    self.priceNumLabel.textColor = [UIColor blackColor];
}

- (void)setDisplayColor:(UIColor *)displayColor
{
    _displayColor = displayColor;
    _thumbView.centerColor = _displayColor;
    _progressLineView.backgroundColor = _displayColor;
}

-(void)setLayoutType:(UnitPriceSliderViewLayout)layoutType
{
    _layoutType = layoutType;
    switch (_layoutType) {
        case Slider_StandAlone:
        {
            _unitPriceLabel.hidden = NO;
            _priceLabel.hidden = NO;
            _unitPriceNumLabel.center = CGPointMake(_unitPriceNumLabel.center.x, _unitPriceLabel.center.y -1);
            _priceLabel.center = CGPointMake(_priceLabel.center.x, _priceNumLabel.center.y +1);
            _markLabel.hidden = YES;
            break;
        }
        case Slider_UpperOfTwo:
        {
            _unitPriceLabel.hidden = NO;
            _priceLabel.hidden = NO;
            _unitPriceNumLabel.center = CGPointMake(_unitPriceNumLabel.center.x, _priceNumLabel.center.y);
            _priceLabel.center = CGPointMake(_priceLabel.center.x, _unitPriceLabel.center.y);
            _markLabel.hidden = NO;
            break;
        }
        case Slider_LowerOfTwo:
        {
            _unitPriceLabel.hidden = YES;
            _priceLabel.hidden = YES;
            _unitPriceNumLabel.center = CGPointMake(_unitPriceNumLabel.center.x, _priceNumLabel.center.y);
            _markLabel.hidden = NO;
            break;
        }
        default:
            break;
    }
}


- (void)setMaxValue:(double)maxValue
{
    _maxValue = (maxValue>0) ? maxValue : 0;
}

- (void)setMinValue:(double)minValue
{
    _minValue = (minValue > 0) ? minValue : 0;
}

- (void)setPriceValue:(float)priceValue
{
    _priceValue = (priceValue>0) ? priceValue : 0;
    _priceValue = (priceValue<=_maxValue) ? priceValue : _maxValue;
}

- (BOOL)allValueValid
{
    if ((_maxValue>0) && (_priceValue>0) && (_unitPriceValue>0)) {
        return YES;
    }
    else return NO;
}

- (void)updateSliderWithAnimation:(BOOL) animated
{
    float leftSideMargin = IS_IPAD ? 28.0:15.0;
    float rightSideMargin = 15.0;
    float lbBetweenMargin = 10.0;
    float progressLineMaxWidth = _lineView.frame.size.width * 0.8;
    
    float unitPrice = _unitPriceValue;
    float pixelPerPrice = progressLineMaxWidth / _maxValue;
    
    if ((floor(_unitPriceValue * 100) / 100) == (floor(_minValue * 100) / 100) && _unitPriceValue < _maxValue && ((1.0 - (_minValue / _maxValue)) < 0.05)) {
        pixelPerPrice = progressLineMaxWidth / (_maxValue * 1.1);
    }

    // slider part
    // 경계값 체크
    float thumbX = _thumbView.center.x;
    float thumbX_Min, thumbX_Max, markX_Min, markX_Max;
    if (_maxValue > 0) {
        thumbX = pixelPerPrice * unitPrice;
    }
    else {
        thumbX = 0;
    }
    
    thumbX_Min = _thumbView.frame.size.width / 2;
    thumbX_Max = progressLineMaxWidth;
    
    
    thumbX = MIN(thumbX, thumbX_Max);
    thumbX = MAX(thumbX, thumbX_Min);
    [_unitPriceLabel sizeToFit];
    [_unitPriceNumLabel sizeToFit];
    _unitPriceNumLabel.center = CGPointMake(thumbX, _unitPriceNumLabel.center.y);
    
    float markX = _markLabel.center.x;
    markX = _lineView.frame.size.width - (_markLabel.frame.size.width / 2) - 15;
    markX_Min = _markLabel.frame.size.width/2 + _thumbView.frame.size.width;
    markX_Max = _lineView.frame.size.width - _markLabel.frame.size.width/2;
    markX = MIN(markX, markX_Max);
    markX = MAX(markX, markX_Min);
    // number label
    // 센터값 대입
    [_priceLabel sizeToFit];
    [_priceNumLabel sizeToFit];
    _priceNumLabel.center = CGPointMake(markX, _priceNumLabel.center.y);
    
    
    // 경계값 체크
    switch (_layoutType) {
        case Slider_StandAlone:
        {
            float unitPriceNumX_Min = 0 + leftSideMargin + _unitPriceNumLabel.frame.size.width/2;
            float unitPriceNumX_Max = _lineView.frame.size.width - (lbBetweenMargin + _unitPriceLabel.frame.size.width +rightSideMargin + _unitPriceNumLabel.frame.size.width/2);
            
            if (_unitPriceNumLabel.center.x < unitPriceNumX_Min) {
                _unitPriceNumLabel.center = CGPointMake(unitPriceNumX_Min, _unitPriceLabel.center.y);
            }
            
            if (_unitPriceNumLabel.center.x > unitPriceNumX_Max) {
                _unitPriceNumLabel.center = CGPointMake(unitPriceNumX_Max, _unitPriceLabel.center.y);
            }
            
            float priceNumX_Min = 0 + leftSideMargin + _priceNumLabel.frame.size.width/2;
            float priceNumX_Max = _lineView.frame.size.width - (lbBetweenMargin + _priceLabel.frame.size.width +rightSideMargin + _priceNumLabel.frame.size.width/2);
            
            if (_priceNumLabel.center.x < priceNumX_Min) {
                _priceNumLabel.center = CGPointMake(priceNumX_Min, _priceNumLabel.center.y);
            }
            
            if (_priceNumLabel.center.x > priceNumX_Max) {
                _priceNumLabel.center = CGPointMake(priceNumX_Max, _priceNumLabel.center.y);
            }
            
            break;
        }
        case Slider_UpperOfTwo:
        case Slider_LowerOfTwo:
        {
            float unitPriceNumX_Min = 0 + leftSideMargin + _unitPriceNumLabel.frame.size.width/2;
            float unitPriceNumX_Max = _lineView.frame.size.width - (lbBetweenMargin + _priceNumLabel.frame.size.width +rightSideMargin + _unitPriceNumLabel.frame.size.width/2);
            
            
            if (_unitPriceNumLabel.center.x < unitPriceNumX_Min) {
                _unitPriceNumLabel.center = CGPointMake(unitPriceNumX_Min, _unitPriceNumLabel.center.y);
            }
            
            if (_unitPriceNumLabel.center.x > unitPriceNumX_Max) {
                _unitPriceNumLabel.center = CGPointMake(unitPriceNumX_Max, _unitPriceNumLabel.center.y);
            }
            
            float priceNumX_Min = _unitPriceNumLabel.center.x + _unitPriceNumLabel.frame.size.width/2 +lbBetweenMargin + _priceNumLabel.frame.size.width/2;
            float priceNumX_Max = _lineView.frame.size.width - (_priceNumLabel.frame.size.width/2 + rightSideMargin);
            
            if (_priceNumLabel.center.x < priceNumX_Min) {
                _priceNumLabel.center = CGPointMake(priceNumX_Min, _priceNumLabel.center.y);
            }
            
            if (_priceNumLabel.center.x > priceNumX_Max) {
                _priceNumLabel.center = CGPointMake(priceNumX_Max, _priceNumLabel.center.y);
            }
            
            break;
        }
        default:
            break;
    }
    
    // Unit Price, Price 위치
    switch (_layoutType) {
        case Slider_StandAlone:
        {
            float betweenGap1 = 8;
            float betweenGap2 = 6;
            float unitPriceLabelCenterX = [_unitPriceNumLabel.text isEqualToString:@""] ? _unitPriceNumLabel.center.x + _unitPriceLabel.frame.size.width/2 : _unitPriceNumLabel.center.x + _unitPriceNumLabel.frame.size.width/2 + betweenGap1 + _unitPriceLabel.frame.size.width/2;
            float priceLabelCenterX = _priceNumLabel.center.x + _priceNumLabel.frame.size.width/2 + betweenGap2 + _priceLabel.frame.size.width/2;
            _unitPriceLabel.center = CGPointMake(unitPriceLabelCenterX, _unitPriceLabel.center.y);
            _priceLabel.center = CGPointMake(priceLabelCenterX, _priceLabel.center.y);
            
            break;
        }
        case Slider_UpperOfTwo:
        {
            // 좌측 , 우측에 고정하는걸로 수정
            _unitPriceLabel.center = CGPointMake(leftSideMargin + _unitPriceLabel.frame.size.width/2, _unitPriceLabel.center.y);
            _priceLabel.center = CGPointMake(_lineView.frame.size.width - rightSideMargin - _priceLabel.frame.size.width/2, _priceLabel.center.y);
            
            break;
        }
        default:
            break;
    }

    if (animated) {
        // 애니메이션
        _priceLabel.alpha = 0.0;
        _unitPriceLabel.alpha = 0.0;
        _priceNumLabel.alpha = 0.0;
        _unitPriceNumLabel.alpha = 0.0;
        
        float aniDuration = 0.3;
        [UIView beginAnimations:@"SliderUpdate" context:NULL];
        [UIView setAnimationDuration:aniDuration];
        CGPoint center = _thumbView.center;
        center = CGPointMake(thumbX, center.y);
        _thumbView.center = center;
        
        center = _markLabel.center;
        center = CGPointMake(markX, center.y);
        _markLabel.center = center;
        
        CGRect frame = _progressLineView.frame;
        frame.size.width = _thumbView.center.x;
        _progressLineView.frame = frame;
        
        _priceLabel.alpha = 1.0;
        _unitPriceLabel.alpha = 1.0;
        _priceNumLabel.alpha = 1.0;
        _unitPriceNumLabel.alpha = 1.0;
        
        [UIView commitAnimations];
    }
    else {
        // 애니메이션
        CGPoint center = _thumbView.center;
        center = CGPointMake(thumbX, center.y);
        _thumbView.center = center;
        
        center = _markLabel.center;
        center = CGPointMake(markX, center.y);
        _markLabel.center = center;
        
        CGRect frame = _progressLineView.frame;
        frame.size.width = _thumbView.center.x;
        _progressLineView.frame = frame;
    }
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self updateSliderWithAnimation:NO];
}

- (void)setProgressBarHidden:(BOOL)progressBarHidden
{
    _progressBarHidden = progressBarHidden;
    
    _progressLineView.hidden = _progressBarHidden;
    _thumbView.hidden = _progressBarHidden;
}

- (BOOL)progressBarHidden
{
    return _progressBarHidden;
}

@end

