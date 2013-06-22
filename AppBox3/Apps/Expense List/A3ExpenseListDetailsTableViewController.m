//
//  A3ExpenseListDetailsTableViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 4/13/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3ExpenseListDetailsTableViewController.h"
#import "A3NumberKeyboardViewController.h"
#import "A3NumberKeyboardViewController_iPad.h"
#import "A3NumberKeyboardViewController_iPhone.h"
#import "A3HorizontalBarContainerView.h"
#import "Expense.h"
#import "A3ExpenseListTableViewCell.h"
#import "NSString+conversion.h"
#import "ExpenseDetail.h"
#import "common.h"
#import "A3AppDelegate.h"
#import "A3UIDevice.h"
#import "UIViewController+A3AppCategory.h"
#import "A3HorizontalBarChartView.h"
#import "MagicalRecord.h"
#import "NSManagedObjectContext+MagicalThreading.h"

@interface A3ExpenseListDetailsTableViewController () <UITextFieldDelegate, A3KeyboardDelegate>

@property (nonatomic, weak) UITextField *editingTextField;
@property (nonatomic, weak) ExpenseDetail *editingDetail;
@property (nonatomic, strong) A3NumberKeyboardViewController *numberKeyboardViewController;
@property (nonatomic, strong) NSArray *orderedDetails;

@end

@implementation A3ExpenseListDetailsTableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

	self.tableView.backgroundColor = [UIColor clearColor];
	[self calculate];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	[[NSManagedObjectContext MR_contextForCurrentThread] MR_saveOnlySelfAndWait];
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

- (A3ExpenseListTableViewCell *)cellWithReuseIdentifier:(NSString *)CellIdentifier {
	A3ExpenseListTableViewCell *cell;
	cell = [[A3ExpenseListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	cell.item.delegate = self;
	[cell.item addTarget:self action:@selector(textFieldValueChanged:) forControlEvents:UIControlEventEditingChanged];
	cell.price.delegate = self;
	[cell.price addTarget:self action:@selector(textFieldValueChanged:) forControlEvents:UIControlEventEditingChanged];
	cell.qty.delegate = self;
	[cell.qty addTarget:self action:@selector(textFieldValueChanged:) forControlEvents:UIControlEventEditingChanged];

	return cell;
}

- (void)fillCell:(A3ExpenseListTableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
	ExpenseDetail *detail = [[self orderedDetails] objectAtIndex:indexPath.row];
	cell.item.text = detail.item;
	cell.price.text = detail.price;
	cell.qty.text = detail.quantity;
	cell.subtotal.text = [self.currencyFormatter stringFromNumber:[NSNumber numberWithFloat:[detail.price floatValueEx] * [detail.quantity floatValueEx] ] ];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"ExpenseListTableViewCell";
	A3ExpenseListTableViewCell *cell = (A3ExpenseListTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];

	// Configure the cell...
	if (cell == nil) {
		cell = [self cellWithReuseIdentifier:CellIdentifier];
	}

	[self fillCell:cell forIndexPath:indexPath];

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

- (UITableViewCell *)cellIdenticalToCellAtIndexPath:(NSIndexPath *)indexPath forDragTableViewController:(ATSDragToReorderTableViewController *)dragTableViewController {
	A3ExpenseListTableViewCell *cell = [self cellWithReuseIdentifier:nil];
	[self fillCell:cell forIndexPath:indexPath];
//	cell.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.6];

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
	NSInteger beforeValue, afterValue, newValue;
	beforeValue = destinationIndexPath.row > 0 ?
			[[[self.orderedDetails objectAtIndex:destinationIndexPath.row - 1] valueForKey:@"order"] integerValue]
			: 0;
	afterValue = [[[self.orderedDetails objectAtIndex:destinationIndexPath.row] valueForKey:@"order"] integerValue];
	newValue = beforeValue + (afterValue - beforeValue) / 2;

	if ((newValue == afterValue) || (newValue == beforeValue)) {
		// Re assign whole order string.
		NSInteger orderNumber = 10000;
		for (NSInteger index = 0; index < [_orderedDetails count]; index++) {
			NSObject *detail = [_orderedDetails objectAtIndex:index];
			[detail setValue:[NSString stringWithFormat:@"%010d", orderNumber] forKey:@"order"];
			orderNumber += 10000;
		}
	} else {
		[[_orderedDetails objectAtIndex:sourceIndexPath.row] setValue:[NSString stringWithFormat:@"%010d", newValue] forKey:@"order"];
	}
	FNLOG(@"%d, %d, %010d, %010d, %010d", sourceIndexPath.row, destinationIndexPath.row, beforeValue, afterValue, newValue);

	NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:self.orderedDetails];
	[mutableArray moveObjectFromIndex:sourceIndexPath.row toIndex:destinationIndexPath.row];
	_orderedDetails = mutableArray;

	NSError *error;
	[self.expenseObject.managedObjectContext save:&error];
}

#pragma mark - Keyboard

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
	NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
	if (indexPath.row > 0) {
		A3ExpenseListTableViewCell *prevCell = (A3ExpenseListTableViewCell *) [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row - 1 inSection:0]];
		return prevCell;
	}
	return nil;
}

