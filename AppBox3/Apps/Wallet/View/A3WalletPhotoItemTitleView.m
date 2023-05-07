//
//  A3WalletPhotoItemTitleView.m
//  A3TeamWork
//
//  Created by kihyunkim on 2014. 1. 8..
//  Copyright (c) 2014년 ALLABOUTAPPS. All rights reserved.
//

#import "A3WalletPhotoItemTitleView.h"
#import "A3AppDelegate+appearance.h"
#import "UIImage+imageWithColor.h"
#import "UIViewController+tableViewStandardDimension.h"
#import "A3UIDevice.h"

@implementation A3WalletPhotoItemTitleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
	[super awakeFromNib];

	if (IS_IPHONE) {
		self.timeLabel.textColor = [UIColor colorWithRed:142.0/255.0 green:142.0/255.0 blue:147.0/255.0 alpha:1.0];
	}

	[self addSubview:self.favoriteButton];

	[_favoriteButton setImage:[[UIImage imageNamed:@"star02"] tintedImageWithColor:[A3AppDelegate instance].themeColor] forState:UIControlStateNormal];
	[_favoriteButton setImage:[[UIImage imageNamed:@"star02_on"] tintedImageWithColor:[A3AppDelegate instance].themeColor] forState:UIControlStateSelected];

	CGFloat leading = IS_IPHONE ? ([[UIScreen mainScreen] scale] > 2 ? 20 : 15) : 28;

	[_titleTextField makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(self.top).with.offset(22);
		make.left.equalTo(self.left).with.offset(leading);
	}];
	[_timeLabel makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(_titleTextField.bottom);
		make.left.equalTo(self.left).with.offset(leading);
	}];
	[_favoriteButton makeConstraints:^(MASConstraintMaker *make) {
		make.width.equalTo(@44);
		make.height.equalTo(@44);
		make.left.equalTo(_titleTextField.right).with.offset(-7);
		make.centerY.equalTo(_titleTextField.centerY).with.offset(-3);
	}];
	[_mediaSizeLabel makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(_timeLabel.bottom).with.offset(11);
		make.left.equalTo(self.left).with.offset(leading);
	}];
	[_takenDateLabel makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(_mediaSizeLabel.bottom);
		make.left.equalTo(self.left).with.offset(leading);
	}];

	[self setupFonts];
}

- (UIButton *)favoriteButton
{
	if (!_favoriteButton) {
		_favoriteButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
		[_favoriteButton setContentMode:UIViewContentModeRight];
		[_favoriteButton setImage:[UIImage imageNamed:@"star02"] forState:UIControlStateNormal];
		[_favoriteButton setImage:[UIImage imageNamed:@"star02_on"] forState:UIControlStateSelected];
	}

	return _favoriteButton;
}

- (void)setupFonts {
	_titleTextField.font = IS_IPAD ? [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline] : [UIFont boldSystemFontOfSize:17.0];
	_timeLabel.font = IS_IPAD ? [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote] : [UIFont systemFontOfSize:13.0];
	_mediaSizeLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
	_takenDateLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
}

- (CGFloat)calculatedHeight {
	CGFloat height = 22.0;
	NSStringDrawingContext *context = [NSStringDrawingContext new];
	height += [self heightOfObject:_titleTextField context:context];
	height += [self heightOfObject:_timeLabel context:context];
	height += [self heightOfObject:_mediaSizeLabel context:context];
	height += [self heightOfObject:_takenDateLabel context:context];
	height += [_mediaSizeLabel.text length] ? 11 + 13 : 18;
	return height;
}

- (CGFloat)heightOfObject:(id)object context:(NSStringDrawingContext *)context {
	NSString *text = [object valueForKey:@"text"];
	if (![text length]) return 0.0;
	UIFont *font = [object valueForKey:@"font"];
	return [text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : font} context:context].size.height;
}

- (UIButton *)saveButton {
	if (!_saveButton) {
		_saveButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
		[_saveButton setImage:[[UIImage imageNamed:@"share"] tintedImageWithColor:[A3AppDelegate instance].themeColor] forState:UIControlStateNormal];
	}
	return _saveButton;
}

- (void)addSaveButton {
	[self addSubview:self.saveButton];
	[_saveButton makeConstraints:^(MASConstraintMaker *make) {
		make.centerY.equalTo(self.favoriteButton.centerY);
		make.right.equalTo(self.right).with.offset(-10);
	}];
}

@end
