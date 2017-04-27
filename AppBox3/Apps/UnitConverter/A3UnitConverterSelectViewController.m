//
//  A3UnitConverterSelectViewController.m
//  A3TeamWork
//
//  Created by kihyunkim on 13. 10. 20..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3UnitConverterSelectViewController.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+NumberKeyboard.h"
#import "A3UnitConverterAddViewController.h"
#import "UIViewController+iPad_rightSideView.h"
#import "UIViewController+tableViewStandardDimension.h"
#import "A3UnitDataManager.h"
#import "A3UIDevice.h"
#import "A3StandardTableViewCell.h"
#import "A3UserDefaultsKeys.h"

@interface A3UnitConverterSelectViewController () <UISearchControllerDelegate,
		A3UnitConverterAddViewControllerDelegate, UISearchResultsUpdating>
{
    BOOL isFavoriteMode;
    BOOL isEdited;
}

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UISegmentedControl *selectSegment;
@property (nonatomic, strong) UIBarButtonItem *cancelItem;
@property (nonatomic, strong) UIBarButtonItem *plusBarButtonItem;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) UITableViewController *searchResultsTableViewController;
@property (nonatomic, strong) NSArray *filteredResults;
@property (nonatomic, strong) NSMutableArray *sectionsArray;
@property (nonatomic, strong) NSMutableArray *allData;
@property (nonatomic, strong) NSMutableArray *favorites;
@property (nonatomic, strong) NSMutableArray *convertItems;

@end

@implementation A3UnitConverterSelectViewController

NSString *const A3UnitConverterActionCellID2 = @"A3UnitConverterActionCell";
NSString *const A3UnitConverterSegmentIndex = @"A3UnitConverterSegmentIndex";

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    
	self.tableView = [UITableView new];
	_tableView.frame = self.view.bounds;
	_tableView.delegate = self;
	_tableView.dataSource = self;
    _tableView.rowHeight = 44.0;
	_tableView.showsVerticalScrollIndicator = NO;

	_tableView.separatorColor = A3UITableViewSeparatorColor;
	_tableView.separatorInset = A3UITableViewSeparatorInset;
	
	if ([_tableView respondsToSelector:@selector(cellLayoutMarginsFollowReadableWidth)]) {
		_tableView.cellLayoutMarginsFollowReadableWidth = NO;
	}
	if ([_tableView respondsToSelector:@selector(layoutMargins)]) {
		FNLOGINSETS(_tableView.layoutMargins);
		_tableView.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0);
	}
	[self.view addSubview:_tableView];
	[_tableView makeConstraints:^(MASConstraintMaker *make) {
		make.edges.equalTo(self.view);
	}];

    [self.tableView registerNib:[UINib nibWithNibName:@"A3UnitConverterTVActionCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:A3UnitConverterActionCellID2];
    
    self.navigationItem.titleView = self.selectSegment;
    [self selectSegmentChanged:self.selectSegment];

    if ((!_isModal && IS_IPHONE) || IS_IPAD) {
        self.navigationItem.leftBarButtonItem = self.cancelItem;
    }
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cloudStoreDidImport) name:A3NotificationCloudKeyValueStoreDidImport object:nil];
    
	if ([self.tableView respondsToSelector:@selector(layoutMargins)])
	{
		UIEdgeInsets layoutMargins = self.tableView.layoutMargins;
		layoutMargins.left = 0;
		self.tableView.layoutMargins = layoutMargins;
	}

    _tableView.separatorInset = A3UITableViewSeparatorInset;
	if ([self.tableView respondsToSelector:@selector(cellLayoutMarginsFollowReadableWidth)]) {
		self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
	}
}

- (void)applicationDidEnterBackground {
	if ([[A3AppDelegate instance] shouldProtectScreen]) {
		[self.searchController.searchBar resignFirstResponder];
	}
}

