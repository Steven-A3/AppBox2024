//
//  A3LoanCalc2ViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 10/22/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3LoanCalc2ViewController.h"
#import "A3TableViewSelectElement.h"
#import "A3LoanCalcPreferences.h"
#import "A3TableViewEntryElement.h"
#import "A3TableViewRootElement.h"
#import "A3TableViewDateEntryElement.h"
#import "A3TableViewMonthEntryElement.h"
#import "A3SelectTableViewController.h"
#import "UIViewController+A3Addition.h"
#import "A3TableViewExpandableElement.h"
#import "A3UIDevice.h"
#import "A3TripleCircleView.h"
#import "A3RoundedSideButton.h"
#import "A3TableViewEntryCell.h"
#import "LoanCalcHistory.h"
#import "LoanCalcHistory+calculation.h"

typedef NS_ENUM(NSInteger, A3LoanCalcRowIdentifier) {
	A3LoanCalcRowIdCalculation = 1,
	A3LoanCalcRowIdFrequency,
};

@interface A3LoanCalc2ViewController () <A3SelectTableViewControllerProtocol>

@property (nonatomic, strong) A3TableViewRootElement *root;
@property (nonatomic, strong) A3LoanCalcPreferences *preferences;
@property (nonatomic, strong) LoanCalcHistory *editingObject;

@end

@implementation A3LoanCalc2ViewController {

}

- (id)init {
	self = [super initWithStyle:UITableViewStyleGrouped];
	if (self) {
		self.title = @"Loan Calc";

		self.preferences.showExtraPayment = YES;
		[self configureTableData];
		self.tableView.showsVerticalScrollIndicator = NO;
	}

	return self;
}

- (LoanCalcHistory *)editingObject {
	if (nil == _editingObject) {
		NSManagedObjectContext *managedObjectContext = [[MagicalRecordStack defaultStack] context];

		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"LoanCalcHistory" inManagedObjectContext:managedObjectContext];
		[fetchRequest setEntity:entity];
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(editing == YES) and (location == 'S')"];
		[fetchRequest setPredicate:predicate];
		NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"created" ascending:NO];
		[fetchRequest setSortDescriptors:@[sortDescriptor]];
		[fetchRequest setFetchLimit:1];
		NSError *error;
		NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
		if ([fetchedObjects count]) {
			_editingObject = [fetchedObjects objectAtIndex:0];
			[self.preferences setCalculationFor:(A3LoanCalcCalculationFor)[_editingObject.calculationFor unsignedIntegerValue]];
			[_preferences setShowDownPayment:[_editingObject.showDownPayment boolValue]];
			[_preferences setShowExtraPayment:[_editingObject.showExtraPayment boolValue]];
			[_preferences setShowAdvanced:[_editingObject.showAdvanced boolValue]];
			[_preferences setUseSimpleInterest:[_editingObject.useSimpleInterest boolValue]];
		} else {
			_editingObject = [NSEntityDescription insertNewObjectForEntityForName:@"LoanCalcHistory" inManagedObjectContext:managedObjectContext];
			[_editingObject initializeValues];
		}
	}
	return _editingObject;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[self makeBackButtonEmptyArrow];
	[self leftBarButtonAppsButton];

	self.tableView.tableHeaderView = [self headerView];
}

