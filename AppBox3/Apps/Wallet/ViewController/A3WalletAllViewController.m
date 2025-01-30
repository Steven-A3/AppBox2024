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
#import "WalletFieldItem+initialize.h"
#import "NSManagedObject+extension.h"
#import "NSManagedObjectContext+extension.h"
#import "A3SyncManager.h"
#import "A3UIDevice.h"

@interface A3WalletAllViewController () <UISearchBarDelegate, UISearchControllerDelegate, A3InstructionViewControllerDelegate, A3ViewControllerProtocol, UISearchResultsUpdating>

@property (nonatomic, strong) NSMutableDictionary *topItem;
@property (nonatomic, strong) NSMutableDictionary *emptyItem;		// 데이터가 없는 경우, 빈 셀 간격을 유지하기 위한 특별한 아이템
@property (nonatomic, readwrite) NSUInteger sortingMode;
@property (nonatomic, readwrite) BOOL isAscendingSort;
@property (nonatomic, strong) UIImageView *sortArrowImgView;

@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) NSArray *filteredResults;
@property (nonatomic, weak) UISegmentedControl *segmentedControlRef;
@property (nonatomic, weak) A3WalletAllTopView *topViewRef;
@property (nonatomic, copy) NSString *searchString;
@property (nonatomic, strong) UIBarButtonItem *searchBarButton;
@property (nonatomic, assign) BOOL dataEmpty;

@end

@implementation A3WalletAllViewController {
	BOOL _dataEmpty;
    BOOL _didPassViewDidAppear;
    CGFloat _previousContentOffset;
    BOOL _didAdjustContentInset;
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

//    self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    self.searchBarButton = [self searchBarButtonItem];
    self.navigationItem.rightBarButtonItems = @[[self instructionHelpBarButton], self.searchBarButton];
    _previousContentOffset = CGFLOAT_MAX;
    
	self.navigationItem.title = NSLocalizedString(@"All Items", @"All Items");
	self.showCategoryInDetailViewController = YES;

    self.definesPresentationContext = YES;

	if (IS_IPAD) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainMenuDidShow) name:A3NotificationMainMenuDidShow object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainMenuDidHide) name:A3NotificationMainMenuDidHide object:nil];
	}
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cloudStoreDidImport:) name:NSManagedObjectContextObjectsDidChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    self.tableView.contentInset = UIEdgeInsetsZero;
}

- (void)applicationDidEnterBackground {
	[self dismissInstructionViewController:nil];

	NSString *startingAppName = [[A3UserDefaults standardUserDefaults] objectForKey:kA3AppsStartingAppName];
	if ([startingAppName length] && ![startingAppName isEqualToString:A3AppName_Wallet]) {
		[_searchController setActive:NO];
		_searchController.delegate = nil;
		_searchController = nil;
	} else {
		if ([[A3AppDelegate instance] shouldProtectScreen] && [_searchController isActive]) {
			[_searchController setActive:NO];
		}
	}
}

- (void)cloudStoreDidImport:(NSNotification *)notification {
    NSManagedObjectContext *context = notification.object;
    if (![context isKindOfClass:[NSManagedObjectContext class]]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        return; // Ensure the notification's object is a managed object context.
    }

    NSDictionary *userInfo = notification.userInfo;

    // Combine all changes into a single set
    NSMutableSet *allChangedObjects = [NSMutableSet set];
    [allChangedObjects unionSet:userInfo[NSInsertedObjectsKey] ?: [NSSet set]];
    [allChangedObjects unionSet:userInfo[NSUpdatedObjectsKey] ?: [NSSet set]];
    [allChangedObjects unionSet:userInfo[NSDeletedObjectsKey] ?: [NSSet set]];

    // Check if any of the changes are related to the "WalletItem_" entity
    for (NSManagedObject *object in allChangedObjects) {
        if ([object.entity.name isEqualToString:@"WalletItem_"]) {
            FNLOG(@"Change detected for WalletItem_: %@", object);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self refreshItems];
                [self itemCountCheck];
                [self setupSearchBar];
                [self updateTopViewInfo:self->_topViewRef];
            });
            break; // No need to continue once we know there's a change
        }
    }
}

