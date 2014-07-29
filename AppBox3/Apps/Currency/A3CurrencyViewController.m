//
//  A3CurrencyViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 7/5/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3CurrencyViewController.h"
#import "CurrencyHistory.h"
#import "A3CurrencyTVDataCell.h"
#import "A3AppDelegate.h"
#import "A3NumberKeyboardViewController.h"
#import "UIViewController+NumberKeyboard.h"
#import "A3CurrencyTVEqualCell.h"
#import "NSMutableArray+A3Sort.h"
#import "A3CurrencyChartViewController.h"
#import "A3CurrencySelectViewController.h"
#import "Reachability.h"
#import "A3CurrencySettingsViewController.h"
#import "NSUserDefaults+A3Defaults.h"
#import "CurrencyHistoryItem.h"
#import "A3CurrencyHistoryViewController.h"
#import "UIViewController+MMDrawerController.h"
#import "NSString+conversion.h"
#import "UIViewController+A3Addition.h"
#import "A3CurrencyDataManager.h"
#import "CurrencyRateItem.h"
#import "NSDate+TimeAgo.h"
#import "UIViewController+iPad_rightSideView.h"
#import "UIColor+A3Addition.h"
#import "A3CalculatorViewController.h"
#import "A3InstructionViewController.h"
#import "A3UserDefaults.h"
#import "A3SyncManager.h"

NSString *const A3CurrencySettingsChangedNotification = @"A3CurrencySettingsChangedNotification";
NSString *const A3CurrencyUpdateDate = @"A3CurrencyUpdateDate";

@interface A3CurrencyViewController () <FMMoveTableViewDataSource, FMMoveTableViewDelegate,
		UITextFieldDelegate, A3CurrencyMenuDelegate, A3SearchViewControllerDelegate, A3CurrencySettingsDelegate, A3CurrencyChartViewDelegate,
		UIPopoverControllerDelegate, NSFetchedResultsControllerDelegate, UIActivityItemSource, A3CalculatorViewControllerDelegate,
		A3InstructionViewControllerDelegate>

@property (nonatomic, strong) NSMutableArray *favorites;
@property (nonatomic, strong) NSMutableDictionary *equalItem;
@property (nonatomic, strong) CurrencyHistory *history;
@property (nonatomic, strong) NSMutableDictionary *textFields;
@property (nonatomic, strong) NSArray *moreMenuButtons;
@property (nonatomic, strong) UIView *moreMenuView;
@property (nonatomic, strong) UIPopoverController *sharePopoverController;
@property (nonatomic, strong) UIButton *plusButton;
@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, copy) NSString *previousValue;
@property (nonatomic, strong) NSDate *updateStartDate;
@property (nonatomic, strong) UIBarButtonItem *historyBarButton;
@property (nonatomic, weak) UITextField *calculatorTargetTextField;
@property (nonatomic, strong) UINavigationController *modalNavigationController;
@property (nonatomic, strong) A3CurrencyHistoryViewController *historyViewController;
@property (nonatomic, strong) A3CurrencySettingsViewController *settingsViewController;
@property (nonatomic, strong) A3CurrencySelectViewController *currencySelectViewController;
@property (nonatomic, strong) A3InstructionViewController *instructionViewController;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) UITableViewController *tableViewController;
@property (nonatomic, assign) BOOL cancelInputNewCloudDataReceived;

@end

@implementation A3CurrencyViewController {
    BOOL 		_draggingFirstRow;
	NSUInteger 	_selectedRow;
	BOOL		_isAddingCurrency;
	BOOL		_isShowMoreMenu;
	BOOL		_isUpdating;
	BOOL		_currentValueIsNotFromUser;
	NSUInteger	_shareSourceIndex, _shareTargetIndex;
	BOOL		_shareAll;
	BOOL		_barButtonEnabled;
}

NSString *const A3CurrencyDataCellID = @"A3CurrencyDataCell";
NSString *const A3CurrencyActionCellID = @"A3CurrencyActionCell";
NSString *const A3CurrencyEqualCellID = @"A3CurrencyEqualCell";

- (void)viewDidLoad
{
    [super viewDidLoad];

	[A3CurrencyDataManager setupFavorites];

	_barButtonEnabled = YES;

	self.tableView.dataSource = self;
	self.tableView.delegate = self;

	self.title = NSLocalizedString(@"Currency Converter", nil);

	self.refreshControl = [UIRefreshControl new];
	[self.refreshControl addTarget:self action:@selector(refreshControlValueChanged) forControlEvents:UIControlEventValueChanged];

	self.tableViewController = [[UITableViewController alloc] initWithStyle:self.tableView.style];
	self.tableViewController.tableView = self.tableView;
	self.tableViewController.refreshControl = self.refreshControl;
	[self addChildViewController:self.tableViewController];

	[self setupSwipeRecognizers];

	[self makeBackButtonEmptyArrow];
	[self leftBarButtonAppsButton];

	if (IS_IPHONE) {
		[self rightButtonMoreButton];
	} else {
		self.navigationItem.hidesBackButton = YES;

		UIBarButtonItem *share = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"share"] style:UIBarButtonItemStylePlain target:self action:@selector(shareButtonAction:)];
		share.tag = A3RightBarButtonTagShareButton;
		UIBarButtonItem *settings = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"general"] style:UIBarButtonItemStylePlain target:self action:@selector(settingsButtonAction:)];
		settings.tag = A3RightBarButtonTagSettingsButton;
		UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
		self.historyBarButton = [self historyBarButton:[CurrencyHistory class]];
		self.historyBarButton.tag = A3RightBarButtonTagHistoryButton;
		space.width = 24.0;
        UIBarButtonItem *help = [self instructionHelpBarButton];
        help.tag = A3RightBarButtonTagHelpButton;
		self.navigationItem.rightBarButtonItems = @[settings, space, self.historyBarButton, space, share, space, help];
	}

	[self.tableView registerClass:[A3CurrencyTVDataCell class] forCellReuseIdentifier:A3CurrencyDataCellID];
	[self.tableView registerNib:[UINib nibWithNibName:@"A3CurrencyTVActionCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:A3CurrencyActionCellID];
	[self.tableView registerNib:[UINib nibWithNibName:@"A3CurrencyTVEqualCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:A3CurrencyEqualCellID];

	self.tableView.rowHeight = 84.0;
	self.tableView.separatorColor = [UIColor colorWithRed:200.0 / 255.0 green:200.0 / 255.0 blue:200.0 / 255.0 alpha:1.0];
	self.tableView.separatorInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
	self.tableView.showsVerticalScrollIndicator = NO;

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cloudDidImportChanges:) name:A3NotificationCloudCoreDataStoreDidImport object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cloudDidImportChanges:) name:A3NotificationCloudKeyValueStoreDidImport object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingsChanged) name:A3CurrencySettingsChangedNotification object:nil];
	if (IS_IPAD) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rightSideViewWillDismiss) name:A3NotificationRightSideViewWillDismiss object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainMenuViewDidHide) name:A3NotificationMainMenuDidHide object:nil];
	}
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(coreDataChanged:) name:NSManagedObjectContextObjectsDidChangeNotification object:[NSManagedObjectContext MR_defaultContext]];
	[self registerContentSizeCategoryDidChangeNotification];
    [self setupInstructionView];
}

