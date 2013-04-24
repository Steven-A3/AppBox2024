//
//  A3QuickDialogController
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 4/19/13 12:56 PM.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3SalesCalcQuickDialogViewController.h"
#import "A3QuickDialogController.h"
#import "EKKeyboardAvoidingScrollViewManager.h"
#import "A3UIKit.h"
#import "A3UserDefaults.h"
#import "UIViewController+A3AppCategory.h"
#import "common.h"


@interface A3QuickDialogController ()
@end

@implementation A3QuickDialogController {

}

- (A3QuickDialogController *)initWithRoot:(QRootElement *)rootElement {
	self = [super initWithRoot:rootElement];
	if (self) {

	}

	return self;
}


- (void)viewDidLoad {
	[super viewDidLoad];

	self.view.backgroundColor = [UIColor clearColor];

	[[EKKeyboardAvoidingScrollViewManager sharedInstance] registerScrollViewForKeyboardAvoiding:self.quickDialogTableView];

	[self registerForKeyboardNotifications];
}

- (void)dealloc {
	FNLOG(@"Check");

	[[EKKeyboardAvoidingScrollViewManager sharedInstance] unregisterScrollViewFromKeyboardAvoiding:self.quickDialogTableView];

	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)registerForKeyboardNotifications
{
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardDidShow:)
												 name:UIKeyboardDidShowNotification object:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardDidHide:)
												 name:UIKeyboardDidHideNotification object:nil];
}

- (void)keyboardDidShow:(NSNotification*)aNotification {
	if (_editingElement) {
		UITableViewCell *cell = [self.quickDialogTableView cellForElement:_editingElement];
		NSIndexPath *indexPath = [self.quickDialogTableView indexPathForCell:cell];

		[self.quickDialogTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
	}
}

- (void)keyboardDidHide:(NSNotification*)aNotification {
	[self.quickDialogTableView setContentOffset:CGPointMake(0.0, 0.0)];
}

- (NSNumberFormatter *)currencyNumberFormatter {
	if (nil == _currencyNumberFormatter) {
		_currencyNumberFormatter = [A3UIKit currencyNumberFormatter];
		[_currencyNumberFormatter setCurrencyCode:[self defaultCurrencyCode]];
	}
	return _currencyNumberFormatter;
}

- (NSNumberFormatter *)percentNumberFormatter {
	if (nil == _percentNumberFormatter) {
		_percentNumberFormatter = [A3UIKit percentNumberFormatter];
	}
	return _percentNumberFormatter;
}

- (NSString *)defaultCurrencyCode {
	if (nil == _defaultCurrencyCode) {
		_defaultCurrencyCode = [[NSUserDefaults standardUserDefaults] objectForKey:A3SalesCalcDefaultCurrencyCode];
		if (![_defaultCurrencyCode length]) {
			NSLocale *locale = [NSLocale currentLocale];
			_defaultCurrencyCode = [locale objectForKey:NSLocaleCurrencyCode];
			[[NSUserDefaults standardUserDefaults] setObject:_defaultCurrencyCode forKey:A3SalesCalcDefaultCurrencyCode];
			[[NSUserDefaults standardUserDefaults] synchronize];
		}
	}
	return _defaultCurrencyCode;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];

	A3NumberKeyboardViewController *kbvc = self.numberKeyboardViewController;
	if ([kbvc respondsToSelector:@selector(rotateToInterfaceOrientation:)]) {
		[kbvc rotateToInterfaceOrientation:toInterfaceOrientation];
	}
}

@end