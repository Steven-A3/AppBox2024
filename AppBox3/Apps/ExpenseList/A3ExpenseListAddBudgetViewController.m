//
//  A3ExpenseListAddBudgetViewController.m
//  A3TeamWork
//
//  Created by jeonghwan kim on 13. 11. 21..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3ExpenseListAddBudgetViewController.h"
#import "UIViewController+NumberKeyboard.h"
#import "UIViewController+A3Addition.h"
#import "A3JHTableViewRootElement.h"
#import "A3TableViewInputElement.h"
#import "A3JHTableViewEntryCell.h"
#import "A3JHTableViewExpandableElement.h"
#import "A3JHTableViewSelectElement.h"
#import "A3JHTableViewDateEntryElement.h"
#import "A3ExpenseListMainViewController.h"
#import "A3JHSelectTableViewController.h"
#import "ExpenseListBudget.h"
#import "A3TableViewDatePickerElement.h"
#import "A3DefaultColorDefines.h"
#import "A3JHTableViewExpandableHeaderCell.h"
#import "A3ItemSelectListViewController.h"
#import "A3TextViewElement.h"
#import "A3Formatter.h"
#import "A3SearchViewController.h"
#import "UIViewController+tableViewStandardDimension.h"
#import "UIViewController+iPad_rightSideView.h"
#import "A3CurrencySelectViewController.h"
#import "A3CalculatorViewController.h"
#import "UITableView+utility.h"
#import "A3UserDefaultsKeys.h"
#import "A3SyncManager.h"
#import "A3SyncManager+NSUbiquitousKeyValueStore.h"
#import "A3NumberKeyboardViewController_iPhone.h"
#import "A3NumberKeyboardViewController_iPad.h"

enum A3ExpenseListAddBudgetCellType {
    AddBudgetCellID_Budget = 100,
    AddBudgetCellID_Categories,
    AddBudgetCellID_PaymentType,
//    AddBudgetCellID_Location,
    AddBudgetCellID_Title,
    AddBudgetCellID_Date,
    A3TableElementCellType_Note
};

@interface A3ExpenseListAddBudgetViewController () <A3JHSelectTableViewControllerProtocol, A3TableViewInputElementDelegate,
		A3SearchViewControllerDelegate, A3CalculatorViewControllerDelegate, A3ViewControllerProtocol>
@property (nonatomic, strong) ExpenseListBudget *currentBudget;
@property (nonatomic, strong) A3JHTableViewRootElement *root;
@property (nonatomic, strong) CellTextInputBlock cellTextInputBeginBlock;
@property (nonatomic, strong) CellTextInputBlock cellTextInputChangedBlock;
@property (nonatomic, strong) CellTextInputBlock cellTextInputFinishedBlock;
@property (nonatomic, strong) CellExpandedBlock cellExpandedBlock;
@property (nonatomic, strong) CellValueChangedBlock cellValueChangedBlock;
@property (nonatomic, strong) BasicBlock cellInputDoneButtonPressed;
@property (nonatomic, strong) UINavigationController *modalNavigationController;

#pragma mark - Table View Data Element
@property (nonatomic, strong) NSArray *section0_Array;
@property (nonatomic, strong) A3JHTableViewExpandableElement *advancedElement;
@property (nonatomic, strong) NSArray *expandableCellElements;
@property (nonatomic, strong) A3TableViewDatePickerElement* datePickerElement;

@property (nonatomic, weak) UITextView *textViewResponder;

@property (nonatomic, strong) A3TableViewInputElement *calculatorTargetElement;
@property (nonatomic, strong) NSIndexPath *calculatorTargetIndexPath;

@property (nonatomic, weak) A3TableViewInputElement *editingElement;
@property (nonatomic, weak) UITextField *editingTextField;
@property (nonatomic, copy) UIColor *textColorBeforeEditing;
@property (nonatomic, copy) NSString *textBeforeEditing;

@end

@implementation A3ExpenseListAddBudgetViewController
{
    CGFloat _tableYOffset, _oldTableOffset;
    BOOL _showDatePicker;
    BOOL _isCategoryModified;
	BOOL _isAddBudget;
	BOOL _barButtonEnabled;

	BOOL _isNumberKeyboardVisible;
	BOOL _didPressNumberKey;
	BOOL _didPressClearKey;
}

#pragma mark -

