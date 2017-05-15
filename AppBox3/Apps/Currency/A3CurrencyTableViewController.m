//
//  A3CurrencyTableViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 7/5/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3CurrencyTableViewController.h"
#import "CurrencyHistory.h"
#import "A3CurrencyTVDataCell.h"
#import "A3AppDelegate.h"
#import "A3NumberKeyboardViewController.h"
#import "UIViewController+NumberKeyboard.h"
#import "A3CurrencyTVEqualCell.h"
#import "NSMutableArray+A3Sort.h"
#import "A3CurrencyDataManager.h"
#import "A3CurrencyChartViewController.h"
#import "A3CurrencySelectViewController.h"
#import "Reachability.h"
#import "A3CurrencySettingsViewController.h"
#import "A3UserDefaults+A3Defaults.h"
#import "CurrencyHistoryItem.h"
#import "UIViewController+MMDrawerController.h"
#import "NSString+conversion.h"
#import "UIViewController+A3Addition.h"
#import "A3CurrencyDataManager.h"
#import "NSDate+TimeAgo.h"
#import "UIViewController+iPad_rightSideView.h"
#import "UIColor+A3Addition.h"
#import "A3CalculatorViewController.h"
#import "A3InstructionViewController.h"
#import "A3SyncManager.h"
#import "A3SyncManager+NSUbiquitousKeyValueStore.h"
#import "CurrencyFavorite.h"
#import "NSManagedObject+extension.h"
#import "UIViewController+tableViewStandardDimension.h"
#import "common.h"
#import "A3YahooCurrency.h"
#import "A3CurrencyViewController.h"

NSString *const A3CurrencySettingsChangedNotification = @"A3CurrencySettingsChangedNotification";

@interface A3CurrencyTableViewController () <FMMoveTableViewDataSource, FMMoveTableViewDelegate,
        UITextFieldDelegate, A3CurrencyMenuDelegate, A3SearchViewControllerDelegate, A3CurrencyChartViewDelegate,
        UIPopoverControllerDelegate, NSFetchedResultsControllerDelegate, UIActivityItemSource, A3CalculatorViewControllerDelegate,
        A3InstructionViewControllerDelegate, A3ViewControllerProtocol, GADNativeExpressAdViewDelegate>

@property(nonatomic, strong) NSMutableArray *favorites;
@property(nonatomic, strong) NSMutableDictionary *equalItem;
@property(nonatomic, strong) NSMutableDictionary *adItem;
@property(nonatomic, strong) CurrencyHistory *history;
@property(nonatomic, strong) NSMutableDictionary *textFields;
@property(nonatomic, strong) NSArray *moreMenuButtons;
@property(nonatomic, strong) UIView *moreMenuView;
@property(nonatomic, strong) UIPopoverController *sharePopoverController;
@property(nonatomic, strong) UIButton *plusButton;
@property(nonatomic, strong) UIView *footerView;
@property(nonatomic, copy) NSString *previousValue;
@property(nonatomic, strong) NSDate *updateStartDate;
@property(nonatomic, weak) UITextField *calculatorTargetTextField;
@property(nonatomic, strong) UINavigationController *modalNavigationController;
@property(nonatomic, strong) A3CurrencySelectViewController *currencySelectViewController;
@property(nonatomic, strong) A3InstructionViewController *instructionViewController;
@property(nonatomic, strong) UIRefreshControl *refreshControl;
@property(nonatomic, strong) UITableViewController *tableViewController;
@property(nonatomic, strong) NSManagedObjectContext *savingContext;
@property(nonatomic, weak) UITextField *editingTextField;
@property(nonatomic, strong) NSNumberFormatter *decimalNumberFormatter;
@property(nonatomic, strong) GADNativeExpressAdView *admobNativeExpressAdView;

@end

@implementation A3CurrencyTableViewController {
    NSUInteger _selectedRow;
    BOOL _isAddingCurrency;
    BOOL _isShowMoreMenu;
    BOOL _isUpdating;
    BOOL _currentValueIsNotFromUser;
    NSUInteger _shareSourceIndex, _shareTargetIndex;
    BOOL _shareAll;
    BOOL _barButtonEnabled;
    BOOL _didFirstTimeRefresh;
    BOOL _isNumberKeyboardVisible;
    BOOL _didPressClearKey;
    BOOL _didPressNumberKey;
    BOOL _didReceiveAds;
}

