//
//  A3UnitConverterTVDataCell.m
//  A3TeamWork
//
//  Created by kihyunkim on 13. 10. 13..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3UnitConverterTVDataCell.h"
#import "A3UIDevice.h"
#import "common.h"

@interface A3UnitConverterTVDataCell ()
@property (nonatomic, strong) UIView *menuView;
@end

@implementation A3UnitConverterTVDataCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
		// Initialization code
        self.frame = CGRectMake(0.0, 0.0, 320.0, 84);
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
		[self.contentView addSubview:self.valueField];
        [self.contentView addSubview:self.value2Field];
        [self.contentView addSubview:self.valueLabel];
        [self.contentView addSubview:self.value2Label];
		[self.contentView addSubview:self.codeLabel];
		[self.contentView addSubview:self.rateLabel];
		[self.contentView addSubview:self.flagImageView];
		[self addSubview:self.separatorLineView];
        
		[self useDynamicType];
        
        [self setupValueViews];
		[self addConstraints];
    }
    return self;
}

- (void)prepareForReuse {
	[super prepareForReuse];
    
	[self useDynamicType];
}

- (void)useDynamicType {
	self.codeLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
	self.rateLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
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

- (void)setInputType:(UnitInputType)inputType
{
    if (_inputType != inputType) {
        _inputType = inputType;
        [self setupValueViews];
        [self addConstraints];
        _valueField.text = @"";
        _value2Field.text = @"";
    }
}

- (UITextField *)valueField {
	if (!_valueField) {
		_valueField = [[UITextField alloc] initWithFrame:CGRectMake(7.0, 0.0, 187.0, 83.0)];
		_valueField.borderStyle = UITextBorderStyleNone;
		_valueField.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:65.0];
		_valueField.adjustsFontSizeToFitWidth = YES;
		_valueField.minimumFontSize = 10.0;
		_valueField.translatesAutoresizingMaskIntoConstraints = NO;
        _valueField.tag = 1;
	}
	return _valueField;
}

- (UITextField *)value2Field {
	if (!_value2Field) {
		_value2Field = [[UITextField alloc] initWithFrame:CGRectMake(7.0, 0.0, 187.0, 83.0)];
		_value2Field.borderStyle = UITextBorderStyleNone;
		_value2Field.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:65.0];
		_value2Field.adjustsFontSizeToFitWidth = YES;
		_value2Field.minimumFontSize = 10.0;
		_value2Field.translatesAutoresizingMaskIntoConstraints = NO;
        _value2Field.tag = 2;
	}
	return _value2Field;
}

- (UILabel *)valueLabel {
	if (!_valueLabel) {
		_valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(7.0, 0.0, 30.0, 83.0)];
		_valueLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:65.0];
		_valueLabel.adjustsFontSizeToFitWidth = YES;
		_valueLabel.translatesAutoresizingMaskIntoConstraints = NO;
	}
	return _valueLabel;
}

