//
//  A3LadyCalendarAddPeriodViewController.m
//  A3TeamWork
//
//  Created by coanyaa on 2013. 11. 18..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3LadyCalendarAddPeriodViewController.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+A3AppCategory.h"
#import "A3LadyCalendarDefine.h"
#import "A3LadyCalendarModelManager.h"
#import "LadyCalendarPeriod.h"
#import "LadyCalendarAccount.h"
#import "A3DateHelper.h"
#import "A3NumberKeyboardViewController.h"
#import "UIColor+A3Addition.h"
#import "A3UserDefaults.h"
#import "A3AppDelegate.h"

@interface A3LadyCalendarAddPeriodViewController ()
@property (strong, nonatomic) NSMutableArray *templateArray;
@property (strong, nonatomic) NSMutableDictionary *periodModel;
@property (strong, nonatomic) NSString *inputItemKey;
@property (strong, nonatomic) A3NumberKeyboardViewController *keyboardVC;
@property (strong, nonatomic) LadyCalendarPeriod *prevPeriod;
@property (copy, nonatomic) NSString *textBeforeEditingTextField;

- (void)cancelAction:(id)sender;
- (void)changeDateAction:(id)sender;
- (void)reloadItemAtCellType:(NSInteger)cellType;
- (void)closeDateInputCell;
@end

@implementation A3LadyCalendarAddPeriodViewController

- (void)reloadItemAtCellType:(NSInteger)cellType
{
    NSMutableArray *array = [NSMutableArray array];
    for(NSInteger section=0; section < [_templateArray count]; section++){
        NSArray *items = [[_templateArray objectAtIndex:section] objectForKey:ItemKey_Items];
        
        for(NSInteger row = 0; row < [items count]; row++){
            NSDictionary *item = [items objectAtIndex:row];
            if( [[item objectForKey:ItemKey_Type] integerValue] == cellType ){
                [array addObject:[NSIndexPath indexPathForRow:row inSection:section]];
            }
        }
    }
    if( [array count] > 0 )
        [self.tableView reloadRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationNone];
}


- (void)closeDateInputCell
{
    NSInteger findRow = NSNotFound;
    NSInteger findSection = NSNotFound;
    for(NSInteger section=0; section < [_templateArray count]; section++){
        NSArray *items = [[_templateArray objectAtIndex:section] objectForKey:ItemKey_Items];
        
        for(NSInteger row = 0; row < [items count]; row++){
            NSDictionary *item = [items objectAtIndex:row];
            if( [[item objectForKey:ItemKey_Type] integerValue] == PeriodCellType_DateInput ){
                findRow = row;
                findSection = section;
                break;
            }
        }
    }
    if( findSection == NSNotFound || findRow == NSNotFound )
        return;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:findRow inSection:findSection];
    NSMutableArray *items = [[_templateArray objectAtIndex:indexPath.section] objectForKey:ItemKey_Items];
    [items removeObjectAtIndex:indexPath.row];

    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    NSInteger inputCellType = 0;
    
    if( [self.inputItemKey isEqualToString:PeriodItem_StartDate] )
        inputCellType = PeriodCellType_StartDate;
    else if( [self.inputItemKey isEqualToString:PeriodItem_EndDate] )
        inputCellType = PeriodCellType_EndDate;
    else if( [self.inputItemKey isEqualToString:PeriodItem_Ovulation] )
        inputCellType = PeriodCellType_Ovulation;
    self.inputItemKey = nil;
    [self reloadItemAtCellType:inputCellType];
    
}