- (void)cloudStoreDidImport {
	_favorites = nil;
	_convertItems = nil;

	[self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    
	if ([_placeHolder length]) {
		self.searchController.searchBar.text = _placeHolder;
		[self filterContentForSearchText:_placeHolder];
	}
    
    if (isFavoriteMode == NO) {
        float heightGap = IS_RETINA ? kSearchBarHeight+3.5:kSearchBarHeight+3.0;
        _tableView.frame = CGRectMake(0, heightGap, self.view.bounds.size.width, self.view.bounds.size.height-heightGap);
    }
    else {
        _tableView.frame = self.view.bounds;
    }
}

- (void)removeObserver {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationCloudKeyValueStoreDidImport object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	if ([self.navigationController.navigationBar isHidden]) {
		[self.navigationController setNavigationBarHidden:NO animated:NO];
	}
}

-(void)viewWillDisappear:(BOOL)animated
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

- (void)dealloc {
	[self removeObserver];
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
	[super didMoveToParentViewController:parent];

	if (!parent) {
		[[NSNotificationCenter defaultCenter] postNotificationName:A3NotificationChildViewControllerDidDismiss object:self];
	}
}

- (BOOL)resignFirstResponder {
	[_searchController.searchBar resignFirstResponder];
	return [super resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIBarButtonItem *)cancelItem
{
    if (!_cancelItem) {
        _cancelItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", @"Done")
													   style:UIBarButtonItemStylePlain
													  target:self
													  action:@selector(cancelButtonAction:)];
    }
    
    return _cancelItem;
}

- (UIBarButtonItem *)plusBarButtonItem
{
    if (!_plusBarButtonItem) {
        _plusBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"add03"] style:UIBarButtonItemStylePlain target:self action:@selector(plusButtonAction:)];
    }
    
    return _plusBarButtonItem;
}

- (UITableViewController *)searchResultsTableViewController {
	if (!_searchResultsTableViewController) {
		_searchResultsTableViewController = [UITableViewController new];
		UITableView *tableView = _searchResultsTableViewController.tableView;
		tableView.delegate = self;
		tableView.dataSource = self;
		tableView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];
		tableView.showsVerticalScrollIndicator = NO;
		if ([tableView respondsToSelector:@selector(cellLayoutMarginsFollowReadableWidth)]) {
			tableView.cellLayoutMarginsFollowReadableWidth = NO;
		}
		if ([tableView respondsToSelector:@selector(layoutMargins)]) {
			tableView.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0);
		}
	}
	return _searchResultsTableViewController;
}

- (UISearchController *)searchController {
	if (!_searchController) {
		_searchController = [[UISearchController alloc] initWithSearchResultsController:self.searchResultsTableViewController];
		_searchController.delegate = self;
		_searchController.searchResultsUpdater = self;
		_searchController.searchBar.delegate = self;
		[_searchController.searchBar sizeToFit];
	}
	return _searchController;
}

- (UISegmentedControl *)selectSegment
{
    UISegmentedControl *segment = [[UISegmentedControl alloc] initWithItems:@[NSLocalizedString(@"All Units", @"All Units"), NSLocalizedString(@"Favorites", @"Favorites")]];
    
    [segment setWidth:IS_IPAD? 150 : 85 forSegmentAtIndex:0];
    [segment setWidth:IS_IPAD? 150 : 85 forSegmentAtIndex:1];

    UIFont *font = [UIFont systemFontOfSize:13.0];
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:font
                                                           forKey:NSFontAttributeName];
    NSNumber *selectedSegmentIndex = [[NSUserDefaults standardUserDefaults] objectForKey:A3UnitConverterSegmentIndex];
    [segment setTitleTextAttributes:attributes forState:UIControlStateNormal];
    segment.selectedSegmentIndex = !selectedSegmentIndex ? 1 : [selectedSegmentIndex integerValue];
    isFavoriteMode = NO;
    [segment addTarget:self action:@selector(selectSegmentChanged:) forControlEvents:UIControlEventValueChanged];
    
    return segment;
}

