//
//  A3SettingsFavoritesViewController.m
//  AppBox3
//
//  Created by A3 on 1/10/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "A3SettingsFavoritesViewController.h"
#import "A3MainMenuTableViewController.h"
#import "NSMutableArray+MoveObject.h"
#import "A3AppDelegate+mainMenu.h"
#import "A3SettingsAddFavoritesViewController.h"
#import "A3CenterViewDelegate.h"
#import "UIViewController+tableViewStandardDimension.h"

@interface A3SettingsFavoritesViewController () <A3ChildViewControllerDelegate>

@property(nonatomic, strong) NSMutableArray *favorites;

@end

@implementation A3SettingsFavoritesViewController

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

	[self.tableView setEditing:YES];
	self.tableView.separatorColor = A3UITableViewSeparatorColor;
	self.tableView.separatorInset = UIEdgeInsetsMake(0, 53, 0, 0);

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuContentChanged:) name:A3NotificationAppsMainMenuContentsChanged object:nil];
}

- (void)removeObserver {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationAppsMainMenuContentsChanged object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	if ([self isMovingFromParentViewController] || [self isBeingDismissed]) {
		FNLOG();
		[self removeObserver];
	}
}

- (void)dealloc {
	[self removeObserver];
}

- (void)menuContentChanged:(NSNotification *)notification {
	if (notification.object != self) {
		_favorites = nil;
		[self.tableView reloadData];
	}
#ifdef DEBUG
	else
	{
		FNLOG(@"Notification received from self");
	}
#endif
}

- (NSMutableArray *)favorites {
	if (!_favorites) {
		_favorites = [[[A3AppDelegate instance] favoriteItems] mutableCopy];
	}
	return _favorites;
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
    return [self.favorites count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
	NSDictionary *menu = self.favorites[indexPath.row];
	cell.textLabel.text = menu[kA3AppsMenuName];
    
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.tableView numberOfRowsInSection:0] > 1;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
		[self.favorites removeObjectAtIndex:indexPath.row];
		[[A3AppDelegate instance] storeFavorites:self.favorites];
		
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];

		[[NSNotificationCenter defaultCenter] postNotificationName:A3NotificationAppsMainMenuContentsChanged object:self];

		if ([self.tableView numberOfRowsInSection:0] < 2) {
			[self.tableView reloadData];
		}
	}
}

// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	[self.favorites moveObjectFromIndex:fromIndexPath.row toIndex:toIndexPath.row];
	[[A3AppDelegate instance] storeFavorites:self.favorites];

	[[NSNotificationCenter defaultCenter] postNotificationName:A3NotificationAppsMainMenuContentsChanged object:self];
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	// Get the new view controller using [segue destinationViewController].
	// Pass the selected object to the new view controller.
	if ([[segue destinationViewController] isKindOfClass:[A3SettingsAddFavoritesViewController class]]) {
		A3SettingsAddFavoritesViewController *viewController = [segue destinationViewController];
		viewController.delegate = self;
	}
}

- (void)childViewControllerWillDismiss {
	[self.tableView reloadData];
}

@end
