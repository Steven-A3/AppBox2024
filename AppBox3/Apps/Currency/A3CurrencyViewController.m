//
//  A3CurrencyViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 7/5/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3CurrencyViewController.h"
#import "CurrencyFavorite.h"
#import "A3CurrencyTVActionCell.h"
#import "CurrencyHistory.h"
#import "A3CurrencyTVDataCell.h"
#import "A3AppDelegate.h"
#import "A3NumberKeyboardViewController.h"
#import "UIViewController+A3AppCategory.h"
#import "A3CurrencyTVEqualCell.h"
#import "NSMutableArray+A3Sort.h"
#import "A3CurrencyChartViewController.h"
#import "A3CurrencySelectViewController.h"
#import "Reachability.h"
#import "A3CurrencySettingsViewController.h"
#import "NSUserDefaults+A3Defaults.h"
#import "A3UIDevice.h"
#import "CurrencyHistoryItem.h"
#import "A3CurrencyHistoryViewController.h"
#import "UIViewController+MMDrawerController.h"
#import "NSString+conversion.h"
#import "UIViewController+A3Addition.h"
#import "A3CacheStoreManager.h"
#import "A3CurrencyDataManager.h"
#import "CurrencyRateItem.h"

NSString *const A3CurrencySettingsChangedNotification = @"A3CurrencySettingsChangedNotification";

@interface A3CurrencyViewController () <UITextFieldDelegate, ATSDragToReorderTableViewControllerDelegate, A3CurrencyMenuDelegate, A3SearchViewControllerDelegate, A3CurrencySettingsDelegate, A3CurrencyChartViewDelegate, UIPopoverControllerDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSMutableArray *favorites;
@property (nonatomic, strong) NSMutableDictionary *equalItem, *plusItem;
@property (nonatomic, strong) NSMutableDictionary *textFields;
@property (nonatomic, strong) CurrencyHistory *history;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UILabel *updateDateLabel;
@property (nonatomic, strong) UIButton *yahooButton;
@property (nonatomic, weak)	UITextField *firstResponder;
@property (nonatomic, strong) NSArray *moreMenuButtons;
@property (nonatomic, strong) UIView *moreMenuView;
@property (nonatomic, strong) CurrencyHistory *currencyHistory;
@property (nonatomic, strong) NSDate *animationStarted;
@property (nonatomic, strong) UIPopoverController *sharePopoverController;
@property (nonatomic, strong) A3CacheStoreManager *cacheStoreManager;

@end

@implementation A3CurrencyViewController {
    BOOL 		_draggingFirstRow;
	NSUInteger 	_selectedRow;
	BOOL		_isAddingCurrency;
	BOOL		_isShowMoreMenu;
}

NSString *const A3CurrencyDataCellID = @"A3CurrencyDataCell";
NSString *const A3CurrencyActionCellID = @"A3CurrencyActionCell";
NSString *const A3CurrencyEqualCellID = @"A3CurrencyEqualCell";

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nil bundle:nil];
	if (self) {

	}

	return self;
}

- (void)cleanUp{
	_favorites = nil;
	_equalItem = nil;
	_plusItem = nil;
	_textFields = nil;
	_history = nil;
	_bottomView = nil;
	_updateDateLabel = nil;
	_yahooButton = nil;
	_moreMenuButtons = nil;
	_currencyHistory = nil;
	_animationStarted = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    @autoreleasepool {
		self.title = NSLocalizedString(@"Currency", @"Currency");
		self.dragDelegate = self;

		self.refreshControl = [UIRefreshControl new];
		[self.refreshControl addTarget:self action:@selector(refreshRates) forControlEvents:UIControlEventValueChanged];

        [self setupSwipeRecognizers];

        [self makeBackButtonEmptyArrow];
        [self leftBarButtonAppsButton];

        if (IS_IPHONE) {
            [self rightButtonMoreButton];
        } else {
            self.navigationItem.hidesBackButton = YES;

            UIBarButtonItem *share = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"share"] style:UIBarButtonItemStylePlain target:self action:@selector(shareButtonAction:)];
            UIBarButtonItem *history = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"history"] style:UIBarButtonItemStylePlain target:self action:@selector(historyButtonAction:)];
            UIBarButtonItem *settings = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"general"] style:UIBarButtonItemStylePlain target:self action:@selector(settingsButtonAction:)];
            UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
            space.width = 24.0;

            self.navigationItem.rightBarButtonItems = @[settings, space, history, space, share];
        }

        [self.tableView registerClass:[A3CurrencyTVDataCell class] forCellReuseIdentifier:A3CurrencyDataCellID];
        [self.tableView registerNib:[UINib nibWithNibName:@"A3CurrencyTVActionCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:A3CurrencyActionCellID];
        [self.tableView registerNib:[UINib nibWithNibName:@"A3CurrencyTVEqualCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:A3CurrencyEqualCellID];

        self.tableView.rowHeight = 84.0;
        self.tableView.separatorColor = [UIColor colorWithRed:200.0 / 255.0 green:200.0 / 255.0 blue:200.0 / 255.0 alpha:1.0];
        self.tableView.separatorInset = UIEdgeInsetsMake(0.0, 0.0, -1.0, 0.0);
        self.tableView.showsVerticalScrollIndicator = NO;

        self.tableView.tableFooterView = self.bottomView;

		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cloudDidImportChanges:) name:USMStoreDidImportChangesNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingsChanged) name:A3CurrencySettingsChangedNotification object:nil];
    };
}

