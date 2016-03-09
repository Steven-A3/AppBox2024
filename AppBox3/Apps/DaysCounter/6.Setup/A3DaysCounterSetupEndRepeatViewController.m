//
//  A3DaysCounterSetupEndRepeatViewController.m
//  A3TeamWork
//
//  Created by coanyaa on 13. 10. 22..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3DaysCounterSetupEndRepeatViewController.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+NumberKeyboard.h"
#import "A3DaysCounterDefine.h"
#import "A3DaysCounterModelManager.h"
#import "A3Formatter.h"
#import "A3DateKeyboardViewController_iPad.h"
#import "A3DateKeyboardViewController_iPhone.h"
#import "SFKImage.h"
#import "DaysCounterEvent.h"
#import "A3DateHelper.h"
#import "A3AppDelegate+appearance.h"
#import "NSDateFormatter+A3Addition.h"

@interface A3DaysCounterSetupEndRepeatViewController ()
@property (strong,nonatomic) NSArray *itemArray;
@property (strong, nonatomic) A3DateKeyboardViewController *keyboardVC;
@property (strong, nonatomic) NSDate *originalValue;

@end

@implementation A3DaysCounterSetupEndRepeatViewController

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
    // Do any additional setup after loading the view from its nib.
    if ( IS_IPAD ) {
        self.originalValue = self.eventModel.repeatEndDate;
    }
    self.title = NSLocalizedString(@"End Repeat", @"End Repeat");
    
    self.itemArray = @[NSLocalizedString(@"Never", @"Never"), NSLocalizedString(@"Custom", @"Custom")];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)willDismissFromRightSide
{
    if (IS_IPAD && _dismissCompletionBlock) {
        _dismissCompletionBlock();
    }
}

#pragma mark -
- (void)updateConstraints
{
    [self.view removeConstraints:self.view.constraints];
    if ( self.keyboardVC ) {
        [_tableView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.keyboardVC.view setTranslatesAutoresizingMaskIntoConstraints:NO];
        _tableView.frame = CGRectMake(_tableView.frame.origin.x, _tableView.frame.origin.y, _tableView.frame.size.width, self.view.frame.size.height - self.keyboardVC.view.frame.size.height);
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_tableView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_tableView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_tableView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_tableView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.keyboardVC.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.keyboardVC.view attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.keyboardVC.view attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.keyboardVC.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.keyboardVC.view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:self.keyboardVC.view.frame.size.height]];
    }
    else {
        _tableView.frame = CGRectMake(_tableView.frame.origin.x, _tableView.frame.origin.y, _tableView.frame.size.width, self.view.frame.size.height);
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_tableView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_tableView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_tableView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_tableView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_itemArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 35;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath row] == 2) {
        return 236.0;
    }
    
    return 44.0;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * const cellID = @"Cell";
    static NSString * const cellID2 = @"dateInputCell";
    
    UITableViewCell *cell;
    
    if ([indexPath row] == 2) {
        cell = [tableView dequeueReusableCellWithIdentifier:cellID2];
        
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"A3DaysCounterAddEventDateInputCell" owner:nil options:nil] lastObject];
            UIDatePicker *datePicker = (UIDatePicker*)[cell viewWithTag:10];
            datePicker.datePickerMode = UIDatePickerModeDate;
            [datePicker addTarget:self action:@selector(datePickerChangeAction:) forControlEvents:UIControlEventValueChanged];
        }

        UIDatePicker *datePicker = (UIDatePicker*)[cell viewWithTag:10];
        if (_originalValue) {
            datePicker.date = _originalValue;
        }
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        
        if ( cell == nil ) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
            //cell.detailTextLabel.textColor = [UIColor colorWithRed:128/255.0 green:128/255.0 blue:128/255.0 alpha:1.0];
        }
        
        cell.textLabel.text = [_itemArray objectAtIndex:indexPath.row];
        cell.detailTextLabel.text = @"";
        cell.detailTextLabel.textColor = [UIColor colorWithRed:128/255.0 green:128/255.0 blue:128/255.0 alpha:1.0];
        
        if ( indexPath.row == 1 && self.eventModel.repeatEndDate) {
            NSDateFormatter *formatter = [NSDateFormatter new];
            cell.detailTextLabel.text = [A3DateHelper dateStringFromDate:[self.eventModel repeatEndDate] withFormat:[formatter customFullStyleFormat]];
            
            cell.detailTextLabel.textColor = [self.itemArray count] == 3 ? [A3AppDelegate instance].themeColor : [UIColor colorWithRed:128/255.0 green:128/255.0 blue:128/255.0 alpha:1.0];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else if ( indexPath.row == 0 && !self.eventModel.repeatEndDate ) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }

    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch ([indexPath row]) {
        case 0:
        {
            self.eventModel.repeatEndDate = nil;
            [tableView reloadData];
            [self doneButtonAction:nil];
        }
            break;

        case 1:
        {
            NSDate *repeatEndDate = self.eventModel.repeatEndDate;
            if ( !repeatEndDate ) {
                self.eventModel.repeatEndDate = [NSDate date];
            }
            
            UITableViewCell *cell_0row = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section]];
            cell_0row.accessoryType = UITableViewCellAccessoryNone;
            UITableViewCell *cell_1row = [tableView cellForRowAtIndexPath:indexPath];
            NSDateFormatter *formatter = [NSDateFormatter new];
            cell_1row.detailTextLabel.text = [A3DateHelper dateStringFromDate:[self.eventModel repeatEndDate] withFormat:[formatter customFullStyleFormat]];
            cell_1row.accessoryType = UITableViewCellAccessoryCheckmark;
            
            if ([self.itemArray count] == 3) {
                [self hideDatePicker];
                cell_1row.detailTextLabel.textColor = [UIColor colorWithRed:128/255.0 green:128/255.0 blue:128/255.0 alpha:1.0];
            }
            else {
                [self showDatePicker:[self.eventModel repeatEndDate]];
                cell_1row.detailTextLabel.textColor = [A3AppDelegate instance].themeColor;
            }
        }
            break;

        default:
            break;
    }
}

