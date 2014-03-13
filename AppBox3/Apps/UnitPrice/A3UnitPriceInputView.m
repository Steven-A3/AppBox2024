//
//  A3UnitPriceInputView.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 1..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3UnitPriceInputView.h"

@interface A3UnitPriceInputView ()
{
}

@end

@implementation A3UnitPriceInputView

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
    
    [self initialize];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    for (UIView *linewView in _lineViews) {
        if (IS_RETINA) {
            CGRect rect = linewView.frame;
            rect.size.height = 0.5;
            if (linewView.tag == 1000) {
                rect.origin.y += 0.5;
            }
            linewView.frame = rect;
        }
    }
}

- (CGSize)sizeThatFits:(CGSize)size {
	return [self intrinsicContentSize];
}

- (CGSize)intrinsicContentSize {
	if (IS_IPAD) {
		return CGSizeMake(704.0, 178.0);
	} else {
        return CGSizeMake(320.0, 178.0);
    }
}

- (void)initialize
{
    UIColor *txtColor = [UIColor colorWithRed:159.0/255.0 green:159.0/255.0 blue:159.0/255.0 alpha:1.0];
    _priceLabel.textColor = txtColor;
    _unitLabel.textColor = txtColor;
    _sizeLabel.textColor = txtColor;
    _quantityLabel.textColor = txtColor;
    _discountLabel.textColor = txtColor;
    
    for (UIView *linewView in _lineViews) {
        
        linewView.backgroundColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0];
    }
    
    _markLabel.layer.cornerRadius = _markLabel.bounds.size.width/2;
    _markLabel.font = [UIFont systemFontOfSize:11];
    _markLabel.backgroundColor = [UIColor colorWithRed:123.0/255.0 green:123.0/255.0 blue:123.0/255.0 alpha:1.0];
    
}

- (IBAction)buttonTapped:(UIButton *)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(inputViewTapped:)]) {
        [_delegate inputViewTapped:self];
    }
}

- (void)loadFontSettings {
    if (!_labels) {
        return;
    }
    
    for (UILabel *label in _labels) {
        label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    }
}

@end
