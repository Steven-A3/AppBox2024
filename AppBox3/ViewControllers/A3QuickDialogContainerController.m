//
//  A3QuickDialogContainerController
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 4/19/13 12:56 PM.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3QuickDialogContainerController.h"
#import "EKKeyboardAvoidingScrollViewManager.h"
#import "UIViewController+A3AppCategory.h"
#import "common.h"
#import "A3UIStyle.h"
#import "NSString+conversion.h"
#import "A3UIDevice.h"
#import "CommonUIDefinitions.h"


@interface A3QuickDialogContainerController ()

@end

@implementation A3QuickDialogContainerController {

}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	FNLOG(@"Check");
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		_rowHeight = DEVICE_IPAD ? A3_TABLE_VIEW_ROW_HEIGHT_IPAD : A3_TABLE_VIEW_ROW_HEIGHT_IPHONE;

		self.view.frame = [A3UIDevice appFrame];
		self.quickDialogController.view.frame = self.view.bounds;
		[self.view addSubview:self.quickDialogController.view];
		[self addChildViewController:self.quickDialogController];
	}

	return self;
}

- (QRootElement *)rootElement {
	return nil;
}

- (QuickDialogController *)quickDialogController {
	if (nil == _quickDialogController) {
		_quickDialogController = [[QuickDialogController alloc] initWithRoot:[self rootElement]];
	}
	return _quickDialogController;
}

- (QuickDialogTableView *)quickDialogTableView {
	return self.quickDialogController.quickDialogTableView;
}

- (QRootElement *)root {
	return self.quickDialogTableView.root;
}

- (void)viewDidLoad {
	FNLOG(@"Check");
	[super viewDidLoad];

}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	self.quickDialogController.quickDialogTableView.styleProvider = self;
	self.quickDialogController.quickDialogTableView.backgroundView = nil;
	self.quickDialogController.quickDialogTableView.backgroundColor = [A3UIStyle contentsBackgroundColor];

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

- (NSString *)defaultCurrencyCode {
	return [[NSLocale currentLocale] objectForKey:NSLocaleCurrencyCode];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];

	[self.numberKeyboardViewController rotateToInterfaceOrientation:toInterfaceOrientation];
	[self.dateKeyboardViewController rotateToInterfaceOrientation:toInterfaceOrientation];
	[self.frequencyKeyboardViewController rotateToInterfaceOrientation:toInterfaceOrientation];
}

#pragma mark -- QuickDialog CELL Style Provider Delegate

- (void)cell:(UITableViewCell *)cell willAppearForElement:(QElement *)element atIndexPath:(NSIndexPath *)indexPath {
	FNLOG(@"Check");
	cell.backgroundColor = [A3UIStyle contentsBackgroundColor];

	if ([element isKindOfClass:[QButtonElement class]]) {
		cell.textLabel.font = [A3UIStyle fontForTableViewEntryCellTextField];
		cell.textLabel.textColor = [A3UIStyle colorForTableViewCellButton];
	} else
	if ([element isKindOfClass:[QEntryElement class]]) {
		cell.textLabel.font = [A3UIStyle fontForTableViewEntryCellLabel];
		cell.textLabel.textColor = [A3UIStyle colorForTableViewCellLabelNormal];

		QEntryTableViewCell *entryCell = (QEntryTableViewCell *) cell;
		entryCell.textField.font = [A3UIStyle fontForTableViewEntryCellTextField];
		entryCell.textField.textColor = [A3UIStyle colorForTableViewCellLabelSelected];
		entryCell.textField.textAlignment = NSTextAlignmentLeft;
	}
}

- (void)prepareNumberKeyboard:(QEntryTableViewCell *)cell forElelement:(QEntryElement *)element {
	cell.textField.inputView = self.numberKeyboardViewController.view;
	self.numberKeyboardViewController.keyInputDelegate = cell.textField;
	self.numberKeyboardViewController.entryTableViewCell = cell;
	self.numberKeyboardViewController.element = element;

	cell.textField.text = [cell.textField.text stringByDecimalConversion];
	[self.numberKeyboardViewController reloadPrevNextButtons];
}

- (void)QEntryDidBeginEditingElement:(QEntryElement *)element  andCell:(QEntryTableViewCell *)cell {
	FNLOG(@"Check");

	self.editingElement = element;
	cell.backgroundColor = [UIColor whiteColor];
	cell.textField.inputAccessoryView = nil;

	NSDictionary *operations = @{
			NSStringFromClass([A3CurrencyEntryElement class]) : ^() {
				[self prepareNumberKeyboard:cell forElelement:element ];
				self.numberKeyboardViewController.keyboardType = A3NumberKeyboardTypeCurrency;
			},
			NSStringFromClass([A3PercentEntryElement class]) : ^() {
				[self prepareNumberKeyboard:cell forElelement:element];
				self.numberKeyboardViewController.keyboardType = A3NumberKeyboardTypePercent;
			},
			NSStringFromClass([A3TermEntryElement class]) : ^() {
				[self prepareNumberKeyboard:cell forElelement:element];
				self.numberKeyboardViewController.keyboardType = A3NumberKeyboardTypeMonthYear;
			},
			NSStringFromClass([A3InterestEntryElement class]) : ^() {
				[self prepareNumberKeyboard:cell forElelement:element];
				self.numberKeyboardViewController.keyboardType = A3NumberKeyboardTypeInterestRate;
			},
			NSStringFromClass([A3FrequencyEntryElement class]) : ^() {
				cell.textField.inputView = self.frequencyKeyboardViewController.view;
				self.frequencyKeyboardViewController.entryTableViewCell = cell;
				self.frequencyKeyboardViewController.element = element;
				[self.frequencyKeyboardViewController reloadPrevNextButtons];
				cell.textField.clearButtonMode = UITextFieldViewModeNever;
			},
			NSStringFromClass([A3DateEntryElement class]) : ^() {
				cell.textField.inputView = self.dateKeyboardViewController.view;
				self.dateKeyboardViewController.workingMode = A3DateKeyboardWorkingModeYearMonthDay;
				self.dateKeyboardViewController.element = element;
				self.dateKeyboardViewController.entryTableViewCell = cell;
				[self.dateKeyboardViewController resetToDefaultState];
				cell.textField.clearButtonMode = UITextFieldViewModeNever;
				[self.dateKeyboardViewController reloadPrevNextButtons];
			},
	};
	void (^operation)() = [operations objectForKey:NSStringFromClass([element class])];
	if (operation != nil) {
		operation();
	} else {
		FNLOG(@"Unhandled calss %@", element);
	}
}

- (void)QEntryDidEndEditingElement:(QEntryElement *)element andCell:(QEntryTableViewCell *)cell {
	FNLOG(@"Check");

	self.editingElement = nil;
	cell.backgroundColor = [A3UIStyle contentsBackgroundColor];

	if ([element isKindOfClass:[A3CurrencyEntryElement class]]) {
		element.textValue = [self currencyFormattedString:cell.textField.text];
		cell.textField.text = element.textValue;
	} else if ([element isKindOfClass:[A3PercentEntryElement class]]) {
		element.textValue = [self percentFormattedString:cell.textField.text];
		cell.textField.text = element.textValue;
	} else {
		element.textValue = cell.textField.text;
	}
}

@end