//
//  A3LoanCalcSettingsViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 3/11/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3LoanCalcSettingsViewController.h"
#import "A3LoanCalcString.h"

@interface A3LoanCalcSettingsViewController ()

@property (nonatomic, strong)	QRootElement *rootElement;
@property (nonatomic, strong)	A3LoanCalcPreferences *preferences;

@end

@implementation A3LoanCalcSettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		// Custom initialization
		self.title = @"Settings";
	}
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (QButtonElement *)elementForSection1WithValue:(A3LoanCalcCalculationFor)value {
	QButtonElement *element = [[QButtonElement alloc] initWithTitle:[A3LoanCalcString stringFromCalculationFor:value]];
	element.controllerAction = @"calculationForButtonAction:";
	return element;
}

- (QRootElement *)rootElement {
	QRootElement *root;
	root = [[QRootElement alloc] init];
	root.title = @"Settings";
	root.grouped = YES;

	QSection *section0 = [[QSection alloc] init];
	QBooleanElement *section0element = [[QBooleanElement alloc] initWithTitle:@"Down Payments" BoolValue:self.preferences.showDownPayment];
	section0element.onSelected = ^{
		QSection *section = [self.root.sections objectAtIndex:0];
		QBooleanElement *element = [section.elements objectAtIndex:0];
		[self.preferences setShowDownPayment:element.boolValue];

		QSection *section1 = [self.root.sections objectAtIndex:1];
		if (!element.boolValue) {
			if ([self.preferences calculationFor] == A3_LCCF_DownPayment) {
				[_preferences setCalculationFor:A3_LCCF_MonthlyPayment];
				if ([section1.elements count] > 1) {
					QElement *firstElement = [section1.elements objectAtIndex:0];
					UITableViewCell *cell = [self.quickDialogTableView cellForElement:firstElement];
					cell.accessoryType = UITableViewCellAccessoryCheckmark;
				}
			}
		}
		if ([section1.elements count] == 1) {
			QButtonElement *element = (QButtonElement *)[section1.elements objectAtIndex:0];
			element.title = [A3LoanCalcString stringFromCalculationFor:_preferences.calculationFor];
			[self.quickDialogTableView reloadData];
		} else {
			if (element.boolValue) {
				// Insert new element and row
				QButtonElement *newElement = [self elementForSection1WithValue:A3_LCCF_DownPayment];
				[section1 insertElement:newElement atIndex:1];
				[self.quickDialogTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:1]] withRowAnimation:UITableViewRowAnimationBottom];
			} else {
				// Remove existing element and row
				[section1.elements removeObjectAtIndex:1];
				[self.quickDialogTableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:1]] withRowAnimation:UITableViewRowAnimationBottom];
			}
		}
	};
	[section0 addElement:section0element];

	QSection *section1 = [[QSection alloc] initWithTitle:@"Calculation For"];
	QButtonElement *section1Element0 = [self elementForSection1WithValue:self.preferences.calculationFor];
	[section1 addElement:section1Element0];

	QRadioSection *section2 = [[QRadioSection alloc] initWithItems:@[@"Simple Interest", @"Compound Interest"] selected:self.preferences.useSimpleInterest ? 0 : 1 title:@"Type of Interest"];
	section2.onSelected = ^{
		QRadioSection *section = [self.root.sections objectAtIndex:2];
		[self.preferences setUseSimpleInterest:(section.selected == 0)];
	};

	QSection *section3 = [[QSection alloc] init];
	QBooleanElement *section3element0 = [[QBooleanElement alloc] initWithTitle:@"Extra Payments" BoolValue:_preferences.showExtraPayment];
	section3element0.onSelected = ^{
		QSection *section = [self.root.sections objectAtIndex:3];
		QBooleanElement *element = [section.elements objectAtIndex:0];
		[self.preferences setShowExtraPayment:element.boolValue];
	};
	[section3 addElement:section3element0];

	[root addSection:section0];
	[root addSection:section1];
	[root addSection:section2];
	[root addSection:section3];

	return root;
}

