//
//  A3DateCalcHeaderView.m
//  A3TeamWork
//
//  Created by jeonghwan kim on 13. 10. 11..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3DateCalcHeaderView.h"
#import "common.h"
#import "A3Utilities.h"
#import "SFKImage.h"
#import <QuartzCore/QuartzCore.h>
#import "A3DateCalcStateManager.h"
#import "A3DateCalcResultCursorView.h"
#import "NSDate+formatting.h"
#import "A3DefaultColorDefines.h"
#import "A3OverlappedCircleView.h"

//#define SLIDER_OFFSET       23
#define SLIDER_OFFSET_LABEL     20
#define SLIDER_THUMB_MARGIN     20

#define COLOR_ELLIPSE_0     [UIColor colorWithRed:229.0/255.0 green:229.0/255.0 blue:229.0/255.0 alpha:1.0]
#define COLOR_ELLIPSE_1     [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0]
#define COLOR_ELLIPSE_1_BORDER     [UIColor colorWithRed:188.0/255.0 green:188.0/255.0 blue:188.0/255.0 alpha:1.0]
#define COLOR_ELLIPSE_2_Center     [UIColor colorWithRed:12.0/255.0 green:95.0/255.0 blue:200.0/255.0 alpha:1.0]
#define COLOR_ELLIPSE_2_Center_GRAY     [UIColor colorWithRed:123.0/255.0 green:123.0/255.0 blue:123.0/255.0 alpha:1.0]

@interface A3DateCalcHeaderView()

@property (strong, nonatomic) NSDate * minDate;
@property (strong, nonatomic) NSDate * maxDate;
@property (strong, nonatomic) NSDate * fromDate;
@property (strong, nonatomic) NSDate * toDate;

@property (assign, nonatomic) CGFloat minValue;
@property (assign, nonatomic) CGFloat maxValue;
@property (assign, nonatomic) CGFloat fromValue;
@property (assign, nonatomic) CGFloat toValue;

@property (weak, nonatomic) IBOutlet UIView *sliderLineView;    // 슬라이더 베이스 라인
@property (strong, nonatomic) A3DateCalcResultCursorView *resultLabel;   // 슬라이더 커서 상단 결과 출력
@property (weak, nonatomic) IBOutlet UILabel *fromLabel;    // 슬라이더 커서 하단 날짜 출력
@property (weak, nonatomic) IBOutlet UILabel *toLabel;      // 슬라이더 커서 하단 날짜 출력

@property (strong, nonatomic) A3OverlappedCircleView * fromThumbView;
@property (strong, nonatomic) A3OverlappedCircleView * toThumbView;

@property (weak, nonatomic) IBOutlet UIView *fromToRangeLineView;   // 슬라이더 커서 간격 표시 라인
@property (weak, nonatomic) IBOutlet UIView *bottomLineView;

@property (assign, nonatomic) CGFloat availableWidth;

@end

@implementation A3DateCalcHeaderView
{
    CALC_TYPE _calcType;
    BOOL _fromLagerThanTo;
    BOOL _freezeToDragLeftCircle;   // from
    BOOL _freezeToDragRightCircle;  // to
    CGFloat SLIDER_OFFSET;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self initialize];
}

#pragma mark - Initialization

