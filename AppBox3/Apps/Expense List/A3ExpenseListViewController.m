//
//  A3ExpenseListViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 2/5/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "A3ExpenseListViewController.h"
#import "A3VerticalLinesView.h"
#import "A3UIKit.h"
#import "A3SalesCalcHistoryTableViewCell.h"
#import "A3ExpenseListTableViewCell.h"
#import "A3UIDevice.h"
#import "A3HorizontalBarContainerView.h"
#import "A3SmallButton.h"
#import "A3HorizontalBarChartView.h"
#import "common.h"
#import "Expense.h"
#import "A3AppDelegate.h"
#import "ExpenseDetail.h"
#import "NSString+conversion.h"
#import "A3NumberKeyboardViewController_iPad.h"
#import "A3NumberKeyboardViewController_iPhone.h"

@interface A3ExpenseListViewController () <UITextFieldDelegate, A3NumberKeyboardDelegate>

@property (nonatomic, strong) IBOutlet A3HorizontalBarContainerView *chartContainerView;
@property (nonatomic, strong) IBOutlet UITableView *myTableView;
@property (nonatomic, weak) UITextField *editingTextField;
@property (nonatomic, strong) Expense *expenseObject;
@property (nonatomic, strong) NSNumberFormatter *currencyFormatter, *decimalFormatter;
@property (nonatomic, weak) ExpenseDetail *editingDetail;
@property (nonatomic, strong) A3NumberKeyboardViewController *numberKeyboardViewController;

@end

@implementation A3ExpenseListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		self.title = @"Expense List";
        [A3UIKit addTopGradientLayerToView:self.view];
	}
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(onActionButton)];
	self.navigationItem.rightBarButtonItem = rightButtonItem;

	A3SmallButton *editButton = [[A3SmallButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 32.0, 30.0)];
	NSString *imageFilePath = [[NSBundle mainBundle] pathForResource:@"edit" ofType:@"png"];
	[editButton setImage:[UIImage imageWithContentsOfFile:imageFilePath] forState:UIControlStateNormal];
	_chartContainerView.accessoryView = editButton;

	// Do any additional setup after loading the view.
	_chartContainerView.chartLabelColor = [UIColor colorWithRed:73.0/255.0 green:74.0/255.0 blue:73.0/255.0 alpha:1.0];
	if (DEVICE_IPAD) {
		_chartContainerView.chartLabelFont = [UIFont boldSystemFontOfSize:18.0];
		_chartContainerView.chartValueFont = [UIFont boldSystemFontOfSize:22.0];
		_chartContainerView.bottomValueFont = [UIFont boldSystemFontOfSize:20.0];
	} else {
		_chartContainerView.chartLabelFont = [UIFont boldSystemFontOfSize:13.0];
		_chartContainerView.chartValueFont = [UIFont boldSystemFontOfSize:20.0];
		_chartContainerView.chartLabelColor = [UIColor blackColor];
		_chartContainerView.bottomValueFont = [UIFont boldSystemFontOfSize:24.0];
	}
	_chartContainerView.labelLeftTop.text = @"Total";
	_chartContainerView.labelLeftTop.font = _chartContainerView.chartLabelFont;
	_chartContainerView.labelRightTop.textColor = _chartContainerView.chartLabelColor;

	_chartContainerView.labelRightTop.text = @"Left";
	_chartContainerView.labelRightTop.font = _chartContainerView.chartLabelFont;
	_chartContainerView.labelRightTop.textColor = [UIColor colorWithRed:42.0/255.0 green:125.0/255.0 blue:0.0 alpha:1.0];

	_chartContainerView.bottomLabel.text = @"Budget";
	_chartContainerView.bottomLabel.font = _chartContainerView.chartLabelFont;
	_chartContainerView.bottomLabel.textColor = _chartContainerView.chartLabelColor;

	_chartContainerView.bottomValueLabel.text = @"$250.00";
	_chartContainerView.bottomValueLabel.font = _chartContainerView.bottomValueFont;

	_chartContainerView.chartLeftValueLabel.textColor = [UIColor whiteColor];
	_chartContainerView.chartLeftValueLabel.font = _chartContainerView.chartValueFont;

	_chartContainerView.chartRightValueLabel.textColor = [UIColor whiteColor];
	_chartContainerView.chartRightValueLabel.font = _chartContainerView.chartValueFont;
	_chartContainerView.chartRightValueLabel.text = @"$0.00";

	_chartContainerView.percentBarChart.leftValue = 183.49;
	_chartContainerView.percentBarChart.rightValue = 66.51;

	[_chartContainerView setBottomLabelText:_chartContainerView.bottomValueLabel.text];

	A3VerticalLinesView *tableViewBackground = [[A3VerticalLinesView alloc] initWithFrame:CGRectZero];
	if (DEVICE_IPAD) {
		tableViewBackground.positions = @[@51.0, @53.0, @302.0, @412.0, @473.0];
	} else {
		tableViewBackground.positions = @[@40.0, @42.0, @140.0, @210.0, @240.0];
	}

	tableViewBackground.backgroundColor = [UIColor colorWithRed:248.0/255.0 green:248.0/255.0 blue:248.0/255.0 alpha:1.0];
	_myTableView.backgroundView = tableViewBackground;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	[self calculate];
}