- (void)settingsChanged {
	[self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	if ([self isMovingToParentViewController]) {
		Reachability *reachability = [Reachability reachabilityForInternetConnection];
		NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		if ([[NSUserDefaults standardUserDefaults] currencyAutoUpdate]) {
			if ([reachability isReachableViaWiFi] ||
					([userDefaults currencyUseCellularData] && [A3UIDevice hasCellularNetwork])) {
				[self updateCurrencyRates];
			}
		}

		[self registerContentSizeCategoryDidChangeNotification];

		[self reloadUpdateDateLabel];
	}
}

- (void)viewWillLayoutSubviews {
	[super viewWillLayoutSubviews];

	if (IS_IPAD) {
		if (IS_LANDSCAPE) {
			self.navigationItem.leftBarButtonItem = nil;
		} else {
			[self leftBarButtonAppsButton];
		}
	}
}

- (void)contentSizeDidChange:(NSNotification *)notification {
	[self.tableView reloadData];
}

- (void)dealloc {
	[self removeObserver];
}

- (void)reloadUpdateDateLabel {
	@autoreleasepool {
		dispatch_async(dispatch_get_main_queue(), ^{
			NSArray *favoriteCurrencyCodes = [self.favorites valueForKeyPath:@"currencyCode"];

			NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K in (%@)", @"currencyCode", favoriteCurrencyCodes];
			NSArray *currencyRates = [CurrencyRateItem MR_findAllWithPredicate:predicate inContext:self.cacheStoreManager.context];
			NSDate *latterDate = nil;
			for (CurrencyRateItem *rate in currencyRates) {
				latterDate = [rate.updated laterDate:latterDate];
			}
			NSDateFormatter *df = [[NSDateFormatter alloc] init];
			[df setDateStyle:NSDateFormatterShortStyle];
			[df setTimeStyle:NSDateFormatterMediumStyle];
			self.updateDateLabel.text = [NSString stringWithFormat:@"Updated %@", [df stringFromDate:latterDate]];
		});
    };
}

- (void)clearEverything {
	@autoreleasepool {
		[_firstResponder resignFirstResponder];
		[self dismissMoreMenu];
	}
}

- (void)appsButtonAction {
	@autoreleasepool {
		[_firstResponder resignFirstResponder];

		if (IS_IPHONE) {
			[self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];

			if ([_moreMenuView superview]) {
				[self dismissMoreMenu];
				[self rightButtonMoreButton];
			}
		} else {
			[[[A3AppDelegate instance] rootViewController] toggleLeftMenuViewOnOff];
		}
	}
}

- (void)moreButtonAction:(UIButton *)button {
    @autoreleasepool {
        [_firstResponder resignFirstResponder];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonAction:)];
        
        _moreMenuButtons = @[self.shareButton, self.historyButton, self.settingsButton];
        _moreMenuView = [self presentMoreMenuWithButtons:_moreMenuButtons tableView:self.tableView];
        _isShowMoreMenu = YES;
    };
}

- (void)doneButtonAction:(id)button {
	@autoreleasepool {
		[self dismissMoreMenu];
	}
}

- (void)dismissMoreMenu {
	@autoreleasepool {
		if ( !_isShowMoreMenu || IS_IPAD ) return;

		[self moreMenuDismissAction:[[self.view gestureRecognizers] lastObject] ];
	}
}

- (void)moreMenuDismissAction:(UITapGestureRecognizer *)gestureRecognizer {
	@autoreleasepool {
		if (!_isShowMoreMenu) return;

		_isShowMoreMenu = NO;

		[self rightButtonMoreButton];
		[self dismissMoreMenuView:_moreMenuView tableView:self.tableView];
		[self.view removeGestureRecognizer:gestureRecognizer];
	}
}

- (NSNumberFormatter *)currencyFormatterWithCode:(NSString *)currencyCode {
	NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
	[nf setNumberStyle:NSNumberFormatterCurrencyStyle];
	[nf setCurrencyCode:currencyCode];
	return nf;
}

- (void)shareButtonAction:(id)sender {
	@autoreleasepool {
		[self clearEverything];

		[self shareAll:sender];
	}
}

- (void)historyButtonAction:(UIButton *)button {
	@autoreleasepool {
		[self clearEverything];

		A3CurrencyHistoryViewController *viewController = [[A3CurrencyHistoryViewController alloc] initWithNibName:nil bundle:nil];
		[self presentSubViewController:viewController];

		_currencyHistory = nil;
	}
}

- (void)settingsButtonAction:(UIButton *)button {
	@autoreleasepool {
		[self clearEverything];

		UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"A3CurrencySettings" bundle:nil];
		A3CurrencySettingsViewController *viewController = [storyboard instantiateInitialViewController];
		viewController.delegate = self;
		[self presentSubViewController:viewController];
	}
}

