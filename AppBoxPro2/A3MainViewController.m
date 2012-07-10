//
//  A3MainViewController.m
//  AppBoxPro2
//
//  Created by Byeong Kwon Kwak on 4/25/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "A3MainViewController.h"
#import "MenuItem.h"
#import "MenuGroup.h"
#import "common.h"
#import "CommonUIDefinitions.h"
#import "A3Utilities.h"
#import "A3RowSeparatorView.h"
#import "A3iPadBatteryLifeViewController.h"
#import "FRLayeredNavigation.h"
#import "A3SearchIPADViewController.h"
#import "A3AppDelegate.h"
#import "A3CalculatorViewController.h"

@interface A3MainViewController ()

@property (strong, nonatomic) NSFetchedResultsController *menusFetchedResultsController;
@property (strong, nonatomic) UIPopoverController *searchPopoverController;
@property (strong, nonatomic) NSArray *menuGroups;

- (IBAction)editButtonTouchUpInside:(UIButton *)sender;

@end

typedef enum tagA3MenuWorkingMode {
	A3_MENU_WORKING_MODE_DISPLAY = 1,
	A3_MENU_WORKING_MODE_IS_EDITING,
	A3_MENU_WORKING_MODE_IS_ADDING
} A3MenuWorkingMode;

@implementation A3MainViewController {
	A3MenuWorkingMode menuWorkingMode;
	CGRect leftButtonFrameOnMenu, rightButtonFrameOnMenu;
	NSInteger numberOfRowsDeletedWhileEditing;
}

@synthesize managedObjectContext = _managedObjectContext;
@synthesize editButton = _editButton;
@synthesize plusButton = _plusButton;
@synthesize hotMenuView = _hotMenuView;
@synthesize leftGradientHotMenuView = _leftGradientHotMenuView;
@synthesize rightGradientHotMenuView = _rightGradientHotMenuView;
@synthesize leftGradientOnMenuView = _leftGradientOnMenuView;
@synthesize rightGradientOnMenuView = _rightGradientOnMenuView;
@synthesize menuTableView = _menuTableView;
@synthesize searchBar = _searchBar;
@synthesize searchPopoverController = _searchPopoverController;
@synthesize menusFetchedResultsController = _menusFetchedResultsController;
@synthesize menuGroups = _menuGroups;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		menuWorkingMode = A3_MENU_WORKING_MODE_DISPLAY;
		numberOfRowsDeletedWhileEditing = 0;

		NSManagedObjectContext *context = [[A3AppDelegate instance] managedObjectContext];
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"MenuGroup" inManagedObjectContext:context];
		[fetchRequest setEntity:entity];

		NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
		NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
		[fetchRequest setSortDescriptors:sortDescriptors];

		NSError *error = nil;
		self.menuGroups = [context executeFetchRequest:fetchRequest error:&error];
	}

	return self;
}


