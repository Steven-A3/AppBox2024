//
//  A3LoanCalcMainViewController.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 12. 6..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3LoanCalcMainViewController.h"
#import "UIViewController+tableViewStandardDimension.h"
#import "UIViewController+iPad_rightSideView.h"
#import "UIViewController+NumberKeyboard.h"
#import "UIViewController+MMDrawerController.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+LoanCalcAddtion.h"
#import "A3LoanCalcLoanDetailViewController.h"
#import "A3LoanCalcSettingViewController.h"
#import "A3LoanCalcSelectModeViewController.h"
#import "A3LoanCalcSelectFrequencyViewController.h"
#import "A3LoanCalcExtraPaymentViewController.h"
#import "A3LoanCalcHistoryViewController.h"
#import "A3LoanCalcLoanInfoCell.h"
#import "A3LoanCalcTextInputCell.h"
#import "A3LoanCalcLoanGraphCell.h"
#import "A3LoanCalcCompareGraphCell.h"
#import "A3WalletNoteCell.h"
#import "A3WalletDateInputCell.h"
#import "LoanCalcPreference.h"
#import "LoanCalcData+Calculation.h"
#import "LoanCalcString.h"
#import "LoanCalcHistory.h"
#import "LoanCalcComparisonHistory.h"
#import "A3NumberKeyboardViewController.h"
#import "SFKImage.h"
#import "UITableView+utility.h"
#import "NSDate+formatting.h"
#import "NSDateFormatter+A3Addition.h"
#import "LoanCalcComparisonHistory+extension.h"
#import "A3SyncManager.h"
#import "A3SyncManager+NSUbiquitousKeyValueStore.h"
#import "LoanCalcHistory+extension.h"
#import "CGColor+Additions.h"
#import "A3NumberFormatter.h"
#import "NSManagedObject+extension.h"
#import "NSManagedObjectContext+extension.h"
#import "UIViewController+extension.h"
#import "A3AppDelegate.h"
#import "A3UIDevice.h"
#import "A3UserDefaults+A3Addition.h"

#define LoanCalcModeSave @"LoanCalcModeSave"

NSString *const A3LoanCalcSelectCellID = @"A3LoanCalcSelectCell";
NSString *const A3LoanCalcTextInputCellID = @"A3LoanCalcTextInputCell";
NSString *const A3LoanCalcLoanInfoCellID = @"A3LoanCalcLoanInfoCell";
NSString *const A3LoanCalcLoanGraphCellID = @"A3LoanCalcLoanGraphCell";
NSString *const A3LoanCalcLoanNoteCellID = @"A3WalletNoteCell";
NSString *const A3LoanCalcCompareGraphCellID = @"A3LoanCalcCompareGraphCell";
NSString *const A3LoanCalcDateInputCellID = @"A3WalletDateInputCell";
NSString *const A3LoanCalcAdCellID = @"A3LoanCalcAdCell";

@interface A3LoanCalcMainViewController () <LoanCalcHistoryViewControllerDelegate, LoanCalcExtraPaymentDelegate,
		LoanCalcLoanDataDelegate, LoanCalcSelectCalcForDelegate, LoanCalcSelectFrequencyDelegate, A3KeyboardDelegate,
		UITextFieldDelegate, UITextViewDelegate, UIPopoverControllerDelegate, UIActivityItemSource, A3ViewControllerProtocol, GADBannerViewDelegate>

@property (nonatomic, strong) NSArray *moreMenuButtons;
@property (nonatomic, strong) UIView *moreMenuView;
@property (nonatomic, strong) UISegmentedControl *selectSegment;
@property (nonatomic, strong) NSMutableDictionary *controlsEnableInfo;
// Loan mode
@property (nonatomic, weak)	UITextView *currentTextView;
@property (nonatomic, strong) NSMutableArray *advItems;
@property (nonatomic, strong) NSDictionary *startDateItem;
@property (nonatomic, strong) NSMutableDictionary *dateInputItem;
@property (nonatomic, strong) NSDictionary *noteItem;
@property (nonatomic, strong) UIView *advancedTitleView;
// comparison mode
@property (nonatomic, strong) LoanCalcData *loanDataA;
@property (nonatomic, strong) LoanCalcData *loanDataB;
@property (nonatomic, strong) UIPopoverController *sharePopoverController;
@property (nonatomic, strong) UINavigationController *modalNavigationController;
@property (nonatomic, copy) NSString *textBeforeEditing;
@property (nonatomic, copy) UIColor *textColorBeforeEditing;
@property (nonatomic, weak) UITextField *editingTextField;

@end

@implementation A3LoanCalcMainViewController {
	BOOL		_isShowMoreMenu;

	// Loan mode
	BOOL        _isComparisonMode;

	NSDate 		*preDate;
	
	BOOL _didPressClearKey;
	BOOL _didPressNumberKey;
	BOOL _isNumberKeyboardVisible;
    BOOL _didReceiveAds;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	self.dataSectionStartIndex = 0;

    [self makeNavigationBarAppearanceDefault];
    [self makeBackButtonEmptyArrow];
	if (IS_IPAD || [UIWindow interfaceOrientationIsPortrait]) {
		[self leftBarButtonAppsButton];
	} else {
		self.navigationItem.leftBarButtonItem = nil;
		self.navigationItem.hidesBackButton = YES;
	}

    self.navigationItem.hidesBackButton = YES;

    self.navigationItem.titleView = self.selectSegment;
    
    if (IS_IPHONE) {
        UIImage *image = [UIImage imageNamed:@"more"];
        UIBarButtonItem *moreButtonItem = [[UIBarButtonItem alloc] initWithImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStylePlain target:self action:@selector(moreButtonAction:)];

        self.navigationItem.rightBarButtonItem = moreButtonItem;

    } else {
        UIBarButtonItem *share = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"share"] style:UIBarButtonItemStylePlain target:self action:@selector(shareButtonAction:)];
        UIBarButtonItem *history = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"history"] style:UIBarButtonItemStylePlain target:self action:@selector(historyButtonAction:)];
        UIBarButtonItem *setting = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"general"] style:UIBarButtonItemStylePlain target:self action:@selector(settingsButtonAction:)];
        UIBarButtonItem *composeItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(composeButtonAction:)];

        self.navigationItem.rightBarButtonItems = @[setting, history, composeItem, share];
    }
    
    [self.percentFormatter setMaximumFractionDigits:3];
    
    // load data
	[self loadPreviousCalculation];
    
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorColor = [self tableViewSeparatorColor];
	if ([self.tableView respondsToSelector:@selector(cellLayoutMarginsFollowReadableWidth)]) {
		self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
	}
	if ([self.tableView respondsToSelector:@selector(layoutMargins)]) {
		self.tableView.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0);
	}

	self.automaticallyAdjustsScrollViewInsets = YES;
    if SYSTEM_VERSION_LESS_THAN(@"11") {
        self.tableView.contentInset = UIEdgeInsetsMake(64.0, 0, 0, 0);
    }
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 2)];
    line.backgroundColor = [UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0];
    line.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.tableView addSubview:line];
    
    // register setting noti
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingNoti:) name:A3LoanCalcNotificationDownPaymentDisabled object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingNoti:) name:A3LoanCalcNotificationDownPaymentEnabled object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingNoti:) name:A3LoanCalcNotificationExtraPaymentDisabled object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingNoti:) name:A3LoanCalcNotificationExtraPaymentEnabled object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currencyCodeChanged) name:A3LoanCalcCurrencyCodeChanged object:nil];
	if (IS_IPAD) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rightSideViewWillHide:) name:A3NotificationRightSideViewWillDismiss object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainMenuDidHide) name:A3NotificationMainMenuDidHide object:nil];
	}
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cloudStoreDidImport) name:A3NotificationCloudKeyValueStoreDidImport object:nil];

    [self registerContentSizeCategoryDidChangeNotification];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
}

- (void)keyboardDidHide:(NSNotification *)notification {
}

- (void)cloudStoreDidImport {
	// 입력 중에 있다면 refresh를 하지 않는다.
	if (self.editingObject) {
		return;
	}

	[self reloadCurrencyCode];

	[self loadPreviousCalculation];
	[self selectSegmentChanged:self.selectSegment];

	[self.tableView reloadData];
}

- (void)removeObserver {
	[self removeContentSizeCategoryDidChangeNotification];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3LoanCalcNotificationDownPaymentDisabled object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3LoanCalcNotificationDownPaymentEnabled object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3LoanCalcNotificationExtraPaymentDisabled object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3LoanCalcNotificationExtraPaymentEnabled object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3LoanCalcCurrencyCodeChanged object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationCloudKeyValueStoreDidImport object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];

	if (IS_IPAD) {
		[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationRightSideViewWillDismiss object:nil];
		[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationMainMenuDidHide object:nil];
	}
}

- (void)prepareClose {
    if (self.presentedViewController) {
        [self.presentedViewController dismissViewControllerAnimated:NO completion:nil];
    }
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    [self removeObserver];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self reloadCurrencyCode];
    [self refreshRightBarItems];
    [self loadPreviousCalculation];
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	[[UIApplication sharedApplication] setStatusBarHidden:NO];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
	
	if (IS_IPHONE && [UIWindow interfaceOrientationIsPortrait]) {
		[self leftBarButtonAppsButton];
	}
    [self setupBannerViewForAdUnitID:@"ca-app-pub-0532362805885914/5665624549"
                            keywords:@[@"loan", @"finance", @"banking"]
                              adSize:IS_IPHONE ? GADAdSizeFluid : GADAdSizeLeaderboard delegate:self];

	if (SYSTEM_VERSION_LESS_THAN(@"11") && [self isMovingToParentViewController]) {
		self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
	}
	[self keyboardDidHide:nil];
	
	if ([self.navigationController.navigationBar isHidden]) {
		[self showNavigationBarOn:self.navigationController];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	if ([self isMovingFromParentViewController] || [self isBeingDismissed]) {
		FNLOG();
		[self removeObserver];
	}
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];

	if (IS_IPHONE && [UIWindow interfaceOrientationIsLandscape]) {
		[self leftBarButtonAppsButton];
	}
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];

	if (_isNumberKeyboardVisible && self.numberKeyboardViewController.view.superview) {
		UIView *keyboardView = self.numberKeyboardViewController.view;
		CGFloat keyboardHeight = self.numberKeyboardViewController.keyboardHeight;

		FNLOGRECT(self.view.bounds);
		FNLOG(@"%f", keyboardHeight);

		CGRect bounds = [A3UIDevice screenBoundsAdjustedWithOrientation];
		keyboardView.frame = CGRectMake(0, bounds.size.height - keyboardHeight, bounds.size.width, keyboardHeight);
		[self.numberKeyboardViewController rotateToInterfaceOrientation:toInterfaceOrientation];
	}
}

- (void)dealloc {
	[self removeObserver];
}

- (void)currencyCodeChanged {
	[self reloadCurrencyCode];
	[self.tableView reloadData];
}

- (void)contentSizeDidChange:(NSNotification *) notification
{
    [self.tableView reloadData];
}

- (void)rightSideViewWillHide:(NSNotification *)noti
{
    [self enableControls:YES];

    [self refreshRightBarItems];
}