- (void)currencyConfigurationChanged {
	[self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIView *)bottomView {
	if (!_bottomView) {
		CGRect frame = self.view.bounds;
		frame.origin.y = 0.0;
		frame.size.height = 45.0;
		_bottomView = [[UIView alloc] initWithFrame:frame];
		_bottomView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.98];
        
        UIView *topSeparator = [[UIView alloc] initWithFrame:CGRectMake(-1.0, 0.0, frame.size.width + 1.0, 1.0)];
        topSeparator.layer.borderColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0].CGColor;
        topSeparator.layer.borderWidth = IS_RETINA ? 0.25 : 0.5;
        topSeparator.backgroundColor = [UIColor clearColor];
		topSeparator.translatesAutoresizingMaskIntoConstraints = NO;
        [_bottomView addSubview:topSeparator];

		[topSeparator makeConstraints:^(MASConstraintMaker *make) {
			make.left.equalTo(_bottomView.left);
			make.right.equalTo(_bottomView.right);
			make.top.equalTo(_bottomView.top);
			make.height.equalTo(@1);
		}];

		[_bottomView addSubview:self.updateDateLabel];
		[self.updateDateLabel makeConstraints:^(MASConstraintMaker *make) {
			make.centerX.equalTo(_bottomView.centerX);
			make.centerY.equalTo(_bottomView.centerY);
		}];

		[_bottomView addSubview:self.yahooButton];

		[_yahooButton makeConstraints:^(MASConstraintMaker *make) {
			make.centerY.equalTo(_bottomView.centerY);
			make.left.equalTo(_updateDateLabel.right).with.offset(10);
		}];
	}
	return _bottomView;
}

- (UILabel *)updateDateLabel {
	if (!_updateDateLabel) {
		_updateDateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		_updateDateLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
		_updateDateLabel.textColor = [UIColor colorWithRed:142.0/255.0 green:142.0/255.0 blue:147.0/255.0 alpha:1.0];
		_updateDateLabel.text = [NSString stringWithFormat:@"Updated 2013/07/24 10:38:11 PM"];
		_updateDateLabel.translatesAutoresizingMaskIntoConstraints = NO;
	}
	return _updateDateLabel;
}

- (UIButton *)yahooButton {
	if (!_yahooButton) {
		_yahooButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_yahooButton.translatesAutoresizingMaskIntoConstraints = NO;
		[_yahooButton setImage:[UIImage imageNamed:@"yahoo"] forState:UIControlStateNormal];
        [_yahooButton addTarget:self action:@selector(openFinanceYahoo) forControlEvents:UIControlEventTouchUpInside];
	}
	return _yahooButton;
}

- (void)refreshRates {
	[self updateCurrencyRates];
}

- (void)updateCurrencyRates {
	@autoreleasepool {

		[self shiftRight:self.swipedCells];
		[self dismissMoreMenu];

		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currencyRatesUpdated) name:A3NotificationCurrencyRatesUpdated object:nil];

		[self.refreshControl beginRefreshing];
		
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			[A3CurrencyDataManager updateCurrencyRatesInContext:self.cacheStoreManager.context];
		});
	}
}

- (void)currencyRatesUpdated {
	@autoreleasepool {
		[self.refreshControl endRefreshing];
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

		double delayInSeconds = 0.2;
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
		dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
			[self shiftRight:self.swipedCells];
			NSMutableArray *visibleRows = [NSMutableArray arrayWithArray:[self.tableView indexPathsForVisibleRows]];
			[self.tableView reloadRowsAtIndexPaths:visibleRows withRowAnimation:UITableViewRowAnimationNone];
			[self reloadUpdateDateLabel];
		});
	}
}

#pragma mark - Data Management

- (A3CacheStoreManager *)cacheStoreManager {
	if (!_cacheStoreManager) {
		_cacheStoreManager = [A3CacheStoreManager new];
	}
	return _cacheStoreManager;
}

- (NSMutableArray *)favorites {
	if (!_favorites) {
		_favorites = [[CurrencyFavorite MR_findAllSortedBy:@"order" ascending:YES] mutableCopy];
		[self addEqualAndPlus];
	}
	return _favorites;
}

- (void)openFinanceYahoo {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://finance.yahoo.com"]];
}

- (void)addEqualAndPlus {
	@autoreleasepool {
		[_favorites insertObjectToSortedArray:self.equalItem atIndex:1];
		[_favorites addObjectToSortedArray:self.plusItem];
	}
}

- (NSMutableDictionary *)equalItem {
	if (!_equalItem) {
		_equalItem = [@{@"title":@"=",@"order":@""} mutableCopy];
	}
	return _equalItem;
}

- (NSMutableDictionary *)plusItem {
	if (!_plusItem) {
		_plusItem = [@{@"title":@"+", @"order":@""} mutableCopy];
	}
	return _plusItem;
}

- (CurrencyHistory *)currencyHistory {
	if (!_currencyHistory) {
		_currencyHistory = [CurrencyHistory MR_findFirstOrderedByAttribute:@"updateDate" ascending:NO];
        if (!_currencyHistory) {
            [self putHistoryWithValue:@1.0];
        }
	}
	return _currencyHistory;
}