- (void)cloudDidImportChanges:(NSNotification *)note {
	if (self.firstResponder) {
		_cancelInputNewCloudDataReceived = YES;
		[self.firstResponder resignFirstResponder];
	}

	_favorites = nil;
	[self favorites];

	[self.tableView reloadData];
	[self enableControls:_barButtonEnabled];
}

- (void)removeObserver {
	[self removeContentSizeCategoryDidChangeNotification];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationCloudCoreDataStoreDidImport object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationCloudKeyValueStoreDidImport object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3CurrencySettingsChangedNotification object:nil];
	if (IS_IPAD) {
		[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationRightSideViewWillDismiss object:nil];
		[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationMainMenuDidHide object:nil];
	}
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextObjectsDidChangeNotification object:[NSManagedObjectContext MR_defaultContext]];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	if ([self isMovingFromParentViewController] || [self isBeingDismissed]) {
		FNLOG();
		[self removeObserver];
	}
}

- (void)cleanUp{
	[self removeObserver];

	_favorites = nil;
	_equalItem = nil;
	_textFields = nil;
	_history = nil;
	_moreMenuButtons = nil;
	[_plusButton removeFromSuperview];
	_plusButton = nil;
}

- (void)dealloc {
	[self removeObserver];
}

- (void)mainMenuViewDidHide {
	[self enableControls:YES];
}

- (void)rightSideViewWillDismiss {
	[self enableControls:YES];
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)settingsChanged {
	[self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	UIView *superview = self.view.superview;
	[superview addSubview:self.plusButton];

	if ([self isMovingToParentViewController]) {
		[self.plusButton makeConstraints:^(MASConstraintMaker *make) {
			make.centerX.equalTo(superview.centerX);
			make.centerY.equalTo(superview.bottom).with.offset(-32);
			make.width.equalTo(@44);
			make.height.equalTo(@44);
		}];

		Reachability *reachability = [Reachability reachabilityForInternetConnection];
		NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		if ([[NSUserDefaults standardUserDefaults] currencyAutoUpdate]) {
			if ([reachability isReachableViaWiFi] ||
					([userDefaults currencyUseCellularData] && [A3UIDevice hasCellularNetwork])) {
				[self updateCurrencyRatesWithAnimation:NO ];
			}
		}

		[self reloadUpdateDateLabel];
	}
}

- (void)enableControls:(BOOL)enable {
	if (!IS_IPAD) return;

	_barButtonEnabled = enable;
	[self.navigationItem.leftBarButtonItem setEnabled:enable];
	[self.plusButton setEnabled:enable];

	if (IS_IPAD) {
		if (enable) {
			[self.navigationItem.rightBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem *barButtonItem, NSUInteger idx, BOOL *stop) {
				switch (barButtonItem.tag) {
					case A3RightBarButtonTagHistoryButton:
						[barButtonItem setEnabled:[CurrencyHistory MR_countOfEntities] > 0];
						break;
					case A3RightBarButtonTagShareButton:
					case A3RightBarButtonTagSettingsButton:
                    case A3RightBarButtonTagHelpButton:
						[barButtonItem setEnabled:YES];
						break;
				}
			}];
		} else {
			[self.navigationItem.rightBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem *barButtonItem, NSUInteger idx, BOOL *stop) {
				[barButtonItem setEnabled:NO];
			}];
		}
	}

	CGRect cellFrame = [self.tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
	if (!CGRectEqualToRect(cellFrame, CGRectZero)) {
		A3CurrencyTVDataCell *cell = (A3CurrencyTVDataCell *) [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
		cell.valueField.textColor = enable ? [[A3AppDelegate instance] themeColor] : [UIColor colorWithRGBRed:201 green:201 blue:201 alpha:255];
	}
}

- (void)coreDataChanged:(NSNotification *)notification {
	if (IS_IPAD) {
		[self.historyBarButton setEnabled:[CurrencyHistory MR_countOfEntities] > 0];
	}
}

- (UIView *)footerView {
	if (!_footerView) {
		_footerView = [UIView new];
		_footerView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 70);

		UIView *topSeparator = [UIView new];
		topSeparator.layer.borderColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0].CGColor;
		topSeparator.layer.borderWidth = IS_RETINA ? 0.25 : 0.5;
		topSeparator.backgroundColor = [UIColor clearColor];
		[_footerView addSubview:topSeparator];

		[topSeparator makeConstraints:^(MASConstraintMaker *make) {
			make.left.equalTo(_footerView.left);
			make.right.equalTo(_footerView.right);
			make.top.equalTo(_footerView.top);
			make.height.equalTo(@1);
		}];
	}
	return _footerView;
}

