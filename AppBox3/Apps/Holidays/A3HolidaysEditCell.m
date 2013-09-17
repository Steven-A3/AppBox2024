//
//  A3HolidaysEditCell.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 9/1/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3HolidaysEditCell.h"
#import "A3UIDevice.h"

@interface A3HolidaysEditCell ()
@property (nonatomic, strong) id<MASConstraint> publicMarkWidth;
@property (nonatomic, strong) id<MASConstraint> publicMarkHeight;
@end

@implementation A3HolidaysEditCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
		// Initialization code
		self.selectionStyle = UITableViewCellSelectionStyleNone;

		_switchControl = [UISwitch new];
		self.accessoryView = _switchControl;

		if (IS_IPAD) {
			_dateLabel = [UILabel new];
			_dateLabel.textAlignment = NSTextAlignmentRight;
			_dateLabel.textColor = [UIColor colorWithRed:159.0/255.0 green:159.0/255.0 blue:159.0/255.0 alpha:1.0];
			[self addSubview:_dateLabel];

			[_dateLabel makeConstraints:^(MASConstraintMaker *make) {
				make.right.equalTo(self.right).with.offset(-76);
				make.centerY.equalTo(self.centerY);
			}];
		}

		_publicLabel = [UILabel new];
		_publicLabel.textAlignment = NSTextAlignmentCenter;
		_publicLabel.textColor = [UIColor colorWithRed:142.0 / 255.0 green:142.0 / 255.0 blue:147.0 / 255.0 alpha:1.0];
		if (IS_IPHONE) {
			_publicLabel.font = [UIFont fontWithName:@".HelveticaNeueInterface-M3" size:10];
		} else {
			_publicLabel.font = [UIFont fontWithName:@".HelveticaNeueInterface-M3" size:13];
		}
		_publicLabel.text = IS_IPHONE ? @"P" : @"Public";
		[self addSubview:_publicLabel];

		CGSize size = [_publicLabel.text sizeWithAttributes:@{NSFontAttributeName : _publicLabel.font}];
		[_publicLabel makeConstraints:^(MASConstraintMaker *make) {
			_publicMarkWidth = make.width.equalTo(@(size.width + 2));
			_publicMarkHeight = make.height.equalTo(@(size.height));
			make.centerY.equalTo(self.centerY);
			if (IS_IPAD) {
				make.centerX.equalTo(self.centerX);
			} else {
				make.right.equalTo(self.right).with.offset(-84);
			}
		}];
		[_publicLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];

		_publicMarkView = [UIView new];
		_publicMarkView.layer.borderColor = [UIColor colorWithRed:142.0/255.0 green:142.0/255.0 blue:147.0/255.0 alpha:1.0].CGColor;
		_publicMarkView.layer.borderWidth = IS_RETINA ? 0.25 : 0.5;
		_publicMarkView.layer.cornerRadius = 5;
		[self insertSubview:_publicMarkView belowSubview:_publicLabel];

		[_publicMarkView makeConstraints:^(MASConstraintMaker *make) {
			make.centerY.equalTo(self.centerY);
			make.width.equalTo(@(size.width + 9));
			make.height.equalTo(@(size.height + 4));
			if (IS_IPAD) {
				make.centerX.equalTo(self.centerX);
			} else {
				make.right.equalTo(self.right).with.offset(-84 + 3);
			}
		}];

		_nameLabel = [UILabel new];
		_nameLabel.textColor = [UIColor blackColor];
		[self addSubview:_nameLabel];

		[_nameLabel makeConstraints:^(MASConstraintMaker *make) {
			make.left.equalTo(self.left).with.offset(IS_IPHONE ? 15 : 28);
			make.centerY.equalTo(self.centerY);
			make.right.lessThanOrEqualTo(_publicMarkView.left);
		}];

//		[self.textLabel makeConstraints:^(MASConstraintMaker *make) {
//			make.left.equalTo(self.left).with.offset(IS_IPHONE ? 15 : 28);
//			make.right.lessThanOrEqualTo(_publicLabel.left);
//		}];
//		[self.textLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];

		[self setupFont];

		[self layoutIfNeeded];
	}
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse {
	[super prepareForReuse];

	[self setupFont];
}


- (void)setupFont {
	_nameLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
	if (IS_IPAD) {
		_dateLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
	}
}

@end
