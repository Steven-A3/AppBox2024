//
//  A3AbbreviationDrillDownTableViewCell.m
//  AppBox3
//
//  Created by Byeong-Kwon Kwak on 1/5/17.
//  Copyright © 2017 ALLABOUTAPPS. All rights reserved.
//

#import "A3AbbreviationDrillDownTableViewCell.h"

@implementation A3AbbreviationDrillDownTableViewCell

+ (NSString *)reuseIdentifier {
	return @"A3AbbreviationDrillDownCell";
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
