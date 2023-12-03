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
#import "A3AppDelegate.h"
#import "UIViewController+tableViewStandardDimension.h"
#import "A3UIDevice.h"

#define SLIDER_OFFSET_LABEL     20
#define SLIDER_THUMB_MARGIN     20

#define COLOR_ELLIPSE_0                 [UIColor colorWithRed:229.0/255.0 green:229.0/255.0 blue:229.0/255.0 alpha:1.0]
#define COLOR_ELLIPSE_1                 [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0]
#define COLOR_ELLIPSE_1_BORDER          [UIColor colorWithRed:188.0/255.0 green:188.0/255.0 blue:188.0/255.0 alpha:1.0]
#define COLOR_ELLIPSE_2_Center          [UIColor colorWithRed:0/255.0 green:122/255.0 blue:255/255.0 alpha:1.0]
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

@property (strong, nonatomic) UIView *sliderLineView;    // 슬라이더 베이스 라인
@property (strong, nonatomic) A3DateCalcResultCursorView *resultLabel;   // 슬라이더 커서 상단 결과 출력
@property (strong, nonatomic) UILabel *resultTextLabel;
@property (strong, nonatomic) UILabel *fromLabel;    // 슬라이더 커서 하단 날짜 출력
@property (strong, nonatomic) UILabel *toLabel;      // 슬라이더 커서 하단 날짜 출력

@property (strong, nonatomic) A3OverlappedCircleView * fromThumbView;
@property (strong, nonatomic) A3OverlappedCircleView * toThumbView;

@property (strong, nonatomic) UIView *fromToRangeLineView;   // 슬라이더 커서 간격 표시 라인
@property (strong, nonatomic) UIView *bottomLineView;
@property (assign, nonatomic) CGFloat availableWidth;
@end

@implementation A3DateCalcHeaderView
{
    //UILabel *test;
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
        [self initializeSubViews];
        [self setupGestureRecognizer];
    }
    return self;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    [self initializeSubViews];
}

#pragma mark - Initialization

- (void)initializeSubViews
{
    _minValue = 0;
    _maxValue = 100;
    
    SLIDER_OFFSET = IS_RETINA ? 22.5 : 23;
    
    self.sliderLineView = [[UIView alloc] initWithFrame:CGRectZero];
    self.fromToRangeLineView = [[UIView alloc] initWithFrame:CGRectZero];
    self.bottomLineView = [[UIView alloc] initWithFrame:CGRectZero];
    self.fromThumbView = [[A3OverlappedCircleView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];;
    self.toThumbView = [[A3OverlappedCircleView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];;
    self.resultLabel = [[A3DateCalcResultCursorView alloc] initWithFrame:CGRectZero];
    self.fromLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.toLabel = [[UILabel alloc] initWithFrame:CGRectZero];

    if (IS_IPHONE) {
        CGFloat baseLineCenterY = 59.0;
        CGFloat lineHeight = IS_RETINA ? 0.5 : 1.0;
        self.sliderLineView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), lineHeight);
        self.fromToRangeLineView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), lineHeight);
        self.bottomLineView.frame = CGRectMake(0, CGRectGetHeight(self.frame) - lineHeight, CGRectGetWidth(self.frame), lineHeight);

        self.sliderLineView.center = CGPointMake(_sliderLineView.center.x, baseLineCenterY);
        self.fromToRangeLineView.center = CGPointMake(_fromToRangeLineView.center.x, baseLineCenterY);
        self.fromThumbView.center = CGPointMake(_fromThumbView.center.x, baseLineCenterY);
        self.toThumbView.center = CGPointMake(_toThumbView.center.x, baseLineCenterY);
    }
    else {
        CGFloat baseLineCenterY = 78.0;
        CGFloat lineHeight = IS_RETINA ? 0.5 : 1.0;
        self.sliderLineView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), lineHeight);
        self.fromToRangeLineView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), lineHeight);
        self.bottomLineView.frame = CGRectMake(0, CGRectGetHeight(self.frame) - lineHeight, CGRectGetWidth(self.frame), lineHeight);
        
        self.sliderLineView.center = CGPointMake(_sliderLineView.center.x, baseLineCenterY);
        self.fromToRangeLineView.center = CGPointMake(_fromToRangeLineView.center.x, baseLineCenterY);
        self.fromThumbView.center = CGPointMake(_fromThumbView.center.x, baseLineCenterY);
        self.toThumbView.center = CGPointMake(_toThumbView.center.x, baseLineCenterY);
    }
    
    self.sliderLineView.backgroundColor = [UIColor colorWithRed:188/255.0 green:188/255.0 blue:188/255.0 alpha:1.0];
    self.fromToRangeLineView.backgroundColor = COLOR_ELLIPSE_2_Center;
    self.bottomLineView.backgroundColor = A3UITableViewSeparatorColor;
    self.fromThumbView.centerColor = COLOR_ELLIPSE_2_Center;
    self.toThumbView.centerColor = COLOR_ELLIPSE_2_Center;
    self.backgroundColor = COLOR_HEADERVIEW_BG;
    self.sliderLineView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleRightMargin;
    self.fromToRangeLineView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleRightMargin;
    self.bottomLineView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleRightMargin;
    
    [self addSubview:_sliderLineView];
    [self addSubview:_fromToRangeLineView];
    [self addSubview:_bottomLineView];
    [self addSubview:_fromThumbView];
    [self addSubview:_toThumbView];
    [self addSubview:_fromLabel];
    [self addSubview:_toLabel];

    _resultLabel = [[A3DateCalcResultCursorView alloc] initWithFrame:CGRectZero ArrowDirection:ArrowDirection_From];
    _resultLabel.center = _sliderLineView.center;
    [self addSubview:_resultLabel];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    [self adjustFromToBetweenLineWidth];
    [self adjustFromToLabelPosition];
    [self adjustSubviewsFont];
    
    if (_calcType == CALC_TYPE_SUB) {
        [self setupResultLabelPositionForThumbView:_fromThumbView];
    } else {
        [self setupResultLabelPositionForThumbView:nil];
    }
}

