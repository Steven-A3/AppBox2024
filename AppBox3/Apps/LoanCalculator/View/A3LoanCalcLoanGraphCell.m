//
//  A3LoanCalcLoanGraphCell.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 12. 8..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3LoanCalcLoanGraphCell.h"
#import "A3TripleCircleView.h"

@implementation A3LoanCalcLoanGraphCell
{
    NSArray *_percentLabels;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self.redLineView addSubview:self.circleView];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    // button font
    UIFont *buttonFont = IS_IPAD ? [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote]:[UIFont systemFontOfSize:12.0];
    _monthlyButton.titleLabel.font = buttonFont;
    _totalButton.titleLabel.font = buttonFont;
    
    // round button
    _monthlyButton.layer.borderWidth = 1;
    _monthlyButton.layer.cornerRadius = _monthlyButton.bounds.size.height/2;
    [_monthlyButton addTarget:self action:@selector(kindButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    _monthlyButton.layer.borderColor = _monthlyButton.currentTitleColor.CGColor;
    
    _totalButton.layer.borderWidth = 1;
    _totalButton.layer.cornerRadius = _totalButton.bounds.size.height/2;
    [_totalButton addTarget:self action:@selector(kindButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    _totalButton.layer.borderColor = [UIColor clearColor].CGColor;
    
    // up label pos
    CGRect upLbFrame = _upLabel.frame;
    upLbFrame.origin.x = IS_IPAD ? 28.0:15.0;
    _upLabel.frame = upLbFrame;
    
    // red color
    UIColor *redColor = [UIColor colorWithRed:255.0/255.0 green:45.0/255.0 blue:85.0/255.0 alpha:1.0];
    self.circleView.centerColor = redColor;
    self.redLineView.backgroundColor = redColor;
    
    // low label, info btn pos
    // downLabel, info X위치 (아이폰 우측에서 50, 아이패드 우측에서 50+13)
    dispatch_async(dispatch_get_main_queue(), ^{
        float fromRightDistance = IS_IPAD ? 63.0:50.0;
        self.lowLabel.layer.anchorPoint = CGPointMake(1.0, 0.5);
        CGPoint center = self.lowLabel.center;
        center.x = self.bounds.size.width - fromRightDistance;
        self.lowLabel.center = center;
        self.lowLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        
        float fromRightDistance2 = IS_IPAD ? 28.0:15.0;
        self.infoButton.layer.anchorPoint = CGPointMake(1.0, 0.5);
        CGPoint center2 = self.infoButton.center;
        center2.x = self.bounds.size.width - fromRightDistance2;
        self.infoButton.center = center2;
        self.infoButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        
    });
    
    if (IS_IPAD) {
        // percent bar
        
        float gapRight = 6;
        NSMutableArray *percentLabelArray = [NSMutableArray new];
        
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
            tmp.layer.anchorPoint = CGPointMake(1, 0);
            [_bgLineView addSubview:tmp];
            tmp.center = CGPointMake(_bgLineView.bounds.size.width/5.0*(i+1), 0);
            tmp.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
            [percentLabelArray addObject:pctLB];
        }
        
        _percentLabels = percentLabelArray;
    }
}

- (A3TripleCircleView *)circleView
{
    if (!_circleView) {
        _circleView = [[A3TripleCircleView alloc] init];
        _circleView.frame = CGRectMake(0, 0, 31, 31);
        _circleView.center = CGPointMake(_redLineView.bounds.size.width, _redLineView.bounds.size.height/2);
        _circleView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        _circleView.centerColor = _redLineView.backgroundColor;
    }
    
    return _circleView;
}

- (void)kindButtonPressed:(UIButton *) button
{
    UIColor *selectedColor = _monthlyButton.currentTitleColor;
    
    if (button == _monthlyButton) {
        _monthlyButton.layer.borderColor = selectedColor.CGColor;
        _totalButton.layer.borderColor = [UIColor clearColor].CGColor;
    }
    else {
        _totalButton.layer.borderColor = selectedColor.CGColor;
        _monthlyButton.layer.borderColor = [UIColor clearColor].CGColor;
    }
}

#pragma mark 

- (void)adjustSubviewsFontSize {
    _monthlyButton.titleLabel.font = IS_IPAD ? [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote] : [UIFont systemFontOfSize:12.0];
    _totalButton.titleLabel.font = IS_IPAD ? [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote] : [UIFont systemFontOfSize:12.0];
    if (_percentLabels) {
        [_percentLabels enumerateObjectsUsingBlock:^(UILabel *percentLabel, NSUInteger idx, BOOL *stop) {
            percentLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
        }];
    }
}

@end
