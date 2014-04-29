//
//  A3WalletItemPhotoFieldCell.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 30..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3WalletItemPhotoFieldCell.h"

@implementation A3WalletItemPhotoFieldCell

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
    
    _photoButton.layer.cornerRadius = _photoButton.frame.size.width/2.0;
    _photoButton.clipsToBounds = YES;

	[_photoButton makeConstraints:^(MASConstraintMaker *make) {
		make.right.equalTo(self.right).with.offset(-15);
		make.width.equalTo(@60);
		make.height.equalTo(@60);
		make.centerY.equalTo(self.centerY);
	}];

	[_valueTextField makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(self.left).with.offset(IS_IPHONE ? 15 : 28);
		make.centerY.equalTo(self.centerY);
		make.right.equalTo(_photoButton.left);
		make.height.equalTo(@50);
	}];
}

- (void)prepareForReuse {
	for (UIView *subview in [_photoButton subviews]) {
		[subview removeFromSuperview];
	}
}

@end
