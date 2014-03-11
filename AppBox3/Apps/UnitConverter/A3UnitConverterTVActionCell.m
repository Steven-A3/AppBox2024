//
//  A3UnitConverterTVActionCell.m
//  A3TeamWork
//
//  Created by kihyunkim on 13. 10. 23..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3UnitConverterTVActionCell.h"

@implementation A3UnitConverterTVActionCell

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