NSString *const A3CurrencyDataCellID = @"A3CurrencyDataCell";
NSString *const A3CurrencyActionCellID = @"A3CurrencyActionCell";
NSString *const A3CurrencyEqualCellID = @"A3CurrencyEqualCell";
NSString *const A3CurrencyAdCellID = @"A3CurrencyAdCell";

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView.accessibilityIdentifier = @"Currency";

    _barButtonEnabled = YES;

    self.tableView.dataSource = self;
    self.tableView.delegate = self;

    self.title = NSLocalizedString(A3AppName_CurrencyConverter, nil);

    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(refreshControlValueChanged) forControlEvents:UIControlEventValueChanged];

    self.tableViewController = [[UITableViewController alloc] initWithStyle:self.tableView.style];
    self.tableViewController.tableView = self.tableView;
    [self addChildViewController:self.tableViewController];

    [self setupSwipeRecognizers];

    [self.tableView registerClass:[A3CurrencyTableViewCell class] forCellReuseIdentifier:A3CurrencyAdCellID];
    [self.tableView registerClass:[A3CurrencyTVDataCell class] forCellReuseIdentifier:A3CurrencyDataCellID];
    [self.tableView registerNib:[UINib nibWithNibName:@"A3CurrencyTVActionCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:A3CurrencyActionCellID];
    [self.tableView registerNib:[UINib nibWithNibName:@"A3CurrencyTVEqualCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:A3CurrencyEqualCellID];

    self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    self.tableView.rowHeight = 84.0;
    self.tableView.separatorColor = A3UITableViewSeparatorColor;
    self.tableView.separatorInset = UIEdgeInsetsZero;
    if ([self.tableView respondsToSelector:@selector(cellLayoutMarginsFollowReadableWidth)]) {
        self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
    }
    if ([self.tableView respondsToSelector:@selector(layoutMargins)]) {
        self.tableView.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    self.tableView.showsVerticalScrollIndicator = NO;

    UIView *superview = self.view;
    [self.view addSubview:self.plusButton];

    [self.plusButton makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(superview.centerX);
        make.centerY.equalTo(superview.bottom).with.offset(-32);
        make.width.equalTo(@44);
        make.height.equalTo(@44);
    }];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)applicationDidEnterBackground {
    [self dismissNumberKeyboardAnimated:NO];
    [self dismissInstructionViewController:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (!_didFirstTimeRefresh) {
        _didFirstTimeRefresh = YES;

        Reachability *reachability = [Reachability reachabilityForInternetConnection];
        A3UserDefaults *userDefaults = [A3UserDefaults standardUserDefaults];
        if ([[A3UserDefaults standardUserDefaults] currencyAutoUpdate]) {
            if ([reachability isReachableViaWiFi] ||
                    ([userDefaults currencyUseCellularData] && [A3UIDevice hasCellularNetwork])) {
                [self updateCurrencyRatesWithAnimation:NO];
            }
        }
        [self reloadUpdateDateLabel];

        self.tableViewController.refreshControl = self.refreshControl;
    }

    if (IS_IPHONE && IS_PORTRAIT) {
        [self leftBarButtonAppsButton];
    }
    _favorites = nil;

    [self loadRequestAdmobNativeExpressAds];

    [self.tableView reloadData];

    if ([self isMovingToParentViewController]) {
        [self addObserver];
    }
    [self setupInstructionView];
    [self showNavigationBarOn:self.navigationController];

    if ([self.mainViewController.navigationController.navigationBar isHidden]) {
        [self.mainViewController showNavigationBarOn:self.mainViewController.navigationController];
    }
    if (self.instructionViewController) {
        [self.navigationController.view bringSubviewToFront:self.instructionViewController.view];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [self dismissNumberKeyboardAnimated:NO];
    if ([self isMovingFromParentViewController] || [self isBeingDismissed]) {
        FNLOG();
        [self removeObserver];
    }
}

- (void)applicationDidBecomeActive {
    if ([[A3UserDefaults standardUserDefaults] currencyAutoUpdate]) {
        [self updateCurrencyRatesWithAnimation:NO];
    }
}

- (void)cloudDidImportChanges:(NSNotification *)note {
    if (self.editingObject) {
        return;
    }

    _favorites = nil;
    [self favorites];

    [self.tableView reloadData];
    [self enableControls:_barButtonEnabled];
}

- (void)addObserver {
    FNLOG();

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cloudDidImportChanges:) name:A3NotificationCloudCoreDataStoreDidImport object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cloudDidImportChanges:) name:A3NotificationCloudKeyValueStoreDidImport object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingsChanged) name:A3CurrencySettingsChangedNotification object:nil];
    if (IS_IPAD) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rightSideViewWillDismiss) name:A3NotificationRightSideViewWillDismiss object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainMenuViewDidHide) name:A3NotificationMainMenuDidHide object:nil];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(coreDataChanged:) name:NSManagedObjectContextObjectsDidChangeNotification object:[NSManagedObjectContext MR_defaultContext]];
    [self registerContentSizeCategoryDidChangeNotification];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)removeObserver {
    FNLOG();
    [self removeContentSizeCategoryDidChangeNotification];

    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self name:A3NotificationCloudCoreDataStoreDidImport object:nil];
    [notificationCenter removeObserver:self name:A3NotificationCloudKeyValueStoreDidImport object:nil];
    [notificationCenter removeObserver:self name:A3CurrencySettingsChangedNotification object:nil];
    if (IS_IPAD) {
        [notificationCenter removeObserver:self name:A3NotificationRightSideViewWillDismiss object:nil];
        [notificationCenter removeObserver:self name:A3NotificationMainMenuDidHide object:nil];
    }
    [notificationCenter removeObserver:self name:NSManagedObjectContextObjectsDidChangeNotification object:[NSManagedObjectContext MR_defaultContext]];
    [notificationCenter removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [notificationCenter removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)prepareClose {
    if (self.presentedViewController) {
        [self.presentedViewController dismissViewControllerAnimated:NO completion:nil];
    }
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    [self removeObserver];
}

- (void)cleanUp {
    [self dismissInstructionViewController:nil];
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

- (BOOL)resignFirstResponder {
    [self dismissNumberKeyboardAnimated:NO];
    [self.editingObject resignFirstResponder];

    NSString *startingAppName = [[A3UserDefaults standardUserDefaults] objectForKey:kA3AppsStartingAppName];
    if ([startingAppName length] && ![startingAppName isEqualToString:A3AppName_CurrencyConverter]) {
        [self.instructionViewController.view removeFromSuperview];
        self.instructionViewController = nil;
    }
    return [super resignFirstResponder];
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

- (void)enableControls:(BOOL)enable {
    if (!IS_IPAD) return;

    _barButtonEnabled = enable;
    [self.plusButton setEnabled:enable];

    CGRect cellFrame = [self.tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    if (!CGRectEqualToRect(cellFrame, CGRectZero)) {
        A3CurrencyTVDataCell *cell = (A3CurrencyTVDataCell *) [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        cell.valueField.textColor = enable ? [[A3AppDelegate instance] themeColor] : [UIColor colorWithRGBRed:201 green:201 blue:201 alpha:255];
    }
}

- (void)coreDataChanged:(NSNotification *)notification {
    if (IS_IPAD) {
        [_mainViewController.historyBarButton setEnabled:[CurrencyHistory MR_countOfEntities] > 0];
    }
}

- (NSManagedObjectContext *)savingContext {
    if (!_savingContext) {
        _savingContext = [NSManagedObjectContext MR_rootSavingContext];
    }
    return _savingContext;
}

- (UIView *)footerView {
    if (!_footerView) {
        _footerView = [UIView new];
        _footerView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 70);

        UIView *topSeparator = [UIView new];
        topSeparator.layer.borderColor = [UIColor colorWithRed:200.0 / 255.0 green:200.0 / 255.0 blue:200.0 / 255.0 alpha:1.0].CGColor;
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

/**
 *  Reset Intermediate State
 *  Unswipe cell, resign first responder, dismiss more menu
 */
- (void)resetIntermediateState {
    [self.editingObject resignFirstResponder];
    [self setEditingObject:nil];

    [self dismissMoreMenu];
}

- (void)appsButtonAction:(UIBarButtonItem *)barButtonItem {
    [self.editingObject resignFirstResponder];
    [self setEditingObject:nil];

    if (IS_IPHONE) {
        if ([[A3AppDelegate instance] isMainMenuStyleList]) {
            [[A3AppDelegate instance].drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
        } else {
            UINavigationController *navigationController = [A3AppDelegate instance].currentMainNavigationController;
            [navigationController setNavigationBarHidden:YES];
            [navigationController popViewControllerAnimated:YES];
            [navigationController setToolbarHidden:YES];
            [A3AppDelegate instance].homeStyleMainMenuViewController.activeAppName = nil;
        }

        if ([_moreMenuView superview]) {
            [self dismissMoreMenu];
            [self rightButtonMoreButton];
        }
    } else {
        A3RootViewController_iPad *rootViewController = [[A3AppDelegate instance] rootViewController_iPad];
        [self enableControls:rootViewController.showLeftView];
        [[[A3AppDelegate instance] rootViewController_iPad] toggleLeftMenuViewOnOff];
    }
    [[A3AppDelegate instance] presentInterstitialAds];
}

- (void)moreButtonAction:(UIBarButtonItem *)button {
    [self dismissNumberKeyboardAnimated:NO];
    [self.editingObject resignFirstResponder];
    [self setEditingObject:nil];

    [self rightBarButtonDoneButton];

    _moreMenuButtons = @[[self instructionHelpButton], self.shareButton, [self historyButton:[CurrencyHistory class]], self.settingsButton];
    _moreMenuView = [self presentMoreMenuWithButtons:_moreMenuButtons pullDownView:self.tableView];
    _isShowMoreMenu = YES;
}

- (void)doneButtonAction:(id)button {
    [self dismissMoreMenu];
}

- (void)dismissMoreMenu {
    if (!_isShowMoreMenu || IS_IPAD) return;

    [self moreMenuDismissAction:[[self.view gestureRecognizers] lastObject]];
}

- (void)moreMenuDismissAction:(UITapGestureRecognizer *)gestureRecognizer {
    if (!_isShowMoreMenu) return;

    _isShowMoreMenu = NO;

    [self.view removeGestureRecognizer:gestureRecognizer];
    [self rightButtonMoreButton];
    [self dismissMoreMenuView:_moreMenuView pullDownView:self.tableView completion:^{
    }];
}

- (void)shareButtonAction:(id)sender {
    [self dismissNumberKeyboardAnimated:YES];
    [self resetIntermediateState];
    [self unSwipeAll];

    [self enableControls:NO];
    [self shareAll:sender];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refreshControlValueChanged {
    if (![[A3AppDelegate instance].reachability isReachable]) {
        [self.refreshControl endRefreshing];

        [self alertInternetConnectionIsNotAvailable];
        return;
    }
    if (self.editingObject) {
        [self.refreshControl endRefreshing];
        return;
    }
    if (_isUpdating) {
        return;
    }
    NSAttributedString *updating = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Updating", @"Updating") attributes:[self refreshControlTitleAttribute]];
    self.refreshControl.attributedTitle = updating;
    [self updateCurrencyRatesWithAnimation:NO];
}

- (void)updateCurrencyRatesWithAnimation:(BOOL)animate {
    if (_isUpdating) return;

    _isUpdating = YES;
    _updateStartDate = [NSDate date];

    [self dismissMoreMenu];

    if (!self.editingObject && animate && !self.presentedViewController) {
        [self.refreshControl beginRefreshing];
    }

    [self.currencyDataManager updateCurrencyRatesOnSuccess:^{
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

        [self unSwipeAll];
        [self.tableView reloadRowsAtIndexPaths:visibleRows withRowAnimation:UITableViewRowAnimationNone];

        [self finishCurrencyRatesUpdate];
    }                                              failure:^{
        [self finishCurrencyRatesUpdate];
    }];
}

- (void)finishCurrencyRatesUpdate {
    _isUpdating = NO;

    if ([self.refreshControl isRefreshing]) {
        NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:_updateStartDate];
        if (interval < 1.5) {
            double delayInSeconds = 1.5 - interval;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t) (delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
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
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t) (delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        [self setRefreshControlTitle];
    });
}

- (void)setRefreshControlTitle {
    NSDate *updateDate = [[A3UserDefaults standardUserDefaults] objectForKey:A3CurrencyUpdateDate];
    if (updateDate) {
        NSString *updateTitle = [NSString stringWithFormat:NSLocalizedString(@"Updated %@", @"Updated %@"), [updateDate timeAgo]];

        NSMutableAttributedString *updateString = [[NSMutableAttributedString alloc] initWithString:updateTitle
                                                                                         attributes:[self refreshControlTitleAttribute]];
        self.refreshControl.attributedTitle = updateString;
    }
}

- (NSDictionary *)refreshControlTitleAttribute {
    return @{
            NSFontAttributeName: [UIFont systemFontOfSize:12],
            NSForegroundColorAttributeName: [UIColor colorWithRed:142.0 / 255.0 green:142.0 / 255.0 blue:147.0 / 255.0 alpha:1.0]
    };
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self dismissNumberKeyboardAnimated:YES];
    [self setRefreshControlTitle];
}

#pragma mark Instruction Related

static NSString *const A3V3InstructionDidShowForCurrency = @"A3V3InstructionDidShowForCurrency";

- (void)setupInstructionView {
    if (![[A3UserDefaults standardUserDefaults] boolForKey:A3V3InstructionDidShowForCurrency]) {
        [self showInstructionView];
    }
}

- (void)instructionHelpButtonAction:(id)sender {
    [self dismissMoreMenu];
    [self dismissNumberKeyboardAnimated:YES];
    [self showInstructionView];
}

- (void)showInstructionView {
    [[A3UserDefaults standardUserDefaults] setBool:YES forKey:A3V3InstructionDidShowForCurrency];
    [[A3UserDefaults standardUserDefaults] synchronize];

    UIStoryboard *instructionStoryBoard = [UIStoryboard storyboardWithName:IS_IPHONE ? A3StoryboardInstruction_iPhone : A3StoryboardInstruction_iPad bundle:nil];
    _instructionViewController = [instructionStoryBoard instantiateViewControllerWithIdentifier:@"CurrencyConverter"];
    self.instructionViewController.delegate = self;
    [self.navigationController.view addSubview:self.instructionViewController.view];
    self.instructionViewController.view.frame = self.navigationController.view.frame;
    self.instructionViewController.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight;
}

- (void)dismissInstructionViewController:(UIView *)view {
    [self.instructionViewController.view removeFromSuperview];
    self.instructionViewController = nil;
}

#pragma mark - Data Management

- (NSMutableArray *)favorites {
    if (!_favorites) {
        NSArray *array = [CurrencyFavorite MR_findAllSortedBy:A3CommonPropertyOrder ascending:YES inContext:self.savingContext];
        _favorites = [array mutableCopy];
        [self addEqualItem];
        if (_adItem) {
            NSInteger position = [_favorites count] > 3 ? 4 : [_favorites count];
            [_favorites insertObject:_adItem atIndex:position];
        }
    }
    return _favorites;
}

- (void)addEqualItem {
    [_favorites insertObject:self.equalItem atIndex:1];
}

- (NSMutableDictionary *)equalItem {
    if (!_equalItem) {
        _equalItem = [@{@"title": @"=", @"order": @""} mutableCopy];
    }
    return _equalItem;
}

- (NSMutableDictionary *)adItem {
    if (!_adItem) {
        _adItem = [@{@"title": @"Ad", @"order": @""} mutableCopy];
    }
    return _adItem;
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

- (NSNumberFormatter *)decimalNumberFormatter {
    if (!_decimalNumberFormatter) {
        _decimalNumberFormatter = [NSNumberFormatter new];
        _decimalNumberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
        _decimalNumberFormatter.minimumFractionDigits = 2;
    }
    return _decimalNumberFormatter;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    [self makeDecisionFooterView];

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(FMMoveTableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.

    NSInteger numberOfRows = [self.favorites count];

    if (tableView.movingIndexPath && tableView.movingIndexPath.section != tableView.initialIndexPathForMovingRow.section) {
        if (section == tableView.movingIndexPath.section) {
            numberOfRows++;
        } else if (section == tableView.initialIndexPathForMovingRow.section) {
            numberOfRows--;
        }
    }

    return numberOfRows;
}

- (CGFloat)tableView:(FMMoveTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.movingIndexPath != nil) {
        indexPath = [tableView adaptedIndexPathForRowAtIndexPath:indexPath];
    }

    if (_favorites[indexPath.row] == _adItem) {
        return 100;
    }
    return 84;
}

- (UITableViewCell *)tableView:(FMMoveTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;

    if (tableView.movingIndexPath != nil) {
        indexPath = [tableView adaptedIndexPathForRowAtIndexPath:indexPath];
    }
    if ([self.favorites objectAtIndex:indexPath.row] == _equalItem) {
        A3CurrencyTVEqualCell *equalCell = [self reusableEqualCellForTableView:tableView];
        cell = equalCell;
    } else if (_favorites[indexPath.row] == _adItem) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:A3CurrencyAdCellID];
        cell.layoutMargins = UIEdgeInsetsZero;

        [cell addSubview:_admobNativeExpressAdView];

        [_admobNativeExpressAdView remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(cell).insets(UIEdgeInsetsMake(0, 0, 1, 0));
        }];
    } else {
        A3CurrencyTVDataCell *dataCell;
        dataCell = [tableView dequeueReusableCellWithIdentifier:A3CurrencyDataCellID forIndexPath:indexPath];

        [self configureDataCell:dataCell atIndexPath:indexPath];

        cell = dataCell;
    }

    return cell;
}

- (void)configureDataCell:(A3CurrencyTVDataCell *)dataCell atIndexPath:(NSIndexPath *)indexPath {
    dataCell.menuDelegate = self;

    NSInteger dataIndex = indexPath.row;

    dataCell.valueField.delegate = self;

    CurrencyFavorite *favorite = self.favorites[dataIndex];
    NSString *currencyCode = favorite.uniqueID;
    A3YahooCurrency *favoriteInfo = [_currencyDataManager dataForCurrencyCode:currencyCode];

    [self.textFields setObject:dataCell.valueField forKey:currencyCode];

    NSNumber *value;
    value = [self lastInputValue];

    if (dataIndex == 0) {
        dataCell.valueField.textColor = [[A3AppDelegate instance] themeColor];
        [dataCell.valueField setEnabled:YES];
        if (IS_IPHONE) {
            dataCell.rateLabel.text = [_currencyDataManager symbolForCode:currencyCode];
        } else {
            dataCell.rateLabel.text = @"";
        }
    } else {
        NSString *favoriteZero = nil;
        for (CurrencyFavorite *object in self.favorites) {
            if (![object isEqual:_equalItem] && ![object isEqual:_adItem]) {
                favoriteZero = object.uniqueID;
                break;
            }
        }
        A3YahooCurrency *zeroInfo = [_currencyDataManager dataForCurrencyCode:favoriteZero];

        float rate = [favoriteInfo.rateToUSD floatValue] / [zeroInfo.rateToUSD floatValue];
        float result = value.floatValue * rate;
        value = @(isnan(result) ? 0.0 : result);

        if (IS_IPHONE) {
            NSString *symbol = [_currencyDataManager symbolForCode:currencyCode];
            if ([symbol length]) {
                symbol = [NSString stringWithFormat:@"%@, ", symbol];
            } else {
                symbol = @"";
            }
            dataCell.rateLabel.text = [NSString stringWithFormat:@"%@%@ = %@",
                                                                 symbol, NSLocalizedString(@"Rate", @"Rate"), [self.decimalNumberFormatter stringFromNumber:@(rate)]];
        } else {
            dataCell.rateLabel.text = [NSString stringWithFormat:@"%@ = %@",
                            NSLocalizedString(@"Rate", @"Rate"), [self.decimalNumberFormatter stringFromNumber:@(rate)]];
        }
        dataCell.valueField.textColor = [UIColor blackColor];
        [dataCell.valueField setEnabled:NO];
    }
    if ([[A3UserDefaults standardUserDefaults] currencyShowNationalFlag]) {
        dataCell.flagImageView.image = [UIImage imageNamed:[_currencyDataManager flagImageNameForCode:currencyCode]];
    } else {
        dataCell.flagImageView.image = nil;
    }
    dataCell.valueField.text = [_currencyDataManager stringFromNumber:value withCurrencyCode:currencyCode isShare:NO];
    dataCell.codeLabel.text = currencyCode;

    dataCell.accessibilityValue = currencyCode;
    dataCell.accessibilityLabel = NSLocalizedString(@"Currency", @"Currency");
}

- (A3CurrencyTVEqualCell *)reusableEqualCellForTableView:(UITableView *)tableView {
    A3CurrencyTVEqualCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:A3CurrencyEqualCellID];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.editingObject) {
        [self.editingObject resignFirstResponder];
        [self setEditingObject:nil];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }

    if ([self.swipedCells.allObjects count]) {
        [self unSwipeAll];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }

    [self resetIntermediateState];
    [self unSwipeAll];

    id object = self.favorites[indexPath.row];
    if (![object isEqual:_equalItem] && ![object isEqual:_adItem]) {
        [self dismissNumberKeyboardAnimated:YES];

        _selectedRow = indexPath.row;
        _isAddingCurrency = NO;

        [self enableControls:NO];

        _currencySelectViewController = [self currencySelectViewControllerWithSelectedCurrency:_selectedRow];
        if (IS_IPHONE) {
            _currencySelectViewController.shouldPopViewController = YES;
            [self.navigationController pushViewController:_currencySelectViewController animated:YES];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currencySelectViewDidDismiss) name:A3NotificationChildViewControllerDidDismiss object:_currencySelectViewController];
        } else {
            [[[A3AppDelegate instance] rootViewController_iPad] presentRightSideViewController:_currencySelectViewController];
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
    [self dismissNumberKeyboardAnimated:YES];
    if (self.editingObject) {
        [self.editingObject resignFirstResponder];
        [self setEditingObject:nil];
        return;
    }

    if ([self.swipedCells.allObjects count]) {
        [self unSwipeAll];
        return;
    }

    [self resetIntermediateState];
    [self unSwipeAll];

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
        [[[A3AppDelegate instance] rootViewController_iPad] presentRightSideViewController:_currencySelectViewController];
    }
}

/*! Push CurrencySelectViewController filling with selected currency code
 * \param selectedIndex, selected row required or -1 for nothing
 * \returns void
 */
- (A3CurrencySelectViewController *)currencySelectViewControllerWithSelectedCurrency:(NSInteger)selectedIndex {
    A3CurrencySelectViewController *viewController = [[A3CurrencySelectViewController alloc] initWithNibName:nil bundle:nil];
    viewController.delegate = self;
    //viewController.allowChooseFavorite = selectedIndex == 0 ? YES : NO;
    viewController.allowChooseFavorite = YES;
    viewController.isFromCurrencyConverter = YES;

    if (selectedIndex >= 0 && selectedIndex <= ([_favorites count] - 1)) {
        CurrencyFavorite *selectedFavorite = _favorites[selectedIndex];
        NSString *selectedItem = selectedFavorite.uniqueID;
        viewController.selectedCurrencyCode = selectedItem;
    }
    return viewController;
}

#pragma mark - FMMoveTableView

- (BOOL)moveTableView:(FMMoveTableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    id <NSObject> object = self.favorites[indexPath.row];
    return ![object isEqual:_equalItem] && ![object isEqual:_adItem];
}

- (void)moveTableView:(FMMoveTableView *)tableView willMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    FNLOG();
}

