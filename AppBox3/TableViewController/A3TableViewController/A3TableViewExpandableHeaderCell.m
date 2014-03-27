//
//  A3TableViewExpandableHeaderCell.m
//  AppBox3
//
//  Created by A3 on 10/29/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3TableViewExpandableHeaderCell.h"
#import "A3UIDevice.h"

@implementation A3TableViewExpandableHeaderCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
		self.backgroundColor = [UIColor colorWithRed:239.0/255.0 green:239.0/255.0 blue:244.0/255.0 alpha:1.0];
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
		_titleLabel.font = [UIFont fontWithName:@".HelveticaNeueInterface-M3" size:14.0];
		_titleLabel.textColor = [UIColor colorWithRed:77.0/255.0 green:77.0/255.0 blue:77.0/255.0 alpha:1.0];
		[self addSubview:_titleLabel];

		[_titleLabel makeConstraints:^(MASConstraintMaker *make) {
			make.left.equalTo(self.left).with.offset(IS_IPHONE ? 15 : 28);
			make.bottom.equalTo(self.bottom).with.offset(-10);
		}];
	}
}

- (void)addExpandButton {
	[self addSubview:self.expandButton];

	[self.expandButton makeConstraints:^(MASConstraintMaker *make) {
		make.right.equalTo(self.right).with.offset(-6);
		make.bottom.equalTo(self.bottom).with.offset(0);
	}];
}

@end