- (void)setupGestureRecognizer
{
    UITapGestureRecognizer *fromTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(fromThumbTapGesture:)];
    UITapGestureRecognizer *fromTap2 = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(fromThumbTapGesture:)];
    [_fromThumbView addGestureRecognizer:fromTap];
    [_fromLabel addGestureRecognizer:fromTap2];
    _fromLabel.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *toTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                            action:@selector(toThumbTapGesture:)];
    [_toThumbView addGestureRecognizer:toTap];
    UITapGestureRecognizer *toTap2 = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                            action:@selector(toThumbTapGesture:)];
    [_toLabel addGestureRecognizer:toTap2];
    _toLabel.userInteractionEnabled = YES;
}

#pragma mark View Control, Result

- (void)adjustSubviewsFont
{
    [_resultLabel setNeedsLayout];
    if (IS_IPAD) {
        self.fromLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        self.toLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        self.resultLabel.contentLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    }
    else {
        self.fromLabel.font = [UIFont systemFontOfSize:13];
        self.toLabel.font = [UIFont systemFontOfSize:13];
        self.resultLabel.contentLabel.font = [UIFont boldSystemFontOfSize:17];
    }

    [self.fromLabel sizeToFit];
    [self.toLabel sizeToFit];
}

- (void)adjustFromToBetweenLineWidth
{
    CGRect fRect = _fromThumbView.frame;
    CGRect tRect = _toThumbView.frame;
    CGRect rect = _fromToRangeLineView.frame;
    CGFloat fXpos = _fromValue + CGRectGetWidth(fRect)/8;
    CGFloat tXpos = _toValue - CGRectGetWidth(tRect)/8;

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
        labelRect.origin.x = roundf( self.bounds.origin.x + SLIDER_OFFSET_LABEL );
    } else if ((labelRect.origin.x + labelRect.size.width + SLIDER_OFFSET_LABEL) > _toLabel.frame.origin.x) {
        labelRect.origin.x = roundf( _toLabel.frame.origin.x - labelRect.size.width - SLIDER_OFFSET_LABEL );
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
    if (IS_IPHONE) {
        labelRect.size.width = roundf( fontRect.size.width );
    }
    
    if (IS_IPHONE) {
        labelRect.origin.y = _sliderLineView.center.y + 9.0;
    } else {
        labelRect.origin.y = _sliderLineView.center.y + 23.0;
    }
    
    if ((labelRect.origin.x+labelRect.size.width) > (CGRectGetWidth(self.bounds) - SLIDER_OFFSET_LABEL)) {
        labelRect.origin.x = roundf( CGRectGetWidth(self.bounds) - (labelRect.size.width + SLIDER_OFFSET_LABEL) );
    } else if (labelRect.origin.x < (_fromLabel.frame.origin.x + _fromLabel.frame.size.width + SLIDER_OFFSET_LABEL)) {
        labelRect.origin.x = roundf( _fromLabel.frame.origin.x + _fromLabel.frame.size.width + SLIDER_OFFSET_LABEL );
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
        
        rRect.origin.x = ceilf(_fromThumbView.center.x + CGRectGetWidth(fRect)/2);
        rRect.origin.y = IS_IPHONE ? ceilf(_sliderLineView.center.y - 15.5 - CGRectGetHeight(_resultLabel.frame)) : ceilf(_sliderLineView.center.y - 16.0 - CGRectGetHeight(_resultLabel.frame));
        rRect.size.width = ceilf(_resultLabel.sizeOfResultText.width) + 38;
        rRect.size.height = 25;
        
        if (rRect.origin.x + rRect.size.width > CGRectGetWidth(self.bounds)) {
            rRect.origin.x = ceilf(CGRectGetWidth(self.bounds) - rRect.size.width);
        }
        _resultLabel.frame = rRect;
    }
    else {
        CGRect rRect = _resultLabel.frame;
        CGRect tRect = _toThumbView.frame;
        
        rRect.origin.x = ceilf(_toThumbView.center.x - CGRectGetWidth(tRect)/2 - _resultLabel.sizeOfResultText.width - 35);
        rRect.origin.y = IS_IPHONE ? ceilf(_sliderLineView.center.y - 15.5 - CGRectGetHeight(_resultLabel.frame)) : ceilf(_sliderLineView.center.y - 16.0 - CGRectGetHeight(_resultLabel.frame));
        rRect.size.width = ceilf(_resultLabel.sizeOfResultText.width) + 38;
        rRect.size.height = 25;
        
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
            _fromThumbView.centerColor = COLOR_ELLIPSE_2_Center_GRAY;//COLOR_ELLIPSE_2_Center;
            _toThumbView.centerColor = COLOR_ELLIPSE_2_Center_GRAY;
            _freezeToDragLeftCircle = NO;
            _freezeToDragRightCircle = YES;
        }
        else {
            if ([_fromDate isEqualToDate:_toDate]) {
                // From 날짜 To 날짜 같은 경우.
                _fromThumbView.centerColor = COLOR_ELLIPSE_2_Center_GRAY;
                _freezeToDragLeftCircle = YES;
                _toThumbView.hidden = YES;
                _toLabel.hidden = YES;
                _fromToRangeLineView.hidden = YES;
            }
            else {
                // From 날짜가 To 날짜보다 작은 경우.
                _fromThumbView.centerColor = COLOR_ELLIPSE_2_Center_GRAY;
                _toThumbView.centerColor = COLOR_ELLIPSE_2_Center_GRAY;//COLOR_ELLIPSE_2_Center;
                _freezeToDragLeftCircle = YES;
                _freezeToDragRightCircle = NO;
            }
        }
        
    } else if (_calcType == CALC_TYPE_ADD) {
        _fromThumbView.centerColor = COLOR_ELLIPSE_2_Center_GRAY;
        _toThumbView.centerColor = COLOR_ELLIPSE_2_Center_GRAY;//COLOR_ELLIPSE_2_Center;
        _freezeToDragLeftCircle = YES;
        _freezeToDragRightCircle = NO;
        
    } else if (_calcType == CALC_TYPE_SUB) {
        _fromThumbView.centerColor = COLOR_ELLIPSE_2_Center_GRAY;//COLOR_ELLIPSE_2_Center;
        _toThumbView.centerColor = COLOR_ELLIPSE_2_Center_GRAY;
        _freezeToDragLeftCircle = NO;
        _freezeToDragRightCircle = YES;
    }
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
        }
        else if (_calcType == CALC_TYPE_ADD) {
            [self setupResultLabelPositionForThumbView:_toThumbView];
            self.resultLabel.arrowDirection = ArrowDirection_To;
        }
        else {
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
        }
        else {
            [self setupResultLabelPositionForThumbView:_toThumbView];
        }
        [self calculateBetweenFromAndTo];
    }
}