- (void)resignAllAction
{
    for(NSInteger section=0; section < [_templateArray count]; section++){
        NSArray *items = [[_templateArray objectAtIndex:section] objectForKey:ItemKey_Items];
        
        for(NSInteger row = 0; row < [items count]; row++){
            NSDictionary *item = [items objectAtIndex:row];
            NSInteger cellType = [[item objectForKey:ItemKey_Type] integerValue];
            if( cellType == PeriodCellType_CycleLength ){
                UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
                UITextField *textField = (UITextField*)cell.accessoryView;
                [textField resignFirstResponder];
            }
            else if( cellType == PeriodCellType_Notes ){
                UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
                UITextView *textView = (UITextView*)[cell viewWithTag:10];
                [textView resignFirstResponder];
            }
        }
    }
}


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = (_isEditMode ? @"Edit Period" : @"Add Period");
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction:)];
    [self rightBarButtonDoneButton];
    
    self.templateArray = [NSMutableArray arrayWithArray:@[@{ItemKey_Items : [NSMutableArray arrayWithArray:@[@{ItemKey_Title : @"Start Date",ItemKey_Type : @(PeriodCellType_StartDate)},@{ItemKey_Title : @"End Date",ItemKey_Type : @(PeriodCellType_EndDate)}]]},@{ItemKey_Items : [NSMutableArray arrayWithArray:@[@{ItemKey_Title : @"Cycle Length",ItemKey_Type : @(PeriodCellType_CycleLength)}]]},/*@{ItemKey_Items : [NSMutableArray arrayWithArray:@[@{ItemKey_Title : @"Ovulation",ItemKey_Type : @(PeriodCellType_Ovulation)}]]},*/@{ItemKey_Items : [NSMutableArray arrayWithArray:@[@{ItemKey_Title : @"Notes",ItemKey_Type : @(PeriodCellType_Notes)}]]} ]];
    currentAccount = [[A3LadyCalendarModelManager sharedManager] currentAccount];
    
    if( _isEditMode /*&& ![_periodItem.isPredict boolValue]*/ )
        [self.templateArray addObject:@{ItemKey_Items : [NSMutableArray arrayWithArray:@[@{ItemKey_Title : @"Delete Period",ItemKey_Type : @(PeriodCellType_Delete)}]]}];
    
    if( _isEditMode ){
        self.periodModel = [[A3LadyCalendarModelManager sharedManager] dictionaryFromPeriod:_periodItem];
        self.prevPeriod = [[A3LadyCalendarModelManager sharedManager] previousPeriodFromDate:[_periodModel objectForKey:PeriodItem_StartDate] accountID:currentAccount.accountID];
    }
    else{
        self.periodModel = [[A3LadyCalendarModelManager sharedManager] emptyPeriod];
        NSInteger ovulationDays = [[NSUserDefaults standardUserDefaults] integerForKey:A3LadyCalendarOvulationDays];
        [_periodModel setObject:[A3DateHelper dateByAddingDays:ovulationDays fromDate:[_periodModel objectForKey:PeriodItem_StartDate]] forKey:PeriodItem_Ovulation];
        self.prevPeriod = nil;
    }
    self.tableView.separatorInset = UIEdgeInsetsMake(0, (IS_IPHONE ? 15.0 : 28.0), 0, 0);
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
    self.keyboardVC = nil;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.A3RootViewController viewWillLayoutSubviews];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_templateArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *items = [[_templateArray objectAtIndex:section] objectForKey:ItemKey_Items];
    return [items count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 35.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if( section == ([_templateArray count]-1) )
        return 38.0;
    return 0.01;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *items = [[_templateArray objectAtIndex:indexPath.section] objectForKey:ItemKey_Items];
    NSDictionary *item = [items objectAtIndex:indexPath.row];
    NSInteger cellType = [[item objectForKey:ItemKey_Type] integerValue];
    NSArray *cellIDs = @[@"value1Cell",@"value1Cell",@"defaultCell",@"value1Cell",@"inputNotesCell",@"dateInputCell",@"deleteCell"];
    NSString *cellID = [cellIDs objectAtIndex:cellType];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        switch (cellType) {
            case PeriodCellType_StartDate:
            case PeriodCellType_EndDate:
            case PeriodCellType_Ovulation:
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
                cell.detailTextLabel.font = [UIFont systemFontOfSize:17.0];
                cell.detailTextLabel.textColor = [UIColor colorWithRGBRed:128 green:128 blue:128 alpha:255];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                break;
            case PeriodCellType_CycleLength:{
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 80.0, 44.0)];
//                textField.keyboardType = UIKeyboardTypeNumberPad;
                textField.borderStyle = UITextBorderStyleNone;
                textField.textAlignment = NSTextAlignmentRight;
                textField.delegate = self;
                textField.clearButtonMode = UITextFieldViewModeNever;
                textField.font = [UIFont systemFontOfSize:17.0];
                textField.textColor = [UIColor colorWithRGBRed:128 green:128 blue:128 alpha:255];
                cell.accessoryView = textField;
            }
                break;
            case PeriodCellType_Notes:{
                NSArray *cellArray = [[NSBundle mainBundle] loadNibNamed:@"A3LadyCalendarAddAccountCell" owner:nil options:nil];
                cell = [cellArray objectAtIndex:1];
                UITextView *textView = (UITextView *)[cell viewWithTag:10];
                textView.delegate = self;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
                break;
            case PeriodCellType_DateInput:{
                NSArray *cellArray = [[NSBundle mainBundle] loadNibNamed:@"A3LadyCalendarAddAccountCell" owner:nil options:nil];
                cell = [cellArray objectAtIndex:2];
                UIDatePicker *datePicker = (UIDatePicker*)[cell viewWithTag:10];
                datePicker.datePickerMode = UIDatePickerModeDate;
                [datePicker addTarget:self action:@selector(changeDateAction:) forControlEvents:UIControlEventValueChanged];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
                break;
            case PeriodCellType_Delete:
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
                cell.textLabel.textColor = [UIColor colorWithRGBRed:255 green:59 blue:48 alpha:255];
                cell.textLabel.textAlignment = NSTextAlignmentCenter;
                break;
        }
    }
    
    switch (cellType) {
        case PeriodCellType_StartDate:
            cell.textLabel.text = [item objectForKey:ItemKey_Title];
            cell.detailTextLabel.text = [[A3LadyCalendarModelManager sharedManager] dateStringForDate:[_periodModel objectForKey:PeriodItem_StartDate]];
            cell.detailTextLabel.textColor = ( [self.inputItemKey isEqualToString:PeriodItem_StartDate] ? [UIColor colorWithRGBRed:0 green:122 blue:255 alpha:255] : [UIColor colorWithRGBRed:128 green:128 blue:128 alpha:255] );
            break;
        case PeriodCellType_EndDate:{
            cell.textLabel.text = [item objectForKey:ItemKey_Title];
            cell.detailTextLabel.text = [[A3LadyCalendarModelManager sharedManager] dateStringForDate:[_periodModel objectForKey:PeriodItem_EndDate]];
            cell.detailTextLabel.textColor = ( [self.inputItemKey isEqualToString:PeriodItem_EndDate] ? [UIColor colorWithRGBRed:0 green:122 blue:255 alpha:255] : [UIColor colorWithRGBRed:128 green:128 blue:128 alpha:255] );
            NSDate *startDate = [_periodModel objectForKey:PeriodItem_StartDate];
            NSDate *endDate = [_periodModel objectForKey:PeriodItem_EndDate];
            
            if( [endDate timeIntervalSince1970] < [startDate timeIntervalSince1970] ){
                NSDictionary *attr = @{NSFontAttributeName: cell.detailTextLabel.font, NSStrikethroughStyleAttributeName : @(NSUnderlineStyleSingle)};
                cell.detailTextLabel.attributedText = [[NSAttributedString alloc] initWithString:cell.detailTextLabel.text attributes:attr];
            }
            else{
                NSDictionary *attr = @{NSFontAttributeName: cell.detailTextLabel.font, NSStrikethroughStyleAttributeName : @(NSUnderlineStyleNone)};
                cell.detailTextLabel.attributedText = [[NSAttributedString alloc] initWithString:cell.detailTextLabel.text attributes:attr];
            }
        }
            break;
        case PeriodCellType_CycleLength:{
            cell.textLabel.text = [item objectForKey:ItemKey_Title];
            UITextField *textField = (UITextField*)cell.accessoryView;
            textField.text = [NSString stringWithFormat:@"%ld",(long)[[_periodModel objectForKey:PeriodItem_CycleLength] integerValue]];
            
        }
            break;
        case PeriodCellType_Ovulation:
            cell.textLabel.text = [item objectForKey:ItemKey_Title];
            cell.detailTextLabel.text = [[A3LadyCalendarModelManager sharedManager] dateStringForDate:[_periodModel objectForKey:PeriodItem_Ovulation]];
            cell.detailTextLabel.textColor = ( [self.inputItemKey isEqualToString:PeriodItem_Ovulation] ? [UIColor colorWithRGBRed:0 green:122 blue:255 alpha:255] : [UIColor colorWithRGBRed:128 green:128 blue:128 alpha:255] );
            break;
            
        case PeriodCellType_Notes:{
            UITextView *textView = (UITextView*)[cell viewWithTag:10];
            textView.text = ([[_periodModel objectForKey:PeriodItem_Notes] length] > 0 ? [_periodModel objectForKey:PeriodItem_Notes] : [item objectForKey:ItemKey_Title]);
            textView.textColor = ([[_periodModel objectForKey:PeriodItem_Notes] length] < 1 ? [UIColor colorWithRed:178.0/255.0 green:178.0/255.0 blue:178.0/255.0 alpha:1.0] : [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0]);
        }
            break;
        case PeriodCellType_DateInput:{
            UIDatePicker *datePicker = (UIDatePicker*)[cell viewWithTag:10];
            datePicker.datePickerMode = UIDatePickerModeDate;
            datePicker.date = ([_periodModel objectForKey:self.inputItemKey] ? [_periodModel objectForKey:self.inputItemKey] : [A3DateHelper dateMake12PM:[NSDate date]]);
        }
            break;
        case PeriodCellType_Delete:
            cell.textLabel.text = [item objectForKey:ItemKey_Title];
            break;
    }
    
    return cell;
}