- (void)initialize
{
    _minValue = 0;
    _maxValue = 100;
    
    SLIDER_OFFSET = IS_RETINA ? 22.5 : 23;
    
    CGFloat lineYOffset = 0.0;
    CGFloat lineHeight = 1.0;
    CGFloat borderLine = 1.0;
    
    if (IS_RETINA) {
        lineYOffset = 1.0;
        lineHeight = 0.5;
        borderLine = 0.5;
    }
    
    // 1 point 라인이 2 point 로 보이는 현상 제거를 위하여...
    {
        CGRect rect = _bottomLineView.frame;
        rect.origin.y += lineYOffset;
        rect.size.height = lineHeight;
        _bottomLineView.frame = rect;
        _bottomLineView.backgroundColor = COLOR_TABLE_SEPARATOR;
        
        rect = _fromToRangeLineView.frame;
        rect.size.height = lineHeight;
        _fromToRangeLineView.frame = rect;
        
        rect = _sliderLineView.frame;
        rect.size.height = lineHeight;
        _sliderLineView.frame = rect;
    }
    
    _fromThumbView = [[A3OverlappedCircleView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];;
    _toThumbView = [[A3OverlappedCircleView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];;
    _fromThumbView.centerColor = COLOR_NEGATIVE;
    _toThumbView.centerColor = COLOR_NEGATIVE;
    
    [self addSubview:_fromThumbView];
    [self addSubview:_toThumbView];
    
    if (IS_IPHONE) {
        _sliderLineView.center = CGPointMake(_sliderLineView.center.x, 59.0);
        _fromToRangeLineView.center = CGPointMake(_fromToRangeLineView.center.x, 59.0);
        _fromThumbView.center = CGPointMake(_fromThumbView.center.x, 59.0);
        _toThumbView.center = CGPointMake(_toThumbView.center.x, 59.0);
        
//        _fromLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:13.0];
//        _toLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:13.0];
        _fromLabel.font = [UIFont systemFontOfSize:13];
        _toLabel.font = [UIFont systemFontOfSize:13];

    } else {
        _sliderLineView.center = CGPointMake(_sliderLineView.center.x, 78.0);
        _fromToRangeLineView.center = CGPointMake(_fromToRangeLineView.center.x, 78.0);
        _fromThumbView.center = CGPointMake(_fromThumbView.center.x, 78.0);
        _toThumbView.center = CGPointMake(_toThumbView.center.x, 78.0);
    }

    _resultLabel = [[A3DateCalcResultCursorView alloc] initWithFrame:CGRectZero ArrowDirection:ArrowDirection_From];
    _resultLabel.center = _sliderLineView.center;
    [self addSubview:_resultLabel];
    //_resultLabel.arrowDirection = ArrowDirection_From;

    _toThumbView.centerColor = COLOR_ELLIPSE_2_Center;

    [self setupGestureRecognizer];

    self.backgroundColor = COLOR_HEADERVIEW_BG;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    //    [self initialize];

    [self setupConstraints];
    [super layoutSubviews];
    
    if (IS_RETINA) {
        CGRect rect = _sliderLineView.frame;
        rect.size.height = 0.5;
        _sliderLineView.frame = rect;
        rect = _fromToRangeLineView.frame;
        rect.size.height = 0.5;
        _fromToRangeLineView.frame = rect;
        rect = _bottomLineView.frame;
        rect.size.height = 0.5;
        _bottomLineView.frame = rect;
    }

}

- (void)setupConstraints
{
    [_resultLabel setNeedsLayout];
    if (IS_IPAD) {
        _fromLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        _toLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        [_fromLabel sizeToFit];
        [_toLabel sizeToFit];
    }
    
    if (_calcType == CALC_TYPE_SUB) {
        [self setupResultLabelPositionForThumbView:_fromThumbView];
    } else {
        [self setupResultLabelPositionForThumbView:nil];
    }
    [self adjustFromToBetweenLineWidth];
    [self adjustFromToLabelPosition];
}

- (void)setupGestureRecognizer
{
    UIPanGestureRecognizer *fromPan = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(fromThumbPanGesture:)];
    UITapGestureRecognizer *fromTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(fromThumbTapGesture:)];
    [_fromThumbView addGestureRecognizer:fromPan];
    [_fromThumbView addGestureRecognizer:fromTap];
    
    UIPanGestureRecognizer *toPan = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                            action:@selector(toThumbPanGesture:)];
    UITapGestureRecognizer *toTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(toThumbTapGesture:)];
    [_toThumbView addGestureRecognizer:toPan];
    [_toThumbView addGestureRecognizer:toTap];
}

#pragma mark - Actions
- (void)fromThumbPanGesture:(UIPanGestureRecognizer *)gesture {

    if (_freezeToDragLeftCircle) {
        return;
    }
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
    }

    if (gesture.state == UIGestureRecognizerStateBegan || gesture.state == UIGestureRecognizerStateChanged) {
        if (_calcType == CALC_TYPE_ADD) {
            return;
        }
        
        CGPoint transition = [gesture translationInView:self];
        self.fromValue += transition.x;
        [gesture setTranslation:CGPointZero inView:self];
        
        
        if (_calcType == CALC_TYPE_SUB) {
            [self setupResultLabelPositionForThumbView:_fromThumbView];
        } else if (_calcType == CALC_TYPE_ADD) {
            [self setupResultLabelPositionForThumbView:_toThumbView];
            self.resultLabel.arrowDirection = ArrowDirection_To;
        } else {
            [self setupResultLabelPositionForThumbView:_fromLagerThanTo==NO ? _toThumbView : _fromThumbView];
            self.resultLabel.arrowDirection = _fromLagerThanTo==NO ? ArrowDirection_To : ArrowDirection_From;
        }
        [self calculateBetweenFromAndTo];
    }
}

- (void)toThumbPanGesture:(UIPanGestureRecognizer *)gesture {
    
    if (_freezeToDragRightCircle) {
        return;
    }
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
    }

    if (gesture.state == UIGestureRecognizerStateBegan || gesture.state == UIGestureRecognizerStateChanged) {
        if (_calcType == CALC_TYPE_SUB) {
            return;
        }
        
        CGPoint transition = [gesture translationInView:self];
        self.toValue += transition.x;
        [gesture setTranslation:CGPointZero inView:self];
        //[self setupRangeLine];
        if (_calcType == CALC_TYPE_SUB) {
            [self setupResultLabelPositionForThumbView:_fromThumbView];
        } else {
            [self setupResultLabelPositionForThumbView:_toThumbView];
        }
        [self calculateBetweenFromAndTo];
    }
}

- (void)fromThumbTapGesture:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        // handling code
        NSLog(@"fromThumbTapGesture");
        if ([_delegate respondsToSelector:@selector(dateCalcHeaderFromThumbTapped)]) {
            [_delegate dateCalcHeaderFromThumbTapped];
        }
    }
}