- (NSMutableDictionary *)textFields {
	if (!_textFields) {
		_textFields = [NSMutableDictionary new];
	}
	return _textFields;
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
    return [self.favorites count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell=nil;
	@autoreleasepool {
		cell = nil;

		if ([self.favorites objectAtIndex:indexPath.row] == self.equalItem) {
			A3CurrencyTVEqualCell *equalCell = [self reusableEqualCellForTableView:tableView];

			cell = equalCell;
		} else if ([self.favorites objectAtIndex:indexPath.row] == self.plusItem) {
			// Bottom row is reserved for "plus" action.
			A3CurrencyTVActionCell *actionCell = [self reusableActionCellForTableView:tableView];
			[self configurePlusCell:actionCell];
			cell = actionCell;
		} else if ( [ [self.favorites objectAtIndex:indexPath.row] isKindOfClass:[CurrencyFavorite class] ] ) {
			A3CurrencyTVDataCell *dataCell;
			dataCell = [tableView dequeueReusableCellWithIdentifier:A3CurrencyDataCellID forIndexPath:indexPath];
			if (nil == dataCell) {
				dataCell = [[A3CurrencyTVDataCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:A3CurrencyDataCellID];
				dataCell.menuDelegate = self;
			}

			[self configureDataCell:dataCell atIndexPath:indexPath];

			cell = dataCell;
		}
	}

    return cell;
}

- (void)configurePlusCell:(A3CurrencyTVActionCell *)actionCell {
//	actionCell.centerButton.titleLabel.font = [UIFont fontWithName:@"FontAwesome" size:25.0];
//	[actionCell.centerButton setTitleColor:nil forState:UIControlStateNormal];
	[actionCell.centerButton addTarget:self action:@selector(addCurrencyAction) forControlEvents:UIControlEventTouchUpInside];
}

- (void)configureDataCell:(A3CurrencyTVDataCell *)dataCell atIndexPath:(NSIndexPath *)indexPath {
	@autoreleasepool {
		dataCell.menuDelegate = self;

		NSInteger dataIndex = indexPath.row;

		dataCell.valueField.delegate = self;

		CurrencyFavorite *favorite = self.favorites[dataIndex];
		
		[self.textFields setObject:dataCell.valueField forKey:favorite.currencyCode];

		NSNumber *value;
		value = self.currencyHistory.value;

		if (dataIndex == 0) {
			dataCell.valueField.textColor = self.tableView.tintColor;
			dataCell.rateLabel.text = @"";
		} else {
			CurrencyFavorite *favoriteZero = nil;
			for (id object in self.favorites) {
				if ([object isKindOfClass:[CurrencyFavorite class]]) {
					favoriteZero = object;
					break;
				}
			}

			float rate = [self.cacheStoreManager rateForCurrencyCode:favorite.currencyCode] / [self.cacheStoreManager rateForCurrencyCode:favoriteZero.currencyCode];
			value = @(value.floatValue * rate);

			NSString *symbol;
			if ([favorite.currencySymbol length]) {
				symbol = [NSString stringWithFormat:@"%@ ,", favorite.currencySymbol];
			} else {
				symbol = @"";
			}
			dataCell.rateLabel.text = [NSString stringWithFormat:@"Rate = %0.4f", rate];
			dataCell.valueField.textColor = [UIColor blackColor];
		}
		if ([[NSUserDefaults standardUserDefaults] currencyShowNationalFlag]) {
			dataCell.flagImageView.image = [UIImage imageNamed:favorite.flagImageName];
		} else {
			dataCell.flagImageView.image = nil;
		}
		dataCell.valueField.text = [self currencyFormattedStringForCurrency:favorite.currencyCode value:value];
		dataCell.codeLabel.text = favorite.currencyCode;
	}
}

- (A3CurrencyTVActionCell *)reusableActionCellForTableView:(UITableView *)tableView {
	A3CurrencyTVActionCell *cell;
	cell = [tableView dequeueReusableCellWithIdentifier:A3CurrencyActionCellID];
	if (nil == cell) {
		cell = [[A3CurrencyTVActionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:A3CurrencyActionCellID];
	}
	return cell;
}

- (A3CurrencyTVEqualCell *)reusableEqualCellForTableView:(UITableView *)tableView {
	A3CurrencyTVEqualCell *cell;
	cell = [tableView dequeueReusableCellWithIdentifier:A3CurrencyEqualCellID];
	if (nil == cell) {
		cell = [[A3CurrencyTVEqualCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:A3CurrencyEqualCellID];
	}
	return cell;
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	return [[self.favorites objectAtIndex:indexPath.row] isKindOfClass:[CurrencyFavorite class]];
}

// Override to support rearranging the table view.
// Assumption : self.favorites is a sorted list.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
	@autoreleasepool {
		[self.favorites moveItemInSortedArrayFromIndex:fromIndexPath.row toIndex:toIndexPath.row];
		FNLOG(@"from: %ld, to: %ld", (long)fromIndexPath.row, (long)toIndexPath.row);
	}
}

#pragma mark - ATSDragToReorderTableViewControllerDraggableIndicators

- (UITableViewCell *)cellIdenticalToCellAtIndexPath:(NSIndexPath *)indexPath forDragTableViewController:(ATSDragToReorderTableViewController *)dragTableViewController {
	FNLOG();
	UITableViewCell *cell = nil;
	if ([self.favorites objectAtIndex:indexPath.row] == self.equalItem) {
		A3CurrencyTVEqualCell *equalCell = [[A3CurrencyTVEqualCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];

		cell = equalCell;
	} else if ([self.favorites objectAtIndex:indexPath.row] == self.plusItem) {
		// Bottom row is reserved for "plus" action.
		A3CurrencyTVActionCell *actionCell = [[A3CurrencyTVActionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
		[self configurePlusCell:actionCell];

		cell = actionCell;
	} else if ([[self.favorites objectAtIndex:indexPath.row] isKindOfClass:[CurrencyFavorite class]]) {
		A3CurrencyTVDataCell *dataCell = [[A3CurrencyTVDataCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];

		[self configureDataCell:dataCell atIndexPath:indexPath];
		cell = dataCell;
	}
	return cell;
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

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	@autoreleasepool {
		if ([_firstResponder isFirstResponder]) {
			[_firstResponder resignFirstResponder];
			[tableView deselectRowAtIndexPath:indexPath animated:YES];
			return;
		}

		if ([self.swipedCells.allObjects count]) {
			[self unswipeAll];
			[tableView deselectRowAtIndexPath:indexPath animated:YES];
			return;
		}

		[self clearEverything];

		id object = self.favorites[indexPath.row];
		if (object != _equalItem && object != _plusItem) {
			_selectedRow = indexPath.row;
			_isAddingCurrency = NO;
			A3CurrencySelectViewController *viewController = [self currencySelectViewControllerWithSelectedCurrency:_selectedRow];
			viewController.cacheStoreManager = self.cacheStoreManager;
			if (IS_IPHONE) {
				viewController.shouldPopViewController = YES;
				[self.navigationController pushViewController:viewController animated:YES];
			} else {
				[self presentSubViewController:viewController];
			}
		} else if (object == _plusItem) {
			[self addCurrencyAction];
			[tableView deselectRowAtIndexPath:indexPath animated:YES];
		} else {
			[tableView deselectRowAtIndexPath:indexPath animated:YES];
		}
	}
}

- (void)willDismissSearchViewController {
	@autoreleasepool {
		NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
		[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	}
}

- (void)searchViewController:(UIViewController *)viewController itemSelectedWithItem:(NSString *)selectedItem {
	@autoreleasepool {
		NSArray *result = [CurrencyRateItem MR_findByAttribute:A3KeyCurrencyCode withValue:selectedItem inContext:self.cacheStoreManager.context];
		if (_isAddingCurrency) {
			if ([result count]) {
				CurrencyRateItem *currencyItem = result[0];
				CurrencyFavorite *newFavorite = [CurrencyFavorite MR_createEntity];
				[A3CurrencyDataManager copyCurrencyFrom:currencyItem to:newFavorite];
				NSInteger insertIdx = [self.favorites count] - 1;
				[self.favorites insertObjectToSortedArray:newFavorite atIndex:insertIdx];

				[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];

				[self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:insertIdx inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
			}
		} else {
			CurrencyFavorite *favorite = self.favorites[_selectedRow];
			if ([result count]) {
				[A3CurrencyDataManager copyCurrencyFrom:result[0] to:favorite];

				[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];

				[self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_selectedRow inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];

				double delayInSeconds = 0.3;
				dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
				dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
					[self.tableView reloadRowsAtIndexPaths:[self.tableView indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationNone];
				});
			}
		}
	}
}

- (void)addCurrencyAction {
	@autoreleasepool {
		if ([_firstResponder isFirstResponder]) {
			[_firstResponder resignFirstResponder];
			return;
		}

		if ([self.swipedCells.allObjects count]) {
			[self unswipeAll];
			return;
		}

		[self clearEverything];

		_isAddingCurrency = YES;
		A3CurrencySelectViewController *viewController = [self currencySelectViewControllerWithSelectedCurrency:-1];
		viewController.cacheStoreManager = self.cacheStoreManager;
		if (IS_IPHONE) {
			viewController.shouldPopViewController = NO;
		}
		[self presentSubViewController:viewController];
	}
}

/*! Push CurrencySelectViewController filling with selected currency code
 * \param selectedIndex, selected row required or -1 for nothing
 * \returns void
 */
- (A3CurrencySelectViewController *)currencySelectViewControllerWithSelectedCurrency:(NSInteger)selectedIndex {
	A3CurrencySelectViewController *viewController = [[A3CurrencySelectViewController alloc] initWithNibName:nil bundle:nil];
	viewController.cacheStoreManager = self.cacheStoreManager;
	viewController.delegate = self;
	viewController.allowChooseFavorite = NO;
	if (selectedIndex >= 0 && selectedIndex < ([_favorites count] - 1) ) {
		CurrencyFavorite *selectedItem = _favorites[selectedIndex];
		viewController.placeHolder = selectedItem.currencyCode;
	}
	return viewController;
}

#pragma mark -- UITextField delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	@autoreleasepool {
		NSSet *keys = [_textFields keysOfEntriesPassingTest:^BOOL(id key, id obj, BOOL *stop) {
			if (obj == textField) {
				*stop = YES;
				return YES;
			}
			return NO;
		}];
		if (![keys count]) {
			return NO;
		}
		NSString *key = keys.allObjects[0];

		NSUInteger index = [self indexForCurrencyCode:key];
		if (index == NSNotFound) {
			return NO;
		}

		if(index == 0) {
			[self unswipeAll];

			if ([textField.text length]) {
				float value = [textField.text floatValueEx];
				if (value > 1.0) {
					[self putHistoryWithValue:@1.0];
					_currencyHistory = nil;
					[self currencyHistory];
				}
				textField.text = @"";
			}

			A3NumberKeyboardViewController *keyboardVC = [self normalNumberKeyboard];
			self.numberKeyboardViewController = keyboardVC;
			self.numberKeyboardViewController.keyboardType = A3NumberKeyboardTypeMonthYear;
			keyboardVC.textInputTarget = textField;
			keyboardVC.delegate = self;
			self.numberKeyboardViewController = keyboardVC;
			textField.inputView = [keyboardVC view];

			_firstResponder = textField;
			return YES;
		} else {
			[_firstResponder resignFirstResponder];

			// shifted 0 : shift self
			// shifted 1 and it is me. unshift self
			// shifted 1 and it is not me. unshift him and shift me.
			NSArray *swipped = self.swipedCells.allObjects;
			if (![swipped count]) {
				id cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];

				if (cell) {
					[self shiftLeft:cell];
				} else {
					FNLOG(@"Attention : Cell is nil");
				}
			} else {
				[self unswipeAll];
			}
			return NO;
		}
	}
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	@autoreleasepool {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
	}
}

- (void)A3KeyboardController:(id)controller clearButtonPressedTo:(UIResponder *)keyInputDelegate {
	UITextField *textField = (UITextField *) self.numberKeyboardViewController.textInputTarget;
	if ([textField isKindOfClass:[UITextField class]]) {
		textField.text = @"";
	}
}

- (void)A3KeyboardController:(id)controller doneButtonPressedTo:(UIResponder *)keyInputDelegate {
	[self.numberKeyboardViewController.textInputTarget resignFirstResponder];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
	FNLOG();
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	return YES;
}


- (void)textFieldDidChange:(NSNotification *)notification {
	@autoreleasepool {
		UITextField *textField = [notification object];
		[self updateTextFieldsWithSourceTextField:textField];
	}
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	@autoreleasepool {
		[[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];

		_firstResponder = nil;
		self.numberKeyboardViewController = nil;

		CurrencyFavorite *currencyFavorite = self.favorites[0];
		float value = [textField.text floatValue];
		if (value < 1.0) {
			value = 1.0;
		}
		textField.text = [self currencyFormattedStringForCurrency:currencyFavorite.currencyCode value:@(value)];
		[self updateTextFieldsWithSourceTextField:textField];

		[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
	}
}

- (NSUInteger)indexForCurrencyCode:(NSString *)code {
	NSUInteger targetIndex = [self.favorites indexOfObjectPassingTest:^BOOL(CurrencyFavorite *object, NSUInteger idx, BOOL *stop) {
		if ([object isKindOfClass:[NSMutableDictionary class]]) return NO;
		return ([object.currencyCode isEqualToString:code]);
	}];
	return targetIndex;
}

- (void)updateTextFieldsWithSourceTextField:(UITextField *)textField {
	@autoreleasepool {
		float fromValue = [textField.text floatValueEx];
		self.currencyHistory.value = @(fromValue);
		FNLOG(@"%@", _currencyHistory.value);

		NSInteger fromIndex = 0;
		FNLOG(@"%@", _textFields);
		for (NSString *key in [self.textFields allKeys]) {
			UITextField *targetTextField = _textFields[key];
			if (targetTextField == textField) {
				continue;
			}
			CurrencyFavorite *sourceCurrency = self.favorites[fromIndex];
			NSUInteger targetIndex = [self indexForCurrencyCode:key];
			if (targetIndex != NSNotFound) {
				CurrencyFavorite *targetCurrency = self.favorites[targetIndex];
				float rate = [self rateForSource:sourceCurrency target:targetCurrency];
				targetTextField.text = [self currencyFormattedStringForCurrency:targetCurrency.currencyCode value:@(fromValue * rate)];
			}
		}
	}
}

- (float)rateForSource:(CurrencyFavorite *)source target:(CurrencyFavorite *)target {
	return [self.cacheStoreManager rateForCurrencyCode:target.currencyCode] / [self.cacheStoreManager rateForCurrencyCode:source.currencyCode];
}

- (void)dragTableViewController:(ATSDragToReorderTableViewController *)dragTableViewController didBeginDraggingAtRow:(NSIndexPath *)dragRow {
    [self unswipeAll];
    _draggingFirstRow = (dragRow.row == 0);
	FNLOG();
}

- (void)dragTableViewController:(ATSDragToReorderTableViewController *)dragTableViewController willEndDraggingToRow:(NSIndexPath *)destinationIndexPath {
	FNLOG();
}

- (NSInteger)indexOfObject:(NSDictionary *) target {
	NSInteger idx = 0;
	NSString *searchTerm = [target valueForKey:@"title"];
	for (id obj in self.favorites) {
		if ([obj isKindOfClass:[NSMutableDictionary class]]) {
			NSDictionary *compareObj = obj;
			if ([searchTerm isEqualToString:[compareObj valueForKey:@"title"]]) {
				return idx;
			}
		}
		idx++;
	}
	return NSNotFound;
}

- (void)dragTableViewController:(ATSDragToReorderTableViewController *)dragTableViewController didEndDraggingToRow:(NSIndexPath *)destinationIndexPath {
	@autoreleasepool {
		NSInteger equalIndex, plusIndex;
		NSInteger count = [self.favorites count];

		equalIndex = [self indexOfObject:self.equalItem];

		if (equalIndex != 1) {
			FNLOG(@"equal index %ld is not 1.", (long)equalIndex);
			[self.favorites moveItemInSortedArrayFromIndex:equalIndex toIndex:1];
			[self.tableView moveRowAtIndexPath:[NSIndexPath indexPathForRow:equalIndex inSection:0] toIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
			if (equalIndex == 0) {
				[self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]]  withRowAnimation:UITableViewRowAnimationNone];
			}
		}

		plusIndex = [self indexOfObject:self.plusItem];

		if (plusIndex != (count - 1)) {
			FNLOG(@"plusIndex %ld is not %ld.", (long)plusIndex, (long)count - 1);
			[self.favorites moveItemInSortedArrayFromIndex:plusIndex toIndex:count - 1];
			[self.tableView moveRowAtIndexPath:[NSIndexPath indexPathForRow:plusIndex inSection:0] toIndexPath:[NSIndexPath indexPathForRow:count - 1 inSection:0]];
		}
		if ((_draggingFirstRow && (destinationIndexPath.row != 0)) || (destinationIndexPath.row == 0)) {
			double delayInSeconds = 0.3;
			dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
			dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
				[self.tableView reloadData];
			});
		}

		[[[MagicalRecordStack defaultStack] context] MR_saveOnlySelfAndWait];

#ifdef DEBUG
		[self logFavorites];
#endif
		
	}
}

#ifdef	DEBUG
- (void)logFavorites {
	NSMutableString *logMessage = [NSMutableString new];
	[logMessage appendString:@"\n"];
	for (id obj in self.favorites) {
		if ([obj isKindOfClass:[CurrencyFavorite class]]) {
			CurrencyFavorite *favoriteObj = obj;
			[logMessage appendFormat:@"%@ / %@\n", favoriteObj.currencyCode, favoriteObj.order];
		} else {
			[logMessage appendFormat:@"%@ / %@\n", obj[A3KeyCurrencyCode], obj[A3CommonPropertyOrder]];
		}
	}
	FNLOG(@"%@", logMessage);
}
#endif

- (BOOL)dragTableViewController:(ATSDragToReorderTableViewController *)dragTableViewController shouldHideDraggableIndicatorForDraggingToRow:(NSIndexPath *)destinationIndexPath {
	FNLOG();
	return NO;
}

#pragma mark - A3CurrencyMenuDelegate
- (void)menuAdded {
	[self clearEverything];
}

- (void)swapActionForCell:(UITableViewCell *)cell {
	@autoreleasepool {
		[self unswipeAll];

		UITableViewCell<A3TableViewSwipeCellDelegate> *swipedCell = (UITableViewCell <A3TableViewSwipeCellDelegate> *) cell;
		[swipedCell removeMenuView];

		NSIndexPath *sourceIndexPath = [self.tableView indexPathForCell:cell];
		NSIndexPath *targetIndexPath;
		if (sourceIndexPath.row == 0) {
			targetIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
		} else {
			targetIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
		}
		[self.favorites exchangeObjectInSortedArrayAtIndex:sourceIndexPath.row withObjectAtIndex:targetIndexPath.row];
		[self.tableView reloadRowsAtIndexPaths:@[sourceIndexPath, targetIndexPath] withRowAnimation:UITableViewRowAnimationMiddle];

		double delayInSeconds = 0.3;
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
		dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
			[self.tableView reloadData];
		});
	}
}


#pragma mark - Chart View Controller

- (void)chartActionForCell:(UITableViewCell *)cell {
	@autoreleasepool {
		[self unswipeAll];

		A3CurrencyChartViewController *viewController = [[A3CurrencyChartViewController alloc] initWithNibName:@"A3CurrencyChartViewController" bundle:nil];
		viewController.cacheStoreManager = self.cacheStoreManager;
		viewController.delegate = self;
		viewController.initialValue = _currencyHistory.value;
		NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
		CurrencyFavorite *favoriteZero = self.favorites[0], *favorite = self.favorites[indexPath.row == 0 ? 2 : indexPath.row ];
		viewController.sourceCurrencyCode = favoriteZero.currencyCode;
		viewController.targetCurrencyCode = favorite.currencyCode;
		[self.navigationController pushViewController:viewController animated:YES];
	}
}

- (void)chartViewControllerValueChanged:(NSNumber *)newValue {
	[self putHistoryWithValue:newValue];
	[self.tableView reloadData];
}

- (void)shareActionForCell:(UITableViewCell *)cell sender:(id)sender {
	@autoreleasepool {
		NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
		NSInteger targetIdx = indexPath.row == 0 ? 2 : indexPath.row;
		NSAssert(self.favorites[indexPath.row] != _equalItem && self.favorites[targetIdx] != _plusItem, @"Selected row must not the equal cell and/or plus cell");
		[self shareActionForSourceIndex:0 targetIndex:targetIdx sender:sender ];
	}
}

- (void)deleteActionForCell:(UITableViewCell *)cell {
	@autoreleasepool {
		[self unswipeAll];

		UITableViewCell<A3TableViewSwipeCellDelegate> *swipedCell = (UITableViewCell <A3TableViewSwipeCellDelegate> *) cell;
		[swipedCell removeMenuView];

		if ([_favorites count] < 5) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
															message:@"You need 2 currencies at least to convert values."
														   delegate:nil
												  cancelButtonTitle:@"OK"
												  otherButtonTitles:nil];
			[alert show];
			return;
		}

		NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
		CurrencyFavorite *favorite = self.favorites[indexPath.row];
		if ([favorite isKindOfClass:[CurrencyFavorite class]]) {
			[self.textFields removeObjectForKey:favorite.currencyCode];

			[favorite MR_deleteEntity];
			[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
			[self.favorites removeObjectAtIndex:indexPath.row];

			[self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];

			if (indexPath.row == 0) {
				_favorites = nil;
				[self favorites];

				[self.tableView moveRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] toIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];

				double delayInSeconds = 0.3;
				dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
				dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
					[self.tableView reloadRowsAtIndexPaths:[self.tableView indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationMiddle];
				});
			}
		}
	}
}