#pragma mark - Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat retHeight = 44.0;
    
    NSArray *items = [[_templateArray objectAtIndex:indexPath.section] objectForKey:ItemKey_Items];
    NSDictionary *item = [items objectAtIndex:indexPath.row];
    NSInteger cellType = [[item objectForKey:ItemKey_Type] integerValue];
    
    switch (cellType)  {
        case PeriodCellType_Notes:{
            NSString *str = [_periodModel objectForKey:PeriodItem_Notes];
            CGRect strBounds = [str boundingRectWithSize:CGSizeMake(tableView.frame.size.width, 99999.0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:17.0]} context:nil];
            retHeight = (strBounds.size.height + 30.0 < 180.0 ? 180.0 : strBounds.size.height + 30.0);
        }
            break;
        case PeriodCellType_DateInput:
            retHeight = 236.0;
            break;
    }
    
    return retHeight;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *items = [[_templateArray objectAtIndex:indexPath.section] objectForKey:ItemKey_Items];
    NSDictionary *item = [items objectAtIndex:indexPath.row];
    NSInteger cellType = [[item objectForKey:ItemKey_Type] integerValue];
    
    if( cellType == PeriodCellType_Delete ){
        cell.textLabel.frame = CGRectMake(cell.textLabel.frame.origin.x, cell.textLabel.frame.origin.y, cell.contentView.frame.size.width, cell.textLabel.frame.size.height);
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *items = [[_templateArray objectAtIndex:indexPath.section] objectForKey:ItemKey_Items];
    NSDictionary *item = [items objectAtIndex:indexPath.row];
    NSInteger cellType = [[item objectForKey:ItemKey_Type] integerValue];
    
    switch (cellType)  {
        case PeriodCellType_StartDate:
        case PeriodCellType_EndDate:
        case PeriodCellType_Ovulation:{
            [self resignAllAction];
            NSInteger inputCellType = 0;
            
            if( [self.inputItemKey isEqualToString:PeriodItem_StartDate] )
                inputCellType = PeriodCellType_StartDate;
            else if( [self.inputItemKey isEqualToString:PeriodItem_EndDate] )
                inputCellType = PeriodCellType_EndDate;
            else if( [self.inputItemKey isEqualToString:PeriodItem_Ovulation] )
                inputCellType = PeriodCellType_Ovulation;
            
            if( [self.inputItemKey length] > 0 ){
                [self closeDateInputCell];
                
                if( cellType == inputCellType )
                    return;
                else if( inputCellType == PeriodCellType_StartDate && indexPath.section == 0 )
                    indexPath = [NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section];
            }
            
            // open
            [items insertObject:@{ItemKey_Title : @"", ItemKey_Type : @(PeriodCellType_DateInput)} atIndex:indexPath.row+1];
            if( cellType == PeriodCellType_StartDate )
                self.inputItemKey = PeriodItem_StartDate;
            else if( cellType == PeriodCellType_EndDate )
                self.inputItemKey = PeriodItem_EndDate;
            else if( cellType == PeriodCellType_Ovulation )
                self.inputItemKey = PeriodItem_Ovulation;
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];

        }
            break;
        case PeriodCellType_CycleLength:{
            [self closeDateInputCell];
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            UITextField *textField = (UITextField*)cell.accessoryView;
            [textField becomeFirstResponder];
        }
            break;
        case PeriodCellType_Notes:{
            [self closeDateInputCell];
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            UITextView *textView = (UITextView*)[cell viewWithTag:10];
            [textView becomeFirstResponder];
        }
            break;
        case PeriodCellType_Delete:{
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete Period" otherButtonTitles: nil];
            [actionSheet showInView:self.view];
        }
            break;
    }
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if( buttonIndex == actionSheet.destructiveButtonIndex ){
        if( _items )
            [_items removeObject:_periodItem];
        
        if( [[A3LadyCalendarModelManager sharedManager] removePeriod:_periodItem.periodID] ){
            [[A3LadyCalendarModelManager sharedManager] recalculateDates];
            
            if( self.parentNavigationCtrl && [_items count] < 1){
                [self.parentNavigationCtrl popViewControllerAnimated:YES];
            }
            [self cancelAction:nil];
        }
    }
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
    if( [[_periodModel objectForKey:PeriodItem_Notes] length] < 1 )
        textView.text = @"";
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [_periodModel setObject:textView.text forKey:PeriodItem_Notes];
    if( [[_periodModel objectForKey:PeriodItem_Notes] length] < 1 )
        textView.text = @"Notes";
