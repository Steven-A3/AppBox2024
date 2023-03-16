//
//  A3WalletMoreTableViewController.m
//  AppBox3
//
//  Created by A3 on 4/13/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.j
//

#import "A3WalletMoreTableViewController.h"
#import "A3WalletMoreTableViewCell.h"
#import "UIViewController+A3Addition.h"
#import "A3WalletMainTabBarController.h"
#import "UIViewController+tableViewStandardDimension.h"
#import "A3WalletAllViewController.h"
#import "A3WalletFavoritesViewController.h"
#import "A3WalletCategoryViewController.h"
#import "A3WalletCategoryEditViewController.h"
#import "UIViewController+NumberKeyboard.h"
#import "UIColor+A3Addition.h"
#import "A3InstructionViewController.h"
#import "WalletItem.h"
#import "WalletFavorite.h"
#import "WalletData.h"
#import "A3UserDefaults.h"
#import "WalletCategory.h"
#import "NSMutableArray+A3Sort.h"
#import "NSManagedObject+extension.h"
#import "NSManagedObjectContext+extension.h"

NSString *const A3WalletMoreTableViewCellIdentifier = @"Cell";

@interface A3WalletMoreTableViewController () <A3InstructionViewControllerDelegate>

@property (nonatomic, strong) NSMutableArray *categories;
@property (nonatomic, strong) NSArray *sections;
@property (nonatomic, strong) A3InstructionViewController *instructionViewController;

@end

@implementation A3WalletMoreTableViewController {
	BOOL _isAddingCategoryInProgress;
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

	self.title = NSLocalizedString(@"More", @"More");

	if (_isEditing) {
		[self leftBarButtonAddButton];
        
        UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonAction:)];
        UIBarButtonItem *help = [self instructionHelpBarButton];
        self.navigationItem.rightBarButtonItems = @[done, help];
	}
    else {
		if (IS_IPAD || IS_PORTRAIT) {
			[self leftBarButtonAppsButton];
		} else {
			self.navigationItem.leftBarButtonItem = nil;
			self.navigationItem.hidesBackButton = YES;
		}
		[self rightBarButtonEditButton];
	}

	[self.tableView registerClass:[A3WalletMoreTableViewCell class] forCellReuseIdentifier:A3WalletMoreTableViewCellIdentifier];
	[self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
	self.tableView.showsVerticalScrollIndicator = NO;
	self.tableView.allowsSelectionDuringEditing = YES;
	self.tableView.separatorInset = A3UITableViewSeparatorInset;
	if ([self.tableView respondsToSelector:@selector(cellLayoutMarginsFollowReadableWidth)]) {
		self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
	}
	if ([self.tableView respondsToSelector:@selector(layoutMargins)]) {
		self.tableView.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0);
	}
    if (_isEditing) {
        [self.tableView setEditing:YES animated:YES];
    }

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDefaultsDidChange) name:A3UserDefaultsDidChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveCategoryAddedNotification:) name:A3WalletNotificationCategoryAdded object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
	if (IS_IPAD) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainMenuDidShow) name:A3NotificationMainMenuDidShow object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainMenuDidHide) name:A3NotificationMainMenuDidHide object:nil];
	}
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)applicationDidEnterBackground {
	[self dismissInstructionViewController:nil];
}

- (void)applicationWillResignActive {
	[self resignFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated {
	_categories = nil;
	[self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	if (![self isMovingToParentViewController]) {
		if (_isAddingCategoryInProgress) {
			_isAddingCategoryInProgress = NO;
			NSIndexPath *indexPath;
			if (_isEditing) {
				NSUInteger lastSection = [self.tableView numberOfSections] - 1;
				NSUInteger lastRow = [self.tableView numberOfRowsInSection:lastSection] - 1;
				indexPath = [NSIndexPath indexPathForRow:lastRow inSection:lastSection];
			} else {
				NSUInteger lastRow = [self.tableView numberOfRowsInSection:0] - 1;
				indexPath = [NSIndexPath indexPathForRow:lastRow inSection:0];
			}
			[self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
		}
	}

	[[UIApplication sharedApplication] setStatusBarHidden:NO];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
	[self.navigationController setNavigationBarHidden:NO];
	
	if (_isEditing) {
		[self setupInstructionView];
	}
	if (IS_IPHONE && IS_PORTRAIT) {
		if (_isEditing) {
			[self leftBarButtonAddButton];
		} else {
			[self leftBarButtonAppsButton];
		}
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	if ([self isMovingFromParentViewController] || [self isBeingDismissed]) {
		FNLOG();
		[self removeObserver];
	}
}

- (void)removeObserver {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3UserDefaultsDidChangeNotification object:nil];
	if (IS_IPAD) {
		[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationMainMenuDidShow object:nil];
		[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationMainMenuDidHide object:nil];
	}
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
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
	[self.navigationItem.rightBarButtonItem setEnabled:enable];
	self.tabBarController.tabBar.tintColor = enable ? nil : [UIColor colorWithRGBRed:201 green:201 blue:201 alpha:255];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];

	if (IS_IPHONE && IS_LANDSCAPE) {
		if (_isEditing) {
			[self leftBarButtonAddButton];
		} else {
			[self leftBarButtonAppsButton];
		}
	}
}

- (void)userDefaultsDidChange {
    if (_isEditing) {
    //  TODO : Edit 모드에서 행 순서를 변경하는 중에 멈추는 문제를 방지하기 위하여 일단 반환하도록 하였습니다.
        return;
    }
    
	_categories = nil;
	_sections = nil;

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)leftBarButtonAddButton {
	UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addCategoryButtonAction)];
	self.navigationItem.leftBarButtonItem = addButton;
}

- (void)rightBarButtonEditButton {
	UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editButtonAction:)];
	self.navigationItem.rightBarButtonItem = editButton;
}