- (UIButton *)plusButton {
	if (!_plusButton) {
		_plusButton = [UIButton buttonWithType:UIButtonTypeSystem];
		[_plusButton setImage:[UIImage imageNamed:@"add01"] forState:UIControlStateNormal];
		[_plusButton addTarget:self action:@selector(plusButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	}
	return _plusButton;
}

- (void)contentSizeDidChange:(NSNotification *)notification {
	[self.tableView reloadData];
}

- (void)clearEverything {
	[self unSwipeAll];

	[self.firstResponder resignFirstResponder];
	[self setFirstResponder:nil];

	[self dismissMoreMenu];
}

- (void)appsButtonAction:(UIBarButtonItem *)barButtonItem {
	[self.firstResponder resignFirstResponder];
	[self setFirstResponder:nil];

	if (IS_IPHONE) {
		[self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];

		if ([_moreMenuView superview]) {
			[self dismissMoreMenu];
			[self rightButtonMoreButton];
		}
	} else {
		A3RootViewController_iPad *rootViewController = self.A3RootViewController;
		[self enableControls: rootViewController.showLeftView ];
		[self.A3RootViewController toggleLeftMenuViewOnOff];
	}
}

- (void)moreButtonAction:(UIBarButtonItem *)button {
	[self.firstResponder resignFirstResponder];
	[self setFirstResponder:nil];

	[self rightBarButtonDoneButton];

	_moreMenuButtons = @[[self instructionHelpButton], self.shareButton, [self historyButton:[CurrencyHistory class] ], self.settingsButton];
	_moreMenuView = [self presentMoreMenuWithButtons:_moreMenuButtons tableView:self.tableView];
	_isShowMoreMenu = YES;
}

- (void)doneButtonAction:(id)button {
	[self dismissMoreMenu];
}

- (void)dismissMoreMenu {
	if ( !_isShowMoreMenu || IS_IPAD ) return;

	[self moreMenuDismissAction:[[self.view gestureRecognizers] lastObject] ];
}

- (void)moreMenuDismissAction:(UITapGestureRecognizer *)gestureRecognizer {
	if (!_isShowMoreMenu) return;

	_isShowMoreMenu = NO;

	[self.view removeGestureRecognizer:gestureRecognizer];
	[self rightButtonMoreButton];
	[self dismissMoreMenuView:_moreMenuView scrollView:self.tableView];
}

- (NSString *)stringFromNumber:(NSNumber *)value withCurrencyCode:(NSString *)currencyCode isShare:(BOOL)isShare {
	NSNumberFormatter *formatter = [NSNumberFormatter new];
	[formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	[formatter setCurrencyCode:currencyCode];
    
    if (!isShare && IS_IPHONE) {
		[formatter setCurrencySymbol:@""];
    }

	NSString *string = [formatter stringFromNumber:value];
	FNLOG(@"%@", string);
	return [string stringByTrimmingSpaceCharacters];
}

- (void)shareButtonAction:(id)sender {
	[self clearEverything];

	[self enableControls:NO];
	[self shareAll:sender];
}

- (void)historyButtonAction:(UIButton *)button {
	[self clearEverything];

	_historyViewController = [[A3CurrencyHistoryViewController alloc] initWithNibName:nil bundle:nil];

	if (IS_IPHONE) {
		_modalNavigationController = [[UINavigationController alloc] initWithRootViewController:_historyViewController];
		[self presentViewController:_modalNavigationController animated:YES completion:NULL];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(historyViewControllerDidDismiss) name:A3NotificationChildViewControllerDidDismiss object:_historyViewController];
	} else {
		[self enableControls:NO];
		[self.A3RootViewController presentRightSideViewController:_historyViewController];
	}
}

- (void)historyViewControllerDidDismiss {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationChildViewControllerDidDismiss object:_historyViewController];
	_modalNavigationController = nil;
	_historyViewController = nil;
}

- (void)settingsButtonAction:(UIButton *)button {
	[self clearEverything];

	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"A3CurrencySettings" bundle:nil];
	_settingsViewController = [storyboard instantiateInitialViewController];
	_settingsViewController.delegate = self;

	if (IS_IPHONE) {
		_modalNavigationController = [[UINavigationController alloc] initWithRootViewController:_settingsViewController];
		[self presentViewController:_modalNavigationController animated:YES completion:NULL];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingsViewControllerDidDismiss) name:A3NotificationChildViewControllerDidDismiss object:_settingsViewController];

	} else {
		[self enableControls:NO];
		[self.A3RootViewController presentRightSideViewController:_settingsViewController];
	}
}

- (void)settingsViewControllerDidDismiss {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationChildViewControllerDidDismiss object:_settingsViewController];
	_settingsViewController = nil;
	_modalNavigationController = nil;
}

- (void)currencyConfigurationChanged {
	[self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refreshControlValueChanged {
	if (![[A3AppDelegate instance].reachability isReachable]) {
		[self.refreshControl endRefreshing];

		[self alertInternetConnectionIsNotAvailable];
		return;
	}
	if (self.firstResponder) {
		[self.refreshControl endRefreshing];
		return;
	}
	if (_isUpdating) {
		return;
	}
	NSAttributedString *updating = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Updating", @"Updating") attributes:[self refreshControlTitleAttribute]];
	self.refreshControl.attributedTitle = updating;
	[self updateCurrencyRatesWithAnimation:NO ];
}

- (void)updateCurrencyRatesWithAnimation:(BOOL)animate {
	if (_isUpdating) return;

	_isUpdating = YES;
	_updateStartDate = [NSDate date];

	[self dismissMoreMenu];

	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currencyRatesUpdated) name:A3NotificationCurrencyRatesUpdated object:nil];


	if (!self.firstResponder && animate) {
		[self.refreshControl beginRefreshing];
	}

	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[A3CurrencyDataManager updateCurrencyRatesInContext:[A3AppDelegate instance].cacheStoreManager.context];
	});
}

