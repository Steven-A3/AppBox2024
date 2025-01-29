//
//  A3WalletFavoritesViewController.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 11..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3WalletFavoritesViewController.h"
#import "A3AppDelegate.h"
#import "UIViewController+NumberKeyboard.h"
#import "UIViewController+A3Addition.h"
#import "UIColor+A3Addition.h"
#import "A3InstructionViewController.h"
#import "A3UserDefaults.h"
#import "NSManagedObject+extension.h"
#import "NSManagedObjectContext+extension.h"
#import "A3SyncManager.h"
#import "A3UIDevice.h"

@interface A3WalletFavoritesViewController () <A3InstructionViewControllerDelegate>

//@property (nonatomic, strong) FMMoveTableView *tableView;

@end

@implementation A3WalletFavoritesViewController

//@dynamic tableView;

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.title = NSLocalizedString(@"Favorites", @"Favorites");
	self.showCategoryInDetailViewController = YES;

	if (IS_IPAD) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainMenuDidShow) name:A3NotificationMainMenuDidShow object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainMenuDidHide) name:A3NotificationMainMenuDidHide object:nil];
	}
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cloudStoreDidImport:) name:NSManagedObjectContextObjectsDidChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    self.tableView.contentInset = UIEdgeInsetsZero;
}

- (void)applicationDidEnterBackground {
	[self dismissInstructionViewController:nil];
}

- (void)removeObserver {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextObjectsDidChangeNotification object:nil];
	if (IS_IPAD) {
		[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationMainMenuDidShow object:nil];
		[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationMainMenuDidHide object:nil];
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	if ([self.navigationController.navigationBar isHidden]) {
		[self.navigationController setNavigationBarHidden:NO animated:NO];
	}
	[self setupInstructionView];
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

- (void)cleanUp {
	[self dismissInstructionViewController:nil];
	[self removeObserver];
}

- (BOOL)resignFirstResponder {
	NSString *startingAppName = [[A3UserDefaults standardUserDefaults] objectForKey:kA3AppsStartingAppName];
	if ([startingAppName length] && ![startingAppName isEqualToString:A3AppName_Wallet]) {
		[self.instructionViewController.view removeFromSuperview];
		self.instructionViewController = nil;
	}
	return [super resignFirstResponder];
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
	self.tabBarController.tabBar.tintColor = enable ? nil : disabledColor;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

	[self showLeftNavigationBarItems];
    
    // 페이지 들어올때마다 갱신한다.
    [self refreshItems];
}

- (void)cloudStoreDidImport:(NSNotification *)notification {
    NSManagedObjectContext *context = notification.object;
    if (![context isKindOfClass:[NSManagedObjectContext class]]) {
        return; // Ensure the notification's object is a managed object context.
    }

    NSDictionary *userInfo = notification.userInfo;

    // Combine all changes into a single set
    NSMutableSet *allChangedObjects = [NSMutableSet set];
    [allChangedObjects unionSet:userInfo[NSInsertedObjectsKey] ?: [NSSet set]];
    [allChangedObjects unionSet:userInfo[NSUpdatedObjectsKey] ?: [NSSet set]];
    [allChangedObjects unionSet:userInfo[NSDeletedObjectsKey] ?: [NSSet set]];

    // Check if any of the changes are related to the "WalletItem_" entity
    for (NSManagedObject *object in allChangedObjects) {
        if ([object.entity.name isEqualToString:@"WalletFavorite_"]) {
            FNLOG(@"Change detected for WalletItem_: %@", object);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self refreshItems];
            });
            break; // No need to continue once we know there's a change
        }
    }
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
		super.items = [NSMutableArray arrayWithArray:[WalletFavorite_ findAllSortedBy:@"order" ascending:YES]];
    }
    
    return super.items;
}

#pragma mark Instruction Related

static NSString *const A3V3InstructionDidShowForWalletFavorite = @"A3V3InstructionDidShowForWalletFavorite";

- (void)setupInstructionView
{
    if ([self shouldShowHelpView]) {
        [self showInstructionView];
    }
    self.navigationItem.rightBarButtonItem = [self instructionHelpBarButton];
}

- (BOOL)shouldShowHelpView {
	return [[CoreDataStack shared] coreDataReady] && ![[A3UserDefaults standardUserDefaults] boolForKey:A3V3InstructionDidShowForWalletFavorite];
}

- (void)showInstructionView
{
	[[A3UserDefaults standardUserDefaults] setBool:YES forKey:A3V3InstructionDidShowForWalletFavorite];
	[[A3UserDefaults standardUserDefaults] synchronize];

    UIStoryboard *instructionStoryBoard = [UIStoryboard storyboardWithName:IS_IPHONE ? A3StoryboardInstruction_iPhone : A3StoryboardInstruction_iPad bundle:nil];
    self.instructionViewController = [instructionStoryBoard instantiateViewControllerWithIdentifier:@"Wallet_4"];
    self.instructionViewController.delegate = self;

	UIWindow *mainWindow = [UIApplication sharedApplication].myKeyWindow;
	[mainWindow addSubview:self.instructionViewController.view];
	[mainWindow.rootViewController addChildViewController:self.instructionViewController];

    self.instructionViewController.view.frame = self.tabBarController.view.frame;
    self.instructionViewController.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight;
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ([[self.items objectAtIndex:(NSUInteger) indexPath.row] isKindOfClass:[WalletFavorite_ class]]) {

		WalletFavorite_ *favorite = self.items[(NSUInteger) indexPath.row];
		WalletItem_ *item = [WalletItem_ findFirstByAttribute:@"uniqueID" withValue:favorite.itemID];

		return [self tableView:tableView cellForRowAtIndexPath:indexPath walletItem:item];
	}

    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	WalletFavorite_ *favorite = self.items[indexPath.row];
	WalletItem_ *item = [WalletItem_ findFirstByAttribute:@"uniqueID" withValue:favorite.itemID];
	[self tableView:tableView didSelectRowAtIndexPath:indexPath withItem:item];
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        
        NSManagedObjectContext *context = CoreDataStack.shared.persistentContainer.viewContext;
        WalletFavorite_ *favorite = self.items[(NSUInteger) indexPath.row];
        [self.items removeObject:favorite];
        
        [context deleteObject:favorite];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];

        [context saveIfNeeded];
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
