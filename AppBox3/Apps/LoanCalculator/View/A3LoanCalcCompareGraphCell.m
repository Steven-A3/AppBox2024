//
//  A3LoanCalcCompareGraphCell.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 12. 11..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3LoanCalcCompareGraphCell.h"

@implementation A3LoanCalcCompareGraphCell
{
    NSArray *_percentALabels;
    NSArray *_percentBLabels;
    NSArray *_percentA_meterViews;
    NSArray *_percentB_meterViews;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self adjustMeterViewsPosition];
//    [self adjustABMarkPosition];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self.red_A_Line addSubview:self.circleA_View];
	
    [self.red_B_Line addSubview:self.circleB_View];
	
    _markA_Label.layer.cornerRadius = _markA_Label.bounds.size.height/2;
    _markB_Label.layer.cornerRadius = _markB_Label.bounds.size.height/2;
    
    UIColor *redColor = [UIColor colorWithRed:255.0/255.0 green:45.0/255.0 blue:85.0/255.0 alpha:1.0];
    _red_A_Line.backgroundColor = redColor;
    _red_B_Line.backgroundColor = redColor;
    _circleA_View.centerColor = redColor;
    _circleB_View.centerColor = redColor;
    
    // left, right number label
    UIFont *font1 = IS_IPAD ? [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline]:[UIFont systemFontOfSize:15.0];
    UIColor *color1 = [UIColor blackColor];
    UIFont *font2 = IS_IPAD ? [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]:[UIFont boldSystemFontOfSize:17.0];
    UIColor *color2 = [UIColor blackColor];
    
    _left_A_Label.font = font1;
    _left_B_Label.font = font1;
    _left_A_Label.textColor = color1;
    _left_B_Label.textColor = color1;
    
    _right_A_Label.font = font2;
    _right_B_Label.font = font2;
    _right_A_Label.textColor = color2;
    _right_B_Label.textColor = color2;
    
    // total interest, amount text label
    UIFont *font3 = IS_IPAD ? [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote]:[UIFont systemFontOfSize:13.0];
    UIColor *color3 = [UIColor colorWithRed:123.0/255.0 green:123.0/255.0 blue:123.0/255.0 alpha:1.0];
    UIFont *font4 = IS_IPAD ? [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline]:[UIFont systemFontOfSize:17.0];
    UIColor *color4 = [UIColor blackColor];
    
    _totalInterestLB.font = font3;
    _totalInterestLB.textColor = color3;
    _totalAmountLB.font = font4;
    _totalAmountLB.textColor = color4;
    
    
    if (IS_IPAD) {
        // percent bar
        float gapRight = 6;
        
        NSMutableArray *percentLabelArray = [NSMutableArray new];
        NSMutableArray *percent_MeterView = [NSMutableArray new];
        
        for (int i=0; i<5; i++) {
            UIView *tmp = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 23)];
            if (i<4) {
                UIView *line = [[UIView alloc] initWithFrame:CGRectMake(49, 0, IS_RETINA ? 0.5:1.0, 18+5)];
                line.backgroundColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0];
                [tmp addSubview:line];
            }
            UILabel *pctLB = [[UILabel alloc] initWithFrame:CGRectMake(0, 2, 50-gapRight, 23)];
            pctLB.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
            pctLB.textColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0];
            pctLB.textAlignment = NSTextAlignmentRight;
            pctLB.text = [NSString stringWithFormat:@"%d%%", (i+1)*20];
            [tmp addSubview:pctLB];
            [_bg_A_Line addSubview:tmp];
            CGRect frame = tmp.frame;
            frame.origin.x = ceilf(_bg_A_Line.bounds.size.width / 5.0 * (i + 1)) - 50.0;
            tmp.frame = frame;
            
            [percentLabelArray addObject:pctLB];
            [percent_MeterView addObject:tmp];
        }
        _percentALabels = percentLabelArray;
        _percentA_meterViews = percent_MeterView;


        percentLabelArray = [NSMutableArray new];
        percent_MeterView = [NSMutableArray new];
        
        for (int i=0; i<5; i++) {
            UIView *tmp = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 23)];
            tmp.backgroundColor = [UIColor clearColor];
            if (i<4) {
                UIView *line = [[UIView alloc] initWithFrame:CGRectMake(49, 0, IS_RETINA ? 0.5:1.0, 18+5)];
                line.backgroundColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0];
                [tmp addSubview:line];
            }
            UILabel *pctLB = [[UILabel alloc] initWithFrame:CGRectMake(0, 2, 50-gapRight, 23)];
            pctLB.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
            pctLB.textColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0];
            pctLB.textAlignment = NSTextAlignmentRight;
            pctLB.text = [NSString stringWithFormat:@"%d%%", (i+1)*20];
            [tmp addSubview:pctLB];
            [_bg_B_Line addSubview:tmp];
            CGRect frame = tmp.frame;
            frame.origin.x = ceilf(_bg_B_Line.bounds.size.width / 5.0 * (i + 1)) - 50.0;
            tmp.frame = frame;
            
            [percentLabelArray addObject:pctLB];
            [percent_MeterView addObject:tmp];
        }
        _percentBLabels = percentLabelArray;
        _percentB_meterViews = percent_MeterView;
    }
}