- (void)currencyRatesUpdated {
	_isUpdating = NO;

	[[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:A3CurrencyUpdateDate];
	[[NSUserDefaults standardUserDefaults] synchronize];

	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

	NSMutableArray *visibleRows = [[self.tableView indexPathsForVisibleRows] mutableCopy];
	NSUInteger firstRowIdx = [visibleRows indexOfObjectPassingTest:^BOOL(NSIndexPath *obj, NSUInteger idx, BOOL *stop) {
		return obj.row == 0;
	}];
	if (firstRowIdx != NSNotFound) {
		[visibleRows removeObjectAtIndex:firstRowIdx];
	}
	if ([self.swipedCells count]) {
		NSIndexPath *swipedCellIndexPath = [self.tableView indexPathForCell:[self.swipedCells anyObject]];
		NSUInteger swipedCellIndex = [visibleRows indexOfObjectPassingTest:^BOOL(NSIndexPath *obj, NSUInteger idx, BOOL *stop) {
			return obj.row == swipedCellIndexPath.row;
		}];
		if (swipedCellIndex != NSNotFound) {
			[visibleRows removeObjectAtIndex:swipedCellIndex];
		}
	}

	[self.tableView reloadRowsAtIndexPaths:visibleRows withRowAnimation:UITableViewRowAnimationNone];

	if ([self.refreshControl isRefreshing]) {
		NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:_updateStartDate];
		if (interval < 1.5) {
			double delayInSeconds = 1.5 - interval;
			dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
			dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
				[self.refreshControl endRefreshing];
				[self reloadUpdateDateLabel];
			});
		} else {
			[self.refreshControl endRefreshing];
			[self reloadUpdateDateLabel];
		}
	}
}

- (void)reloadUpdateDateLabel {
	double delayInSeconds = 0.2;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		[self setRefreshControlTitle];
	});
}

- (void)setRefreshControlTitle {
	NSDate *updateDate = [[NSUserDefaults standardUserDefaults] objectForKey:A3CurrencyUpdateDate];
	if (updateDate) {
		NSString *updateTitle = [NSString stringWithFormat:NSLocalizedString(@"Updated %@", @"Updated %@"), [updateDate timeAgo]];

		NSMutableAttributedString *updateString = [[NSMutableAttributedString alloc] initWithString:updateTitle
																						 attributes:[self refreshControlTitleAttribute]];
		self.refreshControl.attributedTitle = updateString;
	}
}

- (NSDictionary *)refreshControlTitleAttribute {
	return @{
			NSFontAttributeName:[UIFont systemFontOfSize:12],
			NSForegroundColorAttributeName:[UIColor colorWithRed:142.0/255.0 green:142.0/255.0 blue:147.0/255.0 alpha:1.0]
	};
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	[self setRefreshControlTitle];
}

#pragma mark Instruction Related

static NSString *const A3V3InstructionDidShowForCurrency = @"A3V3InstructionDidShowForCurrency";

- (void)setupInstructionView
{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:A3V3InstructionDidShowForCurrency]) {
        [self showInstructionView];
    }
}

- (void)instructionHelpButtonAction:(id)sender {
    [self dismissMoreMenu];
    [self showInstructionView];
}

- (void)showInstructionView
{
	[[NSUserDefaults standardUserDefaults] setBool:YES forKey:A3V3InstructionDidShowForCurrency];
	[[NSUserDefaults standardUserDefaults] synchronize];

    UIStoryboard *instructionStoryBoard = [UIStoryboard storyboardWithName:IS_IPHONE ? A3StoryboardInstruction_iPhone : A3StoryboardInstruction_iPad bundle:nil];
    _instructionViewController = [instructionStoryBoard instantiateViewControllerWithIdentifier:@"CurrencyConverter"];
    self.instructionViewController.delegate = self;
    [self.navigationController.view addSubview:self.instructionViewController.view];
    self.instructionViewController.view.frame = self.navigationController.view.frame;
    self.instructionViewController.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight;
}

- (void)dismissInstructionViewController:(UIView *)view
{
    [self.instructionViewController.view removeFromSuperview];
    self.instructionViewController = nil;
}

#pragma mark - Data Management

- (NSMutableArray *)favorites {
	if (!_favorites) {
		NSArray *array = [[NSUserDefaults standardUserDefaults] objectForKey:A3CurrencyUserDefaultsFavorites];
		_favorites = [array mutableCopy];
		[self addEqualItem];
	}
	return _favorites;
}

- (void)addEqualItem {
	[_favorites insertObject:self.equalItem atIndex:1];
}

- (NSMutableDictionary *)equalItem {
	if (!_equalItem) {
		_equalItem = [@{@"title":@"=",@"order":@""} mutableCopy];
	}
	return _equalItem;
}

- (NSMutableDictionary *)textFields {
	if (!_textFields) {
		_textFields = [NSMutableDictionary new];
	}
	return _textFields;
}

