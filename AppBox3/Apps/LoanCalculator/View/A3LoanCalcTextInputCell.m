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
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
	self = [super initWithCoder:coder];
	if (self) {
		[self initialize];
	}

	return self;
}

- (void)initialize {
	if (IS_IPHONE) {
		_textLabelOffset = [[UIScreen mainScreen] scale] > 2 ? 20 : 15;
	} else {
		_textLabelOffset = 28;
	}
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

	[_titleLabel remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.left).with.offset(self->_textLabelOffset);
		make.centerY.equalTo(self.centerY);
	}];

	_textFieldRightConstraint.constant = -(_textLabelOffset);
	_detailLabelRightConstraint.constant = -(_textLabelOffset);
}

- (void)prepareForReuse {
	[super prepareForReuse];

	[self.textField setUserInteractionEnabled:YES];

	_textField.placeholder = nil;
    _textField.hidden = NO;
	_textField.attributedPlaceholder = nil;
    _detailLabel.hidden = YES;
}

- (void)updateConstraints {
	[_titleLabel updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.left).with.offset(self->_textLabelOffset);
	}];
	[super updateConstraints];
}

@end