- (UILabel *)value2Label {
	if (!_value2Label) {
		_value2Label = [[UILabel alloc] initWithFrame:CGRectMake(7.0, 0.0, 30.0, 83.0)];
		_value2Label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:65.0];
		_value2Label.adjustsFontSizeToFitWidth = YES;
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

- (void)addConstraints {
    
    // reset constraints
    [self removeConstraints:self.constraints];
    [self.contentView removeConstraints:self.contentView.constraints];
    
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


- (void)addNormalInputConstraints {
    NSDictionary *views = NSDictionaryOfVariableBindings(_valueField, _value2Field, _valueLabel, _value2Label, _codeLabel, _rateLabel, _flagImageView, _separatorLineView);
	NSNumber *leftMargin = @(IS_IPHONE ? 15.0 : 28.0);
	NSNumber *marginBetweenFlagCode = @(IS_IPHONE ? 2.0 : 10.0);
	NSNumber *VmarginBetweenCodeRate = @(IS_IPHONE ? 4.0 : 4.0);
    
	// Value Field
	[self.contentView addConstraint:[NSLayoutConstraint	constraintWithItem:_valueField
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.0
                                                                  constant:0.0]];
    
	[self.contentView addConstraint:[NSLayoutConstraint	constraintWithItem:_valueField
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeLeft
                                                                multiplier:1.0
                                                                  constant:leftMargin.floatValue]];
    
	[self.contentView addConstraint:[NSLayoutConstraint	constraintWithItem:_valueField
                                                                 attribute:NSLayoutAttributeWidth
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeWidth
                                                                multiplier:IS_IPAD ? 0.8 : 0.6
                                                                  constant:-leftMargin.floatValue]];
    
	// Flag image View
	[self.contentView addConstraint:[NSLayoutConstraint	constraintWithItem:_flagImageView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.0  constant:0.0]];
    
	// Code Label
	[self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_codeLabel
																 attribute:NSLayoutAttributeCenterY
																 relatedBy:NSLayoutRelationEqual
																	toItem:self.contentView
																 attribute:NSLayoutAttributeCenterY
																multiplier:1.0 constant:0.0]];
    
	[self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[_flagImageView]-marginBetweenFlagCode-[_codeLabel]|"
																			 options:0
																			 metrics:NSDictionaryOfVariableBindings(marginBetweenFlagCode)
																			   views:views]];
    
	// Rate Label
	[self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_rateLabel
																 attribute:NSLayoutAttributeRight
																 relatedBy:NSLayoutRelationEqual
																	toItem:_codeLabel
																 attribute:NSLayoutAttributeRight
																multiplier:1.0 constant:0.0]];
    
    // iphone에서는 code/rate label 크기 고정
    if (IS_IPHONE) {
        
        [self.contentView addConstraint:[NSLayoutConstraint	constraintWithItem:_codeLabel
                                                                     attribute:NSLayoutAttributeWidth
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.contentView
                                                                     attribute:NSLayoutAttributeWidth
                                                                    multiplier:0.45
                                                                      constant:-leftMargin.floatValue]];
        
        [self.contentView addConstraint:[NSLayoutConstraint	constraintWithItem:_rateLabel
                                                                     attribute:NSLayoutAttributeWidth
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:_codeLabel
                                                                     attribute:NSLayoutAttributeWidth
                                                                    multiplier:1.0
                                                                      constant:0.0]];
    }
    
	[self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_codeLabel]-VmarginBetweenCodeRate-[_rateLabel]-8-|"
																			 options:0
																			 metrics:NSDictionaryOfVariableBindings(VmarginBetweenCodeRate)
																			   views:views]];
    
	// Separator Line
	[self addConstraint:[NSLayoutConstraint constraintWithItem:_separatorLineView
													 attribute:NSLayoutAttributeWidth
													 relatedBy:NSLayoutRelationEqual
														toItem:self
													 attribute:NSLayoutAttributeWidth
													multiplier:1.0 constant:0.0]];
	[self addConstraint:[NSLayoutConstraint constraintWithItem:_separatorLineView
													 attribute:NSLayoutAttributeCenterX
													 relatedBy:NSLayoutRelationEqual
														toItem:_separatorLineView
													 attribute:NSLayoutAttributeCenterX
													multiplier:1.0 constant:0.0]];
	[self addConstraint:[NSLayoutConstraint constraintWithItem:_separatorLineView
													 attribute:NSLayoutAttributeBottom
													 relatedBy:NSLayoutRelationEqual
														toItem:self
													 attribute:NSLayoutAttributeBottom
													multiplier:1.0 constant:-1.0]];
	[self addConstraint:[NSLayoutConstraint constraintWithItem:_separatorLineView
													 attribute:NSLayoutAttributeHeight
													 relatedBy:NSLayoutRelationEqual
														toItem:nil
													 attribute:NSLayoutAttributeNotAnAttribute
													multiplier:0.0 constant:1.0]];
}