- (void)addGradientLayer {
	// GradientLayer for Hot Menu left and right side
	CAGradientLayer *leftGradientHotMenuLayer = [CAGradientLayer layer];
	[leftGradientHotMenuLayer setColors:
			[NSArray arrayWithObjects:
					(__bridge id)[[UIColor colorWithRed:8.0/255.0 green:8.0/255.0 blue:9.0/255.0 alpha:0.8] CGColor],
					(__bridge id)[[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0] CGColor],
					nil ] ];
	[leftGradientHotMenuLayer setAnchorPoint:CGPointMake(0.0, 0.0)];
	[leftGradientHotMenuLayer setBounds:[self.leftGradientHotMenuView bounds]];
	[leftGradientHotMenuLayer setStartPoint:CGPointMake(0.0, 0.5)];
	[leftGradientHotMenuLayer setEndPoint:CGPointMake(1.0, 0.5)];
	[[self.leftGradientHotMenuView layer] insertSublayer:leftGradientHotMenuLayer atIndex:1];

	CAGradientLayer *rightGradientHotMenuLayer = [CAGradientLayer layer];
	[rightGradientHotMenuLayer setColors:
			[NSArray arrayWithObjects:
					(__bridge id)[[UIColor colorWithRed:8.0/255.0 green:8.0/255.0 blue:9.0/255.0 alpha:0.8] CGColor],
					(__bridge id)[[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0] CGColor],
					nil ] ];
	[rightGradientHotMenuLayer setAnchorPoint:CGPointMake(0.0, 0.0)];
	[rightGradientHotMenuLayer setBounds:[self.rightGradientHotMenuView bounds]];
	[rightGradientHotMenuLayer setStartPoint:CGPointMake(1.0, 0.5)];
	[rightGradientHotMenuLayer setEndPoint:CGPointMake(0.0, 0.5)];
	[[self.rightGradientHotMenuView layer] insertSublayer:rightGradientHotMenuLayer atIndex:1];
	
	// Gradient layer for Tableview left and right side
	addLeftGradientLayer8Point(self.leftGradientOnMenuView);
	addRightGradientLayer8Point(self.rightGradientOnMenuView);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

	leftButtonFrameOnMenu = self.editButton.frame;
	rightButtonFrameOnMenu = self.plusButton.frame;

	[self.editButton setButtonColor:[UIColor blackColor]];
    [self.plusButton setButtonColor:[UIColor blackColor]];
	
	[self addGradientLayer];
}

- (void)viewDidUnload
{
    [self setEditButton:nil];
    [self setPlusButton:nil];
    [self setHotMenuView:nil];
    [self setLeftGradientHotMenuView:nil];
    [self setRightGradientHotMenuView:nil];
    [self setLeftGradientOnMenuView:nil];
    [self setRightGradientOnMenuView:nil];
    [self setMenuTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	FNLOG(@"HERE");
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
		return YES;
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	FNLOG(@"Rotation");
	CGFloat nextItemDistance;
	if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
		nextItemDistance = 54.0 + 256.0;
	} else {
		nextItemDistance = 54.0;
	}
	[self.layeredNavigationItem setNextItemDistance:nextItemDistance];
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

#pragma mark - Table view data source

#define MENU_GROUP_FAVORITES_ID		@"FAVORITES"

#define A3_MENU_TABLE_VIEW_WIDTH		256.0

- (BOOL)favoritesSectionExist {
	MenuItem *menuItem = [self.menusFetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
	return ([menuItem.menuGroup.groupID isEqualToString:MENU_GROUP_FAVORITES_ID]);
}

- (NSIndexPath *)translatedIndexPathForCurrentWorkingMode:(NSIndexPath *)indexPath {
	NSIndexPath *translatedIndexPath;
	switch (menuWorkingMode) {
		case A3_MENU_WORKING_MODE_DISPLAY:
		case A3_MENU_WORKING_MODE_IS_EDITING:
			translatedIndexPath = indexPath;
			break;
		case A3_MENU_WORKING_MODE_IS_ADDING:
			if ([self favoritesSectionExist]) {
				translatedIndexPath = [NSIndexPath indexPathForRow:[indexPath row] inSection:[indexPath section] + 1];
			} else {
				translatedIndexPath = indexPath;
			}
			break;
	}
	return translatedIndexPath;
}

- (MenuItem *)menuItemOfMenuID:(NSString *)menuID menuGroupID:(NSString *)menuGroupID {
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"MenuItem" inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"menuID == %@ AND menuGroup.groupID == %@", menuID, menuGroupID];
	[fetchRequest setPredicate:predicate];
	
	NSError *error = nil;
	NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	if (fetchedObjects == nil) {
		return nil;
	}
	NSAssert([fetchedObjects count] == 1, @"results must have one row");

	return [fetchedObjects objectAtIndex:0];
}

- (MenuGroup *)menuGroupOfGroupID:(NSString *)groupID {
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"MenuGroup" inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];

	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"groupID == %@", groupID];
	[fetchRequest setPredicate:predicate];

	NSError *error = nil;
	NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	if (fetchedObjects == nil) {
		return nil;
	}
	NSAssert([fetchedObjects count] == 1, @"results must have one row");

	return [fetchedObjects objectAtIndex:0];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	// Return the number of sections.

	NSInteger numberOfSections;
	switch (menuWorkingMode) {
		case A3_MENU_WORKING_MODE_DISPLAY:
			numberOfSections = [[self.menusFetchedResultsController sections] count];
			break;
		case A3_MENU_WORKING_MODE_IS_ADDING:
			numberOfSections = [[self.menusFetchedResultsController sections] count];
			if ([self favoritesSectionExist])
				numberOfSections -= 1;
			break;
		case A3_MENU_WORKING_MODE_IS_EDITING:
			numberOfSections = 1;
			break;
	}
	FNLOG(@"%d", numberOfSections);

    return numberOfSections;
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section {
	// Return the number of rows in the section.
	id <NSFetchedResultsSectionInfo> sectionInfo = [[self.menusFetchedResultsController sections] objectAtIndex:section];
	NSInteger numberOfRow = [sectionInfo numberOfObjects];
	FNLOG(@"number of rows in section %d = %d", section, numberOfRow);
	if (menuWorkingMode == A3_MENU_WORKING_MODE_IS_EDITING) {
		numberOfRow -= numberOfRowsDeletedWhileEditing;
	}
	return numberOfRow;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSInteger adjustedSection;
	adjustedSection = section;
	switch (menuWorkingMode) {
		case A3_MENU_WORKING_MODE_DISPLAY:
			// Do nothing.
			break;
		case A3_MENU_WORKING_MODE_IS_ADDING:
			if ([self favoritesSectionExist])
				adjustedSection = section + 1;
			break;
		case A3_MENU_WORKING_MODE_IS_EDITING:
			adjustedSection = 0;
			break;
	}
	return [self numberOfRowsInSection:adjustedSection];
}

