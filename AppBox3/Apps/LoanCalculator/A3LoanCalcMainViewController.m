//
//  A3LoanCalcMainViewController.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 12. 6..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3LoanCalcMainViewController.h"
#import "A3LoanCalcLoanDetailViewController.h"
#import "A3LoanCalcSettingViewController.h"
#import "A3LoanCalcSelectModeViewController.h"
#import "A3LoanCalcSelectFrequencyViewController.h"
#import "A3LoanCalcExtraPaymentViewController.h"
#import "A3LoanCalcMonthlyDataViewController.h"
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
#import "A3AppDelegate.h"
#import "UIViewController+A3AppCategory.h"
#import "UIViewController+MMDrawerController.h"
#import "UIViewController+A3Addition.h"
#import "SFKImage.h"
#import "UIViewController+LoanCalcAddtion.h"
#import "A3CalculatorDelegate.h"
#import "A3SearchViewController.h"
#import "UITableView+utility.h"

#define LoanCalcModeSave @"LoanCalcModeSave"

@interface A3LoanCalcMainViewController () <LoanCalcHistoryViewControllerDelegate, LoanCalcExtraPaymentDelegate, LoanCalcLoanDataDelegate, LoanCalcSelectCalcForDelegate, LoanCalcSelectFrequencyDelegate, A3KeyboardDelegate, UITextFieldDelegate, UITextViewDelegate, UIPopoverControllerDelegate, A3CalculatorDelegate, A3SearchViewControllerDelegate>
{
    BOOL		_isShowMoreMenu;
    
    // Loan mode
    BOOL        _isComparisonMode;
    BOOL        _isTotalMode;

    BOOL isFirstViewLoad;
    
    NSIndexPath *currentIndexPath;
    
    float textViewHeight;
    NSDate *preDate;
}

@property (nonatomic, strong) NSArray *moreMenuButtons;
@property (nonatomic, strong) UIView *moreMenuView;
@property (nonatomic, strong) UISegmentedControl *selectSegment;
@property (nonatomic, strong) NSMutableDictionary *controlsEnableInfo;
// Loan mode
@property (nonatomic, weak)	UITextView *currentTextView;
@property (nonatomic, strong) LoanCalcData *loanData;
@property (nonatomic, strong) NSMutableArray *calcItems;
@property (nonatomic, strong) NSMutableArray *extraPaymentItems;
@property (nonatomic, strong) NSMutableArray *advItems;
@property (nonatomic, strong) NSDictionary *startDateItem;
@property (nonatomic, strong) NSMutableDictionary *dateInputItem;
@property (nonatomic, strong) NSDictionary *noteItem;
@property (nonatomic, strong) UIView *advancedTitleView;
// comparison mode
@property (nonatomic, strong) LoanCalcData *loanDataA;
@property (nonatomic, strong) LoanCalcData *loanDataB;
@property (nonatomic, strong) UIPopoverController *sharePopoverController;
@property (nonatomic, weak) UITextField *calculatorTargetTextField;
@property (nonatomic, copy) NSString *textFieldTextBeforeEditing;

@end

@implementation A3LoanCalcMainViewController

NSString *const A3LoanCalcSelectCellID = @"A3LoanCalcSelectCell";
NSString *const A3LoanCalcTextInputCellID = @"A3LoanCalcTextInputCell";
NSString *const A3LoanCalcLoanInfoCellID = @"A3LoanCalcLoanInfoCell";
NSString *const A3LoanCalcLoanGraphCellID = @"A3LoanCalcLoanGraphCell";
NSString *const A3LoanCalcLoanNoteCellID = @"A3WalletNoteCell";
NSString *const A3LoanCalcCompareGraphCellID = @"A3LoanCalcCompareGraphCell";
NSString *const A3LoanCalcDateInputCellID = @"A3WalletDateInputCell";


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self makeBackButtonEmptyArrow];
    [self leftBarButtonAppsButton];
    
    self.navigationItem.hidesBackButton = YES;

    self.navigationItem.titleView = self.selectSegment;
    
    if (IS_IPHONE) {
        UIImage *image = [UIImage imageNamed:@"more"];
        UIBarButtonItem *moreButtonItem = [[UIBarButtonItem alloc] initWithImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStylePlain target:self action:@selector(moreButtonAction:)];

        UIBarButtonItem *composeItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(composeButtonAction:)];
        self.navigationItem.rightBarButtonItems = @[moreButtonItem, composeItem];
        
    } else {
        UIBarButtonItem *share = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"share"] style:UIBarButtonItemStylePlain target:self action:@selector(shareButtonAction:)];
        UIBarButtonItem *history = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"history"] style:UIBarButtonItemStylePlain target:self action:@selector(historyButtonAction:)];
        UIBarButtonItem *setting = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"general"] style:UIBarButtonItemStylePlain target:self action:@selector(settingsButtonAction:)];
        UIBarButtonItem *composeItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(composeButtonAction:)];

        
        self.navigationItem.rightBarButtonItems = @[setting, history, composeItem, share];
    }
    
    isFirstViewLoad = YES;
    [self.percentFormatter setMaximumFractionDigits:3];
    
    // load data
	[self loadPreviousCalculation];
    
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.contentInset = UIEdgeInsetsMake(-1, 0, 36, 0);
    self.tableView.separatorColor = [self tableViewSeparatorColor];
    
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rightSubViewDismissed:) name:@"A3_Pad_RightSubViewDismissed" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currencyCodeChanged) name:A3LoanCalcCurrencyCodeChanged object:nil];

	// Keyboard Notification
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];

    [self registerContentSizeCategoryDidChangeNotification];
}

- (void)cleanUp {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)currencyCodeChanged {
	[self reloadCurrencyCode];
	[self.tableView reloadData];
}

- (void)contentSizeDidChange:(NSNotification *) notification
{
    [self.tableView reloadData];
}

- (void)rightSubViewDismissed:(NSNotification *)noti
{
    [self enableControls:YES];
    
    [self refreshRightBarItems];
}

- (void)enableControls:(BOOL) onoff {
	if (!IS_IPAD) {
		return;
	}
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

			if (cell.monthlyButton.layer.borderColor != [UIColor clearColor].CGColor) {
				cell.monthlyButton.layer.borderColor = cell.monthlyButton.currentTitleColor.CGColor;
			}
			if (cell.totalButton.layer.borderColor != [UIColor clearColor].CGColor) {
				cell.totalButton.layer.borderColor = cell.totalButton.currentTitleColor.CGColor;
			}
		}
	}
	else {
		[self.controlsEnableInfo setObject:@(historyItem.enabled) forKey:@"historyItem"];
		[self.controlsEnableInfo setObject:@(shareItem.enabled) forKey:@"shareItem"];
		historyItem.enabled = NO;
		shareItem.enabled = NO;
		settingItem.enabled = NO;
		composeItem.enabled = NO;
		self.selectSegment.enabled = NO;
		self.selectSegment.tintColor = [UIColor colorWithRed:196.0 / 255.0 green:196.0 / 255.0 blue:196.0 / 255.0 alpha:1.0];
		self.navigationItem.leftBarButtonItem.enabled = NO;

		if (!_isComparisonMode) {
			A3LoanCalcLoanGraphCell *cell = (A3LoanCalcLoanGraphCell *) [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
			cell.infoButton.enabled = NO;
			cell.monthlyButton.enabled = NO;
			cell.totalButton.enabled = NO;

			if (cell.monthlyButton.layer.borderColor != [UIColor clearColor].CGColor) {
				cell.monthlyButton.layer.borderColor = [UIColor colorWithRed:196.0 / 255.0 green:196.0 / 255.0 blue:196.0 / 255.0 alpha:1.0].CGColor;
			}
			if (cell.totalButton.layer.borderColor != [UIColor clearColor].CGColor) {
				cell.totalButton.layer.borderColor = [UIColor colorWithRed:196.0 / 255.0 green:196.0 / 255.0 blue:196.0 / 255.0 alpha:1.0].CGColor;
			}
		}
	}


}

- (void)appWillResignActive:(NSNotification*)noti
{
    [self clearEverything];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    /*
    if (isFirstViewLoad) {
        NSIndexPath *ip = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView reloadRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationAutomatic];
        isFirstViewLoad = NO;
    }
     */
    
    [self refreshRightBarItems];
}

- (void)dealloc
{
    [self removeObserver];
}

- (void)removeObserver {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)settingNoti:(NSNotification *)noti
{
    if ([noti.name isEqualToString:A3LoanCalcNotificationExtraPaymentEnabled]) {
        
        self.loanData.showExtraPayment = YES;
        self.loanDataA.showExtraPayment = YES;
        self.loanDataB.showExtraPayment = YES;

        if (!_isComparisonMode) {
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:3] withRowAnimation:UITableViewRowAnimationFade];
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
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:3] withRowAnimation:UITableViewRowAnimationFade];
            [self updateLoanCalculation];
        }
    }
    else if ([noti.name isEqualToString:A3LoanCalcNotificationDownPaymentEnabled]) {
        
        _calcItems = nil;
        
        self.loanData.showDownPayment = YES;
        self.loanDataA.showDownPayment = YES;
        self.loanDataB.showDownPayment = YES;

        if (!_isComparisonMode) {
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
    else if ([noti.name isEqualToString:A3LoanCalcNotificationDownPaymentDisabled]) {
        
        _calcItems = nil;
        
        self.loanData.showDownPayment = NO;
        self.loanData.downPayment = nil;
        
        self.loanDataA.showDownPayment = NO;
        self.loanDataA.downPayment = nil;
        self.loanDataB.showDownPayment = NO;
        self.loanDataB.downPayment = nil;
        
        if (_loanData.calculationFor == A3LC_CalculationForDownPayment) {
            _loanData.calculationFor = A3LC_CalculationForRepayment;
        }
        
        if (_loanDataA.calculationFor == A3LC_CalculationForDownPayment) {
            _loanDataA.calculationFor = A3LC_CalculationForRepayment;
        }
        
        if (_loanDataB.calculationFor == A3LC_CalculationForDownPayment) {
            _loanDataB.calculationFor = A3LC_CalculationForRepayment;
        }
        
        if (!_isComparisonMode) {
            
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 2)] withRowAnimation:UITableViewRowAnimationFade];
            [self updateLoanCalculation];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refreshRightBarItems {
    if (IS_IPAD) {
        // 히스토리가 존재하는지 체크
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"compareWith = nil"];
        LoanCalcHistory *history = [LoanCalcHistory MR_findFirstWithPredicate:predicate sortedBy:@"created" ascending:NO];
        LoanCalcComparisonHistory *comparison = [LoanCalcComparisonHistory MR_findFirstOrderedByAttribute:@"calculateDate" ascending:NO];
        
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
            shareItem.enabled = [_loanData calculated] ? YES : NO;
        }
        
        // KJH
        UIBarButtonItem *composeItem = self.navigationItem.rightBarButtonItems[2];
        if (_isComparisonMode) {
            composeItem.enabled = [_loanDataA calculated] && [_loanDataB calculated]  ? YES : NO;
        }
        else {
            composeItem.enabled = [_loanData calculated] ? YES : NO;
        }
    }
    else {
        UIBarButtonItem *composeItem = self.navigationItem.rightBarButtonItems[1];
        
        if (_isComparisonMode) {
            composeItem.enabled = [_loanDataA calculated] && [_loanDataB calculated]  ? YES : NO;
        }
        else {
            composeItem.enabled = [_loanData calculated] ? YES : NO;
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

- (LoanCalcData *)loanData
{
    if (!_loanData) {
        
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"LoanCalcLoanData"]) {
            NSData *loanData = [[NSUserDefaults standardUserDefaults] objectForKey:@"LoanCalcLoanData"];
            _loanData = [NSKeyedUnarchiver unarchiveObjectWithData:loanData];
        }
        else {
            _loanData = [[LoanCalcData alloc] init];
            [self initializeLoanData:_loanData];
        }
        
        /*
        _loanData = [[LoanCalcData alloc] init];

        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"compareWith = nil"];
        LoanCalcHistory *history = [LoanCalcHistory MR_findFirstWithPredicate:predicate sortedBy:@"created" ascending:NO];
        if (history) {
            [self loadLoanCalcData:_loanData fromLoanCalcHistory:history];
        }
        else {
            [self initializeLoanData:_loanData];
        }
         */
    }
    
    return _loanData;
}

- (LoanCalcData *)loanDataA
{
    if (!_loanDataA) {
        
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"LoanCalcLoanDataA"]) {
            NSData *loanData = [[NSUserDefaults standardUserDefaults] objectForKey:@"LoanCalcLoanDataA"];
            _loanDataA = [NSKeyedUnarchiver unarchiveObjectWithData:loanData];
        }
        else {
            _loanDataA = [[LoanCalcData alloc] init];
            [self initializeLoanData:_loanDataA];
        }
        
        /*
        _loanDataA = [[LoanCalcData alloc] init];
        
        LoanCalcComparisonHistory *comparison = [LoanCalcComparisonHistory MR_findFirstOrderedByAttribute:@"calculateDate" ascending:NO];
        
        if (comparison) {
            [self loadLoanCalcData:_loanDataA fromLoanCalcHistory:comparison.loanCalcA];
        }
        else {
            [self initializeLoanData:_loanDataA];
        }
         */
    }
    
    return _loanDataA;
}

