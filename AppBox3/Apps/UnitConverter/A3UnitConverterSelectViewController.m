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

@interface A3UnitConverterSelectViewController () <UISearchDisplayDelegate, A3UnitConverterAddViewControllerDelegate>
{
    BOOL isFavoriteMode;
    BOOL isEdited;
}

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UISegmentedControl *selectSegment;
@property (nonatomic, strong) UIBarButtonItem *cancelItem;
@property (nonatomic, strong) UIBarButtonItem *plusBarButtonItem;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UISearchDisplayController *mySearchDisplayController;
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
	_tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	_tableView.showsVerticalScrollIndicator = NO;

    _tableView.separatorColor = [self tableViewSeparatorColor];
	[self.view addSubview:_tableView];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"A3UnitConverterTVActionCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:A3UnitConverterActionCellID2];
    
    self.navigationItem.titleView = self.selectSegment;
    [self selectSegmentChanged:self.selectSegment];
	[self.view addSubview:self.searchBar];
	[self mySearchDisplayController];
    
    if ((!_isModal && IS_IPHONE) || IS_IPAD) {
        self.navigationItem.leftBarButtonItem = self.cancelItem;
    }
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cloudStoreDidImport) name:A3NotificationCloudKeyValueStoreDidImport object:nil];
    
#ifdef __IPHONE_8_0
    if ([self.tableView respondsToSelector:@selector(layoutMargins)])
    {
        self.tableView.layoutMargins = UIEdgeInsetsZero;
    }
#endif
    self.tableView.separatorInset = A3UITableViewSeparatorInset;
}

- (void)cloudStoreDidImport {
	_favorites = nil;
	_convertItems = nil;

	[self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    
	if ([_placeHolder length]) {
		self.searchBar.text = _placeHolder;
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
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationCloudKeyValueStoreDidImport object:nil];
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
        self.tableView.layoutMargins = UIEdgeInsetsZero;
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

- (UISearchDisplayController *)mySearchDisplayController {
	if (!_mySearchDisplayController) {
		_mySearchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
		_mySearchDisplayController.delegate = self;
		_mySearchDisplayController.searchBar.delegate = self;
		_mySearchDisplayController.searchResultsTableView.delegate = self;
		_mySearchDisplayController.searchResultsTableView.dataSource = self;
		_mySearchDisplayController.searchResultsTableView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];
		_mySearchDisplayController.searchResultsTableView.showsVerticalScrollIndicator = NO;
        
	}
	return _mySearchDisplayController;
}

- (UISearchBar *)searchBar {
	if (!_searchBar) {
        
        float startY = IS_RETINA ? 63.5 : 63.0;
		_searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0, startY, self.view.bounds.size.width, kSearchBarHeight)];
		_searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		_searchBar.backgroundColor = self.navigationController.navigationBar.backgroundColor;
		_searchBar.delegate = self;
	}
	return _searchBar;
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
            self.searchBar.hidden = NO;
            isFavoriteMode = NO;
            
            float heightGap = IS_RETINA ? kSearchBarHeight+3.5:kSearchBarHeight+3.0;
            _tableView.frame = CGRectMake(0, heightGap, self.view.bounds.size.width, self.view.bounds.size.height-heightGap);
            
            [_tableView reloadData];
            
            self.navigationItem.rightBarButtonItem = nil;
            if (self.editing) {
                [self setEditing:NO animated:YES];
            }
            
            break;
        }
        case 1:
        {
            self.searchBar.hidden = YES;
            isFavoriteMode = YES;
            
            _tableView.frame = self.view.bounds;
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
		[self.A3RootViewController dismissRightSideViewController];
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
	[self.tableView reloadData];
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
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
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
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		cell.textLabel.font = [UIFont systemFontOfSize:17.0];
	}

	// Configure the cell...
	BOOL checkedItem = NO;
	NSUInteger unitID;
	NSString *unitName;
	if (tableView == self.searchDisplayController.searchResultsTableView) {
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
	}

	if (checkedItem) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
		cell.textLabel.textColor = [UIColor colorWithRed:201.0/255.0 green:201.0/255.0 blue:201.0/255.0 alpha:1.0];
		FNLOG(@"%@", cell.textLabel.text);
	}
	else {
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.textLabel.textColor = [UIColor blackColor];
	}

	if ([self.convertItems containsObject:@(unitID)]) {
		cell.textLabel.textColor = [UIColor colorWithRed:201.0/255.0 green:201.0/255.0 blue:201.0/255.0 alpha:1.0];
		FNLOG(@"%@", cell.textLabel.text);
	}
	FNLOG(@"%@", cell.textLabel.text);

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
	if (tableView == self.searchDisplayController.searchResultsTableView) {
		selectedUnitID = [self.filteredResults[indexPath.row][ID_KEY] unsignedIntegerValue];
	} else {
		if (isFavoriteMode) {
			selectedUnitID = [self.favorites[indexPath.row] unsignedIntegerValue];
		}
		else {
			selectedUnitID = [self.allData[indexPath.row][ID_KEY] unsignedIntegerValue];
		}
	}

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

#pragma mark- UISearchDisplayControllerDelegate

- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView {
    
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willHideSearchResultsTableView:(UITableView *)tableView {

}

- (void)searchDisplayController:(UISearchDisplayController *)controller didShowSearchResultsTableView:(UITableView *)tableView {
    
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView {
    
}

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
	CGRect frame = _searchBar.frame;
	frame.origin.y = 20.0;
	_searchBar.frame = frame;
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
	CGRect frame = _searchBar.frame;
	frame.origin.y = 64.0;
	_searchBar.frame = frame;
}

#pragma mark - SearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
	_searchBar.text = @"";
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
