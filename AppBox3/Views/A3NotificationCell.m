//
//  A3NotificationCell.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 12/10/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3NotificationCell.h"
#import "A3NotificationTitleBGView.h"
#import "A3YellowXButton.h"

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

		CGFloat buttonSize = 22.0f;
		_xButton = [[A3YellowXButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.bounds) - 20.0f - buttonSize, 19.0f, buttonSize, buttonSize)];
		[self addSubview:_xButton];
	}
    return self;
}

- (UILabel *)messageText {
	if (nil == _messageText) {
		_messageText = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 20.0f, 200.0f, 18.0f)];
		_messageText.backgroundColor = [UIColor clearColor];
		_messageText.textColor = [UIColor whiteColor];
		_messageText.font = [UIFont systemFontOfSize:15.0f];
		[self addSubview:_messageText];
	}
	return _messageText;
}

- (void)layoutDetailTexts {
	CGFloat width = CGRectGetWidth(self.bounds);
	CGFloat originY = [_detailText2.text length] ? 15.0f : 22.0f;
	CGFloat labelWidth = 100.0f;
	[_detailText setFrame:CGRectMake(width - labelWidth - 40.0f - 10.0f, originY, labelWidth, 14.0f)];
	originY = [_detailText.text length] ? 30.0f : 22.0f;
	[_detailText2 setFrame:CGRectMake(width - labelWidth - 40.0f - 10.0f, originY, labelWidth, 14.0f)];
}

- (UILabel *)detailText {
	if (nil == _detailText) {
		_detailText = [[UILabel alloc] initWithFrame:CGRectZero];
		_detailText.textAlignment = UITextAlignmentRight;
		_detailText.font = [UIFont boldSystemFontOfSize:12.0f];
		_detailText.textColor = [UIColor colorWithRed:153.0f/255.0f green:153.0f/255.0f blue:153.0f/255.0f alpha:1.0f];
		_detailText.backgroundColor = [UIColor clearColor];
		[self addSubview:_detailText];
	}
	return _detailText;
}

- (UILabel *)detailText2 {
	if (nil == _detailText2) {
		_detailText2 = [[UILabel alloc] initWithFrame:CGRectZero];
		_detailText2.textAlignment = UITextAlignmentRight;
		_detailText2.font = [UIFont boldSystemFontOfSize:12.0f];
		_detailText2.textColor = [UIColor colorWithRed:184.0f/255.0f green:184.0f/255.0f blue:184.0f/255.0f alpha:1.0f];
		_detailText2.backgroundColor = [UIColor clearColor];
		[self addSubview:_detailText2];
	}
	return _detailText2;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
