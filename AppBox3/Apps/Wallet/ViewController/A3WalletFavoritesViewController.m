//
//  A3WalletFavoritesViewController.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 11..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3WalletFavoritesViewController.h"
#import "WalletItem.h"
#import "WalletFavorite.h"
#import "A3AppDelegate.h"
#import "UIViewController+NumberKeyboard.h"
#import "UIViewController+A3Addition.h"
#import "UIColor+A3Addition.h"
#import "A3InstructionViewController.h"
#import "A3UserDefaults.h"

@interface A3WalletFavoritesViewController () <A3InstructionViewControllerDelegate>

@property (nonatomic, strong) FMMoveTableView *tableView;

@end

@implementation A3WalletFavoritesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.title = NSLocalizedString(@"Favorites", @"Favorites");
	self.showCategoryInDetailViewController = YES;

	if (IS_IPAD) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainMenuDidShow) name:A3NotificationMainMenuDidShow object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainMenuDidHide) name:A3NotificationMainMenuDidHide object:nil];
	}
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cloudStoreDidImport) name:A3NotificationCloudCoreDataStoreDidImport object:nil];
}

- (void)removeObserver {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationCloudCoreDataStoreDidImport object:nil];
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
	self.tabBarController.tabBar.selectedImageTintColor = enable ? nil : disabledColor;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

	if ([self isMovingToParentViewController] || [self isBeingPresented]) {
		[self setupInstructionView];
	}

	[self showLeftNavigationBarItems];
    
    // 페이지 들어올때마다 갱신한다.
    [self refreshItems];
}

- (void)cloudStoreDidImport {
	[self refreshItems];
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

#pragma mark Instruction Related

static NSString *const A3V3InstructionDidShowForWalletFavorite = @"A3V3InstructionDidShowForWalletFavorite";

- (void)setupInstructionView
{
    if (![[A3UserDefaults standardUserDefaults] boolForKey:A3V3InstructionDidShowForWalletFavorite]) {
        [self showInstructionView];
    }
    self.navigationItem.rightBarButtonItem = [self instructionHelpBarButton];
}

- (void)showInstructionView
{
	[[A3UserDefaults standardUserDefaults] setBool:YES forKey:A3V3InstructionDidShowForWalletFavorite];
	[[A3UserDefaults standardUserDefaults] synchronize];

    UIStoryboard *instructionStoryBoard = [UIStoryboard storyboardWithName:IS_IPHONE ? A3StoryboardInstruction_iPhone : A3StoryboardInstruction_iPad bundle:nil];
    self.instructionViewController = [instructionStoryBoard instantiateViewControllerWithIdentifier:@"Wallet_4"];
    self.instructionViewController.delegate = self;

	UIWindow *mainWindow = [UIApplication sharedApplication].keyWindow;
	[mainWindow addSubview:self.instructionViewController.view];
	[mainWindow.rootViewController addChildViewController:self.instructionViewController];

    self.instructionViewController.view.frame = self.tabBarController.view.frame;
    self.instructionViewController.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight;

	if (IS_IOS7) {
		[self rotateAccordingToStatusBarOrientationAndSupportedOrientations];

		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(statusBarFrameOrOrientationChanged:)
													 name:UIApplicationDidChangeStatusBarOrientationNotification
												   object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(statusBarFrameOrOrientationChanged:)
													 name:UIApplicationDidChangeStatusBarFrameNotification
												   object:nil];
	}
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ([[self.items objectAtIndex:(NSUInteger) indexPath.row] isKindOfClass:[WalletFavorite class]]) {

		WalletFavorite *favorite = self.items[(NSUInteger) indexPath.row];
		WalletItem *item = [WalletItem MR_findFirstByAttribute:@"uniqueID" withValue:favorite.itemID];

		return [self tableView:tableView cellForRowAtIndexPath:indexPath walletItem:item];
	}

    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	WalletFavorite *favorite = self.items[indexPath.row];
	WalletItem *item = [WalletItem MR_findFirstByAttribute:@"uniqueID" withValue:favorite.itemID];
	[self tableView:tableView didSelectRowAtIndexPath:indexPath withItem:item];
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        
        WalletFavorite *favorite = self.items[(NSUInteger) indexPath.row];
        [self.items removeObject:favorite];
        
        [favorite MR_deleteEntity];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];

		[[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
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
