//
//  A3WalletNoteCell.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 12. 26..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3WalletNoteCell.h"
#import "UIViewController+tableViewStandardDimension.h"

@implementation A3WalletNoteCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib {
	[super awakeFromNib];

	[self setupTextView];
}

- (void)setupTextView {
	if (!_textView) {
		_textView = [GCPlaceholderTextView new];
		[self.contentView addSubview:_textView];
	}
	self.selectionStyle = UITableViewCellSelectionStyleNone;
	_textView.bounces = NO;
	_textView.textColor = [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
	_textView.placeholderColor = [UIColor colorWithRed:199.0/255.0 green:199.0/255.0 blue:205.0/255.0 alpha:1.0];

	_textView.placeholder = NSLocalizedString(@"Notes", @"Notes");
	_textView.font = [UIFont systemFontOfSize:17];

	[_textView makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(self.top).with.offset(3);
		make.bottom.equalTo(self.bottom).with.offset(-3);
		make.left.equalTo(self.left).with.offset(IS_IPHONE || _keepShortInset ? ([[UIScreen mainScreen] scale] > 2 ? 15 : 10) : 23);
		make.right.equalTo(self.right).with.offset(IS_IPHONE || _keepShortInset ? -10 : -23);
	}];
}

- (void)setNoteText:(NSString *)text {
	_textView.text = text;

	[self calculatedHeight];
}

- (CGFloat)calculatedHeight {
	CGRect frame = _textView.frame;
	frame.origin.y = 3.0;
	frame.origin.x = IS_IPHONE || _keepShortInset ? 10 : 23;
	CGRect screenBounds = [A3UIDevice screenBoundsAdjustedWithOrientation];
	frame.size.width = screenBounds.size.width - (IS_IPHONE || _keepShortInset ? 10 : 23) * 2;
	[_textView.layoutManager ensureLayoutForTextContainer:_textView.textContainer];
	frame.size.height = MAX(180, [_textView.layoutManager usedRectForTextContainer:_textView.textContainer].size.height + 25.0);
	_textView.frame = frame;

	return _textView.frame.size.height;
}

- (void)showTopSeparator:(BOOL)show {
	if (!_topSeparator) {
		_topSeparator = [UIView new];
		_topSeparator.backgroundColor = A3UITableViewSeparatorColor;
		[self addSubview:_topSeparator];

		CGFloat leading = [[UIScreen mainScreen] scale] > 2 ? 20 : 15;
		[_topSeparator makeConstraints:^(MASConstraintMaker *make) {
			make.left.equalTo(self.left).with.offset(IS_IPHONE || _keepShortInset ? leading : 28);
			make.right.equalTo(self.right);
			make.top.equalTo(self.top);
			make.height.equalTo(IS_RETINA ? @0.5 : @1.0);
		}];
		[self layoutIfNeeded];
	}
	[_topSeparator setHidden:!show];
}

@end
