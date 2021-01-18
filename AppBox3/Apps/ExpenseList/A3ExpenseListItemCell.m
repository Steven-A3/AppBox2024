//
//  A3ExpenseListItemCell.m
//  A3TeamWork
//
//  Created by jeonghwan kim on 13. 11. 21..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3ExpenseListItemCell.h"
#import "A3UserDefaultsKeys.h"
#import "A3SyncManager.h"
#import "A3SyncManager+NSUbiquitousKeyValueStore.h"

@interface A3ExpenseListItemCell() <UITextFieldDelegate>
@property (nonatomic, strong) UIView *sep1View;
@property (nonatomic, strong) UIView *sep2View;
@property (nonatomic, strong) UIView *sep3View;
@property (nonatomic, strong) MASConstraint *sep1Const;
@property (nonatomic, strong) MASConstraint *sep2Const;
@property (nonatomic, strong) MASConstraint *sep3Const;

@end

@implementation A3ExpenseListItemCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setSelectionStyle:UITableViewCellSelectionStyleDefault];
        [self initializeSubviews];
        [self setupConstraintLayout];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
	[self adjustConstraintLayout];
    [super layoutSubviews];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)initializeSubviews
{
    _sep1View = [[UIView alloc] initWithFrame:CGRectZero];
    _sep2View = [[UIView alloc] initWithFrame:CGRectZero];
    _sep3View = [[UIView alloc] initWithFrame:CGRectZero];
    
    _nameField = [[UITextField alloc] initWithFrame:CGRectZero];
    _priceField = [[UITextField alloc] initWithFrame:CGRectZero];
    _quantityField = [[UITextField alloc] initWithFrame:CGRectZero];
    _subTotalLabel = [[UILabel alloc] initWithFrame:CGRectZero];

    _nameField.delegate = self;
    _priceField.delegate = self;
    _quantityField.delegate = self;
    
    //_nameField.placeholder = @"item";
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    _priceField.placeholder = [formatter stringFromNumber:@0];
    _quantityField.placeholder = @"0";
    
    _sep1View.backgroundColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0];
    _sep2View.backgroundColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0];
    _sep3View.backgroundColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0];

    _nameField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _priceField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _quantityField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _nameField.textAlignment = NSTextAlignmentLeft;
    _priceField.textAlignment = NSTextAlignmentRight;
    _quantityField.textAlignment = NSTextAlignmentCenter;
    _subTotalLabel.textAlignment = NSTextAlignmentRight;
    _nameField.clearButtonMode = UITextFieldViewModeNever;

    [self.contentView addSubview:_sep1View];
    [self.contentView addSubview:_sep2View];
    [self.contentView addSubview:_sep3View];
    [self.contentView addSubview:_nameField];
    [self.contentView addSubview:_priceField];
    [self.contentView addSubview:_quantityField];
    [self.contentView addSubview:_subTotalLabel];
    
    [self setupConstraintLayout];
}