- (void)onActionButton {

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	// Return the number of sections.
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	// Return the number of rows in the section.
	return MAX([self.expenseObject.details count], 1);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"ExpenseListTableViewCell";
	A3ExpenseListTableViewCell *cell = (A3ExpenseListTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];

	// Configure the cell...
	if (cell == nil) {
		cell = [[A3ExpenseListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		cell.item.delegate = self;
		[cell.item addTarget:self action:@selector(textFieldValueChanged:) forControlEvents:UIControlEventEditingChanged];
		cell.price.delegate = self;
		[cell.price addTarget:self action:@selector(textFieldValueChanged:) forControlEvents:UIControlEventEditingChanged];
		cell.qty.delegate = self;
		[cell.qty addTarget:self action:@selector(textFieldValueChanged:) forControlEvents:UIControlEventEditingChanged];
	}

	ExpenseDetail *detail = [[self orderedDetails] objectAtIndex:indexPath.row];
	cell.item.text = detail.item;
	cell.price.text = detail.price;
	cell.qty.text = detail.quantity;
	cell.subtotal.text = [self.currencyFormatter stringFromNumber:[NSNumber numberWithFloat:[detail.price floatValueEx] * [detail.quantity floatValueEx] ] ];

	return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	// Return NO if you do not want the specified item to be editable.
	return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	// If none of the above are returned, then return \"none\".
	return UITableViewCellEditingStyleDelete;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		// Delete the row from the data source
	}
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

-(UIToolbar *)createActionBarForTextField:(UITextField *)textField {
	UIToolbar *actionBar = [[UIToolbar alloc] init];
	actionBar.translucent = YES;
	[actionBar sizeToFit];
	actionBar.barStyle = UIBarStyleBlackTranslucent;

	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", @"")
																   style:UIBarButtonItemStyleDone target:self
																  action:@selector(handleActionBarDone:)];

	UISegmentedControl *_prevNext = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:NSLocalizedString(@"Previous", @""), NSLocalizedString(@"Next", @""), nil]];
	_prevNext.momentary = YES;
	_prevNext.segmentedControlStyle = UISegmentedControlStyleBar;
	_prevNext.tintColor = actionBar.tintColor;
	[_prevNext addTarget:self action:@selector(handleActionBarPreviousNext:) forControlEvents:UIControlEventValueChanged];
	[_prevNext setEnabled:[self prevTextFieldForTextField:textField] != nil forSegmentAtIndex:0];
	[_prevNext setEnabled:[self nextTextFieldForTextField:textField] != nil forSegmentAtIndex:1];
	UIBarButtonItem *prevNextWrapper = [[UIBarButtonItem alloc] initWithCustomView:_prevNext];
	UIBarButtonItem *flexible = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	[actionBar setItems:[NSArray arrayWithObjects:prevNextWrapper, flexible, doneButton, nil]];

	return actionBar;
}

