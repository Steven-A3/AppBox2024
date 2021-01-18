//
//  A3WalletItemTitleCell.m
//  AppBox3
//
//  Created by A3 on 4/19/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "A3WalletItemTitleCell.h"
#import "A3AppDelegate+appearance.h"
#import "UIImage+imageWithColor.h"

@implementation A3WalletItemTitleCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
	}
    return self;
}

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	self.selectionStyle = UITableViewCellSelectionStyleNone;

	// Initialization code
	_titleTextField = [UITextField new];
	_titleTextField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
	_titleTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
	[self addSubview:_titleTextField];

	_timeLabel = [UILabel new];
	_timeLabel.textColor = [UIColor colorWithRed:142.0/255.0 green:142.0/255.0 blue:147.0/255.0 alpha:1.0];
	[self addSubview:_timeLabel];

	CGFloat leading = IS_IPHONE ? ([[UIScreen mainScreen] scale] > 2 ? 20 : 15) : 28;
	_favoriteButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[_favoriteButton setImage:[[UIImage imageNamed:@"star02"] tintedImageWithColor:[A3AppDelegate instance].themeColor] forState:UIControlStateNormal];
	[_favoriteButton setImage:[[UIImage imageNamed:@"star02_on"] tintedImageWithColor:[A3AppDelegate instance].themeColor] forState:UIControlStateSelected];
	[self addSubview:_favoriteButton];

	[_titleTextField makeConstraints:^(MASConstraintMaker *make) {
		make.baseline.equalTo(self.bottom).with.offset(-39);
		make.left.equalTo(self.left).with.offset(leading);
		make.right.equalTo(self.favoriteButton.left).with.offset(5);
	}];
	[_favoriteButton makeConstraints:^(MASConstraintMaker *make) {
		make.width.equalTo(@40);
		make.height.equalTo(@40);
		make.right.equalTo(self.right).with.offset(-5);
		make.centerY.equalTo(self.titleTextField.centerY);
	}];
	[_timeLabel makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(self.left).with.offset(leading);
		make.right.equalTo(self.right).with.offset(-leading);
		make.baseline.equalTo(self.bottom).offset(-21);
	}];
	[self setupFonts];
}

- (void)setupFonts {
	_titleTextField.font = IS_IPAD ? [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline] : [UIFont boldSystemFontOfSize:17.0];
	_timeLabel.font = IS_IPAD ? [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote] : [UIFont systemFontOfSize:13.0];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse {
	[super prepareForReuse];

	[self setupFonts];
}

@end