- (void)toThumbTapGesture:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        // handling code
        NSLog(@"toThumbTapGesture");
        if ([_delegate respondsToSelector:@selector(dateCalcHeaderToThumbTapped)]) {
            [_delegate dateCalcHeaderToThumbTapped];
        }
    }
}

#pragma mark -

- (void)setCalcType:(CALC_TYPE)aType {
    _calcType = aType;
}

- (void)setFromValue:(CGFloat)newValue {
    _fromValue = newValue;
    if (_fromValue < SLIDER_OFFSET) {
        _fromValue = SLIDER_OFFSET;
        _fromLabel.textColor = [UIColor blackColor];
    } else {
        _fromLabel.textColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
    }
    
    if (_fromValue > (_toThumbView.center.x - SLIDER_THUMB_MARGIN)) {
        _fromValue = (_toThumbView.center.x - SLIDER_THUMB_MARGIN);
    }
    
    CGPoint point = _fromThumbView.center;
    point.x = _fromValue;
    
    [UIView animateWithDuration:0.5
                          delay:0
         usingSpringWithDamping:500.0f
          initialSpringVelocity:0.0f
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         _fromThumbView.center = point;
                     } completion:^(BOOL finished) {

                     }];
}

- (void)setToValue:(CGFloat)newValue {
    _toValue = newValue;
    if (_toValue > CGRectGetWidth(_sliderLineView.frame) - SLIDER_OFFSET) {
        _toValue = CGRectGetWidth(_sliderLineView.frame) - SLIDER_OFFSET;
        _toLabel.textColor = [UIColor blackColor];
    } else {
        _toLabel.textColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
    }
    
    if (_toValue < (_fromThumbView.center.x + SLIDER_THUMB_MARGIN)) {
        _toValue = (_fromThumbView.center.x + SLIDER_THUMB_MARGIN);
    }
    
    CGPoint point = _toThumbView.center;
    point.x = _toValue;
    NSLog(@"toValue: %f", _toValue);
    
    [UIView animateWithDuration:0.5
                          delay:0
         usingSpringWithDamping:500.0f
          initialSpringVelocity:0.0f
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         _toThumbView.center = point;
                     } completion:^(BOOL finished) {
                         
                     }];
}

- (void)setFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate
{
    if (_calcType == CALC_TYPE_BETWEEN) {
        if ([fromDate compare:toDate] == NSOrderedAscending || [fromDate compare:toDate] == NSOrderedSame) {
            _fromLagerThanTo = NO;
            [self setFromDate:fromDate];
            [self setToDate:toDate];
        } else {
            _fromLagerThanTo = YES;
            [self setFromDate:toDate];
            [self setToDate:fromDate];
        }
    } else {
        _fromLagerThanTo = NO;
        [self setFromDate:fromDate];
        [self setToDate:toDate];
    }
}

- (void)setFromDate:(NSDate *)fromDate
{
    _fromDate = [fromDate copy];
    _minValue = 0.0;
    _minDate = _fromDate;
    
    self.fromLabel.text = [A3DateCalcStateManager formattedStringDate:_fromDate];
    [_fromLabel sizeToFit];
    
    self.fromValue = 0.0;
}

- (void)setToDate:(NSDate *)toDate
{
    _toDate = [toDate copy];
    _maxValue = CGRectGetWidth(self.sliderLineView.frame);
    _maxDate = toDate;

    self.toLabel.text = [A3DateCalcStateManager formattedStringDate:_toDate];
    [_toLabel sizeToFit];
    self.toValue = CGRectGetWidth(self.sliderLineView.frame);
}

// Between two Days 출력 부분.
- (void)setResultDate:(NSDateComponents *)resultDate
{
    if (_calcType == CALC_TYPE_BETWEEN) {
        // DurationType durationType = [A3DateCalcStateManager durationType];
        DurationType durationType = [A3DateCalcStateManager currentDurationType];
        NSMutableArray *result = [[NSMutableArray alloc] init];

        switch (durationType) {
            case DurationType_Year:
                [result addObject:[NSString stringWithFormat:@"%ld years", (long)resultDate.year]];
                break;
            case DurationType_Month:
                [result addObject:[NSString stringWithFormat:@"%ld months", (long)resultDate.month]];
                break;
            case DurationType_Week:
                [result addObject:[NSString stringWithFormat:@"%ld weeks", (long)resultDate.week]];
                break;
            case DurationType_Day:
                [result addObject:[NSString stringWithFormat:@"%ld days", (long)resultDate.day]];
                break;
                
            default:
            {
                if (durationType & DurationType_Year) {
                    if (resultDate.year != 0) {
                        [result addObject:[NSString stringWithFormat:@"%ld years", (long)resultDate.year]];
                    }
                }
                if (durationType & DurationType_Month) {
                    if (resultDate.month != 0) {
                        [result addObject:[NSString stringWithFormat:@"%ld months", (long)resultDate.month]];
                    }
                }
                if (durationType & DurationType_Week) {
                    if (resultDate.week != 0) {
                        [result addObject:[NSString stringWithFormat:@"%ld weeks", (long)resultDate.week]];
                    }
                }
                if (durationType & DurationType_Day) {
                    if (resultDate.day != 0) {
                        [result addObject:[NSString stringWithFormat:@"%ld days", (long)resultDate.day]];
                    }
                }
            }
                break;
        }
    
        if (result.count==0) {
            _resultLabel.hidden = YES;
        } else {
            _resultLabel.hidden = NO;
            [_resultLabel setResultText:[result componentsJoinedByString:@" "]];
        }
        
    } else if (_calcType == CALC_TYPE_ADD) {
        
    }
}

