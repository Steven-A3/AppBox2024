//
//  A3CurrencyTVDataCell.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 7/18/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3CurrencyTVDataCell.h"

@interface A3CurrencyTVDataCell ()
@property (nonatomic, strong) UIView *menuView;
@end

@implementation A3CurrencyTVDataCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
		// Initialization code
        self.frame = CGRectMake(0.0, 0.0, 320.0, 84);
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
		[self.contentView addSubview:self.valueField];
		[self.contentView addSubview:self.codeLabel];
		[self.contentView addSubview:self.rateLabel];
		[self.contentView addSubview:self.flagImageView];
		[self useDynamicType];
		[self addConstraints];
    }
    return self;
}

- (void)prepareForReuse {
	[super prepareForReuse];

	[self useDynamicType];
}

- (void)useDynamicType {
    if (IS_IPAD) {
        self.codeLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        self.rateLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    }
}

- (CGSize)sizeThatFits:(CGSize)size {
	return [self intrinsicContentSize];
}

- (CGSize)intrinsicContentSize {
	if (IS_IPAD) {
		return CGSizeMake(714.0, 84.0);
	} else {
        return CGSizeMake(320.0, 84.0);
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (UITextField *)valueField {
	if (!_valueField) {
		_valueField = [[UITextField alloc] initWithFrame:CGRectMake(7.0, 0.0, 187.0, 83.0)];
		_valueField.borderStyle = UITextBorderStyleNone;
		_valueField.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:65.0];
		_valueField.adjustsFontSizeToFitWidth = YES;
		_valueField.minimumFontSize = 10.0;
		_valueField.translatesAutoresizingMaskIntoConstraints = NO;
	}
	return _valueField;
}

- (void)addConstraints {
    
	[_valueField makeConstraints:^(MASConstraintMaker *make) {
		make.centerY.equalTo(self.centerY);
		make.left.equalTo(self.contentView.left).with.offset(IS_IPHONE ? 15 : 28);
		make.width.equalTo(self.contentView.width).with.multipliedBy(IS_IPAD ? 0.8 : 0.78).with.offset(IS_IPHONE ? -15 : -28);
	}];

	[_flagImageView makeConstraints:^(MASConstraintMaker *make) {
		make.centerY.equalTo(self.centerY);
		make.right.equalTo(_codeLabel.left).with.offset(IS_IPHONE ? -2.0 : -10.0);
	}];

	[_codeLabel makeConstraints:^(MASConstraintMaker *make) {
		make.centerY.equalTo(self.centerY);
		_rightMargin = make.right.equalTo(self.contentView.right);
	}];

	[_rateLabel makeConstraints:^(MASConstraintMaker *make) {
		make.right.equalTo(_codeLabel.right);
		make.baseline.equalTo(self.bottom).with.offset(IS_IPHONE ? -6 : -10);
	}];
}

- (UILabel *)codeLabel {
	if (!_codeLabel) {
		_codeLabel = [[UILabel alloc] initWithFrame:CGRectMake(257.0, 52.0, 30.0, 20.0)];
		_codeLabel.font = IS_IPHONE ? [UIFont systemFontOfSize:15] : [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
		_codeLabel.textColor = [UIColor colorWithRed:159.0 / 255.0 green:159.0 / 255.0 blue:159.0 / 255.0 alpha:1.0];
		_codeLabel.textAlignment = NSTextAlignmentRight;
		_codeLabel.translatesAutoresizingMaskIntoConstraints = NO;
	}
	return _codeLabel;
}

- (UILabel *)rateLabel {
	if (!_rateLabel) {
		_rateLabel = [[UILabel alloc] initWithFrame:CGRectMake(163.0, 75.0, 124.0, 21.0)];
		_rateLabel.font = IS_IPHONE ? [UIFont systemFontOfSize:13] : [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
		_rateLabel.textColor = [UIColor colorWithRed:142.0 / 255.0 green:142.0 / 255.0 blue:147.0 / 255.0 alpha:1.0];
		_rateLabel.textAlignment = NSTextAlignmentRight;
		_rateLabel.translatesAutoresizingMaskIntoConstraints = NO;
	}
	return _rateLabel;
}

- (UIImageView *)flagImageView {
	if (!_flagImageView) {
		// TODO: Flag image names
		_flagImageView = [UIImageView new];
		_flagImageView.frame = CGRectMake(225.0, 54.0, 24.0, 24.0);
		_flagImageView.translatesAutoresizingMaskIntoConstraints = NO;
	}
	return _flagImageView;
}

- (UIView *)separatorLineView {
	if (!_separatorLineView) {
		_separatorLineView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 83.0, self.bounds.size.width, 1.0)];
		_separatorLineView.backgroundColor = [UIColor clearColor];
		_separatorLineView.translatesAutoresizingMaskIntoConstraints = NO;
	}
	return _separatorLineView;
}

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
	[[self menuView:NO ] removeFromSuperview];
	_menuView = nil;
}

- (CGFloat)menuWidth:(BOOL)showDelete {
	return showDelete ? 80.0 * 4 : 80.0 * 3;
}

- (UIView *)menuView:(BOOL)showDelete {
	if (_menuView) {
		return _menuView;
	}
	CGRect frame = self.frame;
	frame.origin.x = frame.size.width - [self menuWidth:showDelete ];
	frame.size.width = [self menuWidth:showDelete ];
	_menuView = [[UIView alloc] initWithFrame:frame];

	NSArray *menuTitles = @[
			NSLocalizedString(@"Swap", @"Swap"),
			NSLocalizedString(@"Chart", @"Chart"),
			NSLocalizedString(@"Share", @"Share"),
			NSLocalizedString(@"Delete", @"Delete")
	];

	[menuTitles enumerateObjectsUsingBlock:^(NSString *title, NSUInteger idx, BOOL *stop) {
		if (!showDelete && idx == 3) return;

		UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
		[button setTitle:title forState:UIControlStateNormal];
		[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		if (idx == 3) {
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
			if ([_menuDelegate respondsToSelector:@selector(chartActionForCell:)]) {
				[_menuDelegate chartActionForCell:self];
			}
			break;
		case 2:
			if ([_menuDelegate respondsToSelector:@selector(shareActionForCell:sender:)]) {
				[_menuDelegate shareActionForCell:self sender:button];
			}
			break;
		case 3:
			if ([_menuDelegate respondsToSelector:@selector(deleteActionForCell:)]) {
				[_menuDelegate deleteActionForCell:self];
			}
			break;
		default:
			break;
	}
}

@end
