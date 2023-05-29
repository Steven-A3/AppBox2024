//
//  A3WalletItemFieldCell.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 23..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <AppBoxKit/AppBoxKit.h>
#import "A3WalletItemFieldCell.h"
#import "UIImage+imageWithColor.h"
#import "WalletFieldItem.h"
#import "WalletField.h"
#import "NSString+WalletStyle.h"

@implementation A3WalletItemFieldCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)awakeFromNib
{
    [super awakeFromNib];

	CGFloat leading = IS_IPHONE ? ([[UIScreen mainScreen] scale] > 2 ? 20 : 15) : 28;
	_valueTextField.adjustsFontSizeToFitWidth = YES;
	_valueTextField.minimumFontSize = 4.0;
	
	[_valueTextField makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(self.left).with.offset(leading);
		make.centerY.equalTo(self.centerY);
		make.right.equalTo(self.right).with.offset(-leading);
		make.height.equalTo(@50);
	}];
}

- (void)addDeleteButton {
	if (!_deleteButton) {
		_deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[_deleteButton setImage:[[UIImage imageNamed:@"delete03"] tintedImageWithColor:[UIColor colorWithRed:204.0 / 255.0 green:204.0 / 255.0 blue:204.0 / 255.0 alpha:1.0]] forState:UIControlStateNormal];
		[self addSubview:_deleteButton];

		[_deleteButton makeConstraints:^(MASConstraintMaker *make) {
			make.right.equalTo(self.right).with.offset(-7.5);
			make.centerY.equalTo(self.centerY);
			make.width.equalTo(@44);
			make.height.equalTo(@44);
		}];
	}
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
	[_deleteButton removeFromSuperview];
	_deleteButton = nil;
    [_showHideButton removeFromSuperview];
    _showHideButton = nil;
}

- (void)addShowHideButton {
	if (!_showHideButton) {
		_showHideButton = [UIButton buttonWithType:UIButtonTypeSystem];
		[_showHideButton setTitle:[_fieldStyleStatus[_fieldItem.uniqueID] boolValue] ? NSLocalizedString(@"Hide", @"Hide") : NSLocalizedString(@"Show", @"Show") forState:UIControlStateNormal];
		[_showHideButton addTarget:self action:@selector(showHideButtonAction) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_showHideButton];

		[_showHideButton makeConstraints:^(MASConstraintMaker *make) {
			make.right.equalTo(self.right).with.offset(-15);
			make.top.equalTo(self.top).with.offset(5);
		}];
	}
}

- (void)showHideButtonAction {
	_fieldStyleStatus[_fieldItem.uniqueID] = [_fieldStyleStatus[_fieldItem.uniqueID] boolValue] ? @NO : @YES;
	if ([_fieldStyleStatus[_fieldItem.uniqueID] boolValue]) {
		_valueTextField.text = _fieldItem.value;
	} else {
		_valueTextField.text = [_fieldItem.value stringForStyle:_fieldStyle];
	}
	[_showHideButton setTitle:[_fieldStyleStatus[_fieldItem.uniqueID] boolValue] ? NSLocalizedString(@"Hide", @"Hide") : NSLocalizedString(@"Show", @"Show") forState:UIControlStateNormal];
}

@end