#define	TABLEVIEW_CELL_SEPARATOR_TAG	101

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"menuCell";

	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}

	A3RowSeparatorView *separator = (A3RowSeparatorView *)[cell viewWithTag:TABLEVIEW_CELL_SEPARATOR_TAG];
	if (nil == separator) {
		CGFloat cellHeight = CGRectGetHeight(cell.bounds);
		CGFloat cellWidth = MENU_VIEW_WIDTH - 20.0;
		separator = [[A3RowSeparatorView alloc] initWithFrame:CGRectMake(10.0, cellHeight - 1.0, cellWidth, 2.0)];
		[separator setTag:TABLEVIEW_CELL_SEPARATOR_TAG];
		[cell addSubview:separator];
	}

	NSIndexPath *adjustedIndexPath = [self translatedIndexPathForCurrentWorkingMode:indexPath];

	MenuItem *menuItem = [self.menusFetchedResultsController objectAtIndexPath:adjustedIndexPath];

	cell.textLabel.text = menuItem.name;
	cell.textLabel.textColor = [UIColor whiteColor];
	UIImage *appIconImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:menuItem.iconName ofType:@"png"]];
	cell.imageView.image = appIconImage;

	if ((menuWorkingMode == A3_MENU_WORKING_MODE_IS_ADDING) && ([menuItem.isFavorite boolValue])) {
		UIImageView *favoriteMarkImage = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 24.0, 24.0)];
		favoriteMarkImage.image = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"green_check_in_circle" ofType:@"png"]];
		cell.accessoryView = favoriteMarkImage;
	} else {
		cell.accessoryView = nil;
	}

	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 24.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, A3_MENU_TABLE_VIEW_WIDTH, 22.0)];
	headerView.clipsToBounds = YES;
	headerView.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];

	UIView *coverToMakeViewDark = [[UIView alloc] initWithFrame:headerView.frame];
	coverToMakeViewDark.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.3];
	[headerView addSubview:coverToMakeViewDark];

	UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 0.0, A3_MENU_TABLE_VIEW_WIDTH - 20.0, 22.0)];
	headerLabel.font = [UIFont boldSystemFontOfSize:18.0];

	NSInteger adjustedSection;
	switch (menuWorkingMode) {
		case A3_MENU_WORKING_MODE_DISPLAY:
			adjustedSection = section;
			break;
		case A3_MENU_WORKING_MODE_IS_EDITING:
			adjustedSection = 0;
			break;
		case A3_MENU_WORKING_MODE_IS_ADDING:
			if ([self favoritesSectionExist])
				adjustedSection = section + 1;
			else
				adjustedSection = section;
			break;
	}

	MenuItem *menuItem = [self.menusFetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:adjustedSection]];
	headerLabel.text = menuItem.menuGroup.name;
	headerLabel.backgroundColor = [UIColor clearColor];
	headerLabel.textColor = [UIColor whiteColor];
	[headerView addSubview:headerLabel];

	UIView *leftGradient = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 8.0, 24.0)];
	[headerView addSubview:leftGradient];
	addLeftGradientLayer8Point(leftGradient);

	UIView *rightGradient = [[UIView alloc] initWithFrame:CGRectMake(A3_MENU_TABLE_VIEW_WIDTH - 8.0, 0.0, 8.0, 24.0)];
	[headerView addSubview:rightGradient];
	addRightGradientLayer8Point(rightGradient);

	A3RowSeparatorView *top = [[A3RowSeparatorView alloc] initWithFrame:CGRectMake(0.0, -1.0, A3_MENU_TABLE_VIEW_WIDTH, 2.0)];
	[headerView addSubview:top];

	A3RowSeparatorView *bottom = [[A3RowSeparatorView alloc] initWithFrame:CGRectMake(0.0, 21.0, A3_MENU_TABLE_VIEW_WIDTH, 2.0)];
	[headerView addSubview:bottom];

	return headerView;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		MenuItem *targetMenuItem = [self.menusFetchedResultsController objectAtIndexPath:indexPath];
		[self.managedObjectContext deleteObject:targetMenuItem];
		numberOfRowsDeletedWhileEditing++;
		
		// Delete the row from the data source
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];

		// Update isFavorite flag
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"MenuItem" inManagedObjectContext:self.managedObjectContext];
		[fetchRequest setEntity:entity];

		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"menuID == %@", targetMenuItem.menuID];
		[fetchRequest setPredicate:predicate];

		NSError *error = nil;
		NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
		for (MenuItem *result in fetchedObjects) {
			[result setIsFavorite:[NSNumber numberWithBool:NO]];
		}
		
	}
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	FNLOG(@"Here");

	[tableView deselectRowAtIndexPath:indexPath animated:YES];

	if (menuWorkingMode == A3_MENU_WORKING_MODE_DISPLAY) {
		[self.layeredNavigationController popToRootViewControllerAnimated:NO];

		A3iPadBatteryLifeViewController *viewController = [[A3iPadBatteryLifeViewController alloc] init];
		[self.layeredNavigationController pushViewController:viewController inFrontOf:self maximumWidth:714.0 animated:YES configuration:^(FRLayeredNavigationItem *item) {
			item.hasChrome = NO;
		}];
	} else {
		// Row selected in add mode
		NSIndexPath *translatedIndexPath = [self translatedIndexPathForCurrentWorkingMode:indexPath];
		MenuItem *menuItem = [self.menusFetchedResultsController objectAtIndexPath:translatedIndexPath];
		if ([menuItem.isFavorite boolValue]) {
			// Delete from favorites
			[menuItem setIsFavorite:[NSNumber numberWithBool:NO]];

			// Find menuItem in Favorites Group and delete it.
			MenuItem *menuItemInFavorites = [self menuItemOfMenuID:menuItem.menuID menuGroupID: MENU_GROUP_FAVORITES_ID];
			[self.managedObjectContext deleteObject:menuItemInFavorites];
		} else {
			// Update isFavorite property
			[menuItem setIsFavorite:[NSNumber numberWithBool:YES]];

			NSString *orderForNewFavoriteItem;
			NSInteger numberOfFavorites = [self numberOfRowsInSection:0];
			if (numberOfFavorites) {
				MenuItem *lastFavoriteItem = [self.menusFetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:numberOfFavorites - 1 inSection:0]];
				orderForNewFavoriteItem = [NSString stringWithFormat:@"%d", [lastFavoriteItem.order integerValue] + 10];
			} else {
				orderForNewFavoriteItem = @"100";
			}
			FNLOG(@"order string for new favorite item: %@", orderForNewFavoriteItem);

			// Add new entity
			MenuItem *newFavoritesMenuItem = [NSEntityDescription insertNewObjectForEntityForName:@"MenuItem" inManagedObjectContext:self.managedObjectContext];
			newFavoritesMenuItem.menuID = menuItem.menuID;
			newFavoritesMenuItem.iconName = menuItem.iconName;
			newFavoritesMenuItem.isFavorite = menuItem.isFavorite;
			newFavoritesMenuItem.name = menuItem.name;
			newFavoritesMenuItem.order = orderForNewFavoriteItem;

			MenuGroup *favoriteGroup = [self menuGroupOfGroupID:MENU_GROUP_FAVORITES_ID];
			NSAssert(favoriteGroup != nil, @"Database must have Favorites Group");

			[favoriteGroup setMenus:[favoriteGroup.menus setByAddingObject:newFavoritesMenuItem]];
		}
		[self.menuTableView reloadData];
	}
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
	MenuItem *sourceMenuItem = [self.menusFetchedResultsController objectAtIndexPath:sourceIndexPath];
	MenuItem *destinationMenuItem = [self.menusFetchedResultsController objectAtIndexPath:destinationIndexPath];
	NSString *sourceOrder = [sourceMenuItem order];
	NSString *destinationOrder = [destinationMenuItem order];
	[sourceMenuItem setOrder:destinationOrder];
	[destinationMenuItem setOrder:sourceOrder];
}