- (A3ExpenseListTableViewCell *)cellForPreviouseRow:(A3ExpenseListTableViewCell *)cell {
	NSIndexPath *indexPath = [_myTableView indexPathForCell:cell];
	if (indexPath.row > 0) {
		A3ExpenseListTableViewCell *prevCell = (A3ExpenseListTableViewCell *) [_myTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row - 1 inSection:0]];
		return prevCell;
	}
	return nil;
}

- (A3ExpenseListTableViewCell *)cellForNextRow:(A3ExpenseListTableViewCell *)cell {
	NSIndexPath *indexPath = [_myTableView indexPathForCell:cell];
	if (indexPath.row < ([_myTableView numberOfRowsInSection:0] - 1)) {
		A3ExpenseListTableViewCell *nextCell = (A3ExpenseListTableViewCell *) [_myTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:0]];
		return nextCell;
	}
	return nil;
}

- (UITextField *)prevTextFieldForTextField:(UITextField *)textField {
	A3ExpenseListTextFields tag = (A3ExpenseListTextFields) textField.tag;
	A3ExpenseListTableViewCell *currentCell = (A3ExpenseListTableViewCell *) [textField superview];
	switch (tag) {
		case A3ExpenseListTextFieldItem: {
			A3ExpenseListTableViewCell *prevCell = [self cellForPreviouseRow:currentCell];
			return prevCell != nil ? prevCell.qty : nil;
		}
		case A3ExpenseListTextFieldPrice:
			return currentCell.item;
		case A3ExpenseListTextFieldQuantity:
			return currentCell.price;
	}
	return nil;
}

- (UITextField *)nextTextFieldForTextField:(UITextField *)textField {
	A3ExpenseListTextFields tag = (A3ExpenseListTextFields)textField.tag;
	A3ExpenseListTableViewCell *currentCell = (A3ExpenseListTableViewCell *) [textField superview];
	switch (tag) {
		case A3ExpenseListTextFieldItem:
			return currentCell.price;
		case A3ExpenseListTextFieldPrice:
			return currentCell.qty;
		case A3ExpenseListTextFieldQuantity: {
			A3ExpenseListTableViewCell *nextCell = [self cellForNextRow:currentCell];
			return nil != nextCell ? nextCell.item : nil;
		}
	}
	return nil;
}

- (void)handleActionBarPreviousNext:(UISegmentedControl *)segmentedControl {
	BOOL prevButtonPressed = segmentedControl.selectedSegmentIndex == 0;
	[self handlePrevNext:prevButtonPressed];
}

- (void)handlePrevNext:(BOOL)prevButtonPressed {
	if (prevButtonPressed) {
		UITextField *prevTextField = [self prevTextFieldForTextField:_editingTextField];
		if (nil != prevTextField) {
			[_editingTextField resignFirstResponder];
			[prevTextField becomeFirstResponder];
		}
	} else {
		UITextField *nextTextField = [self nextTextFieldForTextField:_editingTextField];
		if (nil != nextTextField) {
			[_editingTextField resignFirstResponder];
			[nextTextField becomeFirstResponder];
		}
	}
}

- (void)handleActionBarDone:(id)handleActionBarDone {
	[_editingTextField resignFirstResponder];
}

