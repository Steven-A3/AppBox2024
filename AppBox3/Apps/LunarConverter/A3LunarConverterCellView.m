//
//  A3LunarConverterCellView.m
//  A3TeamWork
//
//  Created by coanyaa on 13. 10. 14..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3LunarConverterCellView.h"

@interface A3LunarConverterCellView ()
@property (nonatomic, strong) NSMutableArray *constraints;
@end

@implementation A3LunarConverterCellView

- (NSMutableArray *)constraints {
	if (!_constraints) {
		_constraints = [NSMutableArray new];
	}
	return _constraints;
}

- (void)addPhoneLayoutConstraints
{
	BOOL isIPHONE35 = IS_IPHONE35;
	[_dateLabel makeConstraints:^(MASConstraintMaker *make) {
		[self.constraints addObject:make.left.equalTo(self.left).with.offset(15)];
		//[self.constraints addObject:make.right.equalTo(self.right).with.offset(_actionButton ? -(40) : -15)];
        [self.constraints addObject:make.right.equalTo(self.right).with.offset(-15)];
		[self.constraints addObject:make.baseline.equalTo(self.top).with.offset(isIPHONE35 ? 32 : 37)];
	}];

	[_descriptionLabel makeConstraints:^(MASConstraintMaker *make) {
		[self.constraints addObject:make.left.equalTo(self.left).with.offset(15)];
		[self.constraints addObject:make.right.equalTo(self.right).with.offset(-15)];
		[self.constraints addObject:make.baseline.equalTo(self.bottom).with.offset(isIPHONE35 ? -10 : -16)];
	}];

	if ( _actionButton ) {
		[_actionButton makeConstraints:^(MASConstraintMaker *make) {
			[self.constraints addObject:make.width.equalTo(@44)];
			[self.constraints addObject:make.height.equalTo(@44)];
			[self.constraints addObject:make.centerY.equalTo(_dateLabel.centerY)];
			[self.constraints addObject:make.right.equalTo(self.right).with.offset(-3)];
		}];
	}
}

- (void)addPadLayoutConstraints
{
	[_dateLabel makeConstraints:^(MASConstraintMaker *make) {
		[self.constraints addObject:make.left.equalTo(self.left).with.offset(28)];
		[self.constraints addObject:make.right.equalTo(self.right).with.offset(-100)];
		[self.constraints addObject:make.centerY.equalTo(self.centerY)];
	}];

	if (_actionButton) {
		[_actionButton makeConstraints:^(MASConstraintMaker *make) {
			[self.constraints addObject:make.width.equalTo(@44)];
			[self.constraints addObject:make.height.equalTo(@44)];
			[self.constraints addObject:make.centerY.equalTo(self.centerY)];
			[self.constraints addObject:make.right.equalTo(self.right).with.offset(-3)];
		}];
	}
	[_descriptionLabel makeConstraints:^(MASConstraintMaker *make) {
		make.centerY.equalTo(self.centerY);
//		if (_actionButton) {
//			[self.constraints addObject:make.right.equalTo(_actionButton.left)];
//		} else {
//			[self.constraints addObject:make.right.equalTo(self.right).with.offset(-15)];
//		}
        [self.constraints addObject:make.right.equalTo(self.right).with.offset(-15)];
	}];
}

- (void)constructView
{
	FNLOG();
	for (MASConstraint *constraint in _constraints) {
		[constraint uninstall];
	}
	[_constraints removeAllObjects];

    if ( _dateLabel == nil ) {
        _dateLabel = [UILabel new];
        _dateLabel.font = [UIFont systemFontOfSize:30.0];
        _dateLabel.adjustsFontSizeToFitWidth = YES;
        _dateLabel.numberOfLines = 1;
        _dateLabel.minimumScaleFactor = 0.3f;
        _dateLabel.textAlignment = NSTextAlignmentLeft;
        _dateLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self addSubview:_dateLabel];
    }
    
    if ( _descriptionLabel == nil ) {
        _descriptionLabel = [UILabel new];
        _descriptionLabel.font = IS_IPHONE ? [UIFont systemFontOfSize:15.0] : [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        _descriptionLabel.textAlignment = (IS_IPAD ? NSTextAlignmentRight : NSTextAlignmentLeft);
        [self addSubview:_descriptionLabel];
    }
    
    if (IS_IPAD) {
        [self addPadLayoutConstraints];
    } else {
        [self addPhoneLayoutConstraints];
    }
    
    _actionButton.hidden = YES;
}

- (void)awakeFromNib
{
    [self constructView];
}

- (void)setActionButton:(UIButton *)actionButton
{
	for (MASConstraint *constraint in _constraints) {
		[constraint uninstall];
	}
	[_constraints removeAllObjects];

    if ( _actionButton ) {
        [_actionButton removeFromSuperview];
        _actionButton = nil;
    }
    _actionButton = actionButton;
    [self addSubview:_actionButton];
    [self constructView];
}

@end