// Add or Sub Subtract Days 출력 부분.
- (NSString *)getDateStringByDurationTypeForComponent:(NSDateComponents *)resultDate
{
    //DurationType durationType = [A3DateCalcStateManager durationType];
    DurationType durationType = [A3DateCalcStateManager currentDurationType];
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    switch (durationType) {
        case DurationType_Year:
            [result addObject:[NSString stringWithFormat:@"%ldyears", labs((long)resultDate.year)]];
            break;
        case DurationType_Month:
            [result addObject:[NSString stringWithFormat:@"%ldmonths", labs((long)resultDate.month)]];
            break;
        case DurationType_Week:
            [result addObject:[NSString stringWithFormat:@"%ldweeks", labs((long)resultDate.week)]];
            break;
        case DurationType_Day:
            [result addObject:[NSString stringWithFormat:@"%lddays", labs((long)resultDate.day)]];
            break;
            
        default:
        {
            if (durationType & DurationType_Year) {
                if (resultDate.year != 0) {
                    [result addObject:[NSString stringWithFormat:@"%ldyears", labs((long)resultDate.year)]];
                }
            }
            if (durationType & DurationType_Month) {
                if (resultDate.month != 0) {
                    [result addObject:[NSString stringWithFormat:@"%ldmonths", labs((long)resultDate.month)]];
                }
            }
            if (durationType & DurationType_Week) {
                if (resultDate.week != 0) {
                    [result addObject:[NSString stringWithFormat:@"%ldweeks", labs((long)resultDate.week)]];
                }
            }
            if (durationType & DurationType_Day) {
                if (resultDate.day != 0) {
                    [result addObject:[NSString stringWithFormat:@"%lddays", labs((long)resultDate.day)]];
                }
            }
            
            if (result.count==0) {
                if (_calcType == CALC_TYPE_SUB) {
                    [result addObject:[NSString stringWithFormat:@"0days"]];
                } else {
                    [result addObject:[NSString stringWithFormat:@"0days"]];
                }
            }
        }
            break;
    }
    
    return [result componentsJoinedByString:@" "];
}

#pragma mark - View Control, Result Reflection
- (void)adjustFromToBetweenLineWidth
{
    CGRect fRect = _fromThumbView.frame;
    CGRect tRect = _toThumbView.frame;
    CGRect rect = _fromToRangeLineView.frame;
    CGFloat fXpos = _fromValue + CGRectGetWidth(fRect)/8;
    CGFloat tXpos = _toValue - CGRectGetWidth(tRect)/8;
    
    NSLog(@"_toThumbView.center.x: %f", _toThumbView.center.x);
    
    rect.origin = CGPointMake(fXpos, rect.origin.y);
    rect.size = CGSizeMake(tXpos - fXpos, rect.size.height);
    
    [UIView animateWithDuration:0.5
                          delay:0
         usingSpringWithDamping:500.0f
          initialSpringVelocity:0.0f
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         [_fromToRangeLineView setFrame:rect];
                     } completion:^(BOOL finished) {
                         
                     }];
    
//    // From Label 위치 지정
//    [_fromLabel sizeToFit];
//    NSDictionary *attributes;
//    if (IS_IPAD) {
//        attributes = @{ NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline] };
//    } else {
//        attributes = @{ NSFontAttributeName : [UIFont fontWithName:@"Helvetica Neue" size:13.0] };
//    }
//    CGRect fontRect = [_fromLabel.text boundingRectWithSize:CGSizeMake(240.0, 26.0)
//                                                    options:NSStringDrawingUsesLineFragmentOrigin
//                                                 attributes:attributes
//                                                    context:nil];
//    
//    _fromLabel.center = CGPointMake(_fromThumbView.center.x, _toLabel.center.y);
//    CGRect labelRect = _fromLabel.frame;
//    if (IS_IPHONE) {
//        labelRect.origin.y = _sliderLineView.center.y + 9.0;
//    } else {
//        labelRect.origin.y = _sliderLineView.center.y + 23.0;
//    }
//    
//    labelRect.size.width = fontRect.size.width;
//    if (labelRect.origin.x < self.bounds.origin.x + SLIDER_OFFSET_LABEL ) {
//        labelRect.origin.x = self.bounds.origin.x + SLIDER_OFFSET_LABEL;
//    } else if ((labelRect.origin.x+labelRect.size.width+SLIDER_OFFSET_LABEL) > _toLabel.frame.origin.x) {
//        labelRect.origin.x = _toLabel.frame.origin.x - labelRect.size.width - SLIDER_OFFSET_LABEL;
//    }
//    
//    _fromLabel.frame = labelRect;
//    
//    // ToLabel 위치 지정
//    [_toLabel sizeToFit];
//    //attributes = @{NSFontAttributeName:[UIFont preferredFontForTextStyle:UIFontTextStyleFootnote]};
//    fontRect = [_toLabel.text boundingRectWithSize:CGSizeMake(240.0, 26.0)
//                                           options:NSStringDrawingUsesLineFragmentOrigin
//                                        attributes:attributes
//                                           context:nil];
//    _toLabel.center = CGPointMake(_toThumbView.center.x, _toLabel.center.y);
//    labelRect = _toLabel.frame;
//    labelRect.size.width = fontRect.size.width;
//    if (IS_IPHONE) {
//        labelRect.origin.y = _sliderLineView.center.y + 9.0;
//    } else {
//        labelRect.origin.y = _sliderLineView.center.y + 23.0;
//    }
//
//    if ((labelRect.origin.x+labelRect.size.width) > (CGRectGetWidth(self.bounds) - SLIDER_OFFSET_LABEL)) {
//        labelRect.origin.x = CGRectGetWidth(self.bounds) - labelRect.size.width - SLIDER_OFFSET_LABEL;
//        
//    } else if (labelRect.origin.x < (_fromLabel.frame.origin.x + _fromLabel.frame.size.width + SLIDER_OFFSET_LABEL)) {
//        labelRect.origin.x = _fromLabel.frame.origin.x + _fromLabel.frame.size.width + SLIDER_OFFSET_LABEL;
//    }
//    
//    _toLabel.frame = labelRect;
}

