//
//  A3UnitPriceSelectViewController.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 3..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3UnitPriceSelectViewController.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+A3AppCategory.h"
#import "UnitPriceFavorite.h"
#import "NSString+conversion.h"
#import "UnitType.h"
#import "UnitItem.h"
#import "A3UnitConverterTVActionCell.h"
#import "A3UnitPriceAddViewController.h"
#import "UIColor+A3Addition.h"

#define kCellHeight 56

@interface A3UnitPriceSelectViewController () <UISearchDisplayDelegate, A3UnitPriceAddViewControllerDelegate>
{
    BOOL isEdited;
}

@property (nonatomic, strong) UISegmentedControl *selectSegment;
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
    
	self.tableView = [UITableView new];
	_tableView.frame = self.view.bounds;
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	_tableView.showsVerticalScrollIndicator = NO;
    _tableView.separatorColor = [self tableViewSeparatorColor];
    _tableView.rowHeight = 44.0;
	[self.view addSubview:_tableView];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"A3UnitConverterTVActionCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:A3UnitPriceActionCellID2];
    
	[self.view addSubview:self.searchBar];
	[self mySearchDisplayController];
    
    if (!_shouldPopViewController && IS_IPHONE) {
        self.tabBarController.navigationItem.leftBarButtonItem = self.cancelItem;
    }
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    
	if ([_placeHolder length]) {
		self.searchBar.text = _placeHolder;
		[self filterContentForSearchText:_placeHolder];
	}
    
    UISegmentedControl *segment = (UISegmentedControl *)self.navigationController.tabBarController.navigationItem.titleView;
    self.isFavoriteMode = segment.selectedSegmentIndex==1 ? YES:NO;
    
//    if (self.editing) {
//        [self setEditing:NO animated:YES];
//    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (isEdited) {
        // 보고
        [self updateEditedDataToDelegate];
    }
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
        _cancelItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonAction:)];
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

