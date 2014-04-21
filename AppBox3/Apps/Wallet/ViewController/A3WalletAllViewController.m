//
//  A3WalletAllViewController.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 11..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3WalletAllViewController.h"
#import "A3WalletItemViewController.h"
#import "A3WalletPhotoItemViewController.h"
#import "A3WalletListPhotoCell.h"
#import "A3WalletAllTopView.h"
#import "A3WalletAllTopCell.h"
#import "WalletData.h"
#import "WalletItem+Favorite.h"
#import "WalletItem+initialize.h"
#import "WalletField.h"
#import "WalletFieldItem.h"
#import "A3AppDelegate.h"
#import "UIViewController+A3Addition.h"
#import "NSDate+TimeAgo.h"
#import "UIViewController+A3AppCategory.h"
#import "WalletCategory.h"
#import "A3WalletVideoItemViewController.h"
#import "A3WalletItemEditViewController.h"
#import "WalletFieldItem+initialize.h"


#define TopHeaderHeight 96

@interface A3WalletAllViewController () <UISearchBarDelegate, UISearchDisplayDelegate>

@property (nonatomic, strong) UIBarButtonItem *searchItem;
@property (nonatomic, strong) NSMutableDictionary *topItem;
@property (nonatomic, strong) NSMutableDictionary *emptyItem;		// 데이터가 없는 경우, 빈 셀 간격을 유지하기 위한 특별한 아이템
@property (nonatomic, strong) UIButton *addButton;
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, readwrite) NSUInteger sortingMode;
@property (nonatomic, readwrite) BOOL isAscendingSort;
@property (nonatomic, strong) UIImageView *sortArrowImgView;

@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UISearchDisplayController *mySearchDisplayController;
@property (nonatomic, strong) NSArray *filteredResults;

@end

@implementation A3WalletAllViewController

NSString *const A3WalletTextCellID = @"A3WalletListTextCell";
NSString *const A3WalletPhotoCellID = @"A3WalletListPhotoCell";
NSString *const A3WalletVideoCellID = @"A3WalletListVideoCell";
NSString *const A3WalletAllTopCellID = @"A3WalletAllTopCell";
NSString *const A3WalletNormalCellID = @"A3WalletNormalCellID";

enum SortingKind {
    kSortingDate = 0,
    kSortingName,
};

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.title = @"All Items";

	[self makeBackButtonEmptyArrow];
    // more tabBar 안에서도 좌측barItem을 Apps로 유지한다.
    self.navigationItem.hidesBackButton = YES;
    [self leftBarButtonAppsButton];
    
    self.navigationItem.rightBarButtonItem = self.searchItem;
    
    [self initializeViews];
    
    self.sortingMode = kSortingDate;
    self.isAscendingSort = YES;
    
    [self.view addSubview:self.searchBar];
	[self mySearchDisplayController];
    
    [self registerContentSizeCategoryDidChangeNotification];
}

- (void)contentSizeDidChange:(NSNotification *) notification
{
    [self.tableView reloadData];
}

- (void)viewWillLayoutSubviews {
	[super viewWillLayoutSubviews];
    
    if (IS_IPAD) {
        
        if (self.editing) {
            
        }
        else {
			[self showLeftNavigationBarItems];
        }
	}
    
}

- (void)showLeftNavigationBarItems
{
    // 현재 more 탭바인지 여부 체크
    if (_isFromMoreTableViewController) {
        self.navigationItem.leftItemsSupplementBackButton = YES;
        // more 탭바
        
        self.navigationItem.hidesBackButton = NO;
        
        if (IS_IPAD) {
            if (IS_LANDSCAPE) {
                self.navigationItem.leftBarButtonItem = nil;
            }
            else {
                UIBarButtonItem *appsItem = [[UIBarButtonItem alloc] initWithTitle:@"Apps" style:UIBarButtonItemStylePlain target:self action:@selector(appsButtonAction:)];
                self.navigationItem.leftBarButtonItem = appsItem;
            }
        }
        else {
            UIBarButtonItem *appsItem = [[UIBarButtonItem alloc] initWithTitle:@"Apps" style:UIBarButtonItemStylePlain target:self action:@selector(appsButtonAction:)];
            self.navigationItem.leftBarButtonItem = appsItem;
        }
    } else {
        // 아님
        [self makeBackButtonEmptyArrow];
        self.navigationItem.hidesBackButton = YES;
        
		[self leftBarButtonAppsButton];
    }
}