- (A3ExpenseListTableViewCell *)cellForNextRow:(A3ExpenseListTableViewCell *)cell {
	NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
	if (indexPath.row < ([self.tableView numberOfRowsInSection:0] - 1)) {
		A3ExpenseListTableViewCell *nextCell = (A3ExpenseListTableViewCell *) [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:0]];
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
	NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
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
	[self calculate];
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

- (void)addNewItemButtonAction {
	[self addNewDetail];

	NSInteger numberOfRows = [self.tableView numberOfRowsInSection:0];
	[self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:numberOfRows inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
}

#pragma mark - data

- (Expense *)expenseObject {
	if (_expenseObject) {
		return _expenseObject;
	}

	NSManagedObjectContext *managedObjectContext = [NSManagedObjectContext MR_defaultContext];
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
		[self addNewList];
	}

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(managedObjectContextObjectsDidChange:) name:NSManagedObjectContextObjectsDidChangeNotification object:managedObjectContext];
	return _expenseObject;
}

- (void)addNewList {
	NSManagedObjectContext *managedObjectContext = [NSManagedObjectContext MR_defaultContext];
	_expenseObject = [NSEntityDescription insertNewObjectForEntityForName:@"Expense" inManagedObjectContext:managedObjectContext];
	_expenseObject.date = [NSDate date];

	ExpenseDetail *newDetail = [NSEntityDescription insertNewObjectForEntityForName:@"ExpenseDetail" inManagedObjectContext:managedObjectContext];
	newDetail.order = [NSString stringWithFormat:@"%010d", 100];

	NSMutableSet *mutableDetails = [_expenseObject mutableSetValueForKey:@"details"];
	[mutableDetails addObject:newDetail];

	NSError *error;
	[managedObjectContext save:&error];

	_orderedDetails = nil;
}

- (void)managedObjectContextObjectsDidChange:(NSNotification *)notification {
	NSSet *changed = [notification.userInfo objectForKey:NSUpdatedObjectsKey];

    [changed enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
		if (obj == _expenseObject) {
			*stop = YES;
			FNLOG(@"%@", obj);
			[_chartContainerView setBottomLabelText:[self currencyFormattedString:_expenseObject.budget]];
			[self calculate];
		}
	}];
}

- (void)addNewDetail {
	ExpenseDetail *newDetail = [NSEntityDescription insertNewObjectForEntityForName:@"ExpenseDetail" inManagedObjectContext:self.expenseObject.managedObjectContext];
	newDetail.order = [self orderStringForLastOrder];

	NSMutableSet *mutableDetails = [_expenseObject mutableSetValueForKey:@"details"];
	[mutableDetails addObject:newDetail];

	NSError *error;
	[_expenseObject.managedObjectContext save:&error];

	_orderedDetails = nil;
	[self orderedDetails];
}

- (NSArray *)orderedDetails {
	if (nil == _orderedDetails) {
		NSSortDescriptor *sortByOrder = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
		_orderedDetails = [self.expenseObject.details sortedArrayUsingDescriptors:@[sortByOrder]];
	}
	return _orderedDetails;
}

- (NSString *)orderStringForLastOrder {
	if ([self.expenseObject.details count]) {
		ExpenseDetail *lastObject = [[self orderedDetails] lastObject];

		return [NSString stringWithFormat:@"%010d", [lastObject.order integerValue] + 10000];
	}
	return [NSString stringWithFormat:@"%010d", 10000];
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

- (void)A3KeyboardDoneButtonPressed {
	[_editingTextField resignFirstResponder];
}

- (void)makeNewList {
	[self addNewList];
	[self.tableView reloadData];
	[self calculate];
}

#pragma mark - calculation

- (void)calculate {
	FNLOG();
	NSArray *allObject = [self.expenseObject.details allObjects];

	float total = 0.0;
	for (ExpenseDetail *detail in allObject) {
		total += [detail.price floatValueEx] * [detail.quantity floatValue];
	}
	_chartContainerView.chartLeftValueLabel.text = [self.currencyFormatter stringFromNumber:@(total)];
	float budget = [_expenseObject.budget floatValueEx];
	float left = budget - total;

	if (total != [_expenseObject.total floatValue]) {
		_expenseObject.total = @(total);
	}
	if (left != [_expenseObject.left floatValue]) {
		_expenseObject.left = @(left);
	}

	_chartContainerView.chartRightValueLabel.text = [self.currencyFormatter stringFromNumber:@(left)];
	_chartContainerView.percentBarChart.leftValue = total;
	_chartContainerView.percentBarChart.rightValue = MAX(0.0, left);
	[_chartContainerView setBottomLabelText:[self currencyFormattedString:_expenseObject.budget]];
}

- (void)historySelected:(Expense *)expenseObject {
	_expenseObject = expenseObject;
	_expenseObject.date = [NSDate date];

	_orderedDetails = nil;
	[self.tableView reloadData];
	[self calculate];
}

@end
