//
//  A3UnitPriceSelectViewController.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 3..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3UnitPriceSelectViewController.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+NumberKeyboard.h"
#import "A3UnitConverterTVActionCell.h"
#import "A3UnitPriceAddViewController.h"
#import "UIViewController+tableViewStandardDimension.h"
#import "A3UnitDataManager.h"
#import "A3StandardTableViewCell.h"

@interface A3UnitPriceSelectViewController () <UISearchControllerDelegate, UISearchResultsUpdating, A3UnitPriceAddViewControllerDelegate>
{
    BOOL isEdited;
}

@property (nonatomic, strong) UITableView *tableView;
/* TODO: 아래 Property는 삭제 돠어야 한다. UISearchController.searchBar를 사용하기 때문
 * TODO: Before delete the following property, make sure all required codes are converted.
@property (nonatomic, strong) UISearchBar *searchBar;
 */
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) UITableViewController *searchResultTableViewController;
@property (nonatomic, strong) NSArray *filteredResults;
@property (nonatomic, strong) NSMutableArray *allData;
@property (nonatomic, strong) NSMutableArray *favorites;
@property (nonatomic, strong) NSMutableDictionary *noneItem;
@property (nonatomic, strong) UIBarButtonItem *cancelItem;
@property (nonatomic, strong) UIBarButtonItem *plusItem;

@end

@implementation A3UnitPriceSelectViewController

NSString *const A3UnitPriceActionCellID2 = @"A3UnitPriceActionCell";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self.allData insertObject:self.noneItem atIndex:0];

    self.definesPresentationContext = YES;
    FNLOGRECT(self.view.bounds);
    
	self.tableView = [UITableView new];
	_tableView.frame = self.view.bounds;
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.showsVerticalScrollIndicator = NO;
	_tableView.separatorColor = A3UITableViewSeparatorColor;
	_tableView.separatorInset = A3UITableViewSeparatorInset;
    _tableView.rowHeight = 44.0;
	if ([_tableView respondsToSelector:@selector(cellLayoutMarginsFollowReadableWidth)]) {
		_tableView.cellLayoutMarginsFollowReadableWidth = NO;
	}
	if ([_tableView respondsToSelector:@selector(layoutMargins)]) {
		_tableView.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0);
	}
	[self.view addSubview:_tableView];

    [_tableView makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"A3UnitConverterTVActionCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:A3UnitPriceActionCellID2];
    
	self.tableView.tableHeaderView = self.searchController.searchBar;

    if ((!_shouldPopViewController && IS_IPHONE) || IS_IPAD) {
        self.tabBarController.navigationItem.leftBarButtonItem = self.cancelItem;
    }
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cloudStoreDidImport) name:A3NotificationCloudKeyValueStoreDidImport object:nil];
    
#ifdef __IPHONE_8_0
	if ([self.tableView respondsToSelector:@selector(layoutMargins)])
	{
		UIEdgeInsets layoutMargins = self.tableView.layoutMargins;
		layoutMargins.left = 0;
		self.tableView.layoutMargins = layoutMargins;
	}
#endif
    self.tableView.separatorInset = A3UITableViewSeparatorInset;
	if ([self.tableView respondsToSelector:@selector(cellLayoutMarginsFollowReadableWidth)]) {
		self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
	}

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)applicationDidEnterBackground {
	if ([[A3AppDelegate instance] shouldProtectScreen]) {
		[self.searchController.searchBar resignFirstResponder];
	}
}

- (void)cloudStoreDidImport {
	_favorites = nil;

	[self.tableView reloadData];
}

- (void)removeObserver {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationCloudKeyValueStoreDidImport object:nil];
}

- (void)dealloc {
	[self removeObserver];
}

- (NSMutableArray *)allData {
	if (!_allData) {
		_allData = [_dataManager allUnitsSortedByLocalizedNameForCategoryID:_categoryID];
	}
	return _allData;
}