- (void)setIsFavoriteMode:(BOOL)isFavoriteMode
{
    _isFavoriteMode = isFavoriteMode;
    
    if (_isFavoriteMode) {
        self.searchBar.hidden = YES;
        self.tableView.frame = self.view.bounds;
        [_tableView reloadData];
        
        self.tabBarController.navigationItem.rightBarButtonItem = self.editButtonItem;
    }
    else {
        self.searchBar.hidden = NO;
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
        if (!_shouldPopViewController && IS_IPHONE) {
            self.tabBarController.navigationItem.leftBarButtonItem = self.cancelItem;
        }
        else {
            self.tabBarController.navigationItem.leftBarButtonItem = nil;
//            self.tabBarController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
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
    //	actionCell.centerButton.titleLabel.font = [UIFont fontWithName:@"FontAwesome" size:25.0];
    //	[actionCell.centerButton setTitleColor:nil forState:UIControlStateNormal];
	cell.textLabel.text = @"None";
    if (!_selectedUnit) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.textLabel.textColor = [UIColor colorWithRGBRed:201 green:201 blue:201 alpha:255];
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.textColor = [UIColor blackColor];
    }
}

- (void)callDelegate:(UnitItem *)selectedItem {
	if ([_delegate respondsToSelector:@selector(selectViewController:unitSelectedWithItem:)]) {
        [_delegate selectViewController:self unitSelectedWithItem:selectedItem];
	}
    
    if (IS_IPHONE) {
        if (_shouldPopViewController) {
            [self.tabBarController.navigationController popViewControllerAnimated:YES];
        } else {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
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

- (void)doneButtonAction:(id)button {
	if (self.presentedViewController) {
		[self.presentedViewController dismissViewControllerAnimated:YES completion:NULL];
	}
	else {
		[self.A3RootViewController dismissRightSideViewController];
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
    
    NSArray *items = [UnitItem MR_findByAttribute:@"type" withValue:self.unitType andOrderBy:@"unitName" ascending:YES];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.unitName!=%@", @"feet inches"];
    viewController.allData = [NSMutableArray arrayWithArray:[items filteredArrayUsingPredicate:predicate]];
    
    return viewController;
}

- (void)filterContentForSearchText:(NSString*)searchText
{
	NSString *query = searchText;
	if (query && query.length) {
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"unitName contains[cd] %@", query];
		_filteredResults = [self.allData filteredArrayUsingPredicate:predicate];
	} else {
		_filteredResults = nil;
	}
	[self.tableView reloadData];
}

- (void)resetOrdering
{
    // reset ordering
    for (int i=0; i<_favorites.count; i++) {
        id object = _favorites[i];
        
        if ([ object isKindOfClass:[UnitPriceFavorite class] ]) {
            ((UnitPriceFavorite *)object).order = [NSString orderStringWithOrder:(i + 1) * 1000000];
		}
    }
}

- (void)updateEditedDataToDelegate
{
    if (_editingDelegate && [_editingDelegate respondsToSelector:@selector(favoritesEdited)]) {
        [_editingDelegate favoritesEdited];
        isEdited = NO;
    }
}

#pragma mark - A3UnitPriceAddViewControllerDelegate

- (void)addViewController:(UIViewController *)viewController itemsAdded:(NSArray *)addedItems itemsRemoved:(NSArray *)removedItems
{
    FNLOG(@"Added\n%@", [addedItems description]);
    FNLOG(@"Removed\n%@", [removedItems description]);
    
    // 삭제하기
    NSMutableArray *removedIndexPaths = [[NSMutableArray alloc] init];
//    [self.tableView beginUpdates];
    for (int i=0; i<removedItems.count; i++) {
        UnitItem *item = removedItems[i];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"item == %@", item];
        NSArray *filtered = [_favorites filteredArrayUsingPredicate:predicate];
        
        if (filtered.count > 0) {
            UnitPriceFavorite *favor = filtered[0];
            NSUInteger itemIdx = [_favorites indexOfObject:favor];
            [favor MR_deleteEntity];
            [_favorites removeObject:favor];
            
            [removedIndexPaths addObject:[NSIndexPath indexPathForRow:itemIdx inSection:0]];
        }
    }
//    [self.tableView deleteRowsAtIndexPaths:removedIndexPaths withRowAnimation:UITableViewRowAnimationLeft];
//    [self.tableView endUpdates];
    
    // 추가하기
//    [self.tableView beginUpdates];
    NSMutableArray *addIndexPaths = [[NSMutableArray alloc] init];
    for (int i=0; i<addedItems.count; i++) {
        NSUInteger lastIdx = [_favorites count];
        
        UnitItem *item = addedItems[i];
        UnitPriceFavorite *favorite = [UnitPriceFavorite MR_createEntity];
        favorite.item = item;
        [_favorites insertObject:favorite atIndex:lastIdx];
        
        NSIndexPath *ip = [NSIndexPath indexPathForRow:lastIdx inSection:0];
        [addIndexPaths addObject:ip];
    }
//    [self.tableView insertRowsAtIndexPaths:addIndexPaths withRowAnimation:UITableViewRowAnimationRight];
//    [self.tableView endUpdates];
    
    [self resetOrdering];
    
	[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];

    [self updateEditedDataToDelegate];
}

- (void)willDismissAddViewController
{
    
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
        if (_isFavoriteMode) {
            return _favorites.count;
        }
        else {
            return _allData.count;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
	UITableViewCell *toCell=nil;

	if (!_isFavoriteMode && (tableView != self.searchDisplayController.searchResultsTableView) && ([self.allData objectAtIndex:indexPath.row] == self.noneItem)) {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
			cell.textLabel.font = [UIFont systemFontOfSize:17];
		}
		[self configureNoneCell:cell];
		toCell = cell;
	}
	else {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
			cell.textLabel.font = [UIFont systemFontOfSize:17];
		}

		// Configure the cell...
		BOOL checkedItem = NO;
		UnitItem *data;
		if (tableView == self.searchDisplayController.searchResultsTableView) {
			data = self.filteredResults[indexPath.row];
		}
		else {
			if (_isFavoriteMode) {
				UnitPriceFavorite *favorite = _favorites[indexPath.row];
				data = favorite.item;
			}
			else {
				data = _allData[indexPath.row];
			}
		}

		cell.textLabel.text = data.unitName;

		if (_selectedUnit && ([[data objectID] isEqual:[_selectedUnit objectID]])) {
			checkedItem = YES;
		}

		if (checkedItem) {
			cell.accessoryType = UITableViewCellAccessoryCheckmark;
			cell.textLabel.textColor = [UIColor colorWithRed:201.0/255.0 green:201.0/255.0 blue:201.0/255.0 alpha:1.0];
		}
		else {
			cell.accessoryType = UITableViewCellAccessoryNone;
			cell.textLabel.textColor = [UIColor blackColor];
		}

		toCell = cell;
	}

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
    
    /*
    UnitPriceFavorite *favorite = _favorites[indexPath.row];
    if ([favorite.item.unitName isEqualToString:_selectedFavorite.item.unitName]) {
        return UITableViewCellEditingStyleNone;
    }
    else {
        return UITableViewCellEditingStyleDelete;
    }
     */
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        isEdited = YES;
        
        UnitPriceFavorite *favorite = _favorites[indexPath.row];
        
        [_favorites removeObjectAtIndex:indexPath.row];
        [self resetOrdering];
        
        [favorite MR_deleteEntity];
		[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];

        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    isEdited = YES;
    
    UnitPriceFavorite *favorite = _favorites[fromIndexPath.row];
    [_favorites removeObjectAtIndex:fromIndexPath.row];
    [_favorites insertObject:favorite atIndex:toIndexPath.row];
    
    [self resetOrdering];

	[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
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
	if (!_isFavoriteMode && (tableView != self.searchDisplayController.searchResultsTableView) && ([self.allData objectAtIndex:indexPath.row] == self.noneItem)) {
		[self callDelegate:nil];
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
	}
	else {
		UnitItem *data;
		if (tableView == self.searchDisplayController.searchResultsTableView) {
			data = self.filteredResults[indexPath.row];
			[self.searchDisplayController setActive:NO animated:NO];

		} else {
			if (_isFavoriteMode) {

				if ([_favorites[indexPath.row] isKindOfClass:[UnitPriceFavorite class]]) {
					UnitPriceFavorite *favorite = _favorites[indexPath.row];
					data = favorite.item;
				}
				else {
					[tableView deselectRowAtIndexPath:indexPath animated:YES];
					return;
				}
			}
			else {
				data = _allData[indexPath.row];
			}
		}

		if (_selectedUnit && ([[data objectID] isEqual:[_selectedUnit objectID]])) {
			[tableView deselectRowAtIndexPath:indexPath animated:YES];

			// 원래 아이템을 선택하였으므로 아무일 없이 돌아간다.
			if (IS_IPHONE) {
				if (_shouldPopViewController) {
					[self.navigationController popViewControllerAnimated:YES];
				} else {
					[self dismissViewControllerAnimated:YES completion:nil];
				}
			} else {
				[self.A3RootViewController dismissRightSideViewController];
			}

			return;
		}

		[self callDelegate:data];
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
	}
}

#pragma mark- UISearchDisplayControllerDelegate

- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView {
	[self.tableView setHidden:YES];
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willHideSearchResultsTableView:(UITableView *)tableView {
	[self.tableView setHidden:NO];
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didShowSearchResultsTableView:(UITableView *)tableView {
    
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView {
    
}

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
    [self.tabBarController.navigationController setNavigationBarHidden:YES animated:YES];
    self.tabBarController.tabBar.hidden = YES;

	CGRect frame = _searchBar.frame;
	frame.origin.y = 20.0;
	_searchBar.frame = frame;
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
    [self.tabBarController.navigationController setNavigationBarHidden:NO animated:YES];
    self.tabBarController.tabBar.hidden = NO;

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
}

// called when cancel button pressed
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
}

// called when Search (in our case "Done") button pressed
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	[searchBar resignFirstResponder];
}

@end