- (void)setupConstraintLayout
{
	CGFloat leftInset = IS_IPHONE ? ([[UIScreen mainScreen] scale] > 2 ? 20 : 15) : 28;
	CGFloat sep1_Item = ceilf(CGRectGetWidth(self.contentView.frame) * 0.33);
	CGFloat sep2_Price = ceilf(CGRectGetWidth(self.contentView.frame) * 0.26);
	CGFloat sep3_Quantity = ceilf(CGRectGetWidth(self.contentView.frame) * 0.11);
    
	[_sep1View makeConstraints:^(MASConstraintMaker *make) {
		self.sep1Const = make.leading.equalTo(@(leftInset + sep1_Item));
		make.top.equalTo(self.contentView.top);
		make.width.equalTo(IS_RETINA? @0.5 : @1);
		make.height.equalTo(self.contentView.height);
	}];
    
	[_sep2View makeConstraints:^(MASConstraintMaker *make) {
		self.sep2Const = make.leading.equalTo(@(leftInset + sep1_Item + sep2_Price));
		make.top.equalTo(self.contentView.top);
		make.width.equalTo(IS_RETINA? @0.5 : @1);
		make.height.equalTo(self.contentView.height);
	}];
    
	[_sep3View makeConstraints:^(MASConstraintMaker *make) {
		self.sep3Const = make.leading.equalTo(@(leftInset + sep1_Item + sep2_Price + sep3_Quantity));
		make.top.equalTo(self.contentView.top);
		make.width.equalTo(IS_RETINA? @0.5 : @1);
		make.height.equalTo(self.contentView.height);
	}];
    
	[_nameField makeConstraints:^(MASConstraintMaker *make) {
		if (IS_IPHONE) {
			make.leading.equalTo(@([[UIScreen mainScreen] scale] > 2 ? 20 : 15));
		} else {
			make.leading.equalTo(@28);
		}
		make.right.equalTo(self.sep1View.left);
        make.centerY.equalTo(self.contentView.centerY);
        make.height.equalTo(@23.0);
    }];
    
    [_priceField makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.sep1View.right);
        make.right.equalTo(self.sep2View.left).with.offset(IS_IPHONE ? -5 : IS_RETINA ? -9.5 : -9);
        make.centerY.equalTo(self.contentView.centerY);
        make.height.equalTo(@23.0);
    }];
    
    [_quantityField makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.sep2View.right);
        make.right.equalTo(self.sep3View.left);
        make.centerY.equalTo(self.contentView.centerY);
        make.height.equalTo(@23.0);
    }];
    
    [_subTotalLabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.sep3View.right);
        make.right.equalTo(self.contentView.right).with.offset(IS_IPHONE ? -5 : IS_RETINA ? -9.5 : -9);
        make.centerY.equalTo(self.contentView.centerY);
        make.height.equalTo(@23.0);
    }];
}

- (void)adjustConstraintLayout
{
	CGFloat leftInset = IS_IPHONE ? ([[UIScreen mainScreen] scale] > 2 ? 20 : 15) : 28;
	CGFloat sep1_Item = ceilf(CGRectGetWidth(self.contentView.frame) * 0.33);
	CGFloat sep2_Price = ceilf(CGRectGetWidth(self.contentView.frame) * 0.26);
	CGFloat sep3_Quantity = ceilf(CGRectGetWidth(self.contentView.frame) * 0.11);
    
	if (IS_IPAD) {
		_nameField.font = [UIFont systemFontOfSize:17.0];
		_priceField.font = [UIFont systemFontOfSize:17.0];
		_quantityField.font = [UIFont systemFontOfSize:17.0];
		_subTotalLabel.font = [UIFont systemFontOfSize:17.0];
	}
	else {
		_nameField.font = [UIFont systemFontOfSize:13.0];
		_priceField.font = [UIFont systemFontOfSize:13.0];
		_quantityField.font = [UIFont systemFontOfSize:13.0];
		_subTotalLabel.font = [UIFont systemFontOfSize:13.0];
	}
    
	_sep1Const.equalTo(@(leftInset + sep1_Item));
	_sep2Const.equalTo(@(leftInset + sep1_Item + sep2_Price));
	_sep3Const.equalTo(@(leftInset + sep1_Item + sep2_Price + sep3_Quantity));
}

#pragma mark - TextField

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
	if ([_delegate respondsToSelector:@selector(cell:textFieldShouldBeginEditing:)]) {
		return [_delegate cell:self textFieldShouldBeginEditing:textField];
	}
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	if ([_delegate respondsToSelector:@selector(cell:textFieldDidBeginEditing:)]) {
		[_delegate cell:self textFieldDidBeginEditing:textField];
	}

}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	if ([_delegate respondsToSelector:@selector(cell:textField:shouldChangeCharactersInRange:replacementString:)]) {
		return [_delegate cell:self textField:textField shouldChangeCharactersInRange:range replacementString:string];
	}
	return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	if ([_delegate respondsToSelector:@selector(cell:textFieldDidEndEditing:)]) {
		[_delegate cell:self textFieldDidEndEditing:textField];
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];

    return YES;
}

@end