- (void)initializeViews
{
	_tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	_tableView.showsVerticalScrollIndicator = NO;
	_tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    _tableView.rowHeight = 48.0;
    self.tableView.separatorColor = [self tableViewSeparatorColor];
    if (IS_IPAD) {
        _tableView.separatorInset = UIEdgeInsetsMake(0, 28, 0, 0);
    }
	[self.view addSubview:_tableView];
    
    [self.view addSubview:self.addButton];
    [self addButtonConstraints];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"A3WalletAllTopCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:A3WalletAllTopCellID];
    [self.tableView registerClass:[A3WalletListPhotoCell class] forCellReuseIdentifier:A3WalletPhotoCellID];
	[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:A3WalletNormalCellID];
}

- (void)addButtonConstraints
{
    CGFloat fromBottom = IS_IPAD ? 89.0:82.0;

	[_addButton makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(self.view.centerX);
		make.centerY.equalTo(self.view.bottom).with.offset(-fromBottom);
		make.width.equalTo(@44);
		make.height.equalTo(@44);
	}];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

	[self showLeftNavigationBarItems];

    // 데이타 갱신
    [self refreshItems];
    
    // 버튼 기능 활성화 여부
    [self itemCountCheck];
}

- (void)itemCountCheck {
    BOOL itemHave = (self.items.count>1) ? YES:NO;
    self.editButtonItem.enabled = itemHave;
    self.searchItem.enabled = itemHave;
    
    NSIndexPath *firstIP = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView reloadRowsAtIndexPaths:@[firstIP] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (NSMutableArray *)items
{
    if (!_items) {
        NSString *sortValue = (_sortingMode == kSortingDate) ? @"modificationDate" : @"name";
        _items = [NSMutableArray arrayWithArray:[WalletItem MR_findAllSortedBy:sortValue ascending:_isAscendingSort]];
        if (![_items count]) {
			[_items addObject:self.emptyItem];
		}
        [_items insertObject:self.topItem atIndex:0];
    }
    
    return _items;
}

- (NSMutableDictionary *)topItem
{
    if (!_topItem) {
        _topItem = [NSMutableDictionary dictionaryWithDictionary:@{@"title":@"TopInfo", @"order":@""}];
    }
    
    return _topItem;
}

- (NSMutableDictionary *)emptyItem {
	if (!_emptyItem) {
		_emptyItem = [NSMutableDictionary dictionaryWithDictionary:@{@"title":@"empty", @"order":@""}];
	}
	return _emptyItem;
}


- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
    [self.tableView setEditing:editing animated:animated];
    
    if (editing) {
        self.searchItem.enabled = NO;
        
        if (IS_IPHONE) {
            self.navigationItem.leftBarButtonItem = nil;
        }
        else {
            self.navigationItem.leftBarButtonItem = nil;
        }
    }
    else {
        self.searchItem.enabled = YES;

		[self leftBarButtonAppsButton];
    }
}

- (UIBarButtonItem *)searchItem
{
    if (!_searchItem) {
        _searchItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchButtonAction:)];
	}
    
    return _searchItem;
}