- (void)moveTableView:(FMMoveTableView *)tableView moveRowFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    FNLOG();

    [_favorites moveItemInSortedArrayFromIndex:fromIndexPath.row toIndex:toIndexPath.row];
    [self.savingContext MR_saveToPersistentStoreAndWait];

    dispatch_async(dispatch_get_main_queue(), ^{
        [_favorites removeObject:_equalItem];
        [_favorites removeObject:_adItem];

        [_favorites insertObject:_equalItem atIndex:1];
        if (_adItem) {
            NSInteger position = [_favorites count] > 3 ? 4 : [_favorites count];
            [_favorites insertObject:_adItem atIndex:position];
        }
        [self.tableView reloadData];
    });
}

#pragma mark - A3SearchViewDelegate / A3CurrencySelectViewController delegate

- (void)willDismissSearchViewController {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)searchViewController:(UIViewController *)viewController itemSelectedWithItem:(NSString *)selectedCode {

    UITableViewCell *alreadyAddedFavoriteCell = nil;
    for (NSInteger idx = 0; idx < [_favorites count]; idx++) {
        CurrencyFavorite *favorite = [_favorites objectAtIndex:idx];
        if (![favorite respondsToSelector:@selector(uniqueID)] || ![favorite.uniqueID isEqualToString:selectedCode]) {
            continue;
        }

        if (idx == 0) {     // n -> 0
            alreadyAddedFavoriteCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_selectedRow inSection:0]];
        } else {
            if (_selectedRow == 0) {    // 0 -> n
                alreadyAddedFavoriteCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
            } else {      // n -> n
                [self moveTableView:self.tableView moveRowFromIndexPath:[NSIndexPath indexPathForRow:idx inSection:0] toIndexPath:[NSIndexPath indexPathForRow:_selectedRow inSection:0]];
                return;
            }
        }
    }

    if (alreadyAddedFavoriteCell) {
        [self swapActionForCell:alreadyAddedFavoriteCell];
        return;
    }


    CurrencyFavorite *newObject = [CurrencyFavorite MR_createEntityInContext:self.savingContext];
    newObject.uniqueID = selectedCode;

    if (_isAddingCurrency) {
        [newObject assignOrderAsLastInContext:self.savingContext];
        [_favorites addObject:newObject];

        NSInteger insertIdx = [self.favorites count] - 1;
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:insertIdx inSection:0]] withRowAnimation:UITableViewRowAnimationRight];

        [_savingContext MR_saveToPersistentStoreAndWait];
    } else {
        CurrencyFavorite *oldObject = self.favorites[_selectedRow];
        newObject.order = oldObject.order;
        [_favorites replaceObjectAtIndex:_selectedRow withObject:newObject];

        [oldObject MR_deleteEntityInContext:_savingContext];

        [self replaceTextFieldKeyFrom:oldObject.uniqueID to:selectedCode];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_selectedRow inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];

        [_savingContext MR_saveToPersistentStoreAndWait];

        double delayInSeconds = 0.3;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t) (delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
            [self.tableView reloadRowsAtIndexPaths:[self.tableView indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationNone];
        });
    }
}