- (LoanCalcData *)loanDataB
{
    if (!_loanDataB) {
        
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"LoanCalcLoanDataB"]) {
            NSData *loanData = [[NSUserDefaults standardUserDefaults] objectForKey:@"LoanCalcLoanDataB"];
            _loanDataB = [NSKeyedUnarchiver unarchiveObjectWithData:loanData];
        }
        else {
            _loanDataB = [[LoanCalcData alloc] init];
            [self initializeLoanData:_loanDataB];
        }
        
        /*
        _loanDataB = [[LoanCalcData alloc] init];
        
        LoanCalcComparisonHistory *comparison = [LoanCalcComparisonHistory MR_findFirstOrderedByAttribute:@"calculateDate" ascending:NO];
        
        if (comparison) {
            [self loadLoanCalcData:_loanDataB fromLoanCalcHistory:comparison.loanCalcB];
        }
        else {
            [self initializeLoanData:_loanDataB];
        }
         */
    }
    
    return _loanDataB;
}

- (NSMutableArray *)calcItems
{
    if (!_calcItems) {
        if (_isComparisonMode) {
            _calcItems = [[NSMutableArray alloc] initWithArray:[LoanCalcMode calculateItemForMode:_loanDataA.calculationFor withDownPaymentEnabled:_loanDataA.showDownPayment]];
        }
        else {
            _calcItems = [[NSMutableArray alloc] initWithArray:[LoanCalcMode calculateItemForMode:_loanData.calculationFor withDownPaymentEnabled:_loanData.showDownPayment]];
        }
    }
    
    return _calcItems;
}

- (NSMutableArray *)extraPaymentItems
{
    if (!_extraPaymentItems) {
        _extraPaymentItems = [[NSMutableArray alloc] initWithArray:[LoanCalcMode extraPaymentTypes]];
    }
    
    return _extraPaymentItems;
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
        _startDateItem = @{@"Title": @"Start Date"};
    }
    
    return _startDateItem;
}

- (NSDictionary *)noteItem
{
    if (!_noteItem) {
        _noteItem = @{@"Title": @"Notes"};
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

    _loanData.startDate = sender.date;

    if (!_isComparisonMode) {
        NSIndexPath *ip = [NSIndexPath indexPathForRow:0 inSection:4];
        [self.tableView reloadRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (UIView *)advancedTitleView
{
    if (!_advancedTitleView) {
        _advancedTitleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, IS_RETINA ? 55.5 : 56.0)];
        _advancedTitleView.backgroundColor = [UIColor clearColor];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = _advancedTitleView.bounds;
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        button.contentEdgeInsets = UIEdgeInsetsMake(20, 0, 0, 15);
        if (_loanData.showAdvanced) {
            [SFKImage setDefaultFont:[UIFont fontWithName:@"appbox" size:17]];
            [SFKImage setDefaultColor:[UIColor colorWithRed:199.0/255.0 green:199.0/255.0 blue:204.0/255.0 alpha:1.0]];
            UIImage *image = [SFKImage imageNamed:@"i"];
            [button setImage:image forState:UIControlStateNormal];
        } else {
            [SFKImage setDefaultFont:[UIFont fontWithName:@"appbox" size:17]];
            [SFKImage setDefaultColor:[UIColor colorWithRed:199.0/255.0 green:199.0/255.0 blue:204.0/255.0 alpha:1.0]];
            UIImage *image = [SFKImage imageNamed:@"j"];
            [button setImage:image forState:UIControlStateNormal];
        }
        button.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [button addTarget:self action:@selector(advButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_advancedTitleView addSubview:button];

        UILabel *adv = [[UILabel alloc] initWithFrame:CGRectMake(IS_IPAD ? 28:15, 20, 100, 35)];
        adv.text = @"ADVANCED";
        adv.tag = 1234;
        
        UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, 55, self.view.bounds.size.width, IS_RETINA ? 0.5:1)];
        bottomLine.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        bottomLine.tag = 5678;
        bottomLine.backgroundColor = [self tableViewSeparatorColor];
        [_advancedTitleView addSubview:bottomLine];
        
        if (_loanData.showAdvanced) {
            adv.textColor = [UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1.0];
            bottomLine.hidden = YES;
        }
        else {
            adv.textColor = [UIColor colorWithRed:109.0/255.0 green:109.0/255.0 blue:114.0/255.0 alpha:1.0];
            bottomLine.hidden = NO;
        }
        
        adv.font = [UIFont systemFontOfSize:14];
        [_advancedTitleView addSubview:adv];
    }
    
    return _advancedTitleView;
}

- (UISegmentedControl *)selectSegment
{
    if (!_selectSegment) {
        _selectSegment = [[UISegmentedControl alloc] initWithItems:@[@"Loan", @"Comparison"]];
        
        [_selectSegment setWidth:IS_IPAD ? 150:85 forSegmentAtIndex:0];
        [_selectSegment setWidth:IS_IPAD ? 150:85 forSegmentAtIndex:1];
        
        _selectSegment.selectedSegmentIndex = 0;
        [_selectSegment addTarget:self action:@selector(selectSegmentChanged:) forControlEvents:UIControlEventValueChanged];
    }

    return _selectSegment;
}

- (void)selectSegmentChanged:(UISegmentedControl*) segment
{
    [self dismissDatePicker];
    
    switch (segment.selectedSegmentIndex) {
        case 0:
        {
            // Loan
            _isComparisonMode = NO;
            _calcItems = nil;
            [self.tableView reloadData];
            
            break;
        }
        case 1:
        {
            // Comparison
            _isComparisonMode = YES;
            _calcItems = nil;
            [self.tableView reloadData];
            
            break;
        }
        default:
            break;
    }
    
    [self dismissMoreMenu];
    [self refreshRightBarItems];
    
    [[NSUserDefaults standardUserDefaults] setBool:_isComparisonMode forKey:LoanCalcModeSave];
    [[NSUserDefaults standardUserDefaults] synchronize];
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
		[[[A3AppDelegate instance] rootViewController] toggleLeftMenuViewOnOff];
	}
}

- (void)moreButtonAction:(UIBarButtonItem *)button {
    @autoreleasepool {
		[self.firstResponder resignFirstResponder];
		[self setFirstResponder:nil];

        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonAction:)];
        
        _moreMenuButtons = @[self.shareButton, [self historyButton:NULL], self.settingsButton];
        _moreMenuView = [self presentMoreMenuWithButtons:_moreMenuButtons tableView:self.tableView];
        _isShowMoreMenu = YES;
        
        if (self.tableView.contentOffset.y == -63) {
            CGRect frame = [self.tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            frame = CGRectOffset(frame, 0, 1);
            [self.tableView scrollRectToVisible:frame animated:YES];
        }
        
        // 히스토리가 존재하는지 체크
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"compareWith = nil"];
        LoanCalcHistory *history = [LoanCalcHistory MR_findFirstWithPredicate:predicate sortedBy:@"created" ascending:NO];
        LoanCalcComparisonHistory *comparison = [LoanCalcComparisonHistory MR_findFirstOrderedByAttribute:@"calculateDate" ascending:NO];
        
        UIButton *shareBtn = _moreMenuButtons[0];
        UIButton *historyBtn = _moreMenuButtons[1];

        if (!history && !comparison) {
            // 둘다 없음
            historyBtn.enabled = NO;
        }
        else {
            historyBtn.enabled = YES;
        }
        
        if (_isComparisonMode) {
            shareBtn.enabled = ([_loanDataA calculated] && [_loanDataB calculated]) ? YES:NO;
        }
        else {
            shareBtn.enabled = [_loanData calculated] ? YES:NO;
        }
    };
}

- (void)doneButtonAction:(id)button {
	@autoreleasepool {
		[self dismissMoreMenu];
	}
}

- (void)composeButtonAction:(id)button
{
    @autoreleasepool {
        if (!_isComparisonMode) {
            if ([_loanData calculated]) {
                [self putLoanHistory];
                
                // clear
                [self clearLoanData:_loanData];
                
                [self deleteLoanData];
                
                [self.tableView reloadData];
            }
        }
        else {
            if ([_loanDataA calculated] && [_loanDataB calculated]) {
                [self putComparisonHistory];
                
                // clear
                [self clearLoanData:_loanDataA];
                [self clearLoanData:_loanDataB];
                
                [self deleteLoanDataA];
                [self deleteLoanDataB];
                
                [self.tableView reloadData];
            }
        }
	}

    [self refreshRightBarItems];
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
		[self dismissMoreMenuView:_moreMenuView scrollView:self.tableView];
		[self.view removeGestureRecognizer:gestureRecognizer];
	}
}