- (A3TripleCircleView *)circleA_View
{
    if (!_circleA_View) {
        _circleA_View = [[A3TripleCircleView alloc] init];
        _circleA_View.frame = CGRectMake(0, 0, 31, 31);
        _circleA_View.center = CGPointMake(_red_A_Line.bounds.size.width, _red_A_Line.bounds.size.height/2);
        _circleA_View.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        _circleA_View.centerColor = _red_A_Line.backgroundColor;
    }
    
    return _circleA_View;
}

- (A3TripleCircleView *)circleB_View
{
    if (!_circleB_View) {
        _circleB_View = [[A3TripleCircleView alloc] init];
        _circleB_View.frame = CGRectMake(0, 0, 31, 31);
        _circleB_View.center = CGPointMake(_red_B_Line.bounds.size.width, _red_B_Line.bounds.size.height/2);
        _circleB_View.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        _circleB_View.centerColor = _red_B_Line.backgroundColor;
    }
    
    return _circleB_View;
}

#pragma mark 

- (void)adjustSubviewsFontSize {
    _left_A_Label.font = IS_IPAD ? [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline]:[UIFont systemFontOfSize:15.0];
    _left_B_Label.font = IS_IPAD ? [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline]:[UIFont systemFontOfSize:15.0];
    _right_A_Label.font = IS_IPAD ? [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]:[UIFont boldSystemFontOfSize:17.0];
    _right_B_Label.font = IS_IPAD ? [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]:[UIFont boldSystemFontOfSize:17.0];
    _totalInterestLB.font = IS_IPAD ? [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote]:[UIFont systemFontOfSize:13.0];
    _totalAmountLB.font = IS_IPAD ? [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote]:[UIFont systemFontOfSize:13.0];
    
    if (_percentALabels) {
        [_percentALabels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger idx, BOOL *stop) {
            label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
        }];
    }
    
    if (_percentBLabels) {
        [_percentBLabels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger idx, BOOL *stop) {
            label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
        }];
    }
}

- (void)adjustMeterViewsPosition
{
    [_percentA_meterViews enumerateObjectsUsingBlock:^(UIView *meterView, NSUInteger idx, BOOL *stop) {
       CGRect frame = meterView.frame;
       frame.origin.x = ceilf(CGRectGetWidth(self.bounds) / 5.0 * (idx + 1)) - 50.0;
        meterView.frame = frame;
    }];
    
    [_percentB_meterViews enumerateObjectsUsingBlock:^(UIView *meterView, NSUInteger idx, BOOL *stop) {
        CGRect frame = meterView.frame;
        frame.origin.x = ceilf(CGRectGetWidth(self.bounds) / 5.0 * (idx + 1)) - 50.0;
        meterView.frame = frame;
    }];
}

- (void)adjustABMarkPosition
{
    CGPoint point = [self.markA_Label center];
    point.x = CGRectGetWidth(self.bounds) - (CGRectGetWidth(self.markA_Label.frame) / 2);
    self.markA_Label.center = point;
    point = [self.markB_Label center];
    point.x = CGRectGetWidth(self.bounds) - (CGRectGetWidth(self.markB_Label.frame) / 2);
    self.markB_Label.center = point;
}

- (void)adjustABMarkPositionForTotalAmountA:(NSNumber *)totalAmountA totalAmountB:(NSNumber *)totalAmountB
{
    CGFloat maxMarkPositionValue = CGRectGetWidth(self.bounds) - CGRectGetWidth(self.markA_Label.frame);
    CGFloat lowerMarkPositionValue = maxMarkPositionValue * (MIN([totalAmountA doubleValue], [totalAmountB doubleValue]) / MAX([totalAmountA doubleValue], [totalAmountB doubleValue]));
    
    if ([totalAmountA isEqualToNumber:@0] || [totalAmountB isEqualToNumber:@0]) {
        self.markA_Label.center = CGPointMake(maxMarkPositionValue, self.markA_Label.center.y);
        self.markB_Label.center = CGPointMake(maxMarkPositionValue, self.markB_Label.center.y);
        return;
    }
    
    self.markA_Label.center = CGPointMake([totalAmountA doubleValue] > [totalAmountB doubleValue] ? maxMarkPositionValue : lowerMarkPositionValue, self.markA_Label.center.y);
    self.markB_Label.center = CGPointMake([totalAmountB doubleValue] > [totalAmountA doubleValue] ? maxMarkPositionValue : lowerMarkPositionValue, self.markB_Label.center.y);
}

@end
