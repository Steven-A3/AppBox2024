//
//  A3WalletItemTitleView.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 23..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <AppBoxKit/AppBoxKit.h>
#import "A3WalletItemTitleView.h"

@interface A3WalletItemTitleView ()

@property (nonatomic, strong) MASConstraint *favoriteButtonWidth;

@end

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

    if (IS_RETINA) {
        CGRect frame = self.frame;
        frame.size.height = 73.5;
        self.frame = frame;
    }
	[self addSubview:self.favoriteButton];

	CGFloat leading = IS_IPHONE ? ([[UIScreen mainScreen] scale] > 2 ? 20 : 15) : 28;
	[_titleTextField makeConstraints:^(MASConstraintMaker *make) {
		make.baseline.equalTo(self.bottom).with.offset(-39);
		make.left.equalTo(self.left).with.offset(leading);
		make.right.equalTo(self->_favoriteButton.left).with.offset(5);
	}];
	[_favoriteButton makeConstraints:^(MASConstraintMaker *make) {
		self.favoriteButtonWidth = make.width.equalTo(@40);
		make.height.equalTo(@40);
		make.right.equalTo(self.right).with.offset(-5);
		make.centerY.equalTo(self->_titleTextField.centerY);
	}];
}

- (UIButton *)favoriteButton
{
    if (!_favoriteButton) {
        _favoriteButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        [_favoriteButton setContentMode:UIViewContentModeRight];
        [_favoriteButton setImage:[UIImage imageNamed:@"star02"] forState:UIControlStateNormal];
        [_favoriteButton setImage:[UIImage imageNamed:@"star02_on"] forState:UIControlStateSelected];
    }
    
    return _favoriteButton;
}

- (void)setIsEditMode:(BOOL)isEditMode
{
    _isEditMode = isEditMode;
}

@end
