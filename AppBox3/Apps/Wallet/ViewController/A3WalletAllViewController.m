//
//  A3WalletAllViewController.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 11..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3WalletAllViewController.h"
#import "A3WalletListPhotoCell.h"
#import "A3WalletAllTopView.h"
#import "A3WalletAllTopCell.h"
#import "WalletData.h"
#import "WalletItem+Favorite.h"
#import "WalletItem+initialize.h"
#import "A3AppDelegate.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+NumberKeyboard.h"
#import "A3WalletItemEditViewController.h"
#import "UIColor+A3Addition.h"
#import "A3InstructionViewController.h"
#import "A3UserDefaults.h"

@interface A3WalletAllViewController () <UISearchBarDelegate, UISearchDisplayDelegate, A3InstructionViewControllerDelegate, A3ViewControllerProtocol>

@property (nonatomic, strong) UIBarButtonItem *searchItem;
@property (nonatomic, strong) NSMutableDictionary *topItem;
@property (nonatomic, strong) NSMutableDictionary *emptyItem;		// 데이터가 없는 경우, 빈 셀 간격을 유지하기 위한 특별한 아이템
@property (nonatomic, readwrite) NSUInteger sortingMode;
@property (nonatomic, readwrite) BOOL isAscendingSort;
@property (nonatomic, strong) UIImageView *sortArrowImgView;

@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UISearchDisplayController *mySearchDisplayController;
@property (nonatomic, strong) NSArray *filteredResults;
@property (nonatomic, weak) UISegmentedControl *segmentedControlRef;
@property (nonatomic, weak) A3WalletAllTopView *topViewRef;

@end

@implementation A3WalletAllViewController {
	BOOL _dataEmpty;
}

enum SortingKind {
    kSortingDate = 0,
    kSortingName,
};

NSString *const A3WalletAllViewSortKey = @"A3WalletAllViewSortKey";
NSString *const A3WalletAllViewSortIsAscending = @"A3WalletAllViewSortIsAscending";
NSString *const A3WalletAllViewSortKeyName = @"name";
NSString *const A3WalletAllViewSortKeyDate = @"date";

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.rightBarButtonItems = @[self.searchItem, [self instructionHelpBarButton]];
    
	self.navigationItem.title = NSLocalizedString(@"All Items", @"All Items");
	self.showCategoryInDetailViewController = YES;

    [self.view addSubview:self.searchBar];
	[self mySearchDisplayController];

	if (IS_IPAD) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainMenuDidShow) name:A3NotificationMainMenuDidShow object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainMenuDidHide) name:A3NotificationMainMenuDidHide object:nil];
	}
    [self setupInstructionView];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cloudStoreDidImport) name:A3NotificationCloudCoreDataStoreDidImport object:nil];
}

- (void)cloudStoreDidImport {
	[self refreshItems];
	[self itemCountCheck];
	[self updateTopViewInfo:_topViewRef];
}

