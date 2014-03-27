//
//  A3DaysCounterValue1Cell.m
//  AppBox3
//
//  Created by dotnetguy83 on 3/27/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "A3DaysCounterValue1Cell.h"

@implementation A3DaysCounterValue1Cell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
    [self.titleTextLabel makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.centerY);
        make.leading.equalTo(self.left).with.offset(15);
        make.width.lessThanOrEqualTo(@200);
    }];
    [self.value1TextLabel makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.centerY);
        make.leading.equalTo(self.titleTextLabel.right);
        make.trailing.equalTo(self.contentView.right);
    }];
}

-(void)layoutSubviews {
    [super layoutSubviews];
    [self.titleTextLabel sizeToFit];
    [self.value1TextLabel sizeToFit];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