#pragma mark - UITextField delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [_mainViewController dismissMoreMenu];
    self.tableViewController.refreshControl = nil;

    if (IS_IPHONE && IS_LANDSCAPE) return NO;

    [self dismissMoreMenu];

    CurrencyFavorite *favoriteItem = self.favorites[0];
    NSString *favorite = favoriteItem.uniqueID;

    if (textField == _textFields[favorite]) {
        [self presentNumberKeyboardForTextField:textField];

        return NO;

        return YES;
    } else {
        [self dismissNumberKeyboardAnimated:YES];

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
    [self setEditingObject:textField];

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

    [self setEditingObject:nil];

    BOOL valueChanged = NO;
    if (![textField.text length]) {
        textField.text = self.previousValue;
    } else {
        double value = [[self.decimalFormatter numberFromString:textField.text] doubleValue];
        CurrencyFavorite *favoriteZero = self.favorites[0];
        textField.text = [_currencyDataManager stringFromNumber:@(value) withCurrencyCode:favoriteZero.uniqueID isShare:NO];
        if (![textField.text isEqualToString:self.previousValue]) {
            valueChanged = YES;
        }
    }
    [self updateTextFieldsWithSourceTextField:textField];

    if (valueChanged) {
        [self putHistoryWithValue:@([self.previousValue floatValueEx])];
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    }
    self.tableViewController.refreshControl = self.refreshControl;
}

