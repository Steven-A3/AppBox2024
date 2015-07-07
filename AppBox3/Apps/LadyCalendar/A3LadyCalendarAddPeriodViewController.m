//
//  A3LadyCalendarAddPeriodViewController.m
//  A3TeamWork
//
//  Created by coanyaa on 2013. 11. 18..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3LadyCalendarAddPeriodViewController.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+NumberKeyboard.h"
#import "A3LadyCalendarDefine.h"
#import "A3LadyCalendarModelManager.h"
#import "LadyCalendarPeriod.h"
#import "A3DateHelper.h"
#import "A3NumberKeyboardViewController.h"
#import "UIColor+A3Addition.h"
#import "A3UserDefaultsKeys.h"
#import "A3AppDelegate+appearance.h"
#import "A3WalletNoteCell.h"
#import "UIViewController+tableViewStandardDimension.h"
#import "NSDate+formatting.h"
#import "NSDateFormatter+A3Addition.h"
#import "LadyCalendarPeriod+extension.h"
#import "A3SyncManager.h"
#import "A3SyncManager+NSUbiquitousKeyValueStore.h"
#import "LadyCalendarAccount.h"
#import "A3UserDefaults.h"

extern NSString *const A3WalletItemFieldNoteCellID;

@interface A3LadyCalendarAddPeriodViewController () <A3ViewControllerProtocol>

@property (strong, nonatomic) NSMutableArray *sectionsArray;
@property (strong, nonatomic) NSString *inputItemKey;
@property (strong, nonatomic) A3NumberKeyboardViewController *keyboardVC;
@property (strong, nonatomic) LadyCalendarPeriod *prevPeriod;
@property (copy, nonatomic) NSString *textBeforeEditingTextField;

@end

@implementation A3LadyCalendarAddPeriodViewController
{
    BOOL _isCustomCycleLengthMode;
    BOOL _isLatestPeriod;
}

- (id)init {
	self = [super initWithStyle:UITableViewStyleGrouped];
	if (self) {

	}

	return self;
}

