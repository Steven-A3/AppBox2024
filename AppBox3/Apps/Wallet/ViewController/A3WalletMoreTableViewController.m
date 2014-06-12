//
//  A3WalletMoreTableViewController.m
//  AppBox3
//
//  Created by A3 on 4/13/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.j
//

#import "A3WalletMoreTableViewController.h"
#import "WalletCategory.h"
#import "WalletCategory+initialize.h"
#import "A3WalletMoreTableViewCell.h"
#import "UIViewController+A3Addition.h"
#import "A3WalletMainTabBarController.h"
#import "UIViewController+tableViewStandardDimension.h"
#import "A3WalletAllViewController.h"
#import "A3WalletFavoritesViewController.h"
#import "A3WalletCategoryViewController.h"
#import "NSString+conversion.h"
#import "A3WalletCategoryEditViewController.h"
#import "UIViewController+NumberKeyboard.h"
#import "UIColor+A3Addition.h"
#import "A3InstructionViewController.h"


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

	self.title = @"More";

	if (_isEditing) {
		[self leftBarButtonAddButton];
		[self rightBarButtonDoneButton];
	} else {
		[self leftBarButtonAppsButton];
		[self rightBarButtonEditButton];
	}

	[self.tableView registerClass:[A3WalletMoreTableViewCell class] forCellReuseIdentifier:A3WalletMoreTableViewCellIdentifier];
	[self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
	self.tableView.showsVerticalScrollIndicator = NO;
	self.tableView.allowsSelectionDuringEditing = YES;

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(managedObjectContextDidSave:) name:NSManagedObjectContextDidSaveNotification object:[MagicalRecordStack defaultStack].context];

	if (IS_IPAD) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainMenuDidShow) name:A3NotificationMainMenuDidShow object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainMenuDidHide) name:A3NotificationMainMenuDidHide object:nil];
	}
}

- (void)removeObserver {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:nil];
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
	[self.navigationItem.rightBarButtonItem setEnabled:enable];
	self.tabBarController.tabBar.selectedImageTintColor = enable ? nil : [UIColor colorWithRGBRed:201 green:201 blue:201 alpha:255];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	if (![self isMovingToParentViewController]) {
		if (_isAddingCategoryInProgress) {
			_isAddingCategoryInProgress = NO;
			NSIndexPath *indexPath;
			if (_isEditing) {
				NSUInteger lastRow = [self.tableView numberOfRowsInSection:1] - 1;
				indexPath = [NSIndexPath indexPathForRow:lastRow inSection:1];
			} else {
				NSUInteger lastRow = [self.tableView numberOfRowsInSection:0] - 1;
				indexPath = [NSIndexPath indexPathForRow:lastRow inSection:0];
			}
			[self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
		}
	}
    
    if (_isEditing) {
        [self setupInstructionView];
        self.tableView.editing = YES;
    }
}

- (void)managedObjectContextDidSave:(NSNotification *)notification {
	FNLOG();
	_categories = nil;
	_sections = nil;
	[self.tableView reloadData];
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
	[self.mainTabBarController setupTabBar];
	[self dismissViewControllerAnimated:YES completion:nil];
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
- (void)setupInstructionView
{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"Wallet_3"]) {
        [self showInstructionView];
    }
    [self setupTwoFingerDoubleTapGestureToShowInstruction];
}

- (void)showInstructionView
{
    UIStoryboard *instructionStoryBoard = [UIStoryboard storyboardWithName:IS_IPHONE ? @"Instruction_iPhone" : @"Instruction_iPad" bundle:nil];
    _instructionViewController = [instructionStoryBoard instantiateViewControllerWithIdentifier:@"Wallet_3"];
    self.instructionViewController.delegate = self;
    [self.navigationController.view addSubview:self.instructionViewController.view];
    self.instructionViewController.view.frame = self.view.superview.frame;
    self.instructionViewController.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight;
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
			_categories = [NSMutableArray arrayWithArray:[WalletCategory MR_findAllSortedBy:@"order" ascending:YES]];
		} else {
			NSPredicate *predicate = [NSPredicate predicateWithFormat:@"doNotShow == NO"];
			_categories = [NSMutableArray arrayWithArray:[WalletCategory MR_findAllSortedBy:@"order" ascending:YES withPredicate:predicate]];
		}
	}
	return _categories;
}

- (NSUInteger)numberOfItemsOnTapBar {
	return IS_IPHONE ? 4 : 7;
}

