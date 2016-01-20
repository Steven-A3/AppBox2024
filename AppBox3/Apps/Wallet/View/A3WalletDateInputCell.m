//
//  A3WalletDateInputCell.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 12. 26..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3WalletDateInputCell.h"

@implementation A3WalletDateInputCell

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
    
	[_datePicker makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(self.centerX);
		make.centerY.equalTo(self.centerY);
		make.width.equalTo(@320);
		make.height.equalTo(@216);
	}];
}

@end
