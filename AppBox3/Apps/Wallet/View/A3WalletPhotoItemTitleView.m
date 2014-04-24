//
//  A3WalletPhotoItemTitleView.m
//  A3TeamWork
//
//  Created by kihyunkim on 2014. 1. 8..
//  Copyright (c) 2014년 ALLABOUTAPPS. All rights reserved.
//

#import "A3WalletPhotoItemTitleView.h"

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

	[_titleTextField makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(self.top).with.offset(22);
		make.left.equalTo(self.left).with.offset(IS_IPHONE ? 15 : 28);
		make.right.equalTo(_favoriteButton.left).with.offset(5);
	}];
	[_timeLabel makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(_titleTextField.bottom);
		make.left.equalTo(self.left).with.offset(IS_IPHONE ? 15 : 28);
	}];
	[_favoriteButton makeConstraints:^(MASConstraintMaker *make) {
		make.width.equalTo(@40);
		make.height.equalTo(@40);
		make.right.equalTo(self.right).with.offset(-5);
		make.centerY.equalTo(_titleTextField.centerY);
	}];
	[_mediaSizeLabel makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(_timeLabel.bottom).with.offset(11);
		make.left.equalTo(self.left).with.offset(IS_IPHONE ? 15 : 28);
	}];
	[_takenDateLabel makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(_mediaSizeLabel.bottom);
		make.left.equalTo(self.left).with.offset(IS_IPHONE ? 15 : 28);
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

@end