- (NSMutableArray *)favorites {
	if (!_favorites) {
		_favorites = [NSMutableArray arrayWithArray:[_dataManager unitPriceFavoriteForCategoryID:_categoryID]];
	}
	return _favorites;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    
	if ([_placeHolder length]) {
		self.searchController.searchBar.text = _placeHolder;
		[self filterContentForSearchText:_placeHolder];
	}
    
    UISegmentedControl *segment = (UISegmentedControl *)self.navigationController.tabBarController.navigationItem.titleView;
    self.isFavoriteMode = segment.selectedSegmentIndex==1 ? YES:NO;
    
    if (![self isEditing]) {
        if ((!_shouldPopViewController && IS_IPHONE) || IS_IPAD) {
            self.tabBarController.navigationItem.leftBarButtonItem = self.cancelItem;
        }
        else {
            self.tabBarController.navigationItem.leftBarButtonItem = nil;
        }
    }
    else {
        self.tabBarController.navigationItem.leftBarButtonItem = self.plusItem;
    }
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	if ([self.navigationController.navigationBar isHidden]) {
		[self.navigationController setNavigationBarHidden:NO animated:NO];
	}
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

	if ([self isMovingFromParentViewController] || [self isBeingDismissed]) {
		[self removeObserver];

		if (isEdited) {
			// 보고
			[self updateEditedDataToDelegate];
		}
	}
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
#ifdef __IPHONE_8_0
	if ([self.tableView respondsToSelector:@selector(layoutMargins)])
	{
		UIEdgeInsets layoutMargins = self.tableView.layoutMargins;
		layoutMargins.left = 0;
		self.tableView.layoutMargins = layoutMargins;
	}
#endif
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSMutableDictionary *)noneItem {
	if (!_noneItem) {
		_noneItem = [NSMutableDictionary dictionaryWithDictionary:@{@"title":@"None", @"order":@""}];
	}
	return _noneItem;
}

- (UIBarButtonItem *)cancelItem
{
    if (!_cancelItem) {
        _cancelItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", @"Done") style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonAction:)];
    }
    
    return _cancelItem;
}

- (UIBarButtonItem *)plusItem
{
    if (!_plusItem) {
        _plusItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"add03"] style:UIBarButtonItemStylePlain target:self action:@selector(plusButtonAction:)];
    }
    
    return _plusItem;
}

- (UITableViewController *)searchResultTableViewController {
	if (!_searchResultTableViewController) {
		_searchResultTableViewController = [[UITableViewController alloc] init];
		_searchResultTableViewController.tableView.dataSource = self;
		_searchResultTableViewController.tableView.delegate = self;
		_searchResultTableViewController.tableView.showsVerticalScrollIndicator = NO;
		/*
		 * TODO: 이 코드는 iPad에서 필요한 사항인지 확인 후 적용합니다.
		if ([_searchResultTableViewController.tableView respondsToSelector:@selector(cellLayoutMarginsFollowReadableWidth)]) {
			_searchResultTableViewController.tableView.cellLayoutMarginsFollowReadableWidth = NO;
		}
		if ([_searchResultTableViewController.tableView respondsToSelector:@selector(layoutMargins)]) {
			_searchResultTableViewController.tableView.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0);
		}
		*/
	}
	return _searchResultTableViewController;
}

- (UISearchController *)searchController {
	if (!_searchController) {
		_searchController = [[UISearchController alloc] initWithSearchResultsController:self.searchResultTableViewController];
		_searchController.delegate = self;
		_searchController.searchBar.delegate = self;
        _searchController.searchResultsUpdater = self;
		[_searchController.searchBar sizeToFit];
	}
	return _searchController;
}

- (void)setIsFavoriteMode:(BOOL)isFavoriteMode
{
	/* TODO: Confirm this code really executed
	 */
    _isFavoriteMode = isFavoriteMode;
    
    if (_isFavoriteMode) {
		self.tableView.tableHeaderView = nil;
        self.tableView.frame = self.view.bounds;
        [_tableView reloadData];
        
        self.tabBarController.navigationItem.rightBarButtonItem = self.editButtonItem;
    }
    else {
		self.tableView.tableHeaderView = self.searchController.searchBar;

        if (IS_RETINA) {
            self.tableView.frame = CGRectMake(0, kSearchBarHeight+3.5, self.view.bounds.size.width, self.view.bounds.size.height -kSearchBarHeight-3.5);
        }
        else {
            self.tableView.frame = CGRectMake(0, kSearchBarHeight+3.0, self.view.bounds.size.width, self.view.bounds.size.height -kSearchBarHeight-3.0);
        }
        [_tableView reloadData];
        
        self.tabBarController.navigationItem.rightBarButtonItem = nil;
    }
}

