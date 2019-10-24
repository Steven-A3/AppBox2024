//
//  A3JHTableViewExpandableHeaderCell.m
//  AppBox3
//
//  Created by A3 on 10/29/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3JHTableViewExpandableHeaderCell.h"
#import "A3UIDevice.h"

@implementation A3JHTableViewExpandableHeaderCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
		self.backgroundColor = [UIColor colorWithRed:239.0/255.0 green:239.0/255.0 blue:244.0/255.0 alpha:1.0];
		self.selectionStyle = UITableViewCellSelectionStyleNone;

		[self addTitleLabel];
		[self addExpandButton];
		self.clipsToBounds = NO;
		self.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    return self;
}

- (void)addTitleLabel {
	if (!_titleLabel) {
		_titleLabel = [UILabel new];
		_titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:14.0];
		_titleLabel.textColor = [UIColor colorWithRed:77.0/255.0 green:77.0/255.0 blue:77.0/255.0 alpha:1.0];
		[self addSubview:_titleLabel];

		[_titleLabel makeConstraints:^(MASConstraintMaker *make) {
			make.left.equalTo(self.left).with.offset(IS_IPHONE ? ([[UIScreen mainScreen] scale] > 2 ? 20 : 15) : 28);
			make.bottom.equalTo(self.bottom).with.offset(-10);
		}];
	}
}

- (void)addExpandButton {
	if (!_expandButton) {
		_expandButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _expandButton.titleLabel.font = [UIFont fontWithName:@"appbox" size:17];
		[_expandButton setTitle:@"j" forState:UIControlStateNormal];
		[_expandButton setTitleColor:[UIColor colorWithRed:199.0 / 255.0 green:199.0 / 255.0 blue:204.0 / 255.0 alpha:1.0] forState:UIControlStateNormal];
		[_expandButton addTarget:self action:@selector(expandButtonAction:) forControlEvents:UIControlEventTouchUpInside];

		[self addSubview:_expandButton];

		[_expandButton makeConstraints:^(MASConstraintMaker *make) {
			make.right.equalTo(self.right).with.offset(-8.5);
			make.bottom.equalTo(self.bottom).with.offset(0);
		}];
	}
}

- (void)expandButtonAction:(UIButton *)expandButton {
	if ([_delegate respondsToSelector:@selector(expandButtonPressed:)]) {
		[_delegate expandButtonPressed:expandButton];
	}
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
