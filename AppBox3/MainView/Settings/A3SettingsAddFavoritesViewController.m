//
//  A3SettingsAddFavoritesViewController.m
//  AppBox3
//
//  Created by A3 on 1/13/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "A3SettingsAddFavoritesViewController.h"
#import "A3AppDelegate.h"
#import "A3AppDelegate+mainMenu.h"
#import "UIViewController+NumberKeyboard.h"
#import "A3CenterViewDelegate.h"
#import "UIViewController+tableViewStandardDimension.h"
#import "A3SyncManager.h"
#import "A3SyncManager+NSUbiquitousKeyValueStore.h"

@interface A3SettingsAddFavoritesViewController ()

@property (nonatomic, strong) NSArray *allMenuItems;
@property (nonatomic, strong) NSMutableArray *favoritesMenuItems;

@end

@implementation A3SettingsAddFavoritesViewController

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

	self.tableView.separatorColor = A3UITableViewSeparatorColor;
	self.tableView.separatorInset = UIEdgeInsetsMake(0, 57, 0, 0);
	if ([self.tableView respondsToSelector:@selector(cellLayoutMarginsFollowReadableWidth)]) {
		self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
	}
	if ([self.tableView respondsToSelector:@selector(layoutMargins)]) {
		self.tableView.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0);
	}

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contentsDidChange:) name:A3NotificationAppsMainMenuContentsChanged object:nil];
}

- (void)removeObserver {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationAppsMainMenuContentsChanged object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	if ([self.navigationController.navigationBar isHidden]) {
		[self.navigationController setNavigationBarHidden:NO animated:NO];
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

- (IBAction)doneButtonAction:(id)sender {
	if ([_delegate respondsToSelector:@selector(childViewControllerWillDismiss)]) {
		[_delegate childViewControllerWillDismiss];
	}
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)contentsDidChange:(NSNotification *) notification {
	if (notification.object != self) {
		_favoritesMenuItems = nil;
		[self.tableView reloadData];
	}
#ifdef DEBUG
	else
	{
		FNLOG(@"Notification received from self");
	}
#endif
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSArray *)allMenuItems {
	if (!_allMenuItems) {
		_allMenuItems = [[A3AppDelegate instance] allMenuItems];
		_allMenuItems = [_allMenuItems sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
			return [NSLocalizedString(obj1[kA3AppsMenuName], nil) compare:NSLocalizedString(obj2[kA3AppsMenuName], nil)];
		}];
	}
	return _allMenuItems;
}

- (NSMutableArray *)favoritesMenuItems {
	if (!_favoritesMenuItems) {
		_favoritesMenuItems = [[[A3AppDelegate instance] favoriteItems] mutableCopy];
	}
	return _favoritesMenuItems;
}

- (NSUInteger)indexOfMenuInFavorites:(NSDictionary *)menuItem {
	NSUInteger idx = [self.favoritesMenuItems indexOfObjectPassingTest:^BOOL(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
		if ([menuItem[kA3AppsMenuName] isEqualToString:obj[kA3AppsMenuName]]) {
			*stop = YES;
			return YES;
		}
		return NO;
	}];

	return idx;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.allMenuItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
	NSDictionary *menuItem = self.allMenuItems[indexPath.row];
	cell.textLabel.text = NSLocalizedString(menuItem[kA3AppsMenuName], nil);
	cell.imageView.image = [UIImage imageNamed:[[A3AppDelegate instance] imageNameForApp:menuItem[kA3AppsMenuName]]];

	BOOL isFavoriteItem = [self indexOfMenuInFavorites:menuItem] != NSNotFound;

	UIButton *plusButton = nil;
	if ([cell.accessoryView isKindOfClass:[UIButton class]]) {
		plusButton = (UIButton *) cell.accessoryView;
	} else {
		plusButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[plusButton setImage:[UIImage imageNamed:@"add04"] forState:UIControlStateNormal];
		[plusButton setImage:[UIImage imageNamed:@"add05"] forState:UIControlStateSelected];
		[plusButton setBounds:CGRectMake(0, 0, 44.0, 44.0)];
		[plusButton addTarget:self action:@selector(plusButtonAction:) forControlEvents:UIControlEventTouchUpInside];
		cell.accessoryView = plusButton;
	}
	plusButton.tag = indexPath.row;

	[plusButton setSelected:isFavoriteItem];
	[self setTextColorForCell:cell favorite:isFavoriteItem];

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self toggleFavorite:indexPath.row button:nil];
}

- (void)plusButtonAction:(UIButton *)button {
	[self toggleFavorite:button.tag button:button];
}

- (void)toggleFavorite:(NSUInteger)menuIndex button:(UIButton *)button {
	UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:menuIndex inSection:0]];
	if (!button) {
		button = (UIButton *) cell.accessoryView;
	}
	// Reload favorite items
	_favoritesMenuItems = nil;
	NSDictionary *menuItem = self.allMenuItems[menuIndex];
	NSUInteger idxFavorite = [self indexOfMenuInFavorites:menuItem];
	BOOL isFavorite;
	if ([button isSelected]) {
		// Remove from favorites
		isFavorite = NO;
		if (idxFavorite != NSNotFound) {
			[self.favoritesMenuItems removeObjectAtIndex:idxFavorite];
			[self saveData];
			[button setSelected:NO];
		}
	} else {
		isFavorite = YES;
		if (idxFavorite == NSNotFound) {
			[self.favoritesMenuItems addObject:menuItem];
			[self saveData];
			[button setSelected:YES];
		}
	}

	[self setTextColorForCell:cell favorite:isFavorite];
}

- (void)setTextColorForCell:(UITableViewCell *)cell favorite:(BOOL)isFavorite {
	cell.textLabel.textColor = isFavorite ? [self selectedTextColor] : [UIColor blackColor];
}

- (void)saveData {
	NSDictionary *favoriteDictionary = [[A3SyncManager sharedSyncManager] objectForKey:A3MainMenuDataEntityFavorites];

	NSMutableDictionary *editingFavorites = [NSMutableDictionary dictionaryWithDictionary:favoriteDictionary];
	editingFavorites[kA3AppsExpandableChildren] = self.favoritesMenuItems;
	[[A3SyncManager sharedSyncManager] setObject:editingFavorites
										  forKey:A3MainMenuDataEntityFavorites
												state:A3DataObjectStateModified];

	[[NSNotificationCenter defaultCenter] postNotificationName:A3NotificationAppsMainMenuContentsChanged object:self];

	[[A3AppDelegate instance] updateApplicationShortcutItems];
}

@end