- (void)shareAll:(id)sender {
	@autoreleasepool {
		NSInteger index = 2;
		NSMutableString *shareString = [[NSMutableString alloc] init];
		CurrencyFavorite *source = self.favorites[0], *target;
		NSNumberFormatter *sourceNF = [self currencyFormatterWithCode:source.currencyCode];
		[shareString appendString:[NSString stringWithFormat:@"%@ %@ equals\n", source.currencyCode, [sourceNF stringFromNumber:self.currencyHistory.value] ] ];
		for (; index < [self.favorites count] - 1; index++) {
			target = self.favorites[index];
			NSNumberFormatter *targetNF = [self currencyFormatterWithCode:target.currencyCode];
			float rate = [self rateForSource:source target:target];
			[shareString appendString: [NSString stringWithFormat:@"%@ with rate %0.4f",
																  [targetNF stringFromNumber:@(self.currencyHistory.value.floatValue * rate)],
																  rate] ];

			[shareString appendString:@"\n"];
		}

		_sharePopoverController = [self presentActivityViewControllerWithActivityItems:@[shareString] fromBarButtonItem:sender];
		if (IS_IPAD) {
			_sharePopoverController.delegate = self;
			[self.navigationItem.rightBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem *buttonItem, NSUInteger idx, BOOL *stop) {
				[buttonItem setEnabled:NO];
			}];
		}
	}
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
	// Popver controller, iPad only.
	[self unswipeAll];

	[self.navigationItem.rightBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem *buttonItem, NSUInteger idx, BOOL *stop) {
		[buttonItem setEnabled:YES];
	}];
	_sharePopoverController = nil;
}