- (void)addFractionInputConstraints {
    NSDictionary *views = NSDictionaryOfVariableBindings(_valueField, _value2Field, _valueLabel, _value2Label, _codeLabel, _rateLabel, _flagImageView, _separatorLineView);
	NSNumber *leftMargin = @(IS_IPHONE ? 15.0 : 28.0);
	NSNumber *marginBetweenFlagCode = @(IS_IPHONE ? 2.0 : 10.0);
	NSNumber *VmarginBetweenCodeRate = @(IS_IPHONE ? 4.0 : 4.0);
    
	// Value Field
	[self.contentView addConstraint:[NSLayoutConstraint	constraintWithItem:_valueField
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.0
                                                                  constant:0.0]];
    
	[self.contentView addConstraint:[NSLayoutConstraint	constraintWithItem:_valueField
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeLeft
                                                                multiplier:1.0
                                                                  constant:leftMargin.floatValue]];
    
    [self.contentView addConstraint:[NSLayoutConstraint	constraintWithItem:_valueField
                                                                 attribute:NSLayoutAttributeWidth
                                                                 relatedBy:NSLayoutRelationLessThanOrEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeWidth
                                                                multiplier:IS_IPAD ? 0.4 : 0.3
                                                                  constant:0.0]];
    
    
    [self.contentView addConstraint:[NSLayoutConstraint	constraintWithItem:_valueLabel
                                                     attribute:NSLayoutAttributeLeft
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:_valueField
                                                     attribute:NSLayoutAttributeRight
                                                    multiplier:1.0  constant:0.0]];
    
    [self.contentView addConstraint:[NSLayoutConstraint	constraintWithItem:_valueLabel
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.0
                                                                  constant:0.0]];
    
    [self.contentView addConstraint:[NSLayoutConstraint	constraintWithItem:_value2Field
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.0
                                                                  constant:0.0]];
    
    [self.contentView addConstraint:[NSLayoutConstraint	constraintWithItem:_value2Field
                                                     attribute:NSLayoutAttributeLeft
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:_valueLabel
                                                     attribute:NSLayoutAttributeRight
                                                    multiplier:1.0
                                                      constant:0]];
    
    [self.contentView addConstraint:[NSLayoutConstraint	constraintWithItem:_value2Field
                                                                 attribute:NSLayoutAttributeWidth
                                                                 relatedBy:NSLayoutRelationLessThanOrEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeWidth
                                                                multiplier:IS_IPAD ? 0.4 : 0.3
                                                                  constant:0.0]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_valueLabel(==30)]"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_valueLabel)]];
    
	// Flag image View
	[self.contentView addConstraint:[NSLayoutConstraint	constraintWithItem:_flagImageView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.0  constant:0.0]];
    
	// Code Label
	[self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_codeLabel
																 attribute:NSLayoutAttributeCenterY
																 relatedBy:NSLayoutRelationEqual
																	toItem:self.contentView
																 attribute:NSLayoutAttributeCenterY
																multiplier:1.0 constant:0.0]];
    
	[self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[_flagImageView]-marginBetweenFlagCode-[_codeLabel]|"
																			 options:0
																			 metrics:NSDictionaryOfVariableBindings(marginBetweenFlagCode)
																			   views:views]];
    
	// Rate Label
	[self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_rateLabel
																 attribute:NSLayoutAttributeRight
																 relatedBy:NSLayoutRelationEqual
																	toItem:_codeLabel
																 attribute:NSLayoutAttributeRight
																multiplier:1.0 constant:0.0]];
    
	[self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_codeLabel]-VmarginBetweenCodeRate-[_rateLabel]-8-|"
																			 options:0
																			 metrics:NSDictionaryOfVariableBindings(VmarginBetweenCodeRate)
																			   views:views]];
    
	// Separator Line
	[self addConstraint:[NSLayoutConstraint constraintWithItem:_separatorLineView
													 attribute:NSLayoutAttributeWidth
													 relatedBy:NSLayoutRelationEqual
														toItem:self
													 attribute:NSLayoutAttributeWidth
													multiplier:1.0 constant:0.0]];
	[self addConstraint:[NSLayoutConstraint constraintWithItem:_separatorLineView
													 attribute:NSLayoutAttributeCenterX
													 relatedBy:NSLayoutRelationEqual
														toItem:_separatorLineView
													 attribute:NSLayoutAttributeCenterX
													multiplier:1.0 constant:0.0]];
	[self addConstraint:[NSLayoutConstraint constraintWithItem:_separatorLineView
													 attribute:NSLayoutAttributeBottom
													 relatedBy:NSLayoutRelationEqual
														toItem:self
													 attribute:NSLayoutAttributeBottom
													multiplier:1.0 constant:-1.0]];
	[self addConstraint:[NSLayoutConstraint constraintWithItem:_separatorLineView
													 attribute:NSLayoutAttributeHeight
													 relatedBy:NSLayoutRelationEqual
														toItem:nil
													 attribute:NSLayoutAttributeNotAnAttribute
													multiplier:0.0 constant:1.0]];
}