- (void)removeObserver {
	[super removeObserver];

	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextObjectsDidChangeNotification object:nil];
	if (IS_IPAD) {
		[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationMainMenuDidShow object:nil];
		[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationMainMenuDidHide object:nil];
	}
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	[self showLeftNavigationBarItems];

	// 데이타 갱신
	[self refreshItems];

	// 버튼 기능 활성화 여부
	[self itemCountCheck];

	if (![self isMovingToParentViewController] && _topViewRef) {
		[self updateTopViewInfo:_topViewRef];
	}
	if ([_searchString length]) {
//        self.navigationItem.searchController = self.searchController;
        [self.searchController setActive:YES];
        _searchController.searchBar.text = _searchString;
		[self filterContentForSearchText:_searchController.searchBar.text];
        self.tableView.tableHeaderView = nil;
	}
	[self enableControls:YES];

    if (!_didPassViewDidAppear) {
        self.tableView.contentOffset = CGPointMake(0, -64);
    } else {
        if (_previousContentOffset != CGFLOAT_MAX) {
            if ([_searchString length] == 0) {
                self.tableView.contentOffset = CGPointMake(0, _previousContentOffset);
                _previousContentOffset = CGFLOAT_MAX;
            }
        }
    }
    _searchString = nil;
    
    [self setupSearchBar];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	if (IS_IPHONE && [UIWindow interfaceOrientationIsPortrait]) {
		[self leftBarButtonAppsButton];
	}
	[self.navigationController setNavigationBarHidden:[_searchController isActive]];

	[self setupInstructionView];

    FNLOG(@"%f", self.tableView.contentOffset.y);
    
    UIEdgeInsets safeAreaInsets = [[[UIApplication sharedApplication] myKeyWindow] safeAreaInsets];
    if ((safeAreaInsets.top == 20) &&
        !_searchString &&
        !_dataEmpty &&
        self.tableView.contentOffset.y < -63.5) {
        double delayInSeconds = 0.3;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [UIView animateWithDuration:0.5
                             animations:^{
                CGFloat verticalOffset = 0;
                UIEdgeInsets safeAreaInsets = [[[UIApplication sharedApplication] myKeyWindow] safeAreaInsets];
                verticalOffset = safeAreaInsets.top - 20;
                self.tableView.contentOffset = CGPointMake(0, -(8 + verticalOffset));
            }
                             completion:nil];
        });
    }
    _didPassViewDidAppear = YES;
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

- (void)mainMenuDidShow {
	[self enableControls:NO];
}

- (void)mainMenuDidHide {
	[self enableControls:YES];
}

- (void)enableControls:(BOOL)enable {
	[self.addButton setEnabled:enable && ([WalletData visibleCategoryCount] > 0)];
    [self.searchBarButton setEnabled:enable && !_dataEmpty];
	
	if (!IS_IPAD) return;
	
	[self.navigationItem.leftBarButtonItem setEnabled:enable];
	[self.navigationItem.rightBarButtonItem setEnabled:enable];
	BOOL segmentedControlEnable = enable && [WalletItem_ countOfEntities] > 0;
	[self.segmentedControlRef setTintColor:segmentedControlEnable ? nil : [UIColor colorWithRed:147.0 / 255.0 green:147.0 / 255.0 blue:147.0 / 255.0 alpha:1.0]];
	[self.segmentedControlRef setEnabled:segmentedControlEnable];
	self.tabBarController.tabBar.tintColor = enable ? nil : [UIColor colorWithRGBRed:201 green:201 blue:201 alpha:255];
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
            if ([UIWindow interfaceOrientationIsLandscape]) {
                self.navigationItem.leftBarButtonItem = nil;
            }
            else {
				[self leftBarButtonAppsButton];
            }
        }
        else {
			if ([UIWindow interfaceOrientationIsPortrait]) {
				[self leftBarButtonAppsButton];
			} else {
				self.navigationItem.leftBarButtonItem = nil;
				self.navigationItem.hidesBackButton = YES;
			}
        }
    } else {
        [self makeBackButtonEmptyArrow];
        self.navigationItem.hidesBackButton = YES;

		if (IS_IPAD || [UIWindow interfaceOrientationIsPortrait]) {
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
}

- (NSMutableArray *)items
{
    if (!super.items) {
		NSMutableArray *items;
        NSString *sortValue = (self.sortingMode == kSortingDate) ? @"updateDate" : @"name";
        items = [NSMutableArray arrayWithArray:[WalletItem_ findAllSortedBy:sortValue ascending:self.isAscendingSort]];
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
        if (IS_IPHONE) {
            self.navigationItem.leftBarButtonItem = nil;
        }
        else {
            self.navigationItem.leftBarButtonItem = nil;
        }
    }
    else {
		[self leftBarButtonAppsButton];
    }
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
    WalletItem_ *recentItem = [WalletItem_ findFirstOrderedByAttribute:@"updateDate" ascending:NO];
    if (recentItem && recentItem.updateDate) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setDateStyle:IS_IPHONE ? NSDateFormatterShortStyle : NSDateFormatterMediumStyle];
        dateText = [formatter stringFromDate:recentItem.updateDate];
		
		if (dateText == nil) {
			dateText = @"-";
		}
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
    super.items = nil;
    [self items];
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

- (A3WalletItemEditViewController *)itemAddViewController
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"WalletPhoneStoryBoard" bundle:nil];
    A3WalletItemEditViewController *viewController = [storyBoard instantiateViewControllerWithIdentifier:@"A3WalletItemEditViewController"];
	viewController.alwaysReturnToOriginalCategory = YES;
    viewController.isAddNewItem = YES;
    viewController.hidesBottomBarWhenPushed = YES;
    
    // 마지막으로 추가되었던 walletItem의 카테고리가 선택되도록 한다.
    WalletItem_ *lastItem = [WalletItem_ findFirstOrderedByAttribute:@"updateDate" ascending:NO];
    if (lastItem) {
        viewController.category = [WalletData categoryItemWithID:lastItem.categoryID];
    }
    else {
        viewController.category = [WalletData firstEditableWalletCategory];
    }
    
    return viewController;
}