- (NSArray *)sections {
	if (!_sections) {
		NSUInteger numberOfItemsOnTapBar = [self numberOfItemsOnTapBar];
		NSUInteger idx = 0;

		NSMutableArray *sections = [NSMutableArray new];

		if (self.isEditing) {
			NSMutableArray *section0 = [NSMutableArray new];
			for (; idx < numberOfItemsOnTapBar; idx++) {
				[section0 addObject:self.categories[idx]];
			}
			[sections addObject:section0];
		} else {
			idx = numberOfItemsOnTapBar;
		}

		NSMutableArray *section1 = [NSMutableArray new];
		for (; idx < [self.categories count]; idx++) {
			[section1 addObject:self.categories[idx]];
		}
		[sections addObject:section1];
		_sections = sections;
	}

	return _sections;
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
            return @"Categories on the bar";
        }
        
		return @"Categories in more";
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
	cell.cellTitleLabel.text = walletCategory.name;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.separatorInset = A3UITableViewSeparatorInset;
	[cell setShowCheckImageView:indexPath.section == 1];
	if (_isEditing) {
		cell.selectionStyle = indexPath.section == 1 ? UITableViewCellSelectionStyleDefault : UITableViewCellSelectionStyleNone;
	} else {
		cell.selectionStyle = UITableViewCellSelectionStyleDefault;
	}
	[cell setShowCheckMark:![walletCategory.doNotShow boolValue]];
	cell.rightSideLabel.text = [self.decimalFormatter stringFromNumber:@([walletCategory.items count])];
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
	if (fromIndexPath.section == toIndexPath.section) {
		NSMutableArray *section = self.sections[fromIndexPath.section];
		id movingObject = section[fromIndexPath.row];
		[section removeObjectAtIndex:fromIndexPath.row];
		[section insertObject:movingObject atIndex:toIndexPath.row];

		[self rewriteOrder];
	} else {
		NSMutableArray *fromSection = self.sections[fromIndexPath.section];
		id movingObject = fromSection[fromIndexPath.row];
		[fromSection removeObjectAtIndex:fromIndexPath.row];
		NSMutableArray *toSection = self.sections[toIndexPath.section];
		[toSection insertObject:movingObject atIndex:toIndexPath.row];

		if (fromIndexPath.section == 0) {
			WalletCategory *category = movingObject;
			category.doNotShow = @NO;
		}

		dispatch_async(dispatch_get_main_queue(), ^{
			[self.tableView reloadRowsAtIndexPaths:@[toIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];

			id movingObject;
			NSIndexPath *adjustedIndexPath;
			if (fromIndexPath.section == 0) {
				movingObject = toSection[0];
				[toSection removeObjectAtIndex:0];
				[fromSection addObject:movingObject];
				adjustedIndexPath = [NSIndexPath indexPathForRow:[fromSection count] - 1 inSection:0];
				[self.tableView moveRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] toIndexPath:adjustedIndexPath];
			} else {
				NSUInteger movingRow = [toSection count] - 1;
				movingObject = toSection[movingRow];
				[toSection removeObjectAtIndex:movingRow];
				[fromSection insertObject:movingObject atIndex:0];
				adjustedIndexPath = [NSIndexPath indexPathForRow:0 inSection:1];
				[self.tableView moveRowAtIndexPath:[NSIndexPath indexPathForRow:movingRow inSection:0] toIndexPath:adjustedIndexPath];
			}
			[self.tableView reloadRowsAtIndexPaths:@[adjustedIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];

			[self rewriteOrder];
		});
	}
}

- (void)rewriteOrder {
	FNLOG();
	// Update order and save to persistent store
	NSArray *section0 = self.sections[0];
	[section0 enumerateObjectsUsingBlock:^(WalletCategory *category, NSUInteger idx, BOOL *stop) {
		category.order = [NSString orderStringWithOrder:(idx +1) * 1000000];
	}];
	NSInteger numberOfItemsOnTabBar = [self numberOfItemsOnTapBar];
	NSArray *section1 = self.sections[1];
	[section1 enumerateObjectsUsingBlock:^(WalletCategory *category, NSUInteger idx, BOOL *stop) {
		category.order = [NSString orderStringWithOrder:(numberOfItemsOnTabBar + idx + 1) * 1000000];
	}];
	// Update order and save to persistent store
	[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
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

		[self.tableView deselectRowAtIndexPath:indexPath animated:YES];

		A3WalletMoreTableViewCell *cell = (A3WalletMoreTableViewCell *) [self.tableView cellForRowAtIndexPath:indexPath];
		[cell setShowCheckMark:![walletCategory.doNotShow boolValue]];

		[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
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
