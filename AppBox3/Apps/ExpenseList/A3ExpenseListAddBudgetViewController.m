//
//  A3ExpenseListAddBudgetViewController.m
//  A3TeamWork
//
//  Created by jeonghwan kim on 13. 11. 21..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3ExpenseListAddBudgetViewController.h"
#import "UIViewController+A3AppCategory.h"
#import "UIViewController+A3Addition.h"
#import "A3ExpenseListPreference.h"
#import "A3JHTableViewRootElement.h"
#import "A3TableViewInputElement.h"
#import "A3JHTableViewEntryCell.h"
#import "A3JHTableViewExpandableElement.h"
#import "A3JHTableViewSelectElement.h"
#import "A3JHTableViewDateEntryElement.h"
#import "A3ExpenseListMainViewController.h"
#import "A3JHSelectTableViewController.h"
#import "ExpenseListCategories.h"
#import "ExpenseListBudget.h"
#import "A3TableViewDatePickerElement.h"
#import "A3DefaultColorDefines.h"
#import "A3JHTableViewExpandableHeaderCell.h"
#import "A3ItemSelectListViewController.h"
#import "A3TextViewElement.h"
#import "A3Formatter.h"

enum A3ExpenseListAddBudgetCellType {
    AddBudgetCellID_Budget = 100,
    AddBudgetCellID_Categories,
    AddBudgetCellID_PaymentType,
    AddBudgetCellID_Location,
    AddBudgetCellID_Title,
    AddBudgetCellID_Date,
    A3TableElementCellType_Note
};

@interface A3ExpenseListAddBudgetViewController () <A3JHSelectTableViewControllerProtocol>
@property (nonatomic, strong) ExpenseListBudget *currentBudget;
@property (nonatomic, strong) A3JHTableViewRootElement *root;
@property (nonatomic, strong) A3ExpenseListPreference *preferences;
@property (nonatomic, strong) CellTextInputBlock cellTextInputBeginBlock;
@property (nonatomic, strong) CellTextInputBlock cellTextInputChangedBlock;
@property (nonatomic, strong) CellTextInputBlock cellTextInputFinishedBlock;
@property (nonatomic, strong) CellExpandedBlock cellExpandedBlock;
@property (nonatomic, strong) CellValueChangedBlock cellValueChangedBlock;
@property (nonatomic, strong) BasicBlock cellInputDoneButtonPressed;

#pragma mark - Table View Data Element
@property (nonatomic, strong) NSArray *section0_Array;
@property (nonatomic, strong) A3JHTableViewExpandableElement *advancedElement;
@property (nonatomic, strong) NSArray *expandableCellElements;
@property (nonatomic, strong) A3TableViewDatePickerElement* datePickerElement;

@property (nonatomic, strong) UITextView *textViewResponder;

@end

