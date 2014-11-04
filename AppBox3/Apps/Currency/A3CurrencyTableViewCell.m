//
//  A3CurrencyTableViewCell.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 7/6/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3CurrencyTableViewCell.h"
#import "UIViewController+tableViewStandardDimension.h"

@implementation A3CurrencyTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
		[self separatorLineView];
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

	[self separatorLineView];
}

- (UIView *)separatorLineView {
	if (!_separatorLineView) {
		_separatorLineView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 83.0, self.bounds.size.width, 1.0)];
		_separatorLineView.backgroundColor = A3UITableViewSeparatorColor;
		[self.contentView addSubview:_separatorLineView];

		[_separatorLineView makeConstraints:^(MASConstraintMaker *make) {
			make.left.equalTo(self.left);
			make.right.equalTo(self.right);
			make.bottom.equalTo(self.bottom);
			make.height.equalTo(@(1 / [UIScreen mainScreen].scale));
		}];
	}
	return _separatorLineView;
}

@end