- (void)initSectionsArray
{
    self.sectionsArray = [NSMutableArray arrayWithArray:@[
                                                          @{ItemKey_Items : [NSMutableArray arrayWithArray:@[
                                                                                                             @{
                                                                                                                 ItemKey_Title : NSLocalizedString(@"LadyCalendar_Start Date", @"Start Date"),
                                                                                                                 ItemKey_Type : @(PeriodCellType_StartDate)
                                                                                                                 },
                                                                                                             @{
                                                                                                                 ItemKey_Title : NSLocalizedString(@"End Date", @"End Date"),
                                                                                                                 ItemKey_Type : @(PeriodCellType_EndDate)
                                                                                                                 }]]},
                                                          @{ItemKey_Items : [NSMutableArray arrayWithArray:@[
                                                                                                             @{
                                                                                                                 ItemKey_Title : NSLocalizedString(@"Cycle Length", @"Cycle Length"),
                                                                                                                 ItemKey_Type : @(PeriodCellType_CycleLength)
                                                                                                                 }]]},
                                                          /*@{ItemKey_Items : [NSMutableArray arrayWithArray:@[@{ItemKey_Title : @"Ovulation",ItemKey_Type : @(PeriodCellType_Ovulation)}]]},*/
                                                          @{ItemKey_Items : [NSMutableArray arrayWithArray:@[
                                                                                                             @{
                                                                                                                 ItemKey_Title : NSLocalizedString(@"Notes", @"Notes"),
                                                                                                                 ItemKey_Type : @(PeriodCellType_Notes)
                                                                                                                 }]]} ]];
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	self.title = (_isEditMode ? NSLocalizedString(@"Edit Period", @"Edit Period") : NSLocalizedString(@"Add Period", @"Add Period"));

	self.tableView.showsVerticalScrollIndicator = NO;
	self.tableView.separatorColor = A3UITableViewSeparatorColor;
	self.tableView.separatorInset = A3UITableViewSeparatorInset;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;

	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
																						  target:self
																						  action:@selector(cancelAction:)];
	[self rightBarButtonDoneButton];
	[self initSectionsArray];

    if ( _isEditMode /*&& ![_periodItem.isPredict boolValue]*/ ) {
		[self.sectionsArray addObject:@{ItemKey_Items : [NSMutableArray arrayWithArray:@[
				@{
						ItemKey_Title : NSLocalizedString(@"Delete Period", @"Delete Period"),
						ItemKey_Type : @(PeriodCellType_Delete)
				}]]}];
	} else {
		_periodItem = [LadyCalendarPeriod MR_createEntityInContext:[NSManagedObjectContext MR_defaultContext]];
		_periodItem.updateDate = [NSDate date];
		_periodItem.startDate = [A3DateHelper dateMake12PM:[NSDate date]];
//		[_periodItem reassignUniqueIDWithStartDate];
		_periodItem.cycleLength = @28;
		_periodItem.isPredict = @NO;
		_periodItem.endDate = [A3DateHelper dateByAddingDays:4 fromDate:_periodItem.startDate];
		_periodItem.accountID = _dataManager.currentAccount.uniqueID;
	}

	if ( _isEditMode ) {
		self.prevPeriod = [_dataManager previousPeriodFromDate:_periodItem.startDate];
        LadyCalendarPeriod *latestPeriod = [[_dataManager periodListSortedByStartDateIsAscending:YES] lastObject];
        _isLatestPeriod = [_periodItem.startDate isEqualToDate:latestPeriod.startDate];
	}
	else
	{
		NSInteger ovulationDays = 14;
		_periodItem.ovulation = [A3DateHelper dateByAddingDays:ovulationDays fromDate:_periodItem.startDate];
        self.prevPeriod = [_dataManager previousPeriodFromDate:_periodItem.startDate];
        if (self.prevPeriod) {
            [self calculateCycleLengthFromDate:_periodItem.startDate];
        }
	}
	self.tableView.separatorInset = UIEdgeInsetsMake(0, (IS_IPHONE ? 15.0 : 28.0), 0, 0);

	[self.tableView registerClass:[A3WalletNoteCell class] forCellReuseIdentifier:A3WalletItemFieldNoteCellID];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)applicationWillResignActive {
	NSString *startingAppName = [[A3UserDefaults standardUserDefaults] objectForKey:kA3AppsStartingAppName];
	if ([startingAppName length] && ![startingAppName isEqualToString:A3AppName_LadiesCalendar]) {
		[self cancelAction:nil];
	}
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
	self.keyboardVC = nil;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[self.A3RootViewController viewWillLayoutSubviews];
}

- (void)reloadItemAtCellType:(NSInteger)cellType
{
    NSMutableArray *array = [NSMutableArray array];
    for (NSInteger section=0; section < [_sectionsArray count]; section++) {
        NSArray *items = [[_sectionsArray objectAtIndex:section] objectForKey:ItemKey_Items];

        for (NSInteger row = 0; row < [items count]; row++) {
            NSDictionary *item = [items objectAtIndex:row];
            if ( [[item objectForKey:ItemKey_Type] integerValue] == cellType ) {
                [array addObject:[NSIndexPath indexPathForRow:row inSection:section]];
            }
        }
    }
    if ( [array count] > 0 )
        [self.tableView reloadRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationNone];
}

- (void)closeDateInputCell
{
    NSInteger findRow = NSNotFound;
    NSInteger findSection = NSNotFound;
    for (NSInteger section=0; section < [_sectionsArray count]; section++) {
        NSArray *items = [[_sectionsArray objectAtIndex:section] objectForKey:ItemKey_Items];

        for (NSInteger row = 0; row < [items count]; row++) {
            NSDictionary *item = [items objectAtIndex:row];
            if ( [[item objectForKey:ItemKey_Type] integerValue] == PeriodCellType_DateInput ) {
                findRow = row;
                findSection = section;
                break;
            }
        }
    }
    if ( findSection == NSNotFound || findRow == NSNotFound )
        return;

    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:findRow inSection:findSection];
    NSMutableArray *items = [[_sectionsArray objectAtIndex:indexPath.section] objectForKey:ItemKey_Items];
    [items removeObjectAtIndex:indexPath.row];

    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];

    NSInteger inputCellType = 0;

    if ( [self.inputItemKey isEqualToString:PeriodItem_StartDate] )
        inputCellType = PeriodCellType_StartDate;
    else if ( [self.inputItemKey isEqualToString:PeriodItem_EndDate] )
        inputCellType = PeriodCellType_EndDate;

    self.inputItemKey = nil;
    [self reloadItemAtCellType:inputCellType];

}

