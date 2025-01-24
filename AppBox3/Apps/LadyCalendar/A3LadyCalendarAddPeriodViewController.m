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
#import "A3WalletNoteCell.h"
#import "UIViewController+tableViewStandardDimension.h"
#import "NSDate+formatting.h"
#import "NSDateFormatter+A3Addition.h"
#import "LadyCalendarPeriod+extension.h"
#import "A3SyncManager.h"
#import "A3SyncManager+NSUbiquitousKeyValueStore.h"
#import "LadyCalendarAccount.h"
#import "A3UserDefaults.h"
#import "NSManagedObject+extension.h"
#import "NSManagedObjectContext+extension.h"
#import "A3AppDelegate.h"
#import "A3UIDevice.h"
#import "A3UserDefaults+A3Addition.h"

extern NSString *const A3WalletItemFieldNoteCellID;

@interface A3LadyCalendarAddPeriodViewController () <A3ViewControllerProtocol>

@property (strong, nonatomic) NSMutableArray *sectionsArray;
@property (strong, nonatomic) NSString *inputItemKey;
@property (strong, nonatomic) LadyCalendarPeriod *prevPeriod;
@property (copy, nonatomic) NSString *textBeforeEditingTextField;
@property (copy, nonatomic) UIColor *textColorBeforeEditing;
@property (weak, nonatomic) UITextField *editingTextField;

@end

