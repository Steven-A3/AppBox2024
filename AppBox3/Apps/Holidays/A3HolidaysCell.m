//
//  A3HolidaysCell.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/28/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3HolidaysCell.h"
#import "UITableViewCell+accessory.h"
#import "A3UIDevice.h"
#import "FXLabel.h"

@interface A3HolidaysCell ()

@property (nonatomic, strong) id<MASConstraint> titleCenterY;

@end

@implementation A3HolidaysCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
		// Initialization code

		_titleLabel = [FXLabel new];
		_titleLabel.textColor = [UIColor whiteColor];
		_titleLabel.adjustsFontSizeToFitWidth = YES;
		_titleLabel.minimumScaleFactor = 0.5;
		[self setShadowToLabel:_titleLabel];
		[self addSubview:_titleLabel];

		[_titleLabel makeConstraints:^(MASConstraintMaker *make) {
			make.left.equalTo(self.left).with.offset(IS_IPHONE ? 15 : 28);
			make.width.equalTo(self.width).with.offset(IS_IPHONE ? -30 : -56);
			_titleCenterY = make.centerY.equalTo(self.centerY).with.offset(0);
		}];

		_lunarDateLabel = [FXLabel new];
		_lunarDateLabel.textAlignment = NSTextAlignmentRight;
		_lunarDateLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.7];
		_lunarDateLabel.adjustsFontSizeToFitWidth = YES;
		_lunarDateLabel.minimumScaleFactor = 0.5;
		[self setShadowToLabel:_lunarDateLabel];
		[self addSubview:_lunarDateLabel];

		[_lunarDateLabel makeConstraints:^(MASConstraintMaker *make) {
			make.right.equalTo(self.right).with.offset(IS_IPHONE ? -15 : -28);
			make.centerY.equalTo(self.centerY).offset(15);
			if (IS_IPHONE) {
				make.width.equalTo(@78);
			}
		}];

		_lunarImageView = [UIImageView new];
		_lunarImageView.image = [[UIImage imageNamed:@"lunar_stroke"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
		_lunarImageView.tintColor = [UIColor colorWithWhite:1.0 alpha:0.7];
		[self addSubview:_lunarImageView];

		[_lunarImageView makeConstraints:^(MASConstraintMaker *make) {
			make.centerY.equalTo(_lunarDateLabel.centerY);
			if (IS_IPHONE) {
				make.left.equalTo(self.right).with.offset(-113);
			} else {
				make.right.equalTo(_lunarDateLabel.left).with.offset(-10);
			}
		}];

		self.backgroundColor = [UIColor clearColor];
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		self.textLabel.textColor = [UIColor whiteColor];

		[self assignFontsToLabels];
	}
    return self;
}

- (void)setShadowToLabel:(FXLabel *)label {
	label.shadowOffset = CGSizeMake(0, 2);
	label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.24];
	label.shadowBlur = 4;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse {
	[super prepareForReuse];

	_cellType = A3HolidayCellTypeSingleLine;

	[_dateLabel removeFromSuperview];
	_dateLabel = nil;

	[_publicLabel removeFromSuperview];
	_publicLabel = nil;
	[_publicMarkView removeFromSuperview];
	_publicMarkView = nil;

	[self assignFontsToLabels];

	_titleCenterY.offset(0);
	[self layoutIfNeeded];
}

- (void)assignFontsToLabels {
	_titleLabel.textColor = [UIColor whiteColor];
	_dateLabel.textColor = [UIColor whiteColor];
	_lunarImageView.tintColor = [UIColor colorWithWhite:1.0 alpha:0.7];
	_lunarDateLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.7];
	_publicMarkView.layer.borderColor = [UIColor whiteColor].CGColor;
	_publicLabel.textColor = [UIColor whiteColor];

	_titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
	_dateLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
	_lunarDateLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];

	[_lunarImageView setHidden:YES];
	[_lunarDateLabel setHidden:YES];
}