- (void)editButtonAction:(UIBarButtonItem *)editButton {
	A3WalletMoreTableViewController *editingViewController = [[A3WalletMoreTableViewController alloc] init];
	editingViewController.mainTabBarController = self.mainTabBarController;
	editingViewController.isEditing = YES;
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:editingViewController];
	[self.mainTabBarController presentViewController:navigationController animated:YES completion:nil];
	return;
}

- (void)doneButtonAction:(UIBarButtonItem *)button {
	FNLOG(@"%@", self.presentingViewController);
	[self dismissViewControllerAnimated:YES completion:nil];
	[self.mainTabBarController setupTabBar];
}

- (void)addCategoryButtonAction {
	_isAddingCategoryInProgress = YES;

	UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"WalletPhoneStoryBoard" bundle:nil];
	A3WalletCategoryEditViewController *viewController = [storyBoard instantiateViewControllerWithIdentifier:@"A3WalletCategoryEditViewController"];
	viewController.isAddingCategory = YES;

	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Instruction Related

static NSString *const A3V3InstructionDidShowForWalletMore = @"A3V3InstructionDidShowForWalletMore";

- (void)setupInstructionView
{
    if ([self shouldShowHelpView]) {
        [self showInstructionView];
    }
}

- (BOOL)shouldShowHelpView {
	return ![[A3UserDefaults standardUserDefaults] boolForKey:A3V3InstructionDidShowForWalletMore];
}

- (void)showInstructionView
{
	[[A3UserDefaults standardUserDefaults] setBool:YES forKey:A3V3InstructionDidShowForWalletMore];
	[[A3UserDefaults standardUserDefaults] synchronize];

    UIStoryboard *instructionStoryBoard = [UIStoryboard storyboardWithName:IS_IPHONE ? A3StoryboardInstruction_iPhone : A3StoryboardInstruction_iPad bundle:nil];
    _instructionViewController = [instructionStoryBoard instantiateViewControllerWithIdentifier:@"Wallet_3"];
    self.instructionViewController.delegate = self;
	if (_isEditing) {
		[self.navigationController.view addSubview:self.instructionViewController.view];
	} else {
		[self.mainTabBarController.view addSubview:self.instructionViewController.view];
	}
    self.instructionViewController.view.frame = self.view.superview.frame;
    self.instructionViewController.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight;
    
    if (IS_IPHONE35) {
        self.instructionViewController.wallet3_finger2BottomConst.constant = 150;
        self.instructionViewController.wallet3_finger3BottomConst.constant = 62;
    }
}

- (void)dismissInstructionViewController:(UIView *)view
{
    [self.instructionViewController.view removeFromSuperview];
    self.instructionViewController = nil;
}

#pragma mark - Prepare Data

- (NSMutableArray *)categories {
	if (nil == _categories) {
		if (_isEditing) {
			_categories = [[WalletData walletCategoriesFilterDoNotShow:NO] mutableCopy];
		} else {
			_categories = [[WalletData walletCategoriesFilterDoNotShow:YES] mutableCopy];
		}
	}
	return _categories;
}

- (NSUInteger)numberOfItemsOnTapBar {
	return IS_IPHONE ? 4 : 7;
}

- (NSArray *)sections {
	if (!_sections) {
		NSInteger numberOfItemsOnTapBar = MIN([self numberOfItemsOnTapBar], [self.categories count]);
		NSInteger idx = 0;

		NSMutableArray *sections = [NSMutableArray new];

		if (self.isEditing) {
			NSMutableArray *section0 = [NSMutableArray new];
			for (; idx < numberOfItemsOnTapBar; idx++) {
				[section0 addObject:_categories[idx]];
			}
			[sections addObject:section0];
		} else {
			idx = numberOfItemsOnTapBar;
		}

		if (idx < [_categories count]) {
			NSMutableArray *section1 = [NSMutableArray new];
			for (; idx < [_categories count]; idx++) {
				[section1 addObject:self.categories[idx]];
			}
			[sections addObject:section1];
		}
		_sections = sections;
	}

	return _sections;
}