- (id)initWithStyle:(UITableViewStyle)style
{
    NSAssert(NO, @"don't use this");
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        _showDatePicker = NO;
        [self configureTableData];
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style withExpenseListBudget:(ExpenseListBudget *)budget
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        _currentBudget = budget;
        _showDatePicker = NO;
        [self configureTableData];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	_barButtonEnabled = YES;

    if (_currentBudget == nil || _currentBudget.category == nil) {
		_isAddBudget = YES;
        self.title = NSLocalizedString(@"Add Budget", @"Add Budget");
        [self rightBarButtonDoneButton];
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    else {
		_isAddBudget = NO;
        self.title = NSLocalizedString(@"Edit Budget", @"Edit Budget");
        [self rightBarButtonDoneButton];
        _isCategoryModified = YES;
    }

    [self makeBackButtonEmptyArrow];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(cancelButtonAction)];

    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
	self.tableView.separatorColor = A3UITableViewSeparatorColor;
	self.tableView.separatorInset = A3UITableViewSeparatorInset;
	if ([self.tableView respondsToSelector:@selector(cellLayoutMarginsFollowReadableWidth)]) {
		self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
	}
	if ([self.tableView respondsToSelector:@selector(layoutMargins)]) {
		self.tableView.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0);
	}

	if (IS_IPAD) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rightSideViewDidAppear) name:A3NotificationRightSideViewDidAppear object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rightSideViewWillDismiss) name:A3NotificationRightSideViewWillDismiss object:nil];
	}
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cloudStoreDidImport) name:A3NotificationCloudCoreDataStoreDidImport object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cloudStoreDidImport) name:A3NotificationCloudKeyValueStoreDidImport object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)applicationWillResignActive:(NSNotification *)notification {
	[self dismissNumberKeyboardAnimated:NO];
}

- (void)cloudStoreDidImport {
	if (self.editingObject) {
		return;
	}
	// reload data
	_currentBudget = [ExpenseListBudget MR_findFirstByAttribute:@"uniqueID" withValue:_currentBudget.uniqueID];
	[self.tableView reloadData];

	[self enableControls:_barButtonEnabled];
}