- (void)resignAllAction
{
    for (NSInteger section=0; section < [_sectionsArray count]; section++) {
        NSArray *items = [[_sectionsArray objectAtIndex:section] objectForKey:ItemKey_Items];

        for (NSInteger row = 0; row < [items count]; row++) {
            NSDictionary *item = [items objectAtIndex:row];
            NSInteger cellType = [[item objectForKey:ItemKey_Type] integerValue];
            if ( cellType == PeriodCellType_CycleLength ) {
                UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
                UITextField *textField = (UITextField*)cell.accessoryView;
                [textField resignFirstResponder];
            }
            else if ( cellType == PeriodCellType_Notes ) {
                UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
                UITextView *textView = (UITextView*)[cell viewWithTag:10];
                [textView resignFirstResponder];
            }
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_sectionsArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *items = [[_sectionsArray objectAtIndex:section] objectForKey:ItemKey_Items];
    return [items count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 35.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if ( section == ([_sectionsArray count]-1) )
        return 38.0;
    return 0.01;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *items = [[_sectionsArray objectAtIndex:indexPath.section] objectForKey:ItemKey_Items];
    NSDictionary *item = [items objectAtIndex:indexPath.row];
    NSInteger cellType = [[item objectForKey:ItemKey_Type] integerValue];
    NSArray *cellIDs = @[
			@"value1Cell",
			@"value1Cell",
			@"defaultCell",
            A3WalletItemFieldNoteCellID,
			@"dateInputCell",
			@"deleteCell"];
    
    NSString *cellID = [cellIDs objectAtIndex:cellType];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        switch (cellType) {
            case PeriodCellType_StartDate:
            case PeriodCellType_EndDate:
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
                cell.detailTextLabel.font = [UIFont systemFontOfSize:17.0];
                cell.detailTextLabel.textColor = [UIColor colorWithRGBRed:128 green:128 blue:128 alpha:255];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
				break;
			}
            case PeriodCellType_CycleLength:
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 80.0, 44.0)];
                textField.borderStyle = UITextBorderStyleNone;
                textField.textAlignment = NSTextAlignmentRight;
                textField.delegate = self;
                textField.clearButtonMode = UITextFieldViewModeNever;
                textField.font = [UIFont systemFontOfSize:17.0];
                textField.textColor = [UIColor colorWithRGBRed:128 green:128 blue:128 alpha:255];
                cell.accessoryView = textField;
				break;
			}
            case PeriodCellType_Notes:
            {
				A3WalletNoteCell *noteCell = [tableView dequeueReusableCellWithIdentifier:A3WalletItemFieldNoteCellID forIndexPath:indexPath];
				[noteCell setupTextView];

				noteCell.textView.delegate = self;
				noteCell.textView.text = _periodItem.notes;

                cell = noteCell;
				break;
			}
            case PeriodCellType_DateInput:
            {
                NSArray *cellArray = [[NSBundle mainBundle] loadNibNamed:@"A3LadyCalendarAddAccountCell" owner:nil options:nil];
                cell = [cellArray objectAtIndex:2];
                UIDatePicker *datePicker = (UIDatePicker*)[cell viewWithTag:10];
                datePicker.datePickerMode = UIDatePickerModeDate;
                [datePicker addTarget:self action:@selector(changeDateAction:) forControlEvents:UIControlEventValueChanged];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
				break;
			}
            case PeriodCellType_Delete:
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
                cell.textLabel.textColor = [UIColor colorWithRGBRed:255 green:59 blue:48 alpha:255];
                cell.textLabel.textAlignment = NSTextAlignmentCenter;
				break;
			}
        }
    }
    
    switch (cellType) {
        case PeriodCellType_StartDate:
        {
            cell.textLabel.text = [item objectForKey:ItemKey_Title];
            NSDateFormatter *formatter = [NSDateFormatter new];
            if (IS_IPAD || [NSDate isFullStyleLocale]) {
                [formatter setDateStyle:NSDateFormatterFullStyle];
            }
            else {
                [formatter setDateFormat:[formatter customFullStyleFormat]];
            }

            //cell.detailTextLabel.text = [_dataManager stringFromDate:_periodItem.startDate];
            cell.detailTextLabel.text = [formatter stringFromDate:_periodItem.startDate];
            cell.detailTextLabel.textColor = ( [self.inputItemKey isEqualToString:PeriodItem_StartDate] ? [[A3AppDelegate instance] themeColor] : [UIColor colorWithRGBRed:128 green:128 blue:128 alpha:255] );
			break;
		}
        case PeriodCellType_EndDate:
        {
            NSDateFormatter *formatter = [NSDateFormatter new];
            if (IS_IPAD || [NSDate isFullStyleLocale]) {
                [formatter setDateStyle:NSDateFormatterFullStyle];
            }
            else {
                [formatter setDateFormat:[formatter customFullStyleFormat]];
            }
            
            cell.textLabel.text = [item objectForKey:ItemKey_Title];
            //cell.detailTextLabel.text = [_dataManager stringFromDate:_periodItem.endDate];
            cell.detailTextLabel.text = [formatter stringFromDate:_periodItem.endDate];
            cell.detailTextLabel.textColor = ( [self.inputItemKey isEqualToString:PeriodItem_EndDate] ? [[A3AppDelegate instance] themeColor] : [UIColor colorWithRGBRed:128 green:128 blue:128 alpha:255] );

            if ( [_periodItem.endDate timeIntervalSince1970] < [_periodItem.startDate timeIntervalSince1970] ) {
                NSDictionary *attr = @{NSFontAttributeName: cell.detailTextLabel.font, NSStrikethroughStyleAttributeName : @(NSUnderlineStyleSingle)};
                cell.detailTextLabel.attributedText = [[NSAttributedString alloc] initWithString:cell.detailTextLabel.text attributes:attr];
            }
            else{
                NSDictionary *attr = @{NSFontAttributeName: cell.detailTextLabel.font, NSStrikethroughStyleAttributeName : @(NSUnderlineStyleNone)};
                cell.detailTextLabel.attributedText = [[NSAttributedString alloc] initWithString:cell.detailTextLabel.text attributes:attr];
            }
			break;
		}
        case PeriodCellType_CycleLength:
        {
            cell.textLabel.text = [item objectForKey:ItemKey_Title];
            UITextField *textField = (UITextField*)cell.accessoryView;
            textField.text = [NSString stringWithFormat:@"%ld",[_periodItem.cycleLength longValue]];
            textField.textColor = (!_prevPeriod || _isLatestPeriod) ? [UIColor colorWithRGBRed:128 green:128 blue:128 alpha:255] : [UIColor colorWithRed:201/255.0 green:201/255.0 blue:201/255.0 alpha:1.0];
            textField.userInteractionEnabled = (!_prevPeriod || _isLatestPeriod) ? YES : NO;
			break;
		}

        case PeriodCellType_Notes:
        {
            A3WalletNoteCell *noteCell = [tableView dequeueReusableCellWithIdentifier:A3WalletItemFieldNoteCellID forIndexPath:indexPath];
            [noteCell setupTextView];
            
            noteCell.textView.delegate = self;
            noteCell.textView.text = _periodItem.notes;
            
            cell = noteCell;
            
			break;
		}
        case PeriodCellType_DateInput:
        {
            UIDatePicker *datePicker = (UIDatePicker*)[cell viewWithTag:10];
            datePicker.datePickerMode = UIDatePickerModeDate;
            datePicker.date = ([_periodItem valueForKey:self.inputItemKey] ? [_periodItem valueForKey:self.inputItemKey] : [A3DateHelper dateMake12PM:[NSDate date]]);
			break;
		}
        case PeriodCellType_Delete:
        {
            cell.textLabel.text = [item objectForKey:ItemKey_Title];
			break;
		}
    }
    
    return cell;
}