- (void)didReceiveCategoryAddedNotification:(NSNotification *)notification
{
	_categories = nil;
	_sections = nil;
	[self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return [self.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.sections[section] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (self.isEditing) {
		if (section == 0) {
            return NSLocalizedString(@"Categories on the bar", @"Categories on the bar");
        }
        
		return NSLocalizedString(@"Categories in more", @"Categories in more");
	}
	return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	A3WalletMoreTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:A3WalletMoreTableViewCellIdentifier forIndexPath:indexPath];

	WalletCategory *walletCategory = self.sections[indexPath.section][indexPath.row];
	cell.cellImageView.image = [[UIImage imageNamed:walletCategory.icon] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
	cell.cellImageView.tintColor = [UIColor colorWithRed:146.0/255.0 green:146.0/255.0 blue:146.0/255.0 alpha:1.0];
	[cell.cellImageView sizeToFit];
	cell.cellTitleLabel.text = NSLocalizedStringFromTable(walletCategory.name, @"WalletPreset", nil);
	[cell setShowCheckImageView:indexPath.section == 1];
	if (_isEditing) {
		cell.selectionStyle = indexPath.section == 1 ? UITableViewCellSelectionStyleDefault : UITableViewCellSelectionStyleNone;
	} else {
		cell.selectionStyle = UITableViewCellSelectionStyleDefault;
	}
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
	[cell setShowCheckMark:![walletCategory.doNotShow boolValue]];

    if ([walletCategory.uniqueID isEqualToString:A3WalletUUIDAllCategory]) {
        cell.rightSideLabel.text = [self.decimalFormatter stringFromNumber:@([WalletItem countOfEntities])];
    }
    else if ([walletCategory.uniqueID isEqualToString:A3WalletUUIDFavoriteCategory]) {
        cell.rightSideLabel.text = [self.decimalFormatter stringFromNumber:@([WalletFavorite countOfEntities])];
    }
    else {
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"categoryID == %@", walletCategory.uniqueID];
        cell.rightSideLabel.text = [self.decimalFormatter stringFromNumber:@([WalletItem countOfEntitiesWithPredicate:predicate])];
    }
    
	if (_isEditing) {
		cell.rightSideLabelConstraint.with.offset(-15);
		[cell layoutIfNeeded];
	}
    
	return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellEditingStyleNone;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	// Return NO if you do not want the specified item to be editable.
	return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	FNLOG(@"%ld - %ld, %ld - %ld", (long)fromIndexPath.section, (long)fromIndexPath.row, (long)toIndexPath.section, (long)toIndexPath.row);

	NSInteger fromIndex = fromIndexPath.section * [self numberOfItemsOnTapBar] + fromIndexPath.row;
	NSInteger toIndex = toIndexPath.section > 0 ? [self numberOfItemsOnTapBar] + toIndexPath.row : toIndexPath.row;
	[self.categories moveItemInSortedArrayFromIndex:fromIndex toIndex:toIndex];

	if (fromIndexPath.section != toIndexPath.section && fromIndexPath.section == 1) {
		WalletCategory *movingObject = self.categories[fromIndex];
		movingObject.doNotShow = @NO;
	}

    NSManagedObjectContext *context = [[A3AppDelegate instance] managedObjectContext];
    [context saveContext];

	self.categories = nil;
	self.sections = nil;
	[self.tableView reloadData];
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
	// Return NO if you do not want the item to be re-orderable.
	return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (_isEditing) {
		WalletCategory *walletCategory = self.sections[indexPath.section][indexPath.row];
		walletCategory.doNotShow = @(![walletCategory.doNotShow boolValue]);
		A3WalletMoreTableViewCell *cell = (A3WalletMoreTableViewCell *) [self.tableView cellForRowAtIndexPath:indexPath];
		[cell setShowCheckMark:![walletCategory.doNotShow boolValue]];

		[self.tableView deselectRowAtIndexPath:indexPath animated:YES];

        NSManagedObjectContext *context = [[A3AppDelegate instance] managedObjectContext];
        [context saveContext];
		return;
	}

	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];

	WalletCategory *category = self.sections[indexPath.section][indexPath.row];

	UIViewController *viewController;
	if ([category.uniqueID isEqualToString:A3WalletUUIDAllCategory]) {
		A3WalletAllViewController *vc = [[A3WalletAllViewController alloc] initWithNibName:nil bundle:nil];
		vc.isFromMoreTableViewController = YES;
		vc.category = category;
		viewController = vc;
	}
	else if ([category.uniqueID isEqualToString:A3WalletUUIDFavoriteCategory]) {
		A3WalletFavoritesViewController *vc = [[A3WalletFavoritesViewController alloc] init];
		vc.isFromMoreTableViewController = YES;
		vc.category = category;
		viewController = vc;
	}
	else {
		A3WalletCategoryViewController *vc = [[A3WalletCategoryViewController alloc] initWithNibName:nil bundle:nil];
		vc.category = category;
		vc.isFromMoreTableViewController = YES;
		viewController = vc;
	}

	[self.navigationController pushViewController:viewController animated:YES];
}

@end
