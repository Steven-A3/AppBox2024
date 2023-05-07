//
//  A3UnitConverterTVDataCell.m
//  A3TeamWork
//
//  Created by kihyunkim on 13. 10. 13..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3UnitConverterTVDataCell.h"
#import "UIViewController+tableViewStandardDimension.h"
#import "A3UIDevice.h"

@interface  A3UnitConverterTVDataCell ()

@property (nonatomic, strong) UIView *separatorLineView;
@property (nonatomic, strong) UIView *menuView;
@property (nonatomic, strong) MASConstraint *valueFieldWidthConstraint, *value2FieldWidthConstraint;

@end

@implementation A3UnitConverterTVDataCell {
	CGFloat _textFieldHeight;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
		// Initialization code
		_textFieldHeight = 77;
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [self.contentView addSubview:self.touchCoverRectButton];
		[self.contentView addSubview:self.valueField];
        [self.contentView addSubview:self.value2Field];
        [self.contentView addSubview:self.valueLabel];
        [self.contentView addSubview:self.value2Label];
		[self.contentView addSubview:self.codeLabel];
		[self.contentView addSubview:self.rateLabel];
		[self.contentView addSubview:self.flagImageView];
		[self separatorLineView];

		[self useDynamicType];
        
        [self setupValueViews];
		[self setupTextFieldConstraints];
		[self setupConstraintsForRightSideViews];
    }
    return self;
}

- (void)prepareForReuse {
	[super prepareForReuse];
    
	[self useDynamicType];

	_valueField.text = @"";
	_value2Field.text = @"";
}

- (void)useDynamicType {
	if (IS_IPHONE) {
		self.codeLabel.font = [UIFont systemFontOfSize:15];
		self.rateLabel.font = [UIFont systemFontOfSize:13];
	} else {
		self.codeLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
		self.rateLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
	}
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setInputType:(UnitInputType)inputType
{
    if (_inputType != inputType) {
        _inputType = inputType;
        [self setupValueViews];
		[self setupTextFieldConstraints];
		if (inputType != UnitInput_Normal) {
			[self updateMultiTextFieldModeConstraintsWithEditingTextField:nil];
		}
		[self layoutIfNeeded];

		FNLOGRECT(_valueField.frame);
		FNLOGRECT(_value2Field.frame);
		FNLOGRECT(_valueLabel.frame);
		FNLOGRECT(_value2Label.frame);
    }
}

- (UITextField *)valueField {
	if (!_valueField) {
		_valueField = [[UITextField alloc] initWithFrame:CGRectZero];
		_valueField.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:65.0];
        _valueField.tag = 1;
		_valueField.adjustsFontSizeToFitWidth = YES;
		_valueField.minimumFontSize = 10;
	}
	return _valueField;
}

- (UITextField *)value2Field {
	if (!_value2Field) {
		_value2Field = [[UITextField alloc] initWithFrame:CGRectMake(7.0, 0.0, 187.0, 83.0)];
		_value2Field.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:65.0];
        _value2Field.tag = 2;
		_value2Field.adjustsFontSizeToFitWidth = YES;
		_value2Field.minimumFontSize = 10;
	}
	return _value2Field;
}

- (UILabel *)valueLabel {
	if (!_valueLabel) {
		_valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(7.0, 0.0, 30.0, 83.0)];
		_valueLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:65.0];
		_valueLabel.translatesAutoresizingMaskIntoConstraints = NO;
	}
	return _valueLabel;
}

- (UILabel *)value2Label {
	if (!_value2Label) {
		_value2Label = [[UILabel alloc] initWithFrame:CGRectMake(7.0, 0.0, 30.0, 83.0)];
		_value2Label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:65.0];
		_value2Label.translatesAutoresizingMaskIntoConstraints = NO;
	}
	return _value2Label;
}