#pragma mark - Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat retHeight = 44.0;
    
    NSArray *items = [[_sectionsArray objectAtIndex:indexPath.section] objectForKey:ItemKey_Items];
    NSDictionary *item = [items objectAtIndex:indexPath.row];
    NSInteger cellType = [[item objectForKey:ItemKey_Type] integerValue];
    
    switch (cellType)  {
        case PeriodCellType_Notes: {
			return [UIViewController noteCellHeight];
		}
        case PeriodCellType_DateInput:
            retHeight = 236.0;
            break;
    }
    
    return retHeight;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *items = [[_sectionsArray objectAtIndex:indexPath.section] objectForKey:ItemKey_Items];
    NSDictionary *item = [items objectAtIndex:indexPath.row];
    NSInteger cellType = [[item objectForKey:ItemKey_Type] integerValue];
    
    if ( cellType == PeriodCellType_Delete ) {
        cell.textLabel.frame = CGRectMake(cell.textLabel.frame.origin.x, cell.textLabel.frame.origin.y, cell.contentView.frame.size.width, cell.textLabel.frame.size.height);
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *items = [[_sectionsArray objectAtIndex:indexPath.section] objectForKey:ItemKey_Items];
    NSDictionary *item = [items objectAtIndex:indexPath.row];
    NSInteger cellType = [[item objectForKey:ItemKey_Type] integerValue];
    
    switch (cellType)  {
        case PeriodCellType_StartDate:
        case PeriodCellType_EndDate:
		{
            [self resignAllAction];
            NSInteger inputCellType = 0;
            
            if ( [self.inputItemKey isEqualToString:PeriodItem_StartDate] ) {
                inputCellType = PeriodCellType_StartDate;
            }
            else if ( [self.inputItemKey isEqualToString:PeriodItem_EndDate] ) {
                inputCellType = PeriodCellType_EndDate;
            }

            if ( [self.inputItemKey length] > 0 ) {
                [self closeDateInputCell];
                
                if ( cellType == inputCellType ) {
                    return;
                }
                else if ( inputCellType == PeriodCellType_StartDate && indexPath.section == 0 ) {
                    indexPath = [NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section];
                }
            }
            
            // open
            [items insertObject:@{ItemKey_Title : @"", ItemKey_Type : @(PeriodCellType_DateInput)} atIndex:indexPath.row+1];
            if ( cellType == PeriodCellType_StartDate ) {
                self.inputItemKey = PeriodItem_StartDate;
            }
            else if ( cellType == PeriodCellType_EndDate ) {
                self.inputItemKey = PeriodItem_EndDate;
            }
            
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
            break;
            
        case PeriodCellType_CycleLength: {
            if (_prevPeriod) {
                return;
            }
            
            [self closeDateInputCell];

            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            UITextField *textField = (UITextField*)cell.accessoryView;
            [textField becomeFirstResponder];
        }
            break;
            
        case PeriodCellType_Notes: {
            [self closeDateInputCell];
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            UITextView *textView = (UITextView*)[cell viewWithTag:10];
            [textView becomeFirstResponder];
        }
            break;
            
        case PeriodCellType_Delete: {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];

#ifdef __IPHONE_8_0
            if (!IS_IOS7 && IS_IPAD) {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
                [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Delete Period", @"Delete Period") style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
                    [self deletePeriodAction];
                }]];
                [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    [alertController dismissViewControllerAnimated:YES completion:NULL];
                }]];
                alertController.modalInPopover = UIModalPresentationPopover;
                
                UIPopoverPresentationController *popoverPresent = alertController.popoverPresentationController;
                UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                CGRect fromRect = [self.tableView convertRect:cell.bounds fromView:cell];
                fromRect.origin.x = self.view.center.x;
                fromRect.size = CGSizeZero;
                popoverPresent.sourceView = self.view;
                popoverPresent.sourceRect = fromRect;
                popoverPresent.permittedArrowDirections = UIPopoverArrowDirectionDown;
                [self presentViewController:alertController animated:YES completion:NULL];
            }
            else
