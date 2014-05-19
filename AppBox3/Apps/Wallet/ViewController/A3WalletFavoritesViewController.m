//
//  A3WalletFavoritesViewController.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 11..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3WalletFavoritesViewController.h"
#import "A3WalletItemViewController.h"
#import "A3WalletPhotoItemViewController.h"
#import "A3WalletVideoItemViewController.h"
#import "A3WalletListPhotoCell.h"
#import "WalletData.h"
#import "WalletCategory.h"
#import "WalletItem.h"
#import "WalletItem+initialize.h"
#import "WalletField.h"
#import "WalletFieldItem.h"
#import "WalletFavorite.h"
#import "NSString+WalletStyle.h"
#import "A3AppDelegate.h"
#import "UIViewController+A3AppCategory.h"
#import "NSMutableArray+A3Sort.h"
#import "UIViewController+A3Addition.h"
#import "NSDate+TimeAgo.h"
#import "WalletFieldItem+initialize.h"
#import "FMMoveTableView.h"
#import "UIViewController+tableViewStandardDimension.h"
#import "UIColor+A3Addition.h"


@interface A3WalletFavoritesViewController ()

@property (nonatomic, strong) FMMoveTableView *tableView;

@end

@implementation A3WalletFavoritesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.title = @"Favorites";
	self.showCategoryInDetailViewController = YES;

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(managedObjectContextDidSave:) name:NSManagedObjectContextWillSaveNotification object:nil];

	if (IS_IPAD) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainMenuDidShow) name:A3NotificationMainMenuDidShow object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainMenuDidHide) name:A3NotificationMainMenuDidHide object:nil];
	}
}

- (void)removeObserver {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextWillSaveNotification object:nil];
	if (IS_IPAD) {
		[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationMainMenuDidShow object:nil];
		[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationMainMenuDidHide object:nil];
	}
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

- (void)mainMenuDidShow {
	[self enableControls:NO];
}

- (void)mainMenuDidHide {
	[self enableControls:YES];
}

- (void)enableControls:(BOOL)enable {
	if (!IS_IPAD) return;
	[self.navigationItem.leftBarButtonItem setEnabled:enable];
	UIColor *disabledColor = [UIColor colorWithRGBRed:201 green:201 blue:201 alpha:255];
	self.tabBarController.tabBar.selectedImageTintColor = enable ? nil : disabledColor;
}

- (void)managedObjectContextDidSave:(NSNotification *)notification {
	self.items = nil;
	[self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

	[self showLeftNavigationBarItems];
    
    // 페이지 들어올때마다 갱신한다.
    [self refreshItems];
    
    // edit 버튼 활성화 여부
    BOOL editable = (self.items.count>0) ? YES:NO;
    self.navigationItem.rightBarButtonItem.enabled = editable;
}

- (void)viewWillLayoutSubviews {
	[super viewWillLayoutSubviews];
    
	if (IS_IPAD) {
        
        if (self.editing) {
            
        }
        else {
			[self showLeftNavigationBarItems];
        }
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refreshItems
{
	self.items = nil;
    [self.tableView reloadData];
}

- (NSMutableArray *)items
{
    if (!super.items) {
		super.items = [NSMutableArray arrayWithArray:[WalletFavorite MR_findAllSortedBy:@"order" ascending:YES]];
    }
    
    return super.items;
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ([[self.items objectAtIndex:(NSUInteger) indexPath.row] isKindOfClass:[WalletFavorite class]]) {

		WalletFavorite *favorite = self.items[(NSUInteger) indexPath.row];
		WalletItem *item = favorite.item;

		return [self tableView:tableView cellForRowAtIndexPath:indexPath walletItem:item];
	}

    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	WalletFavorite *favorite = self.items[indexPath.row];
	[self tableView:tableView didSelectRowAtIndexPath:indexPath withItem:favorite.item];
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        
        WalletFavorite *favorite = self.items[(NSUInteger) indexPath.row];
        [self.items removeObject:favorite];
        
        [favorite.item MR_deleteEntity];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];

		[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}

@end