- (void)addFeetInchInputConstraints {
    NSDictionary *views = NSDictionaryOfVariableBindings(_valueField, _value2Field, _valueLabel, _value2Label, _codeLabel, _rateLabel, _flagImageView, _separatorLineView);
	NSNumber *leftMargin = @(IS_IPHONE ? 15.0 : 28.0);
	NSNumber *marginBetweenFlagCode = @(IS_IPHONE ? 2.0 : 10.0);
	NSNumber *VmarginBetweenCodeRate = @(IS_IPHONE ? 4.0 : 4.0);
    
	// Value Field
	[self.contentView addConstraint:[NSLayoutConstraint	constraintWithItem:_valueField
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.0
                                                                  constant:0.0]];
    
	[self.contentView addConstraint:[NSLayoutConstraint	constraintWithItem:_valueField
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeLeft
                                                                multiplier:1.0
                                                                  constant:leftMargin.floatValue]];
    
    [self.contentView addConstraint:[NSLayoutConstraint	constraintWithItem:_valueField
                                                                 attribute:NSLayoutAttributeWidth
                                                                 relatedBy:NSLayoutRelationLessThanOrEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeWidth
                                                                multiplier:0.17
                                                                  constant:0.0]];
    
    [self.contentView addConstraint:[NSLayoutConstraint	constraintWithItem:_valueLabel
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:_valueField
                                                                 attribute:NSLayoutAttributeRight
                                                                multiplier:1.0
                                                                  constant:0]];
    
    [self.contentView addConstraint:[NSLayoutConstraint	constraintWithItem:_valueLabel
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.0
                                                                  constant:0.0]];
    
    [self.contentView addConstraint:[NSLayoutConstraint	constraintWithItem:_value2Field
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.0
                                                                  constant:0.0]];
    
    [self.contentView addConstraint:[NSLayoutConstraint	constraintWithItem:_value2Field
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:_valueLabel
                                                                 attribute:NSLayoutAttributeRight
                                                                multiplier:1.0
                                                                  constant:0]];
    
    [self.contentView addConstraint:[NSLayoutConstraint	constraintWithItem:_value2Field
                                                                 attribute:NSLayoutAttributeWidth
                                                                 relatedBy:NSLayoutRelationLessThanOrEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeWidth
                                                                multiplier:0.17
                                                                  constant:0.0]];
    
    [self.contentView addConstraint:[NSLayoutConstraint	constraintWithItem:_value2Label
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:_value2Field
                                                                 attribute:NSLayoutAttributeRight
                                                                multiplier:1.0
                                                                  constant:0]];
    
    [self.contentView addConstraint:[NSLayoutConstraint	constraintWithItem:_value2Label
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.0
                                                                  constant:0.0]];
    
    /*
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_valueField
                                                                 attribute:NSLayoutAttributeWidth
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:_value2Field
                                                                 attribute:NSLayoutAttributeWidth
                                                                multiplier:1
                                                                  constant:0]];
     */
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_valueLabel(==25)]"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(_valueLabel)]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_value2Label(==25)]"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(_value2Label)]];
    
	// Flag image View
	[self.contentView addConstraint:[NSLayoutConstraint	constraintWithItem:_flagImageView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.0  constant:0.0]];
    
	// Code Label
	[self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_codeLabel
																 attribute:NSLayoutAttributeCenterY
																 relatedBy:NSLayoutRelationEqual
																	toItem:self.contentView
																 attribute:NSLayoutAttributeCenterY
																multiplier:1.0 constant:0.0]];
    
	[self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[_flagImageView]-marginBetweenFlagCode-[_codeLabel]|"
																			 options:0
																			 metrics:NSDictionaryOfVariableBindings(marginBetweenFlagCode)
																			   views:views]];
    
	// Rate Label
	[self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_rateLabel
																 attribute:NSLayoutAttributeRight
																 relatedBy:NSLayoutRelationEqual
																	toItem:_codeLabel
																 attribute:NSLayoutAttributeRight
																multiplier:1.0 constant:0.0]];
    
	[self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_codeLabel]-VmarginBetweenCodeRate-[_rateLabel]-8-|"
																			 options:0
																			 metrics:NSDictionaryOfVariableBindings(VmarginBetweenCodeRate)
																			   views:views]];
    
	// Separator Line
	[self addConstraint:[NSLayoutConstraint constraintWithItem:_separatorLineView
													 attribute:NSLayoutAttributeWidth
													 relatedBy:NSLayoutRelationEqual
														toItem:self
													 attribute:NSLayoutAttributeWidth
													multiplier:1.0 constant:0.0]];
	[self addConstraint:[NSLayoutConstraint constraintWithItem:_separatorLineView
													 attribute:NSLayoutAttributeCenterX
													 relatedBy:NSLayoutRelationEqual
														toItem:_separatorLineView
													 attribute:NSLayoutAttributeCenterX
													multiplier:1.0 constant:0.0]];
	[self addConstraint:[NSLayoutConstraint constraintWithItem:_separatorLineView
													 attribute:NSLayoutAttributeBottom
													 relatedBy:NSLayoutRelationEqual
														toItem:self
													 attribute:NSLayoutAttributeBottom
													multiplier:1.0 constant:-1.0]];
	[self addConstraint:[NSLayoutConstraint constraintWithItem:_separatorLineView
													 attribute:NSLayoutAttributeHeight
													 relatedBy:NSLayoutRelationEqual
														toItem:nil
													 attribute:NSLayoutAttributeNotAnAttribute
													multiplier:0.0 constant:1.0]];
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

