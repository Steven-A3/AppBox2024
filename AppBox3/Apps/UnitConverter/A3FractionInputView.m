//
//  A3FractionInputView.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 10. 24..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3FractionInputView.h"
#import "A3UIDevice.h"
#import "common.h"

@interface A3FractionInputView ()
@property (nonatomic, strong) UILabel *divideLb;
@end

@implementation A3FractionInputView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.backgroundColor = [UIColor clearColor];
        
        [self addSubview:self.numField];
		[self addSubview:self.denumField];
		[self addSubview:self.divideLb];
		[self addConstraints];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)addConstraints {
    
	NSDictionary *views = NSDictionaryOfVariableBindings(_numField, _denumField, _divideLb);
	NSNumber *leftMargin = @(IS_IPHONE ? 15.0 : 28.0);
	NSNumber *marginBetweenFlagCode = @(IS_IPHONE ? 2.0 : 10.0);
    
	// num Field
	[self addConstraint:[NSLayoutConstraint	constraintWithItem:_numField
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.0
                                                                  constant:0.0]];
    
	[self addConstraint:[NSLayoutConstraint	constraintWithItem:_numField
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self
                                                                 attribute:NSLayoutAttributeLeft
                                                                multiplier:1.0
                                                                  constant:0.0]];
    
	// divide label
    
    [self addConstraint:[NSLayoutConstraint	constraintWithItem:_divideLb
                                                     attribute:NSLayoutAttributeLeft
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:_numField
                                                     attribute:NSLayoutAttributeRight
                                                    multiplier:1.0  constant:leftMargin.floatValue]];
    
    // num Field
	[self addConstraint:[NSLayoutConstraint	constraintWithItem:_denumField
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0
                                                      constant:0.0]];
    
	[self addConstraint:[NSLayoutConstraint	constraintWithItem:_denumField
                                                     attribute:NSLayoutAttributeRight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeRight
                                                    multiplier:1.0
                                                      constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_numField
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:_denumField
                                                     attribute:NSLayoutAttributeWidth
                                                    multiplier:1
                                                      constant:0]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_divideLb(==30)]"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_divideLb)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[_numField]-8-[_divideLb]-8-[_denumField]|"
																			 options:0
																			 metrics:NSDictionaryOfVariableBindings(marginBetweenFlagCode)
																			   views:views]];
}

- (UITextField *)numField
{
    if (!_numField) {
		_numField = [[UITextField alloc] initWithFrame:CGRectMake(0.0, 0.0, 50.0, 83.0)];
        _numField.placeholder = @"x";
		_numField.borderStyle = UITextBorderStyleNone;
		_numField.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:40.0];
		_numField.adjustsFontSizeToFitWidth = YES;
		_numField.minimumFontSize = 10.0;
        _numField.backgroundColor = [UIColor clearColor];
		_numField.textColor = [UIColor colorWithRed:1.0 / 255.0 green:122.0 / 255.0 blue:255.0 / 255.0 alpha:1.0];
		_numField.translatesAutoresizingMaskIntoConstraints = NO;
	}
	return _numField;
}

- (UITextField *)denumField
{
    if (!_denumField) {
		_denumField = [[UITextField alloc] initWithFrame:CGRectMake(0.0, 0.0, 50.0, 83.0)];
        _denumField.placeholder = @"y";
		_denumField.borderStyle = UITextBorderStyleNone;
		_denumField.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:40.0];
		_denumField.adjustsFontSizeToFitWidth = YES;
		_denumField.minimumFontSize = 10.0;
        _denumField.backgroundColor = [UIColor clearColor];
        _denumField.textColor = [UIColor colorWithRed:1.0 / 255.0 green:122.0 / 255.0 blue:255.0 / 255.0 alpha:1.0];
		_denumField.translatesAutoresizingMaskIntoConstraints = NO;
	}
	return _denumField;
}

- (UILabel *)divideLb
{
    if (!_divideLb) {
		_divideLb = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 30.0, 83.0)];
		_divideLb.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:40.0];
		_divideLb.textColor = [UIColor colorWithRed:1.0 / 255.0 green:122.0 / 255.0 blue:255.0 / 255.0 alpha:1.0];
		_divideLb.textAlignment = NSTextAlignmentCenter;
        _divideLb.backgroundColor = [UIColor clearColor];
		_divideLb.translatesAutoresizingMaskIntoConstraints = NO;
        _divideLb.text = @"/";
	}
	return _divideLb;
}

@end
