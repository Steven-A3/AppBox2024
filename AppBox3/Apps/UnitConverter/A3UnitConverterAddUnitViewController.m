//
//  A3UnitConverterSelectViewController.m
//  A3TeamWork
//
//  Created by kihyunkim on 13. 10. 20..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3UnitConverterAddUnitViewController.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+A3AppCategory.h"
#import "UnitFavorite.h"
#import "NSString+conversion.h"
#import "UnitType.h"
#import "UnitItem.h"
#import "A3UnitConverterTVActionCell.h"
#import "A3UnitConverterAddViewController.h"


@interface A3UnitConverterAddUnitViewController () <UISearchDisplayDelegate, A3UnitConverterAddViewControllerDelegate>
{
    BOOL isFavoriteMode;
    BOOL isEdited;
}

@property (nonatomic, strong) UISegmentedControl *selectSegment;
@property (nonatomic, strong) NSMutableDictionary *plusItem;

@end

@implementation A3UnitConverterAddUnitViewController

NSString *const A3UnitConverterActionCellID3 = @"A3UnitConverterActionCell";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.favorites addObject:self.plusItem];
    
	self.tableView = [UITableView new];
	_tableView.frame = self.view.bounds;
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	_tableView.showsVerticalScrollIndicator = NO;
	_tableView.contentInset = UIEdgeInsetsMake(kSearchBarHeight + 4, 0, 0, 0);
	[self.view addSubview:_tableView];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"A3UnitConverterTVActionCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:A3UnitConverterActionCellID3];
    
    self.navigationItem.titleView = self.selectSegment;
	[self.view addSubview:self.searchBar];
	[self mySearchDisplayController];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    
	if ([_placeHolder length]) {
		self.searchBar.text = _placeHolder;
		[self filterContentForSearchText:_placeHolder];
	}
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

- (NSMutableDictionary *)plusItem {
	if (!_plusItem) {
		_plusItem = [NSMutableDictionary dictionaryWithDictionary:@{@"title":@"+", @"order":@""}];
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
		_searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0, 64.0, self.view.bounds.size.width, kSearchBarHeight)];
		_searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		_searchBar.backgroundColor = self.navigationController.navigationBar.backgroundColor;
		_searchBar.delegate = self;
	}
	return _searchBar;
}

- (UISegmentedControl *)selectSegment
{
    UISegmentedControl *segment = [[UISegmentedControl alloc] initWithItems:@[@"All Units", @"Favorites"]];
    
    segment.selectedSegmentIndex = 0;
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
            _tableView.contentInset = UIEdgeInsetsMake(kSearchBarHeight + 4 + 64, 0, 0, 0);
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
            _tableView.contentInset = UIEdgeInsetsMake(4 + 64, 0, 0, 0);
            [_tableView reloadData];
            
            self.navigationItem.rightBarButtonItem = self.editButtonItem;
            
            break;
        }
        default:
            break;
    }
}

- (void) setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
    if (editing) {
        [self.favorites removeObject:self.plusItem];
    }
    else {
        [self.favorites addObject:self.plusItem];
    }
    
    if (isFavoriteMode) {
        [self.tableView reloadData];
    }
    
    [self.tableView setEditing:editing animated:animated];
    
    // edit를 마쳤을때, 바뀐게 있으면 이전 뷰컨트롤러에 반영한다.
    if (!editing && isEdited) {
        [self updateEditedDataToDelegate];
    }
}

