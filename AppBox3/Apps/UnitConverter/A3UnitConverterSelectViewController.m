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
#import "UnitConvertItem.h"
#import "UnitFavorite.h"
#import "NSString+conversion.h"
#import "UnitType.h"
#import "UnitItem.h"
#import "A3UnitConverterTVActionCell.h"
#import "A3UnitConverterAddViewController.h"
#import "NSMutableArray+A3Sort.h"
#import "UIViewController+iPad_rightSideView.h"
#import "UnitFavorite+extension.h"
#import "UnitConvertItem+extension.h"
#import "UnitItem+extension.h"


@interface A3UnitConverterSelectViewController () <UISearchDisplayDelegate, A3UnitConverterAddViewControllerDelegate>
{
    BOOL isFavoriteMode;
    BOOL isEdited;
}

@property (nonatomic, strong) UISegmentedControl *selectSegment;
@property (nonatomic, strong) UIBarButtonItem *cancelItem;
@property (nonatomic, strong) UIBarButtonItem *plusItem;

@end

@implementation A3UnitConverterSelectViewController

NSString *const A3UnitConverterActionCellID2 = @"A3UnitConverterActionCell";

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
	[self.view addSubview:self.searchBar];
	[self mySearchDisplayController];
    
    if (!_shouldPopViewController && IS_IPHONE) {
        self.navigationItem.leftBarButtonItem = self.cancelItem;
    }
    
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

 -(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (isEdited) {
        // 보고
        [self updateEditedDataToDelegate];
    }
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
        _cancelItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", @"Cancel")
													   style:UIBarButtonItemStylePlain
													  target:self
													  action:@selector(cancelButtonAction:)];
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

- (UISegmentedControl *)selectSegment
{
    UISegmentedControl *segment = [[UISegmentedControl alloc] initWithItems:@[NSLocalizedString(@"All Units", @"All Units"), NSLocalizedString(@"Favorites", @"Favorites")]];
    
    [segment setWidth:85 forSegmentAtIndex:0];
    [segment setWidth:85 forSegmentAtIndex:1];

    UIFont *font = [UIFont systemFontOfSize:13.0];
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:font
                                                           forKey:NSFontAttributeName];
    [segment setTitleTextAttributes:attributes forState:UIControlStateNormal];
    
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
}

- (void) setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];

    if (isFavoriteMode) {
        [self.tableView reloadData];
    }
    
    [self.tableView setEditing:editing animated:animated];
    
    if (editing) {
        self.navigationItem.leftBarButtonItem = self.plusItem;
    }
    else {
        if (!_shouldPopViewController && IS_IPHONE) {
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

- (A3UnitConverterTVActionCell *)reusableActionCellForTableView:(UITableView *)tableView {
	A3UnitConverterTVActionCell *cell;
	cell = [tableView dequeueReusableCellWithIdentifier:A3UnitConverterActionCellID2];
	if (nil == cell) {
		cell = [[A3UnitConverterTVActionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:A3UnitConverterActionCellID2];
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
	if ([_delegate respondsToSelector:@selector(selectViewController:unitSelectedWithItem:)]) {
        [_delegate selectViewController:self unitSelectedWithItem:selectedItem];
	}
	if (IS_IPHONE) {
		if (_shouldPopViewController) {
			[self.navigationController popViewControllerAnimated:YES];
		} else {
			[self dismissViewControllerAnimated:YES completion:nil];
		}
	} else {
		[self.A3RootViewController dismissRightSideViewController];
	}
}

- (void)doneButtonAction:(id)button {
	if (_delegate && [_delegate respondsToSelector:@selector(didUnitSelectCancled)]) {
		[_delegate didUnitSelectCancled];
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
    viewController.delegate = self;
    
    UnitItem *item = _allData[0];
    viewController.allData = [NSMutableArray arrayWithArray:[UnitItem MR_findByAttribute:@"typeID" withValue:item.typeID andOrderBy:@"unitName" ascending:YES]];
    
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
         NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemID == %@", item.uniqueID];
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
    
    // 추가하기
    NSMutableArray *addIndexPaths = [[NSMutableArray alloc] init];
    for (int i=0; i<addedItems.count; i++) {
        UnitItem *item = addedItems[i];
        UnitFavorite *favorite = [UnitFavorite MR_createEntity];
		favorite.uniqueID = item.uniqueID;
		favorite.updateDate = [NSDate date];
        favorite.itemID = item.uniqueID;
		favorite.typeID = item.typeID;
        [_favorites addObjectToSortedArray:favorite];
        
        NSUInteger idx = [_favorites indexOfObject:favorite];
        NSIndexPath *ip = [NSIndexPath indexPathForRow:idx inSection:0];
        [addIndexPaths addObject:ip];
    }
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];

	[[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    
    [self updateEditedDataToDelegate];
}

- (void)willDismissAddViewController
{
    FNLOG(@"%s", __PRETTY_FUNCTION__);

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
    UITableViewCell *toCell=nil;

	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		cell.textLabel.font = [UIFont systemFontOfSize:17.0];
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
			data = [favorite item];
		}
		else {
			data = _allData[indexPath.row];
		}
	}

	cell.textLabel.text = NSLocalizedStringFromTable(data.unitName, @"unit", nil);

	if ([data.unitName isEqualToString:_selectedItem.item.unitName]) {
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

	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"unitID == %@", data.uniqueID];
	NSArray *items = [self.convertItems filteredArrayUsingPredicate:predicate];
	if (items.count > 0) {
		cell.textLabel.textColor = [UIColor colorWithRed:201.0/255.0 green:201.0/255.0 blue:201.0/255.0 alpha:1.0];
		FNLOG(@"%@", cell.textLabel.text);
	}
	FNLOG(@"%@", cell.textLabel.text);

	toCell = cell;

    return toCell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return isFavoriteMode;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    UnitFavorite *favorite = _favorites[indexPath.row];
    if ([favorite.item.unitName isEqualToString:[_selectedItem item].unitName]) {
        return UITableViewCellEditingStyleDelete;
    }
    else {
        return UITableViewCellEditingStyleDelete;
    }
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
		[[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        
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

	[[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
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
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

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
				return;
			}
		}
		else {
			data = _allData[indexPath.row];
		}
	}

	if ([data.unitName isEqualToString:_selectedItem.item.unitName]) {

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