- (UIView *)separatorLineView {
	if (!_separatorLineView) {
		_separatorLineView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 83.0, self.bounds.size.width, 1.0)];
		_separatorLineView.backgroundColor = [UIColor clearColor];
		_separatorLineView.translatesAutoresizingMaskIntoConstraints = NO;
	}
	return _separatorLineView;
}

#pragma mark - label size


#pragma mark - A3TableViewSwipeCellDelegate

- (void)addMenuView {
	[self.superview insertSubview:self.menuView belowSubview:self];
	if ([_menuDelegate respondsToSelector:@selector(menuAdded)]) {
		[_menuDelegate menuAdded];
	}
}

- (void)removeMenuView {
	[self.menuView removeFromSuperview];
	_menuView = nil;
}

- (CGFloat)menuWidth {
	return 72.0 * 3;
}

- (UIView *)menuView {
	if (_menuView) {
		return _menuView;
	}
	CGRect frame = self.frame;
	frame.origin.x = frame.size.width - self.menuWidth;
	frame.size.width = self.menuWidth;
	_menuView = [[UIView alloc] initWithFrame:frame];
    
	NSArray *menuTitles = @[@"Swap", @"Share", @"Delete"];
    
	[menuTitles enumerateObjectsUsingBlock:^(NSString *title, NSUInteger idx, BOOL *stop) {
		UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
		[button setTitle:title forState:UIControlStateNormal];
		[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		if (idx == 2) {
			[button setBackgroundColor:[UIColor colorWithRed:255.0/255.0 green:59.0/255.0 blue:48.0/255.0 alpha:1.0]];
		} else {
			[button setBackgroundColor:[UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0]];
		}
		button.frame = CGRectMake(idx * 72.0, 0.0, 72.0, 84.0);
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

