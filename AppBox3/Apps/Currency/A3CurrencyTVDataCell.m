//
//  A3CurrencyTVDataCell.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 7/18/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3CurrencyTVDataCell.h"
#import "A3UIDevice.h"
#import "common.h"

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
		[self addSubview:self.separatorLineView];
		[self addConstraints];
    }
    return self;
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
    
	NSDictionary *views = NSDictionaryOfVariableBindings(_valueField, _codeLabel, _rateLabel, _flagImageView, _separatorLineView);
	[self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-7-[_valueField(187)]" options:0 metrics:nil views:views]];
	[self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_valueField attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];

	[self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_flagImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];

	[self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_codeLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];

	[self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[_flagImageView]-8-[_codeLabel]-2-|" options:0 metrics:nil views:views]];
	[self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_rateLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_codeLabel attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0]];

	[self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_codeLabel]-2-[_rateLabel]-8-|" options:0 metrics:nil views:views]];

	[self addConstraint:[NSLayoutConstraint constraintWithItem:_separatorLineView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]];
	[self addConstraint:[NSLayoutConstraint constraintWithItem:_separatorLineView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_separatorLineView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
	[self addConstraint:[NSLayoutConstraint constraintWithItem:_separatorLineView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-1.0]];
	[self addConstraint:[NSLayoutConstraint constraintWithItem:_separatorLineView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:1.0]];
}

- (UILabel *)codeLabel {
	if (!_codeLabel) {
		_codeLabel = [[UILabel alloc] initWithFrame:CGRectMake(257.0, 52.0, 30.0, 20.0)];
		_codeLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
		_codeLabel.textColor = [UIColor colorWithRed:159.0 / 255.0 green:159.0 / 255.0 blue:159.0 / 255.0 alpha:1.0];
		_codeLabel.textAlignment = NSTextAlignmentRight;
		_codeLabel.translatesAutoresizingMaskIntoConstraints = NO;
	}
	return _codeLabel;
}

- (UILabel *)rateLabel {
	if (!_rateLabel) {
		_rateLabel = [[UILabel alloc] initWithFrame:CGRectMake(163.0, 75.0, 124.0, 21.0)];
		_rateLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
		_rateLabel.textColor = [UIColor colorWithRed:142.0 / 255.0 green:142.0 / 255.0 blue:147.0 / 255.0 alpha:1.0];
		_rateLabel.textAlignment = NSTextAlignmentRight;
		_rateLabel.translatesAutoresizingMaskIntoConstraints = NO;
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

- (UIView *)separatorLineView {
	if (!_separatorLineView) {
		_separatorLineView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 83.0, self.bounds.size.width, 1.0)];
		_separatorLineView.backgroundColor = [UIColor clearColor];
		_separatorLineView.translatesAutoresizingMaskIntoConstraints = NO;
	}
	return _separatorLineView;
}

#pragma mark - A3TableViewSwipeCellDelegate

- (void)addMenuView {
	[self.superview insertSubview:self.menuView belowSubview:self];
}

- (void)removeMenuView {
	[self.menuView removeFromSuperview];
	_menuView = nil;
}

- (CGFloat)menuWidth {
	return 288.0;
}

- (UIView *)menuView {
	if (_menuView) {
		return _menuView;
	}
	CGRect frame = self.frame;
	frame.origin.x = frame.size.width - self.menuWidth;
	frame.size.width = self.menuWidth;
	_menuView = [[UIView alloc] initWithFrame:frame];

	NSArray *menuTitles = @[@"Swap", @"Chart", @"Share", @"Delete"];

	[menuTitles enumerateObjectsUsingBlock:^(NSString *title, NSUInteger idx, BOOL *stop) {
		UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
		[button setTitle:title forState:UIControlStateNormal];
		[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		if (idx == 3) {
			[button setBackgroundColor:[UIColor colorWithRed:255.0/255.0 green:59.0/255.0 blue:48.0/255.0 alpha:1.0]];
		} else {
			[button setBackgroundColor:[UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0]];
		}
		button.frame = CGRectMake(idx * 72.0, 0.0, 72.0, 84.0);
        [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
		[_menuView addSubview:button];
	}];

	return _menuView;
}

- (void)buttonPressed:(UIButton *)button {
    FNLOG();
}

@end
