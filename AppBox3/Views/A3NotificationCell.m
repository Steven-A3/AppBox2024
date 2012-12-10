//
//  A3NotificationCell.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 12/10/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3NotificationCell.h"
#import "A3NotificationTitleBGView.h"

@implementation A3NotificationCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
		self.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.7f];
		CGFloat margin_h = 10.0f, margin_v = 10.0f;
		CGRect frame = CGRectMake(CGRectGetMinX(self.bounds) + margin_h, CGRectGetMinY(self.bounds) + margin_v, CGRectGetWidth(self.bounds) - margin_h * 2.0f, 44.0f);
		A3NotificationTitleBGView *titleBGView = [[A3NotificationTitleBGView alloc] initWithFrame:frame];
		[self addSubview:titleBGView];
	}
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