//    else{
        UITableViewCell *cell = (UITableViewCell*)[[[textView superview] superview] superview];
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
//    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSString *str = [textView.text stringByReplacingCharactersInRange:range withString:text];
    
    [_periodModel setObject:([str length] > 0 ? str : @"") forKey:PeriodItem_Notes];
    textView.textColor = ( [str length] > 0 ? [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0] : [UIColor colorWithRed:178.0/255.0 green:178.0/255.0 blue:178.0/255.0 alpha:1.0] );
    
    CGRect strBounds = [textView.text boundingRectWithSize:CGSizeMake(textView.frame.size.width, 99999.0) options:NSLineBreakByCharWrapping|NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : textView.font} context:nil];
    
    UITableViewCell *cell = (UITableViewCell*)[[[textView superview] superview] superview];
    CGFloat diffHeight = (strBounds.size.height + 30.0 < 180.0 ? 0.0 : (strBounds.size.height + 30.0) - cell.frame.size.height);
    
    //    NSLog(@"%s %f, %@",__FUNCTION__,diffHeight,NSStringFromCGRect(strBounds));
    cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height + diffHeight);
    self.tableView.contentSize = CGSizeMake(self.tableView.contentSize.width, self.tableView.contentSize.height + diffHeight);
    [self.tableView scrollRectToVisible:cell.frame animated:YES];
    
    return YES;
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidChange:(NSNotification*)noti
{
    UITextField *textField = noti.object;
    NSInteger days = [textField.text integerValue];
    [_periodModel setObject:@(days) forKey:PeriodItem_CycleLength];
    
/*
    NSDate *startDate = [_periodModel objectForKey:PeriodItem_StartDate];
    NSDate *ovulationDate = [A3DateHelper dateByAddingDays:days*0.5 fromDate:startDate];
    [_periodModel setObject:ovulationDate forKey:PeriodItem_Ovulation];
    [self reloadItemAtCellType:PeriodCellType_Ovulation];
*/
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
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
}