- (void)removeObserver {
	[super removeObserver];

	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationCloudCoreDataStoreDidImport object:nil];
	if (IS_IPAD) {
		[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationMainMenuDidShow object:nil];
		[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationMainMenuDidHide object:nil];
	}
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	[self.view addSubview:self.searchBar];
	[self showLeftNavigationBarItems];

	// 데이타 갱신
	[self refreshItems];

	// 버튼 기능 활성화 여부
	[self itemCountCheck];

	if (![self isMovingToParentViewController] && _topViewRef) {
		[self updateTopViewInfo:_topViewRef];
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	if (IS_IPHONE && IS_PORTRAIT) {
		[self leftBarButtonAppsButton];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	[self.searchBar removeFromSuperview];

	if ([self isMovingFromParentViewController] || [self isBeingDismissed]) {
		FNLOG();
		[self removeObserver];
	}
}

- (void)dealloc {
	[self removeObserver];
}

- (void)mainMenuDidShow {
	[self enableControls:NO];
}

- (void)mainMenuDidHide {
	[self enableControls:YES];
}

- (void)enableControls:(BOOL)enable {
	if (!IS_IPAD) return;
	[self.navigationItem.leftBarButtonItem setEnabled:enable];
	[self.navigationItem.rightBarButtonItem setEnabled:enable];
	[self.addButton setEnabled:enable];
	BOOL segmentedControlEnable = enable && [WalletItem MR_countOfEntities] > 0;
	[self.segmentedControlRef setTintColor:segmentedControlEnable ? nil : [UIColor colorWithRed:147.0 / 255.0 green:147.0 / 255.0 blue:147.0 / 255.0 alpha:1.0]];
	[self.segmentedControlRef setEnabled:segmentedControlEnable];
	self.tabBarController.tabBar.selectedImageTintColor = enable ? nil : [UIColor colorWithRGBRed:201 green:201 blue:201 alpha:255];
}

- (void)contentSizeDidChange:(NSNotification *) notification
{
    [self.tableView reloadData];
}

- (void)viewWillLayoutSubviews {
	[super viewWillLayoutSubviews];

	[self itemCountCheck];
    if (IS_IPAD) {
		[self showLeftNavigationBarItems];
	}
}

- (void)showLeftNavigationBarItems
{
    // 현재 more 탭바인지 여부 체크
    if (self.isFromMoreTableViewController) {
        self.navigationItem.leftItemsSupplementBackButton = YES;
        // more 탭바
        
        self.navigationItem.hidesBackButton = NO;
        
        if (IS_IPAD) {
            if (IS_LANDSCAPE) {
                self.navigationItem.leftBarButtonItem = nil;
            }
            else {
				[self leftBarButtonAppsButton];
            }
        }
        else {
			if (IS_PORTRAIT) {
				[self leftBarButtonAppsButton];
			} else {
				self.navigationItem.leftBarButtonItem = nil;
				self.navigationItem.hidesBackButton = YES;
			}
        }
    } else {
        [self makeBackButtonEmptyArrow];
        self.navigationItem.hidesBackButton = YES;

		if (IS_IPAD || IS_PORTRAIT) {
			[self leftBarButtonAppsButton];
		} else {
			self.navigationItem.leftBarButtonItem = nil;
			self.navigationItem.hidesBackButton = YES;
		}
    }
}

- (void)initializeViews
{
	[super initializeViews];

    [self.view addSubview:self.addButton];
    [self addButtonConstraints];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"A3WalletAllTopCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:A3WalletAllTopCellID];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)itemCountCheck {
	BOOL enable = !_dataEmpty;
	if (_segmentedControlRef) {
		if (enable) {
			[self.segmentedControlRef setTintColor:nil];
		} else {
			[self.segmentedControlRef setTintColor:[UIColor colorWithRed:147.0 / 255.0 green:147.0 / 255.0 blue:147.0 / 255.0 alpha:1.0]];
		}

		[_segmentedControlRef setEnabled:enable];
	}
	self.navigationItem.rightBarButtonItem.enabled = enable;
}

- (NSMutableArray *)items
{
    if (!super.items) {
		NSMutableArray *items;
        NSString *sortValue = (self.sortingMode == kSortingDate) ? @"updateDate" : @"name";
        items = [NSMutableArray arrayWithArray:[WalletItem MR_findAllSortedBy:sortValue ascending:self.isAscendingSort]];
		_dataEmpty = ![items count];
		if (_dataEmpty) {
			[items addObject:self.emptyItem];
		}
        [items insertObject:self.topItem atIndex:0];
		[super setItems:items];
    }
    
    return super.items;
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

- (UIImageView *)sortArrowImgView
{
    if (!_sortArrowImgView) {
        _sortArrowImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sort"]];
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
    UIFont *numberFont = (IS_IPAD) ? [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline] : [UIFont boldSystemFontOfSize:15];
    
    NSDictionary *textAttributes = @{
                                     NSFontAttributeName : titleFont,
                                     NSForegroundColorAttributeName:[UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0]
                                     };
    NSDictionary *valueAttributes = @{
                                     NSFontAttributeName : numberFont,
                                     NSForegroundColorAttributeName:[UIColor colorWithRed:77.0/255.0 green:77.0/255.0 blue:77.0/255.0 alpha:1.0]
                                     };

    NSUInteger cateCount = [WalletData visibleCategoryCount];

    NSAttributedString *nameText = [[NSAttributedString alloc] initWithString:(cateCount > 1) ? NSLocalizedString(@"CATEGORIES", @"CATEGORIES") : NSLocalizedString(@"CATEGORY", @"CATEGORY")
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
    NSInteger itemCount = self.items.count - 1;
	if (self.items && self.items[1] == self.emptyItem) {
		itemCount = 0;
	}
    
    nameText = [[NSAttributedString alloc] initWithString:(itemCount > 1) ? NSLocalizedString(@"ITEMS", @"ITEMS") : NSLocalizedString(@"ITEM", @"ITEM")
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
    WalletItem *recentItem = [WalletItem MR_findFirstOrderedByAttribute:@"updateDate" ascending:NO];
    if (recentItem) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setDateStyle:IS_IPHONE ? NSDateFormatterShortStyle : NSDateFormatterMediumStyle];
        dateText = [formatter stringFromDate:recentItem.updateDate];
    }
    
    nameText = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"UPDATED", @"UPDATED")
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
    self.items = nil;
    [self.tableView reloadData];
}

- (void)segmentTitleSet:(A3WalletAllTopView *)topView;
{
    CGRect screenBounds = [A3UIDevice screenBoundsAdjustedWithOrientation];
    float topViewWidth = screenBounds.size.width;
    float segmentWidth = IS_IPAD ? 301 : 85 * 2;
    float arrowRightMargin = IS_IPAD ? 30 : 15;
    
    switch (self.sortingMode) {
        case kSortingDate:
        {
            self.sortArrowImgView.center = CGPointMake(topViewWidth/2.0-arrowRightMargin, topView.sortingSegment.center.y);
            FNLOGRECT(self.sortArrowImgView.frame);

            if (self.isAscendingSort) {
				_sortArrowImgView.transform = CGAffineTransformIdentity;
            }
            else {
				_sortArrowImgView.transform = CGAffineTransformMakeRotation(DegreesToRadians(180));
            }
            break;
        }
        case kSortingName:
        {
            self.sortArrowImgView.center = CGPointMake(topViewWidth/2.0+segmentWidth/2.0-arrowRightMargin, topView.sortingSegment.center.y);
            FNLOGRECT(self.sortArrowImgView.frame);
            
            if (self.isAscendingSort) {
				_sortArrowImgView.transform = CGAffineTransformIdentity;
            }
            else {
				_sortArrowImgView.transform = CGAffineTransformMakeRotation(DegreesToRadians(180));
            }
            break;
        }
        default:
            break;
    }
}

#pragma mark -- SegmentedControl

- (void)sortingSegTapped:(UISegmentedControl *)segment
{
    switch (segment.selectedSegmentIndex) {
        case 0:
        {
            if (self.sortingMode == kSortingDate) {
                self.isAscendingSort = !self.isAscendingSort;
            }
            else {
                self.sortingMode = kSortingDate;
            }
            
            break;
        }
        case 1:
        {
            if (self.sortingMode == kSortingDate) {
                self.sortingMode = kSortingName;
            }
            else {
                self.isAscendingSort = !self.isAscendingSort;
            }
            
            break;
        }
        default:
            break;
    }
    
    [self refreshItems];
}

- (NSUInteger)sortingMode {
    NSString *sortKeyString = [[A3UserDefaults standardUserDefaults] objectForKey:A3WalletAllViewSortKey];
    if ([sortKeyString isEqualToString:A3WalletAllViewSortKeyDate]) {
        return kSortingDate;
    }
    return kSortingName;
}

- (void)setSortingMode:(NSUInteger)sortingMode {
    [[A3UserDefaults standardUserDefaults] setObject:sortingMode == kSortingDate ? A3WalletAllViewSortKeyDate : A3WalletAllViewSortKeyName
                                              forKey:A3WalletAllViewSortKey];
    [[A3UserDefaults standardUserDefaults] synchronize];
}

- (BOOL)isAscendingSort {
    id value = [[A3UserDefaults standardUserDefaults] objectForKey:A3WalletAllViewSortIsAscending];
    if (value) {
        return [value boolValue];
    }
    return YES;
}

- (void)setIsAscendingSort:(BOOL)isAscendingSort {
    [[A3UserDefaults standardUserDefaults] setBool:isAscendingSort forKey:A3WalletAllViewSortIsAscending];
    [[A3UserDefaults standardUserDefaults] synchronize];
}

- (void)searchButtonAction:(id)sender
{
    [self.searchBar becomeFirstResponder];
}

- (A3WalletItemEditViewController *)itemAddViewController
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"WalletPhoneStoryBoard" bundle:nil];
    A3WalletItemEditViewController *viewController = [storyBoard instantiateViewControllerWithIdentifier:@"A3WalletItemEditViewController"];
	viewController.alwaysReturnToOriginalCategory = YES;
    viewController.isAddNewItem = YES;
    viewController.hidesBottomBarWhenPushed = YES;
    
    // 마지막으로 추가되었던 walletItem의 카테고리가 선택되도록 한다.
    WalletItem *lastItem = [WalletItem MR_findFirstOrderedByAttribute:@"updateDate" ascending:NO];
    if (lastItem) {
        viewController.category = [WalletData categoryItemWithID:lastItem.categoryID inContext:nil];
    }
    else {
        viewController.category = [WalletData firstEditableWalletCategory];
    }
    
    return viewController;
}

