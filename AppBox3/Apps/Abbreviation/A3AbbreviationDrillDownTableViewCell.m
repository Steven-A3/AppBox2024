//
//  A3AbbreviationDrillDownTableViewCell.m
//  AppBox3
//
//  Created by Byeong-Kwon Kwak on 1/5/17.
//  Copyright © 2017 ALLABOUTAPPS. All rights reserved.
//

#import "A3AbbreviationDrillDownTableViewCell.h"

@implementation A3AbbreviationDrillDownTableViewCell

+ (NSString *)reuseIdentifier {
	return @"A3AbbreviationDrillDownCell";
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
	if (IS_IPHONE_4_7_INCH) {
		_titleLabel.font = [UIFont systemFontOfSize:16];
		_subtitleLabel.font = [UIFont systemFontOfSize:13];
	} else if (IS_IPHONE_4_INCH || IS_IPHONE_3_5_INCH) {
		_titleLabel.font = [UIFont systemFontOfSize:14];
		_subtitleLabel.font = [UIFont systemFontOfSize:11];
	} else if (IS_IPAD_12_9_INCH) {
		
	} else if (IS_IPAD) {
		
	}
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