#pragma mark - KeyboardViewControllerDelegate

- (void)A3KeyboardController:(id)controller clearButtonPressedTo:(UIResponder *)keyInputDelegate {
    _didPressClearKey = YES;
    _didPressNumberKey = NO;
    UITextField *textField = (UITextField *) self.numberKeyboardViewController.textInputTarget;
    if ([textField isKindOfClass:[UITextField class]]) {
        textField.text = [self.decimalFormatter stringFromNumber:@0];
        CurrencyFavorite *favoriteZero = self.favorites[0];
        self.previousValue = [_currencyDataManager stringFromNumber:@1 withCurrencyCode:favoriteZero.uniqueID isShare:NO];
    }
}

- (void)A3KeyboardController:(id)controller doneButtonPressedTo:(UIResponder *)keyInputDelegate {
    [self dismissNumberKeyboardAnimated:YES];
}

- (void)keyboardViewControllerDidValueChange:(A3NumberKeyboardViewController *)vc {
    _didPressNumberKey = YES;
    _didPressClearKey = NO;
    [self updateTextFieldsWithSourceTextField:self.editingTextField];
}

#pragma mark - Number Keyboard Calculator Button Notification

- (void)calculatorButtonAction {
    [self dismissNumberKeyboardAnimated:YES];

    A3CalculatorViewController *viewController = [self presentCalculatorViewController];
    viewController.delegate = self;
}