- (void)addWalletItemAction {
	A3WalletItemEditViewController *viewController = [self itemAddViewController];

    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:viewController];
    [self presentViewController:nav animated:YES completion:NULL];
}

#pragma mark Instruction Related

static NSString *const A3V3InstructionDidShowForWalletAllView = @"A3V3InstructionDidShowForWalletAllView";

- (void)setupInstructionView
{
    if (![[A3UserDefaults standardUserDefaults] boolForKey:A3V3InstructionDidShowForWalletAllView]) {
        [self showInstructionView];
    }
}

- (void)showInstructionView
{
	[[A3UserDefaults standardUserDefaults] setBool:YES forKey:A3V3InstructionDidShowForWalletAllView];
	[[A3UserDefaults standardUserDefaults] synchronize];

    UIStoryboard *instructionStoryBoard = [UIStoryboard storyboardWithName:IS_IPHONE ? A3StoryboardInstruction_iPhone : A3StoryboardInstruction_iPad bundle:nil];
    self.instructionViewController = [instructionStoryBoard instantiateViewControllerWithIdentifier:@"Wallet_1"];
    self.instructionViewController.delegate = self;

	UIWindow *mainWindow = [UIApplication sharedApplication].keyWindow;
    [mainWindow addSubview:self.instructionViewController.view];
	[mainWindow.rootViewController addChildViewController:self.instructionViewController];

    self.instructionViewController.view.frame = self.tabBarController.view.frame;
    self.instructionViewController.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight;
	if (IS_IOS7) {
		[self rotateAccordingToStatusBarOrientationAndSupportedOrientations];

		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(statusBarFrameOrOrientationChanged:)
													 name:UIApplicationDidChangeStatusBarOrientationNotification
												   object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(statusBarFrameOrOrientationChanged:)
													 name:UIApplicationDidChangeStatusBarFrameNotification
												   object:nil];
	}
}