- (void)enableControls:(BOOL) onoff {
	if (!IS_IPAD) return;
	UIBarButtonItem *settingItem = self.navigationItem.rightBarButtonItems[0];
	UIBarButtonItem *historyItem = self.navigationItem.rightBarButtonItems[1];
	UIBarButtonItem *composeItem = self.navigationItem.rightBarButtonItems[2];
	UIBarButtonItem *shareItem = self.navigationItem.rightBarButtonItems[3];

	if (onoff) {
		settingItem.enabled = YES;
		historyItem.enabled = [self.controlsEnableInfo[@"historyItem"] boolValue];
		shareItem.enabled = [self.controlsEnableInfo[@"shareItem"] boolValue];
		composeItem.enabled = YES;
		self.selectSegment.enabled = YES;
		self.selectSegment.tintColor = nil;
		self.navigationItem.leftBarButtonItem.enabled = YES;

		if (!_isComparisonMode) {
			A3LoanCalcLoanGraphCell *cell = (A3LoanCalcLoanGraphCell *) [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
			cell.infoButton.enabled = YES;
			cell.monthlyButton.enabled = YES;
			cell.totalButton.enabled = YES;

			[cell.monthlyButton setTitleColor:[[A3UserDefaults standardUserDefaults] themeColor] forState:UIControlStateNormal];
			[cell.totalButton setTitleColor:[[A3UserDefaults standardUserDefaults] themeColor] forState:UIControlStateNormal];
			if (cell.monthlyButton.layer.borderColor != [UIColor clearColor].CGColor) {
				cell.monthlyButton.layer.borderColor = cell.monthlyButton.currentTitleColor.CGColor;
			}
			if (cell.totalButton.layer.borderColor != [UIColor clearColor].CGColor) {
				cell.totalButton.layer.borderColor = cell.totalButton.currentTitleColor.CGColor;
			}
		}
	}
	else {
		UIColor *disabledColor = [UIColor colorWithRed:201.0 / 255.0 green:201.0 / 255.0 blue:201.0 / 255.0 alpha:1.0];
		[self.controlsEnableInfo setObject:@(historyItem.enabled) forKey:@"historyItem"];
		[self.controlsEnableInfo setObject:@(shareItem.enabled) forKey:@"shareItem"];
		historyItem.enabled = NO;
		shareItem.enabled = NO;
		settingItem.enabled = NO;
		composeItem.enabled = NO;
		self.selectSegment.enabled = NO;
		self.selectSegment.tintColor = disabledColor;
		self.navigationItem.leftBarButtonItem.enabled = NO;

		if (!_isComparisonMode) {
			A3LoanCalcLoanGraphCell *cell = (A3LoanCalcLoanGraphCell *) [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
			cell.infoButton.enabled = NO;
			cell.monthlyButton.enabled = NO;
			cell.totalButton.enabled = NO;

			[cell.monthlyButton setTitleColor:disabledColor forState:UIControlStateDisabled];
			[cell.totalButton setTitleColor:disabledColor forState:UIControlStateDisabled];
			if (cell.monthlyButton.layer.borderColor != [UIColor clearColor].CGColor) {
				cell.monthlyButton.layer.borderColor = disabledColor.CGColor;
			}
			if (cell.totalButton.layer.borderColor != [UIColor clearColor].CGColor) {
				cell.totalButton.layer.borderColor = disabledColor.CGColor;
			}
		}
	}
}

- (void)mainMenuDidHide {
	[self enableControls:YES];
}

- (void)appWillResignActive:(NSNotification*)noti
{
	[self dismissNumberKeyboard];
    [self clearEverything];
}

- (void)settingNoti:(NSNotification *)noti
{
    if ([noti.name isEqualToString:A3LoanCalcNotificationExtraPaymentEnabled]) {
        
        self.loanData.showExtraPayment = YES;
        self.loanDataA.showExtraPayment = YES;
        self.loanDataB.showExtraPayment = YES;
        
        self.loanData.extraPaymentMonthly = @0;

        if (!_isComparisonMode) {
            //[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:3] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:3] withRowAnimation:UITableViewRowAnimationFade];
			[self updateLoanCalculation];
        }
    }
    else if ([noti.name isEqualToString:A3LoanCalcNotificationExtraPaymentDisabled]) {
        self.loanData.extraPaymentMonthly = nil;
        self.loanData.extraPaymentOneTime = nil;
        self.loanData.extraPaymentYearly = nil;
        self.loanData.extraPaymentYearlyDate = nil;
        self.loanData.extraPaymentOneTimeDate = nil;
        self.loanData.showExtraPayment = NO;
        
        self.loanDataA.showExtraPayment = NO;
        self.loanData.extraPaymentMonthly = nil;
        self.loanData.extraPaymentOneTime = nil;
        self.loanData.extraPaymentYearly = nil;
        self.loanData.extraPaymentYearlyDate = nil;
        self.loanData.extraPaymentOneTimeDate = nil;
        
        self.loanDataB.showExtraPayment = NO;
        self.loanData.extraPaymentMonthly = nil;
        self.loanData.extraPaymentOneTime = nil;
        self.loanData.extraPaymentYearly = nil;
        self.loanData.extraPaymentYearlyDate = nil;
        self.loanData.extraPaymentOneTimeDate = nil;
        
        if (!_isComparisonMode) {
            //[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:3] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:3] withRowAnimation:UITableViewRowAnimationFade];
            [self updateLoanCalculation];
        }
    }
    else if ([noti.name isEqualToString:A3LoanCalcNotificationDownPaymentEnabled]) {

		self.calcItems = nil;
        
        self.loanData.showDownPayment = YES;
        self.loanDataA.showDownPayment = YES;
        self.loanDataB.showDownPayment = YES;
        
        self.loanData.downPayment = @0;
        self.loanDataA.downPayment = @0;
        self.loanDataB.downPayment = @0;

        if (!_isComparisonMode) {
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationFade];
			[self updateLoanCalculation];
        }
    }
    else if ([noti.name isEqualToString:A3LoanCalcNotificationDownPaymentDisabled]) {

		self.calcItems = nil;
        
        self.loanData.showDownPayment = NO;
        self.loanData.downPayment = nil;
        
        self.loanDataA.showDownPayment = NO;
        self.loanDataA.downPayment = nil;
        self.loanDataB.showDownPayment = NO;
        self.loanDataB.downPayment = nil;
        
        if (self.loanData.calculationMode == A3LC_CalculationForDownPayment) {
			self.loanData.calculationMode = A3LC_CalculationForRepayment;
        }
        
        if (_loanDataA.calculationMode == A3LC_CalculationForDownPayment) {
            _loanDataA.calculationMode = A3LC_CalculationForRepayment;
        }
        
        if (_loanDataB.calculationMode == A3LC_CalculationForDownPayment) {
            _loanDataB.calculationMode = A3LC_CalculationForRepayment;
        }
        
        if (!_isComparisonMode) {
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 2)] withRowAnimation:UITableViewRowAnimationFade];
            [self updateLoanCalculation];
        }
    }
	[self saveLoanData];
	[self saveLoanDataA];
	[self saveLoanDataB];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refreshRightBarItems {
    if (IS_IPAD) {
        // 히스토리가 존재하는지 체크
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"orderInComparison == nil"];
        LoanCalcHistory *history = [LoanCalcHistory findFirstWithPredicate:predicate sortedBy:@"updateDate" ascending:NO];
        LoanCalcComparisonHistory *comparison = [LoanCalcComparisonHistory findFirstOrderedByAttribute:@"updateDate" ascending:NO];
        
        //self.navigationItem.rightBarButtonItems = @[setting, history, share];
        UIBarButtonItem *historyItem = self.navigationItem.rightBarButtonItems[1];
        UIBarButtonItem *shareItem = self.navigationItem.rightBarButtonItems[3];
        
        if (!history && !comparison) {
            historyItem.enabled = NO;
        }
        else {
            historyItem.enabled = YES;
        }
        
        if (_isComparisonMode) {
            shareItem.enabled = ([_loanDataA calculated] && [_loanDataB calculated]) ? YES:NO;
        } else {
            shareItem.enabled = [self.loanData calculated] ? YES : NO;
        }
        
        // KJH
        UIBarButtonItem *composeItem = self.navigationItem.rightBarButtonItems[2];
        if (_isComparisonMode) {
            composeItem.enabled = [_loanDataA calculated] && [_loanDataB calculated] ? YES : NO;
        }
        else {
            composeItem.enabled = [self.loanData calculated] ? YES : NO;
        }
    }
}

- (NSMutableDictionary *)controlsEnableInfo
{
    if (!_controlsEnableInfo) {
        _controlsEnableInfo = [NSMutableDictionary new];
    }
    
    return _controlsEnableInfo;
}

- (LoanCalcData *)loanData {
	if (!super.loanData) {
		if ([[A3SyncManager sharedSyncManager] objectForKey:A3LoanCalcUserDefaultsLoanDataKey]) {
			NSData *loanData = [[A3SyncManager sharedSyncManager] objectForKey:A3LoanCalcUserDefaultsLoanDataKey];
			super.loanData = [NSKeyedUnarchiver unarchiveObjectWithData:loanData];
		}
		else {
			super.loanData = [[LoanCalcData alloc] init];
			[self initializeLoanData:super.loanData];
		}
	}

	return super.loanData;
}

- (LoanCalcData *)loanDataA
{
    if (!_loanDataA) {
        
        if ([[A3SyncManager sharedSyncManager] objectForKey:A3LoanCalcUserDefaultsLoanDataKey_A]) {
            NSData *loanData = [[A3SyncManager sharedSyncManager] objectForKey:A3LoanCalcUserDefaultsLoanDataKey_A];
            _loanDataA = [NSKeyedUnarchiver unarchiveObjectWithData:loanData];
        }
        else {
            _loanDataA = [[LoanCalcData alloc] init];
            [self initializeLoanData:_loanDataA];
        }
    }
    
    return _loanDataA;
}

- (LoanCalcData *)loanDataB
{
    if (!_loanDataB) {
        
        if ([[A3SyncManager sharedSyncManager] objectForKey:A3LoanCalcUserDefaultsLoanDataKey_B]) {
            NSData *loanData = [[A3SyncManager sharedSyncManager] objectForKey:A3LoanCalcUserDefaultsLoanDataKey_B];
            _loanDataB = [NSKeyedUnarchiver unarchiveObjectWithData:loanData];
        }
        else {
            _loanDataB = [[LoanCalcData alloc] init];
            [self initializeLoanData:_loanDataB];
        }
    }
    
    return _loanDataB;
}

- (NSMutableArray *)calcItems
{
	if (!super.calcItems) {
		NSMutableArray *calcItems;
		if (_isComparisonMode) {
			calcItems = [[NSMutableArray alloc] initWithArray:[LoanCalcMode calculateItemForMode:_loanDataA.calculationMode withDownPaymentEnabled:_loanDataA.showDownPayment]];
		}
		else {
			calcItems = [[NSMutableArray alloc] initWithArray:[LoanCalcMode calculateItemForMode:self.loanData.calculationMode withDownPaymentEnabled:self.loanData.showDownPayment]];
		}
		[super setCalcItems:calcItems];
	}

    return super.calcItems;
}

- (NSMutableArray *)advItems
{
    if (!_advItems) {
        _advItems = [[NSMutableArray alloc] initWithArray:@[self.startDateItem, self.noteItem]];
    }
    
    return _advItems;
}

- (NSDictionary *)startDateItem
{
    if (!_startDateItem) {
        _startDateItem = @{@"Title": NSLocalizedString(@"LoanCalc_Start Date", @"Start Date")};
    }
    
    return _startDateItem;
}

- (NSDictionary *)noteItem
{
    if (!_noteItem) {
        _noteItem = @{@"Title": NSLocalizedString(@"Notes", @"Notes")};
    }
    
    return _noteItem;
}

- (NSMutableDictionary *)dateInputItem
{
    if (!_dateInputItem) {
        _dateInputItem = [NSMutableDictionary dictionaryWithDictionary:@{@"title":@"dateInput", @"order":@""}];
    }
    
    return _dateInputItem;
}

- (void)dateChanged:(UIDatePicker *)sender {

	self.loanData.startDate = sender.date;

    if (!_isComparisonMode) {
        NSIndexPath *ip = [NSIndexPath indexPathForRow:0 inSection:self.loanData.showExtraPayment && self.loanData.frequencyIndex == A3LC_FrequencyMonthly ? 4 : 3];
        [self.tableView reloadRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (UIView *)advancedTitleView
{
    if (!_advancedTitleView) {
        _advancedTitleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, IS_RETINA ? 54.5 : 55.0)];
        _advancedTitleView.backgroundColor = [UIColor clearColor];
		
        UILabel *adv = [[UILabel alloc] initWithFrame:CGRectMake(IS_IPAD ? 28:([[UIScreen mainScreen] scale] > 2 ? 20 : 15), 18.5, 200, 35)];
        adv.text = NSLocalizedString(@"ADVANCED", @"ADVANCED");
        adv.tag = 1234;
        
        UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, 54, self.view.bounds.size.width, IS_RETINA ? 0.5:1)];
        bottomLine.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        bottomLine.tag = 5678;
        bottomLine.backgroundColor = [self tableViewSeparatorColor];
        [_advancedTitleView addSubview:bottomLine];
        
		adv.textColor = [UIColor colorWithRed:109.0/255.0 green:109.0/255.0 blue:114.0/255.0 alpha:1.0];
		bottomLine.hidden = YES;
		
        adv.font = [UIFont systemFontOfSize:14];
        [_advancedTitleView addSubview:adv];
    }
    
    return _advancedTitleView;
}

- (UISegmentedControl *)selectSegment
{
    if (!_selectSegment) {
        _selectSegment = [[UISegmentedControl alloc] initWithItems:@[NSLocalizedString(@"Loan", @"Loan"), NSLocalizedString(@"Comparison", @"Comparison")]];
        
        [_selectSegment setWidth:IS_IPAD ? 150:85 forSegmentAtIndex:0];
        [_selectSegment setWidth:IS_IPAD ? 150:85 forSegmentAtIndex:1];
        
        _selectSegment.selectedSegmentIndex = 0;
        [_selectSegment addTarget:self action:@selector(selectSegmentChanged:) forControlEvents:UIControlEventValueChanged];
    }

    return _selectSegment;
}

- (void)selectSegmentChanged:(UISegmentedControl*) segment
{
	[self dismissNumberKeyboard];
    [self dismissDatePicker];
    [self.editingObject resignFirstResponder];
    
    switch (segment.selectedSegmentIndex) {
        case 0:
        {
            // Loan
            _isComparisonMode = NO;
			self.calcItems = nil;
            [self.tableView reloadData];
			[self updateLoanCalculation];

            break;
        }
        case 1:
        {
            // Comparison
            _isComparisonMode = YES;
			self.calcItems = nil;
            [self.tableView reloadData];
            
            break;
        }
        default:
            break;
    }
    
    [self dismissMoreMenu];
    [self refreshRightBarItems];

	[[A3SyncManager sharedSyncManager] setBool:_isComparisonMode forKey:LoanCalcModeSave state:A3DataObjectStateModified];
}

- (void)appsButtonAction:(UIBarButtonItem *)barButtonItem {
	[self dismissNumberKeyboard];
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
		[rootViewController toggleLeftMenuViewOnOff];
		[self enableControls:!rootViewController.showLeftView];
	}
    [[A3AppDelegate instance] presentInterstitialAds];
}

- (void)moreButtonAction:(UIBarButtonItem *)button {
	[self dismissNumberKeyboard];
	[self.editingObject resignFirstResponder];
	[self setEditingObject:nil];

	[self rightBarButtonDoneButton];

	UIButton *composeButton = self.composeButton;
	UIButton *shareButton = self.shareButton;
	UIButton *historyButton = [self historyButton:NULL];
	UIButton *settingsButton = self.settingsButton;

	_moreMenuButtons = @[composeButton, shareButton, historyButton, settingsButton];
	_moreMenuView = [self presentMoreMenuWithButtons:_moreMenuButtons pullDownView:self.tableView];
	_isShowMoreMenu = YES;

    FNLOG(@"%f", self.tableView.contentOffset.y);
    
    UIEdgeInsets safeAreaInsets = [[[UIApplication sharedApplication] keyWindow] safeAreaInsets];
	if ((self.tableView.contentOffset.y == -63) || (safeAreaInsets.top > 20 && self.tableView.contentOffset.y == -88)) {
		CGRect frame = [self.tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
		frame = CGRectOffset(frame, 0, 1);
		[self.tableView scrollRectToVisible:frame animated:YES];
	}

	// 히스토리가 존재하는지 체크
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"orderInComparison == nil"];
	LoanCalcHistory *history = [LoanCalcHistory findFirstWithPredicate:predicate sortedBy:@"updateDate" ascending:NO];
	LoanCalcComparisonHistory *comparison = [LoanCalcComparisonHistory findFirstOrderedByAttribute:@"updateDate" ascending:NO];

	if (!history && !comparison) {
		// 둘다 없음
		historyButton.enabled = NO;
	}
	else {
		historyButton.enabled = YES;
	}

	if (_isComparisonMode) {
		shareButton.enabled = ([_loanDataA calculated] && [_loanDataB calculated]) ? YES:NO;
	}
	else {
		shareButton.enabled = [self.loanData calculated] ? YES:NO;
	}
	if (_isComparisonMode) {
		composeButton.enabled = [_loanDataA calculated] && [_loanDataB calculated]  ? YES : NO;
	}
	else {
		composeButton.enabled = [self.loanData calculated] ? YES : NO;
	}
}

