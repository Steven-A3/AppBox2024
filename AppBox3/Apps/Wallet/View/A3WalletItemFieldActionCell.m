//
//  A3WalletItemFieldActionCell.m
//  A3TeamWork
//
//  Created by kihyunkim on 2014. 1. 5..
//  Copyright (c) 2014년 ALLABOUTAPPS. All rights reserved.
//

#import "A3WalletItemFieldActionCell.h"

@implementation A3WalletItemFieldActionCell

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

- (void)awakeFromNib {
	[super awakeFromNib];

	CGFloat leading = IS_IPHONE ? ([[UIScreen mainScreen] scale] > 2 ? 20 : 15) : 28;
	[self.rightBtn2 makeConstraints:^(MASConstraintMaker *make) {
		make.width.equalTo(@40);
		make.height.equalTo(@40);
		make.centerY.equalTo(self.centerY);
		make.right.equalTo(self.right).with.offset(-leading);
	}];
	[self.rightBtn1 makeConstraints:^(MASConstraintMaker *make) {
		make.width.equalTo(@40);
		make.height.equalTo(@40);
		make.centerY.equalTo(self.centerY);
		make.right.equalTo(self.rightBtn2.left).with.offset(-5);
	}];
}


@end