#pragma mark - Text Field delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	FNLOG(@"%@", textField.text);
	_editingTextField = textField;

	A3ExpenseListTextFields tag = (A3ExpenseListTextFields) textField.tag;
	switch (tag) {
		case A3ExpenseListTextFieldItem:
			textField.inputAccessoryView = [self createActionBarForTextField:textField];
			textField.returnKeyType = [self nextTextFieldForTextField:textField] != nil ? UIReturnKeyNext : UIReturnKeyDone;
			break;
		case A3ExpenseListTextFieldPrice:
			textField.text = [textField.text stringByDecimalConversion];
		case A3ExpenseListTextFieldQuantity:
			textField.inputView = self.numberKeyboardViewController.view;
			_numberKeyboardViewController.keyInputDelegate = textField;

			[_numberKeyboardViewController reloadPrevNextButtons];
			break;
	}

	A3ExpenseListTableViewCell *cell = (A3ExpenseListTableViewCell *) _editingTextField.superview;
	NSIndexPath *indexPath = [_myTableView indexPathForCell:cell];
	_editingDetail = [[self orderedDetails] objectAtIndex:indexPath.row];
}

- (void)textFieldValueChanged:(UITextField *)textField {
	FNLOG(@"%@", textField.text);

	A3ExpenseListTableViewCell *cell = (A3ExpenseListTableViewCell *) _editingTextField.superview;
	A3ExpenseListTextFields tag = (A3ExpenseListTextFields) textField.tag;
	switch (tag) {
		case A3ExpenseListTextFieldItem:
			_editingDetail.item = textField.text;
			break;
		case A3ExpenseListTextFieldPrice:
			_editingDetail.price = [self.currencyFormatter stringFromNumber:[NSNumber numberWithFloat:[textField.text floatValueEx] ] ];
			break;
		case A3ExpenseListTextFieldQuantity:
			_editingDetail.quantity = textField.text;
			break;
	}

	cell.subtotal.text = [self.currencyFormatter stringFromNumber:[NSNumber numberWithFloat:[_editingDetail.price floatValueEx] * [_editingDetail.quantity floatValueEx] ] ];

	NSManagedObjectContext *managedObjectContext = [[A3AppDelegate instance] managedObjectContext];
	NSError *error;
	[managedObjectContext save:&error];

	[self calculate];

	FNLOG(@"%@", textField.text);
}

- (void)textFieldDidEndEditing:(UITextField *)textField {

	A3ExpenseListTableViewCell *cell = (A3ExpenseListTableViewCell *) _editingTextField.superview;
	A3ExpenseListTextFields tag = (A3ExpenseListTextFields) textField.tag;
	switch (tag) {
		case A3ExpenseListTextFieldItem:
			break;
		case A3ExpenseListTextFieldPrice:
			_editingDetail.price = [self.currencyFormatter stringFromNumber:[NSNumber numberWithFloat:[textField.text floatValueEx] ] ];
			cell.price.text = _editingDetail.price;
			break;
		case A3ExpenseListTextFieldQuantity:
			break;
	}
	FNLOG(@"%@", textField.text);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	FNLOG(@"Check");

	[textField resignFirstResponder];
	UITextField *nextTextField = [self nextTextFieldForTextField:textField];
	if (nextTextField) {
		[nextTextField becomeFirstResponder];
	}
	return YES;
}

