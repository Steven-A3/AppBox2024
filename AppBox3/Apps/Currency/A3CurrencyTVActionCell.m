//
//  A3CurrencyTVActionCell.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 7/13/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3CurrencyTVActionCell.h"

@implementation A3CurrencyTVActionCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
		self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

//- (void)prepareForReuse {
//	[super prepareForReuse];
//}
- (CGFloat)menuWidth {
	return 0.0;
}

- (void)awakeFromNib {
	[super awakeFromNib];

	[_centerButton makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(self.contentView.centerX);
		make.centerY.equalTo(self.contentView.centerY);
	}];
}

- (void)prepareForMove {

}

@end