- (A3UnitConverterTVActionCell *)reusableActionCellForTableView:(UITableView *)tableView {
	A3UnitConverterTVActionCell *cell;
	cell = [tableView dequeueReusableCellWithIdentifier:A3UnitConverterActionCellID3];
	if (nil == cell) {
		cell = [[A3UnitConverterTVActionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:A3UnitConverterActionCellID3];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	return cell;
}

- (void)configurePlusCell:(A3UnitConverterTVActionCell *)actionCell {
    //	actionCell.centerButton.titleLabel.font = [UIFont fontWithName:@"FontAwesome" size:25.0];
    //	[actionCell.centerButton setTitleColor:nil forState:UIControlStateNormal];
	[actionCell.centerButton addTarget:self action:@selector(addUnitAction) forControlEvents:UIControlEventTouchUpInside];
}

- (void)callDelegate:(UnitItem *)selectedItem {
	if (IS_IPHONE) {
		[self dismissViewControllerAnimated:YES completion:nil];
	} else {
		[self.A3RootViewController dismissRightSideViewController];
	}
}

- (void)doneButtonAction:(id)button {
	[self.A3RootViewController dismissRightSideViewController];
}

- (void)addUnitAction {

	A3UnitConverterAddViewController *viewController = [self unitAddViewController];

	[self.navigationController pushViewController:viewController animated:YES];
}

- (A3UnitConverterAddViewController *)unitAddViewController {
    A3UnitConverterAddViewController *viewController = [[A3UnitConverterAddViewController alloc] initWithNibName:nil bundle:nil];
    viewController.delegate = self;
    viewController.shouldPopViewController = YES;
    
    UnitItem *item = _allData[0];
    viewController.allData = [NSMutableArray arrayWithArray:[UnitItem MR_findByAttribute:@"type" withValue:item.type andOrderBy:@"unitName" ascending:YES]];
    
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
        
        if ([ object isKindOfClass:[UnitFavorite class] ]) {
            ((UnitFavorite *)object).order = [NSString orderStringWithOrder:(i + 1) * 1000000];
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

#pragma mark - A3UnitConverterAddViewControllerDelegate

- (void)addViewController:(UIViewController *)viewController itemsAdded:(NSArray *)addedItems itemsRemoved:(NSArray *)removedItems
{
    FNLOG(@"Added\n%@", [addedItems description]);
    FNLOG(@"Removed\n%@", [removedItems description]);
    
    // 삭제하기
    NSMutableArray *removedIndexPaths = [[NSMutableArray alloc] init];
    for (int i=0; i<removedItems.count; i++) {
        UnitItem *item = removedItems[i];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"item == %@", item];
        NSArray *filtered = [_favorites filteredArrayUsingPredicate:predicate];
        
        if (filtered.count>0) {
            UnitFavorite *favor = filtered[0];
            NSUInteger itemIdx = [_favorites indexOfObject:favor];
            [favor MR_deleteEntity];
            [_favorites removeObject:favor];
            
            NSIndexPath *ip = [NSIndexPath indexPathForRow:itemIdx inSection:0];
            [removedIndexPaths addObject:ip];
        }
    }
    [self.tableView deleteRowsAtIndexPaths:removedIndexPaths withRowAnimation:UITableViewRowAnimationLeft];
    
    // 추가하기
    NSMutableArray *addIndexPaths = [[NSMutableArray alloc] init];
    for (int i=0; i<addedItems.count; i++) {
        NSUInteger lastIdx = [_favorites indexOfObject:_plusItem];
        
        UnitItem *item = addedItems[i];
        UnitFavorite *favorite = [UnitFavorite MR_createEntity];
        favorite.item = item;
        [_favorites insertObject:favorite atIndex:lastIdx];
        
        NSIndexPath *ip = [NSIndexPath indexPathForRow:lastIdx inSection:0];
        [addIndexPaths addObject:ip];
    }
    [self.tableView insertRowsAtIndexPaths:addIndexPaths withRowAnimation:UITableViewRowAnimationRight];
    
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
        if (isFavoriteMode) {
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
	UITableViewCell *toCell = nil;

	if (isFavoriteMode && ([self.favorites objectAtIndex:indexPath.row] == self.plusItem) ) {
		A3UnitConverterTVActionCell *actionCell = [self reusableActionCellForTableView:tableView];
		[self configurePlusCell:actionCell];
		toCell = actionCell;
	}
	else {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		}

		// Configure the cell...
		BOOL checkedItem = NO;
		UnitItem *data;
		if (tableView == self.searchDisplayController.searchResultsTableView) {
			data = self.filteredResults[indexPath.row];
		}
		else {
			if (isFavoriteMode) {
				UnitFavorite *favorite = _favorites[indexPath.row];
				data = favorite.item;
			}
			else {
				data = _allData[indexPath.row];
			}
		}

		cell.textLabel.text = data.unitName;

		if (checkedItem) {
			cell.accessoryType = UITableViewCellAccessoryCheckmark;
			cell.textLabel.textColor = [UIColor lightGrayColor];
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
        
        UnitFavorite *favorite = _favorites[indexPath.row];
        
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
    
    UnitFavorite *favorite = _favorites[fromIndexPath.row];
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
	if (isFavoriteMode && ([self.favorites objectAtIndex:indexPath.row] == self.plusItem) ) {
		[self addUnitAction];
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
	}
	else {
		UnitItem *data;
		if (tableView == self.searchDisplayController.searchResultsTableView) {
			data = self.filteredResults[indexPath.row];
		} else {
			if (isFavoriteMode) {

				if ([_favorites[indexPath.row] isKindOfClass:[UnitFavorite class]]) {
					UnitFavorite *favorite = _favorites[indexPath.row];
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