#pragma mark - A3KeyboardDelegate

- (void)A3KeyboardController:(id)controller clearButtonPressedTo:(UIResponder *)keyInputDelegate {
	UITextField *textField = (UITextField *) keyInputDelegate;
	textField.text = @"";
}

- (void)A3KeyboardController:(id)controller doneButtonPressedTo:(UIResponder *)keyInputDelegate
{
    [self resignAllAction];
}

#pragma mark - action method
- (void)changeDateAction:(id)sender
{
    UIDatePicker *datePicker = (UIDatePicker*)sender;
    NSDate *prevDate = [_periodModel objectForKey:PeriodItem_StartDate];
    NSDate *currentDate = [A3DateHelper dateMake12PM:datePicker.date];

    [_periodModel setObject:currentDate forKey:self.inputItemKey];
    
    NSInteger inputCellType = 0;
    if( [self.inputItemKey isEqualToString:PeriodItem_StartDate] )
        inputCellType = PeriodCellType_StartDate;
    else if( [self.inputItemKey isEqualToString:PeriodItem_EndDate] )
        inputCellType = PeriodCellType_EndDate;
    else if( [self.inputItemKey isEqualToString:PeriodItem_Ovulation] )
        inputCellType = PeriodCellType_Ovulation;
    [self reloadItemAtCellType:inputCellType];
    
    if( inputCellType == PeriodCellType_StartDate ){
        NSDate *endDate = [_periodModel objectForKey:PeriodItem_EndDate];
        NSInteger diffDays = [A3DateHelper diffDaysFromDate:prevDate toDate:endDate];
        endDate = [A3DateHelper dateByAddingDays:diffDays fromDate:[_periodModel objectForKey:PeriodItem_StartDate]];
        [_periodModel setObject:endDate forKey:PeriodItem_EndDate];
        [self reloadItemAtCellType:PeriodCellType_EndDate];

//        NSDate *startDate = [_periodModel objectForKey:PeriodItem_StartDate];
//        NSInteger ovulationDays = [[NSUserDefaults standardUserDefaults] integerForKey:A3LadyCalendarOvulationDays];
//        NSDate *ovulationDate = [A3DateHelper dateByAddingDays:ovulationDays fromDate:startDate];
//        [_periodModel setObject:ovulationDate forKey:PeriodItem_Ovulation];
//        [self reloadItemAtCellType:PeriodCellType_Ovulation];
//        [self reloadItemAtCellType:PeriodCellType_EndDate];
        
//        LadyCalendarPeriod *prevPeriod = [[A3LadyCalendarModelManager sharedManager] previousPeriodFromDate:currentDate accountID:currentAccount.accountID];
        if( _prevPeriod ){
            NSInteger cycleLength = [A3DateHelper diffDaysFromDate:_prevPeriod.startDate toDate:currentDate];
            [_periodModel setObject:@(cycleLength) forKey:PeriodItem_CycleLength];
            [self reloadItemAtCellType:PeriodCellType_CycleLength];
        }
    }
    else if( inputCellType == PeriodCellType_Ovulation ){
        NSDate *startDate = [_periodModel objectForKey:PeriodItem_StartDate];
        NSDate *ovulationDate = [_periodModel objectForKey:PeriodItem_Ovulation];
        NSInteger diffDays = [A3DateHelper diffDaysFromDate:startDate toDate:ovulationDate];
        [[NSUserDefaults standardUserDefaults] setInteger:diffDays forKey:A3LadyCalendarOvulationDays];
        [[NSUserDefaults standardUserDefaults] synchronize];
//        NSInteger cycleLength = diffDays * 2;
//        [_periodModel setObject:@(cycleLength) forKey:PeriodItem_CycleLength];
//        [self reloadItemAtCellType:PeriodCellType_CycleLength];
    }
}