#endif
			{
                [self showDeletePeriodActionSheet];
            }
        }
            break;
    }
}

#pragma mark - UIActionSheetDelegate

- (void)deletePeriodAction
{
    [_periodItem MR_deleteEntityInContext:[NSManagedObjectContext MR_defaultContext]];
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    
    [_dataManager recalculateDates];
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self setFirstActionSheet:nil];
    
    if ( buttonIndex == actionSheet.destructiveButtonIndex ) {
        [self deletePeriodAction];
    }
}

#pragma mark ActionSheet Rotation Related
- (void)rotateFirstActionSheet {
    NSInteger currentActionSheetTag = [self.firstActionSheet tag];
    [super rotateFirstActionSheet];
    [self setFirstActionSheet:nil];
    
    [self showActionSheetAdaptivelyInViewWithTag:currentActionSheetTag];
}

- (void)showActionSheetAdaptivelyInViewWithTag:(NSInteger)actionSheetTag {
    switch (actionSheetTag) {
        case 0:
            [self showDeletePeriodActionSheet];
            break;

        default:
            break;
    }
}

- (void)showDeletePeriodActionSheet
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                               destructiveButtonTitle:NSLocalizedString(@"Delete Period", @"Delete Period")
                                                    otherButtonTitles:nil];
    [actionSheet showInView:self.view];
    actionSheet.tag = 0;
    [self setFirstActionSheet:actionSheet];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self resignAllAction];
}

