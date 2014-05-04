//
//  A3LadyCalendarAccountEditViewController.m
//  A3TeamWork
//
//  Created by coanyaa on 2013. 11. 18..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3LadyCalendarAccountEditViewController.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+A3AppCategory.h"
#import "A3LadyCalendarDefine.h"
#import "A3LadyCalendarModelManager.h"
#import "LadyCalendarAccount.h"
#import "A3LadyCalendarAddAccountViewController.h"
#import "SFKImage.h"
#import "A3DateHelper.h"
#import "A3UserDefaults.h"

@interface A3LadyCalendarAccountEditViewController ()
@property (strong, nonatomic) NSMutableArray *itemArray;
@property (strong, nonatomic) UIImage *checkImage;

- (void)reorderingItems;
- (void)cancelAction:(id)sender;
@end

@implementation A3LadyCalendarAccountEditViewController

- (void)reorderingItems
{
    for(NSInteger i=0; i < [_itemArray count]; i++){
        LadyCalendarAccount *item = [_itemArray objectAtIndex:i];
        item.order = [NSNumber numberWithInteger:i+1];
    }
    [[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
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

    self.title = @"Edit Accounts";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addAction:)];
    [self rightBarButtonDoneButton];
    
    [SFKImage setDefaultFont:[UIFont fontWithName:@"LigatureSymbols" size:18.0]];
    [SFKImage setDefaultColor:[UIColor colorWithRed:0.0 green:108.0/255.0 blue:1.0 alpha:1.0]];
    self.checkImage = [SFKImage imageNamed:@"check"];
    
    [self.tableView setEditing:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.itemArray = [NSMutableArray arrayWithArray:[_dataManager accountListSortedByOrderIsAscending:YES]];
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
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *cellArray = [[NSBundle mainBundle] loadNibNamed:@"A3LadyCalendarAccountListCell" owner:nil options:nil];
        cell = [cellArray objectAtIndex:2];
        UIImageView *imageView = (UIImageView*)[cell viewWithTag:12];
        imageView.image = self.checkImage;
    }
    
    LadyCalendarAccount *item = [_itemArray objectAtIndex:indexPath.row];
    UILabel *textLabel = (UILabel*)[cell viewWithTag:10];
    UILabel *detailTextLabel = (UILabel*)[cell viewWithTag:11];
    UIImageView *imageView = (UIImageView*)[cell viewWithTag:12];
    
    textLabel.text = item.name;
    detailTextLabel.text = (item.birthDay ? [A3DateHelper dateStringFromDate:item.birthDay withFormat:@"MMM dd yyyy"] : @"");
//    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    NSString *defaulID = [[NSUserDefaults standardUserDefaults] objectForKey:A3LadyCalendarCurrentAccountID];
    imageView.hidden = ![item.uniqueID isEqualToString:defaulID];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 35.0;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
//    NSString *defaulID = [[NSUserDefaults standardUserDefaults] objectForKey:A3LadyCalendarCurrentAccountID];
//    LadyCalendarAccount *item = [_itemArray objectAtIndex:indexPath.row];
    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        LadyCalendarAccount *account = [_itemArray objectAtIndex:indexPath.row];
        NSString *defaulID = [[NSUserDefaults standardUserDefaults] objectForKey:A3LadyCalendarCurrentAccountID];
        if( [account.uniqueID isEqualToString:defaulID] )
            return;

		[_dataManager removeAccount:account.uniqueID];
        [_itemArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   [self reorderingItems];
}


- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    LadyCalendarAccount *item = [_itemArray objectAtIndex:fromIndexPath.row];
    [_itemArray removeObjectAtIndex:fromIndexPath.row];
    [_itemArray insertObject:item atIndex:toIndexPath.row];
    
    [self reorderingItems];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LadyCalendarAccount *item = [_itemArray objectAtIndex:indexPath.row];
    A3LadyCalendarAddAccountViewController *viewCtrl = [[A3LadyCalendarAddAccountViewController alloc] initWithNibName:@"A3LadyCalendarAddAccountViewController" bundle:nil];
	viewCtrl.dataManager = _dataManager;
    viewCtrl.isEditMode = YES;
    viewCtrl.accountItem = item;
    UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:viewCtrl];
    navCtrl.modalPresentationStyle = UIModalPresentationCurrentContext;
    [self presentViewController:navCtrl animated:YES completion:nil];
}

#pragma mark - action method
- (void)cancelAction:(id)sender
{
    if( IS_IPHONE ){
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else{
        [[self.A3RootViewController.centerNavigationController.viewControllers lastObject] viewWillAppear:YES];
        [self.A3RootViewController dismissRightSideViewController];
    }
}

- (void)doneButtonAction:(UIBarButtonItem *)button
{
    [self cancelAction:nil];
}

- (void)addAction:(id)sender
{
    A3LadyCalendarAddAccountViewController *viewCtrl = [[A3LadyCalendarAddAccountViewController alloc] initWithNibName:@"A3LadyCalendarAddAccountViewController" bundle:nil];
	viewCtrl.dataManager = _dataManager;
    UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:viewCtrl];
    navCtrl.modalPresentationStyle = UIModalPresentationCurrentContext;
    [self presentViewController:navCtrl animated:YES completion:nil];
}

@end
