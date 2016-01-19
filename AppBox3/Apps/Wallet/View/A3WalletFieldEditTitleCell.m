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
	
	CGFloat leading = IS_IPHONE ? ([[UIScreen mainScreen] scale] > 2 ? 20 : 15) : 28;
	[_textField makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(self.left).with.offset(leading);
		make.centerY.equalTo(self.centerY);
		make.right.equalTo(self.right).with.offset(-leading);
	}];
}

@end
