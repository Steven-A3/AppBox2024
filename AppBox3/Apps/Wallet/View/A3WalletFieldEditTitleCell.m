//
//  A3WalletFieldEditTitleCell.m
//  AppBox3
//
//  Created by A3 on 4/25/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "A3WalletFieldEditTitleCell.h"

@implementation A3WalletFieldEditTitleCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib {
	[super awakeFromNib];
	
	[_textField makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(self.left).with.offset(15);
		make.centerY.equalTo(self.centerY);
		make.right.equalTo(self.right).with.offset(-15);
	}];
}

@end