- (void)removeObserver {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationCloudCoreDataStoreDidImport object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationCloudKeyValueStoreDidImport object:nil];
	FNLOG();
	if (IS_IPAD) {
		[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationRightSideViewDidAppear object:nil];
		[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationRightSideViewWillDismiss object:nil];
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	if ([self.navigationController.navigationBar isHidden]) {
		[self.navigationController setNavigationBarHidden:NO animated:NO];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	if ([self isMovingFromParentViewController] || [self isBeingDismissed]) {
		FNLOG();
		[self removeObserver];
	}
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
#ifdef __IPHONE_8_0
    // Ensure self.tableView.separatorInset = UIEdgeInsetsZero is applied correctly in iOS 8
    if ([self.tableView respondsToSelector:@selector(layoutMargins)])
    {
		UIEdgeInsets layoutMargins = self.tableView.layoutMargins;
		layoutMargins.left = 0;
		self.tableView.layoutMargins = layoutMargins;
    }
#endif
}

- (void)dealloc {
	[self removeObserver];
}

- (void)rightSideViewDidAppear {
	[self enableControls:NO];
}

- (void)rightSideViewWillDismiss {
	[self enableControls:YES];
}

- (void)enableControls:(BOOL)enable {
	_barButtonEnabled = enable;
	[self.navigationItem.leftBarButtonItem setEnabled:enable];
	[self.navigationItem.rightBarButtonItem setEnabled:enable];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)defaultCurrencyCode {
	NSString *currencyCode = [[A3SyncManager sharedSyncManager] objectForKey:A3ExpenseListUserDefaultsCurrencyCode];
	if (!currencyCode) {
		currencyCode = [A3UIDevice systemCurrencyCode];
	}
	return currencyCode;
}

- (void)configureTableData {
	[self.root setSectionsArray:@[[self tableDataSourceWithDatePicker:NO]]];
}

- (void)doneButtonAction:(UIBarButtonItem *)button {
	[self dismissNumberKeyboardAnimated:NO];
	
    if (self.textViewResponder) {
        [self.textViewResponder resignFirstResponder];
    }
    
	if (IS_IPAD) {
		[[[A3AppDelegate instance] rootViewController_iPad] dismissCenterViewController];
	} else {
		[self dismissViewControllerAnimated:YES completion:nil];
	}

	if ([_delegate respondsToSelector:@selector(setExpenseBudgetDataFor:)]) {
		NSArray *section0 = [self section0_Array];
		NSArray *elements = [self expandableCellElements];

		ExpenseListBudget *resultBudget;
		if (!_currentBudget) {
			resultBudget = [ExpenseListBudget MR_createEntity];
			resultBudget.uniqueID = [[NSUUID UUID] UUIDString];
			resultBudget.updateDate = [NSDate date];
		} else {
			resultBudget = _currentBudget;
		}

		// Section 0.
		A3TableViewInputElement *budget = section0[0];
		A3JHTableViewSelectElement *category = section0[1];
		A3JHTableViewSelectElement *payment = section0[2];

		NSNumber *totalBudget = [self.decimalFormatter numberFromString:[budget value]];
		NSString *categoryName = [self getCategoryNameForIndex:category.selectedIndex];
		NSString *paymentName = [self getPaymentNameForIndex:payment.selectedIndex];
        if (!totalBudget) {
            totalBudget = @0;
        }

		resultBudget.totalAmount = totalBudget;
		resultBudget.category = categoryName;
		resultBudget.paymentType = paymentName;

		// Advanced.
		A3TableViewInputElement *title = elements[0];
		A3JHTableViewDateEntryElement *date = elements[1];
        A3TextViewElement *notes = elements[2];

		resultBudget.title = title.value;
		resultBudget.date = date.dateValue;
		resultBudget.notes = notes.value;
		resultBudget.updateDate = [NSDate date];
        resultBudget.isModified = @(YES);

		[[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];

		[_delegate setExpenseBudgetDataFor:resultBudget];
	}
    
	[self removeObserver];
}

- (void)cancelButtonAction {
	if (IS_IPAD) {
		[[[A3AppDelegate instance] rootViewController_iPad] dismissCenterViewController];
	}
	else {
		[self dismissViewControllerAnimated:YES completion:nil];
	}
	[[A3SyncManager sharedSyncManager] setBool:YES forKey:A3ExpenseListIsAddBudgetCanceledByUser state:A3DataObjectStateModified];

	[self removeObserver];
}

- (NSString *)dateStringFromDate:(NSDate *)date {
    NSString * result;
    
    if ([[[NSLocale currentLocale] objectForKey:NSLocaleCountryCode] isEqualToString:@"KR"]) {
        NSDateFormatter *df = [NSDateFormatter new];
        [df setDateStyle:NSDateFormatterFullStyle];
        NSString *dateFormat = [df dateFormat];
        dateFormat = [dateFormat stringByReplacingOccurrencesOfString:@"EEEE" withString:@"(E)" options:0 range:NSMakeRange(0, [dateFormat length])];
        dateFormat = [dateFormat stringByReplacingOccurrencesOfString:@"MMMM" withString:@"MMM" options:0 range:NSMakeRange(0, [dateFormat length])];
        [df setDateFormat:dateFormat];
        
        result = [df stringFromDate:date];
    }
    else {
        result  = [A3Formatter customFullStyleStringFromDate:date];
    }
    
    return result;
}

#pragma mark - Validation

- (BOOL)isBudgetModified {
    //if (!_currentBudget || !_currentBudget.category) {
    if ([_currentBudget hasChanges]) {
        
        NSArray *section0 = [self section0_Array];
        NSArray *elements = [self expandableCellElements];
        
        // Section 0.
        A3TableViewInputElement *budget = section0[0];

        NSNumber *totalBudget = @([budget.value doubleValue]);

        if (![totalBudget isEqualToNumber:@0] || _isCategoryModified) {
            return YES;
        }

        // Advanced.
        A3TableViewInputElement *title = elements[0];
        A3JHTableViewDateEntryElement *date = elements[1];
        //        A3JHTableViewElement *location = elements[2];
        A3TableViewInputElement *notes = elements[2];
        
        //        if ((title && [title.value length] > 0) || location.value || date.dateValue || (notes && [notes.value length])) {
        if ((title && [title.value length] > 0) || date.dateValue || (notes && [notes.value length])) {
            return YES;
        }
        
        return NO;
    }
    
    return YES;
}

#pragma mark - TableView Data Elements

- (NSArray *)tableDataSourceWithDatePicker:(BOOL)showDatePicker {
    NSMutableArray *result = [NSMutableArray new];
    NSArray *elements = [self expandableCellElements];
    
    if (showDatePicker) {
        //        self.advancedElement.elements = @[elements[0], elements[1], [self datePickerElement], elements[2], elements[3]];
        self.advancedElement.elements = @[elements[0], elements[1], [self datePickerElement], elements[2]];
    }
    else {
        self.advancedElement.elements = elements;
    }
    
    [result addObjectsFromArray:self.section0_Array];
    [result addObject:self.advancedElement];
    return result;
}

- (NSArray *)section0_Array {
    if (!_section0_Array) {
        NSMutableArray *elements = [NSMutableArray new];
        A3TableViewInputElement *budget = [A3TableViewInputElement new];
        budget.inputType = A3TableViewEntryTypeCurrency;
        budget.title = NSLocalizedString(@"Budget", @"Budget");
        budget.valueType = A3TableViewValueTypeCurrency;
        budget.onEditingBegin = [self cellTextInputBeginBlock];
        budget.onEditingValueChanged = [self cellTextInputChangedBlock];
        budget.onEditingFinished = [self cellTextInputFinishedBlock];
        budget.identifier = AddBudgetCellID_Budget;
		budget.currencyCode = [self defaultCurrencyCode];
		budget.delegate = self;
        [elements addObject:budget];
        
        A3JHTableViewSelectElement *category =[A3JHTableViewSelectElement new];
        category.title = NSLocalizedString(@"Categories", @"Categories");
        
        NSArray *dataArray = [self getCategories];
		NSInteger foodIndex = [dataArray indexOfObjectPassingTest:^BOOL(NSString *item, NSUInteger idx, BOOL *stop) {
			return [item isEqualToString:NSLocalizedString(@"Food", @"Food")];
		}];
        category.items = dataArray;
        category.selectedIndex = foodIndex != NSNotFound ? foodIndex : 0;
        category.identifier = AddBudgetCellID_Categories;
        [elements addObject:category];
        
        A3JHTableViewSelectElement *paymentType =[A3JHTableViewSelectElement new];
        paymentType.title = NSLocalizedString(@"Payment Type", @"Payment Type");
        paymentType.items = [self getPaymentArray];
        paymentType.selectedIndex = 0;
        paymentType.identifier = AddBudgetCellID_PaymentType;
        [elements addObject:paymentType];
        
        if (_currentBudget) {
            budget.value = [_currentBudget.totalAmount stringValue];
            category.value = _currentBudget.category;
            paymentType.value = _currentBudget.paymentType;
            
            NSArray *cateArray = [self getCategories];
            
            for (int i=0; i<cateArray.count; i++) {
                if ([cateArray[i] isEqualToString:category.value]) {
                    category.selectedIndex = i;
                    break;
                }
            }
            
            
            NSArray *payType = [self getPaymentArray];
            
            for (int i=0; i<payType.count; i++) {
                NSString *aData = [payType objectAtIndex:i];
                if ([aData isEqualToString:paymentType.value]) {
                    paymentType.selectedIndex = i;
                    break;
                }
            }
        }
        
        _section0_Array = [NSArray arrayWithArray:elements];
    }
    
    return _section0_Array;
}

- (A3JHTableViewExpandableElement *)advancedElement {
    if (!_advancedElement) {
        _advancedElement = [A3JHTableViewExpandableElement new];
        _advancedElement.title = NSLocalizedString(@"ADVANCED", @"ADVANCED");
        _advancedElement.onExpandCompletion = [self cellExpandedBlock];
        _advancedElement.collapsed = NO;
    }
    
    return _advancedElement;
}

- (NSArray *)expandableCellElements {
    if (!_expandableCellElements) {
        // Title Cell
        A3TableViewInputElement *title = [A3TableViewInputElement new];
        title.inputType = A3TableViewEntryTypeText;
        title.prevEnabled = YES;
        title.nextEnabled = YES;
        title.onEditingBegin = [self cellTextInputBeginBlock];
        title.onEditingValueChanged = [self cellTextInputChangedBlock];
        title.onEditingFinished = [self cellTextInputFinishedBlock];
        _currentBudget.title = [_currentBudget.title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        title.value = _currentBudget.title;
        //title.placeholder = (_currentBudget == nil || _currentBudget.title.length == 0) ? @"Title" : _currentBudget.title;
        title.placeholder = NSLocalizedString(@"Title", @"Title");
        title.identifier = AddBudgetCellID_Title;
        
        // Date Print Cell
        A3JHTableViewDateEntryElement *date = [A3JHTableViewDateEntryElement new];
        date.title = NSLocalizedString(@"Date", @"Date");
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        if (IS_IPAD) {
            [formatter setDateStyle:NSDateFormatterFullStyle];
            [formatter setTimeStyle:NSDateFormatterNoStyle];
            date.detailText = [formatter stringFromDate:(_currentBudget.date == nil) ? [NSDate date] : _currentBudget.date];
        }
        else {
            //date.detailText = [A3Formatter customFullStyleStringFromDate:_currentBudget.date];
            date.detailText = [self dateStringFromDate:(_currentBudget.date == nil) ? [NSDate date] : _currentBudget.date];
        }
        
        //date.dateValue = (_currentBudget.date == nil) ? [NSDate date] : _currentBudget.date;
        date.dateValue = _currentBudget.date;
        date.identifier = AddBudgetCellID_Date;
        
        //        // Location
        //        A3JHTableViewElement *location = [A3JHTableViewElement new];
        //        location.title = @"Location";
        //        location.identifier = AddBudgetCellID_Location;
        
        // Notes
        A3TextViewElement *notes = [A3TextViewElement new];
        notes.identifier = A3TableElementCellType_Note;
        notes.value = _currentBudget.notes;
        notes.onEditingBegin = ^(A3TextViewElement * element, UITextView *textView){
			[self dismissNumberKeyboardAnimated:YES];
            [self hideDatePickerViewCell];
			self.textViewResponder = textView;
        };
        __weak A3ExpenseListAddBudgetViewController * weakSelf = self;
        notes.onEditingChange = ^(A3TextViewElement * element, UITextView *textView){
            if ([weakSelf isBudgetModified]) {
                self.navigationItem.rightBarButtonItem.enabled = YES;
            }
            else {
                self.navigationItem.rightBarButtonItem.enabled = NO;
            }
        };

        _expandableCellElements = @[title, date, notes];
    }
    
    return _expandableCellElements;
}

-(A3TableViewDatePickerElement *)datePickerElement {
    if (!_datePickerElement) {
        _datePickerElement = [A3TableViewDatePickerElement new];
        _datePickerElement.dateValue = _currentBudget.date;
        _datePickerElement.cellValueChangedBlock = [self cellValueChangedBlock];
    }
    
    return _datePickerElement;
}

- (A3JHTableViewRootElement *)root {
	if (!_root) {
		_root = [A3JHTableViewRootElement new];
		_root.tableView = self.tableView;
		_root.viewController = self;
	}
	return _root;
}

- (NSArray *)getCategories {
	NSMutableArray *categories = [
			@[NSLocalizedString(@"Food", nil),
			NSLocalizedString(@"Personal", @"Personal"),
			NSLocalizedString(@"Pets", @"Pets"),
			NSLocalizedString(@"School", @"School"),
			NSLocalizedString(@"Service", @"Service"),
			NSLocalizedString(@"Shopping", @"Shopping"),
			NSLocalizedString(@"Transportation", @"Transportation"),
			NSLocalizedString(@"Travel", @"Travel"),
			NSLocalizedString(@"Utilities", @"Utilities"),
			NSLocalizedString(@"Uncategorized", @"Uncategorized")] mutableCopy];

	[categories sortUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
		return [obj1 compare:obj2];
	}];

    return categories;
}

-(NSString *)getCategoryNameForIndex:(NSInteger)index {
    NSArray *categories = [self getCategories];
    return categories[index];
}

-(NSArray *)getPaymentArray {
    return @[NSLocalizedString(@"Cash", nil),
             NSLocalizedString(@"Check", nil),
             NSLocalizedString(@"Credit", nil),
             NSLocalizedString(@"Debit Card", nil),
             NSLocalizedString(@"Gift Card", nil)];
}

-(NSString *)getPaymentNameForIndex:(NSInteger)index {
    NSArray *payments = [self getPaymentArray];
    return [payments objectAtIndex:index];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.root numberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.root numberOfRowsInSection:section];
}

static NSString *CellIdentifier = @"Cell";

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [self.root cellForRowAtIndexPath:indexPath];
    [self updateTableViewCell:cell atIndexPath:indexPath];
    cell.textLabel.font = [UIFont systemFontOfSize:17.0];
    
#ifdef __IPHONE_8_0
    // Ensure self.tableView.separatorInset = UIEdgeInsetsZero is applied correctly in iOS 8
    if ([cell respondsToSelector:@selector(layoutMargins)])
    {
		UIEdgeInsets layoutMargins = cell.layoutMargins;
		layoutMargins.left = 0;
        cell.layoutMargins = layoutMargins;
    }
#endif

    return cell;
}

