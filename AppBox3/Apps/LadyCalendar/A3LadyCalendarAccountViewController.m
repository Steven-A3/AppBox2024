//
//  A3LadyCalendarAccountViewController.m
//  A3TeamWork
//
//  Created by coanyaa on 2013. 11. 18..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3LadyCalendarAccountViewController.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+A3AppCategory.h"
#import "A3LadyCalendarAddAccountViewController.h"
#import "A3LadyCalendarAccountEditViewController.h"
#import "A3LadyCalendarDefine.h"
#import "A3LadyCalendarModelManager.h"
#import "LadyCalendarAccount.h"
#import "A3DateHelper.h"
#import "SFKImage.h"
#import "A3UserDefaults.h"


@interface A3LadyCalendarAccountViewController ()

@property (strong, nonatomic) NSMutableArray *itemArray;
@property (strong, nonatomic) UIImage *checkImage;
@property (strong, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation A3LadyCalendarAccountViewController {
	NSInteger numberOfCellInPage;
}

- (void)reorderingItems
{
    for(NSInteger i=0; i < [_itemArray count]; i++){
        LadyCalendarAccount *item = [_itemArray objectAtIndex:i];
        item.order = [NSNumber numberWithInteger:i+1];
    }
    [[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
}

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

    self.title = @"Accounts";
    if( [_dataManager numberOfAccount] > 0 )
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editAction:)];
    [self makeBackButtonEmptyArrow];
    
    [SFKImage setDefaultFont:[UIFont fontWithName:@"LigatureSymbols" size:18.0]];
    [SFKImage setDefaultColor:[UIColor colorWithRed:0.0 green:108.0/255.0 blue:1.0 alpha:1.0]];
    self.checkImage = [SFKImage imageNamed:@"check"];
    
//    _addButton.frame = CGRectMake(self.view.frame.size.width*0.5 - _addButton.frame.size.width*0.5, self.view.frame.size.height - _addButton.frame.size.height -self.tableView.alignmentRectInsets.top - 10.0, _addButton.frame.size.width, _addButton.frame.size.height);
//    [self.view addSubview:self.addButton];
//    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_addButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
//    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_addButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1.0 constant:_addButton.frame.size.width]];
//    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_addButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:_addButton.frame.size.height]];
//    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_addButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-10.0]];
    CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
    UIView *removeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, appFrame.size.width, 1.0/[[UIScreen mainScreen] scale])];
    removeView.backgroundColor = [UIColor colorWithRed:239.0/255.0 green:239.0/255.0 blue:244.0/255.0 alpha:1.0];
    [self.tableView addSubview:removeView];
    self.tableView.separatorInset = UIEdgeInsetsMake(0, (IS_IPHONE ? 15.0 : 28.0), 0, 0);
    NSLog(@"%s %@",__FUNCTION__, NSStringFromCGRect(self.tableView.frame));
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:YES];
    
    self.itemArray = [NSMutableArray arrayWithArray:[_dataManager accountListSortedByOrderIsAscending:YES]];
    numberOfCellInPage = (NSInteger)floor((self.tableView.frame.size.height-self.tableView.contentInset.top) / 60.0);