- (void)addWalletItemAction {
	A3WalletItemEditViewController *viewController = [self itemAddViewController];
    viewController.delegate = self;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:viewController];
    [self presentViewController:nav animated:YES completion:NULL];
}

#pragma mark Instruction Related

static NSString *const A3V3InstructionDidShowForWalletAllView = @"A3V3InstructionDidShowForWalletAllView";

- (void)setupInstructionView
{
    if ([self shouldShowHelpView]) {
        [self showInstructionView];
    }
}

- (BOOL)shouldShowHelpView {
    return [[CoreDataStack shared] coreDataReady] && ![[A3UserDefaults standardUserDefaults] boolForKey:A3V3InstructionDidShowForWalletAllView];
}


- (void)showInstructionView
{
    [[A3UserDefaults standardUserDefaults] setBool:YES forKey:A3V3InstructionDidShowForWalletAllView];
    [[A3UserDefaults standardUserDefaults] synchronize];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIStoryboard *instructionStoryBoard = [UIStoryboard storyboardWithName:IS_IPHONE ? A3StoryboardInstruction_iPhone : A3StoryboardInstruction_iPad bundle:nil];
        self.instructionViewController = [instructionStoryBoard instantiateViewControllerWithIdentifier:@"Wallet_1"];
        self.instructionViewController.delegate = self;

        UIWindow *mainWindow = [UIApplication sharedApplication].myKeyWindow;
        [mainWindow addSubview:self.instructionViewController.view];
        [mainWindow.rootViewController addChildViewController:self.instructionViewController];

        self.instructionViewController.view.frame = self.tabBarController.view.frame;
        self.instructionViewController.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight;
    });
}

#pragma mark - Search relative

- (void)searchAction:(id)sender {
//    self.navigationItem.searchController = self.searchController;
//    [self.searchController setActive:YES];
    [self.searchController.searchBar becomeFirstResponder];

    double delayInSeconds = 0.2;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.searchController.searchBar becomeFirstResponder];
    });
}

- (UISearchController *)searchController {
	if (!_searchController) {
		_searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
        _searchController.searchResultsUpdater = self;
        _searchController.delegate = self;
		_searchController.searchBar.delegate = self;
//        _searchController.hidesNavigationBarDuringPresentation = YES;
        [_searchController.searchBar sizeToFit];
        _searchController.obscuresBackgroundDuringPresentation = NO;
	}
	return _searchController;
}

- (void)setupSearchBar {
    if (!_dataEmpty) {
        [self.searchController.searchBar sizeToFit];
        self.tableView.tableHeaderView = self.searchController.searchBar;
    } else {
        self.tableView.tableHeaderView = nil;
    }
    [self.searchBarButton setEnabled:!self.dataEmpty];
}

#pragma mark - UISearchControllerDelegate