- (void)selectSegmentChanged:(UISegmentedControl*) segment
{
    switch (segment.selectedSegmentIndex) {
        case 0:
        {
            isFavoriteMode = NO;
            
            self.tableView.tableHeaderView = self.searchController.searchBar;
            [_tableView reloadData];
            
            self.navigationItem.rightBarButtonItem = nil;
            if (self.editing) {
                [self setEditing:NO animated:YES];
            }
            
            break;
        }
        case 1:
        {
            isFavoriteMode = YES;

            self.tableView.tableHeaderView = nil;
            [_tableView reloadData];
            
            self.navigationItem.rightBarButtonItem = self.editButtonItem;
            
            break;
        }
        default:
            break;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:@(segment.selectedSegmentIndex) forKey:A3UnitConverterSegmentIndex];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];

    if (isFavoriteMode) {
        [self.tableView reloadData];
    }
    
    [self.tableView setEditing:editing animated:animated];
    
    if (editing) {
        self.navigationItem.leftBarButtonItem = self.plusBarButtonItem;
    }
    else {
        if ((!_isModal && IS_IPHONE) || IS_IPAD) {
            self.navigationItem.leftBarButtonItem = self.cancelItem;
        }
        else {
            self.navigationItem.leftBarButtonItem = nil;
        }
    }
    
    // edit를 마쳤을때, 바뀐게 있으면 이전 뷰컨트롤러에 반영한다.
    if (!editing && isEdited) {
        [self updateEditedDataToDelegate];
    }
}

- (void)callDelegate:(NSUInteger)selectedUnitID {
	if ([_delegate respondsToSelector:@selector(selectViewController:didSelectCategoryID:unitID:)]) {
		[_delegate selectViewController:self didSelectCategoryID:_categoryID unitID:selectedUnitID];
	}
	if (IS_IPHONE) {
		if (_isModal) {
			[self.navigationController popViewControllerAnimated:YES];
		} else {
			[self dismissViewControllerAnimated:YES completion:nil];
		}
	} else {
        [self dismissViewControllerAnimated:YES completion:nil];
	}
}

- (void)doneButtonAction:(id)button {
	if (_delegate && [_delegate respondsToSelector:@selector(didCancelUnitSelect)]) {
		[_delegate didCancelUnitSelect];
	}

	if (self.presentedViewController) {
		[self.presentedViewController dismissViewControllerAnimated:YES completion:NULL];
	}
	else {
		[[[A3AppDelegate instance] rootViewController_iPad] dismissRightSideViewController];
	}
}

- (void)cancelButtonAction:(id)button {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)plusButtonAction:(id)sender
{
    [self addUnitAction];
}

- (void)addUnitAction {
	A3UnitConverterAddViewController *viewController = [self unitAddViewController];

	viewController.shouldPopViewController = NO;
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:viewController];
	nav.modalPresentationStyle= UIModalPresentationCurrentContext;
	[self presentViewController:nav animated:YES completion:NULL];
}

- (A3UnitConverterAddViewController *)unitAddViewController {
    A3UnitConverterAddViewController *viewController = [[A3UnitConverterAddViewController alloc] initWithNibName:nil bundle:nil];
	viewController.dataManager = _dataManager;
    viewController.delegate = self;
	viewController.categoryID = _categoryID;
    
    viewController.allData = [_dataManager allUnitsSortedByLocalizedNameForCategoryID:_categoryID];
    
    return viewController;
}

- (void)filterContentForSearchText:(NSString*)searchText
{
	NSString *query = searchText;
	if (query && query.length) {
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K contains[cd] %@", NAME_KEY, query];
		_filteredResults = [self.allData filteredArrayUsingPredicate:predicate];
	} else {
		_filteredResults = nil;
	}
	[self.searchResultsTableViewController.tableView reloadData];
}

- (void)updateEditedDataToDelegate
{
    if (_editingDelegate && [_editingDelegate respondsToSelector:@selector(favoritesEdited)]) {
        [_editingDelegate favoritesEdited];
        isEdited = NO;
    }
	_favorites = nil;
	[self.tableView reloadData];
}

#pragma mark - Data

- (NSMutableArray *)allData {
	if (!_allData) {
		_allData = [_dataManager allUnitsSortedByLocalizedNameForCategoryID:_categoryID];
	}
	return _allData;
}