- (void)fromThumbTapGesture:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        // handling code
        if ([_delegate respondsToSelector:@selector(dateCalcHeaderFromThumbTapped)]) {
            [_delegate dateCalcHeaderFromThumbTapped];
        }
    }
}

- (void)toThumbTapGesture:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        // handling code
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
        if (IS_IPAD && [UIWindow interfaceOrientationIsLandscape]) {
            _toValue = 1024.0 - SLIDER_OFFSET;
        }
        else {
            _toValue = CGRectGetWidth(_sliderLineView.frame) - SLIDER_OFFSET;
        }
        _toLabel.textColor = [UIColor blackColor];
    } else {
        _toLabel.textColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
    }
    
    if (_toValue < (_fromThumbView.center.x + SLIDER_THUMB_MARGIN)) {
        _toValue = (_fromThumbView.center.x + SLIDER_THUMB_MARGIN);
    }
    
    CGPoint point = _toThumbView.center;
    point.x = _toValue;
    
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
    switch (_calcType) {
        case CALC_TYPE_BETWEEN:
        {
            if ([fromDate compare:toDate] == NSOrderedAscending || [fromDate compare:toDate] == NSOrderedSame) {
                _fromLagerThanTo = NO;
                [self setFromDate:fromDate];
                [self setToDate:toDate];
            } else {
                _fromLagerThanTo = YES;
                [self setFromDate:toDate];
                [self setToDate:fromDate];
            }
        }
            break;
            
        case CALC_TYPE_ADD:
        case CALC_TYPE_SUB:
        {
            _fromLagerThanTo = NO;
            [self setFromDate:fromDate];
            [self setToDate:toDate];
        }
            break;
        default:
            break;
    }
}

