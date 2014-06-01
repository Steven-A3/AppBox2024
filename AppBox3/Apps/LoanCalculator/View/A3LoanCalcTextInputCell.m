//
//  A3LoanCalcTextInputCell.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 12. 7..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3LoanCalcTextInputCell.h"

@implementation A3LoanCalcTextInputCell

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

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = _detailLabel.frame;
    frame.origin.x = CGRectGetWidth(self.contentView.frame) - (frame.size.width + 15);
    _detailLabel.frame = frame;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)prepareForReuse {
	[super prepareForReuse];

	[self.textField setUserInteractionEnabled:YES];

	_textField.placeholder = nil;
	_textField.attributedPlaceholder = nil;
    _detailLabel.hidden = YES;
}

@end