- (void)calculatorDidDismissWithValue:(NSString *)value {
    BOOL valueChanged = NO;
    NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];

    CurrencyFavorite *favoriteZero = self.favorites[0];
    _calculatorTargetTextField.text = [_currencyDataManager stringFromNumber:[numberFormatter numberFromString:value] withCurrencyCode:favoriteZero.uniqueID isShare:NO];

    if (![_calculatorTargetTextField.text isEqualToString:self.previousValue]) {
        valueChanged = YES;
    }
    [self updateTextFieldsWithSourceTextField:_calculatorTargetTextField];

    if (valueChanged) {
        [self putHistoryWithValue:@([self.previousValue floatValueEx])];
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    }
}

- (void)updateTextFieldsWithSourceTextField:(UITextField *)textField {
    float fromValue = [textField.text floatValueEx];

    [[A3SyncManager sharedSyncManager] setObject:@(fromValue) forKey:A3CurrencyUserDefaultsLastInputValue state:A3DataObjectStateModified];

    NSInteger fromIndex = 0;
    FNLOG(@"%@", _textFields);

    for (NSString *key in [self.textFields allKeys]) {
        UITextField *targetTextField = _textFields[key];
        if (targetTextField == textField) {
            continue;
        }
        CurrencyFavorite *fromCurrency = self.favorites[fromIndex];
        NSString *sourceCurrency = fromCurrency.uniqueID;
        NSUInteger targetIndex = [_favorites indexOfObjectPassingTest:^BOOL(CurrencyFavorite *obj, NSUInteger idx, BOOL *stop) {
            if ([obj isEqual:_equalItem] || [obj isEqual:_adItem]) return NO;
            return [obj.uniqueID isEqualToString:key];
        }];
        if (targetIndex != NSNotFound) {
            CurrencyFavorite *target = self.favorites[targetIndex];
            NSString *targetCurrency = target.uniqueID;
            float rate = [self rateForSource:sourceCurrency target:targetCurrency];
            targetTextField.text = [_currencyDataManager stringFromNumber:@(fromValue * rate) withCurrencyCode:targetCurrency isShare:NO];
        }
    }
}

- (float)rateForSource:(NSString *)source target:(NSString *)target {
    return [[_currencyDataManager dataForCurrencyCode:target].rateToUSD floatValue] / [[_currencyDataManager dataForCurrencyCode:source].rateToUSD floatValue];
}

#pragma mark - A3CurrencyMenuDelegate

- (void)menuAdded {
    [self dismissNumberKeyboardAnimated:YES];
    [self resetIntermediateState];
}

- (NSIndexPath *)indexPathForDataCell:(A3CurrencyTVDataCell *)cell {
    if (![cell isMemberOfClass:[A3CurrencyTVDataCell class]]) return nil;

    NSInteger indexOfRow = [_favorites indexOfObjectPassingTest:^BOOL(CurrencyFavorite *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        return ((obj != (id) _equalItem) && (obj != (id) _adItem) && [obj.uniqueID isEqualToString:cell.codeLabel.text]);
    }];
    if (indexOfRow != NSNotFound) {
        return [NSIndexPath indexPathForRow:indexOfRow inSection:0];
    }
    return nil;
}

- (void)swapActionForCell:(UITableViewCell *)cell {
    [self unSwipeAll];

    UITableViewCell <A3FMMoveTableViewSwipeCellDelegate> *swipedCell = (UITableViewCell <A3FMMoveTableViewSwipeCellDelegate> *) cell;
    [swipedCell removeMenuView];

    NSIndexPath *sourceIndexPath = [self.tableView indexPathForCell:cell];
    if (!sourceIndexPath) {
        sourceIndexPath = [self indexPathForDataCell:(A3CurrencyTVDataCell *) cell];
        if (!sourceIndexPath) {
            return;
        }
    }
    NSIndexPath *targetIndexPath;
    if (sourceIndexPath.row == 0) {
        targetIndexPath = [NSIndexPath indexPathForRow:2 + (_adItem ? 1 : 0) inSection:0];
    } else {
        targetIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    }

    [self.favorites exchangeObjectAtIndex:sourceIndexPath.row withObjectAtIndex:targetIndexPath.row];

    CurrencyFavorite *sourceCurrency = self.favorites[sourceIndexPath.row];
    CurrencyFavorite *targetCurrency = self.favorites[targetIndexPath.row];
    NSString *orderOfSource = sourceCurrency.order;
    sourceCurrency.order = targetCurrency.order;
    targetCurrency.order = orderOfSource;

    [self.savingContext MR_saveToPersistentStoreAndWait];

    [self.tableView reloadRowsAtIndexPaths:@[sourceIndexPath, targetIndexPath] withRowAnimation:UITableViewRowAnimationMiddle];

    double delayInSeconds = 0.3;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t) (delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        [self.tableView reloadData];
    });
}

#pragma mark - Chart View Controller

