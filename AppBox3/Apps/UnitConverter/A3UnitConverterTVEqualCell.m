//
//  A3UnitConverterTVEqualCell.m
//  A3TeamWork
//
//  Created by kihyunkim on 13. 10. 12..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3UnitConverterTVEqualCell.h"

@implementation A3UnitConverterTVEqualCell

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

- (CGFloat)menuWidth {
	return 0.0;
}

- (void)awakeFromNib {
	[super awakeFromNib];

	self.selectionStyle = UITableViewCellSelectionStyleNone;

	[_centerLabel makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(self.contentView.centerX);
		make.centerY.equalTo(self.contentView.centerY);
	}];
}

@end