- (void)makeDecisionFooterView {
	CGFloat contentsHeight = self.tableView.rowHeight * [self.favorites count];
	CGFloat viewHeight = self.tableView.frame.size.height - self.tableView.contentInset.top;
	self.tableView.tableFooterView = (contentsHeight >= viewHeight) ? self.footerView : nil;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	[self makeDecisionFooterView];

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
	UITableViewCell *cell;

	if ([self.favorites objectAtIndex:indexPath.row] == self.equalItem) {
		A3CurrencyTVEqualCell *equalCell = [self reusableEqualCellForTableView:tableView];
		cell = equalCell;
	} else if ( [ [self.favorites objectAtIndex:indexPath.row] isKindOfClass:[NSString class] ] ) {
		A3CurrencyTVDataCell *dataCell;
		dataCell = [tableView dequeueReusableCellWithIdentifier:A3CurrencyDataCellID forIndexPath:indexPath];
		if (nil == dataCell) {
			dataCell = [[A3CurrencyTVDataCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:A3CurrencyDataCellID];
			dataCell.menuDelegate = self;
		}

		[self configureDataCell:dataCell atIndexPath:indexPath];

		cell = dataCell;
	}

    return cell;
}

- (void)configureDataCell:(A3CurrencyTVDataCell *)dataCell atIndexPath:(NSIndexPath *)indexPath {
	dataCell.menuDelegate = self;

	NSInteger dataIndex = indexPath.row;

	dataCell.valueField.delegate = self;

	NSString *favorite = self.favorites[dataIndex];
	CurrencyRateItem *favoriteInfo = [[[A3AppDelegate instance] cacheStoreManager] currencyInfoWithCode:favorite];

	[self.textFields setObject:dataCell.valueField forKey:favorite];

	NSNumber *value;
	value = [self lastInputValue];

	if (dataIndex == 0) {
		dataCell.valueField.textColor = [[A3AppDelegate instance] themeColor];
		[dataCell.valueField setEnabled:YES];
		if (IS_IPHONE) {
			dataCell.rateLabel.text = favoriteInfo.currencySymbol;
		} else {
			dataCell.rateLabel.text = @"";
		}
	} else {
		NSString *favoriteZero = nil;
		for (id object in self.favorites) {
			if ([object isKindOfClass:[NSString class]]) {
				favoriteZero = object;
				break;
			}
		}
		CurrencyRateItem *zeroInfo = [[[A3AppDelegate instance] cacheStoreManager] currencyInfoWithCode:favoriteZero];

		float rate = [favoriteInfo.rateToUSD floatValue] / [zeroInfo.rateToUSD floatValue];
		float result = value.floatValue * rate;
		value = @(isnan(result) ? 0.0 : result);

		if (IS_IPHONE) {
			NSString *symbol;
			if ([favoriteInfo.currencySymbol length]) {
				symbol = [NSString stringWithFormat:@"%@, ", favoriteInfo.currencySymbol];
			} else {
				symbol = @"";
			}
			dataCell.rateLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@Rate = %0.4f", @"%@Rate = %0.4f"), symbol, rate];
		} else {
			dataCell.rateLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Rate = %0.4f", @"Rate = %0.4f"), rate];
		}
		dataCell.valueField.textColor = [UIColor blackColor];
		[dataCell.valueField setEnabled:NO];
	}
	if ([[NSUserDefaults standardUserDefaults] currencyShowNationalFlag]) {
		dataCell.flagImageView.image = [UIImage imageNamed:favoriteInfo.flagImageName];
	} else {
		dataCell.flagImageView.image = nil;
	}
	dataCell.valueField.text = [self stringFromNumber:value withCurrencyCode:favorite isShare:NO];
	dataCell.codeLabel.text = favorite;
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
	return [[self.favorites objectAtIndex:indexPath.row] isKindOfClass:[NSString class]];
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
	id fromObject = _favorites[fromIndexPath.row];
	[_favorites removeObjectAtIndex:fromIndexPath.row];
	[_favorites insertObject:fromObject atIndex:toIndexPath.row];
}

#pragma mark -- A3SearchViewDelegate / A3CurrencySelectViewController delegate

- (void)willDismissSearchViewController {
	NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)searchViewController:(UIViewController *)viewController itemSelectedWithItem:(NSString *)selectedCode {
	if (_isAddingCurrency) {
			[_favorites addObject:selectedCode];
			[A3CurrencyDataManager saveFavorites:_favorites];
			NSInteger insertIdx = [self.favorites count] - 1;
			[self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:insertIdx inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
	} else {
		[_favorites replaceObjectAtIndex:_selectedRow withObject:selectedCode];
		NSString *favorite = self.favorites[_selectedRow];
		[A3CurrencyDataManager saveFavorites:_favorites];

		[self replaceTextFieldKeyFrom:favorite to:selectedCode];
		[self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_selectedRow inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];

		double delayInSeconds = 0.3;
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
		dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
			[self.tableView reloadRowsAtIndexPaths:[self.tableView indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationNone];
		});
	}
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.firstResponder) {
		[self.firstResponder resignFirstResponder];
		[self setFirstResponder:nil];
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		return;
	}

	if ([self.swipedCells.allObjects count]) {
		[self unSwipeAll];
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		return;
	}

	[self clearEverything];

	id object = self.favorites[indexPath.row];
	if (object != _equalItem) {
		_selectedRow = indexPath.row;
		_isAddingCurrency = NO;

		[self enableControls:NO];

		_currencySelectViewController = [self currencySelectViewControllerWithSelectedCurrency:_selectedRow];
		if (IS_IPHONE) {
			_currencySelectViewController.shouldPopViewController = YES;
			[self.navigationController pushViewController:_currencySelectViewController animated:YES];
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currencySelectViewDidDismiss) name:A3NotificationChildViewControllerDidDismiss object:_currencySelectViewController];
		} else {
			[self.A3RootViewController presentRightSideViewController:_currencySelectViewController];
		}
	} else {
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
	}
}

- (void)currencySelectViewDidDismiss {
	FNLOG();
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationChildViewControllerDidDismiss object:_currencySelectViewController];
	_currencySelectViewController = nil;
}

- (void)plusButtonAction:(UIButton *)button {
	if (self.firstResponder) {
		[self.firstResponder resignFirstResponder];
		[self setFirstResponder:nil];
		return;
	}

	if ([self.swipedCells.allObjects count]) {
		[self unSwipeAll];
		return;
	}

	[self clearEverything];

	_isAddingCurrency = YES;

	[self enableControls:NO];

	_currencySelectViewController = [self currencySelectViewControllerWithSelectedCurrency:-1];
	if (IS_IPHONE) {
		_currencySelectViewController.shouldPopViewController = NO;
		_currencySelectViewController.showCancelButton = YES;
		_modalNavigationController = [[UINavigationController alloc] initWithRootViewController:_currencySelectViewController];
		[self presentViewController:_modalNavigationController animated:YES completion:NULL];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currencySelectViewDidDismiss) name:A3NotificationChildViewControllerDidDismiss object:_currencySelectViewController];
	} else {
		[self.A3RootViewController presentRightSideViewController:_currencySelectViewController];
	}
}

/*! Push CurrencySelectViewController filling with selected currency code
 * \param selectedIndex, selected row required or -1 for nothing
 * \returns void
 */
- (A3CurrencySelectViewController *)currencySelectViewControllerWithSelectedCurrency:(NSInteger)selectedIndex {
	A3CurrencySelectViewController *viewController = [[A3CurrencySelectViewController alloc] initWithNibName:nil bundle:nil];
	viewController.delegate = self;
	viewController.allowChooseFavorite = NO;
	if (selectedIndex >= 0 && selectedIndex < ([_favorites count] - 1) ) {
		NSString *selectedItem = _favorites[selectedIndex];
		viewController.placeHolder = selectedItem;
	}
	return viewController;
}

#pragma mark - FMMoveTableView