- (A3LoanCalcPreferences *)preferences {
	if (nil == _preferences) {
		_preferences = [[A3LoanCalcPreferences alloc] init];
	}
	return _preferences;
}

- (NSUInteger)rowForValue:(A3LoanCalcCalculationFor)value {
	return (value - 1 - ((value >= A3_LCCF_DownPayment) && ![self.preferences showDownPayment] ? 1 : 0));
}

- (void)calculationForButtonAction:(QButtonElement *)element {
	BOOL showDownPayment = [self.preferences showDownPayment];
	NSArray *candidate;
	if (showDownPayment) {
		candidate= @[
				[NSNumber numberWithUnsignedInteger:A3_LCCF_MonthlyPayment],
				[NSNumber numberWithUnsignedInteger:A3_LCCF_DownPayment],
				[NSNumber numberWithUnsignedInteger:A3_LCCF_Principal],
				[NSNumber numberWithUnsignedInteger:A3_LCCF_TermYears],
				[NSNumber numberWithUnsignedInteger:A3_LCCF_TermMonths]
		];
	} else {
		candidate= @[
				[NSNumber numberWithUnsignedInteger:A3_LCCF_MonthlyPayment],
				[NSNumber numberWithUnsignedInteger:A3_LCCF_Principal],
				[NSNumber numberWithUnsignedInteger:A3_LCCF_TermYears],
				[NSNumber numberWithUnsignedInteger:A3_LCCF_TermMonths]
		];
	}

	UITableViewCell *cell = [self.quickDialogTableView cellForElement:element];
	NSIndexPath *indexPath = [self.quickDialogTableView indexPathForCell:cell];
	[self.quickDialogTableView deselectRowAtIndexPath:indexPath animated:YES];

	A3LoanCalcPreferences *preferences = [[A3LoanCalcPreferences alloc] init];
	A3LoanCalcCalculationFor calculationFor = preferences.calculationFor;

	QSection *section = [self.root.sections objectAtIndex:1];
	NSMutableArray *changedRows = [[NSMutableArray alloc] init];
	if ([section.elements count] == 1) {
		NSUInteger index, selectedIndex;
		index = 0;

		for (;index < [candidate count]; index++) {
			NSNumber *value = [candidate objectAtIndex:index];
			if ([value unsignedIntegerValue] == calculationFor) {
				selectedIndex = index;
				continue;
			}

			QButtonElement *newElement = [self elementForSection1WithValue:(A3LoanCalcCalculationFor) [value unsignedIntegerValue]];
			[section insertElement:newElement atIndex:index];
			[changedRows addObject:[NSIndexPath indexPathForRow:index inSection:1]];
		}

		[self.quickDialogTableView insertRowsAtIndexPaths:changedRows withRowAnimation:UITableViewRowAnimationBottom];

		UITableViewCell *cell;
		cell = [self.quickDialogTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:selectedIndex inSection:1]];
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	}
	else
	{
		NSUInteger selectedIndex = [section.elements indexOfObject:element];
		UITableViewCell *cell = [self.quickDialogTableView cellForElement:element];
		cell.accessoryType = UITableViewCellAccessoryNone;
		calculationFor = (A3LoanCalcCalculationFor)[[candidate objectAtIndex:selectedIndex] unsignedIntegerValue];
		[self.preferences setCalculationFor:calculationFor];
		NSInteger index;
		index = [candidate count] - 1;
		for (; index >= 0; index--) {
			if (index == selectedIndex) continue;
			[section.elements removeObjectAtIndex:index];
			[changedRows addObject:[NSIndexPath indexPathForRow:index inSection:1]];
		}
		[self.quickDialogTableView deleteRowsAtIndexPaths:changedRows withRowAnimation:UITableViewRowAnimationBottom];
	}
}

#pragma mark - QuickDialogStyleProvider

- (void)cell:(UITableViewCell *)cell willAppearForElement:(QElement *)element atIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 1) {
		cell.textLabel.textAlignment = NSTextAlignmentLeft;
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
}

@end