- (void)showKeyboard {
    A3JHTableViewEntryCell *aCell = (A3JHTableViewEntryCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    if (!aCell) {
        return;
    }
    if (!_isAddBudget) {
        return;
    }
    
    [aCell.textField becomeFirstResponder];
}

- (void)updateTableViewCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath {
    A3JHTableViewElement * element = [self.root elementForIndexPath:indexPath];
    switch (element.identifier) {
        case AddBudgetCellID_Date:
        {
            cell.textLabel.textColor = [UIColor blackColor];
            cell.detailTextLabel.textColor = _showDatePicker ? [A3AppDelegate instance].themeColor : COLOR_TABLE_DETAIL_TEXTLABEL;
        }
            break;

//        case AddBudgetCellID_Location:
//        {
//            cell.textLabel.textColor = [UIColor colorWithRed:199.0/255.0 green:199.0/255.0 blue:205.0/255.0 alpha:1.0];
//            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//        }
//            break;
        case AddBudgetCellID_Categories:
        {
            cell.separatorInset = A3UITableViewSeparatorInset;
            cell.detailTextLabel.textColor = COLOR_TABLE_DETAIL_TEXTLABEL;
        }
            break;

        case AddBudgetCellID_PaymentType:
            cell.separatorInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        default:
        {
            cell.textLabel.textColor = [UIColor blackColor];
            
            if ([cell isKindOfClass:[A3JHTableViewEntryCell class]]) {
                ((A3JHTableViewEntryCell *)cell).textField.textColor = COLOR_TABLE_DETAIL_TEXTLABEL;
                ((A3JHTableViewEntryCell *)cell).textField.font = [UIFont systemFontOfSize:17.0];
            }
            else if ([cell isKindOfClass:[A3JHTableViewExpandableHeaderCell class]]) {
				[((A3JHTableViewExpandableHeaderCell *)cell).expandButton setHidden:YES];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.detailTextLabel.textColor = COLOR_TABLE_DETAIL_TEXTLABEL;
            }
            else if ([cell isKindOfClass:[A3JHTableViewCell class]]  ) {
                cell.detailTextLabel.textColor = COLOR_TABLE_DETAIL_TEXTLABEL;
            }
            else {
                cell.detailTextLabel.textColor = [UIColor blackColor];
            }
        }
            break;
    }
}

- (void)hideDatePickerViewCell {
    if (_showDatePicker) {
        _showDatePicker = NO;
        [self.editingObject resignFirstResponder];
        [self.textViewResponder resignFirstResponder];
        self.editingObject = nil;
        self.textViewResponder = nil;

        [self.root setSectionsArray:@[[self tableDataSourceWithDatePicker:NO]]];
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:5 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:6 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    A3JHTableViewElement *element = [self.root elementForIndexPath:indexPath];

	if ([element isKindOfClass:[A3JHTableViewExpandableElement class]]) {
		return;
	}
    if (element.identifier != AddBudgetCellID_Date) {
        [self hideDatePickerViewCell];
    }

    // Row 6 Date
    if (element.identifier == AddBudgetCellID_Date) {
		[_editingTextField resignFirstResponder];
		[_textViewResponder resignFirstResponder];
		[self dismissNumberKeyboardAnimated:YES];
		
        _showDatePicker = !_showDatePicker;
        
        UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
        
        if (_showDatePicker) {
            [self.root setSectionsArray:@[[self tableDataSourceWithDatePicker:YES]]];
            [CATransaction begin];
            [CATransaction setCompletionBlock:^{
                [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:6 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
                cell.detailTextLabel.textColor = [A3AppDelegate instance].themeColor;
            }];
            [tableView beginUpdates];
            [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:6 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            [tableView endUpdates];
            [CATransaction commit];
        }
        else {
            cell.detailTextLabel.textColor = COLOR_TABLE_DETAIL_TEXTLABEL;
            [self.root setSectionsArray:@[[self tableDataSourceWithDatePicker:NO]]];
            [tableView beginUpdates];
            [tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:5 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            [tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:6 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            [tableView endUpdates];
        }
    }
    //else if ((indexPath.section == 0 && indexPath.row==1) || (indexPath.section == 0 && indexPath.row==2)) {
    else if (element.identifier == AddBudgetCellID_Categories || element.identifier == AddBudgetCellID_PaymentType) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];

		[self dismissNumberKeyboardAnimated:NO];

        if (IS_IPHONE) {
            A3ItemSelectListViewController *selectTableViewController = [[A3ItemSelectListViewController alloc] initWithStyle:UITableViewStyleGrouped];
            selectTableViewController.root = _section0_Array[indexPath.row];
            selectTableViewController.delegate = self;
            selectTableViewController.indexPathOfOrigin = indexPath;
            [self.navigationController pushViewController:selectTableViewController animated:YES];
        }
        else {
            A3ItemSelectListViewController *selectTableViewController = [[A3ItemSelectListViewController alloc] initWithStyle:UITableViewStyleGrouped];
            selectTableViewController.root = _section0_Array[indexPath.row];
            selectTableViewController.delegate = self;
            selectTableViewController.indexPathOfOrigin = indexPath;

			if (IS_IPHONE) {
				_modalNavigationController = [[UINavigationController alloc] initWithRootViewController:selectTableViewController];
				[self presentViewController:_modalNavigationController animated:YES completion:NULL];
				[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectTableViewControllerDidDismiss) name:A3NotificationChildViewControllerDidDismiss object:selectTableViewController];
			} else {
				[[[A3AppDelegate instance] rootViewController_iPad] presentRightSideViewController:selectTableViewController];
			}
        }
        
        return;
    }
    
    [self.root didSelectRowAtIndexPath:indexPath];
}

- (void)selectTableViewControllerDidDismiss {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationChildViewControllerDidDismiss object:_modalNavigationController.childViewControllers[0]];
	_modalNavigationController = nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1 && indexPath.row == 1) {
        return IS_RETINA ? 43.5 : 43;
    }
    else {
        return [self.root heightForRowAtIndexPath:indexPath];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {

    if (section == 0) {
        return 35;
    }
    
    return section == 1 ? 0.01 : 0.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 38.0;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([cell isKindOfClass:[A3JHTableViewEntryCell class]]) {
		[(A3JHTableViewEntryCell *) cell calculateTextFieldFrame];
	}
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	[self dismissNumberKeyboardAnimated:YES];
}

#pragma mark - Input Related

- (CellTextInputBlock)cellTextInputBeginBlock {
    if (!_cellTextInputBeginBlock) {
        __weak A3ExpenseListAddBudgetViewController * weakSelf = self;
        _cellTextInputBeginBlock = ^(A3TableViewInputElement *element, UITextField *textField) {
            [weakSelf hideDatePickerViewCell];

			if (element.inputType != A3TableViewEntryTypeText) {
				[weakSelf.textViewResponder resignFirstResponder];
				
				if (textField != weakSelf.editingTextField) {
					[weakSelf.editingTextField resignFirstResponder];
				}
				weakSelf.textBeforeEditing = textField.text;
				weakSelf.textColorBeforeEditing = textField.textColor;

				textField.text = [weakSelf.decimalFormatter stringFromNumber:@0];
				textField.textColor = [[A3AppDelegate instance] themeColor];

				A3NumberKeyboardViewController *keyboardVC;
				if (IS_IPHONE) {
					keyboardVC = [[A3NumberKeyboardViewController_iPhone alloc] initWithNibName:@"A3NumberKeyboardViewController_iPhone" bundle:nil];
				} else {
					keyboardVC = [[A3NumberKeyboardViewController_iPad alloc] initWithNibName:@"A3NumberKeyboardViewController_iPad" bundle:nil];
				}
				[weakSelf presentNumberKeyboard:keyboardVC forTextField:textField];
				[weakSelf addNumberKeyboardNotificationObservers];
			} else {
				[weakSelf dismissNumberKeyboardAnimated:YES];
			}
			weakSelf.editingElement = element;
			weakSelf.editingTextField = textField;

			if (element.identifier == AddBudgetCellID_Title) {
				textField.clearButtonMode = UITextFieldViewModeWhileEditing;
				textField.returnKeyType = UIReturnKeyDefault;
			}
        };
    }
    
    return _cellTextInputBeginBlock;
}

- (CellTextInputBlock)cellTextInputChangedBlock {
    if (!_cellTextInputChangedBlock) {
        __weak A3ExpenseListAddBudgetViewController * weakSelf = self;
        _cellTextInputChangedBlock = ^(A3TableViewInputElement *element, UITextField *textField) {
            element.value = textField.text;

            if ([weakSelf isBudgetModified]) {
                weakSelf.navigationItem.rightBarButtonItem.enabled = YES;
            }
            else {
                weakSelf.navigationItem.rightBarButtonItem.enabled = NO;
            }
        };
    }
    
    return _cellTextInputChangedBlock;
}

- (CellTextInputBlock)cellTextInputFinishedBlock {
    if (!_cellTextInputFinishedBlock) {
        __weak A3ExpenseListAddBudgetViewController * weakSelf = self;
        _cellTextInputFinishedBlock = ^(A3TableViewInputElement *element, UITextField *textField) {
			[weakSelf removeNumberKeyboardNotificationObservers];

			if (element.inputType != A3TableViewEntryTypeText) {
				if (weakSelf.textColorBeforeEditing) {
					textField.textColor = weakSelf.textColorBeforeEditing;
					weakSelf.textColorBeforeEditing = nil;
				}
				if (!_didPressClearKey && !_didPressNumberKey && weakSelf.textBeforeEditing) {
					NSNumber *number = [weakSelf.currencyFormatter numberFromString:weakSelf.textBeforeEditing];
					textField.text = [weakSelf.decimalFormatter stringFromNumber:number];
					weakSelf.textBeforeEditing = nil;
				}
			}

            if (textField.text && textField.text.length != 0 && [element inputType] != A3TableViewEntryTypeText) {
				NSNumber *number = [weakSelf.decimalFormatter numberFromString:textField.text];
                element.value = [weakSelf.decimalFormatter stringFromNumber:number];

				textField.text = [weakSelf.currencyFormatter stringFromNumber:number];
            }
            
            switch ([element identifier]) {
                case AddBudgetCellID_Budget:
                    if (![element value] || [element.value length] == 0) {
                        element.value = @"0";
                    }
                    break;

                default:
					element.value = textField.text;
                    break;
            }

            weakSelf.navigationItem.rightBarButtonItem.enabled = [weakSelf isBudgetModified] ? YES : NO;
			weakSelf.editingObject = nil;
			weakSelf.editingTextField = nil;
        };
    }
    
    return _cellTextInputFinishedBlock;
}

- (BasicBlock)cellInputDoneButtonPressed {
    if (!_cellInputDoneButtonPressed) {
        _cellInputDoneButtonPressed = ^(id sender){
        };
    }
    
    return _cellInputDoneButtonPressed;
}

- (CellExpandedBlock)cellExpandedBlock {
    if (!_cellExpandedBlock) {
        __weak A3ExpenseListAddBudgetViewController * weakSelf = self;
        _cellExpandedBlock = ^(A3JHTableViewExpandableElement *element) {
            [weakSelf.tableView reloadData];
        };
    }
    
    return _cellExpandedBlock;
}

- (CellValueChangedBlock)cellValueChangedBlock {
    if (!_cellValueChangedBlock) {
        __weak A3ExpenseListAddBudgetViewController * weakSelf = self;
        _cellValueChangedBlock = ^(A3JHTableViewElement *element) {
            if ([element isKindOfClass:[A3TableViewDatePickerElement class]]) {
                A3TableViewDatePickerElement *datePickerElement = (A3TableViewDatePickerElement *)element;
                NSArray *subElements = [weakSelf expandableCellElements];
                A3JHTableViewDateEntryElement *dateCell = [subElements objectAtIndex:1];
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                
                if (IS_IPAD) {
                    [formatter setDateStyle:NSDateFormatterFullStyle];
                    [formatter setTimeStyle:NSDateFormatterNoStyle];
                    dateCell.detailText = [formatter stringFromDate:datePickerElement.dateValue];
                    dateCell.dateValue = datePickerElement.dateValue;
                }
                else {
                    dateCell.detailText = [weakSelf dateStringFromDate:datePickerElement.dateValue];
                    dateCell.dateValue = datePickerElement.dateValue;
                }

                [weakSelf.tableView beginUpdates];
                [weakSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:5 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                [weakSelf.tableView endUpdates];
                
                if ([weakSelf isBudgetModified]) {
                    weakSelf.navigationItem.rightBarButtonItem.enabled = YES;
                }
                else {
                    weakSelf.navigationItem.rightBarButtonItem.enabled = NO;
                }
            }
        };
    }
    return _cellValueChangedBlock;
}

- (void)presentNumberKeyboard:(A3NumberKeyboardViewController *)keyboardVC forTextField:(UITextField *)textField {
	if (_isNumberKeyboardVisible) {
		return;
	}

	self.numberKeyboardViewController = keyboardVC;

	CGRect bounds = [A3UIDevice screenBoundsAdjustedWithOrientation];
	CGFloat keyboardHeight = keyboardVC.keyboardHeight;
	UIView *keyboardView = keyboardVC.view;
	[self.view.superview addSubview:keyboardView];
	
	keyboardVC.delegate = self;
	keyboardVC.textInputTarget = textField;
	keyboardVC.keyboardType = A3NumberKeyboardTypeCurrency;

	keyboardView.frame = CGRectMake(0, self.view.bounds.size.height, bounds.size.width, keyboardHeight);
	[UIView animateWithDuration:0.3 animations:^{
		CGRect frame = keyboardView.frame;
		frame.origin.y -= keyboardHeight;
		keyboardView.frame = frame;
	} completion:^(BOOL finished) {
		[self addNumberKeyboardNotificationObservers];
		_isNumberKeyboardVisible = YES;
	}];
}

- (void)dismissNumberKeyboardAnimated:(BOOL)animated {
	if (!_isNumberKeyboardVisible) {
		return;
	}

	self.cellTextInputFinishedBlock(_editingElement, _editingTextField);

	A3NumberKeyboardViewController *keyboardViewController = self.numberKeyboardViewController;
	UIView *keyboardView = keyboardViewController.view;

	void(^completion)() = ^{
		[keyboardView removeFromSuperview];
		self.numberKeyboardViewController = nil;
		_isNumberKeyboardVisible = NO;
	};
	if (animated) {
		[UIView animateWithDuration:0.3 animations:^{
			CGRect frame = keyboardView.frame;
			frame.origin.y += keyboardViewController.keyboardHeight;
			keyboardView.frame = frame;
		} completion:^(BOOL finished) {
			completion();
		}];
	} else {
		completion();
	}
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];

	if (_isNumberKeyboardVisible && self.numberKeyboardViewController.view.superview) {
		UIView *keyboardView = self.numberKeyboardViewController.view;
		CGFloat keyboardHeight = self.numberKeyboardViewController.keyboardHeight;

		FNLOGRECT(self.view.bounds);
		FNLOG(@"%f", keyboardHeight);
		CGRect bounds = [A3UIDevice screenBoundsAdjustedWithOrientation];
		keyboardView.frame = CGRectMake(0, bounds.size.height - keyboardHeight, bounds.size.width, keyboardHeight);
		[self.numberKeyboardViewController rotateToInterfaceOrientation:toInterfaceOrientation];
	}
}

#pragma mark - A3KeyboardDelegate

- (void)A3KeyboardController:(id)controller clearButtonPressedTo:(UIResponder *)keyInputDelegate {
	_editingTextField.text = [self.decimalFormatter stringFromNumber:@0];
	_didPressClearKey = YES;
	_didPressNumberKey = NO;
}

- (void)A3KeyboardController:(id)controller doneButtonPressedTo:(UIResponder *)keyInputDelegate {
	[self dismissNumberKeyboardAnimated:YES];
}

- (void)keyboardViewControllerDidValueChange:(A3NumberKeyboardViewController *)vc {
	[_editingElement textFieldEditingChanged:_editingTextField];
	_didPressNumberKey = YES;
	_didPressClearKey = NO;
}

#pragma mark - A3SelectTableViewControllerProtocol

- (void)selectTableViewController:(A3JHSelectTableViewController *)viewController selectedItemIndex:(NSInteger)index indexPathOrigin:(NSIndexPath *)indexPathOrigin {
	viewController.root.selectedIndex = index;
    _isCategoryModified = YES;
    if ([self isBudgetModified]) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    [self.tableView reloadData];
}

#pragma mark - Number Keyboard Currency Button Notification

- (void)currencySelectButtonAction:(NSNotification *)notification {
	[self dismissNumberKeyboardAnimated:NO];
	
	A3CurrencySelectViewController *viewController = [self presentCurrencySelectViewControllerWithCurrencyCode:notification.object];
	viewController.delegate = self;
}

- (void)searchViewController:(UIViewController *)viewController itemSelectedWithItem:(NSString *)currencyCode {
	[[A3SyncManager sharedSyncManager] setObject:currencyCode forKey:A3ExpenseListUserDefaultsCurrencyCode state:A3DataObjectStateModified];

	[[NSNotificationCenter defaultCenter] postNotificationName:A3NotificationExpenseListCurrencyCodeChanged object:nil];

	_section0_Array = nil;
	[self setCurrencyFormatter:nil];
	[self configureTableData];
	[self.tableView reloadData];
}

#pragma mark - Number Keyboard, Calculator Button Notification

- (void)calculatorButtonAction {
	_calculatorTargetIndexPath = [self.tableView indexPathForCellSubview:(UIView *) self.editingObject];
	_calculatorTargetElement = (A3TableViewInputElement *) [self.root elementForIndexPath:_calculatorTargetIndexPath];
	
	[self dismissNumberKeyboardAnimated:NO];
	A3CalculatorViewController *viewController = [self presentCalculatorViewController];
	viewController.delegate = self;
}

- (void)calculatorDidDismissWithValue:(NSString *)value {
	A3JHTableViewEntryCell *cell = (A3JHTableViewEntryCell *) [self.root cellForRowAtIndexPath:_calculatorTargetIndexPath];
	cell.textField.text = value;
	self.cellTextInputFinishedBlock(_calculatorTargetElement, cell.textField);
	[self.tableView reloadRowsAtIndexPaths:@[_calculatorTargetIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (NSNumberFormatter *)currencyFormatterForTableViewInputElement {
	return self.currencyFormatter;
}

@end