- (NSMutableArray *)favorites {
	if (!_favorites) {
		_favorites = [NSMutableArray arrayWithArray:[_dataManager favoritesForCategoryID:_categoryID]];
	}
	return _favorites;
}

- (NSMutableArray *)convertItems {
	if (!_convertItems) {
		_convertItems = [NSMutableArray arrayWithArray:[_dataManager unitConvertItemsForCategoryID:_categoryID]];
	}
	return _convertItems;
}

#pragma mark - A3UnitConverterAddViewControllerDelegate

- (void)favoritesUpdatedInAddViewController {
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
    // Return the number of rows in the section.
    
    if (tableView == self.searchResultsTableViewController.tableView) {
		return [_filteredResults count];
	}
    else {
        if (isFavoriteMode) {
            return self.favorites.count;
        }
        else {
            return self.allData.count;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *toCell=nil;

	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[A3StandardTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		cell.textLabel.font = [UIFont systemFontOfSize:17.0];
	}

	// Configure the cell...
	BOOL checkedItem = NO;
	NSUInteger unitID;
	NSString *unitName;
	if (tableView == self.searchResultsTableViewController.tableView) {
		NSDictionary *data = self.filteredResults[indexPath.row];
		unitID = [data[ID_KEY] unsignedIntegerValue];
		unitName = data[NAME_KEY];
	}
	else {
		if (isFavoriteMode) {
			unitID = [_favorites[indexPath.row] unsignedIntegerValue];
			unitName = [_dataManager localizedUnitNameForUnitID:unitID categoryID:_categoryID];
		}
		else {
			NSDictionary *data = _allData[indexPath.row];
			unitID = [data[ID_KEY] unsignedIntegerValue];
			unitName = data[NAME_KEY];
		}
	}

	cell.textLabel.text = unitName;

	if (unitID == _currentUnitID) {
		checkedItem = YES;
        cell.textLabel.font = [UIFont boldSystemFontOfSize:17.0];
	}
    else {
        cell.textLabel.font = [UIFont systemFontOfSize:17.0];
    }
    
	if ([self.convertItems containsObject:@(unitID)]) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	}
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }


	toCell = cell;
    toCell.separatorInset = A3UITableViewSeparatorInset;
    
    return toCell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return isFavoriteMode;
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
		[_dataManager saveFavorites:_favorites categoryID:_categoryID];

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

	[_dataManager saveFavorites:_favorites categoryID:_categoryID];
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

	NSUInteger selectedUnitID;
	if (tableView == self.searchResultsTableViewController.tableView) {
		selectedUnitID = [self.filteredResults[indexPath.row][ID_KEY] unsignedIntegerValue];
	} else {
		if (isFavoriteMode) {
			selectedUnitID = [self.favorites[indexPath.row] unsignedIntegerValue];
		}
		else {
			selectedUnitID = [self.allData[indexPath.row][ID_KEY] unsignedIntegerValue];
		}
	}

    [self.searchController setActive:NO];
    
	if (selectedUnitID == _currentUnitID) {
		// 원래 아이템을 선택하였으므로 아무일 없이 돌아간다.
		if (IS_IPHONE) {
			if (_isModal) {
				[self.navigationController popViewControllerAnimated:YES];
			} else {
				[self dismissViewControllerAnimated:YES completion:nil];
			}
		} else {
            [self dismissViewControllerAnimated:YES completion:nil];
		}

		return;
	}

	[self callDelegate:selectedUnitID];
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
	[self filterContentForSearchText:searchController.searchBar.text];
}

#pragma mark - SearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
	_searchController.searchBar.text = @"";
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
	[self filterContentForSearchText:searchText];
    
    if (self.filteredResults.count > 0) {
        self.tableView.hidden = YES;
    }
    else {
        self.tableView.hidden = NO;
    }
}

// called when cancel button pressed
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    FNLOG(@"canceled");
    
    self.tableView.hidden = NO;
}

// called when Search (in our case "Done") button pressed
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	[searchBar resignFirstResponder];
}

@end
