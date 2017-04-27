//
//  A3AbbreviationCollectionViewCell.m
//  AppBox3
//
//  Created by Byeong-Kwon Kwak on 12/12/16.
//  Copyright © 2016 ALLABOUTAPPS. All rights reserved.
//

#import "A3AbbreviationCollectionViewCell.h"

@interface A3AbbreviationCollectionViewCell ()

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *firstLineHeightConstraint, *secondLineHeightConstraint;

@end

@implementation A3AbbreviationCollectionViewCell

+ (NSString *)reuseIdentifier {
	return @"abbreviationCollectionViewCell";
}

- (void)awakeFromNib {
	[super awakeFromNib];
	
    if ([[UIScreen mainScreen] scale] == 1) {
        _firstLineHeightConstraint.constant = 1.0;
        _secondLineHeightConstraint.constant = 1.0;
    }
    
	_roundedRectView.layer.cornerRadius = 10;
	_roundedRectView.layer.masksToBounds = YES;

	if (IS_IPHONE_4_7_INCH) {
		if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.2")) {
			_groupTitleLabel.font = [UIFont systemFontOfSize:22 weight:UIFontWeightMedium];
		} else {
			_groupTitleLabel.font = [UIFont boldSystemFontOfSize:22];
		}
		_row1TitleLabel.font = [UIFont systemFontOfSize:17];
		_row1SubtitleLabel.font = [UIFont systemFontOfSize:13];
		_row2TitleLabel.font = [UIFont systemFontOfSize:17];
		_row2SubtitleLabel.font = [UIFont systemFontOfSize:13];
		_row3TitleLabel.font = [UIFont systemFontOfSize:17];
		_row3SubtitleLabel.font = [UIFont systemFontOfSize:13];
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
		_row1SubtitleLabel.font = [UIFont systemFontOfSize:11];
		_row2TitleLabel.font = [UIFont systemFontOfSize:15];
		_row2SubtitleLabel.font = [UIFont systemFontOfSize:11];
		_row3TitleLabel.font = [UIFont systemFontOfSize:15];
		_row3SubtitleLabel.font = [UIFont systemFontOfSize:11];
	} else if (IS_IPAD_12_9_INCH) {
		
	} else if (IS_IPAD) {
		
	}
}

@end
