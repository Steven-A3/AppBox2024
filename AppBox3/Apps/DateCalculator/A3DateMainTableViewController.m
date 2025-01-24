//
//  A3DateMainTableViewController.m
//  A3TeamWork
//
//  Created by dotnetguy83 on 3/10/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "A3DateMainTableViewController.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+NumberKeyboard.h"
#import "A3DateCalcHeaderView.h"
#import "A3DateKeyboardViewController.h"
#import "A3NumberKeyboardViewController.h"
#import "A3NumberKeyboardViewController_iPhone.h"
#import "A3DateCalcDurationViewController.h"
#import "A3DateCalcExcludeViewController.h"
#import "A3DateCalcEditEventViewController.h"
#import "A3DateCalcStateManager.h"
#import "A3DateCalcAddSubCell1.h"
#import "A3DateCalcAddSubCell2.h"
#import "A3DefaultColorDefines.h"
#import "NSString+conversion.h"
#import "UIViewController+iPad_rightSideView.h"
#import "NSDate+formatting.h"
#import "A3SyncManager.h"
#import "A3UserDefaultsKeys.h"
#import "A3SyncManager+NSUbiquitousKeyValueStore.h"
#import "UIViewController+tableViewStandardDimension.h"
#import "UIViewController+extension.h"
#import "A3AppDelegate.h"
#import "A3SyncManager.h"
#import "A3UIDevice.h"
#import "A3UserDefaults+A3Addition.h"

#define kDefaultBackgroundColor [UIColor lightGrayColor]
#define kDefaultButtonColor     [UIColor colorWithRed:193.0/255.0 green:196.0/255.0 blue:200.0/255.0 alpha:1.0]
#define kSelectedButtonColor    [[A3UserDefaults standardUserDefaults] themeColor]

@interface A3DateMainTableViewController ()
		<UITableViewDelegate, UITableViewDataSource,
		UITextFieldDelegate, UIPopoverControllerDelegate,
		A3DateKeyboardDelegate, A3DateCalcExcludeDelegate,
		A3DateCalcDurationDelegate, A3DateCalcHeaderViewDelegate,
		A3DateCalcEditEventDelegate, UIActivityItemSource,
		A3ViewControllerProtocol, GADBannerViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) A3DateCalcHeaderView *headerView;
@property (strong, nonatomic) NSArray *sectionTitles;
@property (strong, nonatomic) NSArray *sections;
@property (strong, nonatomic) NSIndexPath *editingIndexPath;

@property (assign, nonatomic) BOOL isAddSubMode;
@property (strong, nonatomic) NSDate * fromDate;
@property (strong, nonatomic) NSDate * toDate;
@property (strong, nonatomic) NSDate * fromDateCursor;  // 슬라이더 커서를 날짜에 반영하는 임시값
@property (strong, nonatomic) NSDate * toDateCursor;
@property (strong, nonatomic) NSDate * offsetDate;
@property (strong, nonatomic) NSDateComponents* offsetComp;
@property (strong, nonatomic) NSString * excludeDateString;
@property (strong, nonatomic) NSString * durationOptionString;
@property (nonatomic, strong) NSArray *moreMenuButtons;
@property (nonatomic, strong) UIView *moreMenuView;
@property (nonatomic, strong) UIPopoverController *sharePopoverController;
@property (nonatomic, copy) NSString *textBeforeEditingText;
@property (nonatomic, copy) NSString *placeholderBeforeEditingText;
@property (nonatomic, weak) UITextField *editingTextField;
@property (nonatomic, copy) UIColor *colorBeforeEditingText;

@end

@implementation A3DateMainTableViewController {
    BOOL _isShowMoreMenu;
//    BOOL _isKeyboardShown;
	BOOL _isDateKeyboardVisible;
	BOOL _isNumberKeyboardVisible;
    BOOL _datePrevShow, _dateNextShow;
    BOOL _isSelectedFromToCell;
    CGFloat _tableYOffset;
    CGFloat _oldTableOffset;
	NSString *kCalculationString;
}

@synthesize fromDate = _fromDate;
@synthesize toDate = _toDate;
@synthesize offsetDate = _offsetDate;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(A3AppName_DateCalculator, nil);
	kCalculationString = NSLocalizedString(@"CALCULATION", @"CALCULATION");

	if (IS_IPAD || [UIWindow interfaceOrientationIsPortrait]) {
		[self leftBarButtonAppsButton];
	} else {
		self.navigationItem.leftBarButtonItem = nil;
		self.navigationItem.hidesBackButton = YES;
	}
    [self makeNavigationBarAppearanceDefault];
    [self makeBackButtonEmptyArrow];

	_tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
	_tableView.dataSource = self;
	_tableView.delegate = self;
	[self.view addSubview:_tableView];
	
	[_tableView makeConstraints:^(MASConstraintMaker *make) {
		make.edges.equalTo(self.view);
	}];
	
	self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorColor = A3UITableViewSeparatorColor;
	self.tableView.separatorInset = A3UITableViewSeparatorInset;

	[self readFromSavedValue];
	_isDateKeyboardVisible = NO;
	_isNumberKeyboardVisible = NO;

    [self initializeControl];
    [self reloadTableViewDataWithInitialization:YES];
    if ([self isAddSubMode]) {
        [self refreshAddSubModeButtonForResultWithAnimation:YES];
    }
    
    [self registerContentSizeCategoryDidChangeNotification];

	if (IS_IPAD) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainMenuDidHide) name:A3NotificationMainMenuDidHide object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rightSideViewWillHide) name:A3NotificationRightSideViewWillDismiss object:nil];
	}
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cloudStoreDidImport) name:A3NotificationCloudKeyValueStoreDidImport object:nil];
}

- (void)cloudStoreDidImport {
	[self readFromSavedValue];
	[self reloadTableViewDataWithInitialization:YES];
	if ([self isAddSubMode]) {
		[self refreshAddSubModeButtonForResultWithAnimation:YES];
	}
}

- (void)readFromSavedValue {
	// 저장된 textField의 값으로 초기화 하도록 수정.
	self.offsetComp = [A3DateCalcAddSubCell2 dateComponentBySavedText];

	if (self.fromDate==nil) {
		self.fromDate = [NSDate date];
	}
	if (self.toDate==nil) {
		NSDateComponents *comp = [NSDateComponents new];
		comp.month = 1;
		self.toDate = [[A3DateCalcStateManager currentCalendar] dateByAddingComponents:comp toDate:self.fromDate options:0];
	}

	if ([A3DateCalcStateManager excludeOptions]==0) {
		[A3DateCalcStateManager setExcludeOptions:ExcludeOptions_None];
	}
	if ([A3DateCalcStateManager durationType]==0) {
        [A3DateCalcStateManager setDurationType:DurationType_Day];
	}
}

- (void)removeObserver {
	FNLOG();
	[self removeContentSizeCategoryDidChangeNotification];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationCloudKeyValueStoreDidImport object:nil];
	if (IS_IPAD) {
		[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationMainMenuDidHide object:nil];
		[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationRightSideViewWillDismiss object:nil];
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	[[UIApplication sharedApplication] setStatusBarHidden:NO];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];

	if (IS_IPHONE && [UIWindow interfaceOrientationIsPortrait]) {
		[self leftBarButtonAppsButton];
	}
    if ([self isMovingToParentViewController] || [self isBeingPresented]) {
        [self setupBannerViewForAdUnitID:AdMobAdUnitIDDateCalc keywords:@[@"calendar"] delegate:self];
    }
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

- (void)prepareClose {
    if (self.presentedViewController) {
        [self.presentedViewController dismissViewControllerAnimated:NO completion:nil];
    }
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    [self removeObserver];
}

- (void)cleanUp {
	[self removeObserver];
}

- (void)dealloc {
	[self removeObserver];
}

- (void)rightSideViewWillHide {
	[self enableControls:YES];
}

- (void)mainMenuDidHide {
	[self enableControls:YES];
}

- (BOOL)resignFirstResponder {
	FNLOG();
	[self dismissDateKeyboard];
	[self dismissNumberKeyboard];
	
	return [super resignFirstResponder];
}

- (void)initializeControl
{
    // HeaderView
    self.headerView = [[A3DateCalcHeaderView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), IS_IPHONE ? 104 : 158)];
    self.headerView.delegate = self;
    self.headerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleRightMargin;
    self.tableView.separatorInset = A3UITableViewSeparatorInset;
	if ([self.tableView respondsToSelector:@selector(cellLayoutMarginsFollowReadableWidth)]) {
		self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
	}
	if ([self.tableView respondsToSelector:@selector(layoutMargins)]) {
		self.tableView.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0);
	}
    if (IS_IPAD) {
        self.navigationItem.hidesBackButton = YES;
    }
    
    self.tableView.tableHeaderView = self.headerView;
    
    // NavigationItem