- (void)shareButtonAction:(id)sender {
	@autoreleasepool {
		[self clearEverything];
        
        if (_isComparisonMode) {
            NSMutableString *body = [NSMutableString new];
            [body appendFormat:@"I'd like to share a calculation with you.\n\n"];
            
            // * Loan A
            [body appendFormat:@"* Loan A \n"];
            [body appendFormat:@"Principal: %@\n", [self.loanFormatter stringFromNumber:_loanDataA.principal]];
            if ([_loanDataA downPayment]) {
                [body appendFormat:@"Down Payment: %@\n", [_loanDataA downPayment]];  // Down Payment: (값이 있는 경우)
            }
            [body appendFormat:@"Term: %@ years.\n", [_loanDataA termValueString]];
            [body appendFormat:@"Interest Rate: %@\n", [_loanDataA interestRateString]];
            [body appendFormat:@"Frequency: %@ \n", [LoanCalcString titleOfFrequency:_loanDataA.frequencyIndex]];  // Frequency: Monthly (선택값)
            if (_loanDataA.extraPaymentMonthly && [_loanDataA.extraPaymentMonthly floatValue] > 0.0) {
                [body appendFormat:@"Extra Payment(monthly): %@ \n", [self.loanFormatter stringFromNumber:_loanDataA.extraPaymentMonthly]];  // Extra Payment(monthly): (값이 있는 경우)
            }
            if (_loanDataA.extraPaymentYearly && [_loanDataA.extraPaymentYearly floatValue] > 0.0) {
                [body appendFormat:@"Extra Payment(yearly): %@ \n", [self.loanFormatter stringFromNumber:_loanDataA.extraPaymentYearly]];  // Extra Payment(yearly): (값이 있는 경우)
            }
            if (_loanDataA.extraPaymentOneTime && [_loanDataA.extraPaymentOneTime floatValue] > 0.0) {
                [body appendFormat:@"Extra Payment(one-time): %@ \n", [self.loanFormatter stringFromNumber:_loanDataA.extraPaymentOneTime]];  // Extra Payment(one-time): (값이 있는 경우)
            }
            
            [body appendFormat:@"Payment: %@ \n", [self.loanFormatter stringFromNumber:_loanDataA.repayment]];  // Payment: (사용자가 선택한 calculation과 결과값. 위의 입력값은 calculation 선택값에 따라 달라집니다.)
            
            if (_isTotalMode) {
                [body appendFormat:@"Interest: %@ \n", [self.loanFormatter stringFromNumber:[_loanDataA totalInterest]]];  // Interest: $23,981.60 (결과값)
                [body appendFormat:@"Total Amount: %@ \n", [self.loanFormatter stringFromNumber:[_loanDataA totalAmount]]];  // Total Amount: $223,981.60 (결과값)
            }
            else {
                [body appendFormat:@"Interest: %@ \n", [self.loanFormatter stringFromNumber:[_loanDataA totalInterest]]];  // Interest: $23,981.60 (결과값)
                [body appendFormat:@"Total Amount: %@ \n", [self.loanFormatter stringFromNumber:[_loanDataA totalAmount]]];  // Total Amount: $223,981.60 (결과값)
            }
            
            // * Loan B
            [body appendFormat:@"\n* Loan B \n"];
            [body appendFormat:@"Principal: %@\n", [self.loanFormatter stringFromNumber:_loanDataB.principal]];
            if ([_loanDataB downPayment]) {
                [body appendFormat:@"Down Payment: %@\n", [_loanDataB downPayment]];  // Down Payment: (값이 있는 경우)
            }
            [body appendFormat:@"Term: %@ years.\n", [_loanDataB termValueString]];
            [body appendFormat:@"Interest Rate: %@\n", [_loanDataB interestRateString]];
            [body appendFormat:@"Frequency: %@ \n", [LoanCalcString titleOfFrequency:_loanDataB.frequencyIndex]];  // Frequency: Monthly (선택값)
            if (_loanDataB.extraPaymentMonthly && [_loanDataB.extraPaymentMonthly floatValue] > 0.0) {
                [body appendFormat:@"Extra Payment(monthly): %@ \n", [self.loanFormatter stringFromNumber:_loanDataB.extraPaymentMonthly]];  // Extra Payment(monthly): (값이 있는 경우)
            }
            if (_loanDataB.extraPaymentYearly && [_loanDataB.extraPaymentYearly floatValue] > 0.0) {
                [body appendFormat:@"Extra Payment(yearly): %@ \n", [self.loanFormatter stringFromNumber:_loanDataB.extraPaymentYearly]];  // Extra Payment(yearly): (값이 있는 경우)
            }
            if (_loanDataB.extraPaymentOneTime && [_loanDataB.extraPaymentOneTime floatValue] > 0.0) {
                [body appendFormat:@"Extra Payment(one-time): %@ \n", [self.loanFormatter stringFromNumber:_loanDataB.extraPaymentOneTime]];  // Extra Payment(one-time): (값이 있는 경우)
            }
            
            [body appendFormat:@"Payment: %@ \n", [self.loanFormatter stringFromNumber:_loanDataB.repayment]];  // Payment: (사용자가 선택한 calculation과 결과값. 위의 입력값은 calculation 선택값에 따라 달라집니다.)
            
            if (_isTotalMode) {
                [body appendFormat:@"Interest: %@ \n", [self.loanFormatter stringFromNumber:[_loanDataB totalInterest]]];  // Interest: $23,981.60 (결과값)
                [body appendFormat:@"Total Amount: %@ \n", [self.loanFormatter stringFromNumber:[_loanDataB totalAmount]]];  // Total Amount: $223,981.60 (결과값)
            }
            else {
                [body appendFormat:@"Interest: %@ \n", [self.loanFormatter stringFromNumber:[_loanDataB totalInterest]]];  // Interest: $23,981.60 (결과값)
                [body appendFormat:@"Total Amount: %@ \n", [self.loanFormatter stringFromNumber:[_loanDataB totalAmount]]];  // Total Amount: $223,981.60 (결과값)
            }
            
            
            [body appendFormat:@"\nYou can calculate more in the AppBox Pro. \n"]; // You can calculate more in the AppBox Pro.
            [body appendFormat:@"https://itunes.apple.com/us/app/appbox-pro-swiss-army-knife/id318404385?mt=8 \n"]; // https://itunes.apple.com/us/app/appbox-pro-swiss-army-knife/id318404385?mt=8
            // AppBoxPro_amortization_loanA.csv
            // AppBoxPro_amortization_loanb.csv
            NSURL *fileUrlA = [NSURL fileURLWithPath:[_loanDataA filePathOfCsvStringForMonthlyDataWithFileName:@"AppBoxPro_amortization_loanA.csv"]];
            NSURL *fileUrlB = [NSURL fileURLWithPath:[_loanDataB filePathOfCsvStringForMonthlyDataWithFileName:@"AppBoxPro_amortization_loanB.csv"]];
            _sharePopoverController = [self presentActivityViewControllerWithActivityItems:@[body, fileUrlA, fileUrlB]
                                                                                   subject:@"Loan Calculator in the AppBox Pro"
                                                                         fromBarButtonItem:sender];
        }
        else {
            NSMutableString *body = [NSMutableString new];
            [body appendFormat:@"I'd like to share a calculation with you.\n\n"];
            [body appendFormat:@"Principal: %@\n", [self.loanFormatter stringFromNumber:_loanData.principal]];
            if ([_loanData downPayment]) {
                [body appendFormat:@"Down Payment: %@\n", [_loanData downPayment]];  // Down Payment: (값이 있는 경우)
            }
            [body appendFormat:@"Term: %@ years.\n", [_loanData termValueString]];
            [body appendFormat:@"Interest Rate: %@\n", [_loanData interestRateString]];
            [body appendFormat:@"Frequency: %@ \n", [LoanCalcString titleOfFrequency:_loanData.frequencyIndex]];  // Frequency: Monthly (선택값)
            if (_loanData.extraPaymentMonthly && [_loanData.extraPaymentMonthly floatValue] > 0.0) {
                [body appendFormat:@"Extra Payment(monthly): %@ \n", [self.loanFormatter stringFromNumber:_loanData.extraPaymentMonthly]];  // Extra Payment(monthly): (값이 있는 경우)
            }
            if (_loanData.extraPaymentYearly && [_loanData.extraPaymentYearly floatValue] > 0.0) {
                [body appendFormat:@"Extra Payment(yearly): %@ \n", [self.loanFormatter stringFromNumber:_loanData.extraPaymentYearly]];  // Extra Payment(yearly): (값이 있는 경우)
            }
            if (_loanData.extraPaymentOneTime && [_loanData.extraPaymentOneTime floatValue] > 0.0) {
                [body appendFormat:@"Extra Payment(one-time): %@ \n", [self.loanFormatter stringFromNumber:_loanData.extraPaymentOneTime]];  // Extra Payment(one-time): (값이 있는 경우)
            }
            
            [body appendFormat:@"Payment: %@ \n", [self.loanFormatter stringFromNumber:_loanData.repayment]];  // Payment: (사용자가 선택한 calculation과 결과값. 위의 입력값은 calculation 선택값에 따라 달라집니다.)
            
            if (_isTotalMode) {
                [body appendFormat:@"Interest: %@ \n", [self.loanFormatter stringFromNumber:[_loanData totalInterest]]];  // Interest: $23,981.60 (결과값)
                [body appendFormat:@"Total Amount: %@ \n", [self.loanFormatter stringFromNumber:[_loanData totalAmount]]];  // Total Amount: $223,981.60 (결과값)
            }
            else {
                [body appendFormat:@"Interest: %@ \n", [self.loanFormatter stringFromNumber:[_loanData totalInterest]]];  // Interest: $23,981.60 (결과값)
                [body appendFormat:@"Total Amount: %@ \n", [self.loanFormatter stringFromNumber:[_loanData totalAmount]]];  // Total Amount: $223,981.60 (결과값)
            }
            
            [body appendFormat:@"\nYou can calculate more in the AppBox Pro. \n"];  // You can calculate more in the AppBox Pro.
            [body appendFormat:@"https://itunes.apple.com/us/app/appbox-pro-swiss-army-knife/id318404385?mt=8 \n"];  // https://itunes.apple.com/us/app/appbox-pro-swiss-army-knife/id318404385?mt=8
            // AppBoxPro_amortization.csv
            NSURL *fileUrl = [NSURL fileURLWithPath:[_loanData filePathOfCsvStringForMonthlyDataWithFileName:@"AppBoxPro_amortization.csv"]];
            _sharePopoverController = [self presentActivityViewControllerWithActivityItems:@[body, fileUrl]
                                                                                   subject:@"Loan Calculator in the AppBox Pro"
                                                                         fromBarButtonItem:sender];
        }
        
        
        if (IS_IPAD) {
            _sharePopoverController.delegate = self;
            [self.navigationItem.rightBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem *buttonItem, NSUInteger idx, BOOL *stop) {
                [buttonItem setEnabled:NO];
            }];
        }
	}
}

- (void)historyButtonAction:(UIButton *)button {
	@autoreleasepool {
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
            A3RootViewController_iPad *rootViewController = [[A3AppDelegate instance] rootViewController];
            [rootViewController presentRightSideViewController:viewController];
        }
        
        if (IS_IPAD) {
            [self enableControls:NO];
        }
	}
}

- (void)advButtonAction:(UIButton *)sender
{
    _loanData.showAdvanced = !_loanData.showAdvanced;
    
    LoanCalcPreference *preference = [LoanCalcPreference new];
    [preference setShowAdvanced:_loanData.showAdvanced];
    
    if (_loanData.showAdvanced) {
        [SFKImage setDefaultFont:[UIFont fontWithName:@"appbox" size:17]];
        [SFKImage setDefaultColor:[UIColor colorWithRed:199.0/255.0 green:199.0/255.0 blue:204.0/255.0 alpha:1.0]];
        UIImage *image = [SFKImage imageNamed:@"i"];
        [sender setImage:image forState:UIControlStateNormal];
    } else {
        [SFKImage setDefaultFont:[UIFont fontWithName:@"appbox" size:17]];
        [SFKImage setDefaultColor:[UIColor colorWithRed:199.0/255.0 green:199.0/255.0 blue:204.0/255.0 alpha:1.0]];
        UIImage *image = [SFKImage imageNamed:@"j"];
        [sender setImage:image forState:UIControlStateNormal];
    }
    
    UILabel *adv = (UILabel *)[self.advancedTitleView viewWithTag:1234];
    UIView *bottomLine = [self.advancedTitleView viewWithTag:5678];
    if (_loanData.showAdvanced) {
        adv.textColor = [UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1.0];
        bottomLine.hidden = YES;
    }
    else {
        adv.textColor = [UIColor colorWithRed:109.0/255.0 green:109.0/255.0 blue:114.0/255.0 alpha:1.0];
        bottomLine.hidden = NO;
    }
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:4] withRowAnimation:UITableViewRowAnimationFade];
    
    if (_loanData.showAdvanced) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:4] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

- (void)monthlyButtonAction:(UIButton *)button
{
    if (_isTotalMode) {
        _isTotalMode = NO;
        
        [self displayLoanGraph];
    }
}

- (void)infoButtonAction:(UIButton *)button
{
    NSString *storyboardName = IS_IPAD ? @"LoanCalculatorPadStoryBoard" : @"LoanCalculatorPhoneStoryBoard";
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
    A3LoanCalcMonthlyDataViewController *viewController = [storyBoard instantiateViewControllerWithIdentifier:@"A3LoanCalcMonthlyDataViewController"];
    viewController.loanData = _loanData;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)totalButtonAction:(UIButton *)button
{
    if (!_isTotalMode) {
        _isTotalMode = YES;
        
        [self displayLoanGraph];
    }
}

- (void)settingsButtonAction:(UIButton *)button
{
    @autoreleasepool {
		[self clearEverything];
        
        UIStoryboard *stroyBoard = [UIStoryboard storyboardWithName:@"LoanCalculatorPhoneStoryBoard" bundle:nil];
        A3LoanCalcSettingViewController *viewController = [stroyBoard instantiateViewControllerWithIdentifier:@"A3LoanCalcSettingViewController"];
        [self presentSubViewController:viewController];
        [viewController setSettingChangedCompletionBlock:^{
            
        }];
        [viewController setSettingDismissCompletionBlock:^{
            [self enableControls:YES];
            [self refreshRightBarItems];
        }];
        
        if (IS_IPAD) {
            [self enableControls:NO];
        }
	}
}

- (void)clearEverything {
	@autoreleasepool {
		[self.firstResponder resignFirstResponder];
		[self setFirstResponder:nil];

		[self dismissMoreMenu];
        [_currentTextView resignFirstResponder];
	}
}

- (void)refreshCalcFor
{
    _calcItems = nil;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 2)] withRowAnimation:UITableViewRowAnimationFade];
}

- (NSUInteger)indexOfCalcItem:(A3LoanCalcCalculationItem) calcItem
{
    for (NSNumber *itemNum in _calcItems) {
        A3LoanCalcCalculationItem item = itemNum.integerValue;
        
        if (calcItem == item) {
            NSUInteger idx = [_calcItems indexOfObject:itemNum];
            return idx;
        }
    }
    
    return -1;
}

