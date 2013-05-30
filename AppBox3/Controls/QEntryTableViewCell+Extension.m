//
//  QEntryTableViewCell+Extension.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 12/31/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "QEntryTableViewCell+Extension.h"

@interface QEntryTableViewCell ()

@end

@implementation QEntryTableViewCell (Extension)

- (void)handlePrevNextWithForNext:(BOOL)isNext {
	QEntryElement *element;

	if (isNext) {
		element = [self findNextElementToFocusOn];
	} else {
		element = [self findPreviousElementToFocusOn];
	}

	if (element != nil) {

		UITableViewCell *cell = [_quickformTableView cellForElement:element];
		if (cell != nil) {
			[cell becomeFirstResponder];
		}
		else {

			[_quickformTableView scrollToRowAtIndexPath:[element getIndexPath]
									   atScrollPosition:UITableViewScrollPositionMiddle
											   animated:YES];

			dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC);
			dispatch_after(popTime, dispatch_get_main_queue(), ^{
				UITableViewCell *c = [_quickformTableView cellForElement:element];
				if (c != nil) {
					[c becomeFirstResponder];
				}
			});
		}
	}
}

@end
