//
//  A3WalletCateInfoFieldCell.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 15..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3WalletCateInfoFieldCell.h"
#import "A3UIDevice.h"

@implementation A3WalletCateInfoFieldCell

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

    [_nameLabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.left).with.offset(IS_IPAD ? 28+30+28:15+30+15);
        make.top.equalTo(self.top).with.offset(15);
    }];

    [_typeLabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.left).with.offset(IS_IPAD ? 28+30+28:15+30+15);
        make.bottom.equalTo(self.bottom).with.offset(-15);
    }];
}

@end
