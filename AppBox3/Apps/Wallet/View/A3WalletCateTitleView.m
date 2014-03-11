//
//  A3WalletCateTitleView.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 15..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3WalletCateTitleView.h"

@implementation A3WalletCateTitleView

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
        _nameLabel.font = [UIFont boldSystemFontOfSize:17];
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

@end
