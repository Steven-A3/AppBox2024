//
//  A3LoanCalcDateInputCell.m
//  A3TeamWork
//
//  Created by kihyunkim on 2014. 1. 16..
//  Copyright (c) 2014년 ALLABOUTAPPS. All rights reserved.
//

#import "A3LoanCalcDateInputCell.h"

@implementation A3LoanCalcDateInputCell

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

	CGFloat scale = [A3UIDevice scaleToOriginalDesignDimension];
	[_picker remakeConstraints:^(MASConstraintMaker *make) {
		if (IS_IPHONE) {
			make.left.equalTo(self.left);
			make.right.equalTo(self.right);
			make.centerY.equalTo(self.centerY);
			make.height.equalTo(@(216 * scale));
		} else {
			make.centerX.equalTo(self.centerX);
			make.centerY.equalTo(self.centerY);
			make.width.equalTo(@320);
			make.height.equalTo(@(216 * scale));
		}
	}];
	
	[self layoutIfNeeded];
}

@end
