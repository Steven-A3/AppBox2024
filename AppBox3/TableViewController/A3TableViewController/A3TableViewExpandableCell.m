//
//  A3TableViewExpandableCell.m
//  AppBox3
//
//  Created by A3 on 11/26/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3TableViewExpandableCell.h"

@implementation A3TableViewExpandableCell

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

- (UIButton *)expandButton {
	if (!_expandButton) {
		_expandButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_expandButton.titleLabel.font = [UIFont fontWithName:@"appbox" size:17];
		[_expandButton setTitle:@"j" forState:UIControlStateNormal];
		[_expandButton setTitleColor:[UIColor colorWithRed:199.0 / 255.0 green:199.0 / 255.0 blue:204.0 / 255.0 alpha:1.0] forState:UIControlStateNormal];
		[_expandButton addTarget:self action:@selector(expandButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	}
	return _expandButton;
}

- (void)expandButtonAction:(UIButton *)expandButton {
	if ([_delegate respondsToSelector:@selector(expandButtonPressed:)]) {
		[_delegate expandButtonPressed:expandButton];
	}
}

@end
