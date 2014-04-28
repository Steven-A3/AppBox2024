//
//  A3WalletItemFieldCell.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 23..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3WalletItemFieldCell.h"
#import "UIImage+imageWithColor.h"

@implementation A3WalletItemFieldCell

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

	[_valueTextField makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(self.left).with.offset(IS_IPHONE ? 15 : 28);
		make.centerY.equalTo(self.centerY);
		make.right.equalTo(self.right).with.offset(IS_IPHONE ? -15 : -28);
		make.height.equalTo(@50);
	}];
}

- (void)addDeleteButton {
	if (!_deleteButton) {
		_deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[_deleteButton setImage:[[UIImage imageNamed:@"delete03"] tintedImageWithColor:[UIColor colorWithRed:204.0 / 255.0 green:204.0 / 255.0 blue:204.0 / 255.0 alpha:1.0]] forState:UIControlStateNormal];
		[self addSubview:_deleteButton];

		[_deleteButton makeConstraints:^(MASConstraintMaker *make) {
			make.right.equalTo(self.right).with.offset(-7.5);
			make.centerY.equalTo(self.centerY);
			make.width.equalTo(@44);
			make.height.equalTo(@44);
		}];
	}
}

- (void)prepareForReuse {
	[_deleteButton removeFromSuperview];
	_deleteButton = nil;
}

@end