- (IBAction)addNewItemButtonAction {
	[self addNewDetail];

	NSInteger numberOfRows = [_myTableView numberOfRowsInSection:0];
	[self.myTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:numberOfRows inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
}

#pragma mark - data

- (Expense *)expenseObject {
	if (_expenseObject) {
		return _expenseObject;
	}

	NSManagedObjectContext *managedObjectContext = [[A3AppDelegate instance] managedObjectContext];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Expense" inManagedObjectContext:managedObjectContext];
	[fetchRequest setEntity:entity];
	NSSortDescriptor *sortByDate = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
	[fetchRequest setSortDescriptors:@[sortByDate]];
	[fetchRequest setFetchLimit:1];
	NSError *error;
	NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
	if ([fetchedObjects count]) {
		_expenseObject = [fetchedObjects lastObject];
	} else {
		_expenseObject = [NSEntityDescription insertNewObjectForEntityForName:@"Expense" inManagedObjectContext:managedObjectContext];
		_expenseObject.date = [NSDate date];

		ExpenseDetail *newDetail = [NSEntityDescription insertNewObjectForEntityForName:@"ExpenseDetail" inManagedObjectContext:managedObjectContext];
		newDetail.order = [NSString stringWithFormat:@"%010d", 100];

		NSMutableSet *mutableDetails = [_expenseObject mutableSetValueForKey:@"details"];
		[mutableDetails addObject:newDetail];

		NSError *error;
		[managedObjectContext save:&error];
	}

	return _expenseObject;
}

- (void)addNewDetail {
	ExpenseDetail *newDetail = [NSEntityDescription insertNewObjectForEntityForName:@"ExpenseDetail" inManagedObjectContext:self.expenseObject.managedObjectContext];
	newDetail.order = [self orderStringForLastOrder];

	NSMutableSet *mutableDetails = [_expenseObject mutableSetValueForKey:@"details"];
	[mutableDetails addObject:newDetail];

	NSError *error;
	[_expenseObject.managedObjectContext save:&error];
}

- (NSArray *)orderedDetails {
	NSSortDescriptor *sortByOrder = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
	return [self.expenseObject.details sortedArrayUsingDescriptors:@[sortByOrder]];
}

- (NSString *)orderStringForLastOrder {
	if ([self.expenseObject.details count]) {
		ExpenseDetail *lastObject = [[self orderedDetails] lastObject];

		return [NSString stringWithFormat:@"%010d", [lastObject.order integerValue] + 100];
	}
	return [NSString stringWithFormat:@"%010d", 100];
}

- (NSNumberFormatter *)currencyFormatter {
	if (nil == _currencyFormatter) {
		_currencyFormatter = [[NSNumberFormatter alloc] init];
		[_currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	}
	return _currencyFormatter;
}

- (NSNumberFormatter *)decimalFormatter {
	if (nil == _decimalFormatter) {
		_decimalFormatter = [[NSNumberFormatter alloc] init];
		[_decimalFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
		[_decimalFormatter setUsesGroupingSeparator:NO];
	}
	return _decimalFormatter;
}

- (A3NumberKeyboardViewController *)numberKeyboardViewController {
	if (nil == _numberKeyboardViewController) {
		if (DEVICE_IPAD) {
			_numberKeyboardViewController = [[A3NumberKeyboardViewController_iPad alloc] initWithNibName:@"A3NumberKeyboardViewController_iPad" bundle:nil];
		} else {
			_numberKeyboardViewController = [[A3NumberKeyboardViewController_iPhone alloc] initWithNibName:@"A3NumberKeyboardViewController_iPhone" bundle:nil];
		}
		_numberKeyboardViewController.delegate = self;
	}
	return _numberKeyboardViewController;
}

- (void)clearButtonPressed {
	_editingTextField.text = @"";
}

- (BOOL)prevAvailableForElement:(QEntryElement *)element {
	return [self prevTextFieldForTextField:_editingTextField] != nil;
}

- (BOOL)nextAvailableForElement:(QEntryElement *)element {
	return [self nextTextFieldForTextField:_editingTextField] != nil;
}

- (void)prevButtonPressedWithElement:(QEntryElement *)element {
	[self handlePrevNext:YES];
}

- (void)nextButtonPressedWithElement:(QEntryElement *)element {
	[self handlePrevNext:NO];
}

- (void)A3KeyboardViewControllerDoneButtonPressed {
	[_editingTextField resignFirstResponder];
}

#pragma mark - calculation

- (void)calculate {
	NSArray *allObject = [self.expenseObject.details allObjects];

	float total = 0.0;
	for (ExpenseDetail *detail in allObject) {
		total += [detail.price floatValueEx] * [detail.quantity floatValue];
	}
	_chartContainerView.chartLeftValueLabel.text = [self.currencyFormatter stringFromNumber:[NSNumber numberWithFloat:total]];
}

@end
