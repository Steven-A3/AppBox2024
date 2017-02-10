//
//  A3AbbreviationTableViewCell.m
//  AppBox3
//
//  Created by Byeong-Kwon Kwak on 12/13/16.
//  Copyright © 2016 ALLABOUTAPPS. All rights reserved.
//

#import "A3AbbreviationTableViewCell.h"

@interface A3AbbreviationTableViewCell ()

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *alphabetWidthConstraint;

@end

@implementation A3AbbreviationTableViewCell

+ (NSString *)reuseIdentifier {
	return @"abbreviationTableViewCell";
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code

	/*
		_alphabetLabel.font = [UIFont systemFontOfSize:40 weight:UIFontWeightHeavy];
		_abbreviationLabel.font = [UIFont systemFontOfSize:19];
		_meaningLabel.font = [UIFont systemFontOfSize:15];
	 */
	if (IS_IPHONE_5_5_INCH) {
		_alphabetWidthConstraint.constant = 60;
	} else if (IS_IPHONE_4_7_INCH) {
		_alphabetWidthConstraint.constant = 60;
		if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.2")) {
			_alphabetLabel.font = [UIFont systemFontOfSize:36 weight:UIFontWeightHeavy];
		} else {
			_alphabetLabel.font = [UIFont boldSystemFontOfSize:36];
		}
		_abbreviationLabel.font = [UIFont systemFontOfSize:17];
		_meaningLabel.font = [UIFont systemFontOfSize:14];
	} else if (IS_IPHONE_4_INCH || IS_IPHONE_3_5_INCH) {
		_alphabetWidthConstraint.constant = 60;
		if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.2")) {
			_alphabetLabel.font = [UIFont systemFontOfSize:31 weight:UIFontWeightHeavy];
		} else {
			_alphabetLabel.font = [UIFont boldSystemFontOfSize:31];
		}
		_abbreviationLabel.font = [UIFont systemFontOfSize:15];
		_meaningLabel.font = [UIFont systemFontOfSize:12];
	} else if (IS_IPAD) {
		_alphabetWidthConstraint.constant = 80;
	}
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)addTrapezoidShape {
}

- (void)setClipToTrapezoid:(BOOL)clipToTrapezoid {
	_clipToTrapezoid = clipToTrapezoid;
	[self.alphabetTopView setTrapezoidMaskEnabled:clipToTrapezoid];
}

@end
