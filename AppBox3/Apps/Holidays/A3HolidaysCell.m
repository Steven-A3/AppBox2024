//
//  A3HolidaysCell.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/28/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3HolidaysCell.h"
#import "SFKImage.h"
#import "UITableViewCell+accessory.h"

@interface A3HolidaysCell ()

@property (nonatomic, strong) MASConstraint *titleCenterY;
@property (nonatomic, strong) NSMutableArray *mutableConstraints;

@end

@implementation A3HolidaysCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
		// Initialization code

		_titleLabel = [UILabel new];
		_titleLabel.textColor = [UIColor whiteColor];
		_titleLabel.adjustsFontSizeToFitWidth = YES;
		_titleLabel.minimumScaleFactor = 0.5;
		[self addSubview:_titleLabel];

		[_titleLabel makeConstraints:^(MASConstraintMaker *make) {
			make.left.equalTo(self.left).with.offset(IS_IPHONE ? 15 : 28);
			make.width.equalTo(self.width).with.offset(IS_IPHONE ? -30 : -56);
			_titleCenterY = make.centerY.equalTo(self.centerY).with.offset(0);
		}];

		_lunarDateLabel = [UILabel new];
		_lunarDateLabel.textAlignment = NSTextAlignmentRight;
		_lunarDateLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.7];
		_lunarDateLabel.adjustsFontSizeToFitWidth = YES;
		_lunarDateLabel.minimumScaleFactor = 0.5;
		[self addSubview:_lunarDateLabel];

		[_lunarDateLabel makeConstraints:^(MASConstraintMaker *make) {
			make.right.equalTo(self.right).with.offset(IS_IPHONE ? -15 : -28);
			make.top.equalTo(_titleLabel.bottom).offset(10);
		}];

		_lunarImageView = [UIImageView new];
		[SFKImage setDefaultFont:[UIFont fontWithName:@"appbox" size:35]];
		[SFKImage setDefaultColor:[UIColor colorWithWhite:1.0 alpha:0.5]];
		_lunarImageView.image = [SFKImage imageNamed:@"f"];
		[self addSubview:_lunarImageView];

		[_lunarImageView makeConstraints:^(MASConstraintMaker *make) {
			make.centerY.equalTo(_lunarDateLabel.centerY);
			make.right.equalTo(_lunarDateLabel.left).with.offset(6);
		}];

		[self dateLabel];

		self.backgroundColor = [UIColor clearColor];
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		self.textLabel.textColor = [UIColor whiteColor];

		[self assignFontsToLabels];
	}
    return self;
}