//    UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"addToDaysCounter"]
//                                                            style:UIBarButtonItemStylePlain
//                                                           target:self
//                                                           action:@selector(addEventButtonAction:)];
    UIBarButtonItem *share = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"share"]
                                                              style:UIBarButtonItemStylePlain
                                                             target:self
                                                             action:@selector(shareButtonAction:)];
    self.navigationItem.rightBarButtonItems = @[share];
}

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    if (IS_IPAD) {
        if ([self isAddSubMode]) {
            [self refreshAddSubModeButtonForResultWithAnimation:YES];
        }
        else {
            [self.headerView setFromDate:self.fromDate toDate:self.toDate];
        }
    }
}

- (void)contentSizeDidChange:(NSNotification *)notification {
    [self.headerView setNeedsLayout];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
	
	if (IS_IPHONE && [UIWindow interfaceOrientationIsPortrait]) {
		[self leftBarButtonAppsButton];
	}
	
	if (_isDateKeyboardVisible && self.dateKeyboardViewController.view.superview) {
		UIView *keyboardView = self.dateKeyboardViewController.view;
		CGFloat keyboardHeight = self.dateKeyboardViewController.keyboardHeight;

		UIEdgeInsets contentInset = self.tableView.contentInset;
		contentInset.bottom = keyboardHeight;
		self.tableView.contentInset = contentInset;

		FNLOGRECT(self.view.bounds);
		FNLOG(@"%f", keyboardHeight);
		keyboardView.frame = CGRectMake(0, self.view.bounds.size.height - keyboardHeight, self.view.bounds.size.width, keyboardHeight);
		[self.dateKeyboardViewController rotateToInterfaceOrientation:toInterfaceOrientation];

		[self.tableView scrollToRowAtIndexPath:_editingIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
	}
	
	if (_isNumberKeyboardVisible && self.numberKeyboardViewController.view.superview) {
		UIView *keyboardView = self.numberKeyboardViewController.view;
		CGFloat keyboardHeight = self.numberKeyboardViewController.keyboardHeight;
		
		UIEdgeInsets contentInset = self.tableView.contentInset;
		contentInset.bottom = keyboardHeight;
		self.tableView.contentInset = contentInset;
		
		FNLOGRECT(self.view.bounds);
		FNLOG(@"%f", keyboardHeight);
		keyboardView.frame = CGRectMake(0, self.view.bounds.size.height - keyboardHeight, self.view.bounds.size.width, keyboardHeight);
		[self.numberKeyboardViewController rotateToInterfaceOrientation:toInterfaceOrientation];
		
		[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
	}
}

- (void)clearEverything {
	if (_editingIndexPath) {
		UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:_editingIndexPath];
		cell.detailTextLabel.textColor = COLOR_TABLE_DETAIL_TEXTLABEL;
		_editingIndexPath = nil;
	}

	[self dismissNumberKeyboard];
	[self dismissDateKeyboard];
	
	[self dismissMoreMenu];
}

#pragma mark - Properties

-(void)setIsAddSubMode:(BOOL)isAddSubMode
{
	[[A3SyncManager sharedSyncManager] setBool:isAddSubMode forKey:A3DateCalcDefaultsIsAddSubMode state:A3DataObjectStateModified];
}

-(BOOL)isAddSubMode
{
    return [[A3SyncManager sharedSyncManager] boolForKey:A3DateCalcDefaultsIsAddSubMode];
}

-(BOOL)didSelectedAdd
{
    BOOL didSelectMinus = [[A3SyncManager sharedSyncManager] boolForKey:A3DateCalcDefaultsDidSelectMinus];
    return didSelectMinus==YES? NO : YES;
}

-(void)setFromDate:(NSDate *)fromDate
{
    _fromDate = [fromDate copy];
    NSDateComponents *comp = [[A3DateCalcStateManager currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute
                                                                         fromDate:_fromDate];
    comp.hour = 0;
    comp.minute = 0;
    _fromDate = [[A3DateCalcStateManager currentCalendar] dateFromComponents:comp];

	[[A3SyncManager sharedSyncManager] setObject:_fromDate forKey:A3DateCalcDefaultsFromDate state:A3DataObjectStateModified];
}

-(void)setToDate:(NSDate *)toDate
{
    _toDate = [toDate copy];
    NSDateComponents *comp = [[A3DateCalcStateManager currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute
                                                                         fromDate:_toDate];
    comp.hour = 0;
    comp.minute = 0;
    _toDate = [[A3DateCalcStateManager currentCalendar] dateFromComponents:comp];

	[[A3SyncManager sharedSyncManager] setObject:_toDate forKey:A3DateCalcDefaultsToDate state:A3DataObjectStateModified];
}

-(void)setOffsetDate:(NSDate *)offsetDate
{
    _offsetDate = [offsetDate copy];
	[[A3SyncManager sharedSyncManager] setObject:_offsetDate forKey:A3DateCalcDefaultsOffsetDate state:A3DataObjectStateModified];
}

- (NSDate *)fromDate
{
    _fromDate = [[A3SyncManager sharedSyncManager] objectForKey:A3DateCalcDefaultsFromDate];
    return _fromDate;
}

- (NSDate *)toDate
{
    _toDate = [[A3SyncManager sharedSyncManager] objectForKey:A3DateCalcDefaultsToDate];
    return _toDate;
}

- (NSDate *)offsetDate
{
    _offsetDate = [[A3SyncManager sharedSyncManager] objectForKey:A3DateCalcDefaultsOffsetDate];
    return _offsetDate;
}

- (NSDateComponents *)betweenDateCalculatedFromTo
{
    NSUInteger unitFlags =NSCalendarUnitDay;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [calendar components:unitFlags fromDate:self.fromDate toDate:self.toDate options:0];
    return components;
}

#pragma mark - Button Actions

- (IBAction)addButtonTouchUpAction:(id)sender
{
	[[A3SyncManager sharedSyncManager] setBool:NO forKey:A3DateCalcDefaultsDidSelectMinus state:A3DataObjectStateModified];

	BOOL isMinusSelected = NO;

    A3DateCalcAddSubCell1 *footerAddSubCell = (A3DateCalcAddSubCell1 *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]];
    footerAddSubCell.addModeButton.selected = isMinusSelected ? NO : YES;
    footerAddSubCell.subModeButton.selected = isMinusSelected ? YES : NO;
    [footerAddSubCell.addModeButton setBackgroundColor:isMinusSelected ? kDefaultButtonColor : kSelectedButtonColor];
    [footerAddSubCell.subModeButton setBackgroundColor:isMinusSelected ? kSelectedButtonColor : kDefaultButtonColor];
    [footerAddSubCell.addModeButton setNeedsDisplay];
    [footerAddSubCell.subModeButton setNeedsDisplay];
    
    [self refreshAddSubModeButtonForResultWithAnimation:YES];
}

- (IBAction)subButtonTouchUpAction:(id)sender
{
	[[A3SyncManager sharedSyncManager] setBool:YES forKey:A3DateCalcDefaultsDidSelectMinus state:A3DataObjectStateModified];

    BOOL isMinusSelected = YES;
    
    A3DateCalcAddSubCell1 *footerAddSubCell = (A3DateCalcAddSubCell1 *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]];
    footerAddSubCell.addModeButton.selected = isMinusSelected ? NO : YES;
    footerAddSubCell.subModeButton.selected = isMinusSelected ? YES : NO;
    [footerAddSubCell.addModeButton setBackgroundColor:isMinusSelected ? kDefaultButtonColor : kSelectedButtonColor];
    [footerAddSubCell.subModeButton setBackgroundColor:isMinusSelected ? kSelectedButtonColor : kDefaultButtonColor];
    [footerAddSubCell.addModeButton setNeedsDisplay];
    [footerAddSubCell.subModeButton setNeedsDisplay];
    
    [self refreshAddSubModeButtonForResultWithAnimation:YES];
}

- (void)refreshAddSubModeButtonForResultWithAnimation:(BOOL)animation
{
    NSDateComponents *compAdd = [NSDateComponents new];
    
    if ([self didSelectedAdd]) {
        NSDate *result = [[A3DateCalcStateManager currentCalendar] dateByAddingComponents:self.offsetComp
                                                                                   toDate:_fromDate
                                                                                  options:0];
        [self.headerView setFromDate:self.fromDate toDate:result];
        [self.headerView setResultAddDate:result withAnimation:animation];
        
    } else {
        compAdd.year = self.offsetComp.year * -1;
        compAdd.month = self.offsetComp.month * -1;
        compAdd.day = self.offsetComp.day * -1;
        NSDate *result = [[A3DateCalcStateManager currentCalendar] dateByAddingComponents:compAdd
                                                                                   toDate:_fromDate
                                                                                  options:0];
        [self.headerView setFromDate:self.fromDate toDate:result];
        [self.headerView setResultSubDate:result withAnimation:animation];
    }
}

- (void)appsButtonAction:(UIBarButtonItem *)barButtonItem {
	FNLOG();

	[self clearEverything];
	[super appsButtonAction:barButtonItem];
	if (IS_IPAD) {
		[self enableControls:![[A3AppDelegate instance] rootViewController_iPad].showLeftView];
	}
}

- (void)addEventButtonAction:(UIButton *)button
{
    [self clearEverything];
    A3DateCalcEditEventViewController *viewController = [[A3DateCalcEditEventViewController alloc] initWithStyle:UITableViewStyleGrouped];
	viewController.delegate = self;

    if (IS_IPHONE) {
        [self.navigationController pushViewController:viewController animated:YES];
    } else {
		[self enableControls:NO];
		[[[A3AppDelegate instance] rootViewController_iPad] presentRightSideViewController:viewController toViewController:nil];
    }
}

- (void)enableControls:(BOOL)enable {
	if (!IS_IPAD) return;
	[self.navigationItem.leftBarButtonItem setEnabled:enable];
	[self.navigationItem.rightBarButtonItem setEnabled:enable];
}

#pragma mark Share

- (void)shareButtonAction:(id)sender {
    [self clearEverything];

	_sharePopoverController =
			[self presentActivityViewControllerWithActivityItems:@[self]
											   fromBarButtonItem:sender
											   completionHandler:^() {
												   [self enableControls:YES];
											   }];
	_sharePopoverController.delegate = self;
    if (IS_IPAD) {
        _sharePopoverController.delegate = self;
		[self enableControls:NO];
    }
}

#pragma mark Share Activities related

- (NSString *)activityViewController:(UIActivityViewController *)activityViewController subjectForActivityType:(NSString *)activityType
{
	if ([activityType isEqualToString:UIActivityTypeMail]) {
		return NSLocalizedString(@"Date Calculator using AppBox Pro", @"Date Calculator using AppBox Pro");
	}
    
	return @"";
}

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType
{
	if ([activityType isEqualToString:UIActivityTypeMail]) {
		return [self shareMailMessageWithHeader:NSLocalizedString(@"I'd like to share a calculation with you.", nil)
									   contents:[[self stringForShareForActivityType:UIActivityTypeMail] stringByAppendingString:@"<br/>"]
										   tail:NSLocalizedString(@"You can calculate more in the AppBox Pro.", nil)];
	}
	else {
        NSString *shareString = [self stringForShareForActivityType:nil];
        shareString = [shareString stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
		return shareString;
	}
}

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController
{
	return NSLocalizedString(@"Share Currency Converter Data", nil);
}

- (NSString *)stringForShareForActivityType:(NSString *)activityType {
    NSString *shareString;
    if (self.isAddSubMode) {
        shareString = [self stringOfAddSubModeForShareActivityType:activityType];
    }
    else {
        shareString = [self stringOfBetweenModeForShareActivityType:activityType];
    }
    return shareString;
}

- (NSString *)stringOfBetweenModeForShareActivityType:(NSString *)activityType {
    
    NSMutableString *shareString = [[NSMutableString alloc] init];
    /*  Between인 경우
     "Calculate duration between two dates.
     From and including: 시작날
     To, but not including: 끝날
     Result:  ? years ? months ? days" */
    if ([activityType isEqualToString:UIActivityTypeMail] || [NSDate isFullStyleLocale]) {
        [shareString appendString:[NSString stringWithFormat:@"%@: %@<br>", NSLocalizedString(@"From", @"From"), [A3DateCalcStateManager fullStyleDateStringFromDate:_fromDate]]];
        [shareString appendString:[NSString stringWithFormat:@"%@: %@<br>", NSLocalizedString(@"To", @"To"), [A3DateCalcStateManager fullStyleDateStringFromDate:_toDate]]];
    }
    else {
        [shareString appendString:[NSString stringWithFormat:@"%@: %@<br>", NSLocalizedString(@"From", @"From"), [A3DateCalcStateManager fullCustomStyleDateStringFromDate:_fromDate]]];
        [shareString appendString:[NSString stringWithFormat:@"%@: %@<br>", NSLocalizedString(@"To", @"To"), [A3DateCalcStateManager fullCustomStyleDateStringFromDate:_toDate]]];
    }

    if ([A3DateCalcStateManager excludeOptions] != ExcludeOptions_None) {
        [shareString appendString:[NSString stringWithFormat:@"%@ %@<br>", NSLocalizedString(@"Exclude", @"Exclude"), [A3DateCalcStateManager excludeOptionsString]]];
    }
    
    NSDateComponents *intervalComp = [A3DateCalcStateManager dateComponentFromDate:_fromDate toDate:_toDate];
    DurationType durationType = [A3DateCalcStateManager durationType];
    NSMutableString *intervals = [[NSMutableString alloc] init];
    
    if ( (durationType & DurationType_Year) && intervalComp.year !=0 ) {
		[intervals appendString:@" "];
        [intervals appendString:[NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld years", @"StringsDict", nil), labs((long) intervalComp.year)]];
    }
    
    if ( (durationType & DurationType_Month) && intervalComp.month != 0 ) {
		[intervals appendString:@" "];
        [intervals appendString:[NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld months", @"StringsDict", nil), labs((long)intervalComp.month)]];
    }
    
    if ( (durationType & DurationType_Week) && intervalComp.weekOfYear !=0 ) {
		[intervals appendString:@" "];
        [intervals appendString:[NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld weeks", @"StringsDict", nil), labs((long)intervalComp.weekOfYear)]];
    }
    
    if ( (durationType & DurationType_Day) && intervalComp.day!=0 ) {
		[intervals appendString:@" "];
        [intervals appendString:[NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld days", @"StringsDict", nil), labs((long)intervalComp.day)]];
    }
    
    [shareString appendString:[NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Result", @"Result"), intervals]];

    return shareString;
}

- (NSString *)stringOfAddSubModeForShareActivityType:(NSString *)activityType {
    NSMutableString *shareString = [[NSMutableString alloc] init];
    
    /* Date Calculator
     From 시작날
     Added (or Subtracted)  x years ?? months ?? days (값이 0이 아닌 경우만 표시)
     Result: 결과 값  */
    if ([self didSelectedAdd]) {
        NSDate *result = [[A3DateCalcStateManager currentCalendar] dateByAddingComponents:self.offsetComp
                                                                                   toDate:_fromDate
                                                                                  options:0];
        
        if ([activityType isEqualToString:UIActivityTypeMail] || [NSDate isFullStyleLocale]) {
            [shareString appendString:[NSString stringWithFormat:@"%@: %@<br>", NSLocalizedString(@"From", @"From"), [A3DateCalcStateManager fullStyleDateStringFromDate:_fromDate]]];
        }
        else {
            [shareString appendString:[NSString stringWithFormat:@"%@: %@<br>", NSLocalizedString(@"From", @"From"), [A3DateCalcStateManager fullCustomStyleDateStringFromDate:_fromDate]]];
        }
        
        NSMutableString *resultShareString = [[NSMutableString alloc] init];
        if (self.offsetComp.year!=0) {
			[resultShareString appendString:@" "];
            [resultShareString appendString:[NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld years", @"StringsDict", nil), labs((long)self.offsetComp.year)]];
        }
        if (self.offsetComp.month!=0) {
			[resultShareString appendString:@" "];
            [resultShareString appendString:[NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld months", @"StringsDict", nil), labs((long)self.offsetComp.month)]];
        }
        if (self.offsetComp.day!=0) {
			[resultShareString appendString:@" "];
            [resultShareString appendString:[NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld days", @"StringsDict", nil), labs((long)self.offsetComp.day)]];
        }
        
        if (resultShareString.length <= 0) {
            [shareString appendString:[NSString stringWithFormat:@"%@: 0 %@<br>", NSLocalizedString(@"Add", @"Add"), NSLocalizedString(@"day", @"day")]];
        }
        else {
            [shareString appendString:[NSString stringWithFormat:@"%@: %@<br>", NSLocalizedString(@"Add", @"Add"), resultShareString]];
        }
        
        if ([activityType isEqualToString:UIActivityTypeMail] || [NSDate isFullStyleLocale]) {
            [shareString appendString:[NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Result", @"Result"), [A3DateCalcStateManager fullStyleDateStringFromDate:result]]];
        }
        else {
            [shareString appendString:[NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Result", @"Result"), [A3DateCalcStateManager fullCustomStyleDateStringFromDate:result]]];
        }
    }
    else {
        NSDateComponents *compAdd = [NSDateComponents new];
        compAdd.year = self.offsetComp.year * -1;
        compAdd.month = self.offsetComp.month * -1;
        compAdd.day = self.offsetComp.day * -1;
        
        NSDate *result = [[A3DateCalcStateManager currentCalendar] dateByAddingComponents:compAdd
                                                                                   toDate:_fromDate
                                                                                  options:0];
        if ([activityType isEqualToString:UIActivityTypeMail] || [NSDate isFullStyleLocale]) {
            [shareString appendString:[NSString stringWithFormat:@"%@: %@<br>", NSLocalizedString(@"From", @"From"), [A3DateCalcStateManager fullStyleDateStringFromDate:_fromDate]]];
        }
        else {
            [shareString appendString:[NSString stringWithFormat:@"%@: %@<br>", NSLocalizedString(@"From", @"From"), [A3DateCalcStateManager fullCustomStyleDateStringFromDate:_fromDate]]];
        }
        
        NSMutableString *resultShareString = [[NSMutableString alloc] init];
        if (self.offsetComp.year!=0) {
			[resultShareString appendString:@" "];
            [resultShareString appendString:[NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld years", @"StringsDict", nil), labs((long)self.offsetComp.year)]];
        }
        if (self.offsetComp.month!=0) {
			[resultShareString appendString:@" "];
            [resultShareString appendString:[NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld months", @"StringsDict", nil), labs((long)self.offsetComp.month)]];
        }
        if (self.offsetComp.day!=0) {
			[resultShareString appendString:@" "];
            [resultShareString appendString:[NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld days", @"StringsDict", nil), labs((long)self.offsetComp.day)]];
        }
        
        if (resultShareString.length <= 0) {
            [shareString appendString:[NSString stringWithFormat:@"%@: 0 %@<br>", NSLocalizedString(@"Subtract", @"Subtract"), NSLocalizedString(@"day", @"day")]];
        } else {
            [shareString appendString:[NSString stringWithFormat:@"%@: %@<br>", NSLocalizedString(@"Subtract", @"Subtract"), resultShareString]];
        }
        
        if ([activityType isEqualToString:UIActivityTypeMail] || [NSDate isFullStyleLocale]) {
            [shareString appendString:[NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Result", @"Result"), [A3DateCalcStateManager fullStyleDateStringFromDate:result]]];
        }
        else {
            [shareString appendString:[NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Result", @"Result"), [A3DateCalcStateManager fullCustomStyleDateStringFromDate:result]]];
        }
    }

    return shareString;
}

#pragma mark - More Menu Actions

- (void)moreButtonAction:(id)button
{
	[self rightBarButtonDoneButton];

	UIButton *add = [UIButton buttonWithType:UIButtonTypeSystem];
	[add setImage:[UIImage imageNamed:@"addToDaysCounter"] forState:UIControlStateNormal];
	[add addTarget:self action:@selector(addEventButtonAction:) forControlEvents:UIControlEventTouchUpInside];

	UIButton *space = [UIButton buttonWithType:UIButtonTypeSystem];

	_moreMenuButtons = @[add, space, self.shareButton];

	_moreMenuView = [self presentMoreMenuWithButtons:_moreMenuButtons pullDownView:self.tableView];
	_isShowMoreMenu = YES;
}

- (void)doneButtonAction:(id)button {
	[self clearEverything];
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
	}];
	[self.view removeGestureRecognizer:gestureRecognizer];
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
	// Popover controller, iPad only.
	[self enableControls:YES];
	_sharePopoverController = nil;
}

#pragma mark - View Control Actions

- (void)moveToFromDateCell
{
    _datePrevShow = NO;
    _dateNextShow = YES;
    
    self.editingIndexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:self.editingIndexPath];
    cell.detailTextLabel.textColor = [[A3UserDefaults standardUserDefaults] themeColor];
	
    cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
    cell.detailTextLabel.textColor = COLOR_TABLE_DETAIL_TEXTLABEL;
    _isSelectedFromToCell = YES;
	
	[self presentDateKeyboard];
	
	[self.tableView scrollToRowAtIndexPath:_editingIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (void)moveToToDateCell
{
    _datePrevShow = NO;
    _dateNextShow = YES;
    
    self.editingIndexPath = [NSIndexPath indexPathForRow:1 inSection:1];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:self.editingIndexPath];
    cell.detailTextLabel.textColor = [[A3UserDefaults standardUserDefaults] themeColor];
	
    cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    cell.detailTextLabel.textColor = COLOR_TABLE_DETAIL_TEXTLABEL;
    _isSelectedFromToCell = YES;

	[self presentDateKeyboard];
	
	[self.tableView scrollToRowAtIndexPath:_editingIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (void)presentDateKeyboard {
	if (_isDateKeyboardVisible) {
		return;
	}
    [self dismissNumberKeyboard];
    
	_isDateKeyboardVisible = YES;
	
	if (!self.dateKeyboardViewController) {
		self.dateKeyboardViewController = [self newDateKeyboardViewController];
	}
	self.dateKeyboardViewController.delegate = self;
	
	CGRect bounds = [A3UIDevice screenBoundsAdjustedWithOrientation];
	CGFloat keyboardHeight = self.dateKeyboardViewController.keyboardHeight;
	UIView *keyboardView = self.dateKeyboardViewController.view;
	[self.view addSubview:keyboardView];
	[self addChildViewController:self.dateKeyboardViewController];

	UIEdgeInsets contentInset = self.tableView.contentInset;
	contentInset.bottom += keyboardHeight;
	self.tableView.contentInset = contentInset;
	
	FNLOGRECT(self.view.bounds);
	keyboardView.frame = CGRectMake(0, self.view.bounds.size.height, bounds.size.width, keyboardHeight);
	[UIView animateWithDuration:0.3 animations:^{
		CGRect frame = keyboardView.frame;
		frame.origin.y -= keyboardHeight;
		keyboardView.frame = frame;
	} completion:^(BOOL finished) {
	}];
}

- (void)dismissDateKeyboard {
	if (!_isDateKeyboardVisible) {
		return;
	}
	
	UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:_editingIndexPath];
	if (cell) {
		cell.detailTextLabel.textColor = COLOR_TABLE_DETAIL_TEXTLABEL;
	}
	CGFloat keyboardHeight = self.dateKeyboardViewController.keyboardHeight;
	
	UIEdgeInsets contentInset = self.tableView.contentInset;
	contentInset.bottom = 0;
	self.tableView.contentInset = contentInset;

	[UIView animateWithDuration:0.3 animations:^{
		UIView *keyboardView = self.dateKeyboardViewController.view;
		CGRect frame = keyboardView.frame;
		frame.origin.y += keyboardHeight;
		keyboardView.frame = frame;
	} completion:^(BOOL finished) {
		[self.dateKeyboardViewController.view removeFromSuperview];
		[self.dateKeyboardViewController removeFromParentViewController];
		_isDateKeyboardVisible = NO;
	}];
}

- (void)setResultToHeaderViewWithAnimation:(BOOL)animation
{
    self.fromDateCursor = [self.fromDate copy];
    self.toDateCursor = [self.toDate copy];
    
    if (self.isAddSubMode) {
        [self refreshAddSubModeButtonForResultWithAnimation:animation];
    }
    else {
        NSDateComponents *resultComp;
        resultComp = [A3DateCalcStateManager dateComponentFromDate:_fromDate toDate:_toDate];
        
        [self.headerView setCalcType:CALC_TYPE_BETWEEN];
        [self.headerView setFromDate:self.fromDate toDate:self.toDate];
        [self.headerView setResultBetweenDate:resultComp withAnimation:animation];
    }
}

#pragma mark - HeaderView Delegate

- (void)dateCalcHeaderChangedFromDate:(NSDate *)fDate toDate:(NSDate *)tDate
{
    FNLOG(@"fDate: %@", fDate);
    FNLOG(@"tDate: %@", tDate);
    
    if ([self.fromDate compare:self.toDate] == NSOrderedDescending) {   // from > to, 큰 값이 오른쪽(to)에 위치한다.
        self.fromDateCursor = tDate;
        self.toDateCursor = fDate;
    } else {
        self.fromDateCursor = fDate;
        self.toDateCursor = tDate;
    }
    
    if (![self isAddSubMode]) {
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1], [NSIndexPath indexPathForRow:1 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
    }
}

-(void)dateCalcHeaderAddSubResult:(NSDateComponents *)compResult {
    //    footerCell.yearTextField.text = [NSString stringWithFormat:@"%d", compResult.year];
    //    footerCell.monthTextField.text = [NSString stringWithFormat:@"%d", compResult.month];
    //    footerCell.dayTextField.text = [NSString stringWithFormat:@"%d", compResult.day];
}

-(void)dateCalcHeaderFromThumbTapped {
    /*
     * from 이 더 큰 경우, to와 위치가 바뀜.
     - Between
     : from 이 to 보다 작거나 같은 경우 => from 서클(left) Tap => from 셀로 이동.
     : from 이 to 보다 작거나 같은 경우 => to 서클(right) Tap => to 셀로 이동.
     : (reverse) from 이 to 보다 큰 경우 => to 서클(right) Tap => From 셀로 이동.
     : (reverse) from 이 to 보다 큰 경우 => from 서클(left) Tap => to 셀로 이동.
     
     - AddSub
     : add 모드 => from 서클(left) Tap => from 셀로 이동.
     : add 모드 => to 서클(right) Tap => 하단 날짜 입력 필드 이동?
     : (reverse) sub 모드 => from 서클(left) Tap => 하단 날짜 입력 필드 이동?
     : (reverse) sub 모드 => to 서클(right) Tap => from 셀로 이동.
     
     #입력중에도 좌우 크기에 따라서, 터치했던 커서의 위치겨 변경됩니다.
     #회색 처리된 circle 도, 탭 가능.
     */

    if (!self.dateKeyboardViewController) {
        self.dateKeyboardViewController = self.newDateKeyboardViewController;
    }
	
	[self.dateKeyboardViewController changeInputToYear];

	if (!self.isAddSubMode) {

        if ([self.fromDate compare:self.toDate] == NSOrderedDescending) {
            // from > to, 큰 값이 오른쪽(to)에 위치한다.
			self.dateKeyboardViewController.date = self.toDate;
			[self moveToToDateCell];
        } else {
            // from < to
			self.dateKeyboardViewController.date = self.fromDate;
            [self moveToFromDateCell];
        }
        
    } else {
        if ([self didSelectedAdd]) {
			self.dateKeyboardViewController.date = self.fromDate;
            [self moveToFromDateCell];
        } else {
            A3DateCalcAddSubCell2 *footerCell = (A3DateCalcAddSubCell2 *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]];
            if (!footerCell) {
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
                footerCell = (A3DateCalcAddSubCell2 *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]];
            }
            
            [footerCell.yearTextField becomeFirstResponder];
        }
    }
}

-(void)dateCalcHeaderToThumbTapped {
    if (!self.dateKeyboardViewController) {
        self.dateKeyboardViewController = self.newDateKeyboardViewController;
    }
	
	[self.dateKeyboardViewController changeInputToYear];

	if (!self.isAddSubMode) {
        if ([self.fromDate compare:self.toDate] == NSOrderedDescending) {
            // from > to, 큰 값이 오른쪽(to)에 위치한다.
			self.dateKeyboardViewController.date = self.fromDate;
            [self moveToFromDateCell];
        } else {
            // from < to
			self.dateKeyboardViewController.date = self.toDate;
            [self moveToToDateCell];
        }
    }
    else {
        if ([self didSelectedAdd]) {
            A3DateCalcAddSubCell2 *footerCell = (A3DateCalcAddSubCell2 *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]];
            if (!footerCell) {
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
                footerCell = (A3DateCalcAddSubCell2 *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]];
            }
            [footerCell.yearTextField becomeFirstResponder];
        } else {
			self.dateKeyboardViewController.date = self.fromDate;
            [self moveToFromDateCell];
        }
    }
}

-(void)dateCalcHeaderThumbPositionChangeOfFromDate:(NSDate *)fDate toDate:(NSDate *)toDate
{
    FNLOG(@"f: %@, t: %@", fDate, toDate);
//    UITableViewCell *fromCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
//    UITableViewCell *toCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];

    
}

- (void)dateCalcHeaderThumbPositionChangeOfAddSubDateComponents:(NSDateComponents *)dateComp
{
    FNLOG(@"%@", dateComp);
}

#pragma mark - UITextField Related

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
	if (IS_IPHONE && [UIWindow interfaceOrientationIsLandscape]) return NO;

	if (_editingTextField) {
		if (_editingTextField != textField) {
			[self endEditingForTextField:_editingTextField];
			[self prepareEditingForTextField:textField];
			self.numberKeyboardViewController.textInputTarget = textField;
		}
	} else {
		[self presentNumberKeyboardForTextField:textField];
	}
    return NO;
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    if (self.editingObject == textField) {
        [self setEditingObject:nil];
    }

    _isSelectedFromToCell = NO;
    
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:CGPointMake(100, [textField convertPoint:textField.center toView:self.tableView].y)];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (cell && [indexPath section] == 1) {
        cell.detailTextLabel.textColor = COLOR_TABLE_DETAIL_TEXTLABEL;
    }
    
	if (![textField.text length] && _textBeforeEditingText) {
		textField.text = [NSString stringWithFormat:@"%ld", (long)[_textBeforeEditingText floatValueEx]];
	}
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
    
	[self updateOffsetDateCompWithTextField:textField];
	
    if ([self isAddSubMode]) {
        A3DateCalcAddSubCell2 *footerCell = (A3DateCalcAddSubCell2 *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]];
        [footerCell saveInputedTextField:textField];
    }

	textField.placeholder = _placeholderBeforeEditingText;
}

- (void)textFieldDidChange:(NSNotification *)notification {
    
	UITextField *textField = notification.object;
    A3DateCalcAddSubCell2 *footerCell = (A3DateCalcAddSubCell2 *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]];
    if (!footerCell) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        footerCell = (A3DateCalcAddSubCell2 *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]];
    }
    
	if (self.isAddSubMode && [footerCell hasEqualTextField:textField]) {
        if (textField == footerCell.yearTextField) {
            self.offsetComp.year = textField.text.integerValue;
        }
        else if (textField == footerCell.monthTextField) {
            self.offsetComp.month = textField.text.integerValue;
        }
        else if (textField == footerCell.dayTextField) {
            self.offsetComp.day = textField.text.integerValue;
        }
        
        [footerCell saveInputedTextField:textField];
	}
    else {
        FNLOG(@"from/to: %@", notification);
	}
}

- (void)presentNumberKeyboardForTextField:(UITextField *)textField {
	if (_isNumberKeyboardVisible) {
		return;
	}
    [self dismissDateKeyboard];
    
	_isNumberKeyboardVisible = YES;

	[self prepareEditingForTextField:textField];
	
	self.numberKeyboardViewController = [self simplePrevNextNumberKeyboard];
	A3NumberKeyboardViewController *keyboardViewController = self.numberKeyboardViewController;
	keyboardViewController.keyboardType = A3NumberKeyboardTypeInteger;
	keyboardViewController.useDotAsClearButton = YES;
	keyboardViewController.textInputTarget = textField;
	keyboardViewController.delegate = self;
	
	[keyboardViewController view];
	if (IS_IPHONE) {
		((A3NumberKeyboardViewController_iPhone *)keyboardViewController).needButtonsReload = NO;
	}
	
	[keyboardViewController reloadPrevNextButtons];

	CGRect bounds = [A3UIDevice screenBoundsAdjustedWithOrientation];
	CGFloat keyboardHeight = keyboardViewController.keyboardHeight;
	UIView *keyboardView = keyboardViewController.view;
	[self.view addSubview:keyboardView];
	[self addChildViewController:keyboardViewController];
	
	UIEdgeInsets contentInset = self.tableView.contentInset;
	contentInset.bottom += keyboardHeight;
	self.tableView.contentInset = contentInset;

	FNLOGRECT(self.view.bounds);
	keyboardView.frame = CGRectMake(0, self.view.bounds.size.height, bounds.size.width, keyboardHeight);
	[UIView animateWithDuration:0.3 animations:^{
		[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
		CGRect frame = keyboardView.frame;
		frame.origin.y -= keyboardHeight;
		keyboardView.frame = frame;
	} completion:^(BOOL finished) {
	}];
	
}

- (void)dismissNumberKeyboard {
	if (!_isNumberKeyboardVisible) {
		return;
	}
	
	NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:CGPointMake(100, [_editingTextField convertPoint:_editingTextField.center toView:self.tableView].y)];
	UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
	if (cell && [indexPath section] == 1) {
		cell.detailTextLabel.textColor = COLOR_TABLE_DETAIL_TEXTLABEL;
	}

	[self endEditingForTextField:_editingTextField];

	A3NumberKeyboardViewController *keyboardViewController = self.numberKeyboardViewController;
	CGFloat keyboardHeight = keyboardViewController.keyboardHeight;

	[UIView animateWithDuration:0.3 animations:^{
		UIEdgeInsets contentInset = self.tableView.contentInset;
		contentInset.bottom = 0;
		self.tableView.contentInset = contentInset;
		
		UIView *keyboardView = keyboardViewController.view;
		CGRect frame = keyboardView.frame;
		frame.origin.y += keyboardHeight;
		keyboardView.frame = frame;
	} completion:^(BOOL finished) {
		[keyboardViewController.view removeFromSuperview];
		[keyboardViewController removeFromParentViewController];
		self.numberKeyboardViewController = nil;
		_isNumberKeyboardVisible = NO;
	}];
}

- (void)prepareEditingForTextField:(UITextField *)textField {
	self.editingTextField = textField;
	self.textBeforeEditingText = textField.text;
	self.placeholderBeforeEditingText = textField.placeholder;
	self.colorBeforeEditingText = textField.textColor;
	
	textField.text = @"0";
	textField.placeholder = @"0";
    textField.textColor = [[A3UserDefaults standardUserDefaults] themeColor];
	
	A3DateCalcAddSubCell2 *footerCell = (A3DateCalcAddSubCell2 *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]];
	if (!footerCell) {
		footerCell = (A3DateCalcAddSubCell2 *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]];
	}
	
	if (textField == footerCell.yearTextField) {
		_datePrevShow = NO;
		_dateNextShow = YES;
	}
	else if (textField == footerCell.monthTextField) {
		_datePrevShow = YES;
		_dateNextShow = YES;
	}
	else if (textField == footerCell.dayTextField) {
		_datePrevShow = YES;
		_dateNextShow = NO;
	}
}

- (void)endEditingForTextField:(UITextField *)textField {
	if ([textField.text integerValue] == 0 && _textBeforeEditingText) {
		textField.text = [NSString stringWithFormat:@"%ld", (long)[_textBeforeEditingText floatValueEx]];
	}

	[self updateOffsetDateCompWithTextField:textField];
	
	if ([self isAddSubMode]) {
		A3DateCalcAddSubCell2 *footerCell = (A3DateCalcAddSubCell2 *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]];
		[footerCell saveInputedTextField:textField];
	}
	
	textField.placeholder = _placeholderBeforeEditingText;
	textField.textColor = _colorBeforeEditingText;
	_editingTextField = nil;
	_textBeforeEditingText = nil;
}

#pragma mark - A3DateKeyboardViewControllerDelegate

- (void)dateKeyboardValueChangedDate:(NSDate *)date
{
    A3DateCalcAddSubCell2 *footerCell = (A3DateCalcAddSubCell2 *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]];
    if (!footerCell) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        footerCell = (A3DateCalcAddSubCell2 *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]];
    }
    
    // 풋터뷰 필드(ADD/SUB모드)
    if (self.isAddSubMode && (_editingTextField == footerCell.yearTextField || _editingTextField == footerCell.monthTextField || _editingTextField == footerCell.dayTextField)) {
        NSDateComponents *changed = [[A3DateCalcStateManager currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay
                                                                                fromDate:date];
        if (_editingTextField == footerCell.yearTextField) {
            self.offsetComp.year = changed.year;
        }
        else if (_editingTextField == footerCell.monthTextField) {
            self.offsetComp.month = changed.month;
        }
        else if (_editingTextField == footerCell.dayTextField) {
            self.offsetComp.day = changed.day;
        }
        
        [footerCell setOffsetDateComp:self.offsetComp];
    }
    else {
        // From/To Cell
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:_editingIndexPath];
        
        if (self.editingIndexPath.row == 0) {
            if (self.isAddSubMode) {
                self.fromDate = date == nil ? [NSDate date] : date;
            }
            else {
                self.fromDate = date == nil ? [NSDate date] : date;
            }
            
            if (cell) {
                cell.detailTextLabel.text = (IS_IPAD || [NSDate isFullStyleLocale]) ? [A3DateCalcStateManager fullStyleDateStringFromDate:self.fromDate] : [A3DateCalcStateManager fullCustomStyleDateStringFromDate:self.fromDate];
                cell.detailTextLabel.textColor = [[A3UserDefaults standardUserDefaults] themeColor];
            }
        }
        else {
            self.toDate = date == nil ? [NSDate date] : date;
            if (cell) {
                cell.detailTextLabel.text = (IS_IPAD || [NSDate isFullStyleLocale]) ? [A3DateCalcStateManager fullStyleDateStringFromDate:self.toDate] : [A3DateCalcStateManager fullCustomStyleDateStringFromDate:self.toDate];
                cell.detailTextLabel.textColor = [[A3UserDefaults standardUserDefaults] themeColor];
            }
        }
        
        if (_isSelectedFromToCell) {
            _isSelectedFromToCell = NO;
            [self.tableView deselectRowAtIndexPath:_editingIndexPath animated:YES];
        }
        
        [self setResultToHeaderViewWithAnimation:YES];
    }
}

- (BOOL)isPreviousEntryExists {
    return _datePrevShow;
}

- (BOOL)isNextEntryExists {
    return _dateNextShow;
}

- (void)nextButtonPressed{
    A3DateCalcAddSubCell2 *footerCell = (A3DateCalcAddSubCell2 *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]];
    if (!footerCell) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        footerCell = (A3DateCalcAddSubCell2 *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]];
    }
    
	if (_editingTextField == footerCell.yearTextField) {
		[self endEditingForTextField:_editingTextField];
		
		UITextField *textField = footerCell.monthTextField;
		[self prepareEditingForTextField:textField];
		self.numberKeyboardViewController.textInputTarget = textField;
	}
    else if (_editingTextField == footerCell.monthTextField) {
		[self endEditingForTextField:_editingTextField];
		
		UITextField *textField = footerCell.dayTextField;
		[self prepareEditingForTextField:textField];
		self.numberKeyboardViewController.textInputTarget = textField;
	}
}

- (void)prevButtonPressed
{
    A3DateCalcAddSubCell2 *footerCell = (A3DateCalcAddSubCell2 *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]];
    if (!footerCell) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        footerCell = (A3DateCalcAddSubCell2 *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]];
    }
    
	if (_editingTextField == footerCell.dayTextField) {
		[self endEditingForTextField:_editingTextField];
		
		footerCell.dayTextField.text = [NSString stringWithFormat:@"%ld", (long)self.offsetComp.day];
		
		UITextField *textField = footerCell.monthTextField;
		[self prepareEditingForTextField:textField];
		self.numberKeyboardViewController.textInputTarget = textField;
	}
    else if (_editingTextField == footerCell.monthTextField) {
		[self endEditingForTextField:_editingTextField];
		footerCell.monthTextField.text = [NSString stringWithFormat:@"%ld", (long)self.offsetComp.month];

		UITextField *textField = footerCell.yearTextField;
		[self prepareEditingForTextField:textField];
		self.numberKeyboardViewController.textInputTarget = textField;
	}
    else if (_editingTextField == footerCell.yearTextField) {
		[self endEditingForTextField:_editingTextField];
		footerCell.yearTextField.text = [NSString stringWithFormat:@"%ld", (long)self.offsetComp.year];
		
		[self dismissNumberKeyboard];
		[self moveToFromDateCell];
	}
}

- (void)dateKeyboardDoneButtonPressed:(A3DateKeyboardViewController *)keyboardViewController
{
	[self dismissDateKeyboard];

	_editingIndexPath = nil;
    [self setResultToHeaderViewWithAnimation:YES];
	self.dateKeyboardViewController = nil;
    [self scrollToTopOfTableView];
}

- (void)updateOffsetDateCompWithTextField:(UITextField *)textField
{
    A3DateCalcAddSubCell2 *footerCell = (A3DateCalcAddSubCell2 *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]];
    if (!footerCell) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        footerCell = (A3DateCalcAddSubCell2 *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]];
    }

	if (self.isAddSubMode && (_editingTextField == footerCell.yearTextField || _editingTextField == footerCell.monthTextField || _editingTextField == footerCell.dayTextField)) {
		if (_editingTextField == footerCell.yearTextField) {
			self.offsetComp.year = footerCell.yearTextField.text.integerValue;
		}
        else if (_editingTextField == footerCell.monthTextField) {
			self.offsetComp.month = footerCell.monthTextField.text.integerValue;
		}
        else if (_editingTextField == footerCell.dayTextField) {
			self.offsetComp.day = footerCell.dayTextField.text.integerValue;
		}

		[footerCell setOffsetDateComp:self.offsetComp];
		[self setResultToHeaderViewWithAnimation:YES];
	}
}

- (void)A3KeyboardController:(id)controller doneButtonPressedTo:(UIResponder *)keyInputDelegate {
	if (controller == self.dateKeyboardViewController) {
		[self dismissDateKeyboard];
	} else {
		[self dismissNumberKeyboard];
	}
	
	_editingIndexPath = nil;
    [self setResultToHeaderViewWithAnimation:YES];

	[self scrollToTopOfTableView];
}

- (void)A3KeyboardController:(id)controller clearButtonPressedTo:(UIResponder *)keyInputDelegate {
    UITextField *selectedTextField = _editingTextField;
    selectedTextField.text = @"";
	_textBeforeEditingText = nil;
    A3DateCalcAddSubCell2 *footerCell = (A3DateCalcAddSubCell2 *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]];
    if (!footerCell) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        footerCell = (A3DateCalcAddSubCell2 *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]];
    }
    
	if ([footerCell hasEqualTextField:selectedTextField]) {
		if (selectedTextField == footerCell.yearTextField) {
			self.offsetComp.year = 0;
		}
		else if (selectedTextField==footerCell.monthTextField) {
			self.offsetComp.month = 0;
		}
		else if (selectedTextField==footerCell.dayTextField) {
			self.offsetComp.day = 0;
		}

		[footerCell saveInputedTextField:selectedTextField];
	}
}

#pragma mark - UITableView Related

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.sectionTitles count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.sections[section] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.sectionTitles[section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (![self isAddSubMode]) {
        return section == 0 ? 55 : 0;
    }
    
    return section == 0 ? 55.0 : 25.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (![self isAddSubMode]) {
        return 0;
    }
    
    return section == 3 ? (IS_RETINA ? 37.5 : 38) : 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isAddSubMode==YES && indexPath.section==2 && indexPath.row==0) {
        //return self.footerView.bounds.size.height;
        return 50.0;
    }
    if (self.isAddSubMode==YES && indexPath.section==3 && indexPath.row==0) {
        return 82.0;
    }
    
    return 44.0;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 1:  // From, To 날짜 입력 셀 섹션.
        {
            CGRect rect = cell.detailTextLabel.frame;
            rect.origin.x = 300;//cell.bounds.size.width - cell.detailTextLabel.frame.size.width;
            cell.detailTextLabel.frame = rect;
        }
    }
}

- (A3DateCalcAddSubCell1 *)cellOfAddSub1CellForID:(NSString *)cellAddSubCell1 tableView:(UITableView *)tableView
{
    // FooterViewCell - Add Sub Button Cell
    A3DateCalcAddSubCell1 *footerAddSubCell = [tableView dequeueReusableCellWithIdentifier:cellAddSubCell1];
    if (!footerAddSubCell) {
        footerAddSubCell = [[[NSBundle mainBundle] loadNibNamed:@"A3DateCalcAddSubCell1" owner:self options:nil] lastObject];
    }
    
    [footerAddSubCell.addModeButton addTarget:self action:@selector(addButtonTouchUpAction:) forControlEvents:UIControlEventTouchUpInside];
    [footerAddSubCell.subModeButton addTarget:self action:@selector(subButtonTouchUpAction:) forControlEvents:UIControlEventTouchUpInside];
    
    BOOL isMinusSelected = [[A3SyncManager sharedSyncManager] boolForKey:A3DateCalcDefaultsDidSelectMinus];
    footerAddSubCell.addModeButton.selected = isMinusSelected ? NO : YES;
    footerAddSubCell.subModeButton.selected = isMinusSelected ? YES : NO;
    
    [footerAddSubCell.addModeButton setBackgroundColor:footerAddSubCell.addModeButton.selected? kSelectedButtonColor : kDefaultButtonColor];
    [footerAddSubCell.subModeButton setBackgroundColor:footerAddSubCell.subModeButton.selected? kSelectedButtonColor : kDefaultButtonColor];
    return footerAddSubCell;
}

- (A3DateCalcAddSubCell2 *)cellOfAddSubInputCellForID:(NSString *)cellAddSubCell2 tableView:(UITableView *)tableView
{
    // FooterViewCell - Year Month Day, Input TextField Cell
    A3DateCalcAddSubCell2 *footerCell = [tableView dequeueReusableCellWithIdentifier:cellAddSubCell2];
    if (!footerCell) {
        footerCell = [[[NSBundle mainBundle] loadNibNamed:@"A3DateCalcAddSubCell2" owner:self options:nil] lastObject];
    }
    
    footerCell.yearTextField.delegate = self;
    footerCell.monthTextField.delegate = self;
    footerCell.dayTextField.delegate = self;
    
    [footerCell setOffsetDateComp:self.offsetComp];
    
    if (IS_IPHONE) {
        footerCell.yearLabel.font = [UIFont systemFontOfSize:13];
        footerCell.monthLabel.font = [UIFont systemFontOfSize:13];
        footerCell.dayLabel.font = [UIFont systemFontOfSize:13];
    }
    else {
        footerCell.yearLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        footerCell.monthLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        footerCell.dayLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    }
    return footerCell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *const cellIdentifier = @"Cell";
    static NSString *const cellAddSubCell1 = @"AddSubCell1";
    static NSString *const cellAddSubCell2 = @"AddSubCell2";
    
    if (self.isAddSubMode==YES) {
        if (indexPath.section==2 && indexPath.row==0) {
            A3DateCalcAddSubCell1 *footerAddSubCell;
            footerAddSubCell = [self cellOfAddSub1CellForID:cellAddSubCell1 tableView:tableView];
            return footerAddSubCell;
        }
        else if (indexPath.section==3 && indexPath.row==0) {
            A3DateCalcAddSubCell2 *footerCell;
            footerCell = [self cellOfAddSubInputCellForID:cellAddSubCell2 tableView:tableView];
            return footerCell;
        }
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        UITextField *textField = [UITextField new];
        textField.tag = 11;
        [cell.contentView addSubview:textField];
        [textField makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@10);
            make.top.equalTo(cell.contentView.top);
            make.bottom.equalTo(cell.contentView.bottom);
            make.right.equalTo(cell.contentView.right);
        }];
        textField.hidden = YES;
        textField.delegate = self;
    }
    
    [cell.textLabel setText:self.sections[indexPath.section][indexPath.row]];
    
    switch (indexPath.section) {
        case 0: // Caculation - between, add/sub 모드 선택 섹션.
        {
            switch (indexPath.row) {
                case 0:
                    cell.accessoryType = self.isAddSubMode==YES? UITableViewCellAccessoryNone : UITableViewCellAccessoryCheckmark;
                    break;
                    
                case 1:
                    cell.accessoryType = self.isAddSubMode==YES? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                    break;
            }
            cell.detailTextLabel.text = @"";
        }
            break;
            
        case 1:  // From, To 날짜 입력 셀 섹션.
        {
            UIFont *font = cell.detailTextLabel.font;
            font = [font fontWithSize:17.0];
            cell.detailTextLabel.font = font;
            
            switch (indexPath.row) {
                case 0:
                {
                    cell.detailTextLabel.text = (IS_IPAD || [NSDate isFullStyleLocale]) ? [A3DateCalcStateManager fullStyleDateStringFromDate:self.fromDateCursor] : [A3DateCalcStateManager fullCustomStyleDateStringFromDate:self.fromDateCursor];
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    break;
                }
                case 1:
                {
                    cell.detailTextLabel.text = (IS_IPAD || [NSDate isFullStyleLocale]) ? [A3DateCalcStateManager fullStyleDateStringFromDate:self.toDateCursor] : [A3DateCalcStateManager fullCustomStyleDateStringFromDate:self.toDateCursor];
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    break;
                }
            }

            // 선택된 셀 텍스트 색상 편집 중에만 변경.
            if (_isDateKeyboardVisible && _editingIndexPath && (indexPath.row==_editingIndexPath.row)) {
                cell.detailTextLabel.textColor = [[A3UserDefaults standardUserDefaults] themeColor];
            } else {
                cell.detailTextLabel.textColor = COLOR_TABLE_DETAIL_TEXTLABEL;
            }
        }
            break;
            
        case 2:
        {
            switch (indexPath.row) {
                case 0:
                {
                    cell.detailTextLabel.text = [A3DateCalcStateManager excludeOptionsString];
                    cell.detailTextLabel.textColor = COLOR_TABLE_DETAIL_TEXTLABEL;
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                }
                    break;
            }
        }
            break;
            
        case 3:
        {
            switch (indexPath.row) {
                case 0:
                {
                    cell.detailTextLabel.text = [A3DateCalcStateManager durationTypeString];
                    cell.detailTextLabel.textColor = COLOR_TABLE_DETAIL_TEXTLABEL;
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                }
                    break;
            }
        }
            break;
    }
    
    return cell;
}