//    NSLog(@"%s %d / %f ",__FUNCTION__,numberOfCellInPage,(self.tableView.frame.size.height-self.tableView.contentInset.top));
    [self.tableView reloadData];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if( ![_addButton isDescendantOfView:self.view] ){
        _addButton.frame = CGRectMake(self.view.frame.size.width*0.5 - _addButton.frame.size.width*0.5, self.view.frame.size.height - _addButton.frame.size.height -20.0, _addButton.frame.size.width, _addButton.frame.size.height);
        [self.view addSubview:self.addButton];
//        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_addButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
//        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_addButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1.0 constant:_addButton.frame.size.width]];
//        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_addButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:_addButton.frame.size.height]];
//        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_addButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-20.0]];
//        [self.view layoutIfNeeded];
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    _addButton.hidden = YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    _addButton.frame = CGRectMake(self.view.frame.size.width*0.5 - _addButton.frame.size.width*0.5, self.view.frame.size.height - _addButton.frame.size.height -20.0, _addButton.frame.size.width, _addButton.frame.size.height);
    _addButton.hidden = NO;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rowCount = (NSInteger)(tableView.frame.size.height / 62.0);
    return ( [_itemArray count] < rowCount ? rowCount : [_itemArray count]);
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"accountListCell" ;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *cellArray = [[NSBundle mainBundle] loadNibNamed:@"A3LadyCalendarAccountListCell" owner:nil options:nil];
        cell = [cellArray objectAtIndex:0];
        UIImageView *imageView = (UIImageView*)[cell viewWithTag:13];
        imageView.image = self.checkImage;
        UIView *leftView = [cell viewWithTag:10];
        for(NSLayoutConstraint *layout in cell.contentView.constraints){
            if( layout.firstAttribute == NSLayoutAttributeLeading && layout.firstItem == leftView && layout.secondItem == cell.contentView ){
                layout.constant = ( IS_IPHONE ? 15.0 : 28.0);
            }
        }
        UILabel *nameLabel = (UILabel*)[cell viewWithTag:10];
        UILabel *notesLabel = (UILabel*)[cell viewWithTag:12];
        nameLabel.font = (IS_IPHONE ? [UIFont systemFontOfSize:15.0] : [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline]);
        notesLabel.font = (IS_IPHONE ? [UIFont systemFontOfSize:13.0] : [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote]);
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
//        cell.textLabel.font = (IS_IPHONE ? [UIFont systemFontOfSize:15.0] : [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline]);
    }
    
    UILabel *nameLabel = (UILabel*)[cell viewWithTag:10];
    UILabel *dateLabel = (UILabel*)[cell viewWithTag:11];
    UILabel *notesLabel = (UILabel*)[cell viewWithTag:12];
    UIImageView *imageView = (UIImageView*)[cell viewWithTag:13];
    
    if( indexPath.row < [_itemArray count] ){
        LadyCalendarAccount *item = [_itemArray objectAtIndex:indexPath.row];
        
        nameLabel.text = item.name;
        dateLabel.text = (item.birthDay ? [A3DateHelper dateStringFromDate:item.birthDay withFormat:@"MMM dd yyyy"] : @"");
        notesLabel.text = [A3DateHelper dateStringFromDate:item.modificationDate withFormat:@"MMM dd yyyy"];
        imageView.hidden = ![[[NSUserDefaults standardUserDefaults] objectForKey:A3LadyCalendarCurrentAccountID] isEqualToString:item.uniqueID];
    }
    else{
        nameLabel.text = @"";
        dateLabel.text = @"";
        notesLabel.text = @"";
        imageView.hidden = YES;
    }
//    cell.textLabel.text = item.name;
//    cell.detailTextLabel.text = (item.birthDay ? [A3DateHelper dateStringFromDate:item.birthDay withFormat:@"MMM dd yyyy"] : @"" );
//    cell.accessoryView = ( [[[NSUserDefaults standardUserDefaults] objectForKey:A3LadyCalendarCurrentAccountID] isEqualToString:item.uniqueID] ? [[UIImageView alloc] initWithImage:self.checkImage] : nil);
    
    return cell;
}


#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( indexPath.row == 0 )
        return 61.0;
    return 62.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( indexPath.row >= [_itemArray count] )
        return;
    
    LadyCalendarAccount *item = [_itemArray objectAtIndex:indexPath.row];
	[[NSUserDefaults standardUserDefaults] setObject:item.uniqueID forKey:A3LadyCalendarCurrentAccountID];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [tableView reloadData];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( indexPath.row >= [_itemArray count] )
        return NO;
    LadyCalendarAccount *account = [_itemArray objectAtIndex:indexPath.row];
    return ![[[NSUserDefaults standardUserDefaults] objectForKey:A3LadyCalendarCurrentAccountID] isEqualToString:account.uniqueID];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( editingStyle == UITableViewCellEditingStyleDelete ){
        LadyCalendarAccount *account = [_itemArray objectAtIndex:indexPath.row];
		[_dataManager removeAccount:account.uniqueID];
        [_itemArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self reorderingItems];
    }
}

#pragma mark - action method

- (IBAction)addAccountAction
{
    A3LadyCalendarAddAccountViewController *viewCtrl = [[A3LadyCalendarAddAccountViewController alloc] initWithNibName:@"A3LadyCalendarAddAccountViewController" bundle:nil];
	viewCtrl.dataManager = _dataManager;
    UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:viewCtrl];
    if( IS_IPHONE ){
        navCtrl.modalPresentationStyle = UIModalPresentationCurrentContext;
        [self presentViewController:navCtrl animated:YES completion:nil];
    }
    else{
        [self.A3RootViewController presentRightSideViewController:viewCtrl];
    }
}

- (void)editAction:(id)sender
{
    A3LadyCalendarAccountEditViewController *viewCtrl = [[A3LadyCalendarAccountEditViewController alloc] initWithNibName:@"A3LadyCalendarAccountEditViewController" bundle:nil];
	viewCtrl.dataManager = self.dataManager;
    UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:viewCtrl];
    if( IS_IPHONE ){
        navCtrl.modalPresentationStyle = UIModalPresentationCurrentContext;
        [self presentViewController:navCtrl animated:YES completion:nil];
    }
    else{
        [self.A3RootViewController presentRightSideViewController:viewCtrl];
    }
}

@end
