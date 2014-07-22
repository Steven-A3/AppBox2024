//
//  A3DaysCounterSlideshowOptionViewController.m
//  A3TeamWork
//
//  Created by coanyaa on 13. 10. 18..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3DaysCounterSlideshowOptionViewController.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+NumberKeyboard.h"
#import "A3DaysCounterDefine.h"
#import "A3DaysCounterModelManager.h"
#import "A3UserDefaults.h"
#import "A3DaysCounterSlideshowTransitionSelectViewController.h"
#import "A3DaysCounterSlideshowTimeSelectViewController.h"
#import "A3DaysCounterSlideshowViewController.h"
#import "UIViewController+iPad_rightSideView.h"
#import "UIViewController+tableViewStandardDimension.h"

@interface A3DaysCounterSlideshowOptionViewController ()
@property (strong, nonatomic) NSArray *sectionArray;
@property (strong, nonatomic) NSMutableDictionary *optionDict;

- (void)cancelAction:(id)sender;

- (NSDictionary*)itemAtIndexPath:(NSIndexPath*)indexPath;
- (NSInteger)cellTypeAtIndexPath:(NSIndexPath*)indexPath;

- (void)repeatValueChanged:(id)sender;
- (void)shuffleValueChanged:(id)sender;
- (void)saveCurrentOption;
@end

@implementation A3DaysCounterSlideshowOptionViewController

- (id)init {
	self = [super initWithStyle:UITableViewStyleGrouped];
	if (self) {

	}

	return self;
}

- (void)saveCurrentOption
{
	NSDate *updateDate = [NSDate date];
	[[NSUserDefaults standardUserDefaults] setObject:updateDate forKey:A3DaysCounterUserDefaultsUpdateDate];
	[[NSUserDefaults standardUserDefaults] setObject:_optionDict forKey:A3DaysCounterUserDefaultsSlideShowOptions];
    [[NSUserDefaults standardUserDefaults] synchronize];

	if ([[A3AppDelegate instance].ubiquityStoreManager cloudEnabled]) {
		NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
		[store setObject:_optionDict forKey:A3DaysCounterUserDefaultsSlideShowOptions];
		[store setObject:updateDate forKey:A3DaysCounterUserDefaultsCloudUpdateDate];
		[store synchronize];
	}
}

- (NSDictionary*)itemAtIndexPath:(NSIndexPath*)indexPath
{
    NSDictionary *dict = [_sectionArray objectAtIndex:indexPath.section];
    NSArray *items = [dict objectForKey:EventKey_Items];
    return [items objectAtIndex:indexPath.row];
}

- (NSInteger)cellTypeAtIndexPath:(NSIndexPath*)indexPath
{
    NSDictionary *item = [self itemAtIndexPath:indexPath];
    
    return [[item objectForKey:EventRowType] integerValue];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = NSLocalizedString(@"Slideshow Options", @"Slideshow Options");
    if ( IS_IPHONE )
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction:)];
    [self makeBackButtonEmptyArrow];

	self.tableView.showsVerticalScrollIndicator = NO;
	self.tableView.separatorColor = A3UITableViewSeparatorColor;
	self.tableView.separatorInset = A3UITableViewSeparatorInset;

    self.sectionArray = @[
                          @{EventRowTitle : @"", EventKey_Items : @[@{EventRowTitle : NSLocalizedString(@"Transitions", @"Transitions"), EventRowType : @(SlideshowOptionType_Transition)}]},
                          @{EventRowTitle : @"",EventKey_Items : @[@{EventRowTitle : NSLocalizedString(@"Play Each Slide For", @"Play Each Slide For"),EventRowType : @(SlideshowOptionType_Showtime)}]},
                          @{EventRowTitle : @"",EventKey_Items : @[@{EventRowTitle : NSLocalizedString(@"Slideshow_Repeat", @"Repeat"),EventRowType : @(SlideshowOptionType_Repeat)},
                                                                   @{EventRowTitle : NSLocalizedString(@"Shuffle", @"Shuffle"),EventRowType : @(SlideshowOptionType_Shuffle)}]},
                          @{EventRowTitle : @"",EventKey_Items : @[@{EventRowTitle : NSLocalizedString(@"Start Slideshow", @"Start Slideshow"),EventRowType : @(SlideshowOptionType_Startshow)}]}];
    
    NSDictionary *opt = [[NSUserDefaults standardUserDefaults] objectForKey:A3DaysCounterUserDefaultsSlideShowOptions];
    self.optionDict = [NSMutableDictionary dictionaryWithDictionary:opt];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
	[super didMoveToParentViewController:parent];

	FNLOG(@"%@", parent);
	if (!parent) {
		[[NSNotificationCenter defaultCenter] postNotificationName:A3NotificationChildViewControllerDidDismiss object:self];
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_sectionArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDictionary *dict = [_sectionArray objectAtIndex:section];
    NSArray *items = [dict objectForKey:EventKey_Items];
    return [items count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 35.0;//(section == 0 ? 35.0 : 36.0);
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return ( section == ([_sectionArray count]-1) ? 35.0 : 0.01);
}

- (UITableViewCell*)createSwitchCellID:(NSString*)cellID selector:(SEL)selector
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
    UISwitch *swButton = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 51, 31)];
    [swButton addTarget:self action:selector forControlEvents:UIControlEventValueChanged];
    cell.textLabel.font = [UIFont systemFontOfSize:17.0];
    cell.accessoryView = swButton;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (UITableViewCell*)createCellWithType:(NSInteger)cellType cellID:(NSString*)cellID
{
    UITableViewCell *cell = nil;
    switch (cellType) {
        case SlideshowOptionType_Transition:
        case SlideshowOptionType_Showtime:
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
            cell.textLabel.font = [UIFont systemFontOfSize:17.0];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:17.0];
            break;
        case SlideshowOptionType_Repeat:
            cell = [self createSwitchCellID:cellID selector:@selector(repeatValueChanged:)];
            break;
        case SlideshowOptionType_Shuffle:
            cell = [self createSwitchCellID:cellID selector:@selector(shuffleValueChanged:)];
            break;
        case SlideshowOptionType_Startshow:
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
            cell.textLabel.font = [UIFont systemFontOfSize:17.0];
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.textColor = [UIColor colorWithRed:0.0 green:122.0    /255.0 blue:1.0 alpha:1.0];
            break;
    }
    
    return cell;
}