- (void) setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
    if (_isFavoriteMode) {
        [self.tableView reloadData];
    }
    
    [self.tableView setEditing:editing animated:animated];
    
    if (editing) {
        self.tabBarController.navigationItem.leftBarButtonItem = self.plusItem;
    }
    else {
        if ((!_shouldPopViewController && IS_IPHONE) || IS_IPAD) {
            self.tabBarController.navigationItem.leftBarButtonItem = self.cancelItem;
        }
        else {
            self.tabBarController.navigationItem.leftBarButtonItem = nil;
        }
    }
    
    // edit를 마쳤을때, 바뀐게 있으면 이전 뷰컨트롤러에 반영한다.
    if (!editing && isEdited) {
        [self updateEditedDataToDelegate];
    }
}

- (A3UnitConverterTVActionCell *)reusableActionCellForTableView:(UITableView *)tableView {
	A3UnitConverterTVActionCell *cell;
	cell = [tableView dequeueReusableCellWithIdentifier:A3UnitPriceActionCellID2];
	if (nil == cell) {
		cell = [[A3UnitConverterTVActionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:A3UnitPriceActionCellID2];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	return cell;
}

- (void)configureNoneCell:(UITableViewCell *)cell {
	cell.textLabel.text = NSLocalizedString(@"None", @"None");
    if (_currentUnitID == NSNotFound) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.textLabel.font = [UIFont boldSystemFontOfSize:17];
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.font = [UIFont systemFontOfSize:17];
    }
}

- (void)callDelegate:(NSUInteger)selectedUnitID {
	if ([_delegate respondsToSelector:@selector(selectViewController:didSelectCategoryID:unitID:)]) {
		[_delegate selectViewController:self didSelectCategoryID:_categoryID unitID:selectedUnitID];
	}
    
    if (IS_IPHONE) {
        if (_shouldPopViewController) {
            [self.tabBarController.navigationController popViewControllerAnimated:YES];
        } else {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
    else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)cancelButtonAction:(id)button {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)plusButtonAction:(id)sender
{
    [self addUnitAction];
}

- (void)doneButtonAction:(id)button {
	if (self.presentedViewController) {
		[self.presentedViewController dismissViewControllerAnimated:YES completion:NULL];
	}
	else {
		[[[A3AppDelegate instance] rootViewController_iPad] dismissRightSideViewController];
	}
}

- (void)addUnitAction {
	A3UnitPriceAddViewController *viewController = [self unitAddViewController];

	viewController.shouldPopViewController = NO;
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:viewController];
	nav.modalPresentationStyle= UIModalPresentationCurrentContext;
	[self.tabBarController.navigationController presentViewController:nav animated:YES completion:NULL];
}

- (A3UnitPriceAddViewController *)unitAddViewController {
    A3UnitPriceAddViewController *viewController = [[A3UnitPriceAddViewController alloc] initWithNibName:nil bundle:nil];
    viewController.delegate = self;
    viewController.shouldPopViewController = YES;
	viewController.dataManager = _dataManager;
	viewController.categoryID = _categoryID;

    return viewController;
}

- (void)filterContentForSearchText:(NSString*)searchText
{
	NSString *query = searchText;
	if (query && query.length) {
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name contains[cd] %@", query];
		_filteredResults = [self.allData filteredArrayUsingPredicate:predicate];
	} else {
		_filteredResults = nil;
	}
	[self.searchResultTableViewController.tableView reloadData];
}

- (void)updateEditedDataToDelegate
{
    if (_editingDelegate && [_editingDelegate respondsToSelector:@selector(favoritesEdited)]) {
        [_editingDelegate favoritesEdited];
        isEdited = NO;
    }
}

#pragma mark - A3UnitPriceAddViewControllerDelegate

- (void)addViewControllerDidUpdateData {
	_favorites = nil;
    [self updateEditedDataToDelegate];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_isFavoriteMode) {
        return self.favorites.count;
    } else {
        if (_filteredResults) {
            return [_filteredResults count];
        } else {
            return self.allData.count;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
	UITableViewCell *toCell=nil;

	if (!_isFavoriteMode && !_filteredResults && ([self.allData objectAtIndex:indexPath.row] == self.noneItem)) {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[A3StandardTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		}
		[self configureNoneCell:cell];
		toCell = cell;
	} else {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[A3StandardTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
			cell.textLabel.font = [UIFont systemFontOfSize:17];
		}

		// Configure the cell...
		BOOL checkedItem = NO;
		NSUInteger unitID;
		NSString *unitName;
		if (_filteredResults) {
			unitID = [self.filteredResults[indexPath.row][ID_KEY] unsignedIntegerValue];
			unitName = self.filteredResults[indexPath.row][NAME_KEY];
			cell.textLabel.text = unitName;
		}
		else {
			if (_isFavoriteMode) {
				unitID = [_favorites[indexPath.row] unsignedIntegerValue];
				unitName = [_dataManager unitNameForUnitID:unitID categoryID:_categoryID];
				cell.textLabel.text = NSLocalizedStringFromTable(unitName, @"unit", nil);
			}
			else {
				unitID = [_allData[indexPath.row][ID_KEY] unsignedIntegerValue];
				unitName = _allData[indexPath.row][NAME_KEY];
				cell.textLabel.text = unitName;
			}
		}

		if (_currentUnitID == unitID) {
			checkedItem = YES;
			cell.textLabel.font = [UIFont boldSystemFontOfSize:17];
		}
        else {
			cell.textLabel.font = [UIFont systemFontOfSize:17];
        }

		if (checkedItem) {
			cell.accessoryType = UITableViewCellAccessoryCheckmark;
		}
		else {
			cell.accessoryType = UITableViewCellAccessoryNone;
		}

		toCell = cell;
	}

    toCell.separatorInset = A3UITableViewSeparatorInset;
    
    return toCell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return _isFavoriteMode;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        isEdited = YES;
        
        [_favorites removeObjectAtIndex:indexPath.row];
		[_dataManager saveUnitPriceFavorites:_favorites categoryID:_categoryID];

        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    isEdited = YES;
    
    NSNumber *favorite = _favorites[fromIndexPath.row];
    [_favorites removeObjectAtIndex:fromIndexPath.row];
    [_favorites insertObject:favorite atIndex:toIndexPath.row];

	[_dataManager saveUnitPriceFavorites:_favorites categoryID:_categoryID];
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}

/*
 #pragma mark - Navigation
 
 // In a story board-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (!_isFavoriteMode && !_filteredResults && ([self.allData objectAtIndex:indexPath.row] == self.noneItem)) {
		[self callDelegate:NSNotFound];
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
	}
	else {
		NSUInteger selectedUnitID = NSNotFound;
		if (_filteredResults) {
			selectedUnitID = [self.filteredResults[indexPath.row][ID_KEY] unsignedIntegerValue];
			/* TODO: Delete after test, if it is not required.
			self.searchController.active = YES;
			 */
		} else {
			if (_isFavoriteMode) {
				selectedUnitID = [_favorites[indexPath.row] unsignedIntegerValue];
			}
			else {
				selectedUnitID = [_allData[indexPath.row][ID_KEY] unsignedIntegerValue];
			}
		}

		if (_currentUnitID == selectedUnitID) {
			[tableView deselectRowAtIndexPath:indexPath animated:YES];

			// 원래 아이템을 선택하였으므로 아무일 없이 돌아간다.
			if (IS_IPHONE) {
				if (_shouldPopViewController) {
					[self.navigationController popViewControllerAnimated:YES];
				} else {
					[self dismissViewControllerAnimated:YES completion:nil];
				}
			} else {
				[[[A3AppDelegate instance] rootViewController_iPad] dismissRightSideViewController];
			}

			return;
		}

		[self callDelegate:selectedUnitID];
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
	}
}

#pragma mark - SearchBarDelegate

/*
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
	_searchBar.text = @"";
}
 */

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
	[self filterContentForSearchText:searchText];
}

// called when cancel button pressed
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
}

// called when Search (in our case "Done") button pressed
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	[searchBar resignFirstResponder];
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    [self filterContentForSearchText:searchController.searchBar.text];
}

#pragma mark - UISearchControllerDelegate

- (void)willPresentSearchController:(UISearchController *)searchController {
    [self.tabBarController.navigationController setNavigationBarHidden:YES animated:YES];
    [self.tabBarController.tabBar setHidden:YES];
}

- (void)didPresentSearchController:(UISearchController *)searchController {
}

- (void)willDismissSearchController:(UISearchController *)searchController {
    [self.tabBarController.navigationController setNavigationBarHidden:NO animated:YES];
    [self.tabBarController.tabBar setHidden:NO];
}

- (void)didDismissSearchController:(UISearchController *)searchController {

}

- (void)presentSearchController:(UISearchController *)searchController {

}

@end