- (void)doneButtonAction:(id)button {
	[self dismissMoreMenu];
}

- (void)composeButtonAction:(id)button
{
	[self dismissNumberKeyboard];
	[self dismissMoreMenu];

	if (!_isComparisonMode) {
		if ([self.loanData calculated]) {
			[self putLoanHistory];

			// clear
			[self clearLoanData:self.loanData];

			[self saveLoanData];

			[self.tableView reloadData];
		}
	}
	else {
		if ([_loanDataA calculated] && [_loanDataB calculated]) {
			[self putComparisonHistory];

			// clear
			[self clearLoanData:_loanDataA];
			[self clearLoanData:_loanDataB];

			[self saveLoanDataA];
			[self saveLoanDataB];

			[self.tableView reloadData];
		}
	}

    [self refreshRightBarItems];
}

- (void)dismissMoreMenu {
	if ( !_isShowMoreMenu || IS_IPAD ) return;

	[self moreMenuDismissAction:[[self.view gestureRecognizers] lastObject] ];
}

- (void)moreMenuDismissAction:(UITapGestureRecognizer *)gestureRecognizer {
	if (!_isShowMoreMenu) return;

	_isShowMoreMenu = NO;

	[self rightButtonMoreButton];
	[self dismissMoreMenuView:_moreMenuView pullDownView:self.tableView completion:^{
		[self keyboardDidHide:nil];
	}];
	if (gestureRecognizer) {
		[self.view removeGestureRecognizer:gestureRecognizer];
	}
}

- (void)historyButtonAction:(UIButton *)button {
	[self dismissNumberKeyboard];
	[self clearEverything];

	UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"LoanCalculatorPhoneStoryBoard" bundle:nil];
	A3LoanCalcHistoryViewController *viewController = [storyBoard instantiateViewControllerWithIdentifier:@"A3LoanCalcHistoryViewController"];
	viewController.isComparisonMode = _isComparisonMode;
	viewController.delegate = self;

	if (IS_IPHONE) {
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
		navigationController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
		[self presentViewController:navigationController animated:YES completion:nil];
	} else {
		A3RootViewController_iPad *rootViewController = [[A3AppDelegate instance] rootViewController_iPad];
		[rootViewController presentRightSideViewController:viewController toViewController:nil];
	}

	if (IS_IPAD) {
		[self enableControls:NO];
	}
}

- (void)settingsButtonAction:(UIButton *)button
{
	[self dismissNumberKeyboard];
	[self clearEverything];

	UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"LoanCalculatorPhoneStoryBoard" bundle:nil];
	A3LoanCalcSettingViewController *viewController = [storyBoard instantiateViewControllerWithIdentifier:@"A3LoanCalcSettingViewController"];
	[viewController setSettingChangedCompletionBlock:^{

	}];
	[viewController setSettingDismissCompletionBlock:^{
		[self enableControls:YES];
		[self refreshRightBarItems];
	}];

	if (IS_IPHONE) {
		_modalNavigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
		[self presentViewController:_modalNavigationController animated:YES completion:NULL];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingsViewControllerDidDismiss) name:A3NotificationChildViewControllerDidDismiss object:viewController];
	} else {
		[self enableControls:NO];
		[[[A3AppDelegate instance] rootViewController_iPad] presentRightSideViewController:viewController toViewController:nil];
	}
}

- (void)settingsViewControllerDidDismiss {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationChildViewControllerDidDismiss object:_modalNavigationController.childViewControllers[0]];
	_modalNavigationController = nil;
}

- (void)clearEverything {
	[self.editingObject resignFirstResponder];
	[self setEditingObject:nil];

	[self dismissMoreMenu];
	[_currentTextView resignFirstResponder];
}

- (void)refreshCalcFor
{
	self.calcItems = nil;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 2)] withRowAnimation:UITableViewRowAnimationFade];
	[self updateLoanCalculation];
}

- (UITextField *)previousTextField:(UITextField *) current
{
    NSUInteger section, row;
    section = self.currentIndexPath.section;
    row = self.currentIndexPath.row;
    NSIndexPath *selectedIP = nil;
    UITableViewCell *prevCell = nil;
    BOOL exit = false;
    do {
        if (row == 0) {
            if (section == 0) {
                return nil;
            }
            section--;
            if (!(self.loanData.showExtraPayment && self.loanData.frequencyIndex == A3LC_FrequencyMonthly) && (section == 3)) {
                section = 2;
            }
            
            row = [self.tableView numberOfRowsInSection:section]-1;
        }
        else {
            row--;
        }
        
        NSIndexPath *tmpIp = [NSIndexPath indexPathForRow:row inSection:section];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:tmpIp];
        
        if ([cell isKindOfClass:[A3LoanCalcTextInputCell class]]) {
            exit = true;
            prevCell = cell;
            selectedIP = tmpIp;
        }
        
    } while (!exit);

    if (prevCell && selectedIP && [prevCell isKindOfClass:[A3LoanCalcTextInputCell class]]) {
        if (selectedIP.section == (self.loanData.showExtraPayment && self.loanData.frequencyIndex == A3LC_FrequencyMonthly ? 4 : 3)) {
            return nil;
        }
        else if (selectedIP.section == 3) {
            return self.loanData.showExtraPayment && self.loanData.frequencyIndex == A3LC_FrequencyMonthly ? ((A3LoanCalcTextInputCell *)prevCell).textField : nil;
        }
        return ((A3LoanCalcTextInputCell *)prevCell).textField;
    }
    else {
        return nil;
    }
    
}

- (UITextField *)nextTextField:(UITextField *) current
{
    NSUInteger section, row;
    section = self.currentIndexPath.section;
    row = self.currentIndexPath.row;
    NSIndexPath *selectedIP = nil;
    UITableViewCell *nextCell = nil;
    BOOL exit = false;
    do {
        row++;
        NSInteger numRowOfSection = [self.tableView numberOfRowsInSection:section];
        if ((row+1) > numRowOfSection) {
            section++;
            row=0;
            
            if (!(self.loanData.showExtraPayment && self.loanData.frequencyIndex == A3LC_FrequencyMonthly) && (section == 3)) {
                section = 4;
            }
        }

        NSUInteger maxSection = [self.tableView numberOfSections];
        
        if (section > (maxSection-1)) {
            return nil;
        }
        
        NSIndexPath *tmpIp = [NSIndexPath indexPathForRow:row inSection:section];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:tmpIp];
        
        if ([cell isKindOfClass:[A3LoanCalcTextInputCell class]]) {
            exit = true;
            nextCell = cell;
            selectedIP = tmpIp;
        }
        
    } while (!exit);
    
    if (nextCell && selectedIP && [nextCell isKindOfClass:[A3LoanCalcTextInputCell class]]) {
        if (selectedIP.section == 4) {
            return nil;
        }
        else if (selectedIP.section == 3) {
            return self.loanData.showExtraPayment && self.loanData.frequencyIndex == A3LC_FrequencyMonthly ? ((A3LoanCalcTextInputCell *)nextCell).textField : nil;
        }
        return ((A3LoanCalcTextInputCell *)nextCell).textField;
    }
    else {
        return nil;
    }
}

- (LoanCalcHistory *)loanHistoryForLoanData:(LoanCalcData *)loan
{
    NSManagedObjectContext *context = A3SyncManager.sharedSyncManager.persistentContainer.viewContext;
    LoanCalcHistory *history = [[LoanCalcHistory alloc] initWithContext:context];
	history.uniqueID = [[NSUUID UUID] UUIDString];
    history.calculationMode = @(loan.calculationMode);
    history.updateDate = [NSDate date];
    history.downPayment = loan.downPayment.stringValue;
    history.extraPaymentMonthly = loan.extraPaymentMonthly.stringValue;
    history.extraPaymentOnetime = loan.extraPaymentOneTime.stringValue;
    history.extraPaymentOnetimeYearMonth = loan.extraPaymentOneTimeDate;
    history.extraPaymentYearly = loan.extraPaymentYearly.stringValue;
    history.extraPaymentYearlyMonth = loan.extraPaymentYearlyDate;
    history.frequency = @(loan.frequencyIndex);
    history.interestRate = loan.annualInterestRate.stringValue;
    history.interestRatePerYear = loan.showsInterestInYearly;
    history.monthlyPayment = loan.repayment.stringValue;
    history.notes = loan.note;
    history.principal = loan.principal.stringValue;
    history.showAdvanced = @(loan.showAdvanced);
    history.showDownPayment = @(loan.showDownPayment);
    history.showExtraPayment = @(loan.showExtraPayment);
    history.startDate = loan.startDate;
    history.term = loan.monthOfTerms.stringValue;
    history.termTypeMonth = loan.showsTermInMonths;
	history.currencyCode = [self defaultCurrencyCode];
    
    return history;
}

- (void)loadLoanCalcData:(LoanCalcData *)data fromLoanCalcHistory:(LoanCalcHistory *)history
{
    data.downPayment = @(history.downPayment.doubleValue);
    data.extraPaymentMonthly = @(history.extraPaymentMonthly.doubleValue);
    data.extraPaymentOneTime = @(history.extraPaymentOnetime.doubleValue);
    data.extraPaymentOneTimeDate = history.extraPaymentOnetimeYearMonth;
    data.extraPaymentYearly = @(history.extraPaymentYearly.doubleValue);
    data.extraPaymentYearlyDate = history.extraPaymentYearlyMonth;
    data.frequencyIndex = history.frequency.integerValue;
    data.annualInterestRate = @(history.interestRate.doubleValue);
	data.showsInterestInYearly = history.interestRatePerYear;
    data.repayment = @(history.monthlyPayment.doubleValue);
    data.note = history.notes;
    data.principal = @(history.principal.doubleValue);
    data.startDate = history.startDate;
    data.monthOfTerms = @(history.term.floatValue);
	data.showsTermInMonths = history.termTypeMonth;
    data.calculationDate = history.updateDate;
    data.calculationMode = history.calculationMode.integerValue;
    data.showAdvanced = history.showAdvanced.boolValue;
    data.showDownPayment = history.showDownPayment.boolValue;
    data.showExtraPayment = history.showExtraPayment.boolValue;
}

- (void)initializeLoanData:(LoanCalcData *)loan
{
    loan.principal = @0;
    loan.downPayment = @0;
    loan.extraPaymentMonthly = @0;
	loan.showsTermInMonths = @NO;
	loan.showsInterestInYearly = @YES;
    
    loan.frequencyIndex = A3LC_FrequencyMonthly;
    loan.startDate = [NSDate date];
    loan.calculationMode = A3LC_CalculationForRepayment;
    loan.showAdvanced = [LoanCalcPreference showAdvanced];
    loan.showDownPayment = [LoanCalcPreference showDownPayment];
    loan.showExtraPayment = [LoanCalcPreference showExtraPayment];
}

- (void)clearLoanData:(LoanCalcData *)loan
{
    loan.principal = @0;
    loan.repayment = nil;
    loan.downPayment = @0;
    loan.monthOfTerms = nil;
    loan.annualInterestRate = nil;
    loan.calculationDate = nil;
    
    loan.startDate = [NSDate date];
    loan.note = @"";
    
    loan.extraPaymentMonthly = @0;
    loan.extraPaymentOneTime = nil;
    loan.extraPaymentYearly = nil;
    loan.extraPaymentOneTimeDate = nil;
    loan.extraPaymentYearlyDate = nil;
}

- (void)loadPreviousCalculation
{
	self.calcItems = nil;
	self.loanData = nil;
	_loanDataA = nil;
	_loanDataB = nil;

    [self loanData];
    [self loanDataA];
    [self loanDataB];
    
    _isComparisonMode = [[A3SyncManager sharedSyncManager] boolForKey:LoanCalcModeSave];
    [self selectSegment].selectedSegmentIndex = _isComparisonMode ? 1:0;
    
    /*
    if (self.loanData.calculationDate) {
        if (self.loanDataA.calculationDate && self.loanDataB.calculationDate) {
            NSDate *date1 = _loanData.calculationDate;
            NSDate *date2 = _loanDataA.calculationDate;
            
            if ([date1 compare:date2] == NSOrderedDescending) {
                FNLOG(@"date1 is later than date2");
                _isComparisonMode = NO;
                [self selectSegment].selectedSegmentIndex = 0;
            }
            else {
                _isComparisonMode = YES;
                [self selectSegment].selectedSegmentIndex = 1;
            }
        }
        else {
            _isComparisonMode = NO;
            [self selectSegment].selectedSegmentIndex = 0;
        }
    }
    else {
        if (self.loanDataA.calculationDate && self.loanDataB.calculationDate) {
            _isComparisonMode = YES;
            [self selectSegment].selectedSegmentIndex = 1;
        }
        else {
            _isComparisonMode = NO;
            [self selectSegment].selectedSegmentIndex = 0;
        }
    }
     */
}