- (void)updateTableviewCell:(UITableViewCell*)cell indexPath:(NSIndexPath*)indexPath
{
    NSDictionary *item = [self itemAtIndexPath:indexPath];
    NSInteger cellType = [[item objectForKey:EventRowType] integerValue];
    cell.textLabel.text = [item objectForKey:EventRowTitle];
    cell.accessoryType = UITableViewCellAccessoryNone;
    switch (cellType) {
        case SlideshowOptionType_Transition:
            cell.detailTextLabel.text = [_sharedManager stringForSlideshowTransitionType:[[_optionDict objectForKey:OptionKey_Transition] integerValue]];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        case SlideshowOptionType_Showtime:
            cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld seconds", @"StringsDict", nil), (long)[[_optionDict objectForKey:OptionKey_Showtime] integerValue]];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        
        case SlideshowOptionType_Repeat:{
            UISwitch *swButton = (UISwitch*)cell.accessoryView;
            swButton.on = [[_optionDict objectForKey:OptionKey_Repeat] boolValue];
        }
            break;
        case SlideshowOptionType_Shuffle:{
            UISwitch *swButton = (UISwitch*)cell.accessoryView;
            swButton.on = [[_optionDict objectForKey:OptionKey_Shuffle] boolValue];
        }
            break;
        case SlideshowOptionType_Startshow:
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *cellIDs = @[@"value1Cell",@"value1Cell",@"switchCell",@"switchCell",@"defaultCell"];
    NSDictionary *dict = [_sectionArray objectAtIndex:indexPath.section];
    NSDictionary *item = [[dict objectForKey:EventKey_Items] objectAtIndex:indexPath.row];
    NSInteger cellType = [[item objectForKey:EventRowType] integerValue];
    NSString *CellIdentifier = [cellIDs objectAtIndex:cellType];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [self createCellWithType:cellType cellID:CellIdentifier];
    }
    
    [self updateTableviewCell:cell indexPath:indexPath];
    
    return cell;
}


#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger cellType = [self cellTypeAtIndexPath:indexPath];
    if ( cellType == SlideshowOptionType_Startshow ) {
        cell.textLabel.frame = CGRectMake(cell.textLabel.frame.origin.x, cell.textLabel.frame.origin.y, cell.contentView.frame.size.width, cell.textLabel.frame.size.height);
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger cellType = [self cellTypeAtIndexPath:indexPath];
    if ( cellType == SlideshowOptionType_Transition ) {
        A3DaysCounterSlideshowTransitionSelectViewController *viewCtrl = [[A3DaysCounterSlideshowTransitionSelectViewController alloc] init];
        viewCtrl.optionDict = self.optionDict;
        viewCtrl.sharedManager = _sharedManager;
        [self.navigationController pushViewController:viewCtrl animated:YES];
    }
    else if ( cellType == SlideshowOptionType_Showtime ) {
        A3DaysCounterSlideshowTimeSelectViewController *viewCtrl = [[A3DaysCounterSlideshowTimeSelectViewController alloc] init];
        viewCtrl.optionDict = self.optionDict;
        viewCtrl.sharedManager = _sharedManager;
        [self.navigationController pushViewController:viewCtrl animated:YES];
    }
    else if ( cellType == SlideshowOptionType_Startshow ) {
        if ( [_sharedManager numberOfAllEvents] < 1 ) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"There is no events.", @"There is no events.") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil];
            [alertView show];
            return;
        }
        
        [self saveCurrentOption];

        if (IS_IPHONE) {
            [self dismissViewControllerAnimated:YES completion:^{
                if (_completionBlock) {
                    _completionBlock(self.optionDict, self.activity);
                }
            }];
        }
        else {
            [self.A3RootViewController dismissRightSideViewController];

            A3DaysCounterSlideshowViewController *viewCtrl = [[A3DaysCounterSlideshowViewController alloc] initWithNibName:nil bundle:nil];
            viewCtrl.optionDict = self.optionDict;
            viewCtrl.sharedManager = _sharedManager;
            viewCtrl.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [self presentViewController:viewCtrl animated:YES completion:nil];
        }
    }
}

#pragma mark - action methods
- (void)cancelAction:(id)sender
{
    if ( IS_IPHONE ) {
        [self.activity activityDidFinish:YES];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        [self.A3RootViewController dismissRightSideViewController];
    }
}

- (void)doneButtonAction:(UIBarButtonItem *)button
{
    [self cancelAction:nil];
}

- (void)repeatValueChanged:(id)sender
{
    UISwitch *swButton = (UISwitch*)sender;
    [_optionDict setObject:@(swButton.on) forKey:OptionKey_Repeat];
}

- (void)shuffleValueChanged:(id)sender
{
    UISwitch *swButton = (UISwitch*)sender;
    [_optionDict setObject:@(swButton.on) forKey:OptionKey_Shuffle];
}

@end