- (void)adjustFromToLabelPosition {
    // From Label 위치 지정
    [_fromLabel sizeToFit];
    NSDictionary *attributes;
    if (IS_IPAD) {
        attributes = @{ NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline] };
    } else {
        //attributes = @{ NSFontAttributeName : [UIFont fontWithName:@"Helvetica Neue" size:13.0] };
        attributes = @{ NSFontAttributeName : [UIFont systemFontOfSize:13] };
    }
    CGRect fontRect = [_fromLabel.text boundingRectWithSize:CGSizeMake(240.0, 26.0)
                                                    options:NSStringDrawingUsesLineFragmentOrigin
                                                 attributes:attributes
                                                    context:nil];
    
    _fromLabel.center = CGPointMake(_fromThumbView.center.x, _toLabel.center.y);
    CGRect labelRect = _fromLabel.frame;
    if (IS_IPHONE) {
        labelRect.origin.y = _sliderLineView.center.y + 9.0;
    } else {
        labelRect.origin.y = _sliderLineView.center.y + 23.0;
    }
    
    labelRect.size.width = fontRect.size.width;
    if (labelRect.origin.x < self.bounds.origin.x + SLIDER_OFFSET_LABEL ) {
        labelRect.origin.x = self.bounds.origin.x + SLIDER_OFFSET_LABEL;
    } else if ((labelRect.origin.x+labelRect.size.width+SLIDER_OFFSET_LABEL) > _toLabel.frame.origin.x) {
        labelRect.origin.x = _toLabel.frame.origin.x - labelRect.size.width - SLIDER_OFFSET_LABEL;
    }
    
    _fromLabel.frame = labelRect;
    
    // ToLabel 위치 지정
    [_toLabel sizeToFit];
    //attributes = @{NSFontAttributeName:[UIFont preferredFontForTextStyle:UIFontTextStyleFootnote]};
    fontRect = [_toLabel.text boundingRectWithSize:CGSizeMake(240.0, 26.0)
                                           options:NSStringDrawingUsesLineFragmentOrigin
                                        attributes:attributes
                                           context:nil];
    _toLabel.center = CGPointMake(_toThumbView.center.x, _toLabel.center.y);
    labelRect = _toLabel.frame;
    labelRect.size.width = fontRect.size.width;
    if (IS_IPHONE) {
        labelRect.origin.y = _sliderLineView.center.y + 9.0;
    } else {
        labelRect.origin.y = _sliderLineView.center.y + 23.0;
    }
    
    if ((labelRect.origin.x+labelRect.size.width) > (CGRectGetWidth(self.bounds) - SLIDER_OFFSET_LABEL)) {
        labelRect.origin.x = CGRectGetWidth(self.bounds) - labelRect.size.width - SLIDER_OFFSET_LABEL;
        
    } else if (labelRect.origin.x < (_fromLabel.frame.origin.x + _fromLabel.frame.size.width + SLIDER_OFFSET_LABEL)) {
        labelRect.origin.x = _fromLabel.frame.origin.x + _fromLabel.frame.size.width + SLIDER_OFFSET_LABEL;
    }
    
    _toLabel.frame = labelRect;
}