@implementation A3LadyCalendarAddPeriodViewController
{
    BOOL _isCustomCycleLengthMode;
    BOOL _isLatestPeriod;

	BOOL _isNumberKeyboardVisible;
	BOOL _didPressClearKey;
	BOOL _didPressNumberKey;
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
	if ([self.tableView respondsToSelector:@selector(cellLayoutMarginsFollowReadableWidth)]) {
		self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
	}
	if ([self.tableView respondsToSelector:@selector(layoutMargins)]) {
		self.tableView.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0);
	}
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
	self.tableView.separatorInset = A3UITableViewSeparatorInset;
	[self.tableView registerClass:[A3WalletNoteCell class] forCellReuseIdentifier:A3WalletItemFieldNoteCellID];

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
		self.prevPeriod = [_dataManager previousPeriodFromDate:_periodItem.startDate];
		LadyCalendarPeriod *latestPeriod = [[_dataManager periodListSortedByStartDateIsAscending:YES] lastObject];
		_isLatestPeriod = [_periodItem.startDate isEqualToDate:latestPeriod.startDate];
	} else {
		A3LadyCalendarModelManager *modelManager = [A3LadyCalendarModelManager new];
		NSInteger cycleLength = [modelManager cycleLengthConsideringUserOption];
		
		self.prevPeriod = [_dataManager lastPeriod];

        NSManagedObjectContext *context = A3SyncManager.sharedSyncManager.persistentContainer.viewContext;
        _periodItem = [[LadyCalendarPeriod alloc] initWithContext:context];
		_periodItem.updateDate = [NSDate date];
		_periodItem.cycleLength = cycleLength == 0 ? @28 : @(cycleLength);
		_periodItem.isPredict = @NO;
		_periodItem.accountID = _dataManager.currentAccount.uniqueID;
		
		if (_prevPeriod) {
			_periodItem.startDate = [A3DateHelper dateByAddingDays:cycleLength fromDate:_prevPeriod.startDate];
			_periodItem.endDate = [A3DateHelper dateByAddingDays:4 fromDate:_periodItem.startDate];
		} else {
			_periodItem.startDate = [A3DateHelper dateMake12PM:[NSDate date]];
			_periodItem.endDate = [A3DateHelper dateByAddingDays:4 fromDate:_periodItem.startDate];
		}
		
		NSInteger ovulationDays = 14;
		_periodItem.ovulation = [A3DateHelper dateByAddingDays:ovulationDays fromDate:_periodItem.startDate];
	}
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)applicationWillResignActive {
	[self cancelAction:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

	if (!_isEditMode && self.prevPeriod) {
		[self calculateCycleLengthFromDate:_periodItem.startDate];
	}
	if ([self.navigationController.navigationBar isHidden]) {
		[self.navigationController setNavigationBarHidden:NO animated:NO];
	}
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[[[A3AppDelegate instance] rootViewController_iPad] viewWillLayoutSubviews];
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
	[self.editingObject resignFirstResponder];
	[self dismissNumberKeyboard];

    for (NSInteger section=0; section < [_sectionsArray count]; section++) {
        NSArray *items = [[_sectionsArray objectAtIndex:section] objectForKey:ItemKey_Items];

        for (NSInteger row = 0; row < [items count]; row++) {
            NSDictionary *item = [items objectAtIndex:row];
            NSInteger cellType = [[item objectForKey:ItemKey_Type] integerValue];
			if ( cellType == PeriodCellType_Notes ) {
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
                if (@available(iOS 13.4, *)) {
                    datePicker.preferredDatePickerStyle = UIDatePickerStyleWheels;
                }
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
            cell.detailTextLabel.textColor = ( [self.inputItemKey isEqualToString:PeriodItem_StartDate] ? [[A3UserDefaults standardUserDefaults] themeColor] : [UIColor colorWithRGBRed:128 green:128 blue:128 alpha:255] );
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
            cell.detailTextLabel.textColor = ( [self.inputItemKey isEqualToString:PeriodItem_EndDate] ? [[A3UserDefaults standardUserDefaults] themeColor] : [UIColor colorWithRGBRed:128 green:128 blue:128 alpha:255] );

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
			textField.textColor = [UIColor colorWithRGBRed:128 green:128 blue:128 alpha:255];
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
            if (@available(iOS 13.4, *)) {
                datePicker.preferredDatePickerStyle = UIDatePickerStyleWheels;
            }
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
			[self.editingObject resignFirstResponder];
			
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

            if (IS_IPAD) {
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
    NSManagedObjectContext *context = A3SyncManager.sharedSyncManager.persistentContainer.viewContext;
    [context deleteObject:_periodItem];
    [context saveContext];

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
	[self dismissNumberKeyboard];
    [self resignAllAction];
}

#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    [self closeDateInputCell];
	[self dismissNumberKeyboard];
	
    self.editingObject = textView;
    
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    _periodItem.notes = textView.text;
    if (self.editingObject == textView) {
        [self.editingObject resignFirstResponder];
        self.editingObject = nil;
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
	[self.editingObject resignFirstResponder];
	
	[self closeDateInputCell];
	[self presentNumberKeyboardForTextField:textField];
	return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
	self.textBeforeEditingTextField = textField.text;
	self.textColorBeforeEditing = textField.textColor;

    textField.textColor = [[A3UserDefaults standardUserDefaults] themeColor];
	textField.text = [self.decimalFormatter stringFromNumber:@0];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {

}

- (void)textFieldDidChange:(NSNotification*)noti
{
	UITextField *textField = noti.object;
	NSInteger days = [textField.text integerValue];
	_periodItem.cycleLength = @(days);
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
	if (!_didPressClearKey && !_didPressNumberKey) {
		textField.text = _textBeforeEditingTextField;
	}
	if (![textField.text length] || [textField.text integerValue] == 0) {
		textField.text = _textBeforeEditingTextField;
	}
	
	NSInteger days = [textField.text integerValue];
	_periodItem.cycleLength = @(days);

    if (![textField.text isEqualToString:_textBeforeEditingTextField]) {
        _isCustomCycleLengthMode = YES;
    }

	if (_textColorBeforeEditing) {
		textField.textColor = _textColorBeforeEditing;
	}
}

- (void)presentNumberKeyboardForTextField:(UITextField *)textField {
	if (_isNumberKeyboardVisible) {
		return;
	}
	_editingTextField = textField;
	
	[self textFieldDidBeginEditing:textField];

	A3NumberKeyboardViewController *keyboardVC = [self simplePrevNextNumberKeyboard];
	self.numberKeyboardViewController = keyboardVC;
	keyboardVC.useDotAsClearButton = YES;
	keyboardVC.keyboardType = A3NumberKeyboardTypeInteger;
	keyboardVC.textInputTarget = textField;
	keyboardVC.delegate = self;
	
	CGRect bounds = [A3UIDevice screenBoundsAdjustedWithOrientation];
	CGFloat keyboardHeight = keyboardVC.keyboardHeight;
	UIView *keyboardView = keyboardVC.view;
	[self.view.superview addSubview:keyboardView];

	[keyboardVC reloadPrevNextButtons];

	_didPressClearKey = NO;
	_didPressNumberKey = NO;
	_isNumberKeyboardVisible = YES;

	keyboardView.frame = CGRectMake(0, self.view.bounds.size.height, bounds.size.width, keyboardHeight);
	[UIView animateWithDuration:0.3 animations:^{
		CGRect frame = keyboardView.frame;
		frame.origin.y -= keyboardHeight;
		keyboardView.frame = frame;
	} completion:^(BOOL finished) {
		[self addNumberKeyboardNotificationObservers];
	}];
}

- (void)dismissNumberKeyboard {
	if (!_isNumberKeyboardVisible) {
		return;
	}
	[self removeNumberKeyboardNotificationObservers];
	
	[self textFieldDidEndEditing:_editingTextField];

	_isNumberKeyboardVisible = NO;

	A3NumberKeyboardViewController *keyboardViewController = self.numberKeyboardViewController;
	UIView *keyboardView = keyboardViewController.view;
	[UIView animateWithDuration:0.3 animations:^{
		CGRect frame = keyboardView.frame;
		frame.origin.y += keyboardViewController.keyboardHeight;
		keyboardView.frame = frame;
	} completion:^(BOOL finished) {
		[keyboardView removeFromSuperview];
		self.numberKeyboardViewController = nil;
	}];
}

#pragma mark - A3KeyboardDelegate

- (void)A3KeyboardController:(id)controller clearButtonPressedTo:(UIResponder *)keyInputDelegate {
	_didPressClearKey = YES;
	_didPressNumberKey = NO;
	UITextField *textField = (UITextField *) keyInputDelegate;
	textField.text = [self.decimalFormatter stringFromNumber:@0];
	_textBeforeEditingTextField = textField.text;
}

- (void)A3KeyboardController:(id)controller doneButtonPressedTo:(UIResponder *)keyInputDelegate
{
	[self dismissNumberKeyboard];
    [self resignAllAction];
}

- (void)keyboardViewControllerDidValueChange:(A3NumberKeyboardViewController *)vc {
	_didPressNumberKey = YES;
	_didPressClearKey = NO;
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
    if (!fromDate)
        return;
    
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
        _prevPeriod = [_dataManager previousPeriodFromDate: fromDate];
    }
    
    if (!_prevPeriod && currentPeriod ) {    // 더이상 이전월이 없는, 최초의 달.
        _prevPeriod = currentPeriod;
    }
    else if ((!_prevPeriod && !currentPeriod) || ([_prevPeriod.startDate isEqualToDate:fromDate])) {    // 더이상 않이 없는, 이전 월인 경우.
        [self reloadItemAtCellType:PeriodCellType_CycleLength];
        return;
    }
    FNLOG(@"%@,%@", currentPeriod, _prevPeriod);
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
    [self.editingObject resignFirstResponder];

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

    LadyCalendarAccount *account = self.dataManager.currentAccount;
	account.watchingDate = _periodItem.startDate;
    NSManagedObjectContext *context = A3SyncManager.sharedSyncManager.persistentContainer.viewContext;
    [context saveContext];

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
    NSManagedObjectContext *context = A3SyncManager.sharedSyncManager.persistentContainer.viewContext;
	if ([context hasChanges]) {
		[context rollback];
	}

	[self dismissViewControllerAnimated:YES completion:nil];
}

@end
