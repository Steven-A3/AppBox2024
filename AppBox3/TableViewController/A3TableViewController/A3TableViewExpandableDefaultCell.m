//
//  A3TableViewExpandableDefaultCell.m
//  AppBox3
//
//  Created by A3 on 11/26/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3TableViewExpandableDefaultCell.h"

@implementation A3TableViewExpandableDefaultCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
		[self addSubview:self.expandButton];
		[self.expandButton makeConstraints:^(MASConstraintMaker *make) {
			make.centerY.equalTo(self.centerY);
			make.right.equalTo(self.right).offset(-10);
		}];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