- (void)moveTableView:(FMMoveTableView *)tableView moveRowFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	id fromObject = _favorites[fromIndexPath.row];
	[_favorites removeObjectAtIndex:fromIndexPath.row];
	[_favorites insertObject:fromObject atIndex:toIndexPath.row];

	dispatch_async(dispatch_get_main_queue(), ^{
		NSInteger equalIndex;
		equalIndex = [_favorites indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
			return [obj isEqual:self.equalItem];
		}];

		if (equalIndex != 1) {
			id movingObject = [_favorites objectAtIndex:equalIndex];
			[_favorites removeObjectAtIndex:equalIndex];
			[_favorites insertObject:movingObject atIndex:1];

			[self.tableView moveRowAtIndexPath:[NSIndexPath indexPathForRow:equalIndex inSection:0] toIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
			if (equalIndex == 0) {
				[self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]]  withRowAnimation:UITableViewRowAnimationNone];
			}
		}

		if (fromIndexPath.row == 0 || toIndexPath.row == 0) {
			double delayInSeconds = 0.7;
			dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
			dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
				[self.tableView reloadData];
			});
		}
	});
}

#pragma mark -- UITextField delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [self dismissMoreMenu];

	NSString *favorite = self.favorites[0];

	if (textField == _textFields[favorite]) {
		self.previousValue = textField.text;

		[self.refreshControl endRefreshing];
		[self.tableView scrollsToTop];
		[self unSwipeAll];

		textField.text = @"";

		A3NumberKeyboardViewController *keyboardVC = [self simpleNumberKeyboard];
		self.numberKeyboardViewController = keyboardVC;
		self.numberKeyboardViewController.currencyCode = self.favorites[0];
		self.numberKeyboardViewController.keyboardType = A3NumberKeyboardTypeCurrency;
		keyboardVC.textInputTarget = textField;
		keyboardVC.delegate = self;
		self.numberKeyboardViewController = keyboardVC;
		textField.inputView = [keyboardVC view];

		[self setFirstResponder:textField];

		return YES;
	} else {
		[self.firstResponder resignFirstResponder];
		[self setFirstResponder:nil];

		// shifted 0 : shift self
		// shifted 1 and it is me. unshift self
		// shifted 1 and it is not me. unshift him and shift me.
		NSArray *swipped = self.swipedCells.allObjects;
		if (![swipped count]) {
			CGPoint center = [textField convertPoint:textField.center toView:nil];
			NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:[self.view convertPoint:center fromView:nil]];
			UITableViewCell <A3FMMoveTableViewSwipeCellDelegate> *cell = (UITableViewCell <A3FMMoveTableViewSwipeCellDelegate> *) [self.tableView cellForRowAtIndexPath:indexPath];

			if (cell) {
				[self shiftLeft:cell];
			} else {
				FNLOG(@"Attention : Cell is nil");
			}
		} else {
			[self unSwipeAll];
		}
		return NO;
	}
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	_calculatorTargetTextField = textField;
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:textField];
	[self addNumberKeyboardNotificationObservers];
}