- (NSString *)stringForSource:(NSUInteger)sourceIdx targetIndex:(NSUInteger)targetIdx {
	CurrencyFavorite *source = self.favorites[sourceIdx], *target = self.favorites[targetIdx];
	NSNumberFormatter *sourceNF = [self currencyFormatterWithCode:source.currencyCode];
	NSNumberFormatter *targetNF = [self currencyFormatterWithCode:target.currencyCode];
	float rate = [self rateForSource:source target:target];
	return [NSString stringWithFormat:@"%@ equals %@ with rate %0.4f",
														[sourceNF stringFromNumber:self.currencyHistory.value],
														[targetNF stringFromNumber:@(self.currencyHistory.value.floatValue * rate)],
														rate];
}

- (void)shareActionForSourceIndex:(NSUInteger)sourceIdx targetIndex:(NSUInteger)targetIdx sender:(id)sender {
	@autoreleasepool {
		NSString *activityItem = [self stringForSource:sourceIdx targetIndex:targetIdx];

		UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[activityItem] applicationActivities:nil];
		if (IS_IPHONE) {
			[self presentViewController:activityController animated:YES completion:nil];
		} else {
			_sharePopoverController = [[UIPopoverController alloc] initWithContentViewController:activityController];
			UIView *view = (UIView *)sender;
			FNLOGRECT(view.frame);
			CGRect rect = [view convertRect:view.frame toView:self.view];
			rect.origin.x -= 144.0;
			[_sharePopoverController presentPopoverFromRect:rect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
			_sharePopoverController.delegate = self;
		}
	}
}

