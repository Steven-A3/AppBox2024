//
//  A3DateCalcAddSubCell1.m
//  A3TeamWork
//
//  Created by jeonghwan kim on 13. 11. 13..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3DateCalcAddSubCell1.h"
#import "A3DateCalcAddSubButton.h"

@implementation A3DateCalcAddSubCell1

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        [_addModeButton makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.left);
            make.top.equalTo(self.top);
            make.bottom.equalTo(self.bottom);
            make.trailing.equalTo(self.centerX);
        }];
        
        [_subModeButton makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.centerX);
            make.top.equalTo(self.top);
            make.bottom.equalTo(self.bottom);
            make.trailing.equalTo(self.right);
        }];
    }
    return self;
}

-(void)layoutSubviews
{
    self.addModeButton.isAddButton = YES;
    self.subModeButton.isAddButton = NO;
    [super layoutSubviews];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