#pragma mark - UIAction selectors

- (void)changeLeftButtonAsCancel {
	[self.editButton setTitle:@"Cancel" forState:UIControlStateNormal];
	[self.editButton setButtonColor:[UIColor blackColor]];
}

- (void)changeRightButtonSave {
	BOOL oldAnimationEnabled = [UIView areAnimationsEnabled];
	[UIView setAnimationsEnabled:NO];

	[self.plusButton setTitle:@"Save" forState:UIControlStateNormal];
	[self.plusButton setFrame:CGRectMake(204.0, 7.0, 42.0, 26.0)];
	[self.plusButton setButtonColor:[UIColor colorWithRed:45.0/255.0 green:112.0/255.0 blue:220.0/255.0 alpha:1.0]];
	[self.plusButton.titleLabel setFont:[UIFont systemFontOfSize:14.0]];

	[UIView setAnimationsEnabled:oldAnimationEnabled];
}

- (void)resetButtonsOnMenu {
	BOOL oldAnimationEnabled = [UIView areAnimationsEnabled];
	[UIView setAnimationsEnabled:NO];

	[self.editButton setButtonColor:[UIColor blackColor]];
	[self.editButton setTitle:@"Edit" forState:UIControlStateNormal];
	[self.editButton setFrame:leftButtonFrameOnMenu];

	[self.plusButton setTitle:@"+" forState:UIControlStateNormal];
	[self.plusButton.titleLabel setFont:[UIFont boldSystemFontOfSize:24.0]];
	[self.plusButton setFrame:rightButtonFrameOnMenu];
	[self.plusButton setButtonColor:[UIColor blackColor]];

	[UIView setAnimationsEnabled:oldAnimationEnabled];
}

