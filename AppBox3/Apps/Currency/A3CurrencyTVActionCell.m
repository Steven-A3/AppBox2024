//
//  A3CurrencyTVActionCell.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 7/13/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3CurrencyTVActionCell.h"

@implementation A3CurrencyTVActionCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
		self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)awakeFromNib {
	[super awakeFromNib];

	[_centerButton makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(self.contentView.centerX);
		make.centerY.equalTo(self.contentView.centerY);
		make.width.equalTo(@44);
		make.height.equalTo(@44);
	}];
    
    [_rightHelpButton makeConstraints:^(MASConstraintMaker *make) {
		make.trailing.equalTo(IS_IPHONE ? @-4 : @-17);
		make.centerY.equalTo(self.contentView.centerY);
		make.width.equalTo(@44);
		make.height.equalTo(@44);
    }];
    _rightHelpButton.hidden = YES;
}

@end