- (FXLabel *)dateLabel {
	if (!_dateLabel) {
		_dateLabel = [FXLabel new];
		_dateLabel.textColor = [UIColor whiteColor];
		_dateLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
		_dateLabel.adjustsFontSizeToFitWidth = YES;
		_dateLabel.minimumScaleFactor = 0.5;
		_dateLabel.textAlignment = NSTextAlignmentRight;
		[self setShadowToLabel:_dateLabel];
		[self addSubview:_dateLabel];

		[_dateLabel makeConstraints:^(MASConstraintMaker *make) {
			switch (_cellType) {
				case A3HolidayCellTypeSingleLine:
				case A3HolidayCellTypeLunar1:
					make.baseline.equalTo(_titleLabel.baseline);
					make.right.equalTo(self.right).offset(IS_IPHONE ? -15 : -28);
					if (IS_IPHONE) {
						make.width.equalTo(@(78));
					}
					break;
				case A3HolidayCellTypeDoubleLine:
				case A3HolidayCellTypeLunar2:
					_dateLabelLeft = make.left.equalTo(self.left).with.offset(IS_IPHONE ? 15 + 18 + 5 : 28 + 18 + 5);
					make.centerY.equalTo(self.centerY).with.offset(15);
					break;
			}
		}];

		if (IS_IPHONE) {
			_publicMarkView = [self createAddPublicMarkToSelf];
			_publicLabel = _publicMarkView.subviews[0];

			[_publicMarkView makeConstraints:^(MASConstraintMaker *make) {
				make.centerY.equalTo(_dateLabel.centerY);

				if (IS_IPHONE) {
					make.width.equalTo(@18);
					make.height.equalTo(@18);

					switch (_cellType) {
						case A3HolidayCellTypeSingleLine:
						case A3HolidayCellTypeLunar1:
							make.left.equalTo(self.right).with.offset(-113);
							break;
						case A3HolidayCellTypeDoubleLine:
						case A3HolidayCellTypeLunar2:
							make.left.equalTo(self.left).with.offset(IS_IPHONE ? 15 : 28);
							break;
					}
				} else {
					CGSize size = [@"Public" sizeWithAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:10]}];
					make.width.equalTo(@(size.width + 8));
					make.height.equalTo(@18);
					make.centerX.equalTo(self.centerX);
				}
			}];
		} else {
			_publicLabel = [UILabel new];
			_publicLabel.textAlignment = NSTextAlignmentCenter;
			_publicLabel.textColor = [UIColor whiteColor];
			_publicLabel.font = [UIFont fontWithName:@".HelveticaNeueInterface-M3" size:13];
			_publicLabel.text = @"Public";
			[self addSubview:_publicLabel];

			CGSize size = [_publicLabel.text sizeWithAttributes:@{NSFontAttributeName : _publicLabel.font}];
			[_publicLabel makeConstraints:^(MASConstraintMaker *make) {
				make.width.equalTo(@(size.width + 2));
				make.height.equalTo(@(size.height));
				make.centerY.equalTo(self.centerY);
				make.centerX.equalTo(self.centerX);
			}];
			[_publicLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];

			_publicMarkView = [UIView new];
			_publicMarkView.layer.borderColor = [UIColor whiteColor].CGColor;
			_publicMarkView.layer.borderWidth = IS_RETINA ? 0.25 : 0.5;
			_publicMarkView.layer.cornerRadius = 5;
			[self insertSubview:_publicMarkView belowSubview:_publicLabel];

			[_publicMarkView makeConstraints:^(MASConstraintMaker *make) {
				make.centerY.equalTo(self.centerY);
				make.width.equalTo(@(size.width + 9));
				make.height.equalTo(@(size.height + 4));
				make.centerX.equalTo(self.centerX);
			}];
		}

	}
	return _dateLabel;
}

- (void)setCellType:(A3HolidayCellType)cellType {
	_cellType = cellType;
	switch (_cellType) {
		case A3HolidayCellTypeSingleLine:
			_titleCenterY.offset(0);
			break;
		case A3HolidayCellTypeDoubleLine:
		case A3HolidayCellTypeLunar1:
		case A3HolidayCellTypeLunar2:
			_titleCenterY.offset(-14);
			break;
	}
	[self layoutIfNeeded];
}

@end