#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    [self closeDateInputCell];
    self.firstResponder = textView;
    
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    _periodItem.notes = textView.text;
    if (self.firstResponder == textView) {
        [self.firstResponder resignFirstResponder];
        self.firstResponder = nil;
    }
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidChange:(NSNotification*)noti
{
    UITextField *textField = noti.object;
    NSInteger days = [textField.text integerValue];
	_periodItem.cycleLength = @(days);
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    self.firstResponder = textField;

	self.keyboardVC = [self simplePrevNextClearNumberKeyboard];
	self.keyboardVC.delegate = self;
	self.keyboardVC.textInputTarget = textField;
	self.keyboardVC.delegate = self;
	textField.inputView = self.keyboardVC.view;
	[self.keyboardVC setKeyboardType:A3NumberKeyboardTypeInteger];
    [self closeDateInputCell];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
	self.textBeforeEditingTextField = textField.text;
	textField.text = @"";
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
	if (![textField.text length]) {
		textField.text = _textBeforeEditingTextField;
	}
	if (![textField.text length] || [textField.text integerValue] == 0) {
		textField.text = _textBeforeEditingTextField;
	}
    
    if (![textField.text isEqualToString:_textBeforeEditingTextField]) {
        _isCustomCycleLengthMode = YES;
    }
    
    if (self.firstResponder == textField) {
        [self.firstResponder resignFirstResponder];
        self.firstResponder = nil;
    }
}

#pragma mark - A3KeyboardDelegate

- (void)A3KeyboardController:(id)controller clearButtonPressedTo:(UIResponder *)keyInputDelegate {
	UITextField *textField = (UITextField *) keyInputDelegate;
	textField.text = @"";
	_textBeforeEditingTextField = @"";
}

- (void)A3KeyboardController:(id)controller doneButtonPressedTo:(UIResponder *)keyInputDelegate
{
    [self resignAllAction];
}

#pragma mark - action method

- (void)changeDateAction:(id)sender
{
    UIDatePicker *datePicker = (UIDatePicker*)sender;
    NSDate *prevDate = _periodItem.startDate;
    NSDate *currentDate = [A3DateHelper dateMake12PM:datePicker.date];

	[_periodItem setValue:currentDate forKey:self.inputItemKey];
    
    NSInteger inputCellType = 0;
    if ( [self.inputItemKey isEqualToString:PeriodItem_StartDate] ) {
        inputCellType = PeriodCellType_StartDate;
    }
    else if ( [self.inputItemKey isEqualToString:PeriodItem_EndDate] ) {
        inputCellType = PeriodCellType_EndDate;
    }
    
    [self reloadItemAtCellType:inputCellType];
    
    if ( inputCellType == PeriodCellType_StartDate ) {
        NSDate *endDate = _periodItem.endDate;
        NSInteger diffDays = [A3DateHelper diffDaysFromDate:prevDate toDate:endDate];
        endDate = [A3DateHelper dateByAddingDays:diffDays fromDate:[_periodItem startDate]];
		_periodItem.endDate = endDate;
        [self reloadItemAtCellType:PeriodCellType_EndDate];
        [self calculateCycleLengthFromDate:currentDate];
    }
}