- (void)setupResultLabelPositionForThumbView:(UIView *)aThumbView
{
    if (_calcType==CALC_TYPE_BETWEEN) {
        if (_fromLagerThanTo == YES) {
            aThumbView = _fromThumbView;
            self.resultLabel.arrowDirection = ArrowDirection_From;
        } else {
            aThumbView = _toThumbView;
            self.resultLabel.arrowDirection = ArrowDirection_To;
        }
    } else {
        if (_calcType==CALC_TYPE_ADD) {
            aThumbView = _toThumbView;
            self.resultLabel.arrowDirection = ArrowDirection_To;
        } else {
            aThumbView = _fromThumbView;
            self.resultLabel.arrowDirection = ArrowDirection_From;
        }
    }

    if (_fromThumbView==aThumbView) {
        CGRect rRect = _resultLabel.frame;
        CGRect fRect = _fromThumbView.frame;

        rRect.origin.x =_fromThumbView.center.x + CGRectGetWidth(fRect)/2;
        rRect.origin.y = _sliderLineView.center.y - 9.0 - CGRectGetHeight(_resultLabel.frame);
        rRect.size.width = _resultLabel.sizeOfResultText.width + 38;
        rRect.size.height = 23;
        
        if (rRect.origin.x+rRect.size.width > CGRectGetWidth(self.bounds)) {
            rRect.origin.x = CGRectGetWidth(self.bounds) - rRect.size.width;
        }
        _resultLabel.frame = rRect;
        
    } else {
        CGRect rRect = _resultLabel.frame;
        CGRect tRect = _toThumbView.frame;

        rRect.origin.x = _toThumbView.center.x - CGRectGetWidth(tRect)/2 - _resultLabel.sizeOfResultText.width - 35;
        rRect.origin.y = _sliderLineView.center.y - 9.0 - CGRectGetHeight(_resultLabel.frame);
        rRect.size.width = _resultLabel.sizeOfResultText.width + 38;
        rRect.size.height = 23;

        if (rRect.origin.x < 0) {
            rRect.origin.x = 0;
        }
        _resultLabel.frame = rRect;
    }
}

- (void)setupSliderThumbShadeByCalcType
{
    _toThumbView.hidden = NO;
    _toLabel.hidden = NO;
    _fromToRangeLineView.hidden = NO;
    
    if (_calcType == CALC_TYPE_BETWEEN) {
        
        if (_fromLagerThanTo) {
            // From 날짜가 To 날짜보다 큰 경우.
            _fromThumbView.centerColor = COLOR_ELLIPSE_2_Center;
            _toThumbView.centerColor = COLOR_ELLIPSE_2_Center_GRAY;
            _freezeToDragLeftCircle = NO;
            _freezeToDragRightCircle = YES;
            
        } else {
            
            if ([_fromDate isEqualToDate:_toDate]) {
                // From 날짜 To 날짜 같은 경우.
                _fromThumbView.centerColor = COLOR_ELLIPSE_2_Center_GRAY;
                _freezeToDragLeftCircle = YES;
                _toThumbView.hidden = YES;
                _toLabel.hidden = YES;
                _fromToRangeLineView.hidden = YES;
            } else {
                // From 날짜가 To 날짜보다 작은 경우.
                _fromThumbView.centerColor = COLOR_ELLIPSE_2_Center_GRAY;
                _toThumbView.centerColor = COLOR_ELLIPSE_2_Center;
                _freezeToDragLeftCircle = YES;
                _freezeToDragRightCircle = NO;
            }
        }

    } else if (_calcType == CALC_TYPE_ADD) {
        _fromThumbView.centerColor = COLOR_ELLIPSE_2_Center_GRAY;
        _toThumbView.centerColor = COLOR_ELLIPSE_2_Center;
        _freezeToDragLeftCircle = YES;
        _freezeToDragRightCircle = NO;
        
    } else if (_calcType == CALC_TYPE_SUB) {
        _fromThumbView.centerColor = COLOR_ELLIPSE_2_Center;
        _toThumbView.centerColor = COLOR_ELLIPSE_2_Center_GRAY;
        _freezeToDragLeftCircle = NO;
        _freezeToDragRightCircle = YES;
    }
}

#pragma mark - Date Calc Related
- (void)calculateBetweenFromAndTo
{
    NSInteger minDayCount = 0;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *result = [calendar components:NSDayCalendarUnit fromDate:_minDate toDate:_maxDate options:0];
    NSInteger maxDayCount = result.day;
    
    CGFloat offsetFrom = minDayCount + ((_fromValue-SLIDER_OFFSET) / (_maxValue-SLIDER_OFFSET)) * maxDayCount;
    CGFloat offsetTo = minDayCount + (_toValue / (_maxValue-SLIDER_OFFSET)) * maxDayCount;
    NSLog(@"offset From: %f = %ld + (%f / %f) * %ld", offsetFrom, (long)minDayCount, (_fromValue-SLIDER_OFFSET), _maxValue-SLIDER_OFFSET, (long)maxDayCount);
    NSLog(@"offset To: %f = %ld + (%f / %f) * %ld", offsetTo, (long)minDayCount, _toValue, _maxValue-SLIDER_OFFSET, (long)maxDayCount);
    NSDateComponents *fComp = [NSDateComponents new];
    NSDateComponents *tComp = [NSDateComponents new];
    if (_calcType == CALC_TYPE_SUB) {
        fComp.day = maxDayCount + abs(offsetFrom);
    } else {
        fComp.day = offsetFrom;
    }

    tComp.day = offsetTo;
    
    NSDate *fDate = [[A3DateCalcStateManager currentCalendar] dateByAddingComponents:fComp toDate:_minDate options:0];
    NSDate *tDate = [[A3DateCalcStateManager currentCalendar] dateByAddingComponents:tComp toDate:_minDate options:0];
    
    if (_calcType == CALC_TYPE_BETWEEN) {
        NSDateComponents *resultComp = [A3DateCalcStateManager dateComponentFromDate:fDate toDate:tDate];
        _fromDate = fDate;
        _toDate = tDate;
        NSLog(@"MinDate: %@, FromDate: %@", _minDate, _fromDate);
        NSLog(@"MaxDate: %@, ToDate: %@", _maxDate, _toDate);

        [self setResultBetweenDate:resultComp withAnimation:YES];
        if ([_delegate respondsToSelector:@selector(dateCalcHeaderChangedFromDate:toDate:)]) {
            [_delegate dateCalcHeaderChangedFromDate:fDate toDate:tDate];
        }

        _fromLabel.text = [A3DateCalcStateManager formattedStringDate:fDate];
        _toLabel.text = [A3DateCalcStateManager formattedStringDate:tDate];
    } else if (_calcType == CALC_TYPE_ADD) {
        [self setResultAddDate:tDate withAnimation:YES];
    } else if (_calcType == CALC_TYPE_SUB) {
        [self setResultSubDate:fDate withAnimation:YES];
    }
}

