//
//  A3WalletCateEditIconCell.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 21..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3WalletCateEditIconCell.h"

@interface A3WalletCateEditIconCell ()

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;

@end

@implementation A3WalletCateEditIconCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];

	CGFloat leading = IS_IPHONE ? ([[UIScreen mainScreen] scale] > 2 ? 20 : 15) : 28;
	[_titleLabel makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(self.left).with.offset(leading);
		make.centerY.equalTo(self.centerY);
	}];
    self.accessoryView = self.iconImageView;
}

- (UIImageView *)iconImageView
{
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    }
    
    return _iconImageView;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