- (void)calculateCycleLengthFromDate:(NSDate *)fromDate
{
//    if (_isEditMode) {
//        return;
//    }
    if (_isCustomCycleLengthMode) {
        return;
    }

    // cycle length 변경.
    LadyCalendarPeriod *currentPeriod = [_dataManager currentPeriodFromDate:fromDate];
    if (_isEditMode && currentPeriod && [currentPeriod.startDate timeIntervalSince1970] < [_periodItem.startDate timeIntervalSince1970]) {
        _prevPeriod = currentPeriod;
    }
    else {
        _prevPeriod = [_dataManager previousPeriodFromDate: currentPeriod ? [currentPeriod startDate] : fromDate];
    }
    
    if (!_prevPeriod && currentPeriod ) {    // 더이상 이전월이 없는, 최초의 달.
        _prevPeriod = currentPeriod;
    }
    else if ((!_prevPeriod && !currentPeriod) || ([_prevPeriod.startDate timeIntervalSince1970] == [currentPeriod.startDate timeIntervalSince1970])) {    // 더이상 않이 없는, 이전 월인 경우.
        [self reloadItemAtCellType:PeriodCellType_CycleLength];
        return;
    }
    
    if (_prevPeriod) {
        NSInteger cycleLength = [A3DateHelper diffDaysFromDate:_prevPeriod.startDate
                                                        toDate:fromDate];
        _periodItem.cycleLength = @(labs(cycleLength));
        [self reloadItemAtCellType:PeriodCellType_CycleLength];
    }
}

- (void)doneButtonAction:(UIBarButtonItem *)button
{
    [self resignAllAction];
    [self.firstResponder resignFirstResponder];

	NSDateComponents *cycleLengthComponents = [NSDateComponents new];
	cycleLengthComponents.day = [_periodItem.cycleLength integerValue] - 1;
	_periodItem.periodEnds = [[A3AppDelegate instance].calendar dateByAddingComponents:cycleLengthComponents toDate:_periodItem.startDate options:0];

	if ( _periodItem.endDate == nil) {
		[A3LadyCalendarModelManager alertMessage:NSLocalizedString(@"Please input end date.", @"Please input end date.") title:nil];
        return;
    }
    else if ( [_periodItem.endDate timeIntervalSince1970] < [_periodItem.startDate timeIntervalSince1970] ) {
		[A3LadyCalendarModelManager alertMessage:NSLocalizedString(@"The start date must be before the end date.", nil)
										   title:NSLocalizedString(@"Cannot Save Period.", nil)];
        return;
    }
    else if ( [_dataManager isOverlapStartDate:_periodItem.startDate endDate:_periodItem.endDate accountID:_dataManager.currentAccount.uniqueID periodID:_periodItem.uniqueID] ) {
		[A3LadyCalendarModelManager alertMessage:NSLocalizedString(@"The new date you entered overlaps with previous dates.", @"The new date you entered overlaps with previous dates.")
										   title:NSLocalizedString(@"Info", @"Info")];
        return;
    }
    if ( _prevPeriod && !_isCustomCycleLengthMode ) {
        NSInteger diffDays = [A3DateHelper diffDaysFromDate:_prevPeriod.startDate toDate:_periodItem.startDate];
        _periodItem.cycleLength = @(diffDays);
    }
    
    if (!_periodItem.uniqueID) {
        [_periodItem reassignUniqueIDWithStartDate];
    }

	_periodItem.updateDate = [NSDate date];
	_periodItem.isPredict = @NO;

	LadyCalendarAccount *account = [self.dataManager.currentAccount MR_inContext:[NSManagedObjectContext MR_defaultContext]];
	account.watchingDate = _periodItem.startDate;
	[account.managedObjectContext MR_saveToPersistentStoreAndWait];

	[_dataManager recalculateDates];
    
    NSDictionary * settingDictionary = [[A3SyncManager sharedSyncManager] objectForKey:A3LadyCalendarUserDefaultsSettings];
    if ([[settingDictionary objectForKey:SettingItem_AutoRecord] boolValue]) {
		[_dataManager makePredictPeriodsBeforeCurrentPeriod];
        [_dataManager recalculateDates];
    }

	[self dismissViewControllerAnimated:YES completion:nil];

	NSNotification *notification = [[NSNotification alloc] initWithName:A3NotificationLadyCalendarPeriodDataChanged object:nil userInfo:@{A3LadyCalendarChangedDateKey: _periodItem.startDate}];
	[[NSNotificationCenter defaultCenter] postNotification:notification];
}

- (void)cancelAction:(id)sender
{
	NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
	if ([context hasChanges]) {
		[context rollback];
	}

	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - A3ViewControllerProtocol

- (BOOL)shouldAllowExtensionPointIdentifier:(NSString *)extensionPointIdentifier {
	return NO;
}

@end
