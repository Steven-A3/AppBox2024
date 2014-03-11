//
//  A3UnitPriceNoteCell.m
//  A3TeamWork
//
//  Created by kihyunkim on 2014. 1. 24..
//  Copyright (c) 2014년 ALLABOUTAPPS. All rights reserved.
//

#import "A3UnitPriceNoteCell.h"

@implementation A3UnitPriceNoteCell

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didTextFieldActiveNoti:) name:UITextFieldTextDidBeginEditingNotification object:self.textFd];
}

- (void)didTextFieldActiveNoti:(NSNotification *) noti
{
    if (_delegate && [_delegate respondsToSelector:@selector(didTextFieldBeActive:inTableViewCell:)]) {
        [_delegate didTextFieldBeActive:self.textFd inTableViewCell:self];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