- (void)adjustLeftRightButtonsForAddMode {
	if (menuWorkingMode == A3_MENU_WORKING_MODE_IS_ADDING) {
		[self changeLeftButtonAsCancel];
		[self changeRightButtonSave];
	} else {
		[self resetButtonsOnMenu];
	}
}

- (IBAction)editButtonTouchUpInside:(UIButton *)sender {
	switch (menuWorkingMode) {
		case A3_MENU_WORKING_MODE_DISPLAY:
			// enter "Edit" mode
			menuWorkingMode = A3_MENU_WORKING_MODE_IS_EDITING;

			numberOfRowsDeletedWhileEditing = 0;

			[self changeLeftButtonAsCancel];
			[self changeRightButtonSave];
			break;
		case A3_MENU_WORKING_MODE_IS_EDITING:
			// cancel "Edit" mode
			menuWorkingMode = A3_MENU_WORKING_MODE_DISPLAY;
			[self.managedObjectContext rollback];
			[self resetButtonsOnMenu];
			break;
		case A3_MENU_WORKING_MODE_IS_ADDING:
			// cancel "Add" mode
			menuWorkingMode = A3_MENU_WORKING_MODE_DISPLAY;
			[self.managedObjectContext rollback];
			[self resetButtonsOnMenu];
			break;
	}

	[self.menuTableView reloadData];
	[self.menuTableView setEditing:menuWorkingMode == A3_MENU_WORKING_MODE_IS_EDITING];
}