- (void)setupValueViews
{
    if (_inputType == UnitInput_Normal) {
        _valueField.hidden = NO;
        _valueLabel.hidden = YES;
        _value2Field.hidden = YES;
        _value2Label.hidden = YES;
        _valueField.placeholder = @"";
    }
    else if (_inputType == UnitInput_Fraction) {
        _valueField.hidden = NO;
        _valueLabel.hidden = NO;
        _value2Field.hidden = NO;
        _value2Label.hidden = YES;
        _valueLabel.text = @"/";
        _valueLabel.textAlignment = NSTextAlignmentCenter;
        _valueField.placeholder = @"x";
        _value2Field.placeholder = @"y";
    }
    else if (_inputType == UnitInput_FeetInch) {
        _valueField.hidden = NO;
        _valueLabel.hidden = NO;
        _value2Field.hidden = NO;
        _value2Label.hidden = NO;
        _valueLabel.text = @"ft";
        _value2Label.text = @"in";
        _valueLabel.textAlignment = NSTextAlignmentLeft;
        _value2Label.textAlignment = NSTextAlignmentLeft;
        _valueField.placeholder = @"";
        _value2Field.placeholder = @"";
    }
}

- (void)setupTextFieldConstraints {
	_valueFieldWidthConstraint = nil;
	_value2FieldWidthConstraint = nil;

	if (_inputType == UnitInput_Normal) {
        [self addNormalInputConstraints];
    }
    else if (_inputType == UnitInput_Fraction) {
        [self addFractionInputConstraints];
    }
    else if (_inputType == UnitInput_FeetInch) {
        [self addFeetInchInputConstraints];
    }
}

- (UIView *)separatorLineView {
	if (!_separatorLineView) {
		_separatorLineView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 83.0, self.bounds.size.width, 1.0)];
		_separatorLineView.backgroundColor = A3UITableViewSeparatorColor;
		[self addSubview:_separatorLineView];

		[self setupSeparatorConstraint];
	}
	return _separatorLineView;
}

- (void)setupSeparatorConstraint {
	[_separatorLineView makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(self.left);
		make.right.equalTo(self.right);
		make.bottom.equalTo(self.bottom);
		make.height.equalTo(@(1 / [UIScreen mainScreen].scale));
	}];
}

- (void)updateMultiTextFieldModeConstraintsWithEditingTextField:(UITextField *)field {
	[_valueFieldWidthConstraint uninstall];
	[_value2FieldWidthConstraint uninstall];

	CGFloat maxWidth = self.contentView.bounds.size.width * (IS_IPHONE ? 0.65 : 0.8);
	CGFloat valueFieldWidth, value2FieldWidth;
	UIFont *font;
	if (_inputType != UnitInput_Normal) {
		CGFloat fontSize = 66.0, minFontSize = 10.0;
		CGFloat effectiveWidth = maxWidth;
		NSStringDrawingContext *context = [NSStringDrawingContext new];
		CGSize size = CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX);
		while (effectiveWidth >= maxWidth && fontSize >= minFontSize) {
			effectiveWidth = 0.0;
			fontSize -= 1.0;
			font = [UIFont fontWithName:@"HelveticaNeue-Light" size:fontSize];
			NSString *text = [_valueField.text length] ? _valueField.text : _valueField.placeholder;
			NSDictionary *attribute = @{NSFontAttributeName : font};

			CGRect bounds = [text boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin
											attributes:attribute
											   context:context];
			valueFieldWidth = bounds.size.width;
			effectiveWidth += valueFieldWidth;

			bounds = [_valueLabel.text boundingRectWithSize:size
													options:NSStringDrawingUsesLineFragmentOrigin
												 attributes:attribute
													context:context];
			effectiveWidth += bounds.size.width;

			text = [_value2Field.text length] ? _value2Field.text : _value2Field.placeholder;
			bounds = [text boundingRectWithSize:size
										options:NSStringDrawingUsesLineFragmentOrigin
									 attributes:attribute
										context:context];
			value2FieldWidth = bounds.size.width;
			effectiveWidth += value2FieldWidth;

			if ([_valueField isEditing] || [_value2Field isEditing]) {
				bounds = [@"93" boundingRectWithSize:size
											 options:NSStringDrawingUsesLineFragmentOrigin
										  attributes:attribute
											 context:context
				];
				effectiveWidth += bounds.size.width;

				if ([_valueField isEditing]) {
					valueFieldWidth += bounds.size.width;
				} else {
					value2FieldWidth += bounds.size.width;
				}
			}
		}
	} else {
		valueFieldWidth = maxWidth;
		value2FieldWidth = 0.0;
		font = [UIFont fontWithName:@"HelveticaNeue-Light" size:65];
	}

	[_valueField setFont:font];
	[_valueLabel setFont:font];
	[_value2Field setFont:font];
	[_value2Label setFont:font];

	[_valueField makeConstraints:^(MASConstraintMaker *make) {
		_valueFieldWidthConstraint = make.width.equalTo(@(valueFieldWidth));
	}];
	[_value2Field makeConstraints:^(MASConstraintMaker *make) {
		_value2FieldWidthConstraint = make.width.equalTo(@(value2FieldWidth));
	}];

	[self layoutIfNeeded];

	NSString *text;
	if (field != _valueField) {
		text = _valueField.text;
		_valueField.text = @"";
		_valueField.text = text;
	}
	if (field != _value2Field) {
		text = _value2Field.text;
		_value2Field.text = @"";
		_value2Field.text = text;
	}
}