#pragma mark - A3DateKeyboardDelegate
- (void)dateKeyboardValueChangedDate:(NSDate *)date
{
    if ( date == nil ) {
        return;
    }
    
    self.eventModel.repeatEndDate = date;
    [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)dateKeyboardDoneButtonPressed:(A3DateKeyboardViewController *)keyboardViewController {
    [self doneButtonAction:nil];
}

- (void)showDatePicker:(NSDate *)date
{
    self.itemArray = @[NSLocalizedString(@"Never", @"Never"), NSLocalizedString(@"Custom", @"Custom"), @"DatePicker"];
    
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }];
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationMiddle];
    [self.tableView endUpdates];
    [CATransaction commit];
}

- (void)hideDatePicker
{
    self.itemArray = @[NSLocalizedString(@"Never", @"Never"), NSLocalizedString(@"Custom", @"Custom")];
    
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationMiddle];
    [self.tableView endUpdates];
}

#pragma mark - action method

- (void)cancelAction:(id)sender
{
    self.eventModel.repeatEndDate = self.originalValue;

    if ( IS_IPAD ) {
        [[[A3AppDelegate instance] rootViewController_iPad] dismissRightSideViewController];
        [[[A3AppDelegate instance] rootViewController_iPad].centerNavigationController viewWillAppear:YES];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)doneButtonAction:(UIBarButtonItem *)button
{
    if ( IS_IPAD ) {
        [[[A3AppDelegate instance] rootViewController_iPad] dismissRightSideViewController];
        [[[A3AppDelegate instance] rootViewController_iPad].centerNavigationController viewWillAppear:YES];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
        
        if (_dismissCompletionBlock) {
            _dismissCompletionBlock();
        }
    }
}

- (void)datePickerChangeAction:(id)sender
{
    self.eventModel.repeatEndDate = ((UIDatePicker *)sender).date;
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

@end