- (IBAction)plusButtonTouchUpInside:(UIButton *)sender {
	switch (menuWorkingMode) {
		case A3_MENU_WORKING_MODE_DISPLAY:
			// Entering Add mode
			menuWorkingMode = A3_MENU_WORKING_MODE_IS_ADDING;
			[self adjustLeftRightButtonsForAddMode];
			break;
		case A3_MENU_WORKING_MODE_IS_ADDING:
			// "Save" pressed while adding
			menuWorkingMode = A3_MENU_WORKING_MODE_DISPLAY;
			[[A3AppDelegate instance] saveContext];
			[self setMenusFetchedResultsController:nil];
			[self adjustLeftRightButtonsForAddMode];
			break;
		case A3_MENU_WORKING_MODE_IS_EDITING:
			// "Save" pressed while editing
			[[A3AppDelegate instance] saveContext];

			menuWorkingMode = A3_MENU_WORKING_MODE_DISPLAY;
			self.menusFetchedResultsController = nil;

			[self resetButtonsOnMenu];

			[self.menuTableView reloadData];
			[self.menuTableView setEditing:NO];
			break;
	}
	[self.menuTableView reloadData];
}

- (IBAction)calculatorButtonTouchUpInside:(UIButton *)sender {
	A3CalculatorViewController *viewController = [[A3CalculatorViewController alloc] initWithNibName:@"Calculator_iPad" bundle:nil];
	[self.layeredNavigationController pushViewController:viewController inFrontOf:self maximumWidth:714.0 animated:YES configuration:^(FRLayeredNavigationItem *item) {
		item.hasChrome = NO;
	}];
}

#pragma mark - Search

- (IBAction)searchButtonTouchUpInside:(UIButton *)sender {
	[self.searchPopoverController presentPopoverFromRect:sender.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
	if (popoverController == self.searchPopoverController) {
		[self setSearchPopoverController:nil];
	}
}

- (UIPopoverController *)searchPopoverController {
	if (_searchPopoverController == nil) {
		A3SearchIPADViewController *searchViewController = [[A3SearchIPADViewController alloc] initWithNibName:@"SearchViewiPad" bundle:nil];
		self.searchPopoverController = [[UIPopoverController alloc] initWithContentViewController:searchViewController];
	}
	return _searchPopoverController;
}

#pragma mark - FetchResultsController

- (NSFetchedResultsController *)menusFetchedResultsController {
	if (_menusFetchedResultsController == nil) {
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		[fetchRequest setEntity:[NSEntityDescription entityForName:@"MenuItem" inManagedObjectContext:self.managedObjectContext]];

		NSString *sectionNameKeyPath = @"menuGroup.order";
		NSArray *sortDescriptors = [NSArray arrayWithObjects:[[NSSortDescriptor alloc] initWithKey:@"menuGroup.order" ascending:YES], [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES], nil];
		[fetchRequest setSortDescriptors:sortDescriptors];
		_menusFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:sectionNameKeyPath cacheName:nil];
		[_menusFetchedResultsController setDelegate:self];

		NSError *error;
		BOOL success = [_menusFetchedResultsController performFetch:&error];
		NSAssert3(success, @"Unhandled error performing fetch at %s, line %d: %@", __FUNCTION__, __LINE__, [error localizedDescription]);
	}
	return _menusFetchedResultsController;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	FNLOG(@"Data changed.");
}

@end