- (UIButton *)addButton
{
    if (!_addButton) {
        _addButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_addButton setImage:[UIImage imageNamed:@"add01"] forState:UIControlStateNormal];
        _addButton.frame = CGRectMake(0, 0, 44, 44);
		[_addButton addTarget:self action:@selector(addWalletItemAction) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _addButton;
}

- (UIImageView *)sortArrowImgView
{
    if (!_sortArrowImgView) {
        _sortArrowImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sort"]];
        _sortArrowImgView.frame = CGRectMake(0, 0, 9, 5);
    }
    
    return _sortArrowImgView;
}

- (void)topView:(A3WalletAllTopView *)topView enabledSet:(BOOL)enable
{
    topView.sortingSegment.enabled = enable;
    
    if (topView.sortingSegment.enabled) {
        topView.sortingSegment.tintColor = nil;
    } else {
        topView.sortingSegment.tintColor = SEGMENTED_CONTROL_DISABLED_TINT_COLOR;
    }
}

- (void)updateTopViewInfo:(A3WalletAllTopView *)topView;
{
    NSMutableAttributedString *cateAttrString = [[NSMutableAttributedString alloc] init];
    NSMutableAttributedString *itemAttrString = [[NSMutableAttributedString alloc] init];
    NSMutableAttributedString *updateAttrString = [[NSMutableAttributedString alloc] init];
    
    // attributes
    UIFont *titleFont = (IS_IPAD) ? [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2] : [UIFont systemFontOfSize:11];
    UIFont *numberFont = (IS_IPAD) ? [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline] : [UIFont boldSystemFontOfSize:17];
    
    NSDictionary *textAttributes = @{
                                     NSFontAttributeName : titleFont,
                                     NSForegroundColorAttributeName:[UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0]
                                     };
    NSDictionary *valueAttributes = @{
                                     NSFontAttributeName : numberFont,
                                     NSForegroundColorAttributeName:[UIColor colorWithRed:77.0/255.0 green:77.0/255.0 blue:77.0/255.0 alpha:1.0]
                                     };
    
    // cate
    NSMutableArray *tmp = [NSMutableArray new];
    for (WalletItem *item in self.items) {
        if (([item isKindOfClass:[WalletItem class]]) && ![tmp containsObject:item.category]) {
            [tmp addObject:item.category];
        }
    }
    NSUInteger cateCount = tmp.count;
    
    NSAttributedString *nameText = [[NSAttributedString alloc] initWithString:(cateCount > 1) ? @"CATEGORIES" : @"CATEGORY"
                                                                   attributes:textAttributes];
    NSAttributedString *countText = [[NSAttributedString alloc] initWithString:@(cateCount).stringValue
                                                                  attributes:valueAttributes];
    if (IS_IPAD) {
        [cateAttrString appendAttributedString:countText];
        [cateAttrString appendAttributedString:[[NSAttributedString alloc] initWithString:@" " attributes:textAttributes]];
        [cateAttrString appendAttributedString:nameText];
    }
    else {
        [cateAttrString appendAttributedString:nameText];
        [cateAttrString appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n" attributes:textAttributes]];
        [cateAttrString appendAttributedString:countText];
    }
    topView.cateLabel.attributedText = cateAttrString;
    
    // item
    NSInteger itemCount = _items.count - 1;
	if (_items && _items[1] == self.emptyItem) {
		itemCount = 0;
	}
    
    nameText = [[NSAttributedString alloc] initWithString:(itemCount > 1) ? @"ITEMS" : @"ITEM"
                                                                   attributes:textAttributes];
    countText = [[NSAttributedString alloc] initWithString:@(itemCount).stringValue
                                                                    attributes:valueAttributes];
    if (IS_IPAD) {
        [itemAttrString appendAttributedString:countText];
        [itemAttrString appendAttributedString:[[NSAttributedString alloc] initWithString:@" " attributes:textAttributes]];
        [itemAttrString appendAttributedString:nameText];
    }
    else {
        [itemAttrString appendAttributedString:nameText];
        [itemAttrString appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n" attributes:textAttributes]];
        [itemAttrString appendAttributedString:countText];
    }
    
    topView.itemsLabel.attributedText = itemAttrString;
    
    
    // update
    NSString *dateText = @"-";
    WalletItem *recentItem = [WalletItem MR_findFirstOrderedByAttribute:@"modificationDate" ascending:NO];
    if (recentItem) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MM/dd/yy"];
        dateText = [formatter stringFromDate:recentItem.modificationDate];
    }
    
    nameText = [[NSAttributedString alloc] initWithString:@"UPDATED"
                                               attributes:textAttributes];
    countText = [[NSAttributedString alloc] initWithString:dateText
                                                attributes:valueAttributes];
    if (IS_IPAD) {
        [updateAttrString appendAttributedString:countText];
        [updateAttrString appendAttributedString:[[NSAttributedString alloc] initWithString:@" " attributes:textAttributes]];
        [updateAttrString appendAttributedString:nameText];
    }
    else {
        [updateAttrString appendAttributedString:nameText];
        [updateAttrString appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n" attributes:textAttributes]];
        [updateAttrString appendAttributedString:countText];
    }
    
    topView.updatedLabel.attributedText = updateAttrString;
    
    int numOfLines = IS_IPAD ? 1:2;
    topView.cateLabel.numberOfLines = numOfLines;
    topView.itemsLabel.numberOfLines = numOfLines;
    topView.updatedLabel.numberOfLines = numOfLines;
}

- (void)refreshItems
{
    _items = nil;
    [self.tableView reloadData];
}

- (void)segmentTitleSet:(A3WalletAllTopView *)topView;
{
    float topViewWidth = topView.bounds.size.width;
    float segmentWidth = topView.sortingSegment.frame.size.width;
    float arrowRightMargin = IS_IPAD ? 30 : 15;
    
    switch (_sortingMode) {
        case kSortingDate:
        {
            self.sortArrowImgView.center = CGPointMake(topViewWidth/2.0-arrowRightMargin, topView.sortingSegment.center.y);
            
            if (_isAscendingSort) {
                _sortArrowImgView.transform = CGAffineTransformMakeRotation(DegreesToRadians(180));
            }
            else {
                _sortArrowImgView.transform = CGAffineTransformIdentity;
            }
            break;
        }
        case kSortingName:
        {
            self.sortArrowImgView.center = CGPointMake(topViewWidth/2.0+segmentWidth/2.0-arrowRightMargin, topView.sortingSegment.center.y);
            
            if (_isAscendingSort) {
                _sortArrowImgView.transform = CGAffineTransformMakeRotation(DegreesToRadians(180));
            }
            else {
                _sortArrowImgView.transform = CGAffineTransformIdentity;
            }
            break;
        }
        default:
            break;
    }
}

- (void)sortingSegTapped:(UISegmentedControl *)segment
{
    switch (segment.selectedSegmentIndex) {
        case 0:
        {
            if (_sortingMode == kSortingDate) {
                self.isAscendingSort = !_isAscendingSort;
            }
            else {
                self.sortingMode = kSortingDate;
            }
            
            break;
        }
        case 1:
        {
            if (_sortingMode == kSortingDate) {
                self.sortingMode = kSortingName;
            }
            else {
                self.isAscendingSort = !_isAscendingSort;
            }
            
            break;
        }
        default:
            break;
    }
    
    [self refreshItems];
}

- (void)searchButtonAction:(id)sender
{
    [self.searchBar becomeFirstResponder];
}

- (A3WalletItemEditViewController *)itemAddViewController
{
    NSString *nibName = (IS_IPHONE) ? @"WalletPhoneStoryBoard" : @"WalletPadStoryBoard";
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:nibName bundle:nil];
    A3WalletItemEditViewController *viewController = [storyBoard instantiateViewControllerWithIdentifier:@"A3WalletItemEditViewController"];
    viewController.isAddNewItem = YES;
    viewController.hidesBottomBarWhenPushed = YES;
    
    // 마지막으로 추가되었던 walletItem의 카테고리가 선택되도록 한다.
    WalletItem *lastItem = [WalletItem MR_findFirstOrderedByAttribute:@"modificationDate" ascending:NO];
    if (lastItem) {
        viewController.walletCategory = lastItem.category;
    }
    else {
        WalletCategory *category = [WalletCategory MR_findFirstOrderedByAttribute:@"name" ascending:YES];
        viewController.walletCategory = category;
    }
    
    return viewController;
}

- (void)addWalletItemAction {
	A3WalletItemEditViewController *viewController = [self itemAddViewController];

	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:viewController];
	[self presentViewController:nav animated:YES completion:NULL];
}

#pragma mark - Search relative

- (UISearchDisplayController *)mySearchDisplayController {
	if (!_mySearchDisplayController) {
		_mySearchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
		_mySearchDisplayController.delegate = self;
		_mySearchDisplayController.searchBar.delegate = self;
		_mySearchDisplayController.searchResultsTableView.delegate = self;
		_mySearchDisplayController.searchResultsTableView.dataSource = self;
		_mySearchDisplayController.searchResultsTableView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2f];
		_mySearchDisplayController.searchResultsTableView.showsVerticalScrollIndicator = NO;
        _mySearchDisplayController.searchResultsTableView.rowHeight = 48;
        
        [_mySearchDisplayController.searchResultsTableView registerClass:[A3WalletListPhotoCell class] forCellReuseIdentifier:A3WalletPhotoCellID];

	}
	return _mySearchDisplayController;
}

