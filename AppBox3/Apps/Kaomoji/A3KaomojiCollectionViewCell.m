//
//  A3KaomojiCollectionViewCell.m
//  AppBox3
//
//  Created by Byeong-Kwon Kwak on 2/6/17.
//  Copyright © 2017 ALLABOUTAPPS. All rights reserved.
//

#import "A3KaomojiCollectionViewCell.h"

@implementation A3KaomojiCollectionViewCell

+ (NSString *)reuseIdentifier {
	return @"kaomojiCollectionViewCell";
}

- (void)awakeFromNib {
	[super awakeFromNib];

	_roundedRectView.layer.cornerRadius = 10;
	_roundedRectView.layer.masksToBounds = YES;


	if (IS_IPHONE_4_7_INCH) {
		if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.2")) {
			_groupTitleLabel.font = [UIFont systemFontOfSize:22 weight:UIFontWeightMedium];
		} else {
			_groupTitleLabel.font = [UIFont boldSystemFontOfSize:22];
		}
		_row1TitleLabel.font = [UIFont systemFontOfSize:17];
		_row2TitleLabel.font = [UIFont systemFontOfSize:17];
		_row3TitleLabel.font = [UIFont systemFontOfSize:17];
	} else if (IS_IPHONE_4_INCH || IS_IPHONE_3_5_INCH) {
		if (IS_IPHONE_3_5_INCH) {
			if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.2")) {
				_groupTitleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];
			} else {
				_groupTitleLabel.font = [UIFont boldSystemFontOfSize:18];
			}
		} else {
			if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.2")) {
				_groupTitleLabel.font = [UIFont systemFontOfSize:19 weight:UIFontWeightMedium];
			} else {
				_groupTitleLabel.font = [UIFont boldSystemFontOfSize:19];
			}
		}
		_row1TitleLabel.font = [UIFont systemFontOfSize:15];
		_row2TitleLabel.font = [UIFont systemFontOfSize:15];
		_row3TitleLabel.font = [UIFont systemFontOfSize:15];
	} else if (IS_IPAD_12_9_INCH) {
		
	} else if (IS_IPAD) {
		
	}
}

@end