- (void)addNormalInputConstraints {
	[_valueField remakeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(self.contentView.left).with.offset(IS_IPHONE ? 15 : 28);
		make.centerY.equalTo(self.contentView.centerY);
		make.right.equalTo(_codeLabel.left);
		make.height.equalTo(@(_textFieldHeight));
	}];
}

- (void)addFractionInputConstraints {
	[_valueField remakeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(self.contentView.left).with.offset(IS_IPHONE ? 15 : 28);
		make.centerY.equalTo(self.contentView.centerY);
		_valueFieldWidthConstraint = make.width.equalTo(self.contentView.width).with.multipliedBy(IS_IPAD ? 0.4 : 0.3);
		make.height.equalTo(@(_textFieldHeight));
	}];

	[_valueLabel remakeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(_valueField.right);
		make.centerY.equalTo(self.contentView.centerY);
	}];

	[_value2Field remakeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(_valueLabel.right);
		make.centerY.equalTo(self.contentView.centerY);
		_value2FieldWidthConstraint = make.width.lessThanOrEqualTo(self.contentView.width).with.multipliedBy(IS_IPAD ? 0.4 : 0.3);
		make.height.equalTo(@(_textFieldHeight));
	}];
}

- (void)addFeetInchInputConstraints {
	[_valueField remakeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(self.contentView.left).with.offset(IS_IPHONE ? 15 : 28);
		make.centerY.equalTo(self.contentView.centerY).with.offset(-4);
		_valueFieldWidthConstraint = make.width.equalTo(self.contentView.width).with.multipliedBy(0.17);
		make.height.equalTo(@(_textFieldHeight));
	}];
	[_valueLabel remakeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(_valueField.right);
		make.centerY.equalTo(_valueField.centerY);
	}];
	[_value2Field remakeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(_valueLabel.right).with.offset(15);
		make.centerY.equalTo(_valueField.centerY);
		_value2FieldWidthConstraint = make.width.lessThanOrEqualTo(self.contentView.width).with.multipliedBy(IS_IPAD ? 0.4 : 0.3);
		make.height.equalTo(@(_textFieldHeight));
	}];
	[_value2Label remakeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(_value2Field.right);
		make.centerY.equalTo(_valueField.centerY);
	}];
}

- (void)setupConstraintsForRightSideViews {
	[_flagImageView makeConstraints:^(MASConstraintMaker *make) {
		make.centerY.equalTo(self.contentView.centerY);
		make.right.equalTo(_codeLabel.left).with.offset(IS_IPHONE ? 2.0 : 10.0);
	}];

	[_codeLabel makeConstraints:^(MASConstraintMaker *make) {
		make.centerY.equalTo(self.contentView.centerY);
		make.right.equalTo(self.contentView.right);
	}];

	[_rateLabel makeConstraints:^(MASConstraintMaker *make) {
		make.right.equalTo(_codeLabel.right);
		make.bottom.equalTo(self.contentView.bottom).with.offset(-8);
	}];

	[self.touchCoverRectButton makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(self.contentView.left);
		make.top.equalTo(self.contentView.top);
		make.bottom.equalTo(self.contentView.bottom);
		if (IS_IPAD) {
			make.right.equalTo(self.contentView.right).with.offset(-160);
		}
		else {
			make.right.equalTo(self.rateLabel.right).with.offset(-20);
		}
	}];
}

- (UILabel *)codeLabel {
	if (!_codeLabel) {
		_codeLabel = [[UILabel alloc] initWithFrame:CGRectMake(257.0, 52.0, 30.0, 20.0)];
        UIFont *lbFont = (IS_IPAD) ? [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline] : [UIFont systemFontOfSize:15.0];
		_codeLabel.font = lbFont;
		_codeLabel.textColor = [UIColor colorWithRed:159.0 / 255.0 green:159.0 / 255.0 blue:159.0 / 255.0 alpha:1.0];
		_codeLabel.textAlignment = NSTextAlignmentRight;
		_codeLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _codeLabel.adjustsFontSizeToFitWidth = YES;
	}
	return _codeLabel;
}