- (UISearchBar *)searchBar {
	if (!_searchBar) {
		_searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, kSearchBarHeight)];
		_searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		_searchBar.backgroundColor = self.navigationController.navigationBar.backgroundColor;
		_searchBar.delegate = self;
	}
	return _searchBar;
}

- (void)filterContentForSearchText:(NSString*)searchText
{
	NSString *query = searchText;
	if (query && query.length) {
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name contains[cd] %@", query];
		_filteredResults = [self.items filteredArrayUsingPredicate:predicate];
	} else {
		_filteredResults = nil;
	}
	[self.tableView reloadData];
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
	frame.origin.y = 0.0;
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

#pragma mark - WalletItemAddDelegate
- (void)walletItemAddCompleted:(WalletItem *)addedItem
{
    [self refreshItems];
}

- (void)walletITemAddCanceled
{
    
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *itemContainArray;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        itemContainArray = _filteredResults;
    }
    else {
        itemContainArray = self.items;
    }
    
    WalletItem *item = itemContainArray[indexPath.row];

    if ((tableView == self.tableView) && ([_items objectAtIndex:indexPath.row] == self.topItem)) {
        
    }
    else if ([item.category.name isEqualToString:WalletCategoryTypePhoto]) {
        NSString *boardName = IS_IPAD ? @"WalletPadStoryBoard":@"WalletPhoneStoryBoard";
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:boardName bundle:nil];
        A3WalletPhotoItemViewController *viewController = [storyBoard instantiateViewControllerWithIdentifier:@"A3WalletPhotoItemViewController"];
        viewController.hidesBottomBarWhenPushed = YES;
        viewController.item = item;
        [self.navigationController pushViewController:viewController animated:YES];
    }
    else if ([item.category.name isEqualToString:WalletCategoryTypeVideo]) {
        NSString *boardName = IS_IPAD ? @"WalletPadStoryBoard":@"WalletPhoneStoryBoard";
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:boardName bundle:nil];
        A3WalletVideoItemViewController *viewController = [storyBoard instantiateViewControllerWithIdentifier:@"A3WalletVideoItemViewController"];
        viewController.hidesBottomBarWhenPushed = YES;
        viewController.item = item;
        [self.navigationController pushViewController:viewController animated:YES];
    }
    else {
        NSString *boardName = IS_IPAD ? @"WalletPadStoryBoard":@"WalletPhoneStoryBoard";
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:boardName bundle:nil];
        A3WalletItemViewController *viewController = [storyBoard instantiateViewControllerWithIdentifier:@"A3WalletItemViewController"];
        viewController.hidesBottomBarWhenPushed = YES;
        viewController.item = item;
        viewController.showCategory = YES;
        [self.navigationController pushViewController:viewController animated:YES];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((tableView == self.tableView) && ([self.items objectAtIndex:indexPath.row] == self.topItem)) {
        return 104;
    }
    else {
        return 48;
    }
}

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
        return self.items.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=nil;
	@autoreleasepool {
		cell = nil;
        
        NSArray *itemContainArray;
        if (tableView == self.searchDisplayController.searchResultsTableView) {
            itemContainArray = _filteredResults;
        }
        else {
            itemContainArray = self.items;
        }

		if ([[itemContainArray objectAtIndex:indexPath.row] isKindOfClass:[WalletItem class]]) {
            
            WalletItem *item = itemContainArray[indexPath.row];

            if ([item.category.name isEqualToString:WalletCategoryTypePhoto]) {
                A3WalletListPhotoCell *photoCell;
                photoCell = [tableView dequeueReusableCellWithIdentifier:A3WalletPhotoCellID forIndexPath:indexPath];
                
                photoCell.rightLabel.textColor = [UIColor colorWithRed:159.0/255.0 green:159.0/255.0 blue:159.0/255.0 alpha:1.0];
                photoCell.rightLabel.text = [item.modificationDate timeAgo];
                if (IS_IPHONE) {
                    photoCell.rightLabel.font = [UIFont systemFontOfSize:12];
                }
                else {
                    photoCell.rightLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
                }
                
                NSMutableArray *photoPick = [[NSMutableArray alloc] init];
                NSArray *fieldItems = [item fieldItemsArray];
                for (int i=0; i<fieldItems.count; i++) {
                    WalletFieldItem *fieldItem = fieldItems[i];
                    if ([fieldItem.field.type isEqualToString:WalletFieldTypeImage] && fieldItem.image) {
                        [photoPick addObject:fieldItem];
                    }
                }
                
                NSInteger maxPhotoCount = (IS_IPAD) ? 5 : 2;
                NSInteger showPhotoCount = MIN(maxPhotoCount, photoPick.count);
                
                [photoCell resetThumbImages];

                for (int i=0; i<showPhotoCount; i++) {
                    WalletFieldItem *fieldItem = photoPick[i];
                    UIImage *thumbImg = [UIImage imageWithContentsOfFile:[fieldItem imageThumbnailPathInTemporary:NO ]];
                    
                    [photoCell addThumbImage:thumbImg];
                }
                
                cell = photoCell;
            }
            else if ([item.category.name isEqualToString:WalletCategoryTypeVideo]) {
                A3WalletListPhotoCell *videoCell;
                videoCell = [tableView dequeueReusableCellWithIdentifier:A3WalletPhotoCellID forIndexPath:indexPath];
                
                videoCell.rightLabel.textColor = [UIColor colorWithRed:159.0/255.0 green:159.0/255.0 blue:159.0/255.0 alpha:1.0];
                videoCell.rightLabel.text = [item.modificationDate timeAgo];
                if (IS_IPHONE) {
                    videoCell.rightLabel.font = [UIFont systemFontOfSize:12];
                }
                else {
                    videoCell.rightLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
                }
                
                NSMutableArray *photoPick = [[NSMutableArray alloc] init];
                NSArray *fieldItems = [item fieldItemsArray];
                for (int i=0; i<fieldItems.count; i++) {
                    WalletFieldItem *fieldItem = fieldItems[i];
                    if ([fieldItem.field.type isEqualToString:WalletFieldTypeVideo] && [fieldItem.hasVideo boolValue]) {
                        [photoPick addObject:fieldItem];
                    }
                }
                
                NSInteger maxPhotoCount = (IS_IPAD) ? 5 : 2;
                NSInteger showPhotoCount = MIN(maxPhotoCount, photoPick.count);

                [videoCell resetThumbImages];
                for (int i=0; i<showPhotoCount; i++) {
                    WalletFieldItem *fieldItem = photoPick[i];
                    UIImage *thumbImg = [UIImage imageWithContentsOfFile:[fieldItem videoThumbnailPathInTemporary:NO ]];
                    [videoCell addThumbImage:thumbImg];
                }
                
                cell = videoCell;
            }
            else {
                UITableViewCell *dataCell;
                dataCell = [tableView dequeueReusableCellWithIdentifier:A3WalletTextCellID];
                if (dataCell == nil) {
                    dataCell = [[UITableViewCell alloc] initWithStyle:IS_IPAD ? UITableViewCellStyleValue1:UITableViewCellStyleSubtitle reuseIdentifier:A3WalletTextCellID];
                    dataCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    dataCell.detailTextLabel.textColor = [UIColor colorWithRed:159.0/255.0 green:159.0/255.0 blue:159.0/255.0 alpha:1.0];
                }
				if (IS_IPHONE) {
					dataCell.textLabel.font = [UIFont systemFontOfSize:15];
					dataCell.detailTextLabel.font = [UIFont systemFontOfSize:12];
				}
				else {
					dataCell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
					dataCell.detailTextLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
				}

                if (item.name && item.name.length>0) {
                    dataCell.textLabel.text = item.name;
                }
                else {
                    dataCell.textLabel.text = @"New Item";
                }
                
                // all 에서는 오른쪽 필드에 시간을 표시하도록 변경
                dataCell.detailTextLabel.text = [item.modificationDate timeAgo];

                cell = dataCell;
            }
		}
        else if ((tableView == self.tableView) && ([_items objectAtIndex:indexPath.row] == self.topItem)) {
            A3WalletAllTopCell *topCell = [tableView dequeueReusableCellWithIdentifier:A3WalletAllTopCellID forIndexPath:indexPath];
            topCell.selectionStyle = UITableViewCellSelectionStyleNone;
            topCell.topView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            
            [topCell.topView.sortingSegment addTarget:self action:@selector(sortingSegTapped:) forControlEvents:UIControlEventValueChanged];
            if (![topCell.topView.subviews containsObject:self.sortArrowImgView]) {
                [topCell.topView addSubview:self.sortArrowImgView];
            }
            [topCell.topView.sortingSegment setTitle:@"Date" forSegmentAtIndex:0];
            [topCell.topView.sortingSegment setTitle:@"Name" forSegmentAtIndex:1];
            
            UIFont *segFont = [UIFont systemFontOfSize:13];
            NSDictionary *segTextAttributes = @{
                                            NSFontAttributeName : segFont
                                            };
            [topCell.topView.sortingSegment setTitleTextAttributes:segTextAttributes forState:UIControlStateNormal];
            
            [self updateTopViewInfo:topCell.topView];
            [self segmentTitleSet:topCell.topView];
            
            BOOL itemHave = (self.items.count>1) ? YES:NO;
            [self topView:topCell.topView enabledSet:itemHave];

			topCell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);

            cell = topCell;
        } else if ([_items objectAtIndex:indexPath.row] == self.emptyItem) {
			UITableViewCell *emptyCell = [tableView dequeueReusableCellWithIdentifier:A3WalletNormalCellID forIndexPath:indexPath];
			emptyCell.selectionStyle = UITableViewCellSelectionStyleNone;
			emptyCell.userInteractionEnabled = NO;
			cell = emptyCell;
		}
	}
    
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        WalletItem *item = _items[indexPath.row];
        [_items removeObject:item];
        [item MR_deleteEntity];

		if ([_items count] == 1) {
			[_items addObject:self.emptyItem];
			[tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
		} else {
			[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
		}

		[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
        
        // 버튼 기능 활성화 여부
        [self itemCountCheck];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

@end
