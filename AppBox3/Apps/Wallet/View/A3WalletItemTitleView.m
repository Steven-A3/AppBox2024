//
//  A3WalletItemTitleView.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 23..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3WalletItemTitleView.h"

@implementation A3WalletItemTitleView

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
    
    if (IS_IPHONE) {
        _titleTextField.font = [UIFont boldSystemFontOfSize:17];
        _timeLabel.font = [UIFont systemFontOfSize:13];
        _timeLabel.textColor = [UIColor colorWithRed:142.0/255.0 green:142.0/255.0 blue:147.0/255.0 alpha:1.0];
    }
    else {
        
        
    }
    
    if (IS_RETINA) {
        CGRect frame = self.frame;
        frame.size.height = 73.5;
        self.frame = frame;
    }
}

- (UIButton *)favorButton
{
    if (!_favorButton) {
        _favorButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        [_favorButton setContentMode:UIViewContentModeRight];
        [_favorButton setImage:[UIImage imageNamed:@"star02"] forState:UIControlStateNormal];
        [_favorButton setImage:[UIImage imageNamed:@"star02_on"] forState:UIControlStateSelected];
    }
    
    return _favorButton;
}

- (void)setIsEditMode:(BOOL)isEditMode
{
    _isEditMode = isEditMode;
    
    if (_isEditMode) {
        CGRect frame = _titleTextField.frame;
        [self addSubview:self.favorButton];
        _favorButton.layer.anchorPoint = CGPointMake(1.0, 0.5);
        _favorButton.center = CGPointMake(self.bounds.size.width-3, _titleTextField.center.y);
        _favorButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        
        frame.size.width = frame.size.width - 22;
        _titleTextField.frame = frame;
        
        _titleTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }
    else {
        _titleTextField.rightView = self.favorButton;
        _titleTextField.rightViewMode = UITextFieldViewModeAlways;
    }
}

@end
