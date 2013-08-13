//
//  A3CurrencyHistory3RowCell.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/8/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3CurrencyHistory3RowCell.h"

@implementation A3CurrencyHistory3RowCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setNumberOfLines:(NSNumber *)numberOfLines {
	_numberOfLines = numberOfLines;

	[self removeAllLables];

	NSMutableArray *mLeftLabels = [[NSMutableArray alloc] initWithCapacity:_numberOfLines.integerValue];
	NSMutableArray *mRightLabels = [[NSMutableArray alloc] initWithCapacity:_numberOfLines.integerValue];

	UILabel *leftLabel = [self addUILabelWithColor:[UIColor blackColor]];
	[mLeftLabels addObject:leftLabel];
	UILabel *rightLabel = [self addUILabelWithColor:[UIColor colorWithRed:142.0 / 255.0 green:147.0 / 255.0 blue:147.0 / 255.0 alpha:1.0]];
	[mRightLabels addObject:rightLabel];
	[self addConstraintLeft:leftLabel right:rightLabel centerY:2.0 * (1.0 / (_numberOfLines.integerValue + 1.0))];

	for (NSInteger index = 1; index < numberOfLines.integerValue; index++) {
		UILabel *leftLabel = [self addUILabelWithColor:[UIColor colorWithRed:77.0 / 255.0 green:77.0 / 255.0 blue:77.0 / 255.0 alpha:1.0]];
		[mLeftLabels addObject:leftLabel];
		UILabel *rightLabel = [self addUILabelWithColor:[UIColor colorWithRed:123.0 / 255.0 green:123.0 / 255.0 blue:123.0 / 255.0 alpha:1.0]];
		[mRightLabels addObject:rightLabel];

		[self addConstraintLeft:leftLabel right:rightLabel centerY:2.0 * ((index + 1) / (_numberOfLines.integerValue + 1.0))];
	}

	_leftLabels = [[NSArray alloc] initWithArray:mLeftLabels];
	_rightLabels = [[NSArray alloc] initWithArray:mRightLabels];

	[self useDynamicType];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)removeAllLables {
	[self.contentView removeConstraints:[self.contentView constraints]];

	for (UILabel *label in _leftLabels) {
		[label removeFromSuperview];
	}
	for (UILabel *label in _rightLabels) {
		[label removeFromSuperview];
	}
	_leftLabels = nil;
	_rightLabels = nil;
}

- (void)prepareForReuse {
	[super prepareForReuse];

	[self removeAllLables];
}

- (void)useDynamicType {
	((UILabel *)_leftLabels[0]).font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
	((UILabel *)_rightLabels[0]).font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];

	for (NSInteger index = 1; index < [_leftLabels count]; index++) {
		((UILabel *)_leftLabels[index]).font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
		((UILabel *)_rightLabels[index]).font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
	}
}

@end