- (UIView *)headerView {
	UIView *headerView = [UIView new];
	headerView.frame = CGRectMake(0, 0, self.view.bounds.size.width, IS_IPHONE ? 134 : 193);
	headerView.backgroundColor = [UIColor colorWithRed:247.0 / 255.0 green:247.0 / 255.0 blue:247.0 / 255.0 alpha:1.0];

	A3TripleCircleView *circleView = [A3TripleCircleView new];
	circleView.frame = CGRectMake(100, 40, 31, 31);
	[headerView addSubview:circleView];

	A3RoundedSideButton *monthlyButton = [A3RoundedSideButton buttonWithType:UIButtonTypeCustom];
	[monthlyButton setTitle:@"Monthly" forState:UIControlStateNormal];
	[headerView addSubview:monthlyButton];

	[monthlyButton makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(headerView.centerX).with.offset(-72);
		make.bottom.equalTo(headerView.bottom).with.offset(-10);
		make.width.equalTo(@70);
		make.height.equalTo(@20);
	}];

	A3RoundedSideButton *totalButton = [A3RoundedSideButton buttonWithType:UIButtonTypeCustom];
	[totalButton setTitle:@"Total" forState:UIControlStateNormal];
	[headerView addSubview:totalButton];

	[totalButton makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(headerView.centerX).with.offset(72);
		make.bottom.equalTo(headerView.bottom).with.offset(-10);
		make.width.equalTo(@70);
		make.height.equalTo(@20);
	}];

	[headerView layoutIfNeeded];
	
	[totalButton setSelected:YES];
	
	return headerView;
}

- (A3LoanCalcPreferences *)preferences {
	if (!_preferences) {
		_preferences = [A3LoanCalcPreferences new];
	}
	return _preferences;
}

- (A3TableViewRootElement *)root {
	if (!_root) {
		_root = [A3TableViewRootElement new];
		_root.tableView = self.tableView;
		_root.viewController = self;
	}
	return _root;
}


- (void)configureTableData {
	@autoreleasepool {
		_preferences = [A3LoanCalcPreferences new];

		NSMutableArray *sectionsArray = [NSMutableArray new];
		[sectionsArray addObject:@[[self calculationElement]] ];
		[sectionsArray addObject:[self mainElements]];
		if (_preferences.showExtraPayment) {
			[sectionsArray addObject:[self extraPaymentElements]];
		}
		[self.root setSectionsArray:sectionsArray];
	}
}

- (id)notesElement {
	A3TableViewEntryElement *element = [A3TableViewEntryElement new];
	element.title = @"Notes";
	return element;
}

- (id)startDateElement {
	A3TableViewDateEntryElement *element = [A3TableViewDateEntryElement new];
	element.title = @"Start Date";
	return element;
}

- (id)extraPaymentElements {
	return @[
			[self extraPaymentMonthlyElement],
			[self extraPaymentYearlyElement],
			[self extraPaymentOnetimeElement],
			[self advancedElement]
	];
}

- (id)extraPaymentOnetimeElement {
	A3TableViewRootElement *element = [A3TableViewRootElement new];
	element.title = @"One-Time";
	NSMutableArray *sectionsArray = [NSMutableArray new];
	[sectionsArray addObject:@[
			[self extraPaymentAmountsElement],
			[self extraPaymentOnetimeDateElement]
	]];
	element.sectionsArray = sectionsArray;
	return element;
}

- (id)extraPaymentOnetimeDateElement {
	A3TableViewDateEntryElement *element = [A3TableViewDateEntryElement new];
	element.title = @"Date";
	return element;
}

- (id)extraPaymentAmountsElement {
	A3TableViewEntryElement *element = [A3TableViewEntryElement new];
	element.title = @"Amounts";
	return element;
}

- (id)extraPaymentYearlyElement {
	A3TableViewRootElement *element = [A3TableViewRootElement new];
	element.title = @"Yearly";
	NSMutableArray *sectionsArray = [NSMutableArray new];
	[sectionsArray addObject:@[
			[self extraPaymentAmountsElement],
			[self extraPaymentYearlyDateElement]
	]];
	element.sectionsArray = sectionsArray;
	return element;
}

- (id)extraPaymentYearlyDateElement {
	A3TableViewMonthEntryElement *element = [A3TableViewMonthEntryElement new];
	element.title = @"Date";
	return element;
}

- (id)extraPaymentMonthlyElement {
	A3TableViewEntryElement *element = [A3TableViewEntryElement new];
	element.title = @"Monthly";
	return element;
}

