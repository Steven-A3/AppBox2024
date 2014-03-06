//
//  A3CurrencyTVEqualCell.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 7/18/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3CurrencyTVEqualCell.h"

@implementation A3CurrencyTVEqualCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (CGFloat)menuWidth {
	return 0.0;
}

- (void)awakeFromNib {
	[super awakeFromNib];

	[_centerLabel makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(self.contentView.centerX);
		make.centerY.equalTo(self.contentView.centerY);
	}];

	[_yahooButton addTarget:self action:@selector(yahooButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	[_yahooButton makeConstraints:^(MASConstraintMaker *make) {
		make.right.equalTo(self.contentView.right).with.offset(-7);
		make.bottom.equalTo(self.contentView.bottom).with.offset(7);
		make.width.equalTo(@44);
		make.height.equalTo(@44);
	}];
}

- (void)yahooButtonAction:(id)yahooButtonAction {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://finance.yahoo.com"]];
}

@end