#pragma mark - Search relative

- (UISearchDisplayController *)mySearchDisplayController {
	if (!_mySearchDisplayController) {
		_mySearchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
		_mySearchDisplayController.delegate = self;
		_mySearchDisplayController.searchBar.delegate = self;
		_mySearchDisplayController.searchResultsTableView.delegate = self;
		_mySearchDisplayController.searchResultsTableView.dataSource = self;
        _mySearchDisplayController.searchResultsTableView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
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
	self.items = nil;
    _filteredResults = nil;
	[self.tableView reloadData];
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
    if (!((tableView == self.tableView) && (indexPath.row == 0))) {
		NSArray *itemContainingArray;
		if (tableView == self.searchDisplayController.searchResultsTableView) {
			itemContainingArray = _filteredResults;
		}
		else {
			itemContainingArray = self.items;
		}

		WalletItem *item = itemContainingArray[indexPath.row];

		[super tableView:tableView didSelectRowAtIndexPath:indexPath withItem:item];
	}
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	FNLOG(@"%ld", (long)[self.items count]);
	if (tableView == self.searchDisplayController.searchResultsTableView) {
		return [_filteredResults count];
	}
    else {
	    return self.items.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	FNLOG(@"%ld, %ld", (long)indexPath.section, (long)indexPath.row);

	UITableViewCell *cell = nil;
	NSArray *itemContainArray;
	if (tableView == self.searchDisplayController.searchResultsTableView) {
		itemContainArray = _filteredResults;
	}
	else {
		itemContainArray = self.items;
	}

	if ([[itemContainArray objectAtIndex:indexPath.row] isKindOfClass:[WalletItem class]]) {
		WalletItem *item = itemContainArray[indexPath.row];
		cell = [self tableView:tableView cellForRowAtIndexPath:indexPath walletItem:item];
	}
	else if ((tableView == self.tableView) && ([self.items objectAtIndex:indexPath.row] == self.topItem)) {
		A3WalletAllTopCell *topCell = [tableView dequeueReusableCellWithIdentifier:A3WalletAllTopCellID forIndexPath:indexPath];
		topCell.selectionStyle = UITableViewCellSelectionStyleNone;
		topCell.topView.autoresizingMask = UIViewAutoresizingFlexibleWidth;

		[topCell.topView.sortingSegment addTarget:self action:@selector(sortingSegTapped:) forControlEvents:UIControlEventValueChanged];
		if (![topCell.topView.subviews containsObject:self.sortArrowImgView]) {
			[topCell.topView addSubview:self.sortArrowImgView];
		}
		[topCell.topView.sortingSegment setTitle:NSLocalizedString(@"Date", @"Date") forSegmentAtIndex:0];
		[topCell.topView.sortingSegment setTitle:NSLocalizedString(@"Name", @"Name") forSegmentAtIndex:1];

		UIFont *segFont = [UIFont systemFontOfSize:13];
		NSDictionary *segTextAttributes = @{
				NSFontAttributeName : segFont
		};
		[topCell.topView.sortingSegment setTitleTextAttributes:segTextAttributes forState:UIControlStateNormal];

		[self updateTopViewInfo:topCell.topView];
        [topCell.topView.sortingSegment setSelectedSegmentIndex:self.sortingMode == kSortingDate ? 0 : 1];
		[self segmentTitleSet:topCell.topView];

		BOOL itemHave = (self.items.count>1) ? YES:NO;
		[self topView:topCell.topView enabledSet:itemHave];

        topCell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);

		_segmentedControlRef = topCell.topView.sortingSegment;
		_topViewRef = topCell.topView;

		[self itemCountCheck];

		cell = topCell;
	} else {
		UITableViewCell *emptyCell = [tableView dequeueReusableCellWithIdentifier:A3WalletNormalCellID forIndexPath:indexPath];
		emptyCell.selectionStyle = UITableViewCellSelectionStyleNone;
		emptyCell.userInteractionEnabled = NO;
		cell = emptyCell;
	}

	return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return !_dataEmpty;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		WalletItem *item;
		if ([_filteredResults count]) {
			item = _filteredResults[indexPath.row];

			NSMutableArray *newArray = [_filteredResults mutableCopy];
			[newArray removeObject:item];
			_filteredResults = newArray;

			[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
		} else {
			item = self.items[indexPath.row];
			[self.items removeObject:item];

			// Delete the row from the data source
			if ([self.items count] == 1) {
				_dataEmpty = YES;
				[self.items addObject:self.emptyItem];
				[tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
			} else {
				[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
			}
		}

		// 버튼 기능 활성화 여부
		[self itemCountCheck];
		if (_topViewRef) {
			[self updateTopViewInfo:_topViewRef];
		}
		[item deleteWalletItemInContext:[NSManagedObjectContext MR_defaultContext]];
		[[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
	}
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
	// Return NO if you do not want the item to be re-orderable.
	return NO;
}

- (BOOL)moveTableView:(FMMoveTableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];

	if (IS_IPHONE && IS_LANDSCAPE) {
		[self leftBarButtonAppsButton];
	}
}

@end