- (id)mainElements {
	NSMutableArray *elements = [NSMutableArray new];
	switch (_preferences.calculationFor) {
		case A3_LCCF_MonthlyPayment:
			[elements addObject:[self principalElement]];
			if (_preferences.showDownPayment) {
				[elements addObject:[self downPaymentElement]];
			}
			[elements addObject:[self termElement]];
			break;
		case A3_LCCF_DownPayment:
			[elements addObject:[self principalElement]];
			[elements addObject:[self repaymentElement]];
			if (_preferences.showDownPayment) {
				[elements addObject:[self downPaymentElement]];
			}
			[elements addObject:[self termElement]];
			break;
		case A3_LCCF_Principal:
			if (_preferences.showDownPayment) {
				[elements addObject:[self downPaymentElement]];
			}
			[elements addObject:[self repaymentElement]];
			[elements addObject:[self termElement]];
			break;
		case A3_LCCF_TermYears:
		case A3_LCCF_TermMonths:
			[elements addObject:[self principalElement]];
			if (_preferences.showDownPayment) {
				[elements addObject:[self downPaymentElement]];
			}
			[elements addObject:[self repaymentElement]];
			break;
	}
	[elements addObject:[self interestRateElement]];
	[elements addObject:[self frequencyElement]];

	if (!self.preferences.showExtraPayment) {
		[elements addObject:[self advancedElement]];
	}
	return elements;
}

- (id)advancedElement {
	A3TableViewExpandableElement *advancedElement = [A3TableViewExpandableElement new];
	advancedElement.title = @"ADVANCED";
	advancedElement.elements = @[[self startDateElement], [self notesElement]];
	[advancedElement setCollapsed:YES];
	return advancedElement;
}

- (id)repaymentElement {
	A3TableViewEntryElement *element = [A3TableViewEntryElement new];
	element.title = @"Repayment";
	return element;
}

- (id)frequencyElement {
	A3TableViewSelectElement *element = [A3TableViewSelectElement new];
	element.identifier = A3LoanCalcRowIdFrequency;
	element.title = @"Frequency";
	element.items = @[@"Weekly", @"Biweekly", @"Monthly", @"Bimonthly", @"Quarterly", @"Semiannually", @"Annually"];
	element.selectedIndex = 2;
	return element;
}

- (id)interestRateElement {
	A3TableViewEntryElement *element = [A3TableViewEntryElement new];
	element.title = @"Interest Rate";
	return element;
}

- (id)termElement {
	A3TableViewEntryElement *element = [A3TableViewEntryElement new];
	element.title = @"Term";
	element.inputType = A3TableViewEntryTypeYears;
	return element;
}

- (id)downPaymentElement {
	A3TableViewEntryElement *element = [A3TableViewEntryElement new];
	element.title = @"Down payment";
	element.inputType = A3TableViewEntryTypeCurrency;
	return element;
}

- (id)principalElement {
	A3TableViewEntryElement *element = [A3TableViewEntryElement new];
	element.title = @"Principal";
	element.inputType = A3TableViewEntryTypeCurrency;
	element.onEditingValueChanged = ^(A3TableViewEntryElement *elementMe, UITextField *textField) {

	};
	return element;
}

- (id)calculationElement {
	A3TableViewSelectElement *element = [A3TableViewSelectElement new];
	element.identifier = A3LoanCalcRowIdCalculation;
	element.title = @"Calculation";
	element.items = @[@"Down Payment", @"Principal", @"Repayment", @"Term(years)", @"Term(months)"];
	element.selectedIndex = 2;
	return element;
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
    return [self.root numberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.root numberOfRowsInSection:section];
}

static NSString *CellIdentifier = @"Cell";

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return [self.root cellForRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([cell isKindOfClass:[A3TableViewEntryCell class]]) {
		[(A3TableViewEntryCell *) cell calculateTextFieldFrame];
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self.root didSelectRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return [self.root heightForRowAtIndexPath:indexPath];
}

- (void)selectTableViewController:(A3SelectTableViewController *)viewController selectedItemIndex:(NSInteger)index indexPathOrigin:(NSIndexPath *)indexPathOrigin {
	[self.navigationController popViewControllerAnimated:YES];
	viewController.root.selectedIndex = index;

	[self.tableView reloadRowsAtIndexPaths:@[indexPathOrigin] withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