- (NSDateComponents *)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime
{
    if (fromDateTime==nil || toDateTime==nil) {
        return 0;
    }
    
    NSDate *fromDate;
    NSDate *toDate;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&fromDate
                 interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&toDate
                 interval:NULL forDate:toDateTime];
    
    DurationType durationType = [A3DateCalcStateManager durationType];
    NSCalendarUnit calUnit;
    
    if (durationType == DurationType_Month) {
        calUnit = NSMonthCalendarUnit | NSDayCalendarUnit;
    } else if (durationType == DurationType_Week) {
        calUnit = NSWeekdayCalendarUnit;
    } else if (durationType == DurationType_Day) {
        calUnit = NSDayCalendarUnit;
    } else {
        calUnit = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    }
    NSDateComponents *result = [calendar components:calUnit
                                               fromDate:fromDate toDate:toDate options:0];

    [self setResultDate:result];
    
    return result;
}

- (void)setResultBetweenDate:(NSDateComponents *)resultDate withAnimation:(BOOL)animation
{
    _calcType = CALC_TYPE_BETWEEN;
    
    if (_fromLagerThanTo==NO) {
        _resultLabel.isPositive = YES;
    } else {
        _resultLabel.isPositive = NO;
    }

    [self setResultDate:resultDate];
    
    if ( animation && ((_fromLagerThanTo==YES && _resultLabel.arrowDirection!=ArrowDirection_From) ||
                       (_fromLagerThanTo==NO && _resultLabel.arrowDirection!=ArrowDirection_To)) ) {

        [UIView animateWithDuration:0.5
                              delay:0
             usingSpringWithDamping:500.0f
              initialSpringVelocity:0.0f
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             [self adjustFromToBetweenLineWidth];
                             [self setupResultLabelPositionForThumbView:_fromLagerThanTo==NO ? _toThumbView : _fromThumbView];
                             self.resultLabel.arrowDirection = _fromLagerThanTo==NO ? ArrowDirection_To : ArrowDirection_From;
                             [self setupSliderThumbShadeByCalcType];
                         }
                         completion:^(BOOL finished) {
                             _fromLabel.text = [A3DateCalcStateManager formattedStringDate:_fromDate];
                             _toLabel.text = [A3DateCalcStateManager formattedStringDate:_toDate];
                             [self adjustFromToLabelPosition];
                         }];
    } else {
        [self adjustFromToBetweenLineWidth];
        [self adjustFromToLabelPosition];
        [self setupResultLabelPositionForThumbView:_fromLagerThanTo==NO ? _toThumbView : _fromThumbView];
        self.resultLabel.arrowDirection = _fromLagerThanTo==NO ? ArrowDirection_To : ArrowDirection_From;
        [self setupSliderThumbShadeByCalcType];
        _fromLabel.text = [A3DateCalcStateManager formattedStringDate:_fromDate];
        _toLabel.text = [A3DateCalcStateManager formattedStringDate:_toDate];
    }
}

