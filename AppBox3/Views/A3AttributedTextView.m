//
//  A3AttributedTextView
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 5/28/13 12:27 PM.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import "A3AttributedTextView.h"


@implementation A3AttributedTextView {

}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];

	CGFloat width = 0.0;
	CGFloat height = 0.0;

	NSUInteger index = 0;
	for (NSString *string in _texts) {
		NSDictionary *attribute = [_attributes objectAtIndex:index];
		CGSize size = [string sizeWithFont:attribute[NSFontAttributeName]];
		width += size.width;
		height = MAX(height, size.height);
	}
	width += _space * ([_texts count] - 1);

	CGFloat x = CGRectGetWidth(rect) / 2.0 - width / 2.0;
	for (NSString *string in _texts) {
		[string drawInRect:<#(CGRect)rect#> withFont:<#(UIFont *)font#> lineBreakMode:<#(NSLineBreakMode)lineBreakMode#> alignment:<#(NSTextAlignment)alignment#>]
	}
}

@end