- (void)setFromDate:(NSDate *)fromDate
{
    _fromDate = [fromDate copy];
    _minValue = 0.0;
    _minDate = _fromDate;
    
    self.fromLabel.text = IS_IPAD ? [A3DateCalcStateManager fullStyleDateStringFromDate:_fromDate] : [A3DateCalcStateManager fullCustomStyleDateStringFromDate:_fromDate];
    [_fromLabel sizeToFit];
    
    self.fromValue = 0.0;
}

- (void)setToDate:(NSDate *)toDate
{
    _toDate = [toDate copy];
    _maxValue = CGRectGetWidth(self.sliderLineView.frame);
    _maxDate = toDate;

    self.toLabel.text = IS_IPAD ? [A3DateCalcStateManager fullStyleDateStringFromDate:_toDate] : [A3DateCalcStateManager fullCustomStyleDateStringFromDate:_toDate];
    [_toLabel sizeToFit];
    if (IS_IPAD && [UIWindow interfaceOrientationIsLandscape]) {
        self.toValue = 1024.0;
    }
    else {
        self.toValue = CGRectGetWidth(self.sliderLineView.frame);
    }
}

// Between two Days 출력 부분.
- (void)setResultDate:(NSDateComponents *)resultDate
{
    if (_calcType == CALC_TYPE_BETWEEN) {
        // DurationType durationType = [A3DateCalcStateManager durationType];
        DurationType durationType = [A3DateCalcStateManager currentDurationType];
        NSMutableArray *result = [[NSMutableArray alloc] init];
        
        resultDate.year = labs(resultDate.year);
        resultDate.month = labs(resultDate.month);
        resultDate.day = labs(resultDate.day);
        resultDate.weekOfYear = labs(resultDate.weekOfYear);

        switch (durationType) {
            case DurationType_Year:
                [result addObject:[NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld years", @"StringsDict", nil), (long) resultDate.year]];
                break;
            case DurationType_Month:
                [result addObject:[NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld months", @"StringsDict", nil), (long) resultDate.month]];
                break;
            case DurationType_Week:
                [result addObject:[NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld weeks", @"StringsDict", nil), (long)resultDate.weekOfYear]];
                break;
            case DurationType_Day:
                [result addObject:[NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld days", @"StringsDict", nil), (long) resultDate.day]];
                break;
                
            default:
            {
                if (durationType & DurationType_Year) {
                    if (resultDate.year != 0) {
                        [result addObject:[NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld years", @"StringsDict", nil), (long) resultDate.year]];
                    }
                }
                if (durationType & DurationType_Month) {
                    if (resultDate.month != 0) {
                        [result addObject:[NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld months", @"StringsDict", nil), (long) resultDate.month]];
                    }
                }
                if (durationType & DurationType_Week) {
                    if (resultDate.weekOfYear != 0) {
                        [result addObject:[NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld weeks", @"StringsDict", nil), (long)resultDate.weekOfYear]];
                    }
                }
                if (durationType & DurationType_Day) {
                    if (resultDate.day != 0) {
                        [result addObject:[NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld days", @"StringsDict", nil), (long) resultDate.day]];
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
        FNLOG(@"_calcType == CALC_TYPE_ADD 결과출력.");
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
            [result addObject:[NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld years", @"StringsDict", nil), labs((long)resultDate.year)]];
            break;
        case DurationType_Month:
            [result addObject:[NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld months", @"StringsDict", nil), labs((long)resultDate.month)]];
            break;
        case DurationType_Week:
            [result addObject:[NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld weeks", @"StringsDict", nil), labs((long)resultDate.weekOfYear)]];
            break;
        case DurationType_Day:
            [result addObject:[NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld days", @"StringsDict", nil), labs((long)resultDate.day)]];
            break;
            
        default:
        {
            NSInteger durationFlagCount = 0;

            if (IS_IPHONE) {
                if (durationType & DurationType_Year) {
                    durationFlagCount++;
                }
                if (durationType & DurationType_Month) {
                    durationFlagCount++;
                }
                if (durationType & DurationType_Week) {
                    durationFlagCount++;
                }
                if (durationType & DurationType_Day) {
                    durationFlagCount++;
                }
            }

            if (durationType & DurationType_Year) {
                if (resultDate.year != 0) {
                    if (durationFlagCount >= 3) {
                        [result addObject:[NSString stringWithFormat:NSLocalizedString(@"%ldy", @"%ldy"), labs((long) resultDate.year)]];
                    }
                    else {
                        [result addObject:[NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld years", @"StringsDict", nil), labs((long)resultDate.year)]];
                    }
                }
            }
            if (durationType & DurationType_Month) {
                if (resultDate.month != 0) {
                    if (durationFlagCount >= 3) {
                        [result addObject:[NSString stringWithFormat:NSLocalizedString(@"%ldm", @"%ldm"), labs((long) resultDate.month)]];
                    }
                    else {
                        [result addObject:[NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld months", @"StringsDict", nil), labs((long)resultDate.month)]];
                    }
                }
            }
            if (durationType & DurationType_Week) {
                if (resultDate.weekOfYear != 0) {
                    if (durationFlagCount >= 3) {
                        [result addObject:[NSString stringWithFormat:NSLocalizedString(@"%ldw", @"%ldw"), labs((long) resultDate.weekOfYear)]];
                    }
                    else {
                        [result addObject:[NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld weeks", @"StringsDict", nil), labs((long) resultDate.weekOfYear)]];
                    }
                }
            }
            if (durationType & DurationType_Day) {
                if (resultDate.day != 0) {
                    if (durationFlagCount >= 3) {
                        [result addObject:[NSString stringWithFormat:NSLocalizedString(@"%ldd", @"%ldd"), labs((long) resultDate.day)]];
                    }
                    else {
                        [result addObject:[NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld days", @"StringsDict", nil), labs((long)resultDate.day)]];
                    }
                }
            }
            
            if (result.count == 0) {
				[result addObject:[NSString stringWithFormat:NSLocalizedString(@"0 day", @"0 day")]];
//                if (_calcType == CALC_TYPE_SUB) {
//                    [result addObject:[NSString stringWithFormat:@"0day"]];
//                } else {
//                    [result addObject:[NSString stringWithFormat:@"0day"]];
//                }
            }
        }
            break;
		case DurationType_None:break;
	}
    
    return [result componentsJoinedByString:@" "];
}

#pragma mark - Date Calc Related
- (void)calculateBetweenFromAndTo
{
    NSInteger minDayCount = 0;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *result = [calendar components:NSCalendarUnitDay fromDate:_minDate toDate:_maxDate options:0];
    NSInteger maxDayCount = result.day;
    
    CGFloat offsetFrom = minDayCount + ((_fromValue-SLIDER_OFFSET) / (_maxValue-SLIDER_OFFSET)) * maxDayCount;
    CGFloat offsetTo = minDayCount + (_toValue / (_maxValue-SLIDER_OFFSET)) * maxDayCount;
    NSDateComponents *fComp = [NSDateComponents new];
    NSDateComponents *tComp = [NSDateComponents new];
    if (_calcType == CALC_TYPE_SUB) {
        fComp.day = maxDayCount + fabs(offsetFrom);
    }
    else {
        fComp.day = offsetFrom;
    }

    tComp.day = offsetTo;
    
    NSDate *fDate = [[A3DateCalcStateManager currentCalendar] dateByAddingComponents:fComp toDate:_minDate options:0];
    NSDate *tDate = [[A3DateCalcStateManager currentCalendar] dateByAddingComponents:tComp toDate:_minDate options:0];
    
    if (_calcType == CALC_TYPE_BETWEEN) {
        NSDateComponents *resultComp = [A3DateCalcStateManager dateComponentFromDate:fDate toDate:tDate];
        _fromDate = fDate;
        _toDate = tDate;

        [self setResultBetweenDate:resultComp withAnimation:YES];

        _fromLabel.text = IS_IPAD ? [A3DateCalcStateManager fullStyleDateStringFromDate:fDate] : [A3DateCalcStateManager fullCustomStyleDateStringFromDate:fDate];
        _toLabel.text = IS_IPAD ? [A3DateCalcStateManager fullStyleDateStringFromDate:tDate] : [A3DateCalcStateManager fullCustomStyleDateStringFromDate:tDate];
        
        if ([_delegate respondsToSelector:@selector(dateCalcHeaderChangedFromDate:toDate:)]) {
            [_delegate dateCalcHeaderChangedFromDate:fDate toDate:tDate];
        }
    }
    else if (_calcType == CALC_TYPE_ADD) {
        NSDateComponents *changedComp = [self setResultAddDate:tDate withAnimation:YES];
        if ([_delegate respondsToSelector:@selector(dateCalcHeaderThumbPositionChangeOfAddSubDateComponents:)]) {
            [_delegate dateCalcHeaderThumbPositionChangeOfAddSubDateComponents:changedComp];
        }
    }
    else if (_calcType == CALC_TYPE_SUB) {
        NSDateComponents *changedComp = [self setResultSubDate:fDate withAnimation:YES];
        if ([_delegate respondsToSelector:@selector(dateCalcHeaderThumbPositionChangeOfAddSubDateComponents:)]) {
            [_delegate dateCalcHeaderThumbPositionChangeOfAddSubDateComponents:changedComp];
        }
    }
}

- (NSDateComponents *)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime
{
    if (fromDateTime == nil || toDateTime == nil) {
        return 0;
    }
    
    NSDate *fromDate;
    NSDate *toDate;
    NSCalendar *calendar = [[A3AppDelegate instance] calendar];
    
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate
                 interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate
                 interval:NULL forDate:toDateTime];
    
    DurationType durationType = [A3DateCalcStateManager durationType];
    NSCalendarUnit calUnit;
    
    if (durationType == DurationType_Month) {
        calUnit = NSCalendarUnitMonth |NSCalendarUnitDay;
    }
    else if (durationType == DurationType_Week) {
        calUnit = NSCalendarUnitWeekday;
    }
    else if (durationType == DurationType_Day) {
        calUnit =NSCalendarUnitDay;
    }
    else {
        calUnit = NSCalendarUnitYear | NSCalendarUnitMonth |NSCalendarUnitDay;
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
    }
    else {
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
                             _fromLabel.text = IS_IPAD ? [A3DateCalcStateManager fullStyleDateStringFromDate:_fromDate] : [A3DateCalcStateManager fullCustomStyleDateStringFromDate:_fromDate];
                             _toLabel.text = IS_IPAD ? [A3DateCalcStateManager fullStyleDateStringFromDate:_toDate] : [A3DateCalcStateManager fullCustomStyleDateStringFromDate:_toDate];
                             [self adjustFromToLabelPosition];
                         }];
    }
    else {
        _fromLabel.text = IS_IPAD ? [A3DateCalcStateManager fullStyleDateStringFromDate:_fromDate] : [A3DateCalcStateManager fullCustomStyleDateStringFromDate:_fromDate];
        _toLabel.text = IS_IPAD ? [A3DateCalcStateManager fullStyleDateStringFromDate:_toDate] : [A3DateCalcStateManager fullCustomStyleDateStringFromDate:_toDate];
        
        [self adjustFromToBetweenLineWidth];
        [self adjustFromToLabelPosition];
        [self setupResultLabelPositionForThumbView:_fromLagerThanTo==NO ? _toThumbView : _fromThumbView];
        self.resultLabel.arrowDirection = _fromLagerThanTo==NO ? ArrowDirection_To : ArrowDirection_From;
        [self setupSliderThumbShadeByCalcType];
    }
}

- (NSDateComponents *)setResultAddDate:(NSDate *)resultDate withAnimation:(BOOL)animation
{
    _calcType = CALC_TYPE_ADD;
    [_resultLabel setResultText:IS_IPAD ? [A3DateCalcStateManager fullStyleDateStringFromDate:resultDate] : [A3DateCalcStateManager fullCustomStyleDateStringFromDate:resultDate]];
    
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
                             
                             _fromLabel.text = IS_IPAD ? [A3DateCalcStateManager fullStyleDateStringFromDate:_fromDate] : [A3DateCalcStateManager fullCustomStyleDateStringFromDate:_fromDate];
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
    }
    else {
        [self adjustFromToBetweenLineWidth];
        [self adjustFromToLabelPosition];
        [self setupResultLabelPositionForThumbView:_toThumbView];
        [self setupSliderThumbShadeByCalcType];
        
        _fromLabel.text = IS_IPAD ? [A3DateCalcStateManager fullStyleDateStringFromDate:_fromDate] : [A3DateCalcStateManager fullCustomStyleDateStringFromDate:_fromDate];
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
    return comp;
}

- (NSDateComponents *)setResultSubDate:(NSDate *)resultDate withAnimation:(BOOL)animation
{
    _calcType = CALC_TYPE_SUB;
    [_resultLabel setResultText:IS_IPAD ? [A3DateCalcStateManager fullStyleDateStringFromDate:resultDate] : [A3DateCalcStateManager fullCustomStyleDateStringFromDate:resultDate]];
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
                             _toLabel.text = IS_IPAD ? [A3DateCalcStateManager fullStyleDateStringFromDate:_fromDate] : [A3DateCalcStateManager fullCustomStyleDateStringFromDate:_fromDate];
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
    }
    else {
        [self adjustFromToBetweenLineWidth];
        [self adjustFromToLabelPosition];
        [self setupResultLabelPositionForThumbView:_fromThumbView];
        [self setupSliderThumbShadeByCalcType];

        _fromLabel.text = rDateString;
        _toLabel.text = IS_IPAD ? [A3DateCalcStateManager fullStyleDateStringFromDate:_fromDate] : [A3DateCalcStateManager fullCustomStyleDateStringFromDate:_fromDate];
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
    return comp;
}


@end