- (void)reloadTableViewDataWithInitialization:(BOOL)bInit
{
    if (bInit) {
        if (self.isAddSubMode) {
            self.sectionTitles = @[kCalculationString, @"", @"", @""];
            self.sections = @[
                              @[NSLocalizedString(@"Between two dates", nil), NSLocalizedString(@"Add or Subtract days", nil)],
                              @[NSLocalizedString(@"From", nil)],
                              @[@"AddSubCell1"],
                              @[@"AddSubCell2"]
                              ];
        } else {
            self.sectionTitles = @[kCalculationString, @"", @"", @""];
            self.sections = @[
                              @[NSLocalizedString(@"Between two dates", nil), NSLocalizedString(@"Add or Subtract days", nil)],
                              @[NSLocalizedString(@"From", nil), NSLocalizedString(@"To", nil)],
                              @[NSLocalizedString(@"Exclude", nil)],
                              @[NSLocalizedString(@"Duration", nil)]
                              ];
        }
        
        [_headerView setFromDate:self.fromDate toDate:self.toDate];
        [self setResultToHeaderViewWithAnimation: bInit? NO : YES];
        
        [self.tableView reloadData];
        return;
    }
    else {
        [self setResultToHeaderViewWithAnimation: bInit? NO : YES];
        
        if (self.isAddSubMode) {
            
            self.sectionTitles = @[kCalculationString, @""];
            self.sections = @[
                              @[NSLocalizedString(@"Between two dates", nil), NSLocalizedString(@"Add or Subtract days", nil)],
                              @[NSLocalizedString(@"From", nil)],
                              @[@"AddSubCell1"],
                              @[@"AddSubCell2"]
                              ];
            
            
            self.tableView.allowsSelection = NO;
            [CATransaction begin];
            [CATransaction setCompletionBlock:^{
                self.sectionTitles = @[kCalculationString, @"", @"", @""];
                [CATransaction begin];
                [CATransaction setCompletionBlock:^{
                    [self.tableView reloadData];
                    self.tableView.allowsSelection = YES;
                    
                    if (IS_IPHONE35) {
                        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]
                                              atScrollPosition:UITableViewScrollPositionBottom
                                                      animated:YES];
                    }
                }];
                [self.tableView beginUpdates];
                [self.tableView insertSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(2, 2)] withRowAnimation:UITableViewRowAnimationFade];
                [self.tableView endUpdates];
                [CATransaction commit];
            }];
            
            [self.tableView beginUpdates];
            [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:1]]
                                  withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(2, 2)]
                          withRowAnimation:UITableViewRowAnimationFade];
            
            [self.tableView endUpdates];
            [CATransaction commit];
            
        } else {
            
            self.tableView.allowsSelection = NO;
            self.sectionTitles = @[kCalculationString, @""];
            self.sections = @[
                              @[NSLocalizedString(@"Between two dates", nil), NSLocalizedString(@"Add or Subtract days", nil)],
                              @[NSLocalizedString(@"From", nil), NSLocalizedString(@"To", @"To")]
                              ];
            
            [CATransaction begin];
            [CATransaction setAnimationDuration:0.01];
            [CATransaction setCompletionBlock:^{
                
                self.sectionTitles = @[kCalculationString, @"", @"", @""];
                self.sections = @[
                                  @[NSLocalizedString(@"Between two dates", @"Between two dates"), NSLocalizedString(@"Add or Subtract days", @"Add or Subtract days")],
                                  @[NSLocalizedString(@"From", @"From"), NSLocalizedString(@"To", @"To")],
                                  @[NSLocalizedString(@"Exclude", @"Exclude")],
                                  @[NSLocalizedString(@"Duration", @"Duration")]
                                  ];
                // 2
                [self.tableView beginUpdates];
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0]
                              withRowAnimation:UITableViewRowAnimationNone];
                [self.tableView insertSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationFade];
                [self.tableView insertSections:[NSIndexSet indexSetWithIndex:3] withRowAnimation:UITableViewRowAnimationFade];
                self.tableView.allowsSelection = YES;
                [self.tableView endUpdates];
                
                [CATransaction commit];
            }];
            
            // 1
            [self.tableView beginUpdates];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(2, 2)] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView endUpdates];
            [CATransaction commit];
        }
    }
}