- (NSString *)resultTextOfLoan:(LoanCalcData *)data forCalcuFor:(A3LoanCalcCalculationMode)calcMode
{
    if (data) {
        switch (calcMode) {
            case A3LC_CalculationForDownPayment:
            {
                return [self.loanFormatter stringFromNumber:data.downPayment];
            }
            case A3LC_CalculationForPrincipal:
            {
                return [self.loanFormatter stringFromNumber:data.principal];
            }
            case A3LC_CalculationForRepayment:
            {
                return [self.loanFormatter stringFromNumber:data.repayment];
            }
            case A3LC_CalculationForTermOfMonths:
            {
                long month = (long) round(data.monthOfTerms.doubleValue);
                NSString *result = [NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld mos", @"StringsDict", nil), month];
                return result;
            }
            case A3LC_CalculationForTermOfYears:
            {
                if (round([data.monthOfTerms doubleValue]) < 12.0) {
                    NSInteger monthInt = roundl([data.monthOfTerms doubleValue]);
					return [NSString stringWithFormat:@"%@ %@",
													  [NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld yrs", @"StringsDict", nil), (long)0],
													  [NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld mos", @"StringsDict", nil), (long) monthInt]
					];
                }
                else {
                    NSInteger yearInt = roundl([data.monthOfTerms doubleValue]) / 12.0;
                    NSInteger monthInt = roundl([data.monthOfTerms doubleValue]) - (12 * yearInt);
                    NSString *result;
                    if (monthInt == 0) {
                        result = [NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld yrs", @"StringsDict", nil), (long)yearInt];
                    }
                    else {
                        result = [NSString stringWithFormat:@"%@ %@",
								[NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld yrs", @"StringsDict", nil), (long) yearInt],
								[NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld mos", @"StringsDict", nil), (long) monthInt]
						];
                    }
                    return result;
                }
            }
            default:
                return @"";
        }
    }
    else {
        return @"";
    }
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
	// Popover controller, iPad only.
	[self enableControls:YES];

	_sharePopoverController = nil;
}

- (void)shareButtonAction:(id)sender {
	[self dismissNumberKeyboard];
	[self clearEverything];

	if (_isComparisonMode) {
		NSURL *fileUrlA = [NSURL fileURLWithPath:[_loanDataA filePathOfCsvStringForMonthlyDataWithFileName:@"AppBoxPro_amortization_loanA.csv"]];
		NSURL *fileUrlB = [NSURL fileURLWithPath:[_loanDataB filePathOfCsvStringForMonthlyDataWithFileName:@"AppBoxPro_amortization_loanB.csv"]];
		self.sharePopoverController =
                [self presentActivityViewControllerWithActivityItems:@[self, fileUrlA, fileUrlB]
                                                   fromBarButtonItem:sender
                                                   completionHandler:^() {
                                                       [self enableControls:YES];
                                                   }];
	}
	else {
		NSURL *fileUrl = [NSURL fileURLWithPath:[[self loanData] filePathOfCsvStringForMonthlyDataWithFileName:@"AppBoxPro_amortization.csv"]];
        self.sharePopoverController =
                [self presentActivityViewControllerWithActivityItems:@[self, fileUrl]
                                                   fromBarButtonItem:sender
                                                   completionHandler:^() {
                                                       [self enableControls:YES];
                                                   }];
	}

    if (IS_IPAD) {
        self.sharePopoverController.delegate = self;
		[self enableControls:NO];
    }
}

#pragma mark Share Activities related

- (NSString *)activityViewController:(UIActivityViewController *)activityViewController subjectForActivityType:(NSString *)activityType
{
	if ([activityType isEqualToString:UIActivityTypeMail]) {
		return NSLocalizedString(@"Loan Calculator using AppBox Pro", @"Loan Calculator using AppBox Pro");
	}
    
	return @"";
}

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType
{
	if ([activityType isEqualToString:UIActivityTypeMail]) {
		return [self shareMailMessageWithHeader:NSLocalizedString(@"I'd like to share a calculation with you.", nil)
									   contents:[self shareStringForMail]
										   tail:NSLocalizedString(@"You can calculate more in the AppBox Pro.", nil)];
	}
	else {
        NSString *shareString = [self shareStringForEtc];
        shareString = [shareString stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
		return shareString;
	}
}

//-(NSString *)activityViewController:(UIActivityViewController *)activityViewController dataTypeIdentifierForActivityType:(NSString *)activityType
//{
//	if ([activityType isEqualToString:UIActivityTypeMail]) {
//        
//		NSString *filePathA = [_loanDataA filePathOfCsvStringForMonthlyDataWithFileName:@"AppBoxPro_amortization_loanA.csv"];
//		NSString *filePathB = [_loanDataB filePathOfCsvStringForMonthlyDataWithFileName:@"AppBoxPro_amortization_loanB.csv"];
//        if (![[NSFileManager defaultManager] fileExistsAtPath:filePathA]) {
//            return nil;
//        }
//        // Borrowed from http://stackoverflow.com/questions/5996797/determine-mime-type-of-nsdata-loaded-from-a-file
//        // itself, derived from  http://stackoverflow.com/questions/2439020/wheres-the-iphone-mime-type-database
//        CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)[filePathA pathExtension] , NULL);
//        CFStringRef mimeType = UTTypeCopyPreferredTagWithClass (UTI, kUTTagClassMIMEType);
//        CFRelease(UTI);
//        if (!mimeType) {
//            return @"application/octet-stream";
//        }
//
//        NSString *resultUtiString = (__bridge_transfer NSString *)UTI;
//        return resultUtiString;
//    }
//    FNLOG(@"");
//    return nil;
//}

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController
{
	return NSLocalizedString(@"Share Loan Calculator Data", @"Share Loan Calculator Data");
}

- (NSString *)shareStringForMail
{
    NSMutableString *body = [NSMutableString new];
    
	if (_isComparisonMode) {
		// * Loan A
		[body appendFormat:@"** %@ A <br>", NSLocalizedString(@"Loan", @"Loan")];
        [body appendString:[self shareStringForLoanCalcData:_loanDataA isShortType:NO]];
        
		// * Loan B
		[body appendFormat:@"<br>** %@ B <br>", NSLocalizedString(@"Loan", @"Loan")];
        [body appendString:[self shareStringForLoanCalcData:_loanDataB isShortType:NO]];
	}
	else {
        // Loan Mode
        body = [self shareStringForLoanCalcData:self.loanData isShortType:NO];
	}
    
    return body;
}

- (NSString *)shareStringForEtc
{
    NSMutableString *body = [NSMutableString new];
    
	if (_isComparisonMode) {
		// * Loan A
		[body appendFormat:@"** %@ A <br>", NSLocalizedString(@"Loan", @"Loan")];
        [body appendString:[self shareStringForLoanCalcData:_loanDataA isShortType:YES]];
        
		// * Loan B
		[body appendFormat:@"<br>** %@ B <br>", NSLocalizedString(@"Loan", @"Loan")];
        [body appendString:[self shareStringForLoanCalcData:_loanDataB isShortType:YES]];
	}
	else {
        // Loan Mode
        body = [self shareStringForLoanCalcData:self.loanData isShortType:YES];
	}
    
    return body;
}

- (NSMutableString *)shareStringForLoanCalcData:(LoanCalcData *)loanData isShortType:(BOOL)isShortType
{
    NSMutableString *body = [NSMutableString new];
    if (!isShortType) {
		[body appendFormat:@"*%@<br>", NSLocalizedString(@"Calculation", @"Calculation")];
    }
    // Result
    // Payments or etc
    [body appendFormat:@"%@:", [[LoanCalcString titleOfCalFor:loanData.calculationMode] uppercaseString]];
    A3LoanCalcCalculationItem resultItem = [LoanCalcMode resltItemForCalcMode:loanData.calculationMode];
    if (loanData.calculationMode == A3LC_CalculationForTermOfMonths || loanData.calculationMode == A3LC_CalculationForTermOfYears) {
        NSInteger yearInt =  (int)loanData.monthOfTerms.doubleValue/12.0;
        if (yearInt > 0) {
			[body appendString:@" "];
            [body appendString:[NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld years", @"StringsDict", nil), (long)yearInt]];
        }

        NSInteger monthInt =  (int)round(loanData.monthOfTerms.doubleValue)  - (12 * yearInt);
        if (monthInt > 0) {
			[body appendString:@" "];
            [body appendString:[NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld months", @"StringsDict", nil), (long)monthInt]];
        }
    }
    else {
        [body appendString:[LoanCalcString valueTextForCalcItem:resultItem fromData:loanData formatter:self.currencyFormatter]];
    }

	[body appendFormat:@"<br>%@: %@ <br>", NSLocalizedString(@"Interest", @"Interest"), [self.loanFormatter stringFromNumber:[loanData totalInterest]]];  // Interest: $23,981.60 (결과값)
	[body appendFormat:@"%@: %@ <br>", NSLocalizedString(@"Total Amount", @"Total Amount"), [self.loanFormatter stringFromNumber:[loanData totalAmount]]];
    
    if (isShortType) {
        return body;
    }
    
    // Inputs
	[body appendFormat:@"<br>*%@<br>", NSLocalizedString(@"Input", @"Input")];
    BOOL downPaymentEnable = (loanData.showDownPayment && (loanData.downPayment.doubleValue >0)) ? YES:NO;
    NSArray *inputCalcItems = [LoanCalcMode calculateItemForMode:loanData.calculationMode withDownPaymentEnabled:downPaymentEnable];
    [inputCalcItems enumerateObjectsUsingBlock:^(NSNumber *itemID, NSUInteger idx, BOOL *stop) {
        A3LoanCalcCalculationItem inputCalcItem = (A3LoanCalcCalculationItem)[itemID integerValue];
        [body appendFormat:@"%@: ", [LoanCalcString titleOfItem:inputCalcItem]];
        [body appendFormat:@"%@<br>", [LoanCalcString valueTextForCalcItem:inputCalcItem fromData:loanData formatter:self.currencyFormatter]];
    }];
    
    if (loanData.extraPaymentMonthly && [loanData.extraPaymentMonthly floatValue] > 0.0) {
        // Extra Payment(monthly): (값이 있는 경우)
		[body appendFormat:@"%@: %@ <br>", NSLocalizedString(@"Extra Payment(monthly)", @"Extra Payment(monthly)"), [self.loanFormatter stringFromNumber:loanData.extraPaymentMonthly]];
    }
    if (loanData.extraPaymentYearly && [loanData.extraPaymentYearly floatValue] > 0.0) {
        // Extra Payment(yearly): (값이 있는 경우)
		[body appendFormat:@"%@: %@ <br>", NSLocalizedString(@"Extra Payment(yearly)", @"Extra Payment(yearly)"), [self.loanFormatter stringFromNumber:loanData.extraPaymentYearly]];
    }
    if (loanData.extraPaymentOneTime && [loanData.extraPaymentOneTime floatValue] > 0.0) {
        // Extra Payment(one-time): (값이 있는 경우)
		[body appendFormat:@"%@: %@ <br>", NSLocalizedString(@"Extra Payment(one-time)", @"Extra Payment(one-time)"), [self.loanFormatter stringFromNumber:loanData.extraPaymentOneTime]];
    }
    
    return body;
}

#pragma mark - Loan Mode Calculation

- (void)updateLoanCalculation
{
    if (!_isComparisonMode) {
        switch (self.loanData.calculationMode) {
            case A3LC_CalculationForDownPayment:
                [self.loanData calculateDownPayment];
                break;
            case A3LC_CalculationForPrincipal:
                [self.loanData calculatePrincipal];
                break;
            case A3LC_CalculationForRepayment:
                [self.loanData calculateRepayment];
                break;
            case A3LC_CalculationForTermOfMonths:
                [self.loanData calculateTermInMonth];
                break;
            case A3LC_CalculationForTermOfYears:
                [self.loanData calculateTermInMonth];
                break;
                
            default:
                break;
        }
        
        [self displayLoanGraph];
        
        // calculation 정보 업데이트
        NSIndexPath *calIP = [NSIndexPath indexPathForRow:0 inSection:1];
        [self.tableView reloadRowsAtIndexPaths:@[calIP] withRowAnimation:UITableViewRowAnimationAutomatic];
        
		[self saveLoanData];
		[self refreshRightBarItems];
        
        if ([self.loanData calculated]) {
            [self scrollToTopOfTableView];
        }
    }
}

- (void)putLoanHistory
{
    if (![LoanCalcHistory sameDataExistForLoanCalcData:self.loanData type:nil]) {
        [self loanHistoryForLoanData:self.loanData];

        NSManagedObjectContext *context = A3SyncManager.sharedSyncManager.persistentContainer.viewContext;
        [context saveContext];
    }
}

#pragma mark - Save previous user input

- (void)saveLoanData
{
    NSData *myLoanData = [NSKeyedArchiver archivedDataWithRootObject:self.loanData];

	[[A3SyncManager sharedSyncManager] setObject:myLoanData forKey:A3LoanCalcUserDefaultsLoanDataKey state:A3DataObjectStateModified];
}

- (void)saveLoanDataA
{
    NSData *myLoanData = [NSKeyedArchiver archivedDataWithRootObject:_loanDataA];

	[[A3SyncManager sharedSyncManager] setObject:myLoanData forKey:A3LoanCalcUserDefaultsLoanDataKey_A state:A3DataObjectStateModified];
}

- (void)saveLoanDataB
{
    NSData *myLoanData = [NSKeyedArchiver archivedDataWithRootObject:_loanDataB];

	[[A3SyncManager sharedSyncManager] setObject:myLoanData forKey:A3LoanCalcUserDefaultsLoanDataKey_B state:A3DataObjectStateModified];
}

#pragma mark - Compare mode calculation

- (void)updateCompareLoanA
{
    if (_isComparisonMode) {
        // update info cell
        
        [self updateLoanInfoA];
        [self displayCompareGraph];
		[self saveLoanDataA];
    }
}

- (void)updateCompareLoanB
{
    if (_isComparisonMode) {
        // update info cell
        
        [self updateLoanInfoB];
        [self displayCompareGraph];
        [self saveLoanDataB];
    }
}

- (void)updateLoanInfoA
{
    A3LoanCalcLoanInfoCell *infoCell = (A3LoanCalcLoanInfoCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    [self updateInfoCell:infoCell withLoanInfo:_loanDataA];
}

- (void)updateLoanInfoB
{
    A3LoanCalcLoanInfoCell *infoCell = (A3LoanCalcLoanInfoCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]];
    [self updateInfoCell:infoCell withLoanInfo:_loanDataB];
}

- (void)updateInfoCell:(A3LoanCalcLoanInfoCell *)infoCell withLoanInfo:(LoanCalcData *)loan
{
    if (IS_IPAD) {
        infoCell.amountLabel.text = [self.loanFormatter stringFromNumber:loan.totalAmount];
    }

    NSString *paymentText = [loan calculated] ? [self.loanFormatter stringFromNumber:loan.repayment] : [self.loanFormatter stringFromNumber:@(0)];
    infoCell.paymentLabel.text = [NSString stringWithFormat:@"%@/%@", paymentText, [LoanCalcString shortTitleOfFrequency:loan.frequencyIndex]];
    infoCell.frequencyLabel.text = [LoanCalcString titleOfFrequency:loan.frequencyIndex];
    infoCell.interestLabel.text = [loan interestRateString];
    infoCell.termLabel.text = [loan termValueString];
	infoCell.principalLabel.text = [self.loanFormatter stringFromNumber:loan.principal];
    
    [infoCell.paymentLabel sizeToFit];
    [infoCell.frequencyLabel sizeToFit];
    [infoCell.interestLabel sizeToFit];
    [infoCell.termLabel sizeToFit];
	[infoCell.principalLabel sizeToFit];

    CGRect rect = infoCell.paymentLabel.frame;
    rect.origin.x = (CGRectGetWidth(infoCell.contentView.frame) - 15 - 14) - rect.size.width;
    infoCell.paymentLabel.frame = rect;
    
    rect = infoCell.frequencyLabel.frame;
    rect.origin.x = (CGRectGetWidth(infoCell.contentView.frame) - 15) - rect.size.width;
    infoCell.frequencyLabel.frame = rect;
    
    rect = infoCell.interestLabel.frame;
    rect.origin.x = (CGRectGetWidth(infoCell.contentView.frame) - 15) - rect.size.width;
    infoCell.interestLabel.frame = rect;
    
    rect = infoCell.termLabel.frame;
    rect.origin.x = (CGRectGetWidth(infoCell.contentView.frame) - 15) - rect.size.width;
    infoCell.termLabel.frame = rect;

    rect = infoCell.principalLabel.frame;
    rect.origin.x = (CGRectGetWidth(infoCell.contentView.frame) - 15) - rect.size.width;
    infoCell.principalLabel.frame = rect;
}

- (void)makeClearInfoCell:(A3LoanCalcLoanInfoCell *)infoCell
{
    if (IS_IPAD) {
        infoCell.amountLabel.text = [self.loanFormatter stringFromNumber:@(0)];
    }
    infoCell.paymentLabel.text = [NSString stringWithFormat:@"%@/%@", [self.loanFormatter stringFromNumber:@(0)], [LoanCalcString shortTitleOfFrequency:A3LC_FrequencyMonthly]];
    infoCell.frequencyLabel.text = [LoanCalcString titleOfFrequency:A3LC_FrequencyMonthly];
    infoCell.interestLabel.text = [self.percentFormatter stringFromNumber:@(0)];
    infoCell.termLabel.text = NSLocalizedString(@"0 year", @"0 year");
    infoCell.principalLabel.text = [self.loanFormatter stringFromNumber:@(0)];
}

- (void)displayCompareGraph
{
    if (_isComparisonMode) {
        A3LoanCalcCompareGraphCell *compareCell = (A3LoanCalcCompareGraphCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        
        // loan data A,B
        if ([_loanDataA calculated] || [_loanDataB calculated]) {
            [self displayCompareCell:compareCell];
        }
        else {
            [self makeCompareCellClear:compareCell];
        }
    }
}

- (void)displayCompareCell:(A3LoanCalcCompareGraphCell *)compareCell
{
    A3NumberFormatter *nonSymobolCurrencyFormatter = [A3NumberFormatter new];
    [nonSymobolCurrencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [nonSymobolCurrencyFormatter setCurrencyCode:[self.loanFormatter currencyCode]];
    [nonSymobolCurrencyFormatter setCurrencySymbol:@""];
    
    if ([_loanDataA calculated]) {
        // text
        NSString *totalInterestString;
        NSString *totalAmountString;

        if (IS_IPHONE) {
            if ([_loanDataA.totalInterest doubleValue] > 0.0) {
                totalInterestString = [nonSymobolCurrencyFormatter stringFromNumber:[_loanDataA totalInterest]];
            }
            else {
                totalInterestString = [self.loanFormatter stringFromNumber:[_loanDataA totalInterest]];
            }

            if ([_loanDataA.totalAmount doubleValue] > 0.0) {
                totalAmountString = [nonSymobolCurrencyFormatter stringFromNumber:[_loanDataA totalAmount]];
            }
            else {
                totalAmountString = [self.loanFormatter stringFromNumber:[_loanDataA totalAmount]];
            }
        }
        else {
            totalInterestString = [self.loanFormatter stringFromNumber:[_loanDataA totalInterest]];
            totalAmountString = [self.loanFormatter stringFromNumber:[_loanDataA totalAmount]];
        }
        
        compareCell.left_A_Label.text = totalInterestString;
        compareCell.right_A_Label.text = totalAmountString;
        
        // graph
        compareCell.red_A_Line.hidden = NO;
        
        float maxAmount = MAX([_loanDataA totalAmount].floatValue, [_loanDataB totalAmount].floatValue);
        float percentOfRedBar = 0;
        float interestFloat = [_loanDataA totalInterest].floatValue;
        percentOfRedBar = interestFloat/maxAmount;

		FNLOG(@"%f", percentOfRedBar);
		compareCell.redLineARightConstraint.constant = -1 * self.view.bounds.size.width * (1 - percentOfRedBar);
		[compareCell.left_A_Label sizeToFit];
		CGFloat minimumCenterX = -1 * (self.view.bounds.size.width - (compareCell.left_A_Label.bounds.size.width / 2 + 10.0));
		compareCell.leftLabelACenterXConstraint.constant = MAX(-(self.view.bounds.size.width * (1 - percentOfRedBar)), minimumCenterX);
		[compareCell layoutIfNeeded];

        // 애니메이션 Start
        compareCell.left_A_Label.alpha = 0.0;
        compareCell.right_A_Label.alpha = 0.0;
        
        float aniDuration = 0.3;
        [UIView beginAnimations:@"GraphUpdateA" context:NULL];
        [UIView setAnimationDuration:aniDuration];
        
        // 애니메이션 End
        compareCell.left_A_Label.alpha = 1.0;
        compareCell.right_A_Label.alpha = 1.0;
        
        [UIView commitAnimations];
    }
    else {
        [self makeClearGraphLoanA:compareCell];
    }
    
    if ([_loanDataB calculated]) {
        // text
        NSString *totalInterestString;
        NSString *totalAmountString;
        if (IS_IPHONE) {
            if ([_loanDataB.totalInterest doubleValue] > 0.0) {
                totalInterestString = [nonSymobolCurrencyFormatter stringFromNumber:[_loanDataB totalInterest]];
            }
            else {
                totalInterestString = [self.loanFormatter stringFromNumber:[_loanDataB totalInterest]];
            }
            
            if ([_loanDataB.totalAmount doubleValue] > 0.0) {
                totalAmountString = [nonSymobolCurrencyFormatter stringFromNumber:[_loanDataB totalAmount]];
            }
            else {
                totalAmountString = [self.loanFormatter stringFromNumber:[_loanDataB totalAmount]];
            }
        }
        else {
            totalInterestString = [self.loanFormatter stringFromNumber:[_loanDataB totalInterest]];
            totalAmountString = [self.loanFormatter stringFromNumber:[_loanDataB totalAmount]];
        }
        compareCell.left_B_Label.text = totalInterestString;
        compareCell.right_B_Label.text = totalAmountString;
		
        // graph
        compareCell.red_B_Line.hidden = NO;
        
        float maxAmount = MAX([_loanDataA totalAmount].floatValue, [_loanDataB totalAmount].floatValue);
        float percentOfRedBar = 0;
        float interestFloat = [_loanDataB totalInterest].floatValue;
        percentOfRedBar = interestFloat/maxAmount;

		FNLOG(@"%f", percentOfRedBar);
		compareCell.redLineBRightConstraint.constant = -1 * self.view.bounds.size.width * (1 - percentOfRedBar);
		compareCell.leftLabelBCenterXConstraint.constant = -1 * self.view.bounds.size.width * (1 - percentOfRedBar);
		[compareCell layoutIfNeeded];

        float percentOfMarkB = 0;
        
        float totalFloat = [_loanDataB totalAmount].floatValue;
        percentOfMarkB = totalFloat/maxAmount;

        // 애니메이션 Start
        compareCell.left_B_Label.alpha = 0.0;
        compareCell.right_B_Label.alpha = 0.0;
        
        float aniDuration = 0.3;
        [UIView beginAnimations:@"GraphUpdateB" context:NULL];
        [UIView setAnimationDuration:aniDuration];
        
        // 애니메이션 End
        compareCell.left_B_Label.alpha = 1.0;
        compareCell.right_B_Label.alpha = 1.0;
        
        [UIView commitAnimations];
        
    }
    else {
        [self makeClearGraphLoanB:compareCell];
    }
    
    [compareCell adjustABMarkPositionForTotalAmountA:[_loanDataA calculated] ? [_loanDataA totalAmount] : @0
                                        totalAmountB:[_loanDataB calculated] ? [_loanDataB totalAmount] : @0];
}

- (void)makeCompareCellClear:(A3LoanCalcCompareGraphCell *)compareCell
{
    [self makeClearGraphLoanA:compareCell];
    [self makeClearGraphLoanB:compareCell];
}

- (void)makeClearGraphLoanA:(A3LoanCalcCompareGraphCell *)compareCell
{
    compareCell.red_A_Line.hidden = YES;
    
    compareCell.left_A_Label.text = @"";
    compareCell.right_A_Label.text = @"";
}

- (void)makeClearGraphLoanB:(A3LoanCalcCompareGraphCell *)compareCell
{
    compareCell.red_B_Line.hidden = YES;
    
    compareCell.left_B_Label.text = @"";
    compareCell.right_B_Label.text = @"";
}

- (void)putComparisonHistory
{
    BOOL shouldSave;
    
	shouldSave = ![LoanCalcHistory sameDataExistForLoanCalcData:_loanDataA type:@"A"] ||
			![LoanCalcHistory sameDataExistForLoanCalcData:_loanDataB type:@"B"];
    
    if (shouldSave) {
        LoanCalcHistory *historyA = [self loanHistoryForLoanData:_loanDataA];
        LoanCalcHistory *historyB = [self loanHistoryForLoanData:_loanDataB];
		historyA.orderInComparison = @"A";
		historyB.orderInComparison = @"B";
        
        NSManagedObjectContext *context = A3SyncManager.sharedSyncManager.persistentContainer.viewContext;
        LoanCalcComparisonHistory *comparison = [[LoanCalcComparisonHistory alloc] initWithContext:context];
        comparison.uniqueID = [[NSUUID UUID] UUIDString];
        comparison.updateDate = [NSDate date];
        comparison.totalInterestA = [_loanDataA totalInterest].stringValue;
        comparison.totalInterestB = [_loanDataB totalInterest].stringValue;
        comparison.totalAmountA = [_loanDataA totalAmount].stringValue;
        comparison.totalAmountB = [_loanDataB totalAmount].stringValue;
		comparison.currencyCode = [self defaultCurrencyCode];

		historyA.comparisonHistoryID = comparison.uniqueID;
		historyB.comparisonHistoryID = comparison.uniqueID;

        [context saveContext];
    }
}

- (void)dismissDatePicker
{
    if ([_advItems containsObject:self.dateInputItem]) {
        [self.tableView beginUpdates];
        
        [_advItems removeObject:self.dateInputItem];
        NSIndexPath *ip1 = [NSIndexPath indexPathForRow:0 inSection:self.loanData.showExtraPayment && self.loanData.frequencyIndex == A3LC_FrequencyMonthly ? 4 : 3];
        NSIndexPath *ip2 = [NSIndexPath indexPathForRow:1 inSection:self.loanData.showExtraPayment && self.loanData.frequencyIndex == A3LC_FrequencyMonthly ? 4 : 3];
        [self.tableView reloadRowsAtIndexPaths:@[ip1] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView deleteRowsAtIndexPaths:@[ip2] withRowAnimation:UITableViewRowAnimationFade];
        
        [self.tableView endUpdates];
    }
}

- (void)datePickerActiveFromIndexPath:(NSIndexPath *)dateIndexPath
{
    if (![_advItems containsObject:self.dateInputItem]) {
        [_advItems insertObject:self.dateInputItem atIndex:1];
        [self.tableView beginUpdates];
        NSIndexPath *ip1 = [NSIndexPath indexPathForRow:0 inSection:self.loanData.showExtraPayment && self.loanData.frequencyIndex == A3LC_FrequencyMonthly ? 4 : 3];
        NSIndexPath *ip2 = [NSIndexPath indexPathForRow:1 inSection:self.loanData.showExtraPayment && self.loanData.frequencyIndex == A3LC_FrequencyMonthly ? 4 : 3];
        [self.tableView reloadRowsAtIndexPaths:@[ip1] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView insertRowsAtIndexPaths:@[ip2] withRowAnimation:UITableViewRowAnimationFade];
		CGRect cellRect = [self.tableView rectForRowAtIndexPath:ip2];
		[self.tableView scrollRectToVisible:cellRect animated:YES];
        [self.tableView endUpdates];
    }
}

#pragma mark - ScrollView Delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
	[self dismissNumberKeyboard];
    [self clearEverything];
}

#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    [self dismissMoreMenu];
    [self dismissDatePicker];
    
    _currentTextView = textView;
	[self setEditingObject:textView];
	self.scrollToIndexPath = nil;
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    if ([textView.text isEqualToString:self.loanData.note]) {
        return;
    }

	self.loanData.note = textView.text;
    
    CGSize newSize = [textView sizeThatFits:CGSizeMake(textView.frame.size.width, MAXFLOAT)];
    if (newSize.height < 180) {
        return;
    }
    
    UITableViewCell *currentCell = [self.tableView cellForCellSubview:textView];
    CGFloat diffHeight = newSize.height - currentCell.frame.size.height;
    
    currentCell.frame = CGRectMake(currentCell.frame.origin.x,
                                   currentCell.frame.origin.y,
                                   currentCell.frame.size.width,
                                   newSize.height);
    
    [UIView beginAnimations:@"cellExpand" context:nil];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationCurve:7];
    [UIView setAnimationDuration:0.25];
    self.tableView.contentOffset = CGPointMake(0.0, self.tableView.contentOffset.y + diffHeight);
    [UIView commitAnimations];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
	self.loanData.note = textView.text;
    [self saveLoanData];
    
    UITableViewCell *currentCell = [self.tableView cellForCellSubview:textView];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:currentCell];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];

	[self setEditingObject:nil];
}

#pragma mark - TextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
	if (IS_IPHONE && [UIWindow interfaceOrientationIsLandscape]) return NO;

	[self dismissMoreMenu];
	[self dismissDatePicker];

	self.scrollToIndexPath = [self.tableView indexPathForCellSubview:textField];

	if (self.scrollToIndexPath.section == (self.loanData.showExtraPayment && self.loanData.frequencyIndex == A3LC_FrequencyMonthly ? 4 : 3)) {
		if (_advItems[self.scrollToIndexPath.row] == self.startDateItem) {
			return NO;
		}
	}
	if (_isNumberKeyboardVisible) {
		if (_editingTextField != textField) {
			[self textFieldDidEndEditing:_editingTextField];
			[self textFieldDidBeginEditing:textField];
		}
	} else {
		self.numberKeyboardViewController = [self normalNumberKeyboard];
		[self presentNumberKeyboardForTextField:textField];
	}

	return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	[self setEditingObject:textField];

	_editingTextField = textField;
	self.textBeforeEditing = textField.text;
	self.textColorBeforeEditing = textField.textColor;
	_didPressNumberKey = NO;
	_didPressClearKey = NO;
	
	textField.text = [self.decimalFormatter stringFromNumber:@0];
    textField.textColor = [[A3UserDefaults standardUserDefaults] themeColor];
	textField.placeholder = @"";

	self.currentIndexPath = [self.tableView indexPathForCellSubview:textField];
	[self.tableView scrollToRowAtIndexPath:self.currentIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];

	if (self.currentIndexPath.section == 2) {

		// calculation items
		NSNumber *calcItemNum = self.calcItems[self.currentIndexPath.row];
		A3LoanCalcCalculationItem calcItem = calcItemNum.integerValue;

		A3NumberKeyboardViewController *keyboardVC = self.numberKeyboardViewController;

		switch (calcItem) {
			case A3LC_CalculationItemDownPayment:
			case A3LC_CalculationItemPrincipal:
			case A3LC_CalculationItemRepayment:
			{
				keyboardVC.currencyCode = [self defaultCurrencyCode];
				keyboardVC.keyboardType = A3NumberKeyboardTypeCurrency;
				break;
			}
			case A3LC_CalculationItemInterestRate:
			{
				keyboardVC.keyboardType = A3NumberKeyboardTypeInterestRate;
				if (!self.loanData.showsInterestInYearly || ![self.loanData.showsInterestInYearly boolValue]) {
					[keyboardVC.bigButton1 setSelected:NO];
					[keyboardVC.bigButton2 setSelected:YES];
				}
				break;
			}
			case A3LC_CalculationItemTerm:
			{
				keyboardVC.keyboardType = A3NumberKeyboardTypeMonthYear;
				if ([self.loanData.showsTermInMonths boolValue]) {
					[keyboardVC.bigButton1 setSelected:NO];
					[keyboardVC.bigButton2 setSelected:YES];
				}
				break;
			}
			default:
				keyboardVC.keyboardType = A3NumberKeyboardTypeCurrency;
				break;
		}

		keyboardVC.textInputTarget = textField;
		keyboardVC.delegate = self;

		[keyboardVC reloadPrevNextButtons];
	}
	else if (self.currentIndexPath.section == 3) {
		// extra payment
		NSNumber *exPaymentItemNum = self.extraPaymentItems[self.currentIndexPath.row];
		A3LoanCalcExtraPaymentType exPaymentItem = exPaymentItemNum.integerValue;

		if (exPaymentItem == A3LC_ExtraPaymentMonthly) {

			A3NumberKeyboardViewController *keyboardVC = self.numberKeyboardViewController;
			keyboardVC.currencyCode = [self defaultCurrencyCode];
            if (IS_IPAD) {
                keyboardVC.hidesLeftBigButtons = YES;
            }
			keyboardVC.keyboardType = A3NumberKeyboardTypeCurrency;
			keyboardVC.textInputTarget = textField;
			keyboardVC.delegate = self;

			[keyboardVC reloadPrevNextButtons];
		}
	}

	FNLOGINSETS(self.tableView.contentInset);
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	FNLOGINSETS(self.tableView.contentInset);

	return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	FNLOGINSETS(self.tableView.contentInset);

	if (_textColorBeforeEditing) {
		textField.textColor = _textColorBeforeEditing;
		_textColorBeforeEditing = nil;
	}
	
	[self setEditingObject:nil];

	if (!_didPressNumberKey && !_didPressClearKey) {
		textField.text = _textBeforeEditing;
		_textBeforeEditing = nil;

		return;
	}

	NSIndexPath *endIP = self.currentIndexPath;
	FNLOG(@"End IP : %ld - %ld", (long) endIP.section, (long) endIP.row);

	NSNumberFormatter *formatter = [NSNumberFormatter new];
	[formatter setNumberStyle:NSNumberFormatterDecimalStyle];

	NSNumber *inputNum = [formatter numberFromString:[textField text]];
	float inputFloat = [inputNum floatValue];

	// update
	if (endIP.section == 2) {
		// calculation item
		NSNumber *calcItemNum = self.calcItems[endIP.row];
		A3LoanCalcCalculationItem calcItem = calcItemNum.integerValue;
		//double inputFloat = [textField.text doubleValue];
		switch (calcItem) {
			case A3LC_CalculationItemDownPayment: {
				if ([textField.text length] > 0) {
					self.loanData.downPayment = inputNum;
				}
				textField.text = [self.loanFormatter stringFromNumber:self.loanData.downPayment];
				break;
			}
			case A3LC_CalculationItemInterestRate: {
				if ([textField.text length] > 0) {
					self.loanData.showsInterestInYearly = @([self.numberKeyboardViewController.bigButton1 isSelected]);
					if ([self.loanData.showsInterestInYearly boolValue]) {
						self.loanData.annualInterestRate = @(inputFloat / 100.0);
					} else {
						self.loanData.annualInterestRate = @(inputFloat / 100.0 * 12.0);
					}
				}
				textField.text = [self.loanData interestRateString];
				break;
			}
			case A3LC_CalculationItemPrincipal: {
				if ([textField.text length] > 0) {
					self.loanData.principal = inputNum;
				}
				textField.text = [self.loanFormatter stringFromNumber:self.loanData.principal];

				break;
			}
			case A3LC_CalculationItemRepayment: {
				if ([textField.text length] > 0) {
					self.loanData.repayment = inputNum;
				}
				textField.text = [self.loanFormatter stringFromNumber:self.loanData.repayment];

				break;
			}
			case A3LC_CalculationItemTerm: {
				if ([textField.text length]) {
					self.loanData.showsTermInMonths = @([self.numberKeyboardViewController.bigButton2 isSelected]);
					if ([self.loanData.showsTermInMonths boolValue]) {
						self.loanData.monthOfTerms = inputNum;
					} else {
						NSInteger years = [inputNum integerValue];
						self.loanData.monthOfTerms = @(years * 12);
					}
				}
				textField.text = [self.loanData termValueString];
				break;
			}
			default:
				break;
		}
	}
	else if (endIP.section == 3) {
		// extra payment
		NSNumber *exPayItemNum = self.extraPaymentItems[endIP.row];
		A3LoanCalcExtraPaymentType exPayType = exPayItemNum.integerValue;

		if (exPayType == A3LC_ExtraPaymentMonthly) {
			if ([textField.text length] > 0) {
				self.loanData.extraPaymentMonthly = inputNum;
			}
			textField.text = [self.loanFormatter stringFromNumber:self.loanData.extraPaymentMonthly];
		}
	}

	[self updateLoanCalculation];
}

- (void)presentNumberKeyboardForTextField:(UITextField *)textField {
	if (_isNumberKeyboardVisible) {
		return;
	}
	_isNumberKeyboardVisible = YES;

	[self addNumberKeyboardNotificationObservers];
	A3NumberKeyboardViewController *numberKeyboardViewController = self.numberKeyboardViewController;
	
	CGRect bounds = [A3UIDevice screenBoundsAdjustedWithOrientation];
	CGFloat keyboardHeight = numberKeyboardViewController.keyboardHeight;
	UIView *keyboardView = numberKeyboardViewController.view;
	[self.view.superview addSubview:keyboardView];

	// KeyboardView를 addSubview를 해야 view가 load된다는 점, 정확히는 view에 access를 해야 load가 된다.
	// View가 load되기 전에는 IBOutlet이 nil입니다.
	[self textFieldDidBeginEditing:textField];

	_didPressClearKey = NO;
	_didPressNumberKey = NO;

	[numberKeyboardViewController reloadPrevNextButtons];

	keyboardView.frame = CGRectMake(0, self.view.bounds.size.height, bounds.size.width, keyboardHeight);
	[UIView animateWithDuration:0.3 animations:^{
		UIEdgeInsets contentInset = self.tableView.contentInset;
		contentInset.bottom += keyboardHeight;
		self.tableView.contentInset = contentInset;

		CGRect frame = keyboardView.frame;
		frame.origin.y -= keyboardHeight;
		keyboardView.frame = frame;
		
		NSIndexPath *indexPath = [self.tableView indexPathForCellSubview:textField];
		[self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
		
	} completion:^(BOOL finished) {
		[self addNumberKeyboardNotificationObservers];
	}];
	
}

- (void)dismissNumberKeyboard {
	if (!_isNumberKeyboardVisible) {
		return;
	}

	[self removeNumberKeyboardNotificationObservers];
	[self textFieldDidEndEditing:_editingTextField];

	_editingTextField = nil;
	self.editingObject = nil;

	A3NumberKeyboardViewController *keyboardViewController = self.numberKeyboardViewController;
	UIView *keyboardView = keyboardViewController.view;
	[UIView animateWithDuration:0.3 animations:^{
        UIEdgeInsets contentInset = self.tableView.contentInset;
        contentInset.bottom = 0;
        self.tableView.contentInset = contentInset;
        
		CGRect frame = keyboardView.frame;
		frame.origin.y += keyboardViewController.keyboardHeight;
		keyboardView.frame = frame;
	} completion:^(BOOL finished) {
		[keyboardView removeFromSuperview];
		[keyboardViewController removeFromParentViewController];
		self.numberKeyboardViewController = nil;
		_isNumberKeyboardVisible = NO;
	}];
}

#pragma mark - Number Keyboard Delegate

- (void)A3KeyboardController:(id)controller clearButtonPressedTo:(UIResponder *)keyInputDelegate {
	[super A3KeyboardController:controller clearButtonPressedTo:keyInputDelegate];
	_didPressClearKey = YES;
	_didPressNumberKey = NO;
}

- (void)keyboardViewControllerDidValueChange:(A3NumberKeyboardViewController *)vc {
	_didPressClearKey = NO;
	_didPressNumberKey = YES;
}

- (void)A3KeyboardController:(id)controller doneButtonPressedTo:(UIResponder *)keyInputDelegate {
	[self dismissNumberKeyboard];
}

- (void)currencySelectButtonAction:(NSNotification *)notification {
	[self dismissNumberKeyboard];

	[super currencySelectButtonAction:notification];
}

- (void)calculatorButtonAction {
	[super calculatorButtonAction];
	self.calculatorTargetTextField = _editingTextField;
	[self dismissNumberKeyboard];
}

- (void)calculatorDidDismissWithValue:(NSString *)value {
	_didPressNumberKey = YES;

	[super calculatorDidDismissWithValue:value];
}

#pragma mark - LoanCalcHistoryViewController delegate

- (void)putCurrentDataToHistory
{
	if (!_isComparisonMode) {
		if ([self.loanData calculated]) {
			[self putLoanHistory];
		}
	}
	else {
		if ([_loanDataA calculated] && [_loanDataB calculated]) {
			[self putComparisonHistory];
		}
	}
}

- (void)historyViewController:(UIViewController *)viewController selectLoanCalcHistory:(LoanCalcHistory *)history
{
	[self putCurrentDataToHistory];

    [self loadLoanCalcData:self.loanData fromLoanCalcHistory:history];
	[self saveLoanData];

	if (![self.defaultCurrencyCode isEqualToString:history.currencyCode]) {
		[self changeDefaultCurrencyCode:history.currencyCode];
	}

    _isComparisonMode = NO;
    [self selectSegment].selectedSegmentIndex = 0;
	self.calcItems = nil;
    [self.tableView reloadData];
    
    [self enableControls:YES];
    [self refreshRightBarItems];
}

- (void)historyViewController:(UIViewController *)viewController selectLoanCalcComparisonHistory:(LoanCalcComparisonHistory *)comparison {
	[self putCurrentDataToHistory];

	if (![self.defaultCurrencyCode isEqualToString:comparison.currencyCode]) {
		[self changeDefaultCurrencyCode:comparison.currencyCode];
	}

	LoanCalcHistory *historyA, *historyB;
	for (LoanCalcHistory *history in comparison.details) {
		if ([history.orderInComparison isEqualToString:@"A"]) {
			historyA = history;
		} else {
			historyB = history;
		}
	}
	[self loadLoanCalcData:self.loanDataA fromLoanCalcHistory:historyA];
	[self saveLoanDataA];
	[self loadLoanCalcData:self.loanDataB fromLoanCalcHistory:historyB];
	[self saveLoanDataB];

	_isComparisonMode = YES;
	[self selectSegment].selectedSegmentIndex = 1;
	self.calcItems = nil;
	[self.tableView reloadData];

	[self enableControls:YES];
	[self refreshRightBarItems];
}

- (void)historyViewControllerDismissed:(UIViewController *)viewController {
    [self enableControls:YES];
    [self refreshRightBarItems];
}

#pragma mark - LoanCalcExtraPaymentDelegate

- (void)didChangedLoanCalcExtraPayment:(LoanCalcData *)loanCalc
{
    if (!_isComparisonMode) {
        // reload extra payment info
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:3] withRowAnimation:UITableViewRowAnimationFade];
        
        [self updateLoanCalculation];
    }
}

#pragma mark - LoanCalcDataDelegate

- (void)didEditedLoanData:(LoanCalcData *)loanCalc
{
	[self reloadCurrencyCode];

    if (loanCalc == _loanDataA) {
        [self updateCompareLoanA];
    }
    else if (loanCalc == _loanDataB) {
        [self updateCompareLoanB];
    }
    
    /*
    // loan A, B가 모두 계산이 되었으면 history에 추가한다.
    if ([_loanDataA calculated] && [_loanDataB calculated]) {
        [self putComparisonHistory];
    }
     */
}

#pragma mark - LoanCalcSelectFrequencyDelegate

- (void)didSelectLoanCalcFrequency:(A3LoanCalcFrequencyType)frequencyType
{
    if (self.loanData.frequencyIndex != frequencyType) {
		self.loanData.frequencyIndex = frequencyType;
        
        [self.tableView reloadData];
        [self updateLoanCalculation];
    }
}

#pragma mark - LoanCalcSelectCalcForDelegate

- (void)didSelectCalculationForMode:(A3LoanCalcCalculationMode)calculationMode
{
    if (self.loanData.calculationMode != calculationMode) {
		self.loanData.calculationMode = calculationMode;
        [self refreshCalcFor];
    }
}

#pragma mark - Table view delegate

- (void)didSelectExtraPaymentSectionAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView
{
    // extra payment
    NSNumber *exPaymentItemNum = self.extraPaymentItems[indexPath.row];
    A3LoanCalcExtraPaymentType exPaymentItem = exPaymentItemNum.integerValue;
    
    if (exPaymentItem == A3LC_ExtraPaymentMonthly) {
        A3LoanCalcTextInputCell *inputCell = (A3LoanCalcTextInputCell *)[tableView cellForRowAtIndexPath:indexPath];
        [inputCell.textField becomeFirstResponder];
    }
    else if ((exPaymentItem == A3LC_ExtraPaymentYearly) || (exPaymentItem == A3LC_ExtraPaymentOnetime)) {
		[self dismissNumberKeyboard];
		[self dismissDatePicker];
		
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"LoanCalculatorPhoneStoryBoard" bundle:nil];
        A3LoanCalcExtraPaymentViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"A3LoanCalcExtraPaymentViewController"];
        viewController.delegate = self;
        viewController.exPaymentType = exPaymentItem;
        viewController.loanCalcData = self.loanData;
        
        if (IS_IPHONE) {
            [self.navigationController pushViewController:viewController animated:YES];
        }
        else {
            [self enableControls:NO];
            [[[A3AppDelegate instance] rootViewController_iPad] presentRightSideViewController:viewController toViewController:nil];
        }
    }
}

- (void)didSelectAdvancedSectionAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView
{
    if (_advItems[indexPath.row] == self.startDateItem) {
        A3LoanCalcTextInputCell *inputCell = (A3LoanCalcTextInputCell *)[tableView cellForRowAtIndexPath:indexPath];
        [inputCell.textField becomeFirstResponder];
        
        preDate = self.loanData.startDate;
        
        if ([_advItems containsObject:self.dateInputItem]) {
            [self dismissDatePicker];
        }
        else {
            [self datePickerActiveFromIndexPath:indexPath];
        }
    }
    else if (_advItems[indexPath.row] == self.noteItem) {
        A3WalletNoteCell *noteCell = (A3WalletNoteCell *)[tableView cellForRowAtIndexPath:indexPath];
        [noteCell.textView becomeFirstResponder];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self clearEverything];
    
    if (_isComparisonMode) {
        if (indexPath.section == 0) {
            
        }
        else if (indexPath.section == 1 || indexPath.section == 2){
			[self dismissNumberKeyboard];
			[self dismissDatePicker];
			
            NSString *storyboardName = IS_IPAD ? @"LoanCalculatorPadStoryBoard" : @"LoanCalculatorPhoneStoryBoard";
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
            A3LoanCalcLoanDetailViewController *viewController = [storyBoard instantiateViewControllerWithIdentifier:@"A3LoanCalcLoanDetailViewController"];
            if (indexPath.section == 1) {
                viewController.navigationItem.title = NSLocalizedString(@"Loan A", @"Loan A");
                viewController.loanData = self.loanDataA;
				viewController.isLoanData_A = YES;
            }
            else {
                viewController.navigationItem.title = NSLocalizedString(@"Loan B", @"Loan B");
                viewController.loanData = self.loanDataB;
				viewController.isLoanData_A = NO;
            }
            viewController.delegate = self;
            [self.navigationController pushViewController:viewController animated:YES];
        }
        
    }
    else {
        if (indexPath.section == 0) {
            // graph
        }
        else if (indexPath.section == 1) {
			[self dismissNumberKeyboard];
			[self dismissDatePicker];
			
            // calculation for
            A3LoanCalcSelectModeViewController *viewController = [[A3LoanCalcSelectModeViewController alloc] initWithStyle:UITableViewStyleGrouped];
            viewController.delegate = self;
            viewController.currentCalcMode = self.loanData.calculationMode;
            
            if (IS_IPHONE) {
                [self.navigationController pushViewController:viewController animated:YES];
            }
            else {
				[self enableControls:NO];
				[[[A3AppDelegate instance] rootViewController_iPad] presentRightSideViewController:viewController toViewController:nil];
			}
        }
        else if (indexPath.section == 2) {
            // calculation items
            NSNumber *calcItemNum = self.calcItems[indexPath.row];
            A3LoanCalcCalculationItem calcItem = calcItemNum.integerValue;
            
            if (calcItem == A3LC_CalculationItemFrequency) {
				[self dismissNumberKeyboard];
				[self dismissDatePicker];
				
                A3LoanCalcSelectFrequencyViewController *viewController = [[A3LoanCalcSelectFrequencyViewController alloc] initWithStyle:UITableViewStyleGrouped];
                viewController.delegate = self;
                viewController.currentFrequency = self.loanData.frequencyIndex;
                
                if (IS_IPHONE) {
                    [self.navigationController pushViewController:viewController animated:YES];
                }
                else {
					[self enableControls:NO];
					[[[A3AppDelegate instance] rootViewController_iPad] presentRightSideViewController:viewController toViewController:nil];
				}
            }
            else {
                A3LoanCalcTextInputCell *inputCell = (A3LoanCalcTextInputCell *)[tableView cellForRowAtIndexPath:indexPath];
				[self textFieldShouldBeginEditing:inputCell.textField];
            }
        }
        
        if (self.loanData.showExtraPayment && self.loanData.frequencyIndex == A3LC_FrequencyMonthly) {
            if (indexPath.section == 3) {
                [self didSelectExtraPaymentSectionAtIndexPath:indexPath tableView:tableView];
            }
            if (indexPath.section == 4) {
                [self didSelectAdvancedSectionAtIndexPath:indexPath tableView:tableView];
            }
        }
        else {
            if (indexPath.section == 3) {
                [self didSelectAdvancedSectionAtIndexPath:indexPath tableView:tableView];
            }
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if (_isComparisonMode) {
        return 3;
    }
    else {
        if (self.loanData.showExtraPayment && self.loanData.frequencyIndex == A3LC_FrequencyMonthly) {
            return 5;
        }
        else {
            return 4;
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (_isComparisonMode) {
        if (section == 0) {
            return _didReceiveAds ? 2 : 1;
        }
        return 1;
    }
    else {
        if (section == 0) {
            return _didReceiveAds ? 2 : 1;   // loan graph
        }
        else if (section == 1) {
            return 1;   // calculation
        }
        else if (section == 2) {
            return self.calcItems.count;
        }
        else if (section == 3) {
            if (self.loanData.showExtraPayment && self.loanData.frequencyIndex == A3LC_FrequencyMonthly) {
                return self.extraPaymentItems.count;
            }
            else {
                return self.advItems.count;
            }
        }
        else if (section == 4){
            // advanced
            return self.advItems.count;
        }
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_isComparisonMode) {
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                return (IS_IPHONE) ? 165 : 225;
            } else {
                return [self bannerHeight];
            }
        }
        else {
            return (IS_IPHONE) ? 160 : 194;
        }
    }
    else {
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                return (IS_IPHONE) ? 133 : 192;
            } else {
                return [self bannerHeight];
            }
        }
        else if (indexPath.section == 1) {
            if ([self.loanData calculated]) {
                if (IS_IPAD) {
                    return 44;
                }
                else {
                    return 62;
                }
            }
            else {
                return 44;
            }
        }
        else if (indexPath.section == 3) {
            if (self.loanData.showExtraPayment && self.loanData.frequencyIndex == A3LC_FrequencyMonthly) {
                return 44;
            }
            else {
                if (self.advItems[indexPath.row] == self.noteItem) {
                    return [UIViewController noteCellHeight];
                }
                else if (_advItems[indexPath.row] == self.dateInputItem) {
                    return 218.0;
                }
                return 44;
            }
        }
        else if (indexPath.section == 4) {
            if (self.advItems[indexPath.row] == self.noteItem) {
				return [UIViewController noteCellHeight];
            }
            else if (_advItems[indexPath.row] == self.dateInputItem) {
                return 218.0;
            }
            return 44;
        }
        else {
            return 44;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat nonTitleHeight = 35.0;
    CGFloat titleHeight = 55.0;

    if (!_isComparisonMode) {
        if (section == 0) {
            return 1;
        }
        else if (section == 1) {
            return nonTitleHeight -1;
        }
        else if (section == 2) {
            return nonTitleHeight -1;
        }
        else if (section == 3) {
            return titleHeight - 1;
//            return self.loanData.showExtraPayment && self.loanData.frequencyIndex == A3LC_FrequencyMonthly ? titleHeight - 1 : 1;
        }
        else if (section == 4) {
            return self.loanData.showExtraPayment && self.loanData.frequencyIndex == A3LC_FrequencyMonthly ? titleHeight - 1 : titleHeight - 2;
        }
        return 1;
    }
    else {
        if (section == 0) {
            return 1;
        }
        else {
            return nonTitleHeight -1;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
	CGFloat height = 1;
    if (_isComparisonMode && section == 2) {
		height = 38;
    }
    else if (!_isComparisonMode && section == (self.loanData.showExtraPayment && self.loanData.frequencyIndex == A3LC_FrequencyMonthly ? 4 : 3)) {
		height = 38;
    }

	FNLOG(@"%f", height);
    return height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (_isComparisonMode) {
        
    }
    else {
        if (section == (self.loanData.showExtraPayment && self.loanData.frequencyIndex == A3LC_FrequencyMonthly ? 4 : 3)) {
            return self.advancedTitleView;
        }
    }
    
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (_isComparisonMode) {
        
    }
    else {
        if (section == 3) {
            return [self.loanData showExtraPayment] ? NSLocalizedString(@"EXTRA PAYMENTS", @"EXTRA PAYMENTS") : nil;
        }
    }
    
    return nil;
}

-(void)scrollToTopOfTableView {
	[UIView beginAnimations:A3AnimationIDKeyboardWillShow context:nil];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationCurve:7];
	[UIView setAnimationDuration:0.35];
	if (self.tableView.contentInset.top == 0) {
        if SYSTEM_VERSION_LESS_THAN(@"11") {
            self.tableView.contentOffset = CGPointMake(0.0, 0.0);
        } else {
            [self.tableView scrollsToTop];
        }
	}
	else {
		self.tableView.contentOffset = CGPointMake(0.0, -(self.navigationController.navigationBar.bounds.size.height + [A3UIDevice statusBarHeight]));
	}
	[UIView commitAnimations];
}

#pragma mark Configure TableView Cell

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell;

	if (_isComparisonMode) {
		cell = [self tableView:tableView cellForComparisonModeRowAtIndexPath:indexPath];
	}
	else {
		cell = [self tableView:tableView cellForLoanModeRowAtIndexPath:indexPath];
	}
	return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForComparisonModeRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell=nil;
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [UIView setAnimationsEnabled:NO];
            A3LoanCalcCompareGraphCell *compareCell = [tableView dequeueReusableCellWithIdentifier:A3LoanCalcCompareGraphCellID forIndexPath:indexPath];
            compareCell.selectionStyle = UITableViewCellSelectionStyleNone;
            [compareCell adjustSubviewsFontSize];

            // loan data A,B
            if ([_loanDataA calculated] || [_loanDataB calculated]) {
                [self displayCompareCell:compareCell];
            } else {
                [self makeCompareCellClear:compareCell];
            }

            cell = compareCell;

            [UIView setAnimationsEnabled:YES];

            if (_didReceiveAds) {
                cell.separatorInset = UIEdgeInsetsZero;
                cell.layoutMargins = UIEdgeInsetsZero;
            }
        } else {
            cell = [tableView dequeueReusableCellWithIdentifier:A3LoanCalcAdCellID forIndexPath:indexPath];

            UIView *bannerView = [self bannerView];
            [cell addSubview:bannerView];

            [bannerView makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(cell);
                make.top.equalTo(cell);
                make.right.equalTo(cell);
                make.bottom.equalTo(cell).with.offset(-1);
            }];
        }
    }
    else if (indexPath.section == 1){
        A3LoanCalcLoanInfoCell *infoCell = [tableView dequeueReusableCellWithIdentifier:A3LoanCalcLoanInfoCellID forIndexPath:indexPath];
        infoCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        infoCell.markLabel.text = @"A";

		[self updateInfoCell:infoCell withLoanInfo:_loanDataA];
//        if ([_loanDataA calculated]) {
//            [self updateInfoCell:infoCell withLoanInfo:_loanDataA];
//        }
//        else {
//            [self makeClearInfoCell:infoCell];
//        }
        
        if (IS_RETINA) {
            for (UIView *line in infoCell.hori1PxLines) {
                CGRect rect = line.frame;
                rect.size.height = 0.5f;
                line.frame = rect;
            }
        }
        
        cell = infoCell;
    }
    else if (indexPath.section == 2){
        A3LoanCalcLoanInfoCell *infoCell = [tableView dequeueReusableCellWithIdentifier:A3LoanCalcLoanInfoCellID forIndexPath:indexPath];
        infoCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        infoCell.markLabel.text = @"B";

		[self updateInfoCell:infoCell withLoanInfo:_loanDataB];
//        if ([_loanDataB calculated]) {
//            [self updateInfoCell:infoCell withLoanInfo:_loanDataB];
//        }
//        else {
//            [self makeClearInfoCell:infoCell];
//        }
        
        if (IS_RETINA) {
            for (UIView *line in infoCell.hori1PxLines) {
                CGRect rect = line.frame;
                rect.size.height = 0.5f;
                line.frame = rect;
            }
        }
        
        cell = infoCell;
    }
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForLoanModeRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    switch ([indexPath section]) {
        case 0:
        {
            if (indexPath.row == 0) {
                [UIView setAnimationsEnabled:NO];
                // graph
                A3LoanCalcLoanGraphCell *graphCell = [tableView dequeueReusableCellWithIdentifier:A3LoanCalcLoanGraphCellID forIndexPath:indexPath];
                [graphCell.monthlyButton addTarget:self action:@selector(monthlyButtonAction:) forControlEvents:UIControlEventTouchUpInside];
                [graphCell.totalButton addTarget:self action:@selector(totalButtonAction:) forControlEvents:UIControlEventTouchUpInside];
                [graphCell.infoButton addTarget:self action:@selector(infoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
                [graphCell adjustSubviewsFontSize];
                [graphCell adjustSubviewsPosition];
                
                if ([self.loanData calculated]) {
                    [self displayGraphCell:graphCell];
                } else {
                    [self makeGraphCellClear:graphCell];
                }
                
                [graphCell.monthlyButton setTitle:[LoanCalcString titleOfFrequency:self.loanData.frequencyIndex] forState:UIControlStateNormal];
                graphCell.monthlyButton.titleLabel.font = IS_IPHONE ? [UIFont systemFontOfSize:12] : [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
                graphCell.totalButton.titleLabel.font = IS_IPHONE ? [UIFont systemFontOfSize:12] : [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
                
                cell = graphCell;
                [UIView setAnimationsEnabled:YES];

                if (_didReceiveAds) {
                    cell.separatorInset = UIEdgeInsetsZero;
                    cell.layoutMargins = UIEdgeInsetsZero;
                }
            } else {
                cell = [tableView dequeueReusableCellWithIdentifier:A3LoanCalcAdCellID forIndexPath:indexPath];

                UIView *bannerView = [self bannerView];
                [cell addSubview:bannerView];
                
                [bannerView makeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(cell);
                    make.top.equalTo(cell);
                    make.right.equalTo(cell);
                    make.bottom.equalTo(cell).with.offset(-1);
                }];
            }
			break;
		}

        case 1:
        {
            // calculation
            cell = [tableView dequeueReusableCellWithIdentifier:A3LoanCalcSelectCellID forIndexPath:indexPath];
            cell.textLabel.text = NSLocalizedString(@"Calculation", @"Calculation");
            if ([self.loanData calculated]) {
                
                NSDictionary *textAttributes1 = @{
                                                  NSFontAttributeName : [UIFont systemFontOfSize:17.0],
                                                  NSForegroundColorAttributeName:[UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0]
                                                  };
                
                NSDictionary *textAttributes2 = @{
                                                  NSFontAttributeName : IS_IPAD ? [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline] : [UIFont systemFontOfSize:17.0],
                                                  NSForegroundColorAttributeName:[UIColor blackColor]
                                                  };
                
                NSString *calcuTitle = [LoanCalcString titleOfCalFor:self.loanData.calculationMode];
                NSString *resultText = [self resultTextOfLoan:self.loanData forCalcuFor:self.loanData.calculationMode];
                
                if (IS_IPAD) {
                    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] init];
                    NSMutableAttributedString *text1 = [[NSMutableAttributedString alloc] initWithString:calcuTitle attributes:textAttributes1];
                    NSMutableAttributedString *text2 = [[NSMutableAttributedString alloc] initWithString:resultText attributes:textAttributes2];
                    NSMutableAttributedString *divide = [[NSMutableAttributedString alloc] initWithString:@" " attributes:textAttributes2];
                    [attrString appendAttributedString:text1];
                    [attrString appendAttributedString:divide];
                    [attrString appendAttributedString:text2];
                    cell.detailTextLabel.attributedText = attrString;
                    cell.detailTextLabel.numberOfLines = 1;
                    cell.textLabel.numberOfLines = 1;
                }
                else {
                    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] init];
                    NSMutableAttributedString *text1 = [[NSMutableAttributedString alloc] initWithString:calcuTitle attributes:textAttributes1];
                    NSMutableAttributedString *text2 = [[NSMutableAttributedString alloc] initWithString:resultText attributes:textAttributes2];
                    NSMutableAttributedString *line = [[NSMutableAttributedString alloc] initWithString:@"\n" attributes:textAttributes2];
                    [attrString appendAttributedString:text1];
                    [attrString appendAttributedString:line];
                    [attrString appendAttributedString:text2];
                    cell.detailTextLabel.attributedText = attrString;
                    cell.detailTextLabel.numberOfLines = 2;
                    cell.textLabel.numberOfLines = 2;
                }
            }
            else {
                cell.detailTextLabel.text = [LoanCalcString titleOfCalFor:self.loanData.calculationMode];
                cell.detailTextLabel.font = [UIFont systemFontOfSize:17];
                cell.detailTextLabel.textColor = [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
                cell.detailTextLabel.numberOfLines = 1;
                cell.textLabel.numberOfLines = 1;
            }
			break;
		}

        case 2:
        {
            // calculation items
            NSNumber *calcItemNum = self.calcItems[indexPath.row];
            A3LoanCalcCalculationItem calcItem = calcItemNum.integerValue;
            
            if (calcItem == A3LC_CalculationItemFrequency) {
                cell = [tableView dequeueReusableCellWithIdentifier:A3LoanCalcSelectCellID forIndexPath:indexPath];
                cell.textLabel.text = [LoanCalcString titleOfItem:calcItem];
                cell.detailTextLabel.text = [LoanCalcString titleOfFrequency:self.loanData.frequencyIndex];
                cell.detailTextLabel.font = [UIFont systemFontOfSize:17];
                cell.detailTextLabel.textColor = [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
            }
            else {
                A3LoanCalcTextInputCell *inputCell = [tableView dequeueReusableCellWithIdentifier:A3LoanCalcTextInputCellID forIndexPath:indexPath];
                inputCell.selectionStyle = UITableViewCellSelectionStyleNone;
                inputCell.textField.delegate = self;
                inputCell.textField.font = [UIFont systemFontOfSize:17];
                inputCell.textField.textColor = [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
                
                [self configureInputCell:inputCell withCalculationItem:calcItem];
                
                cell = inputCell;
            }
			break;
		}

        case 3:
        case 4:
        {
            if (self.loanData.showExtraPayment && self.loanData.frequencyIndex == A3LC_FrequencyMonthly) {
                if ([indexPath section] == 3) {
                    cell = [self cellOfExtraPaymentAtIndexPath:indexPath tableView:tableView];
                }
                else if([indexPath section] == 4) {
                    cell = [self cellOfAdvancedAtIndexPath:indexPath tableView:tableView];
                }
            }
            else {
                if ([indexPath section] == 3) {
                    cell = [self cellOfAdvancedAtIndexPath:indexPath tableView:tableView];
                }
            }
			break;
		}


        default:
            break;
    }
    
    return cell;
}

- (UITableViewCell *)cellOfExtraPaymentAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView {
    // extra payment
    UITableViewCell *cell;
    NSNumber *exPaymentItemNum = self.extraPaymentItems[indexPath.row];
    A3LoanCalcExtraPaymentType exPaymentItem = exPaymentItemNum.integerValue;
    
    if (exPaymentItem == A3LC_ExtraPaymentMonthly) {
        A3LoanCalcTextInputCell *inputCell = [tableView dequeueReusableCellWithIdentifier:A3LoanCalcTextInputCellID forIndexPath:indexPath];
        inputCell.selectionStyle = UITableViewCellSelectionStyleNone;
        inputCell.textField.font = [UIFont systemFontOfSize:17];
        inputCell.textField.textColor = [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
        inputCell.textField.delegate = self;
        
        [self configureInputCell:inputCell withExtraPaymentItem:exPaymentItem];
        
        cell = inputCell;
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:A3LoanCalcSelectCellID forIndexPath:indexPath];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:17];
        cell.detailTextLabel.textColor = [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
        
        if (exPaymentItem == A3LC_ExtraPaymentYearly) {
            [self configureExtraPaymentYearlyCell:cell];
        }
        else if (exPaymentItem == A3LC_ExtraPaymentOnetime) {
            [self configureExtraPaymentOneTimeCell:cell];
        }
    }
    return cell;
}

- (UITableViewCell *)cellOfAdvancedAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView {
    // advanced
    UITableViewCell *cell;
    if (_advItems[indexPath.row] == self.startDateItem) {
        A3LoanCalcTextInputCell *inputCell = [tableView dequeueReusableCellWithIdentifier:A3LoanCalcTextInputCellID forIndexPath:indexPath];
        inputCell.selectionStyle = UITableViewCellSelectionStyleNone;
        inputCell.titleLabel.text = _startDateItem[@"Title"];
        inputCell.textField.font = [UIFont systemFontOfSize:17];
        inputCell.textField.delegate = self;
        inputCell.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"None", @"None")
                                                                                    attributes:@{NSForegroundColorAttributeName:inputCell.textField.textColor}];
        inputCell.textField.userInteractionEnabled = NO;
        inputCell.textField.hidden = YES;
        
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        if (IS_IPAD || [NSDate isFullStyleLocale]) {
            [df setDateStyle:NSDateFormatterFullStyle];
        }
        else {
            [df setDateFormat:[df customFullStyleFormat]];
        }
        inputCell.textField.text = [df stringFromDate:self.loanData.startDate];

        if ([_advItems containsObject:self.dateInputItem]) {
            //            inputCell.textField.textColor = [UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1.0];
            inputCell.textField.textColor = [[A3UserDefaults standardUserDefaults] themeColor];
            inputCell.detailLabel.textColor = [[A3UserDefaults standardUserDefaults] themeColor];
        } else {
            inputCell.textField.textColor = [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
            inputCell.detailLabel.textColor = [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
        }
        
        inputCell.detailLabel.font = [UIFont systemFontOfSize:17];
        inputCell.detailLabel.text = [df stringFromDate:self.loanData.startDate];
        if ([inputCell.detailLabel.text length] == 0) {
            inputCell.detailLabel.text = NSLocalizedString(@"None", @"None");
        }
        [inputCell.detailLabel sizeToFit];
        inputCell.detailLabel.center = inputCell.contentView.center;
        CGRect frame = inputCell.detailLabel.frame;
        frame.origin.x = inputCell.contentView.frame.size.width - (frame.size.width + 15);
        inputCell.detailLabel.frame = frame;
        inputCell.detailLabel.hidden = NO;

        
        
        cell = inputCell;
    }
    else if (_advItems[indexPath.row] == self.noteItem) {
        // note
        A3WalletNoteCell *noteCell = [tableView dequeueReusableCellWithIdentifier:A3LoanCalcLoanNoteCellID forIndexPath:indexPath];
        [noteCell setupTextView];
        noteCell.textView.delegate = self;
        noteCell.textView.text = self.loanData.note;
        
        cell = noteCell;
    }
    else if (_advItems[indexPath.row] == self.dateInputItem) {
        // date input cell
        A3WalletDateInputCell *dateInputCell = [tableView dequeueReusableCellWithIdentifier:A3LoanCalcDateInputCellID forIndexPath:indexPath];
        dateInputCell.selectionStyle = UITableViewCellSelectionStyleNone;
        dateInputCell.datePicker.date = preDate;
        dateInputCell.datePicker.datePickerMode = UIDatePickerModeDate;
        [dateInputCell.datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
        
        cell = dateInputCell;
    }
    
    return cell;
}

- (void)configureInputCell:(A3LoanCalcTextInputCell *)inputCell withCalculationItem:(A3LoanCalcCalculationItem) calcItem
{
    inputCell.titleLabel.text = [LoanCalcString titleOfItem:calcItem];
    NSString *placeHolderText = @"";
    NSString *textFieldText = @"";
    switch (calcItem) {
        case A3LC_CalculationItemDownPayment:
        {
            textFieldText = [self.loanFormatter stringFromNumber:self.loanData.downPayment];
            break;
        }
        case A3LC_CalculationItemInterestRate:
        {
            placeHolderText = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Annual", @"Annual"), [self.percentFormatter stringFromNumber:@(0)]];
            textFieldText = [self.loanData interestRateString];
            break;
        }
        case A3LC_CalculationItemPrincipal:
        {
            textFieldText = [self.loanFormatter stringFromNumber:self.loanData.principal];
            break;
        }
        case A3LC_CalculationItemRepayment:
        {
            placeHolderText = [self.loanFormatter stringFromNumber:@(0)];
            textFieldText = [self.loanFormatter stringFromNumber:self.loanData.repayment];
            break;
        }
        case A3LC_CalculationItemTerm:
        {
            placeHolderText = NSLocalizedString(@"years or months", @"years or months");
            textFieldText = [self.loanData termValueString];
			break;
        }
        default:
            break;
	}
    inputCell.textField.text = textFieldText;
    inputCell.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeHolderText
                                                                                attributes:@{NSForegroundColorAttributeName:inputCell.textField.textColor}];
}

- (void)configureInputCell:(A3LoanCalcTextInputCell *)inputCell withExtraPaymentItem:(A3LoanCalcExtraPaymentType) extraPaymentItem
{
    inputCell.titleLabel.text = [LoanCalcString titleOfExtraPayment:extraPaymentItem];
    //    NSString *placeHolderText = [self.loanFormatter stringFromNumber:@(0)];
    NSString *placeHolderText = @"";
    NSString *textFieldText = [self.loanFormatter stringFromNumber:self.loanData.extraPaymentMonthly];
    inputCell.textField.text = textFieldText;
    inputCell.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeHolderText
                                                                                attributes:@{NSForegroundColorAttributeName:inputCell.textField.textColor}];
}

- (void)reloadCurrencyCode {
	NSString *customCurrencyCode = [[A3SyncManager sharedSyncManager] objectForKey:A3LoanCalcUserDefaultsCustomCurrencyCode];
	if ([customCurrencyCode length]) {
		[self.loanFormatter setCurrencyCode:customCurrencyCode];
	}
}

#pragma mark - AdMob

- (void)bannerViewDidReceiveAd:(GADBannerView *)bannerView {
    _didReceiveAds = YES;
    
    [self.tableView reloadData];
}

@end