#pragma mark - History

- (void)putHistoryWithValue:(NSNumber *)value {
	@autoreleasepool {
		CurrencyFavorite *baseCurrency = self.favorites[0];
		CurrencyHistory *latestHistory = [CurrencyHistory MR_findFirstOrderedByAttribute:@"updateDate" ascending:NO];

		// Compare code and value.
		if (latestHistory) {
			if ([latestHistory.currencyCode isEqualToString:baseCurrency.currencyCode] &&
					[value isEqualToNumber:latestHistory.value])
			{

				FNLOG(@"Does not make new history for same code and value, in history %@, %@", latestHistory.value, value);
				return;
			}
		}

		CurrencyHistory *history = [CurrencyHistory MR_createEntity];
		NSDate *keyDate = [NSDate date];
		history.updateDate = keyDate;
		history.currencyCode = baseCurrency.currencyCode;
		history.rate = @([self.cacheStoreManager rateForCurrencyCode:baseCurrency.currencyCode]);
		history.value = value;

		NSInteger historyItemCount = MIN([self.favorites count] - 3, 4);
		NSInteger idx = 0;
		NSMutableSet *targets = [[NSMutableSet alloc] init];
		for (; idx < historyItemCount; idx++) {
			CurrencyHistoryItem *item = [CurrencyHistoryItem MR_createEntity];
			CurrencyFavorite *favorite = self.favorites[idx + 2];
			item.currencyCode = favorite.currencyCode;
			item.rate = @([self.cacheStoreManager rateForCurrencyCode:favorite.currencyCode]);
			item.order = favorite.order;
			[targets addObject:item];
		}
		history.targets = targets;

		[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];

		_currencyHistory = history;
	}
}

- (void)cloudDidImportChanges:(NSNotification *)note {
	_favorites = nil;
	[self.tableView reloadData];
}

#pragma mark -- THE END

@end
