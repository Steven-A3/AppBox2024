//
//  A3WalletNoteCell.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 12. 26..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3WalletNoteCell.h"

@implementation A3WalletNoteCell

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

- (void)setNoteText:(NSString *)text {
	_textView.text = text;

	[self calculatedHeight];
}

- (CGFloat)calculatedHeight {
	CGRect frame = _textView.frame;
	frame.origin.x = IS_IPHONE ? 10 : 23;
	CGRect screenBounds = [A3UIDevice screenBoundsAdjustedWithOrientation];
	frame.size.width = screenBounds.size.width - (IS_IPHONE ? 10 : 23) * 2;
	[_textView.layoutManager ensureLayoutForTextContainer:_textView.textContainer];
	frame.size.height = MAX(180, [_textView.layoutManager usedRectForTextContainer:_textView.textContainer].size.height + 25.0);
	_textView.frame = frame;

	return _textView.frame.size.height;
}

@end