- (void)doneButtonAction:(UIBarButtonItem *)button
{
    [self resignAllAction];
    
    NSDate *startDate = [_periodModel objectForKey:PeriodItem_StartDate];
    NSDate *endDate = [_periodModel objectForKey:PeriodItem_EndDate];
    
    if( endDate == nil){
        [A3LadyCalendarModelManager alertMessage:@"Please input end date." title:nil];
        return;
    }
    else if( [endDate timeIntervalSince1970] < [startDate timeIntervalSince1970] ){
        [A3LadyCalendarModelManager alertMessage:@"Cannot Save Period.\nThe start date must be before the end date." title:nil];
        return;
    }
    else if([[A3LadyCalendarModelManager sharedManager] isOverlapStartDate:startDate endDate:endDate accountID:currentAccount.accountID periodID:(_periodItem ? _periodItem.periodID : nil)] ){
        [A3LadyCalendarModelManager alertMessage:@"The new date you entered overlaps with previous dates." title:nil];
        return;
    }
//    else if( [_periodModel objectForKey:PeriodItem_Ovulation] == nil){
//        [A3LadyCalendarModelManager alertMessage:@"Please input ovulation." title:nil];
//        return;
//    }
    
//    LadyCalendarAccount *account = [[A3LadyCalendarModelManager sharedManager] currentAccount];
    // 해당 항목의 이전 항목 값을 가져와서 실제 cycle length 값을 계산하여 업데이트 한다.
//    LadyCalendarPeriod *prevPeriod = [[A3LadyCalendarModelManager sharedManager] previousPeriodFromDate:[_periodModel objectForKey:PeriodItem_StartDate] accountID:account.accountID];
    if( _prevPeriod ){
        NSInteger diffDays = [A3DateHelper diffDaysFromDate:_prevPeriod.startDate toDate:[_periodModel objectForKey:PeriodItem_StartDate]];
        _prevPeriod.cycleLength = @(diffDays);
        [_prevPeriod.managedObjectContext MR_saveToPersistentStoreAndWait];
    }
    
    BOOL isSuccess = NO;
    if( _isEditMode ){
        [_periodModel setObject:@(NO) forKey:PeriodItem_IsPerdict];
        isSuccess = [[A3LadyCalendarModelManager sharedManager] modifyPeriod:_periodModel];
    }
    else{
        isSuccess = [[A3LadyCalendarModelManager sharedManager] addPeriod:_periodModel];
    }
    if( isSuccess )
        [[A3LadyCalendarModelManager sharedManager] recalculateDates];
    [self cancelAction:nil];
}

- (void)cancelAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