- (void)setResultAddDate:(NSDate *)resultDate withAnimation:(BOOL)animation
{
    _calcType = CALC_TYPE_ADD;
    [_resultLabel setResultText:[A3DateCalcStateManager formattedStringDate:resultDate]];
    
    [A3DateCalcStateManager setCurrentDurationType:[A3DateCalcStateManager addSubDurationType]];
    NSDateComponents *comp = [[A3DateCalcStateManager currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay
                                                                         fromDate:_fromDate
                                                                           toDate:resultDate
                                                                          options:0];
    NSString *rDateString = [NSString stringWithFormat:@"%@", [self getDateStringByDurationTypeForComponent:comp]];
    
    if (animation && _resultLabel.arrowDirection != ArrowDirection_To) {
        _resultLabel.arrowDirection = ArrowDirection_To;

        [UIView animateWithDuration:0.5
                              delay:0
             usingSpringWithDamping:500.0f
              initialSpringVelocity:0.0f
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             [self adjustFromToBetweenLineWidth];
                             [self setupResultLabelPositionForThumbView:_toThumbView];
                             [self setupSliderThumbShadeByCalcType];
                             
                             _fromLabel.text = [A3DateCalcStateManager formattedStringDate:_fromDate];
                             _toLabel.text = rDateString;
                             
                             if (comp.year==0 && comp.month==0 && comp.day==0) {
                                 _fromThumbView.centerColor = COLOR_ELLIPSE_2_Center_GRAY;
                                 _toThumbView.centerColor = COLOR_ELLIPSE_2_Center_GRAY;
                                 _freezeToDragLeftCircle = YES;
                                 _freezeToDragRightCircle = YES;
                             }
                         }
         
                         completion:^(BOOL finished) {
                             [self adjustFromToLabelPosition];
                             
                             if ([_delegate respondsToSelector:@selector(dateCalcHeaderAddSubResult:)]) {
                                 [_delegate dateCalcHeaderAddSubResult:comp];
                             }
                         }];
    } else {
        [self adjustFromToBetweenLineWidth];
        [self adjustFromToLabelPosition];
        [self setupResultLabelPositionForThumbView:_toThumbView];
        [self setupSliderThumbShadeByCalcType];
        
        _fromLabel.text = [A3DateCalcStateManager formattedStringDate:_fromDate];
        _toLabel.text = rDateString;
        
        if (comp.year==0 && comp.month==0 && comp.day==0) {
            _fromThumbView.centerColor = COLOR_ELLIPSE_2_Center_GRAY;
            _toThumbView.centerColor = COLOR_ELLIPSE_2_Center_GRAY;
            _freezeToDragLeftCircle = YES;
            _freezeToDragRightCircle = YES;
        }
        
        if ([_delegate respondsToSelector:@selector(dateCalcHeaderAddSubResult:)]) {
            [_delegate dateCalcHeaderAddSubResult:comp];
        }
    }
    
    _resultLabel.isPositive = YES;
}

- (void)setResultSubDate:(NSDate *)resultDate withAnimation:(BOOL)animation
{
    _calcType = CALC_TYPE_SUB;
    [_resultLabel setResultText:[A3DateCalcStateManager formattedStringDate:resultDate]];
    
    [A3DateCalcStateManager setCurrentDurationType:[A3DateCalcStateManager addSubDurationType]];
    NSDateComponents *comp = [[A3DateCalcStateManager currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay
                                                                         fromDate:_fromDate
                                                                           toDate:resultDate
                                                                          options:0];
    NSString *rDateString = [self getDateStringByDurationTypeForComponent:comp];

    if (animation && _resultLabel.arrowDirection != ArrowDirection_From) {
        _resultLabel.arrowDirection = ArrowDirection_From;

        [UIView animateWithDuration:0.5
                              delay:0
             usingSpringWithDamping:500.0f
              initialSpringVelocity:0.0f
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             [self adjustFromToBetweenLineWidth];
                             [self setupResultLabelPositionForThumbView:_fromThumbView];
                             [self setupSliderThumbShadeByCalcType];
                             
                             // Sub 모드는 from/to 반대
                             _fromLabel.text = rDateString;
                             _toLabel.text = [A3DateCalcStateManager formattedStringDate:_fromDate];
                             [_fromLabel sizeToFit];
                             [_toLabel sizeToFit];
                             
                             if (comp.year==0 && comp.month==0 && comp.day==0) {
                                 _fromThumbView.centerColor = COLOR_ELLIPSE_2_Center_GRAY;
                                 _toThumbView.centerColor = COLOR_ELLIPSE_2_Center_GRAY;
                                 _freezeToDragLeftCircle = YES;
                                 _freezeToDragRightCircle = YES;
                             }
                         }
         
                         completion:^(BOOL finished) {
                             [self adjustFromToLabelPosition];
                             
                             if ([_delegate respondsToSelector:@selector(dateCalcHeaderAddSubResult:)]) {
                                 [_delegate dateCalcHeaderAddSubResult:comp];
                             }
                         }];
    } else {
        [self adjustFromToBetweenLineWidth];
        [self adjustFromToLabelPosition];
        [self setupResultLabelPositionForThumbView:_fromThumbView];
        [self setupSliderThumbShadeByCalcType];

        _fromLabel.text = rDateString;
        _toLabel.text = [A3DateCalcStateManager formattedStringDate:_fromDate];
        [_fromLabel sizeToFit];
        [_toLabel sizeToFit];
        
        if (comp.year==0 && comp.month==0 && comp.day==0) {
            _fromThumbView.centerColor = COLOR_ELLIPSE_2_Center_GRAY;
            _toThumbView.centerColor = COLOR_ELLIPSE_2_Center_GRAY;
            _freezeToDragLeftCircle = YES;
            _freezeToDragRightCircle = YES;
            
            if ([_delegate respondsToSelector:@selector(dateCalcHeaderAddSubResult:)]) {
                [_delegate dateCalcHeaderAddSubResult:comp];
            }
        }
    }

    _resultLabel.isPositive = NO;
}


@end
