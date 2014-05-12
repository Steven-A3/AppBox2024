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
#import "UIViewController+A3AppCategory.h"
#import "A3CenterViewDelegate.h"
#import "UIViewController+tableViewStandardDimension.h"

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

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contentsDidChange:) name:A3AppsMainMenuContentsChangedNotification object:nil];
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

- (void)dealloc {
	[self removeObserver];
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
			return [obj1[kA3AppsMenuName] compare:obj2[kA3AppsMenuName]];
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
	cell.textLabel.text = menuItem[kA3AppsMenuName];
	cell.imageView.image = [UIImage imageNamed:menuItem[kA3AppsMenuImageName]];

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
			[[A3AppDelegate instance] storeFavorites:self.favoritesMenuItems];

			[[NSNotificationCenter defaultCenter] postNotificationName:A3AppsMainMenuContentsChangedNotification object:self];

			[button setSelected:NO];
		} else {
			FNLOG(@"Data changed before re-load tableview");
		}
	} else {
		isFavorite = YES;
		if (idxFavorite == NSNotFound) {
			[self.favoritesMenuItems addObject:menuItem];
			FNLOG(@"%@", menuItem);
			[[A3AppDelegate instance] storeFavorites:self.favoritesMenuItems];

			[[NSNotificationCenter defaultCenter] postNotificationName:A3AppsMainMenuContentsChangedNotification object:self];

			[button setSelected:YES];
		} else {
			FNLOG(@"Data changed before re-load tableview");
		}
	}

	[self setTextColorForCell:cell favorite:isFavorite];
}

- (void)setTextColorForCell:(UITableViewCell *)cell favorite:(BOOL)isFavorite {
	cell.textLabel.textColor = isFavorite ? [self selectedTextColor] : [UIColor blackColor];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