- (void)textFieldDidChange:(NSNotification *)notification {
	UITextField *textField = [notification object];
	[self updateTextFieldsWithSourceTextField:textField];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:textField];
	[self removeNumberKeyboardNotificationObservers];

	[self setFirstResponder:nil];
	[self setNumberKeyboardViewController:nil];

	if (_cancelInputNewCloudDataReceived) {
		_cancelInputNewCloudDataReceived = NO;
		return;
	}
	BOOL valueChanged = NO;
	if (![textField.text length]) {
		textField.text = self.previousValue;
	} else {
		double value = [[self.decimalFormatter numberFromString:textField.text] doubleValue];
		textField.text = [self stringFromNumber:@(value) withCurrencyCode:self.favorites[0] isShare:NO];
		if (![textField.text isEqualToString:self.previousValue]) {
			valueChanged = YES;
		}
	}
	[self updateTextFieldsWithSourceTextField:textField];

	if (valueChanged) {
		[self putHistoryWithValue:@([self.previousValue floatValueEx])];
		[[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
	}
}

#pragma mark - KeyboardViewControllerDelegate

- (void)A3KeyboardController:(id)controller clearButtonPressedTo:(UIResponder *)keyInputDelegate {
	UITextField *textField = (UITextField *) self.numberKeyboardViewController.textInputTarget;
	if ([textField isKindOfClass:[UITextField class]]) {
		textField.text = @"";
		self.previousValue = [self stringFromNumber:@1 withCurrencyCode:self.favorites[0] isShare:NO];
	}
}

- (void)A3KeyboardController:(id)controller doneButtonPressedTo:(UIResponder *)keyInputDelegate {
	[self.numberKeyboardViewController.textInputTarget resignFirstResponder];
}

#pragma mark - Number Keyboard Calculator Button Notification

- (void)calculatorButtonAction {
	_calculatorTargetTextField = (UITextField *) self.firstResponder;
	[self.firstResponder resignFirstResponder];
	A3CalculatorViewController *viewController = [self presentCalculatorViewController];
	viewController.delegate = self;
}

- (void)calculatorDidDismissWithValue:(NSString *)value {
	BOOL valueChanged = NO;
	NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
	[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];

	_calculatorTargetTextField.text = [self stringFromNumber:[numberFormatter numberFromString:value] withCurrencyCode:self.favorites[0] isShare:NO];

	if (![_calculatorTargetTextField.text isEqualToString:self.previousValue]) {
		valueChanged = YES;
	}
	[self updateTextFieldsWithSourceTextField:_calculatorTargetTextField];

	if (valueChanged) {
		[self putHistoryWithValue:@([self.previousValue floatValueEx])];
		[[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
	}
}

- (NSUInteger)indexForCurrencyCode:(NSString *)code {
	NSUInteger targetIndex = [self.favorites indexOfObjectPassingTest:^BOOL(NSString *object, NSUInteger idx, BOOL *stop) {
		if ([object isKindOfClass:[NSMutableDictionary class]]) return NO;
		return ([object isEqualToString:code]);
	}];
	return targetIndex;
}

- (void)updateTextFieldsWithSourceTextField:(UITextField *)textField {
	float fromValue = [textField.text floatValueEx];

	NSDate *updateDate = [NSDate date];
	[[NSUserDefaults standardUserDefaults] setObject:updateDate forKey:A3CurrencyUserDefaultsUpdateDate];
	[[NSUserDefaults standardUserDefaults] setObject:@(fromValue) forKey:A3CurrencyUserDefaultsLastInputValue];
	[[NSUserDefaults standardUserDefaults] synchronize];

	if ([[A3SyncManager sharedSyncManager] isCloudEnabled]) {
		NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
		[store setObject:@(fromValue) forKey:A3CurrencyUserDefaultsLastInputValue];
		[store setObject:updateDate forKey:A3CurrencyUserDefaultsCloudUpdateDate];
		[store synchronize];
	}

	NSInteger fromIndex = 0;
	FNLOG(@"%@", _textFields);

	for (NSString *key in [self.textFields allKeys]) {
		UITextField *targetTextField = _textFields[key];
		if (targetTextField == textField) {
			continue;
		}
		NSString *sourceCurrency = self.favorites[fromIndex];
		NSUInteger targetIndex = [_favorites indexOfObject:key];
		if (targetIndex != NSNotFound) {
			NSString *targetCurrency = self.favorites[targetIndex];
			float rate = [self rateForSource:sourceCurrency target:targetCurrency];
			targetTextField.text = [self stringFromNumber:@(fromValue * rate) withCurrencyCode:targetCurrency isShare:NO];
		}
	}
}

- (float)rateForSource:(NSString *)source target:(NSString *)target {
	return [[A3AppDelegate instance].cacheStoreManager rateForCurrencyCode:target] / [[A3AppDelegate instance].cacheStoreManager rateForCurrencyCode:source];
}

#pragma mark --- Drag and Reorder

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

#pragma mark - A3CurrencyMenuDelegate
- (void)menuAdded {
	[self clearEverything];
}

- (void)swapActionForCell:(UITableViewCell *)cell {
	[self unSwipeAll];

	UITableViewCell<A3FMMoveTableViewSwipeCellDelegate> *swipedCell = (UITableViewCell <A3FMMoveTableViewSwipeCellDelegate> *) cell;
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

#pragma mark - Chart View Controller

- (void)chartActionForCell:(UITableViewCell *)cell {
	[self unSwipeAll];

	A3CurrencyChartViewController *viewController = [[A3CurrencyChartViewController alloc] initWithNibName:@"A3CurrencyChartViewController" bundle:nil];
	viewController.delegate = self;
	viewController.initialValue = [self lastInputValue];
	NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
	NSString *favoriteZero = self.favorites[0], *favorite = self.favorites[indexPath.row == 0 ? 2 : indexPath.row ];
	viewController.sourceCurrencyCode = viewController.originalSourceCode = favoriteZero;
	viewController.targetCurrencyCode = viewController.originalTargetCode = favorite;
	[self.navigationController pushViewController:viewController animated:YES];
}

- (void)replaceTextFieldKeyFrom:(NSString *)oldKey to:(NSString *)newKey {
	id object = _textFields[oldKey];
	if (object) {
		_textFields[newKey] = object;
		[_textFields removeObjectForKey:oldKey];
	}
}

- (void)chartViewControllerValueChangedChartViewController:(A3CurrencyChartViewController *)chartViewController valueChanged:(NSNumber *)newValue newCodes:(NSArray *)newCodesArray {
	if ([newValue doubleValue] != [self.previousValue doubleValue]) {
		[[NSUserDefaults standardUserDefaults] setObject:newValue forKey:A3CurrencyUserDefaultsLastInputValue];
		[[NSUserDefaults standardUserDefaults] synchronize];
		[self putHistoryWithValue:newValue];
	}

	NSMutableArray *reloadingRows = [NSMutableArray new];
	[reloadingRows addObject:[NSIndexPath indexPathForRow:0 inSection:0]];

	CurrencyRateItem *newSource = newCodesArray[0], *newDestination = newCodesArray[1];
	if (![chartViewController.originalSourceCode isEqualToString:newSource.currencyCode]) {
		[self replaceTextFieldKeyFrom:chartViewController.originalSourceCode to:newSource.currencyCode];
	}
	if (![newSource.currencyCode isEqualToString:newDestination.currencyCode] &&
			![newDestination.currencyCode isEqualToString:chartViewController.originalTargetCode]) {
		[self replaceTextFieldKeyFrom:chartViewController.originalTargetCode to:newDestination.currencyCode];

		NSUInteger oldDestinationIndex = [self.favorites indexOfObjectPassingTest:^BOOL(NSString *obj, NSUInteger idx, BOOL *stop) {
			if (![obj isKindOfClass:[NSString class]]) return NO;
			return [obj isEqualToString:chartViewController.originalTargetCode];
		}];
		if (oldDestinationIndex != NSNotFound) {
			NSUInteger indexOfNewCodeInExistingFavorites = [self.favorites indexOfObjectPassingTest:^BOOL(NSString *obj, NSUInteger idx, BOOL *stop) {
				if (![obj isKindOfClass:[NSString class]]) return NO;
				return [obj isEqualToString:newDestination.currencyCode];
			}];
			if (indexOfNewCodeInExistingFavorites != NSNotFound) {
				[_favorites removeObjectAtIndex:indexOfNewCodeInExistingFavorites];
				[A3CurrencyDataManager saveFavorites:_favorites];

				NSIndexPath *indexPathToDelete = [NSIndexPath indexPathForRow:indexOfNewCodeInExistingFavorites inSection:0];
				[self.tableView deleteRowsAtIndexPaths:@[indexPathToDelete] withRowAnimation:UITableViewRowAnimationAutomatic];
			}
			[reloadingRows addObject:[NSIndexPath indexPathForRow:oldDestinationIndex inSection:0]];
		}
	}
	if ([reloadingRows count]) {
		[self.tableView reloadRowsAtIndexPaths:reloadingRows withRowAnimation:UITableViewRowAnimationAutomatic];
	}

	[self updateTextFieldsWithSourceTextField:_textFields[newSource.currencyCode]];
}

#pragma mark --- Share

- (void)shareActionForCell:(UITableViewCell *)cell sender:(id)sender {
	[self unSwipeAll];

	NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
	//NSInteger targetIdx = indexPath.row == 0 ? 2 : indexPath.row;
    NSInteger targetIdx = indexPath.row;
	NSAssert(self.favorites[indexPath.row] != _equalItem, @"Selected row must not the equal cell and/or plus cell");
	[self shareActionForSourceIndex:0 targetIndex:targetIdx sender:sender ];
}

- (void)deleteActionForCell:(UITableViewCell *)cell {
	[self unSwipeAll];

	UITableViewCell<A3FMMoveTableViewSwipeCellDelegate> *swipedCell = (UITableViewCell <A3FMMoveTableViewSwipeCellDelegate> *) cell;
	[swipedCell removeMenuView];

	NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
	NSString *favorite = self.favorites[indexPath.row];
	if ([favorite isKindOfClass:[NSString class]]) {
		[self.textFields removeObjectForKey:favorite];

		[self.favorites removeObjectAtIndex:indexPath.row];
		[A3CurrencyDataManager saveFavorites:_favorites];

		[self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];

		if (indexPath.row == 0) {
			[self.tableView moveRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] toIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];

			double delayInSeconds = 0.3;
			dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
			dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
				[self.tableView reloadRowsAtIndexPaths:[self.tableView indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationMiddle];
			});
		}
	}
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
	// Popover controller, iPad only.
	[self unSwipeAll];

	[self enableControls:YES];

	_sharePopoverController = nil;
}

- (void)shareAll:(id)sender {
	_shareAll = YES;
	_sharePopoverController = [self presentActivityViewControllerWithActivityItems:@[self] fromBarButtonItem:sender];
	if (IS_IPAD) {
		_sharePopoverController.delegate = self;
		[self.navigationItem.rightBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem *buttonItem, NSUInteger idx, BOOL *stop) {
			[buttonItem setEnabled:NO];
		}];
	}
}
// http://itunes.apple.com/us/app/appbox-pro-alarm-clock-wallet/id318404385?mt=8
- (void)shareActionForSourceIndex:(NSUInteger)sourceIdx targetIndex:(NSUInteger)targetIdx sender:(id)sender {
	_shareSourceIndex = sourceIdx;
	_shareTargetIndex = targetIdx;
    if (_shareSourceIndex == 0 && _shareTargetIndex == 0) {
        _shareAll = YES;
    }
    else {
        _shareAll = NO;
    }
	
	UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[self] applicationActivities:nil];
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

- (NSString *)activityViewController:(UIActivityViewController *)activityViewController subjectForActivityType:(NSString *)activityType
{
	if ([activityType isEqualToString:UIActivityTypeMail]) {
		return NSLocalizedString(@"Currency Converter using AppBox Pro", nil);
	}

	return @"";
}

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType
{
	if ([activityType isEqualToString:UIActivityTypeMail]) {
		return [self shareMailMessageWithHeader:NSLocalizedString(@"I'd like to share a conversion with you.", nil)
									   contents:[self stringForShare]
										   tail:NSLocalizedString(@"You can convert more in the AppBox Pro.", nil)];
	}
	else {
        return [[self stringForShare] stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n"];
	}
}

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController
{
	return NSLocalizedString(@"Share Currency Converter Data", @"Share Currency Converter Data");
}

- (NSString *)stringForShare {
	if (_shareAll) {
		NSUInteger idx = 2;
		NSMutableString *resultString = [NSMutableString new];
		for (; idx < [self.favorites count]; idx++) {
			[resultString appendString:[self stringForShareOfSource:0 target:idx]];
		}
		return resultString;
	} else {
		return [self stringForShareOfSource:_shareSourceIndex target:_shareTargetIndex];
	}
}

- (NSString *)stringForShareOfSource:(NSUInteger)sourceIdx target:(NSUInteger)targetIdx {
	NSString *source = self.favorites[sourceIdx], *target = self.favorites[targetIdx];
	float rate = [self rateForSource:source target:target];
	return [NSString stringWithFormat:@"%@ %@ = %@ %@<br/>",
			source,
            [self stringFromNumber:self.lastInputValue withCurrencyCode:source isShare:YES],
			target,
            [self stringFromNumber:@(self.lastInputValue.floatValue * rate) withCurrencyCode:target isShare:YES]];
}

#pragma mark - History

- (NSNumber *)lastInputValue {
	NSNumber *lastInput = [[NSUserDefaults standardUserDefaults] objectForKey:A3CurrencyUserDefaultsLastInputValue];
	_currentValueIsNotFromUser = lastInput == nil;
	return lastInput ? lastInput : @1;
}

- (void)putHistoryWithValue:(NSNumber *)value {
	if ([value doubleValue] == 1.0 && _currentValueIsNotFromUser) {
		return;
	}
	_currentValueIsNotFromUser = NO;

	NSString *baseCurrency = self.favorites[0];
	CurrencyHistory *latestHistory = [CurrencyHistory MR_findFirstOrderedByAttribute:@"updateDate" ascending:NO];

	// Compare code and value.
	if (latestHistory) {
		if ([latestHistory.currencyCode isEqualToString:baseCurrency] &&
				[value isEqualToNumber:latestHistory.value]) {

			FNLOG(@"Does not make new history for same code and value, in history %@, %@", latestHistory.value, value);
			return;
		}
	}

	CurrencyHistory *history = [CurrencyHistory MR_createEntity];
	history.uniqueID = [[NSUUID UUID] UUIDString];
	NSDate *keyDate = [NSDate date];
	history.updateDate = keyDate;
	history.currencyCode = baseCurrency;
	history.rate = @([[A3AppDelegate instance].cacheStoreManager rateForCurrencyCode:baseCurrency]);
	history.value = value;

	NSInteger historyItemCount = MIN([self.favorites count] - 2, 4);
	NSInteger idx = 0;
	NSMutableSet *targets = [[NSMutableSet alloc] init];
	for (; idx < historyItemCount; idx++) {
		CurrencyHistoryItem *item = [CurrencyHistoryItem MR_createEntity];
		item.uniqueID = [[NSUUID UUID] UUIDString];
		item.updateDate = [NSDate date];
		item.historyID = history.uniqueID;
		NSString *favorite = self.favorites[idx + 2];
		item.currencyCode = favorite;
		item.rate = @([[A3AppDelegate instance].cacheStoreManager rateForCurrencyCode:favorite]);
		item.order = [NSString stringWithFormat:@"%010ld", (long)idx];
		[targets addObject:item];
	}

	[[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];

	[self.historyBarButton setEnabled:YES];
}

#pragma mark -- THE END

@end