- (void)willPresentSearchController:(UISearchController *)searchController {
    FNLOG(@"contentOffset = %f", self.tableView.contentOffset.y);
    FNLOG(@"contentInset = %f", self.tableView.contentInset.top);
    FNLOG(@"adjustedContentInset = %f", self.tableView.adjustedContentInset.top);
}

- (void)didPresentSearchController:(UISearchController *)searchController {
//    self.tableView.contentOffset = CGPointMake(0, 18);
    FNLOG(@"contentOffset = %f", self.tableView.contentOffset.y);
    FNLOG(@"contentInset = %f", self.tableView.contentInset.top);
    FNLOG(@"adjustedContentInset = %f", self.tableView.adjustedContentInset.top);
}

- (void)didDismissSearchController:(UISearchController *)searchController {
    FNLOG(@"contentOffset = %f", self.tableView.contentOffset.y);
    FNLOG(@"contentInset = %f", self.tableView.contentInset.top);
    FNLOG(@"adjustedContentInset = %f", self.tableView.adjustedContentInset.top);
    [self setupSearchBar];
    [self.tableView reloadData];
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    [self filterContentForSearchText:searchController.searchBar.text];
}

- (void)filterContentForSearchText:(NSString*)searchText
{
	NSMutableArray *uniqueIDs = [NSMutableArray new];
	if (searchText && [searchText length]) {
		NSPredicate *predicateForValues = [NSPredicate predicateWithFormat:@"value contains[cd] %@", searchText];
		NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"WalletFieldItem_"];
		fetchRequest.predicate = predicateForValues;
		fetchRequest.resultType = NSDictionaryResultType;
		fetchRequest.propertiesToFetch = @[@"walletItemID"];
		NSError *error;
        NSManagedObjectContext *context = CoreDataStack.shared.persistentContainer.viewContext;
		NSArray *results = [context executeFetchRequest:fetchRequest error:&error];
		for (NSDictionary *item in results) {
			[uniqueIDs addObjectsFromArray:[item allValues]];
		}
	}
	
	NSString *query = searchText;
	if (query && query.length) {
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"note contains[cd] %@ OR name contains[cd] %@ OR uniqueID in %@", query, query, uniqueIDs];
		_filteredResults = [self.items filteredArrayUsingPredicate:predicate];
	} else {
		_filteredResults = nil;
	}
	[self.tableView reloadData];
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
- (void)walletItemAddCompleted:(WalletItem_ *)addedItem
{
    [self refreshItems];
}

- (void)walletITemAddCanceled
{
    
}

- (void)walletItemEdited:(WalletItem_ *)item {
    [self refreshItems];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *itemContainingArray;
    if (_filteredResults) {
        itemContainingArray = _filteredResults;
    } else {
        if (indexPath.row == 0) {
            return;
        }
        itemContainingArray = self.items;
    }
    WalletItem_ *item = itemContainingArray[indexPath.row];
    _previousContentOffset = self.tableView.contentOffset.y;

    [super tableView:tableView didSelectRowAtIndexPath:indexPath withItem:item];
    self.searchString = _searchController.searchBar.text;
    FNLOG(@"%@", _searchController.searchBar.text);
    [self.searchController setActive:NO];
    FNLOG(@"%@", _searchController.searchBar.text);
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!_filteredResults && ([self.items objectAtIndex:indexPath.row] == self.topItem)) {
        return 104;
    }
    else {
        return 48;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	FNLOG(@"%ld", (long)[self.items count]);
	if (_filteredResults) {
		return [_filteredResults count];
	}
    else {
	    return self.items.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = nil;
	NSArray *itemContainArray;
	if (_filteredResults) {
		itemContainArray = _filteredResults;
	}
	else {
		itemContainArray = self.items;
	}

	if ([[itemContainArray objectAtIndex:indexPath.row] isKindOfClass:[WalletItem_ class]]) {
		WalletItem_ *item = itemContainArray[indexPath.row];
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
		if ([topCell respondsToSelector:@selector(layoutMargins)]) {
			topCell.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0);
		}

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
		WalletItem_ *item;
		if (_filteredResults) {
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
		[item deleteWalletItem];
        NSManagedObjectContext *context = CoreDataStack.shared.persistentContainer.viewContext;
        [context saveIfNeeded];
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

	if (IS_IPHONE && [UIWindow interfaceOrientationIsLandscape]) {
		[self leftBarButtonAppsButton];
	}
}

@end