@implementation A3ExpenseListAddBudgetViewController
{
    CGFloat _tableYOffset, _oldTableOffset;
    BOOL _showDatePicker;
    BOOL _isCategoryModified;
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

    if (_currentBudget == nil || _currentBudget.category == nil) {
        self.title = @"Add Budget";
        [self rightBarButtonDoneButton];
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    else {
        self.title = @"Edit Budget";
        [self rightBarButtonDoneButton];
        _isCategoryModified = YES;
    }

    [self makeBackButtonEmptyArrow];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(cancelButtonAction)];

    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    self.tableView.separatorColor = COLOR_TABLE_SEPARATOR;
    if (IS_IPHONE) {
        self.tableView.separatorInset = UIEdgeInsetsMake(0.0, 15.0, 0.0, 0.0);
    }
    else {
        self.tableView.separatorInset = UIEdgeInsetsMake(0.0, 28.0, 0.0, 0.0);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureTableData {
	@autoreleasepool {
        _preferences = [self preferences];

        //[self.root setSectionsArray:@[self.section0_Array, [self tableDataSourceWithDatePicker:NO]]];
        [self.root setSectionsArray:@[[self tableDataSourceWithDatePicker:NO]]];
	}
}

- (void)doneButtonAction:(UIBarButtonItem *)button {
    @autoreleasepool {
        if (IS_IPAD) {
            [self.A3RootViewController dismissCenterViewController];
        } else {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        
        if ([_delegate respondsToSelector:@selector(setExpenseBudgetDataFor:)]) {
            NSArray *section0 = [self section0_Array];
            NSArray *elements = [self expandableCellElements];
            
            ExpenseListBudget *resultBudget;
            if (!_currentBudget) {
                resultBudget = [ExpenseListBudget MR_createEntity];
                resultBudget.budgetId = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]];
            } else {
                resultBudget = _currentBudget;
            }
            
            // Section 0.
            A3TableViewInputElement *budget = section0[0];
            A3JHTableViewSelectElement *category = section0[1];
            A3JHTableViewSelectElement *payment = section0[2];
            
            NSNumber *totalBudget = @([((NSString *)budget.value) floatValue]);
            NSString *categoryName = [self getCategoryNameForIndex:category.selectedIndex];
            NSString *paymentName = [self getPaymentNameForIndex:payment.selectedIndex];
            
            resultBudget.totalAmount = totalBudget;
            resultBudget.category = categoryName;
            resultBudget.paymentType = paymentName;
            
            // Advanced.
            A3TableViewInputElement *title = elements[0];
            A3JHTableViewDateEntryElement *date = elements[1];
            A3JHTableViewElement *location = elements[2];
            A3TableViewInputElement *notes = elements[3];
            
            resultBudget.title = title.value;
            resultBudget.location = location.value;
            resultBudget.date = date.dateValue;
            resultBudget.notes = notes.value;
            resultBudget.updateDate = [NSDate date];

			[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];

            [_delegate performSelector:@selector(setExpenseBudgetDataFor:) withObject:resultBudget];
        }
    }
}

-(void)cancelButtonAction {
    @autoreleasepool {
        if (IS_IPAD) {
            [self.A3RootViewController dismissCenterViewController];
        }
        else {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

-(NSString *) dateStringFromDate:(NSDate *)date {
    
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
    if (!_currentBudget || !_currentBudget.category) {
        
        NSArray *section0 = [self section0_Array];
        NSArray *elements = [self expandableCellElements];
        
        // Section 0.
        A3TableViewInputElement *budget = section0[0];
//        A3JHTableViewSelectElement *category = section0[1];
//        A3JHTableViewSelectElement *payment = section0[2];
        
        NSNumber *totalBudget = @([((NSString *)budget.value) floatValue]);
//        NSString *categoryName = [self getCategoryNameForIndex:category.selectedIndex];
//        NSString *paymentName = [self getPaymentNameForIndex:payment.selectedIndex];
        
        //if (![totalBudget isEqualToNumber:@0] || categoryName || paymentName) {
        if (![totalBudget isEqualToNumber:@0] || _isCategoryModified) {
            return YES;
        }

        // Advanced.
        A3TableViewInputElement *title = elements[0];
        A3JHTableViewDateEntryElement *date = elements[1];
        A3JHTableViewElement *location = elements[2];
        A3TableViewInputElement *notes = elements[3];
        
        if ((title && [title.value length] > 0) || location.value || date.dateValue || (notes && [notes.value length])) {
            return YES;
        }
        
        return NO;
    }
    
    return YES;
}

#pragma mark - TableView Data Elements

//-(NSArray *)tableDataSourceWithDatePicker:(BOOL)showDatePicker {
//    //NSMutableArray *dataSource = [NSMutableArray new];
//    NSArray *elements = [self expandableCellElements];
//    
//    if (showDatePicker) {
//        self.advancedElement.elements = @[elements[0], elements[1], [self datePickerElement], elements[2], elements[3]];
//    }
//    else {
//        self.advancedElement.elements = elements;
//    }
//
//    return @[self.advancedElement];
//}

-(NSArray *)tableDataSourceWithDatePicker:(BOOL)showDatePicker {
    NSMutableArray *result = [NSMutableArray new];
    NSArray *elements = [self expandableCellElements];
    
    if (showDatePicker) {
        self.advancedElement.elements = @[elements[0], elements[1], [self datePickerElement], elements[2], elements[3]];
    }
    else {
        self.advancedElement.elements = elements;
    }
    
    [result addObjectsFromArray:self.section0_Array];
    [result addObject:self.advancedElement];
    return result;
}

-(NSArray *)section0_Array {
    if (!_section0_Array) {
        NSMutableArray *elements = [NSMutableArray new];
        A3TableViewInputElement *budget = [A3TableViewInputElement new];
        budget.inputType = A3TableViewEntryTypeCurrency;
        budget.title = @"Budget";
        budget.valueType = A3TableViewValueTypeCurrency;
        budget.bigButton1Type = A3TableViewBigButtonTypeCurrency;
        budget.onEditingBegin = [self cellTextInputBeginBlock];
        budget.onEditingValueChanged = [self cellTextInputChangedBlock];
        budget.onEditingFinished = [self cellTextInputFinishedBlock];
        budget.bigButton2Type = A3TableViewBigButtonTypeCalculator;
        budget.identifier = AddBudgetCellID_Budget;
        
        NSNumberFormatter *formatter = [NSNumberFormatter new];
        [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        //budget.placeholder = [formatter stringFromNumber: _currentBudget ? _currentBudget.totalAmount : @0 ];
        [elements addObject:budget];
        
        A3JHTableViewSelectElement *category =[A3JHTableViewSelectElement new];
        category.title = @"Categories";
        
        NSArray *dataArray = [self getCategoryEntities];
        NSMutableArray *names = [NSMutableArray new];
        NSAssert(dataArray, @"Category 데이터가 없습니다.");
        for (ExpenseListCategories *aCategory in dataArray) {
            [names addObject:aCategory.name];
        }
        category.items = names;
        category.selectedIndex = 0;
        category.identifier = AddBudgetCellID_Categories;
        [elements addObject:category];
        
        A3JHTableViewSelectElement *paymentType =[A3JHTableViewSelectElement new];
        paymentType.title = @"Payment Type";
        paymentType.items = [self getPaymentArray];
        paymentType.selectedIndex = 0;
        paymentType.identifier = AddBudgetCellID_PaymentType;
        [elements addObject:paymentType];
        
        if (_currentBudget) {
            budget.value = _currentBudget.totalAmount.stringValue;
            category.value = _currentBudget.category;
            paymentType.value = _currentBudget.paymentType;
            
            NSArray *cateArray = [self getCategoryEntities];
            
            for (int i=0; i<cateArray.count; i++) {
                ExpenseListCategories *aData = [cateArray objectAtIndex:i];
                if ([aData.name isEqualToString:category.value]) {
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

//-(id)advancedSection1RowDataWithDatePicker:(BOOL)showDatePicker
-(A3JHTableViewExpandableElement *)advancedElement {
    if (!_advancedElement) {
        _advancedElement = [A3JHTableViewExpandableElement new];
        _advancedElement.title = @"ADVANCED";
        _advancedElement.onExpandCompletion = [self cellExpandedBlock];
        _advancedElement.collapsed = (_currentBudget.title.length>0 || _currentBudget.date || _currentBudget.notes.length>0) ? NO : YES;
    }
    
    return _advancedElement;
}

-(NSArray *)expandableCellElements {
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
        title.placeholder = @"Title";
        title.identifier = AddBudgetCellID_Title;
        
        // Date Print Cell
        A3JHTableViewDateEntryElement *date = [A3JHTableViewDateEntryElement new];
        date.title = @"Date";
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
        
        // Location
        A3JHTableViewElement *location = [A3JHTableViewElement new];
        location.title = @"Location";
        location.identifier = AddBudgetCellID_Location;
        
        // Notes
        A3TextViewElement *notes = [A3TextViewElement new];
        notes.identifier = A3TableElementCellType_Note;
        notes.value = @"";
        notes.placeHolder = @"Notes";
        notes.minHeight = 180.0;
        notes.value = _currentBudget.notes;
        notes.onEditingBegin = ^(A3TextViewElement * element, UITextView *textView){
            _textViewResponder = textView;
            [self hideDatePickerViewCell];
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
        
        _expandableCellElements = @[title, date, location, notes];
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

-(NSArray *)getCategoryEntities {
    NSArray *categories = [ExpenseListCategories MR_findAll];
    if (!categories || categories.count==0) {
        categories = @[NSLocalizedString(@"Food", @"Food"),
                       NSLocalizedString(@"Personal", @"Personal"),
                       NSLocalizedString(@"Pets", @"Pets"),
                       NSLocalizedString(@"School", @"Pets"),
                       NSLocalizedString(@"Service", @"Pets"),
                       NSLocalizedString(@"Shopping", @"Pets"),
                       NSLocalizedString(@"Transportation", @"Pets"),
                       NSLocalizedString(@"Travel", @"Pets"),
                       NSLocalizedString(@"Utilies", @"Pets"),
                       NSLocalizedString(@"Uncategorized", @"Pets")];
        for (NSString *category in categories) {
            ExpenseListCategories *entity = [ExpenseListCategories MR_createEntity];
            entity.name = category;
			[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
        }
        
        categories = [ExpenseListCategories MR_findAll];
    }
    
    return categories;
}

-(NSString *)getCategoryNameForIndex:(NSInteger)index {
    NSArray *categories = [self getCategoryEntities];
    ExpenseListCategories *entity = [categories objectAtIndex:index];
    return entity.name;
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

    return cell;
}

- (void)showKeyboard {
    A3JHTableViewEntryCell *aCell = (A3JHTableViewEntryCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    if (!aCell) {
        return;
    }
    if (![self.title isEqualToString:@"Add Budget"]) {
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
            cell.detailTextLabel.textColor = _showDatePicker ? [UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1] : COLOR_TABLE_DETAIL_TEXTLABEL;
        }
            break;

        case AddBudgetCellID_Location:
        {
            cell.textLabel.textColor = [UIColor colorWithRed:199.0/255.0 green:199.0/255.0 blue:205.0/255.0 alpha:1.0];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
            break;
        case AddBudgetCellID_Categories:
        {
            cell.separatorInset = UIEdgeInsetsMake(0.0, IS_IPAD ? 28.0 : 15.0, 0.0, 0.0);
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
        [self.firstResponder resignFirstResponder];
        [self.textViewResponder resignFirstResponder];
        self.firstResponder = nil;
        self.textViewResponder = nil;

        //[self.root setSectionsArray:@[self.section0_Array, [self tableDataSourceWithDatePicker:NO]]];
        [self.root setSectionsArray:@[[self tableDataSourceWithDatePicker:NO]]];
        [self.tableView beginUpdates];
//        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:1]] withRowAnimation:UITableViewRowAnimationFade];
//        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:3 inSection:1]] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:5 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:6 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.firstResponder resignFirstResponder];
    
    A3JHTableViewElement *element = [self.root elementForIndexPath:indexPath];

    if (element.identifier != AddBudgetCellID_Date) {
        [self hideDatePickerViewCell];
    }

    // Row 6 Date
    //if (indexPath.section == 1 && indexPath.row == 3) {
    if (indexPath.section == 0 && indexPath.row == 6) {
        /*if( [_eventModel objectForKey:EventItem_Location]){
            A3DaysCounterLocationDetailViewController *nextVC = [[A3DaysCounterLocationDetailViewController alloc] initWithNibName:@"A3DaysCounterLocationDetailViewController" bundle:nil];
            nextVC.eventModel = self.eventModel;
            nextVC.locationItem = [[A3DaysCounterModelManager sharedManager] fsvenueFromEventModel:[_eventModel objectForKey:EventItem_Location]];
            nextVC.isEditMode = YES;
            [self.navigationController pushViewController:nextVC animated:YES];
        }
        else{*/
		// TODO:
//            A3DaysCounterSetupLocationViewController *nextVC = [[A3DaysCounterSetupLocationViewController alloc] initWithNibName:@"A3DaysCounterSetupLocationViewController" bundle:nil];
//            //nextVC.eventModel = self.eventModel;
//            UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:nextVC];
//            navCtrl.modalPresentationStyle = UIModalPresentationCurrentContext;
//            [self presentViewController:navCtrl animated:YES completion:nil];
//        //}
        
    }
    else if (element.identifier == AddBudgetCellID_Date) {
        _showDatePicker = !_showDatePicker;
        
        UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
        
        if (_showDatePicker) {
            [self.root setSectionsArray:@[[self tableDataSourceWithDatePicker:YES]]];
            [CATransaction begin];
            [CATransaction setCompletionBlock:^{
                [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:6 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
                cell.detailTextLabel.textColor = [UIColor colorWithRed:0.0/255.0 green:122.0/255 blue:255.0/255.0 alpha:1];
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
    else if ((indexPath.section == 0 && indexPath.row==1) || (indexPath.section == 0 && indexPath.row==2)) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
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
            [self presentSubViewController:selectTableViewController];
        }
        
        return;
    }
    
    [self.root didSelectRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section ==1 && indexPath.row == 1) {
        return IS_RETINA ? 43.5 : 43;
    }
    else {
        return [self.root heightForRowAtIndexPath:indexPath];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {

    if (section == 0) {
        return 35;
//        return IS_RETINA ? 35.5 : 36;   // 71 : 36
    }
    
    return section == 1 ? 0.01 : 0.0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return section == 0 ? 0.01 : 0.0;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([cell isKindOfClass:[A3JHTableViewEntryCell class]]) {
		[(A3JHTableViewEntryCell *) cell calculateTextFieldFrame];
	}
}

#pragma mark - Input Related
-(CellTextInputBlock)cellTextInputBeginBlock {
    if (!_cellTextInputBeginBlock) {
        __weak A3ExpenseListAddBudgetViewController * weakSelf = self;
        _cellTextInputBeginBlock = ^(A3TableViewInputElement *element, UITextField *textField) {
            weakSelf.firstResponder = textField;
            [weakSelf hideDatePickerViewCell];
            
            if (element.identifier == AddBudgetCellID_Title) {
                textField.returnKeyType = UIReturnKeyDone;
            }
        };
    }
    
    return _cellTextInputBeginBlock;
}

-(CellTextInputBlock)cellTextInputChangedBlock {
    if (!_cellTextInputChangedBlock) {
        __weak A3ExpenseListAddBudgetViewController * weakSelf = self;
        _cellTextInputChangedBlock = ^(A3TableViewInputElement *element, UITextField *textField) {
            element.value = textField.text;
            //if ([textField.text length] > 0 || [weakSelf isBudgetModified]) {
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

-(CellTextInputBlock)cellTextInputFinishedBlock {
    if (!_cellTextInputFinishedBlock) {
        __weak A3ExpenseListAddBudgetViewController * weakSelf = self;
        _cellTextInputFinishedBlock = ^(A3TableViewInputElement *element, UITextField *textField) {
            if (weakSelf.firstResponder == textField) {
                weakSelf.firstResponder = nil;
            }
            
            if (textField.text && textField.text.length!=0) {
                element.value = textField.text;
            }
            
            weakSelf.navigationItem.rightBarButtonItem.enabled = [weakSelf isBudgetModified] ? YES : NO;
        };
    }
    
    return _cellTextInputFinishedBlock;
}

-(BasicBlock)cellInputDoneButtonPressed {
    if (!_cellInputDoneButtonPressed) {
        _cellInputDoneButtonPressed = ^(id sender){
        };
    }
    
    return _cellInputDoneButtonPressed;
}

-(CellExpandedBlock)cellExpandedBlock {
    if (!_cellExpandedBlock) {
        __weak A3ExpenseListAddBudgetViewController * weakSelf = self;
        _cellExpandedBlock = ^(A3JHTableViewExpandableElement *element) {
            [weakSelf.tableView reloadData];
        };
    }
    
    return _cellExpandedBlock;
}

-(CellValueChangedBlock)cellValueChangedBlock {
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
//                [weakSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:1]] withRowAnimation:UITableViewRowAnimationFade];
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

@end