- (UILabel *)rateLabel {
	if (!_rateLabel) {
		_rateLabel = [[UILabel alloc] initWithFrame:CGRectMake(163.0, 75.0, 124.0, 21.0)];
        UIFont *lbFont = (IS_IPAD) ? [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote] : [UIFont systemFontOfSize:13.0];
		_rateLabel.font = lbFont;
		_rateLabel.textColor = [UIColor colorWithRed:142.0 / 255.0 green:142.0 / 255.0 blue:147.0 / 255.0 alpha:1.0];
		_rateLabel.textAlignment = NSTextAlignmentRight;
		_rateLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _rateLabel.adjustsFontSizeToFitWidth = YES;
	}
	return _rateLabel;
}

- (UIImageView *)flagImageView {
	if (!_flagImageView) {
		_flagImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"flag_us"]];
		_flagImageView.frame = CGRectMake(225.0, 54.0, 24.0, 24.0);
		_flagImageView.translatesAutoresizingMaskIntoConstraints = NO;
	}
	return _flagImageView;
}

- (UIButton *)touchCoverRectButton {
    if (!_touchCoverRectButton) {
        _touchCoverRectButton = [UIButton new];
        _touchCoverRectButton.backgroundColor = [UIColor clearColor];
        _touchCoverRectButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_touchCoverRectButton addTarget:self action:@selector(touchCoverRectButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _touchCoverRectButton;
}
- (void)touchCoverRectButtonAction:(id)sender {
    [_valueField becomeFirstResponder];
}

#pragma mark - label size


#pragma mark - A3TableViewSwipeCellDelegate

- (BOOL)cellShouldShowMenu {
	return YES;
}

- (void)addMenuView:(BOOL)showDelete {
	[self.superview insertSubview:[self menuView:showDelete ] belowSubview:self];
	if ([_menuDelegate respondsToSelector:@selector(menuAdded)]) {
		[_menuDelegate menuAdded];
	}
}

- (void)removeMenuView {
	[_menuView removeFromSuperview];
	_menuView = nil;
}

- (CGFloat)menuWidth:(BOOL)showDelete {
	return showDelete ? 80.0 * 3 : 80.0 * 2;
}

- (UIView *)menuView:(BOOL)showDelete {
	if (_menuView) {
		return _menuView;
	}
	CGRect frame = self.frame;
	frame.origin.x = frame.size.width - [self menuWidth:showDelete];
	frame.size.width = [self menuWidth:showDelete];
	_menuView = [[UIView alloc] initWithFrame:frame];
    
	NSArray *menuTitles = @[NSLocalizedString(@"Swap", @"Swap"), NSLocalizedString(@"Share", @"Share"), NSLocalizedString(@"Delete", @"Delete")];
    
	[menuTitles enumerateObjectsUsingBlock:^(NSString *title, NSUInteger idx, BOOL *stop) {
		if (!showDelete && idx == 2) return;

		UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
		[button setTitle:title forState:UIControlStateNormal];
		[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		if (idx == 2) {
			[button setBackgroundColor:[UIColor colorWithRed:255.0/255.0 green:59.0/255.0 blue:48.0/255.0 alpha:1.0]];
		} else {
			[button setBackgroundColor:[UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0]];
		}
		button.frame = CGRectMake(idx * 80.0, 0.0, 80.0, 84.0);
		button.tag = idx;
        [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
		[_menuView addSubview:button];
	}];
    
	return _menuView;
}

- (void)buttonPressed:(UIButton *)button {
	FNLOG(@"%ld", (long)button.tag);
	switch (button.tag) {
		case 0:
			if ([_menuDelegate respondsToSelector:@selector(swapActionForCell:)]) {
				[_menuDelegate swapActionForCell:self];
			}
			break;
        case 1:
			if ([_menuDelegate respondsToSelector:@selector(shareActionForCell:sender:)]) {
				[_menuDelegate shareActionForCell:self sender:button];
			}
			break;
		case 2:
			if ([_menuDelegate respondsToSelector:@selector(deleteActionForCell:)]) {
				[_menuDelegate deleteActionForCell:self];
			}
			break;
		default:
			break;
	}
}

@end