#define kAddSubRowIndex 1

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self dismissMoreMenu];
	
    if (indexPath.section == 0) {
        if ((self.isAddSubMode==YES && indexPath.row==kAddSubRowIndex) || (self.isAddSubMode==NO && indexPath.row==0)) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            return;
        }
        else {
            self.isAddSubMode = !self.isAddSubMode;
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:!indexPath.row inSection:indexPath.section]];
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            [self reloadTableViewDataWithInitialization:NO];
            if ([self isAddSubMode]) {
                [self refreshAddSubModeButtonForResultWithAnimation:NO];
            }
        }
    }
    else if (indexPath.section == 1) {
        // From, To Date Input
        [tableView deselectRowAtIndexPath:indexPath animated:YES];

		if (IS_IPHONE && [UIWindow interfaceOrientationIsLandscape]) return;
		
		if (_isDateKeyboardVisible) {
			if (_editingIndexPath.row != indexPath.row) {
				if ([indexPath row] == 0) {
					self.dateKeyboardViewController.date = self.fromDate;
					[self moveToFromDateCell];
				}
				else {
					self.dateKeyboardViewController.date = self.toDate;
					[self moveToToDateCell];
				}
			} else {
				[self dismissDateKeyboard];
			}
		} else {
			if (!self.dateKeyboardViewController) {
				self.dateKeyboardViewController = self.newDateKeyboardViewController;
			}
			
			[self.dateKeyboardViewController changeInputToYear];
			if ([indexPath row] == 0) {
				self.dateKeyboardViewController.date = self.fromDate;
				[self moveToFromDateCell];
			}
			else {
				self.dateKeyboardViewController.date = self.toDate;
				[self moveToToDateCell];
			}
		}
    }
    else if (indexPath.section == 2 && indexPath.row == 0) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        if (self.isAddSubMode) {
            return;
        }
        
        // Exclude
        [self clearEverything];
        A3DateCalcExcludeViewController *viewController = [[A3DateCalcExcludeViewController alloc] initWithStyle:UITableViewStyleGrouped];
        viewController.delegate = self;
        if (IS_IPHONE) {
            [self.navigationController pushViewController:viewController animated:YES];
        } else {
			[self enableControls:NO];
			[[[A3AppDelegate instance] rootViewController_iPad] presentRightSideViewController:viewController toViewController:nil];
		}
    }
    else if (indexPath.section == 3 && indexPath.row == 0) {
        // Duration
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        if (self.isAddSubMode) {
            return;
        }
        
        [self clearEverything];
        A3DateCalcDurationViewController *viewController = [[A3DateCalcDurationViewController alloc] initWithStyle:UITableViewStyleGrouped];
        viewController.delegate = self;
        if (IS_IPHONE) {
            [self.navigationController pushViewController:viewController animated:YES];
        }
        else {
			[self enableControls:NO];
			[[[A3AppDelegate instance] rootViewController_iPad] presentRightSideViewController:viewController toViewController:nil];
		}
    }
}

- (void)scrollToTopOfTableView {
	[UIView beginAnimations:A3AnimationIDKeyboardWillShow context:nil];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationCurve:7];
	[UIView setAnimationDuration:0.35];
	self.tableView.contentOffset = CGPointMake(0.0, -(self.navigationController.navigationBar.bounds.size.height + [A3UIDevice statusBarHeight]));
	[UIView commitAnimations];
}

#pragma mark - Option Views Delegate

- (void)durationSettingChanged
{
    [self setResultToHeaderViewWithAnimation:YES];
    [self.tableView reloadData];
}

- (void)excludeSettingDelegate
{
    [self setResultToHeaderViewWithAnimation:YES];
    [self.tableView reloadData];
}

- (void)dismissDateCalcDurationViewController {
	[self enableControls:YES];
}

- (void)dismissExcludeSettingViewController {
	[self enableControls:YES];
}

- (void)dismissEditEventViewController {
	[self enableControls:YES];
}

@end
