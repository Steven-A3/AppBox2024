//
//  A3DaysCounterEventChangeCalendarViewController.m
//  A3TeamWork
//
//  Created by coanyaa on 2013. 11. 8..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3DaysCounterEventChangeCalendarViewController.h"
#import "A3DaysCounterModelManager.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+NumberKeyboard.h"
#import "DaysCounterCalendar.h"
#import "DaysCounterCalendar+Extension.h"
#import "DaysCounterEvent.h"
#import "UIViewController+tableViewStandardDimension.h"

@interface A3DaysCounterEventChangeCalendarViewController ()
@property (strong, nonatomic) NSArray *itemArray;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;

- (void)cancelAction:(id)sender;
@end

@implementation A3DaysCounterEventChangeCalendarViewController

- (id)init {
	self = [super initWithStyle:UITableViewStyleGrouped];
	if (self) {

	}

	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = [NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld Events", @"StringsDict", nil), (long)[_eventArray count]];

	self.tableView.showsVerticalScrollIndicator = NO;
	self.tableView.separatorColor = A3UITableViewSeparatorColor;
	self.tableView.separatorInset = A3UITableViewSeparatorInset;

    if (IS_IPHONE) {
        [self rightBarButtonDoneButton];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction:)];
    }
    
    self.navigationController.navigationBar.topItem.prompt = NSLocalizedString(@"Move these events to a new calendar.", @"Move these events to a new calendar.");
    
    NSMutableArray *array = [_sharedManager allUserCalendarList];
    self.itemArray = [array filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"calendarId != %@",_currentCalendar.calendarId]];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_itemArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"calendarListCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"A3DaysCounterAddEventCalendarListCell" owner:nil options:nil] lastObject];
        UIImageView *imageView = (UIImageView*)[cell viewWithTag:10];
        imageView.image = [imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    // Configure the cell...
    UIImageView *imageView = (UIImageView*)[cell viewWithTag:10];
    UILabel *textLabel = (UILabel*)[cell viewWithTag:11];
    
    DaysCounterCalendar *item = [_itemArray objectAtIndex:indexPath.row];
    textLabel.text = item.calendarName;
    textLabel.textColor = ( item.isShow ? [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0] : [UIColor colorWithRed:143.0/255.0 green:143.0/255.0 blue:143.0/255.0 alpha:1.0] );
    imageView.tintColor = [item color];
    cell.accessoryType = ( _selectedIndexPath && (_selectedIndexPath.row == indexPath.row) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone);
    
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *prevIndexPath = nil;
    if ( self.selectedIndexPath ) {
        prevIndexPath = [NSIndexPath indexPathForRow:_selectedIndexPath.row inSection:_selectedIndexPath.section];
    }
    self.selectedIndexPath = indexPath;
    [tableView beginUpdates];
    if ( prevIndexPath && (prevIndexPath.row != indexPath.row ) ) {
        [tableView reloadRowsAtIndexPaths:@[prevIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [tableView endUpdates];
    
    if (IS_IPAD) {
        [self doneButtonAction:nil];
    }
}

#pragma mark - action method
- (void)doneButtonAction:(UIBarButtonItem *)button
{
    if( self.selectedIndexPath == nil ){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"Please select calendar.", @"Please select calendar.") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    DaysCounterCalendar *targetCalendar = [_itemArray objectAtIndex:self.selectedIndexPath.row];
    NSManagedObjectContext *context = [_currentCalendar managedObjectContext];
    for(DaysCounterEvent *event in _eventArray){
        event.calendar = targetCalendar;
    }
    [context MR_saveToPersistentStoreAndWait];
    
    if (_doneActionCompletionBlock) {
        _doneActionCompletionBlock();
    }
    
    [self cancelAction:nil];
}

- (void)cancelAction:(id)sender
{
    if (IS_IPHONE) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        [self.A3RootViewController dismissRightSideViewController];
    }
}

@end