- (void)chartActionForCell:(UITableViewCell *)cell {
    [self unSwipeAll];

    A3CurrencyChartViewController *viewController = [[A3CurrencyChartViewController alloc] initWithNibName:@"A3CurrencyChartViewController" bundle:nil];
    viewController.delegate = self;
    viewController.currencyDataManager = _currencyDataManager;
    viewController.initialValue = [self lastInputValue];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    CurrencyFavorite *favorite0 = self.favorites[0], *favoriteN = self.favorites[indexPath.row == 0 ? 2 + (_adItem ? 1 : 0) : indexPath.row];
    NSString *favoriteZero = favorite0.uniqueID, *favorite = favoriteN.uniqueID;
    viewController.originalSourceCode = favoriteZero;
    viewController.originalTargetCode = favorite;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)replaceTextFieldKeyFrom:(NSString *)oldKey to:(NSString *)newKey {
    id object = _textFields[oldKey];
    if (object) {
        _textFields[newKey] = object;
        [_textFields removeObjectForKey:oldKey];
    }
}

- (void)chartViewControllerValueChangedChartViewController:(A3CurrencyChartViewController *)chartViewController valueChanged:(NSNumber *)newValue {
    if ([newValue doubleValue] != [self.previousValue doubleValue]) {
        [[A3SyncManager sharedSyncManager] setObject:newValue forKey:A3CurrencyUserDefaultsLastInputValue state:A3DataObjectStateModified];
        [self putHistoryWithValue:newValue];
    }

    [self updateTextFieldsWithSourceTextField:_textFields[chartViewController.originalSourceCode]];
}

#pragma mark - Share

- (void)shareActionForCell:(UITableViewCell *)cell sender:(id)sender {
    [self unSwipeAll];

    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    //NSInteger targetIdx = indexPath.row == 0 ? 2 : indexPath.row;
    NSInteger targetIdx = indexPath.row;
    [self shareActionForSourceIndex:0 targetIndex:targetIdx sender:sender];
}