- (UITextField *)previousTextField:(UITextField *) current
{
    NSUInteger section, row;
    section = currentIndexPath.section;
    row = currentIndexPath.row;
    NSIndexPath *selectedIP = nil;
    UITableViewCell *prevCell = nil;
    BOOL exit = false;
    do {
        if (row == 0) {
            if (section == 0) {
                return nil;
            }
            section--;
            if ((_loanData.showExtraPayment == NO) && (section == 3)) {
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
        if (selectedIP.section == 4) {
            return nil;
        }
        else if (selectedIP.section == 3) {
            return _loanData.showExtraPayment ? ((A3LoanCalcTextInputCell *)prevCell).textField : nil;
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
    section = currentIndexPath.section;
    row = currentIndexPath.row;
    NSIndexPath *selectedIP = nil;
    UITableViewCell *nextCell = nil;
    BOOL exit = false;
    do {
        row++;
        NSInteger numRowOfSection = [self.tableView numberOfRowsInSection:section];
        if ((row+1) > numRowOfSection) {
            section++;
            row=0;
            
            if ((_loanData.showExtraPayment == NO) && (section == 3)) {
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
            return _loanData.showExtraPayment ? ((A3LoanCalcTextInputCell *)nextCell).textField : nil;
        }
        return ((A3LoanCalcTextInputCell *)nextCell).textField;
    }
    else {
        return nil;
    }
}

- (LoanCalcHistory *)loanHistoryForLoanData:(LoanCalcData *)loan
{
    LoanCalcHistory *history = [LoanCalcHistory MR_createEntity];
    history.calculationFor = @(loan.calculationFor);
    history.created = [NSDate date];
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
    data.annualInterestRate = @(history.interestRate.floatValue);
	data.showsInterestInYearly = history.interestRatePerYear;
    data.repayment = @(history.monthlyPayment.doubleValue);
    data.note = history.notes;
    data.principal = @(history.principal.doubleValue);
    data.startDate = history.startDate;
    data.monthOfTerms = @(history.term.floatValue);
	data.showsTermInMonths = history.termTypeMonth;
    data.calculationDate = history.created;
    data.calculationFor = history.calculationFor.integerValue;
    data.showAdvanced = history.showAdvanced.boolValue;
    data.showDownPayment = history.showDownPayment.boolValue;
    data.showExtraPayment = history.showExtraPayment.boolValue;
}

- (void)initializeLoanData:(LoanCalcData *)loan
{
    LoanCalcPreference *preference = [LoanCalcPreference new];
    loan.principal = @0;
    loan.downPayment = @0;
    loan.extraPaymentMonthly = @0;
	loan.showsTermInMonths = @NO;
	loan.showsInterestInYearly = @YES;
    
    loan.frequencyIndex = A3LC_FrequencyMonthly;
    loan.startDate = [NSDate date];
    loan.calculationFor = A3LC_CalculationForRepayment;
    loan.showAdvanced = preference.showAdvanced;
    loan.showDownPayment = preference.showDownPayment;
    loan.showExtraPayment = preference.showExtraPayment;
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
    [self loanData];
    [self loanDataA];
    [self loanDataB];
    
    _isComparisonMode = [[NSUserDefaults standardUserDefaults] boolForKey:LoanCalcModeSave];
    [self selectSegment].selectedSegmentIndex = _isComparisonMode ? 1:0;
    
 
    /*
    if (self.loanData.calculationDate) {
        if (self.loanDataA.calculationDate && self.loanDataB.calculationDate) {
            NSDate *date1 = _loanData.calculationDate;
            NSDate *date2 = _loanDataA.calculationDate;
            
            if ([date1 compare:date2] == NSOrderedDescending) {
                NSLog(@"date1 is later than date2");
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
                NSString *unit = [LoanCalcString shortTitleOfFrequency:A3LC_FrequencyMonthly];
                int monthInt =  (int)round(data.monthOfTerms.doubleValue);
                NSString *result = [NSString stringWithFormat:@"%ld %@", (long)monthInt, unit];
                return result;
            }
            case A3LC_CalculationForTermOfYears:
            {
                NSString *unit = [LoanCalcString shortTitleOfFrequency:A3LC_FrequencyAnnually];
//                int yearInt = (int)(data.monthOfTerms.doubleValue/12.0);
//                int monthInt = (int)round(data.monthOfTerms.doubleValue);
//                int yearInt = (int)(round(data.monthOfTerms.doubleValue / 12.0));
//                int monthInt = (int)round(data.monthOfTerms.doubleValue);
//                NSString *result = [NSString stringWithFormat:@"%d %@(%d mo)", yearInt, unit, monthInt];
//                return result;
//                break;
                if (round([data.monthOfTerms doubleValue]) < 12.0) {
                    NSInteger monthInt = roundl([data.monthOfTerms doubleValue]);
                    NSString *result = [NSString stringWithFormat:@"(%ld mo)", (long)monthInt];
                    return result;
                }
                else {
                    NSInteger yearInt = roundl([data.monthOfTerms doubleValue]) / 12.0;
                    NSInteger monthInt = roundl([data.monthOfTerms doubleValue]) - (12 * yearInt);
                    NSString *result;
                    if (monthInt == 0) {
                        result = [NSString stringWithFormat:@"%ld %@", (long)yearInt, unit];
                    }
                    else {
                        result = [NSString stringWithFormat:@"%ld %@(%ld mo)", (long)yearInt, unit, (long)monthInt];
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
	[self.navigationItem.rightBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem *buttonItem, NSUInteger idx, BOOL *stop) {
		[buttonItem setEnabled:YES];
	}];
	_sharePopoverController = nil;
}

#pragma mark - Loan Mode Calculation

- (BOOL)isSameHistory:(LoanCalcHistory *)history withLan:(LoanCalcData *)loan
{
    /*
     data.downPayment = @(history.downPayment.doubleValue);
     data.extraPaymentMonthly = @(history.extraPaymentMonthly.doubleValue);
     data.extraPaymentOneTime = @(history.extraPaymentOnetime.doubleValue);
     data.extraPaymentOneTimeDate = history.extraPaymentOnetimeYearMonth;
     data.extraPaymentYearly = @(history.extraPaymentYearly.doubleValue);
     data.extraPaymentYearlyDate = history.extraPaymentYearlyMonth;
     data.frequencyIndex = history.frequency.integerValue;
     data.annualInterestRate = @(history.interestRate.floatValue);
     data.repayment = @(history.monthlyPayment.doubleValue);
     data.note = history.notes;
     data.principal = @(history.principal.doubleValue);
     data.startDate = history.startDate;
     data.monthOfTerms = @(history.term.floatValue);
     data.calculationDate = history.created;
     data.calculationFor = history.calculationFor.integerValue;
     data.showAdvanced = history.showAdvanced.boolValue;
     data.showDownPayment = history.showDownPayment.boolValue;
     data.showExtraPayment = history.showExtraPayment.boolValue;
     */
    
    LoanCalcData *tmpLoan = [LoanCalcData new];
    [self loadLoanCalcData:tmpLoan fromLoanCalcHistory:history];
    
    if (tmpLoan.downPayment.doubleValue != loan.downPayment.doubleValue) {
        return NO;
    }
    
    if (tmpLoan.frequencyIndex != loan.frequencyIndex) {
        return NO;
    }
    
    if (tmpLoan.annualInterestRate.floatValue != loan.annualInterestRate.floatValue) {
        return NO;
    }
    
    if (tmpLoan.repayment.doubleValue != loan.repayment.doubleValue) {
        return NO;
    }
    
    if (tmpLoan.principal.doubleValue != loan.principal.doubleValue) {
        return NO;
    }
    
    if (tmpLoan.monthOfTerms.floatValue != loan.monthOfTerms.floatValue) {
        return NO;
    }
    
    if (tmpLoan.calculationFor!= loan.calculationFor) {
        return NO;
    }
    
    return YES;
}

- (void)updateLoanCalculation
{
    if (!_isComparisonMode) {
        switch (_loanData.calculationFor) {
            case A3LC_CalculationForDownPayment:
                [_loanData calculateDownPayment];
                break;
            case A3LC_CalculationForPrincipal:
                [_loanData calculatePrincipal];
                break;
            case A3LC_CalculationForRepayment:
                [_loanData calculateRepayment];
                break;
            case A3LC_CalculationForTermOfMonths:
                [_loanData calculateTermInMonth];
                break;
            case A3LC_CalculationForTermOfYears:
                [_loanData calculateTermInMonth];
                break;
                
            default:
                break;
        }
        
        [self displayLoanGraph];
        
        // calculation 정보 업데이트
        NSIndexPath *calIP = [NSIndexPath indexPathForRow:0 inSection:1];
        [self.tableView reloadRowsAtIndexPaths:@[calIP] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        if ([_loanData calculated]) {
            
            /*
            // loanCalc 가 계산이 되었으면, History에 기록한다.
            [self putLoanHistory];
             */
            
            [self saveLoanData];
            
            // 계산이 되었으면, 상단 그래프가 보이도록 이동시킨다.
//            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
            [self refreshRightBarItems];
        }
    }
}

- (void)displayLoanGraph
{
    if (!_isComparisonMode) {
        A3LoanCalcLoanGraphCell *graphCell = (A3LoanCalcLoanGraphCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        if ([_loanData calculated]) {
            [self displayGraphCell:graphCell];
        }
        else {
            [self makeGraphCellClear:graphCell];
        }
        
        [graphCell.monthlyButton setTitle:[LoanCalcString titleOfFrequency:_loanData.frequencyIndex] forState:UIControlStateNormal];
    }
}

- (void)displayGraphCell:(A3LoanCalcLoanGraphCell *)graphCell
{
    graphCell.infoButton.hidden = NO;
    
    // red bar
    graphCell.redLineView.hidden = NO;
    
    // downLabel, info X위치 (아이폰/아이패드 모두 우측에서 50)
    dispatch_async(dispatch_get_main_queue(), ^{
        float fromRightDistance = 15.0 + graphCell.infoButton.bounds.size.width + 10.0;
        graphCell.lowLabel.layer.anchorPoint = CGPointMake(1.0, 0.5);
        CGPoint center = graphCell.lowLabel.center;
        center.x = graphCell.bounds.size.width - fromRightDistance;
        graphCell.lowLabel.center = center;
        graphCell.lowLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        
        float fromRightDistance2 = 15.0;
        graphCell.infoButton.layer.anchorPoint = CGPointMake(1.0, 0.5);
        CGPoint center2 = graphCell.infoButton.center;
        center2.x = graphCell.bounds.size.width - fromRightDistance2;
        center2.y = (int)round(center.y);
        graphCell.infoButton.center = center2;
        graphCell.infoButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;

    });
    
    // 애니메이션 Start
    graphCell.upLabel.alpha = 0.0;
    graphCell.lowLabel.alpha = 0.0;
    
    float aniDuration = 0.3;
    [UIView beginAnimations:@"GraphUpdate" context:NULL];
    [UIView setAnimationDuration:aniDuration];
    
    float percentOfRedBar = 0;
    
    if (_isTotalMode) {
        float valueUp = [_loanData totalInterest].floatValue;
        float valueDown = [_loanData totalAmount].floatValue;
        percentOfRedBar = valueUp/valueDown;
    }
    else {
        float valueUp = [_loanData monthlyAverageInterest].floatValue;
        float valueDown = [_loanData repayment].floatValue;
        percentOfRedBar = valueUp/valueDown;
    }
    
    CGRect redRect = graphCell.redLineView.frame;
    redRect.size.width = self.view.bounds.size.width * percentOfRedBar;
    graphCell.redLineView.frame = redRect;
    
    // 애니메이션 End
    graphCell.upLabel.alpha = 1.0;
    graphCell.lowLabel.alpha = 1.0;
    
    [UIView commitAnimations];
    
    // text info
    NSString *interestText = _isTotalMode ? @"Interest" : @"Avg.Interest";
    NSString *paymentText = _isTotalMode ? @"Total Amount" : @"Payment";
    NSString *interestValue = _isTotalMode ? [self.loanFormatter stringFromNumber:[_loanData totalInterest]] : [self.loanFormatter stringFromNumber:[_loanData monthlyAverageInterest]];
    NSString *paymentValue = _isTotalMode ? [self.loanFormatter stringFromNumber:[_loanData totalAmount]] : [self.loanFormatter stringFromNumber:_loanData.repayment];
    
    if (!_isTotalMode) {
        paymentValue = [NSString stringWithFormat:@"%@/%@", paymentValue, [LoanCalcString shortTitleOfFrequency:_loanData.frequencyIndex]];
    }
    
    NSDictionary *textAttributes1 = @{
                                      NSFontAttributeName : IS_IPAD ? [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline] : [UIFont systemFontOfSize:15.0],
                                      NSForegroundColorAttributeName:[UIColor blackColor]
                                      };
    
    NSDictionary *textAttributes2 = @{
                                      NSFontAttributeName : IS_IPAD ? [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote] : [UIFont systemFontOfSize:13.0],
                                      NSForegroundColorAttributeName:[UIColor colorWithRed:123.0/255.0 green:123.0/255.0 blue:123.0/255.0 alpha:1.0]
                                      };
    
    NSDictionary *textAttributes3 = @{
                                      NSFontAttributeName : IS_IPAD ? [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline] : [UIFont boldSystemFontOfSize:17.0],
                                      NSForegroundColorAttributeName:[UIColor blackColor]
                                      };
    
    NSDictionary *textAttributes4 = @{
                                      NSFontAttributeName : IS_IPAD ? [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline] : [UIFont systemFontOfSize:17.0],
                                      NSForegroundColorAttributeName:[UIColor blackColor]
                                      };
    NSDictionary *space1 = @{
                             NSFontAttributeName : [UIFont systemFontOfSize:25.0],
                             NSForegroundColorAttributeName:[UIColor blackColor]
                             };
    
    NSDictionary *space2 = @{
                             NSFontAttributeName : [UIFont systemFontOfSize:17.0],
                             NSForegroundColorAttributeName:[UIColor blackColor]
                             };
    
    NSMutableAttributedString *upAttrString = [[NSMutableAttributedString alloc] init];
    NSMutableAttributedString *upText1 = [[NSMutableAttributedString alloc] initWithString:interestValue attributes:textAttributes1];
    NSMutableAttributedString *upText2 = [[NSMutableAttributedString alloc] initWithString:interestText attributes:textAttributes2];
    NSMutableAttributedString *upGap = [[NSMutableAttributedString alloc] initWithString:@" " attributes:space1];
    [upAttrString appendAttributedString:upText1];
    [upAttrString appendAttributedString:upGap];
    [upAttrString appendAttributedString:upText2];
    graphCell.upLabel.attributedText = upAttrString;
    
    NSMutableAttributedString *downAttrString = [[NSMutableAttributedString alloc] init];
    NSMutableAttributedString *downText1 = [[NSMutableAttributedString alloc] initWithString:paymentValue attributes:textAttributes3];
    NSMutableAttributedString *downText2 = [[NSMutableAttributedString alloc] initWithString:paymentText attributes:textAttributes4];
    NSMutableAttributedString *lowGap = [[NSMutableAttributedString alloc] initWithString:@" " attributes:space2];
    [downAttrString appendAttributedString:downText1];
    [downAttrString appendAttributedString:lowGap];
    [downAttrString appendAttributedString:downText2];
    graphCell.lowLabel.attributedText = downAttrString;
}


- (void)makeGraphCellClear:(A3LoanCalcLoanGraphCell *)graphCell
{
    graphCell.redLineView.hidden = YES;
    graphCell.infoButton.hidden = YES;
    
    // downLabel X위치 (우측에서 15)
    dispatch_async(dispatch_get_main_queue(), ^{
        float fromRightDistance = 15.0;
        graphCell.lowLabel.layer.anchorPoint = CGPointMake(1.0, 0.5);
        CGPoint center = graphCell.lowLabel.center;
        center.x = graphCell.bounds.size.width - fromRightDistance;
        graphCell.lowLabel.center = center;
        graphCell.lowLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    });
    
    NSString *interestText = _isTotalMode ? @"Interest" : (IS_IPAD ? @"Average Interest":@"Avg.Interest");
    NSString *paymentText = _isTotalMode ? @"Total Amount" : @"Payment";
    
    NSDictionary *textAttributes1 = @{
                                      NSFontAttributeName : IS_IPAD ? [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline] : [UIFont systemFontOfSize:15.0],
                                      NSForegroundColorAttributeName:[UIColor blackColor]
                                      };
    
    NSDictionary *textAttributes2 = @{
                                      NSFontAttributeName : IS_IPAD ? [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote] : [UIFont systemFontOfSize:13.0],
                                      NSForegroundColorAttributeName:[UIColor colorWithRed:123.0/255.0 green:123.0/255.0 blue:123.0/255.0 alpha:1.0]
                                      };
    
    NSDictionary *textAttributes3 = @{
                                      NSFontAttributeName : IS_IPAD ? [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline] : [UIFont boldSystemFontOfSize:17.0],
                                      NSForegroundColorAttributeName:[UIColor blackColor]
                                      };
    
    NSDictionary *textAttributes4 = @{
                                      NSFontAttributeName : IS_IPAD ? [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline] : [UIFont systemFontOfSize:17.0],
                                      NSForegroundColorAttributeName:[UIColor blackColor]
                                      };
    
    NSDictionary *space1 = @{
                             NSFontAttributeName : [UIFont systemFontOfSize:25.0],
                             NSForegroundColorAttributeName:[UIColor blackColor]
                             };
    
    NSDictionary *space2 = @{
                             NSFontAttributeName : [UIFont systemFontOfSize:17.0],
                             NSForegroundColorAttributeName:[UIColor blackColor]
                             };
    
    NSMutableAttributedString *upAttrString = [[NSMutableAttributedString alloc] init];
    NSMutableAttributedString *upText1 = [[NSMutableAttributedString alloc] initWithString:[self.loanFormatter stringFromNumber:@(0)] attributes:textAttributes1];
    NSMutableAttributedString *upText2 = [[NSMutableAttributedString alloc] initWithString:interestText attributes:textAttributes2];
    NSMutableAttributedString *upGap = [[NSMutableAttributedString alloc] initWithString:@" " attributes:space1];
    [upAttrString appendAttributedString:upText1];
    [upAttrString appendAttributedString:upGap];
    [upAttrString appendAttributedString:upText2];
    graphCell.upLabel.attributedText = upAttrString;
    
    NSMutableAttributedString *downAttrString = [[NSMutableAttributedString alloc] init];
    NSMutableAttributedString *downText1 = [[NSMutableAttributedString alloc] initWithString:[self.loanFormatter stringFromNumber:@(0)] attributes:textAttributes3];
    NSMutableAttributedString *downText2 = [[NSMutableAttributedString alloc] initWithString:paymentText attributes:textAttributes4];
    NSMutableAttributedString *lowGap = [[NSMutableAttributedString alloc] initWithString:@" " attributes:space2];
    [downAttrString appendAttributedString:downText1];
    [downAttrString appendAttributedString:lowGap];
    [downAttrString appendAttributedString:downText2];
    graphCell.lowLabel.attributedText = downAttrString;
}

- (void)putLoanHistory
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"compareWith = nil"];
    LoanCalcHistory *history = [LoanCalcHistory MR_findFirstWithPredicate:predicate sortedBy:@"created" ascending:NO];
    
    BOOL shouldSave = NO;
    if (history) {
        shouldSave = ![self isSameHistory:history withLan:_loanData];
    }
    else {
        shouldSave = YES;
    }
    
    if (shouldSave) {
        [self loanHistoryForLoanData:_loanData];
		[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
    }
}

#pragma mark - Save previous user input

- (NSDictionary *)dictionFromLoanData:(LoanCalcData *)loanData
{
//    NSDictionary *dic =
//    @{@"Pricipal": loanData.principal,
//      @"DownPayment": loanData.downPayment,
//      @"Repayment": loanData.repayment,
//      @"MonthOfTerms": loanData.monthOfTerms,
//      @"AnnualInterest": loanData.annualInterestRate,
//      @"FrequencyIndex": @(loanData.frequencyIndex),
//      @"DownPayment": loanData.downPayment,
//      @"DownPayment": loanData.downPayment,
//      @"DownPayment": loanData.downPayment,
//      @"DownPayment": loanData.downPayment,
//    
    return nil;
}

- (void)saveLoanData
{
    /*
    @property (nonatomic, strong) NSNumber *principal;
    @property (nonatomic, strong) NSNumber *downPayment;
    @property (nonatomic, strong) NSNumber *repayment;
    @property (nonatomic, strong) NSNumber *monthOfTerms;
    @property (nonatomic, strong) NSNumber *annualInterestRate;
    @property (nonatomic, readwrite) A3LoanCalcFrequencyType frequencyIndex;
    @property (nonatomic, strong) NSDate *calculationDate;
    
    // advanced
    @property (nonatomic, strong) NSDate *startDate;
    @property (nonatomic, strong) NSString *note;
    
    // extra payment
    @property (nonatomic, strong) NSNumber *extraPaymentMonthly;
    @property (nonatomic, strong) NSNumber *extraPaymentYearly;
    @property (nonatomic, strong) NSDate *extraPaymentYearlyDate;
    @property (nonatomic, strong) NSNumber *extraPaymentOneTime;
    @property (nonatomic, strong) NSDate *extraPaymentOneTimeDate;
    
    // setting
    @property (nonatomic, readwrite) A3LoanCalcCalculationMode calculationFor;
    @property (nonatomic, readwrite) BOOL showAdvanced;
    @property (nonatomic, readwrite) BOOL showDownPayment;
    @property (nonatomic, readwrite) BOOL showExtraPayment;
     */
    
    NSData *myLoanData = [NSKeyedArchiver archivedDataWithRootObject:_loanData];
    [[NSUserDefaults standardUserDefaults] setObject:myLoanData forKey:@"LoanCalcLoanData"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)saveLoanDataA
{
    NSData *myLoanData = [NSKeyedArchiver archivedDataWithRootObject:_loanDataA];
    [[NSUserDefaults standardUserDefaults] setObject:myLoanData forKey:@"LoanCalcLoanDataA"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)saveLoanDataB
{
    NSData *myLoanData = [NSKeyedArchiver archivedDataWithRootObject:_loanDataB];
    [[NSUserDefaults standardUserDefaults] setObject:myLoanData forKey:@"LoanCalcLoanDataB"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)deleteLoanData
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"LoanCalcLoanData"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)deleteLoanDataA
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"LoanCalcLoanDataA"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)deleteLoanDataB
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"LoanCalcLoanDataB"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Compare mode calculation

- (void)updateCompareLoanA
{
    if (_isComparisonMode) {
        // update info cell
        
        [self updateLoanInfoA];
        [self displayCompareGraph];
        
        if ([_loanDataA calculated]) {
            [self saveLoanDataA];
        }
        
    }
}

- (void)updateCompareLoanB
{
    if (_isComparisonMode) {
        // update info cell
        
        [self updateLoanInfoB];
        [self displayCompareGraph];
        
        [self saveLoanDataB];
        
        if ([_loanDataB calculated]) {
            [self saveLoanDataB];
        }
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
}

- (void)makeClearInfoCell:(A3LoanCalcLoanInfoCell *)infoCell
{
    if (IS_IPAD) {
        infoCell.amountLabel.text = [self.loanFormatter stringFromNumber:@(0)];
    }
    infoCell.paymentLabel.text = [NSString stringWithFormat:@"%@/%@", [self.loanFormatter stringFromNumber:@(0)], [LoanCalcString shortTitleOfFrequency:A3LC_FrequencyMonthly]];
    infoCell.frequencyLabel.text = [LoanCalcString titleOfFrequency:A3LC_FrequencyMonthly];
    infoCell.interestLabel.text = [self.percentFormatter stringFromNumber:@(0)];
    infoCell.termLabel.text = @"0 years";
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
    if ([_loanDataA calculated]) {
        
        compareCell.left_A_Label.layer.anchorPoint = CGPointMake(0, 1.0);
        compareCell.right_A_Label.layer.anchorPoint = CGPointMake(1, 1.0);
        
        // text
        compareCell.left_A_Label.text = [self.loanFormatter stringFromNumber:[_loanDataA totalInterest]];
        compareCell.right_A_Label.text = [self.loanFormatter stringFromNumber:[_loanDataA totalAmount]];
        
        // value label position
        [compareCell.left_A_Label sizeToFit];
        [compareCell.right_A_Label sizeToFit];
        
        // graph
        compareCell.red_A_Line.hidden = NO;
        
        float maxAmount = MAX([_loanDataA totalAmount].floatValue, [_loanDataB totalAmount].floatValue);
        
        float percentOfRedBar = 0;
        
        float interestFloat = [_loanDataA totalInterest].floatValue;
        percentOfRedBar = interestFloat/maxAmount;
        
        CGRect redRect = compareCell.red_A_Line.frame;
        redRect.size.width = MAX(self.view.bounds.size.width * percentOfRedBar, compareCell.circleA_View.bounds.size.width/2);
        compareCell.red_A_Line.frame = redRect;
        
        float percentOfMarkA = 0;
        
        float totalFloat = [_loanDataA totalAmount].floatValue;
        percentOfMarkA = totalFloat/maxAmount;
        
        compareCell.markA_Label.layer.anchorPoint = CGPointMake(0.5, 0.5);
        CGPoint center = compareCell.markA_Label.center;
        center.x = MIN(self.view.bounds.size.width * percentOfMarkA, self.view.bounds.size.width - compareCell.markA_Label.frame.size.width/2);
        compareCell.markA_Label.center = center;
        
        NSLog(@"markA : %@", NSStringFromCGRect(compareCell.markA_Label.frame));
        NSLog(@"redLine : %@", NSStringFromCGRect(compareCell.red_A_Line.frame));
        
        float circleOriginX = compareCell.circleA_View.frame.origin.x;
        CGRect rectLeft = compareCell.left_A_Label.frame;
        rectLeft.origin.x = MAX(circleOriginX, IS_IPAD ? 28:15);
        compareCell.left_A_Label.frame = rectLeft;
        NSLog(@"leftA : %@", NSStringFromCGRect(compareCell.left_A_Label.frame));
        
        float markTailX = compareCell.markA_Label.frame.origin.x + compareCell.markA_Label.frame.size.width;
        markTailX = MIN(markTailX, self.view.bounds.size.width-15);
        CGRect rectRight = compareCell.right_A_Label.frame;
        rectRight.origin.x = MAX(markTailX - rectRight.size.width, compareCell.left_A_Label.frame.origin.x + compareCell.left_A_Label.frame.size.width + 15);
        compareCell.right_A_Label.frame = rectRight;
        NSLog(@"rightA : %@", NSStringFromCGRect(compareCell.right_A_Label.frame));

        
        // from bottom to label bottom : 115/90
        float gap = IS_IPAD ? 115 : 90;
        float fromTopToA = compareCell.bounds.size.height - gap;
        
        CGPoint lbCenter;
        
        lbCenter = compareCell.left_A_Label.center;
        lbCenter.y = fromTopToA;
        compareCell.left_A_Label.center = lbCenter;
        
        lbCenter = compareCell.right_A_Label.center;
        lbCenter.y = fromTopToA;
        compareCell.right_A_Label.center = lbCenter;
        
        // label baseline adjustment with font
        CGRect newFrame = compareCell.left_A_Label.frame;
        newFrame.origin.y -= floor(compareCell.left_A_Label.font.descender);
        compareCell.left_A_Label.frame = newFrame;
        newFrame = compareCell.right_A_Label.frame;
        newFrame.origin.y -= floor(compareCell.right_A_Label.font.descender);
        compareCell.right_A_Label.frame = newFrame;
        
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
        
        NSLog(@"leftA : %@", NSStringFromCGRect(compareCell.left_A_Label.frame));
        NSLog(@"rightA : %@", NSStringFromCGRect(compareCell.right_A_Label.frame));

    }
    else {
        [self makeClearGraphLoanA:compareCell];
    }
    
    if ([_loanDataB calculated]) {
        
        compareCell.left_B_Label.layer.anchorPoint = CGPointMake(0, 1.0);
        compareCell.right_B_Label.layer.anchorPoint = CGPointMake(1, 1.0);
        
        // text
        compareCell.left_B_Label.text = [self.loanFormatter stringFromNumber:[_loanDataB totalInterest]];
        compareCell.right_B_Label.text = [self.loanFormatter stringFromNumber:[_loanDataB totalAmount]];
        
        // value label position
        [compareCell.left_B_Label sizeToFit];
        [compareCell.right_B_Label sizeToFit];
        
        // graph
        compareCell.red_B_Line.hidden = NO;
        
        float maxAmount = MAX([_loanDataA totalAmount].floatValue, [_loanDataB totalAmount].floatValue);
        
        float percentOfRedBar = 0;
        
        float interestFloat = [_loanDataB totalInterest].floatValue;
        percentOfRedBar = interestFloat/maxAmount;
        
        CGRect redRect = compareCell.red_B_Line.frame;
        redRect.size.width = MAX(self.view.bounds.size.width * percentOfRedBar, compareCell.circleA_View.bounds.size.width/2);
        compareCell.red_B_Line.frame = redRect;
        
        float percentOfMarkB = 0;
        
        float totalFloat = [_loanDataB totalAmount].floatValue;
        percentOfMarkB = totalFloat/maxAmount;
        
        compareCell.markB_Label.layer.anchorPoint = CGPointMake(0.5, 0.5);
        CGPoint center = compareCell.markB_Label.center;
        center.x = MIN(self.view.bounds.size.width * percentOfMarkB, self.view.bounds.size.width - compareCell.markB_Label.frame.size.width/2);
        compareCell.markB_Label.center = center;
        
        float circleOriginX = compareCell.circleB_View.frame.origin.x;
        CGRect rectLeft = compareCell.left_B_Label.frame;
        rectLeft.origin.x = MAX(circleOriginX, IS_IPAD ? 28:15);
        compareCell.left_B_Label.frame = rectLeft;
        
        float markTailX = compareCell.markB_Label.frame.origin.x + compareCell.markB_Label.frame.size.width;
        markTailX = MIN(markTailX, self.view.bounds.size.width-15);
        CGRect rectRight = compareCell.right_B_Label.frame;
        rectRight.origin.x = MAX(markTailX - rectRight.size.width, compareCell.left_B_Label.frame.origin.x + compareCell.left_B_Label.frame.size.width + 15);
        compareCell.right_B_Label.frame = rectRight;
        
        // from bottom to label bottom : 28 / 23
        float gap = IS_IPAD ? 28 : 23;
        float fromTopToA = compareCell.bounds.size.height - gap;
        
        CGPoint lbCenter;
        
        lbCenter = compareCell.left_B_Label.center;
        lbCenter.y = fromTopToA;
        compareCell.left_B_Label.center = lbCenter;
        
        lbCenter = compareCell.right_B_Label.center;
        lbCenter.y = fromTopToA;
        compareCell.right_B_Label.center = lbCenter;
        
        // label baseline adjustment with font
        CGRect newFrame = compareCell.left_B_Label.frame;
        newFrame.origin.y -= floor(compareCell.left_B_Label.font.descender);
        compareCell.left_B_Label.frame = newFrame;
        newFrame = compareCell.right_B_Label.frame;
        newFrame.origin.y -= floor(compareCell.right_B_Label.font.descender);
        compareCell.right_B_Label.frame = newFrame;
        
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
}

- (void)makeCompareCellClear:(A3LoanCalcCompareGraphCell *)compareCell
{
    [self makeClearGraphLoanA:compareCell];
    [self makeClearGraphLoanB:compareCell];
}

- (void)makeClearGraphLoanA:(A3LoanCalcCompareGraphCell *)compareCell
{
    compareCell.red_A_Line.hidden = YES;
    
    NSString *initText = [self.loanFormatter stringFromNumber:@(0)];
    compareCell.left_A_Label.text = initText;
    compareCell.right_A_Label.text = initText;

    // value label position
    [compareCell.left_A_Label sizeToFit];
    [compareCell.right_A_Label sizeToFit];
    
    // from bottom to label bottom : 115 / 90
    float gap = IS_IPAD ? 115 : 90;
    float fromTopToA = compareCell.bounds.size.height - gap;
    compareCell.left_A_Label.layer.anchorPoint = CGPointMake(0, 1.0);
    compareCell.right_A_Label.layer.anchorPoint = CGPointMake(1, 1.0);
    
    CGPoint lbCenter;
    float left_hori_margin = IS_IPAD ? 28 : 15;
    float right_hori_margin = 15.0;
    
    lbCenter = compareCell.left_A_Label.center;
    lbCenter.x = 0.0+left_hori_margin;
    lbCenter.y = fromTopToA;
    compareCell.left_A_Label.center = lbCenter;
    
    lbCenter = compareCell.right_A_Label.center;
    lbCenter.x = self.view.bounds.size.width-right_hori_margin;
    lbCenter.y = fromTopToA;
    compareCell.right_A_Label.center = lbCenter;
    
    // label baseline adjustment with font
    CGRect newFrame = compareCell.left_A_Label.frame;
    newFrame.origin.y -= floor(compareCell.left_A_Label.font.descender);
    compareCell.left_A_Label.frame = newFrame;
    newFrame = compareCell.right_A_Label.frame;
    newFrame.origin.y -= floor(compareCell.right_A_Label.font.descender);
    compareCell.right_A_Label.frame = newFrame;
    
    compareCell.markA_Label.layer.anchorPoint = CGPointMake(1, 0.5);
    
    lbCenter = compareCell.markA_Label.center;
    lbCenter.x = self.view.bounds.size.width-right_hori_margin;
    compareCell.markA_Label.center = lbCenter;
}

- (void)makeClearGraphLoanB:(A3LoanCalcCompareGraphCell *)compareCell
{
    compareCell.red_B_Line.hidden = YES;
    
    NSString *initText = [self.loanFormatter stringFromNumber:@(0)];
    compareCell.left_B_Label.text = initText;
    compareCell.right_B_Label.text = initText;
    
    // value label position
    [compareCell.left_B_Label sizeToFit];
    [compareCell.right_B_Label sizeToFit];
    
    // from bottom to label bottom : 28 / 23
    float gap = IS_IPAD ? 28 : 23;
    float fromTopToA = compareCell.bounds.size.height - gap;
    compareCell.left_B_Label.layer.anchorPoint = CGPointMake(0, 1.0);
    compareCell.right_B_Label.layer.anchorPoint = CGPointMake(1, 1.0);
    
    CGPoint lbCenter;
    float left_hori_margin = IS_IPAD ? 28 : 15;
    float right_hori_margin = 15.0;
    
    lbCenter = compareCell.left_B_Label.center;
    lbCenter.x = 0.0+left_hori_margin;
    lbCenter.y = fromTopToA;
    compareCell.left_B_Label.center = lbCenter;
    
    lbCenter = compareCell.right_B_Label.center;
    lbCenter.x = self.view.bounds.size.width-right_hori_margin;
    lbCenter.y = fromTopToA;
    compareCell.right_B_Label.center = lbCenter;
    
    // label baseline adjustment with font
    CGRect newFrame = compareCell.left_B_Label.frame;
    newFrame.origin.y -= floor(compareCell.left_B_Label.font.descender);
    compareCell.left_B_Label.frame = newFrame;
    newFrame = compareCell.right_B_Label.frame;
    newFrame.origin.y -= floor(compareCell.right_B_Label.font.descender);
    compareCell.right_B_Label.frame = newFrame;
    
    compareCell.markB_Label.layer.anchorPoint = CGPointMake(1, 0.5);
    
    lbCenter = compareCell.markB_Label.center;
    lbCenter.x = self.view.bounds.size.width-right_hori_margin;
    compareCell.markB_Label.center = lbCenter;
}

- (void)putComparisonHistory
{
    BOOL shouldSave = NO;
    
    LoanCalcComparisonHistory *lastComparison = [LoanCalcComparisonHistory MR_findFirstOrderedByAttribute:@"calculateDate" ascending:NO];
    
    if (lastComparison) {
		LoanCalcHistory *historyA, *historyB;
		for (LoanCalcHistory *history in lastComparison.details) {
			if ([history.orderInComparison isEqualToString:@"A"]) {
				historyA = history;
			} else {
				historyB = history;
			}
		}
        if (![self isSameHistory:historyA withLan:_loanDataA] || ![self isSameHistory:historyB withLan:_loanDataB]) {
            shouldSave = YES;
        }
    }
    else {
        shouldSave = YES;
    }
    
    if (shouldSave) {
        LoanCalcHistory *historyA = [self loanHistoryForLoanData:_loanDataA];
        LoanCalcHistory *historyB = [self loanHistoryForLoanData:_loanDataB];
        historyA.compareWith = historyB;
        historyB.compareWith = historyA;
		historyA.orderInComparison = @"A";
		historyB.orderInComparison = @"B";
        LoanCalcComparisonHistory *comparison = [LoanCalcComparisonHistory MR_createEntity];
        comparison.calculateDate = [NSDate date];
		comparison.details = [NSSet setWithArray:@[historyA, historyB]];
        comparison.totalInterestA = [_loanDataA totalInterest].stringValue;
        comparison.totalInterestB = [_loanDataB totalInterest].stringValue;
        comparison.totalAmountA = [_loanDataA totalAmount].stringValue;
        comparison.totalAmountB = [_loanDataB totalAmount].stringValue;
		[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
    }
}

- (void)dismissDatePicker
{
    if ([_advItems containsObject:self.dateInputItem]) {
        [self.tableView beginUpdates];
        
        [_advItems removeObject:self.dateInputItem];
        NSIndexPath *ip1 = [NSIndexPath indexPathForRow:0 inSection:4];
        NSIndexPath *ip2 = [NSIndexPath indexPathForRow:1 inSection:4];
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
        NSIndexPath *ip1 = [NSIndexPath indexPathForRow:0 inSection:4];
        NSIndexPath *ip2 = [NSIndexPath indexPathForRow:1 inSection:4];
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
    [self clearEverything];
}

#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    [self dismissMoreMenu];
    [self dismissDatePicker];
    
    _currentTextView = textView;
	[self setFirstResponder:textView];
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    if ([textView.text isEqualToString:_loanData.note]) {
        return;
    }
    
    _loanData.note = textView.text;
    
    CGSize newSize = [textView sizeThatFits:CGSizeMake(textView.frame.size.width, MAXFLOAT)];
    if (newSize.height < 180) {
        return;
    }
    UITableViewCell *currentCell = (UITableViewCell *)[[[textView superview] superview] superview];
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
    _loanData.note = textView.text;
    [self saveLoanData];
    
    UITableViewCell *currentCell = (UITableViewCell *)[[[textView superview] superview] superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:currentCell];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];

	[self setFirstResponder:nil];

	[self.tableView setContentOffset:CGPointMake(0, -self.tableView.contentInset.top) animated:YES];
}

#pragma mark - TextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
	[self dismissMoreMenu];
	[self dismissDatePicker];

	currentIndexPath = [self.tableView indexPathForCellSubview:textField];

	if (currentIndexPath.section == 4) {
		if (_advItems[currentIndexPath.row] == self.startDateItem) {
			return NO;
		}
	}

	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	[self setFirstResponder:textField];

	_textFieldTextBeforeEditing = textField.text;

    textField.text = @"";
	textField.placeholder = @"";

	if (currentIndexPath.section == 2) {

		// calculation items
		NSNumber *calcItemNum = _calcItems[currentIndexPath.row];
		A3LoanCalcCalculationItem calcItem = calcItemNum.integerValue;

		A3NumberKeyboardViewController *keyboardVC = [self normalNumberKeyboard];
		textField.inputView = [keyboardVC view];
		self.numberKeyboardViewController = keyboardVC;

		switch (calcItem) {
			case A3LC_CalculationItemDownPayment:
			case A3LC_CalculationItemPrincipal:
			case A3LC_CalculationItemRepayment:
			{
				NSString *customCurrencyCode = [[NSUserDefaults standardUserDefaults] objectForKey:A3LoanCalcCustomCurrencyCode];
				if ([customCurrencyCode length]) {
					[self.numberKeyboardViewController setCurrencyCode:customCurrencyCode];
				}
				self.numberKeyboardViewController.keyboardType = A3NumberKeyboardTypeCurrency;
				break;
			}
			case A3LC_CalculationItemInterestRate:
			{
				self.numberKeyboardViewController.keyboardType = A3NumberKeyboardTypeInterestRate;
				break;
			}
			case A3LC_CalculationItemTerm:
			{
				self.numberKeyboardViewController.keyboardType = A3NumberKeyboardTypeMonthYear;
				break;
			}
			default:
				self.numberKeyboardViewController.keyboardType = A3NumberKeyboardTypeCurrency;
				break;
		}

		keyboardVC.textInputTarget = textField;
		keyboardVC.delegate = self;
		self.numberKeyboardViewController = keyboardVC;

		[keyboardVC reloadPrevNextButtons];
	}
	else if (currentIndexPath.section == 3) {
		// extra payment
		NSNumber *exPaymentItemNum = _extraPaymentItems[currentIndexPath.row];
		A3LoanCalcExtraPaymentType exPaymentItem = exPaymentItemNum.integerValue;

		if (exPaymentItem == A3LC_ExtraPaymentMonthly) {

			A3NumberKeyboardViewController *keyboardVC = [self normalNumberKeyboard];
			textField.inputView = [keyboardVC view];
			self.numberKeyboardViewController = keyboardVC;
			self.numberKeyboardViewController.keyboardType = A3NumberKeyboardTypeCurrency;
			keyboardVC.textInputTarget = textField;
			keyboardVC.delegate = self;
			self.numberKeyboardViewController = keyboardVC;

			[keyboardVC reloadPrevNextButtons];
		}
	}
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {

	return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	[self setFirstResponder:nil];

	if ([textField.text doubleValue] == 0.0) {
		textField.text = _textFieldTextBeforeEditing;
		[self updateLoanCalculation];
		[self.tableView setContentOffset:CGPointMake(0, -self.tableView.contentInset.top) animated:YES];
		return;
	}

	NSIndexPath *endIP = [self.tableView indexPathForCellSubview:textField];
	NSLog(@"End IP : %ld - %ld", (long) endIP.section, (long) endIP.row);

	// update
	if (endIP.section == 2) {
		// calculation item
		NSNumberFormatter *formatter = [NSNumberFormatter new];
		[formatter setNumberStyle:NSNumberFormatterDecimalStyle];

		NSNumber *calcItemNum = _calcItems[endIP.row];
		A3LoanCalcCalculationItem calcItem = calcItemNum.integerValue;
		//double inputFloat = [textField.text doubleValue];
		NSNumber *inputNum = [formatter numberFromString:[textField text]];
		float inputFloat = [inputNum floatValue];

		switch (calcItem) {
			case A3LC_CalculationItemDownPayment: {
				if ([textField.text length] > 0) {
					_loanData.downPayment = inputNum;
					textField.text = [self.loanFormatter stringFromNumber:inputNum];
				}
				else {
					textField.text = [self.loanFormatter stringFromNumber:_loanData.downPayment];
				}
				break;
			}
			case A3LC_CalculationItemInterestRate: {
				_loanData.showsInterestInYearly = @([self.numberKeyboardViewController.bigButton1 isSelected]);
				if ([_loanData.showsInterestInYearly boolValue]) {
					_loanData.annualInterestRate = @(inputFloat / 100.0);
				} else {
					_loanData.annualInterestRate = @(inputFloat / 100.0 * 12.0);
				}
				textField.text = [_loanData interestRateString];
				break;
			}
			case A3LC_CalculationItemPrincipal: {
				if ([textField.text length] > 0) {
					_loanData.principal = inputNum;
					textField.text = [self.loanFormatter stringFromNumber:inputNum];
				}
				else {
					textField.text = [self.loanFormatter stringFromNumber:_loanData.principal];
				}

				break;
			}
			case A3LC_CalculationItemRepayment: {
				if ([textField.text length] > 0) {
					_loanData.repayment = inputNum;
					textField.text = [self.loanFormatter stringFromNumber:inputNum];
				}
				else {
					textField.text = [self.loanFormatter stringFromNumber:_loanData.repayment];
				}

				break;
			}
			case A3LC_CalculationItemTerm: {
				_loanData.showsTermInMonths = @([self.numberKeyboardViewController.bigButton2 isSelected]);
				if ([_loanData.showsTermInMonths boolValue]) {
					_loanData.monthOfTerms = inputNum;
				} else {
					NSInteger years = [inputNum integerValue];
					_loanData.monthOfTerms = @(years * 12);
				}
				textField.text = [_loanData termValueString];
				break;
			}
			default:
				break;
		}
	}
	else if (endIP.section == 3) {
		// extra payment
		NSNumber *exPayItemNum = _extraPaymentItems[endIP.row];
		A3LoanCalcExtraPaymentType exPayType = exPayItemNum.integerValue;
		float inputFloat = [textField.text floatValue];
		NSNumber *inputNum = @(inputFloat);

		if (exPayType == A3LC_ExtraPaymentMonthly) {
			if ([textField.text length] > 0) {
				_loanData.extraPaymentMonthly = inputNum;
				textField.text = [self.loanFormatter stringFromNumber:inputNum];
			}
			else {
				textField.text = [self.loanFormatter stringFromNumber:_loanData.extraPaymentMonthly];
			}
		}
	}

	[self updateLoanCalculation];
	[self.tableView setContentOffset:CGPointMake(0, -self.tableView.contentInset.top) animated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];

    return YES;
}

/*
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *toBe = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if ([toBe rangeOfString:@"."].location == NSNotFound) {
        return YES;
    }
    else {
        NSArray *textDivs = [toBe componentsSeparatedByString:@"."];
        NSString *intString = textDivs[0];
        NSString *floatString = textDivs[1];
        
        if (floatString.length > 3) {
            return NO;
        }
        else {
            return YES;
        }
    }
}
 */

#pragma mark - Keyboard Show/Hide notification

- (void)keyboardDidShow:(NSNotification *)notification {
	[self moveTableScrollToIndexPath:currentIndexPath responder:self.firstResponder];
	FNLOG(@"top:%f, bottom:%f", self.tableView.contentInset.top, self.tableView.contentInset.bottom);
}

- (void)keyboardDidHide:(NSNotification *)notification {
	FNLOG(@"top:%f, bottom:%f", self.tableView.contentInset.top, self.tableView.contentInset.bottom);

}

- (void)moveTableScrollToIndexPath:(NSIndexPath *)indexPath responder:(UIResponder *)responder {
	CGRect cellRect = [self.tableView rectForRowAtIndexPath:indexPath];
	CGFloat keyboardHeight;
	keyboardHeight = responder.inputView.bounds.size.height + responder.inputAccessoryView.bounds.size.height;

	if ((cellRect.origin.y + cellRect.size.height + self.tableView.contentInset.top) < (self.tableView.frame.size.height - keyboardHeight)) {
		return;
	}

	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.3];

	CGFloat viewHeight = self.tableView.frame.size.height;
	CGFloat offset = (cellRect.origin.y + cellRect.size.height) - (viewHeight - keyboardHeight);
	self.tableView.contentInset = UIEdgeInsetsMake(64, 0, keyboardHeight, 0);
	self.tableView.contentOffset = CGPointMake(0.0, offset);

	[UIView commitAnimations];
}

#pragma mark - LoanCalcHistoryViewController delegate

- (void)historyViewController:(UIViewController *)viewController selectLoanCalcHistory:(LoanCalcHistory *)history
{
    [self loadLoanCalcData:self.loanData fromLoanCalcHistory:history];
    
    _isComparisonMode = NO;
    [self selectSegment].selectedSegmentIndex = 0;
    _calcItems = nil;
    [self.tableView reloadData];
    
    [self enableControls:YES];
    [self refreshRightBarItems];
}

- (void)historyViewController:(UIViewController *)viewController selectLoanCalcComparisonHistory:(LoanCalcComparisonHistory *)comparison
{
	LoanCalcHistory *historyA, *historyB;
	for (LoanCalcHistory *history in comparison.details) {
		if ([history.orderInComparison isEqualToString:@"A"]) {
			historyA = history;
		} else {
			historyB = history;
		}
	}
    [self loadLoanCalcData:self.loanDataA fromLoanCalcHistory:historyA];
    [self loadLoanCalcData:self.loanDataB fromLoanCalcHistory:historyB];

    _isComparisonMode = YES;
    [self selectSegment].selectedSegmentIndex = 1;
    _calcItems = nil;
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
        _loanData.frequencyIndex = frequencyType;
        
        NSUInteger frequencyIndex = [self indexOfCalcItem:A3LC_CalculationItemFrequency];
        [self.tableView reloadRowsAtIndexPaths:@[
                                                 [NSIndexPath indexPathForRow:frequencyIndex inSection:2]
                                                 ]
                              withRowAnimation:UITableViewRowAnimationFade];
        
        [self updateLoanCalculation];
    }
}

#pragma mark - LoanCalcSelectCalcForDelegate

- (void)didSelectCalculationFor:(A3LoanCalcCalculationMode)calculationFor
{
    if (_loanData.calculationFor != calculationFor) {
        _loanData.calculationFor = calculationFor;
        [self refreshCalcFor];
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self clearEverything];
    
    if (_isComparisonMode) {
        if (indexPath.section == 0) {
            
        }
        else if (indexPath.section == 1 || indexPath.section == 2){
            NSString *storyboardName = (IS_IPHONE) ? @"LoanCalculatorPhoneStoryBoard" : @"LoanCalculatorPadStoryBoard";
            UIStoryboard *stroyBoard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
            A3LoanCalcLoanDetailViewController *viewController = [stroyBoard instantiateViewControllerWithIdentifier:@"A3LoanCalcLoanDetailViewController"];
            if (indexPath.section == 1) {
                viewController.navigationItem.title = @"Loan A";
                viewController.loanData = self.loanDataA;
            }
            else {
                viewController.navigationItem.title = @"Loan B";
                viewController.loanData = self.loanDataB;
            }
            viewController.delegate = self;
            [self.navigationController pushViewController:viewController animated:YES];
            [self dismissDatePicker];
        }
        
    }
    else {
        if (indexPath.section == 0) {
            // graph
        }
        else if (indexPath.section == 1) {
            // calculation for
            A3LoanCalcSelectModeViewController *viewController = [[A3LoanCalcSelectModeViewController alloc] initWithStyle:UITableViewStyleGrouped];
            viewController.delegate = self;
            viewController.currentCalcFor = _loanData.calculationFor;
            
            if (IS_IPHONE) {
                [self.navigationController pushViewController:viewController animated:YES];
            }
            else {
                [self presentSubViewController:viewController];
            }
            [self dismissDatePicker];
        }
        else if (indexPath.section == 2) {
            // calculation items
            NSNumber *calcItemNum = _calcItems[indexPath.row];
            A3LoanCalcCalculationItem calcItem = calcItemNum.integerValue;
            
            if (calcItem == A3LC_CalculationItemFrequency) {
                A3LoanCalcSelectFrequencyViewController *viewController = [[A3LoanCalcSelectFrequencyViewController alloc] initWithStyle:UITableViewStyleGrouped];
                viewController.delegate = self;
                viewController.currentFrequency = self.loanData.frequencyIndex;
                
                if (IS_IPHONE) {
                    [self.navigationController pushViewController:viewController animated:YES];
                }
                else {
                    [self presentSubViewController:viewController];
                }
                
                [self dismissDatePicker];
            }
            else {
                A3LoanCalcTextInputCell *inputCell = (A3LoanCalcTextInputCell *)[tableView cellForRowAtIndexPath:indexPath];
                [inputCell.textField becomeFirstResponder];
            }
        }
        if (indexPath.section == 3) {
            // extra payment
            NSNumber *exPaymentItemNum = _extraPaymentItems[indexPath.row];
            A3LoanCalcExtraPaymentType exPaymentItem = exPaymentItemNum.integerValue;
            
            if (exPaymentItem == A3LC_ExtraPaymentMonthly) {
                A3LoanCalcTextInputCell *inputCell = (A3LoanCalcTextInputCell *)[tableView cellForRowAtIndexPath:indexPath];
                [inputCell.textField becomeFirstResponder];
            }
            else if ((exPaymentItem == A3LC_ExtraPaymentYearly) || (exPaymentItem == A3LC_ExtraPaymentOnetime)) {
                UIStoryboard *stroyBoard = [UIStoryboard storyboardWithName:@"LoanCalculatorPhoneStoryBoard" bundle:nil];
                A3LoanCalcExtraPaymentViewController *viewController = [stroyBoard instantiateViewControllerWithIdentifier:@"A3LoanCalcExtraPaymentViewController"];
                viewController.delegate = self;
                viewController.exPaymentType = exPaymentItem;
                viewController.loanCalcData = _loanData;
                
                if (IS_IPHONE) {
                    [self.navigationController pushViewController:viewController animated:YES];
                }
                else {
                    [self presentSubViewController:viewController];
                }
                [self dismissDatePicker];
            }
        }
        if (indexPath.section == 4) {
            if (_advItems[indexPath.row] == self.startDateItem) {
                A3LoanCalcTextInputCell *inputCell = (A3LoanCalcTextInputCell *)[tableView cellForRowAtIndexPath:indexPath];
                [inputCell.textField becomeFirstResponder];
                
                preDate = _loanData.startDate;
                
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
        return 5;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (_isComparisonMode) {
        return 1;
    }
    else {
        if (section == 0) {
            return 1;   // loan graph
        }
        else if (section == 1) {
            return 1;   // calculation
        }
        else if (section == 2) {
            return self.calcItems.count;
        }
        else if (section == 3) {
            return self.extraPaymentItems.count;
        }
        else if (section == 4){
            // advanced
            return _loanData.showAdvanced ? self.advItems.count:0;
        }
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_isComparisonMode) {
        if (indexPath.section == 0) {
            return (IS_IPHONE) ? 166 : 226;
        }
        else {
            return (IS_IPHONE) ? 160 : 194;
        }
    }
    else {
        if (indexPath.section == 0) {
            return (IS_IPHONE) ? 134 : 193;
        }
        else if (indexPath.section == 1) {
            if ([_loanData calculated]) {
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
            return _loanData.showExtraPayment ? 44:0;
        }
        else if (indexPath.section == 4) {
            if (self.advItems[indexPath.row] == self.noteItem) {
                NSDictionary *textAttributes = @{
                                                 NSFontAttributeName : [UIFont systemFontOfSize:17]
                                                 };
                
                NSString *testText = _loanData.note ? _loanData.note : @"";
                NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:testText attributes:textAttributes];
                UITextView *txtView = [[UITextView alloc] init];
                [txtView setAttributedText:attributedString];
                float margin = IS_IPAD ? 49:31;
                CGSize txtViewSize = [txtView sizeThatFits:CGSizeMake(self.view.frame.size.width-margin, CGFLOAT_MAX)];
                //float cellHeight = txtViewSize.height + 20;
                float cellHeight = txtViewSize.height;
                
                // memo카테고리에서는 화면의 가장 아래까지 노트필드가 채워진다.
                float defaultCellHeight = 180.0;
                
                if (cellHeight < defaultCellHeight) {
                    return defaultCellHeight;
                }
                else {
                    return cellHeight;
                }
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
    float nonTitleHieght = 35.0;
    float titleHeight = 55.0;

    if (!_isComparisonMode) {
        if (section == 0) {
            return 1;
        }
        else if (section == 1) {
            return nonTitleHieght-1;
        }
        else if (section == 2) {
            return nonTitleHieght-1;
        }
        else if (section == 3) {
            return _loanData.showExtraPayment ? titleHeight-1:1;
        }
        else if (section == 4) {
            return _loanData.showExtraPayment ? titleHeight-1:titleHeight-2;
        }
        return 1;
    }
    else {
        if (section == 0) {
            return 1;
        }
        else {
            return nonTitleHieght-1;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (_isComparisonMode) {
        
    }
    else {
        if (section == 4) {
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
            return [_loanData showExtraPayment] ? @"EXTRA PAYMENTS" : nil;
        }
    }
    
    return nil;
}

#pragma mark Configure TableView Cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=nil;
	@autoreleasepool {
		cell = nil;
        
        if (_isComparisonMode) {
            cell = [self tableView:tableView cellForComparisonModeRowAtIndexPath:indexPath];
        }
        else {
            cell = [self tableView:tableView cellForLoanModeRowAtIndexPath:indexPath];
        }
	}
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForComparisonModeRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell=nil;
    
    if (indexPath.section == 0) {
        A3LoanCalcCompareGraphCell *compareCell = [tableView dequeueReusableCellWithIdentifier:A3LoanCalcCompareGraphCellID forIndexPath:indexPath];
        compareCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        // loan data A,B
        if ([_loanDataA calculated] || [_loanDataB calculated]) {
            [self displayCompareCell:compareCell];
        }
        else {
            [self makeCompareCellClear:compareCell];
        }
        
        [compareCell adjustSubviewsFontSize];
        
        cell = compareCell;
    }
    else if (indexPath.section == 1){
        A3LoanCalcLoanInfoCell *infoCell = [tableView dequeueReusableCellWithIdentifier:A3LoanCalcLoanInfoCellID forIndexPath:indexPath];
        infoCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        infoCell.markLabel.text = @"A";
        
        if ([_loanDataA calculated]) {
            [self updateInfoCell:infoCell withLoanInfo:_loanDataA];
        }
        else {
            [self makeClearInfoCell:infoCell];
        }
        
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
        
        if ([_loanDataB calculated]) {
            [self updateInfoCell:infoCell withLoanInfo:_loanDataB];
        }
        else {
            [self makeClearInfoCell:infoCell];
        }
        
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
            // graph
            A3LoanCalcLoanGraphCell *graphCell = [tableView dequeueReusableCellWithIdentifier:A3LoanCalcLoanGraphCellID forIndexPath:indexPath];
            [graphCell.monthlyButton addTarget:self action:@selector(monthlyButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            [graphCell.totalButton addTarget:self action:@selector(totalButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            [graphCell.infoButton addTarget:self action:@selector(infoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            [graphCell adjustSubviewsFontSize];
            
            if ([_loanData calculated]) {
                [self displayGraphCell:graphCell];
            }
            else {
                [self makeGraphCellClear:graphCell];
            }
            
            [graphCell.monthlyButton setTitle:[LoanCalcString titleOfFrequency:_loanData.frequencyIndex] forState:UIControlStateNormal];
            
            cell = graphCell;
			break;
		}

        case 1:
        {
            // calculation
            cell = [tableView dequeueReusableCellWithIdentifier:A3LoanCalcSelectCellID forIndexPath:indexPath];
            cell.textLabel.text = @"Calculation";
            if ([_loanData calculated]) {
                
                NSDictionary *textAttributes1 = @{
                                                  NSFontAttributeName : [UIFont systemFontOfSize:17.0],
                                                  NSForegroundColorAttributeName:[UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0]
                                                  };
                
                NSDictionary *textAttributes2 = @{
                                                  NSFontAttributeName : IS_IPAD ? [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline] : [UIFont systemFontOfSize:17.0],
                                                  NSForegroundColorAttributeName:[UIColor blackColor]
                                                  };
                
                NSString *calcuTitle = [LoanCalcString titleOfCalFor:_loanData.calculationFor];
                NSString *resultText = [self resultTextOfLoan:_loanData forCalcuFor:_loanData.calculationFor];
                
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
                cell.detailTextLabel.text = [LoanCalcString titleOfCalFor:_loanData.calculationFor];
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
            NSNumber *calcItemNum = _calcItems[indexPath.row];
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
        {
            // extra payment
            NSNumber *exPaymentItemNum = _extraPaymentItems[indexPath.row];
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
			break;
		}

        case 4:
        {
            // advanced
            if (_advItems[indexPath.row] == self.startDateItem) {
                A3LoanCalcTextInputCell *inputCell = [tableView dequeueReusableCellWithIdentifier:A3LoanCalcTextInputCellID forIndexPath:indexPath];
                inputCell.selectionStyle = UITableViewCellSelectionStyleNone;
                inputCell.textField.font = [UIFont systemFontOfSize:17];
                inputCell.titleLabel.text = _startDateItem[@"Title"];
                inputCell.textField.delegate = self;
                inputCell.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"None"
                                                                                            attributes:@{NSForegroundColorAttributeName:inputCell.textField.textColor}];
                inputCell.textField.userInteractionEnabled = NO;
                NSDateFormatter *df = [[NSDateFormatter alloc] init];
                df.dateStyle = IS_IPAD ? NSDateFormatterFullStyle : NSDateFormatterMediumStyle;
                inputCell.textField.text = [df stringFromDate:_loanData.startDate];
                
                if ([_advItems containsObject:self.dateInputItem]) {
                    inputCell.textField.textColor = [UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1.0];
                } else {
                    inputCell.textField.textColor = [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
                }
                
                cell = inputCell;
            }
            else if (_advItems[indexPath.row] == self.noteItem) {
                // note
                A3WalletNoteCell *noteCell = [tableView dequeueReusableCellWithIdentifier:A3LoanCalcLoanNoteCellID forIndexPath:indexPath];
                
                noteCell.selectionStyle = UITableViewCellSelectionStyleNone;
                noteCell.textView.delegate = self;
                noteCell.textView.bounces = NO;
                noteCell.textView.placeholder = @"Notes";
                noteCell.textView.placeholderColor = [UIColor colorWithRed:199.0/255.0 green:199.0/255.0 blue:205.0/255.0 alpha:1.0];
                noteCell.textView.textColor = [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
                noteCell.textView.font = [UIFont systemFontOfSize:17];
                noteCell.textView.text = _loanData.note;
                noteCell.textView.scrollEnabled = NO;
                
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
			break;
		}
        default:
            break;
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
            textFieldText = [self.loanFormatter stringFromNumber:_loanData.downPayment];
            break;
        }
        case A3LC_CalculationItemInterestRate:
        {
            placeHolderText = [NSString stringWithFormat:@"Annual %@", [self.percentFormatter stringFromNumber:@(0)]];
            textFieldText = [_loanData interestRateString];
            break;
        }
        case A3LC_CalculationItemPrincipal:
        {
            textFieldText = [self.loanFormatter stringFromNumber:_loanData.principal];
            break;
        }
        case A3LC_CalculationItemRepayment:
        {
            placeHolderText = [self.loanFormatter stringFromNumber:@(0)];
            textFieldText = [self.loanFormatter stringFromNumber:_loanData.repayment];
            break;
        }
        case A3LC_CalculationItemTerm:
        {
            placeHolderText = @"years or months";
            textFieldText = [_loanData termValueString];
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
    NSString *textFieldText = [self.loanFormatter stringFromNumber:_loanData.extraPaymentMonthly];
    inputCell.textField.text = textFieldText;
    inputCell.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeHolderText
                                                                                attributes:@{NSForegroundColorAttributeName:inputCell.textField.textColor}];
}

- (void)configureExtraPaymentYearlyCell:(UITableViewCell *)cell
{
    cell.textLabel.text = [LoanCalcString titleOfExtraPayment:A3LC_ExtraPaymentYearly];
    NSString *currencyText = @"";
    if (_loanData.extraPaymentYearly) {
        currencyText = [self.loanFormatter stringFromNumber:_loanData.extraPaymentYearly];
    }
    else {
        currencyText = [self.loanFormatter stringFromNumber:@(0)];
    }
    NSString *dateText = @"";
    
    if (_loanData.extraPaymentYearlyDate) {
        NSDate *pickDate = _loanData.extraPaymentYearlyDate;
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setDateFormat:@"MMM"];
        dateText = [formatter stringFromDate:pickDate];
    }
    else {
        dateText = @"None";
    }
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", currencyText, dateText];
}

- (void)configureExtraPaymentOneTimeCell:(UITableViewCell *)cell
{
    cell.textLabel.text = [LoanCalcString titleOfExtraPayment:A3LC_ExtraPaymentOnetime];
    NSString *currencyText = @"";
    if (_loanData.extraPaymentOneTime) {
        currencyText = [self.loanFormatter stringFromNumber:_loanData.extraPaymentOneTime];
    }
    else {
        currencyText = [self.loanFormatter stringFromNumber:@(0)];
    }
    NSString *dateText = @"";
    if (_loanData.extraPaymentOneTimeDate) {
        NSDate *pickDate = _loanData.extraPaymentOneTimeDate;
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setDateFormat:@"MMM, yyyy"];
        dateText = [formatter stringFromDate:pickDate];
    }
    else {
        dateText = @"None";
    }
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", currencyText, dateText];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

#pragma mark - A3KeyboardDelegate

- (BOOL)isPreviousEntryExists{
    if ([self previousTextField:(UITextField *) self.firstResponder]) {
        return YES;
    }
    else {
        return NO;
    }
}

- (BOOL)isNextEntryExists{
    if ([self nextTextField:(UITextField *) self.firstResponder]) {
        return YES;
    }
    else {
        return NO;
    }
}

- (void)prevButtonPressed{
    if (self.firstResponder) {
        UITextField *prevTxtField = [self previousTextField:(UITextField *) self.firstResponder];
        if (prevTxtField) {
            [prevTxtField becomeFirstResponder];
        }
    }
}

- (void)nextButtonPressed{
    if (self.firstResponder) {
        UITextField *nextTxtField = [self nextTextField:(UITextField *) self.firstResponder];
        if (nextTxtField) {
            [nextTxtField becomeFirstResponder];
        }
    }
}

- (void)A3KeyboardController:(id)controller clearButtonPressedTo:(UIResponder *)keyInputDelegate {
	UITextField *textField = (UITextField *) self.numberKeyboardViewController.textInputTarget;
	if ([textField isKindOfClass:[UITextField class]]) {
		textField.text = @"";
	}
}

- (void)A3KeyboardController:(id)controller doneButtonPressedTo:(UIResponder *)keyInputDelegate {
    [keyInputDelegate resignFirstResponder];
}

#pragma mark --- Response to Calculator Button and result

- (UIViewController *)modalPresentingParentViewControllerForCalculator {
	_calculatorTargetTextField = (UITextField *) self.firstResponder;
	return self;
}

- (id <A3CalculatorDelegate>)delegateForCalculator {
	return self;
}

- (void)calculatorViewController:(UIViewController *)viewController didDismissWithValue:(NSString *)value {
	_calculatorTargetTextField.text = value;
	[self textFieldDidEndEditing:_calculatorTargetTextField];
}

#pragma mark --- Response to Currency Select Button and result

- (UIViewController *)modalPresentingParentViewControllerForCurrencySelector {
	return self;
}

- (id <A3SearchViewControllerDelegate>)delegateForCurrencySelector {
	return self;
}

- (void)searchViewController:(UIViewController *)viewController itemSelectedWithItem:(NSString *)selectedItem {
	if ([selectedItem length]) {
		[[NSUserDefaults standardUserDefaults] setObject:selectedItem forKey:A3LoanCalcCustomCurrencyCode];
		[[NSUserDefaults standardUserDefaults] synchronize];

		[self.loanFormatter setCurrencyCode:selectedItem];

		[self.tableView reloadData];
	}
}

- (void)reloadCurrencyCode {
	NSString *customCurrencyCode = [[NSUserDefaults standardUserDefaults] objectForKey:A3LoanCalcCustomCurrencyCode];
	if ([customCurrencyCode length]) {
		[self.loanFormatter setCurrencyCode:customCurrencyCode];
	}
}

@end
