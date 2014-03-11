//
//  A3LoanCalcGraphView.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 12. 8..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3LoanCalcGraphView.h"

@implementation A3LoanCalcGraphView

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
    
    _monthlyButton.layer.borderWidth = 1;
    _monthlyButton.layer.cornerRadius = _monthlyButton.bounds.size.height/2;
    [_monthlyButton addTarget:self action:@selector(kindButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    _monthlyButton.layer.borderColor = _monthlyButton.currentTitleColor.CGColor;
    
    _totalButton.layer.borderWidth = 1;
    _totalButton.layer.cornerRadius = _totalButton.bounds.size.height/2;
    [_totalButton addTarget:self action:@selector(kindButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    _totalButton.layer.borderColor = [UIColor clearColor].CGColor;
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

@end