- (void)deleteActionForCell:(UITableViewCell *)cell {
    [self unSwipeAll];

    UITableViewCell <A3FMMoveTableViewSwipeCellDelegate> *swipedCell = (UITableViewCell <A3FMMoveTableViewSwipeCellDelegate> *) cell;
    [swipedCell removeMenuView];

    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if (!indexPath) {
        return;
    }
    NSInteger numberOfItems = [_favorites count];
    if (_adItem && [_favorites containsObject:_adItem]) numberOfItems--;
    if (_equalItem && [_favorites containsObject:_equalItem]) numberOfItems--;
    if (numberOfItems <= 2) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:NSLocalizedString(@"You need two units at least to convert values.", nil)
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    CurrencyFavorite *favorite = self.favorites[indexPath.row];
    NSString *deletingFavoriteID = favorite.uniqueID;

    if (deletingFavoriteID) {
        [self.textFields removeObjectForKey:deletingFavoriteID];

        CurrencyFavorite *deletingObject = self.favorites[indexPath.row];
        [self.favorites removeObjectAtIndex:indexPath.row];

        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];

        [deletingObject MR_deleteEntityInContext:self.savingContext];
        [self.savingContext MR_saveToPersistentStoreAndWait];

        if (indexPath.row == 0) {
            _favorites = nil;

            [self.tableView moveRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] toIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];

            double delayInSeconds = 0.3;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t) (delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
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

#pragma mark - Share

- (void)shareAll:(id)sender {
    _shareAll = YES;
    _sharePopoverController =
            [self presentActivityViewControllerWithActivityItems:@[self]
                                               fromBarButtonItem:sender
                                               completionHandler:^() {
                                                   [self unSwipeAll];
                                                   [self enableControls:YES];
                                               }];
    _sharePopoverController.delegate = self;
    if (IS_IPAD) {
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
    } else {
        _shareAll = NO;
    }

    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[self] applicationActivities:nil];
    if (IS_IPHONE) {
        [self presentViewController:activityController animated:YES completion:nil];
    } else {
        _sharePopoverController = [[UIPopoverController alloc] initWithContentViewController:activityController];
        UIView *view = (UIView *) sender;
        FNLOGRECT(view.frame);
        CGRect rect = [view convertRect:view.frame toView:self.view];
        rect.origin.x -= 144.0;
        [_sharePopoverController presentPopoverFromRect:rect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
        _sharePopoverController.delegate = self;
    }
}

- (NSString *)activityViewController:(UIActivityViewController *)activityViewController subjectForActivityType:(NSString *)activityType {
    if ([activityType isEqualToString:UIActivityTypeMail]) {
        return NSLocalizedString(@"Currency Converter using AppBox Pro", nil);
    }

    return @"";
}

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType {
    if ([activityType isEqualToString:UIActivityTypeMail]) {
        return [self shareMailMessageWithHeader:NSLocalizedString(@"I'd like to share a conversion with you.", nil)
                                       contents:[self stringForShare]
                                           tail:NSLocalizedString(@"You can convert more in the AppBox Pro.", nil)];
    } else {
        return [[self stringForShare] stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n"];
    }
}

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController {
    return NSLocalizedString(@"Share Currency Converter Data", @"Share Currency Converter Data");
}

- (NSString *)stringForShare {
    if (_shareAll) {
        NSUInteger idx = 2 + (_adItem ? 1 : 0);
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
    CurrencyFavorite *sourceFavorite = self.favorites[sourceIdx], *targetFavorite = self.favorites[targetIdx];
    NSString *source = sourceFavorite.uniqueID, *target = targetFavorite.uniqueID;
    float rate = [self rateForSource:source target:target];
    return [NSString stringWithFormat:@"%@ %@ = %@ %@<br/>",
                                      source,
                                      [_currencyDataManager stringFromNumber:self.lastInputValue withCurrencyCode:source isShare:YES],
                                      target,
                                      [_currencyDataManager stringFromNumber:@(self.lastInputValue.floatValue * rate) withCurrencyCode:target isShare:YES]];
}

#pragma mark - History

- (NSNumber *)lastInputValue {
    NSNumber *lastInput = [[A3SyncManager sharedSyncManager] objectForKey:A3CurrencyUserDefaultsLastInputValue];
    _currentValueIsNotFromUser = lastInput == nil;
    return lastInput ? lastInput : @1;
}

- (void)putHistoryWithValue:(NSNumber *)value {
    if ([value doubleValue] == 1.0 && _currentValueIsNotFromUser) {
        return;
    }
    _currentValueIsNotFromUser = NO;

    CurrencyFavorite *currencyZero = self.favorites[0];
    NSString *baseCurrency = currencyZero.uniqueID;
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
    history.rate = [_currencyDataManager dataForCurrencyCode:baseCurrency].rateToUSD;
    history.value = value;

    NSInteger historyItemCount = MIN([self.favorites count] - 2 - (_adItem ? 1 : 0), 4);
    NSInteger idx = 0;
    NSMutableSet *targets = [[NSMutableSet alloc] init];
    for (; idx < historyItemCount; idx++) {
        CurrencyHistoryItem *item = [CurrencyHistoryItem MR_createEntity];
        item.uniqueID = [[NSUUID UUID] UUIDString];
        item.updateDate = keyDate;
        item.historyID = history.uniqueID;
        CurrencyFavorite *favoriteN = self.favorites[idx + 2 + (_adItem ? 1 : 0)];
        NSString *favorite = favoriteN.uniqueID;
        item.currencyCode = favorite;
        item.rate = [_currencyDataManager dataForCurrencyCode:favorite].rateToUSD;
        item.order = [NSString stringWithFormat:@"%010ld", (long) idx];
        [targets addObject:item];
    }

    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];

    [_mainViewController.historyBarButton setEnabled:YES];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];

    if (IS_IPHONE && IS_LANDSCAPE) {
        [self leftBarButtonAppsButton];
    }

    UIEdgeInsets contentInset = self.tableView.contentInset;
    contentInset.top = 64;
    self.tableView.contentInset = contentInset;

    if (_isNumberKeyboardVisible && self.numberKeyboardViewController.view.superview) {
        UIView *keyboardView = self.numberKeyboardViewController.view;
        CGFloat keyboardHeight = self.numberKeyboardViewController.keyboardHeight;

        FNLOGRECT(self.view.bounds);
        FNLOG(@"%f", keyboardHeight);
        keyboardView.frame = CGRectMake(0, self.view.bounds.size.height - keyboardHeight, self.view.bounds.size.width, keyboardHeight);
        [self.numberKeyboardViewController rotateToInterfaceOrientation:toInterfaceOrientation];
    }
}

#pragma mark - AdMob Ad

- (GADNativeExpressAdView *)admobNativeExpressAdView {
    if (!_admobNativeExpressAdView) {
        CGSize adSize = self.view.bounds.size;
        adSize.height = 100;
        _admobNativeExpressAdView = [[GADNativeExpressAdView alloc] initWithAdSize:GADAdSizeFromCGSize(adSize)];
        _admobNativeExpressAdView.adUnitID = @"ca-app-pub-0532362805885914/4031842545";
        _admobNativeExpressAdView.delegate = self;
        _admobNativeExpressAdView.rootViewController = self;
    }
    return _admobNativeExpressAdView;
}

- (void)loadRequestAdmobNativeExpressAds {
    if (![[A3AppDelegate instance] shouldPresentAd]) return;

    GADRequest *gadRequest = [GADRequest request];
    gadRequest.keywords = @[@"finance", @"money", @"shopping", @"travel"];
    [self.admobNativeExpressAdView loadRequest:gadRequest];
}

- (void)nativeExpressAdViewDidReceiveAd:(GADNativeExpressAdView *)nativeExpressAdView {
    if (_adItem && [_favorites containsObject:_adItem]) {
        return;
    }
    NSInteger position = [_favorites count] > 3 ? 4 : [_favorites count];
    [_favorites insertObject:[self adItem] atIndex:position];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:position inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)nativeExpressAdView:(GADNativeExpressAdView *)nativeExpressAdView didFailToReceiveAdWithError:(GADRequestError *)error {
    FNLOG(@"%@", error.localizedDescription);
}

#pragma mark - Number Keyboard

- (void)presentNumberKeyboardForTextField:(UITextField *)textField {
    if (_isNumberKeyboardVisible) {
        return;
    }

    [self.refreshControl endRefreshing];
    [self.tableView scrollsToTop];
    [self unSwipeAll];

    self.editingTextField = textField;
    _previousValue = textField.text;
    textField.text = [self.decimalFormatter stringFromNumber:@0];

    [self updateTextFieldsWithSourceTextField:textField];

    self.numberKeyboardViewController = [self simpleNumberKeyboard];

    A3NumberKeyboardViewController *keyboardViewController = self.numberKeyboardViewController;
    keyboardViewController.delegate = self;
    keyboardViewController.keyboardType = A3NumberKeyboardTypeCurrency;
    keyboardViewController.textInputTarget = textField;

    CurrencyFavorite *favorite = self.favorites[0];
    keyboardViewController.currencyCode = favorite.uniqueID;

    CGRect bounds = [A3UIDevice screenBoundsAdjustedWithOrientation];
    CGFloat keyboardHeight = keyboardViewController.keyboardHeight;
    UIView *keyboardView = keyboardViewController.view;
    [self.view.superview addSubview:keyboardView];

    [self textFieldDidBeginEditing:textField];

    _didPressClearKey = NO;
    _didPressNumberKey = NO;
    _isNumberKeyboardVisible = YES;

    keyboardView.frame = CGRectMake(0, self.view.bounds.size.height, bounds.size.width, keyboardHeight);
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = keyboardView.frame;
        frame.origin.y -= keyboardHeight;
        keyboardView.frame = frame;
    }                completion:^(BOOL finished) {
        [self addNumberKeyboardNotificationObservers];
    }];

}

- (void)dismissNumberKeyboardAnimated:(BOOL)animated {
    if (!_isNumberKeyboardVisible) {
        return;
    }

    UITextField *textField = self.editingTextField;

    if (_didPressClearKey) {
        textField.text = @"0";
    } else if (!_didPressNumberKey) {
        textField.text = _previousValue;
    }

    [self textFieldDidEndEditing:textField];

    A3NumberKeyboardViewController *keyboardViewController = self.numberKeyboardViewController;
    UIView *keyboardView = keyboardViewController.view;

    void (^completion)() = ^{
        [keyboardView removeFromSuperview];
        self.numberKeyboardViewController = nil;
        _isNumberKeyboardVisible = NO;
    };

    if (animated) {
        [UIView animateWithDuration:0.3 animations:^{
            CGRect frame = keyboardView.frame;
            frame.origin.y += keyboardViewController.keyboardHeight;
            keyboardView.frame = frame;
        }                completion:^(BOOL finished) {
            completion();
        }];
    } else {
        completion();
    }
}

- (NSNumberFormatter *)currencyFormatterWithCurrencyCode:(NSString *)code {
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];

    [nf setNumberStyle:NSNumberFormatterCurrencyStyle];
    [nf setCurrencyCode:code];
    if (IS_IPHONE) {
        [nf setCurrencySymbol:@""];
    }
    return nf;
}

@end