- (void)assignFontsToLabels {
	_titleLabel.textColor = [UIColor whiteColor];
	_dateLabel.textColor = [UIColor whiteColor];
	_lunarImageView.tintColor = [UIColor colorWithWhite:1.0 alpha:0.7];
	_lunarDateLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.7];
	_publicMarkView.layer.borderColor = [UIColor whiteColor].CGColor;
	_publicLabel.textColor = [UIColor whiteColor];

	_titleLabel.font = IS_IPHONE ? [UIFont systemFontOfSize:15] : [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
	_dateLabel.font = IS_IPHONE ? [UIFont systemFontOfSize:13] : [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
	_lunarDateLabel.font = IS_IPHONE ? [UIFont systemFontOfSize:12] : [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];

	[_lunarImageView setHidden:YES];
	[_lunarDateLabel setHidden:YES];
}

- (UILabel *)dateLabel {
	if (!_dateLabel) {
		_dateLabel = [UILabel new];
		_dateLabel.textColor = [UIColor whiteColor];
		_dateLabel.adjustsFontSizeToFitWidth = YES;
		_dateLabel.minimumScaleFactor = 0.5;
		_dateLabel.textAlignment = NSTextAlignmentRight;
		[self addSubview:_dateLabel];

		if (IS_IPHONE) {
			_publicMarkView = [self createAddPublicMarkToSelf];
			_publicLabel = _publicMarkView.subviews[0];

			[_publicMarkView makeConstraints:^(MASConstraintMaker *make) {
				make.centerY.equalTo(_dateLabel.centerY);
				make.width.equalTo(@18);
				make.height.equalTo(@18);
			}];
		} else {
			// IPAD의 경우, 항상 같은 위치에 표시
			[_dateLabel makeConstraints:^(MASConstraintMaker *make) {
				make.baseline.equalTo(_titleLabel.baseline);
				make.right.equalTo(self.right).with.offset(-28);
			}];

			_publicLabel = [UILabel new];
			_publicLabel.textAlignment = NSTextAlignmentCenter;
			_publicLabel.textColor = [UIColor whiteColor];
			_publicLabel.font = [UIFont systemFontOfSize:IS_IPHONE ? 11 : 13];
			_publicLabel.text = NSLocalizedString(@"Public", @"Public");
			[self addSubview:_publicLabel];

			CGSize size = [_publicLabel.text sizeWithAttributes:@{NSFontAttributeName : _publicLabel.font}];
			[_publicLabel makeConstraints:^(MASConstraintMaker *make) {
				make.width.equalTo(@(size.width + 2));
				make.height.equalTo(@(size.height));
				make.centerX.equalTo(self.centerX);
				make.centerY.equalTo(_titleLabel.centerY);
			}];
			[_publicLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];

			_publicMarkView = [UIView new];
			_publicMarkView.layer.borderColor = [UIColor whiteColor].CGColor;
			_publicMarkView.layer.borderWidth = IS_RETINA ? 0.25 : 0.5;
			_publicMarkView.layer.cornerRadius = 5;
			[self insertSubview:_publicMarkView belowSubview:_publicLabel];

			[_publicMarkView makeConstraints:^(MASConstraintMaker *make) {
				make.width.equalTo(@(size.width + 9));
				make.height.equalTo(@(size.height + 4));
				make.centerX.equalTo(_publicLabel.centerX);
				make.centerY.equalTo(_publicLabel.centerY);
			}];
		}
	}
	return _dateLabel;
}

/*! cellType을 변경하면 레이아웃을 조정한다.
 *  showPublic은 호출전에 설정해두어야 한다.
 * \param
 * \returns
 */
- (void)setCellType:(A3HolidayCellType)cellType {
	_cellType = cellType;
	switch (_cellType) {
		case A3HolidayCellTypeSingleLine:
			_titleCenterY.offset(0);
			[_lunarImageView setHidden:YES];
			[_lunarDateLabel setHidden:YES];
			break;
		case A3HolidayCellTypeDoubleLine:
			_titleCenterY.offset(-14);
			[_lunarImageView setHidden:YES];
			[_lunarDateLabel setHidden:YES];
			break;
		case A3HolidayCellTypeLunar1:
		case A3HolidayCellTypeLunar2:
			_titleCenterY.offset(-14);
			[_lunarImageView setHidden:NO];
			[_lunarDateLabel setHidden:NO];
			break;
	}

	[self.publicLabel setHidden:!_showPublic];
	[self.publicMarkView setHidden:!_showPublic];

	for (MASConstraint *constraint in self.mutableConstraints) {
		[constraint uninstall];
	}
	[self.mutableConstraints removeAllObjects];

	if (IS_IPHONE) {
		[_dateLabel sizeToFit];
		[_dateLabel makeConstraints:^(MASConstraintMaker *make) {
			switch (_cellType) {
				case A3HolidayCellTypeSingleLine:
				case A3HolidayCellTypeLunar1:
					[self.mutableConstraints addObject:make.baseline.equalTo(_titleLabel.baseline)];
					[self.mutableConstraints addObject:make.right.equalTo(self.right).offset(-15)];
					[self.mutableConstraints addObject:make.width.equalTo(@(78))];
					_dateLabel.textAlignment = NSTextAlignmentRight;
					break;
				case A3HolidayCellTypeDoubleLine:
				case A3HolidayCellTypeLunar2:
					if (_showPublic) {
						[self.mutableConstraints addObject:make.left.equalTo(_publicMarkView.right).with.offset(5)];
					} else {
						[self.mutableConstraints addObject:make.left.equalTo(self.left).with.offset(15)];
					}
					[self.mutableConstraints addObject:make.right.equalTo(self.right)];
					[self.mutableConstraints addObject:make.centerY.equalTo(self.centerY).with.offset(15)];
					_dateLabel.textAlignment = NSTextAlignmentLeft;
					break;
			}
		}];
		if (_showPublic) {
			[_publicMarkView makeConstraints:^(MASConstraintMaker *make) {
				switch (_cellType) {
					case A3HolidayCellTypeSingleLine:
					case A3HolidayCellTypeLunar1:
						[self.mutableConstraints addObject:make.left.equalTo(self.right).with.offset(-113)];
						break;
					case A3HolidayCellTypeDoubleLine:
					case A3HolidayCellTypeLunar2:
						[self.mutableConstraints addObject:make.left.equalTo(self.left).with.offset(15)];
						break;
				}
			}];
		}
	}

	[self layoutIfNeeded];
}

- (NSMutableArray *)mutableConstraints {
	if (!_mutableConstraints) {
		_mutableConstraints = [NSMutableArray new];
	}
	return _mutableConstraints;
}


@end
