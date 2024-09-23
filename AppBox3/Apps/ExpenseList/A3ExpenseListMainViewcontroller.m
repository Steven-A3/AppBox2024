//
//  A3ExpenseListMainViewController.m
//  A3TeamWork
//
//  Created by jeonghwan kim on 13. 11. 21..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3ExpenseListMainViewController.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+NumberKeyboard.h"
#import "A3ExpenseListHeaderView.h"
#import "A3ExpenseListItemCell.h"
#import "A3ExpenseListAddBudgetViewController.h"
#import "A3ExpenseListHistoryViewController.h"
#import "A3ExpenseListColumnSectionView.h"
#import "ExpenseListBudget.h"
#import "ExpenseListItem.h"
#import "ExpenseListHistory.h"
#import "NSString+conversion.h"
#import "ExpenseListItem+management.h"
#import "NSMutableArray+A3Sort.h"
#import "UIViewController+iPad_rightSideView.h"
#import "A3CalculatorViewController.h"
#import "UITableView+utility.h"
#import "A3InstructionViewController.h"
#import "ExpenseListBudget+extension.h"
#import "A3SyncManager.h"
#import "NSManagedObject+extension.h"
#import "NSManagedObjectContext+extension.h"
#import "A3SyncManager+NSUbiquitousKeyValueStore.h"
#import "A3UserDefaults.h"
#import "UIViewController+tableViewStandardDimension.h"
#import "A3NavigationController.h"
#import "A3NumberKeyboardViewController_iPhone.h"
#import "A3NumberKeyboardSimpleVC_iPad.h"
#import "NSManagedObject+extension.h"
#import "NSManagedObjectContext+extension.h"
#import "UIViewController+extension.h"
#import "A3AppDelegate.h"
#import "A3UIDevice.h"
#import "A3UserDefaults+A3Addition.h"

#define kDefaultItemCount_iPhone    9
#define kDefaultItemCount_iPad      18

NSString *const A3ExpenseListCurrentBudgetID = @"CurrentBudget";
NSString *const A3NotificationExpenseListCurrencyCodeChanged = @"A3NotificationExpenseListCurrencyCodeChanged";

@interface A3ExpenseListMainViewController () <ATSDragToReorderTableViewControllerDelegate, UIPopoverControllerDelegate,
		A3ExpenseBudgetSettingDelegate, A3ExpenseListItemCellDelegate, UINavigationControllerDelegate,
		A3ExpenseListHistoryDelegate, A3CalculatorViewControllerDelegate, A3InstructionViewControllerDelegate,
		A3ViewControllerProtocol, A3ExpenseListAccessoryDelegate, A3KeyboardDelegate, GADBannerViewDelegate>

@property (nonatomic, strong) A3ExpenseListHeaderView *headerView;
@property (nonatomic, strong) UIView *sep1View;
@property (nonatomic, strong) UIView *sep2View;
@property (nonatomic, strong) UIView *sep3View;
@property (nonatomic, strong) MASConstraint *sep1Const;
@property (nonatomic, strong) MASConstraint *sep2Const;
@property (nonatomic, strong) MASConstraint *sep3Const;
@property (nonatomic, strong) NSArray *moreMenuButtons;
@property (nonatomic, strong) UIView *moreMenuView;
@property (nonatomic, strong) UIPopoverController *sharePopoverController;
@property (nonatomic, strong) A3ExpenseListColumnSectionView *columnSectionView;
@property (nonatomic, strong) NSMutableArray *tableDataSourceArray;
@property (nonatomic, strong) UIButton *addItemButton;
@property (nonatomic, strong) UIView *topWhitePaddingView;
@property (nonatomic, strong) UINavigationController *modalNavigationController;
@property (nonatomic, strong) UITextField *calculatorTargetTextField;
@property (nonatomic, strong) A3ExpenseListItemCell *calculatorTargetCell;
@property (nonatomic, strong) A3InstructionViewController *instructionViewController;
@property (nonatomic, strong) NSNumberFormatter *decimalFormatter;
@property (nonatomic, strong) A3ExpenseListAccessoryView *keyboardAccessoryView;
@property (nonatomic, strong) A3ExpenseListAccessoryView *accessoryForNumberField;

@property (nonatomic, strong) NSIndexPath *editingIndexPath;
@property (nonatomic, weak) UITextField *editingTextField;
@property (nonatomic, weak) A3ExpenseListItemCell *editingCell;
@property (nonatomic, copy) NSString *textBeforeEditingTextField;
@property (nonatomic, copy) UIColor *textColorBeforeEditing;

/*
 * NumberPad 키보드를 UIInputView로 처리하면 iOS 시스템 이벤트에 따라 처리할 수 있지만,
 * 키보드 확장자의 간섭을 피할 수 없어, 별도 처리를 하기 위해서 이름 입력후에 가격/수량 입력을 위한 
 * 별도 처리를 위하여 아래의 변수가 필요하게 되었다.
 */
@property (nonatomic, weak) UITextField *nextEditingTextField;
@property (nonatomic, weak) A3ExpenseListItemCell *nextEditingCell;

@end

@implementation A3ExpenseListMainViewController
{
    ExpenseListBudget *_currentBudget;
    ExpenseListItem *_selectedItem;
	BOOL    _isShowMoreMenu;
    UITapGestureRecognizer *_tapGestureRecognizer;
	BOOL _isAutoMovingAddBudgetView;
	BOOL _barButtonEnabled;
	CGFloat _tableCellStartY;

	BOOL _nextColumnAvail, _prevColumnAvail;

	/// Number Keyboard Management
	BOOL _didPressClearKey, _didPressNumberKey;
	BOOL _isNumberKeyboardVisible;
	BOOL _isSwitchingTextField;
}

NSString *const ExpenseListMainCellIdentifier = @"Cell";

- (void)viewDidLoad
{
    [super viewDidLoad];

	_isAutoMovingAddBudgetView = NO;
	_barButtonEnabled = YES;

    [self makeNavigationBarAppearanceDefault];
    [self makeBackButtonEmptyArrow];
	if (IS_IPAD || [UIWindow interfaceOrientationIsPortrait]) {
		[self leftBarButtonAppsButton];
	} else {
		self.navigationItem.leftBarButtonItem = nil;
		self.navigationItem.hidesBackButton = YES;
	}

    self.title = NSLocalizedString(A3AppName_ExpenseList, nil);

	self.dragDelegate = self;

    _addItemButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_addItemButton setImage:[UIImage imageNamed:@"add03"] forState:UIControlStateNormal];
    [self.view addSubview:_addItemButton];
    [_addItemButton addTarget:self action:@selector(addItemButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    _addItemButton.hidden = YES;

    // 테이블 뷰 Column 구분선.
    _sep1View = [[UIView alloc] initWithFrame:CGRectZero];
    _sep2View = [[UIView alloc] initWithFrame:CGRectZero];
    _sep3View = [[UIView alloc] initWithFrame:CGRectZero];
    _sep1View.backgroundColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0];
    _sep2View.backgroundColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0];
    _sep3View.backgroundColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0];
    [self.view addSubview:_sep1View];
    [self.view addSubview:_sep2View];
    [self.view addSubview:_sep3View];
    // 테이블 뷰 속성 설정.
    self.tableView.tableHeaderView = self.headerView;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    self.tableView.separatorColor = A3UITableViewSeparatorColor;
	self.tableView.separatorInset = A3UITableViewSeparatorInset;
    if (@available(iOS 15.0, *)) {
        self.tableView.sectionHeaderTopPadding = 0;
    }

	if ([self.tableView respondsToSelector:@selector(cellLayoutMarginsFollowReadableWidth)]) {
		self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
	}
	if ([self.tableView respondsToSelector:@selector(layoutMargins)]) {
		self.tableView.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0);
	}
    [self.tableView registerClass:[A3ExpenseListItemCell class] forCellReuseIdentifier:ExpenseListMainCellIdentifier];
    // 테이블 뷰 탭 제스쳐.
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnTableView:)];
    _tapGestureRecognizer.numberOfTouchesRequired = 1;
    _tapGestureRecognizer.numberOfTapsRequired = 1;
    [self.tableView addGestureRecognizer:_tapGestureRecognizer];
    
    _columnSectionView = [[A3ExpenseListColumnSectionView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 45.0)];

    if (IS_IPHONE) {
        [self rightButtonMoreButton];
    }
    else {
        [self makeRightBarButtons];
    }
	[self reloadBudgetDataWithAnimation:NO saveData:YES];
    [self setupTopWhitePaddingView];
    [self expandContentSizeForAddItem];
    [self setupInstructionView];
    
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currencyCodeChanged:) name:A3NotificationExpenseListCurrencyCodeChanged object:nil];

	if (IS_IPAD) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainMenuDidHide) name:A3NotificationMainMenuDidHide object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rightSideViewDidAppear) name:A3NotificationRightSideViewDidAppear object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rightSideViewWillDismiss) name:A3NotificationRightSideViewWillDismiss object:nil];
	}

	[self registerContentSizeCategoryDidChangeNotification];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cloudStoreDidImport) name:A3NotificationCloudCoreDataStoreDidImport object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cloudStoreDidImport) name:A3NotificationCloudKeyValueStoreDidImport object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(systemKeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(systemKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)systemKeyboardWillShow:(NSNotification *)notification {
	UIEdgeInsets contentInset = self.tableView.contentInset;
	contentInset.bottom = 0;
	self.tableView.contentInset = contentInset;
}

- (void)systemKeyboardWillHide:(NSNotification *)notification {
	UIEdgeInsets contentInset = self.tableView.contentInset;
	contentInset.bottom = self.bannerView ? self.bannerView.bounds.size.height : 0;
	self.tableView.contentInset = contentInset;
}

- (void)applicationDidEnterBackground {
	[self dismissInstructionViewController:nil];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	[[UIApplication sharedApplication] setStatusBarHidden:NO];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
	
	if (IS_IPHONE && [UIWindow interfaceOrientationIsPortrait]) {
		[self leftBarButtonAppsButton];
	}
    if ([self isMovingToParentViewController] || [self isBeingPresented]) {
        [self setupBannerViewForAdUnitID:AdMobAdUnitIDExpenseList keywords:@[@"expense"] delegate:self];
    }
	if ([self.navigationController.navigationBar isHidden]) {
		[self showNavigationBarOn:self.navigationController];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	if ([self isMovingFromParentViewController] || [self isBeingDismissed]) {
		[self removeObserver];
	}
}

- (void)cloudStoreDidImport {
	if (self.editingObject) return;

	NSString *currencyCode = [[A3SyncManager sharedSyncManager] objectForKey:A3ExpenseListUserDefaultsCurrencyCode];
	[self.currencyFormatter setCurrencyCode:currencyCode];

	[self reloadBudgetDataWithAnimation:YES saveData:NO];
	[self enableControls:_barButtonEnabled];
}

- (void)removeObserver {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationCloudCoreDataStoreDidImport object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationCloudKeyValueStoreDidImport object:nil];
	[self removeContentSizeCategoryDidChangeNotification];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationExpenseListCurrencyCodeChanged object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];

	if (IS_IPAD) {
		[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationMainMenuDidHide object:nil];
		[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationRightSideViewDidAppear object:nil];
		[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationRightSideViewWillDismiss object:nil];
	}
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)prepareClose {
	self.tableView.delegate = nil;
	self.tableView.dataSource = nil;
	[self removeObserver];
}

- (void)dealloc {
	[self removeObserver];
}

- (void)cleanUp {
	[self dismissInstructionViewController:nil];
	[self removeObserver];
}

- (BOOL)resignFirstResponder {
	[self dismissNumberKeyboardWithAnimation:NO completion:NULL];
	
	NSString *startingAppName = [[A3UserDefaults standardUserDefaults] objectForKey:kA3AppsStartingAppName];
	if ([startingAppName length] && ![startingAppName isEqualToString:A3AppName_ExpenseList]) {
		[self dismissMoreMenuView:_moreMenuView pullDownView:nil completion:^{
		}];
		[self.instructionViewController.view removeFromSuperview];
		self.instructionViewController = nil;
	}
	return [super resignFirstResponder];
}

- (void)mainMenuDidHide {
	[self enableControls:YES];
}

- (void)rightSideViewDidAppear {
	[self dismissNumberKeyboardWithAnimation:YES completion:NULL];
	[self enableControls:NO];
}

- (void)rightSideViewWillDismiss {
	[self enableControls:YES];
}

- (void)enableControls:(BOOL)enable {
	_barButtonEnabled = enable;
	[self.navigationItem.leftBarButtonItem setEnabled:enable];
	if (enable) {
		[self.navigationItem.rightBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem *barButtonItem, NSUInteger idx, BOOL *stop) {
			switch (barButtonItem.tag) {
				case A3RightBarButtonTagComposeButton:{
					NSPredicate *predicate = [NSPredicate predicateWithFormat:@"budgetID == %@ and hasData == YES", _currentBudget.uniqueID];
					[barButtonItem setEnabled:[ExpenseListItem countOfEntitiesWithPredicate:predicate] > 0];
					break;
				}
				case A3RightBarButtonTagHistoryButton:
					[barButtonItem setEnabled:[ExpenseListHistory countOfEntities] > 0];
					break;
				case A3RightBarButtonTagShareButton:
					[barButtonItem setEnabled:_currentBudget.category != nil];
					break;
                default:
                    [barButtonItem setEnabled:YES];
                    break;
			}
		}];
	} else {
		[self.navigationItem.rightBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem *barButtonItem, NSUInteger idx, BOOL *stop) {
			[barButtonItem setEnabled:NO];
		}];
	}
	[_headerView.detailInfoButton setEnabled:enable];
}

- (NSNumberFormatter *)decimalFormatter {
	if (!_decimalFormatter) {
		_decimalFormatter = [NSNumberFormatter new];
		[_decimalFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
		[_decimalFormatter setMaximumFractionDigits:3];
	}
	return _decimalFormatter;
}

- (void)currencyCodeChanged:(NSNotification *)notification {
	NSString *currencyCode = [[A3SyncManager sharedSyncManager] objectForKey:A3ExpenseListUserDefaultsCurrencyCode];
	[self.currencyFormatter setCurrencyCode:currencyCode];
    
	_headerView.currencyFormatter = self.currencyFormatter;
	[self reloadBudgetDataWithAnimation:NO saveData:NO ];
}

-(void)setupTopWhitePaddingView
{
    FNLOGRECT(self.view.frame);
    _topWhitePaddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.0)];
    _topWhitePaddingView.backgroundColor = [UIColor colorWithRed:239.0/255.0 green:239.0/255.0 blue:244.0/255.0 alpha:1.0];
    _topWhitePaddingView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.tableView addSubview:_topWhitePaddingView];
}

-(void)contentSizeDidChange:(NSNotification *)notification {
    [self reloadBudgetDataWithAnimation:NO saveData:NO ];
}

- (void)drawCellSeparatorLineView
{
    CGFloat leftInset = IS_IPHONE ? 15 : 28;
    CGFloat sep1XPos = (ceilf(CGRectGetWidth(self.view.frame) * 0.33));
    CGFloat sep2XPos = (ceilf(CGRectGetWidth(self.view.frame) * 0.26));
    CGFloat sep3XPos = (ceilf(CGRectGetWidth(self.view.frame) * 0.11));
    
    CGRect rect = _sep1View.frame;
    rect.origin.x = leftInset + sep1XPos;
    rect.origin.y = self.tableView.contentSize.height;//0.0;
    rect.size.width = IS_RETINA ? 0.5 : 1.0;
    rect.size.height = self.tableView.frame.size.height + self.tableView.contentSize.height;
    _sep1View.frame = rect;
    
    rect = _sep2View.frame;
    rect.origin.x = leftInset + sep1XPos + sep2XPos;
    rect.origin.y = self.tableView.contentSize.height;//0.0;
    rect.size.width = IS_RETINA ? 0.5 : 1.0;
    rect.size.height = self.tableView.frame.size.height + self.tableView.contentSize.height;
    _sep2View.frame = rect;
    

    rect = _sep3View.frame;
    rect.origin.x = leftInset + sep1XPos + sep2XPos + sep3XPos;
    rect.origin.y = self.tableView.contentSize.height;//0.0;
    rect.size.width = IS_RETINA ? 0.5 : 1.0;
    rect.size.height = self.tableView.frame.size.height + self.tableView.contentSize.height;
    _sep3View.frame = rect;
}

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    [self drawCellSeparatorLineView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(A3ExpenseListHeaderView *)headerView {
    if (!_headerView) {
        _headerView = [[A3ExpenseListHeaderView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, IS_IPAD? (IS_RETINA? 157.5 : 157.0) : (IS_RETINA? 103.5 : 103) )];
		_headerView.currencyFormatter = self.currencyFormatter;
        _headerView.decimalFormatter = self.decimalFormatter;
        [_headerView.detailInfoButton addTarget:self action:@selector(detailInfoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _headerView;
}

- (void)makeRightBarButtons
{
    UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"add06"]
                                                            style:UIBarButtonItemStylePlain
                                                           target:self
                                                           action:@selector(addNewButtonAction:)];
    add.tag = A3RightBarButtonTagComposeButton;
    
    UIBarButtonItem *history = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"history"]
                                                                style:UIBarButtonItemStylePlain
                                                               target:self
                                                               action:@selector(historyButtonAction:)];
    history.tag = A3RightBarButtonTagHistoryButton;

    self.navigationItem.rightBarButtonItems = @[history, add, [self instructionHelpBarButton]];
}

- (void)appsButtonAction:(UIBarButtonItem *)barButtonItem {
	[self dismissNumberKeyboardWithAnimation:NO completion:NULL];
	[self clearEverything];

	[super appsButtonAction:barButtonItem];
	if (IS_IPAD) {
		[self enableControls:![[A3AppDelegate instance] rootViewController_iPad].showLeftView];
	}
}

- (NSString *)defaultCurrencyCode {
	NSString *currencyCode = [[A3SyncManager sharedSyncManager] objectForKey:A3ExpenseListUserDefaultsCurrencyCode];
	if (!currencyCode) {
		currencyCode = [A3UIDevice systemCurrencyCode];
	}
	return currencyCode;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];

	if (IS_IPHONE && [UIWindow interfaceOrientationIsLandscape]) {
		[self leftBarButtonAppsButton];
	}
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
	
	if (self.numberKeyboardViewController.view.superview) {
		UIView *keyboardView = self.numberKeyboardViewController.view;
		CGFloat keyboardHeight = self.numberKeyboardViewController.keyboardHeight;
		
		FNLOGRECT(self.view.bounds);
		FNLOG(@"%f", keyboardHeight);
		keyboardView.frame = CGRectMake(0, self.view.bounds.size.height - keyboardHeight, self.view.bounds.size.width, keyboardHeight);
		[self.numberKeyboardViewController rotateToInterfaceOrientation:toInterfaceOrientation];

		if (_accessoryForNumberField) {
			_accessoryForNumberField.frame = CGRectMake(0, keyboardView.frame.origin.y - 45.0, self.view.bounds.size.width, 45);
		}
		
		UIEdgeInsets contentInset = self.tableView.contentInset;
		contentInset.bottom = keyboardHeight + _accessoryForNumberField.frame.size.height;
		self.tableView.contentInset = contentInset;
		
		[self.tableView scrollToRowAtIndexPath:_editingIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
	}
}

#pragma mark Instruction Related

static NSString *const A3V3InstructionDidShowForExpenseList = @"A3V3InstructionDidShowForExpenseList";

- (void)setupInstructionView
{
    if (![[A3UserDefaults standardUserDefaults] boolForKey:A3V3InstructionDidShowForExpenseList]) {
        if (IS_IPHONE) {
            [self moreButtonAction:nil];
        }
        [self showInstructionView];
    }
}

- (void)showInstructionView
{
	[self dismissNumberKeyboardWithAnimation:YES completion:NULL];
	[[A3UserDefaults standardUserDefaults] setBool:YES forKey:A3V3InstructionDidShowForExpenseList];
	[[A3UserDefaults standardUserDefaults] synchronize];

    UIStoryboard *instructionStoryBoard = [UIStoryboard storyboardWithName:IS_IPHONE ? A3StoryboardInstruction_iPhone : A3StoryboardInstruction_iPad bundle:nil];
    _instructionViewController = [instructionStoryBoard instantiateViewControllerWithIdentifier:@"ExpenseList"];
    self.instructionViewController.delegate = self;
    [self.navigationController.view addSubview:self.instructionViewController.view];
    self.instructionViewController.view.frame = self.navigationController.view.frame;
    self.instructionViewController.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight;
    if (IS_IPHONE) {
        CGPoint contentOffset = self.tableView.contentOffset;
        contentOffset.y = -self.tableView.contentInset.top;
        [self.tableView setContentOffset:contentOffset animated:YES];
    }
}

- (void)dismissInstructionViewController:(UIView *)view
{
    [self.instructionViewController.view removeFromSuperview];
    if ([self.instructionViewController isFirstInstruction]) {
        [self dismissMoreMenu];
    }
    self.instructionViewController = nil;
}

#pragma mark - UINavigationController Delegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
}

-(void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (!animated) {
        return;
    }
    
    if ([viewController isKindOfClass:[A3ExpenseListAddBudgetViewController class]]) {
        navigationController.delegate = nil;
        [((A3ExpenseListAddBudgetViewController *)viewController) showKeyboard];
    }
}

#pragma mark - Actions

- (void)detailInfoButtonAction:(UIButton *)button
{
	[self dismissNumberKeyboardWithAnimation:YES completion:NULL];

    if (![self navigationController] || ![[self navigationController] viewControllers] || [[[self navigationController] viewControllers] count] == 0) {
        return;
    }
    if (_isAutoMovingAddBudgetView) {
        return;
    }
    
    [self moveToAddBudgetViewController];
}

- (void)doneButtonAction:(id)button {
	[self clearEverything];
}

- (void)addItemWithFocus:(BOOL)focus
{
    ExpenseListItem *item = [self createExpenseListItemWithBudgetID:_currentBudget.uniqueID];
	item.budgetID = _currentBudget.uniqueID;
    item.itemDate = [NSDate date];
    item.itemName = @"";
    item.price = @0;
    item.qty = @1;
	item.order = [item makeOrderString];
    item.hasData = @(YES);

    NSManagedObjectContext *context = A3SyncManager.sharedSyncManager.persistentContainer.viewContext;
    [context saveIfNeeded];

	NSInteger focusingRow = [_currentBudget expenseItemsCount] - 1;

    _tableDataSourceArray = [self loadBudgetFromDB];
	[self.tableView reloadData];

    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        if (focus) {
            A3ExpenseListItemCell *cell = (A3ExpenseListItemCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:focusingRow inSection:0]];
            cell.nameField.userInteractionEnabled = YES;
            [cell.nameField becomeFirstResponder];
        }
    }];
    [CATransaction commit];
}

- (void)clearEverything {
	[self dismissMoreMenu];
	[self.editingObject resignFirstResponder];
	[self setEditingObject:nil];
    [self.tableView setEditing:NO animated:YES];
}

- (void)dismissMoreMenu {
	if ( !_isShowMoreMenu || IS_IPAD ) return;

    UITapGestureRecognizer *lastTapGesture = [[self. view gestureRecognizers] lastObject];
    if (_tapGestureRecognizer != lastTapGesture) {
        [self moreMenuDismissAction:lastTapGesture];
        _isShowMoreMenu = NO;
    }
}

- (void)moreMenuDismissAction:(UITapGestureRecognizer *)gestureRecognizer {
    FNLOGINSETS(self.tableView.contentInset);
	[self rightButtonMoreButton];
	[self dismissMoreMenuView:_moreMenuView pullDownView:self.tableView completion:^{
	}];
	[self.view removeGestureRecognizer:gestureRecognizer];
    
    if SYSTEM_VERSION_LESS_THAN(@"11") {
        UIEdgeInsets inset = self.tableView.contentInset;
        inset.top = 64;
        self.tableView.contentInset = inset;
    }
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
	// Popover controller, iPad only.

	[self enableControls:YES];
	_sharePopoverController = nil;
}

- (void)didTapOnTableView:(UIGestureRecognizer *)recognizer {
    CGPoint tapLocation = [recognizer locationInView:self.tableView];
	if (tapLocation.y < _tableCellStartY) {
		return;
	}
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:tapLocation];
	FNLOG(@"%ld", (long)indexPath.row);
    
    if (indexPath) {
        FNLOG(@"%@", NSStringFromCGPoint(tapLocation));
        
        A3ExpenseListItemCell *aCell = (A3ExpenseListItemCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        
        if (tapLocation.x < _sep1View.frame.origin.x) {
            aCell.nameField.userInteractionEnabled = YES;
            [aCell.nameField becomeFirstResponder];
        }
        else if ( tapLocation.x > _sep1View.frame.origin.x && tapLocation.x < _sep2View.frame.origin.x) {
            aCell.priceField.userInteractionEnabled = YES;
            [aCell.priceField becomeFirstResponder];
        }
        else if ( tapLocation.x > _sep2View.frame.origin.x && tapLocation.x < _sep3View.frame.origin.x) {
            aCell.quantityField.userInteractionEnabled = YES;
            [aCell.quantityField becomeFirstResponder];
        }
    } else {
        [self addItemWithFocus:YES];
    }
}

#pragma mark BarButton Actions
- (UIButton *)addNewButton {
	UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
	[button setImage:[UIImage imageNamed:@"add06"] forState:UIControlStateNormal];
	[button addTarget:self action:@selector(addNewButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	return button;
}

- (void)addNewButtonAction:(id)sender
{
	[self dismissNumberKeyboardWithAnimation:YES completion:NULL];
    [self clearEverything];

    // 현재 상태 저장.
    if ([_currentBudget.isModified boolValue]) {
        [self saveCurrentBudgetToHistory];
    }

	[[A3SyncManager sharedSyncManager] setBool:NO forKey:A3ExpenseListIsAddBudgetCanceledByUser state:A3DataObjectStateModified];

	// 초기화.
    [self clearCurrentBudget];
    _tableDataSourceArray = nil;
    [self reloadBudgetDataWithAnimation:YES saveData:YES ];
    [self moveToAddBudgetIfBudgetNotExistWithDelay:1.0];
}

- (void)clearCurrentBudget {
    NSManagedObjectContext *context = A3SyncManager.sharedSyncManager.persistentContainer.viewContext;
    for (ExpenseListItem * item in [_currentBudget expenseItems]) {
        [context deleteObject:item];
    }
    
    [context deleteObject:_currentBudget];
    
    _currentBudget = nil;
    
    [context saveIfNeeded];
}

- (void)historyButtonAction:(id)sender
{
	[self dismissNumberKeyboardWithAnimation:YES completion:NULL];
    [self clearEverything];
    
    if (_isAutoMovingAddBudgetView) {
        return;
    }
    
    if (IS_IPAD) {
		[self enableControls:NO];
        _sharePopoverController.delegate = self;
        _headerView.detailInfoButton.enabled = NO;
    }
    
    A3ExpenseListHistoryViewController *viewController = [[A3ExpenseListHistoryViewController alloc] initWithStyle:UITableViewStylePlain];
    viewController.delegate = self;

	if (IS_IPHONE) {
		_modalNavigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
		[self presentViewController:_modalNavigationController animated:YES completion:NULL];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(expenseHistoryViewControllerDidDismiss) name:A3NotificationChildViewControllerDidDismiss object:viewController];
	} else {
		[[[A3AppDelegate instance] rootViewController_iPad] presentRightSideViewController:viewController toViewController:nil];
	}
}

- (void)expenseHistoryViewControllerDidDismiss {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationChildViewControllerDidDismiss object:_modalNavigationController.childViewControllers[0]];
	_modalNavigationController = nil;
}

- (void)shareButtonAction:(id)sender {
	[self dismissNumberKeyboardWithAnimation:YES completion:NULL];
	[self clearEverything];

	if (_isAutoMovingAddBudgetView) {
		return;
	}

	_sharePopoverController =
			[self presentActivityViewControllerWithActivityItems:@[@"test"]
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

- (void)moveToAddBudgetViewController {
    [self clearEverything];
    [self removeNumberKeyboardNotificationObservers];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
    _isAutoMovingAddBudgetView = NO;
    
    A3ExpenseListAddBudgetViewController *viewController = [[A3ExpenseListAddBudgetViewController alloc] initWithStyle:UITableViewStyleGrouped
                                                                                                 withExpenseListBudget:_currentBudget];
    viewController.delegate = self;
    
    if ( IS_IPHONE ) {
        UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:viewController];
        [self presentViewController:navCtrl animated:YES completion:^{
            [viewController showKeyboard];
        }];
    }
    else {
		A3RootViewController_iPad *rootViewController = [[A3AppDelegate instance] rootViewController_iPad];
        [rootViewController presentCenterViewController:[[A3NavigationController alloc] initWithRootViewController:viewController] fromViewController:self withCompletion:^{
            [viewController showKeyboard];
        }];
    }
}

- (void)moreButtonAction:(UIButton *)button
{
	[self dismissNumberKeyboardWithAnimation:YES completion:NULL];
	[self.editingObject resignFirstResponder];

	if (_isAutoMovingAddBudgetView) {
		return;
	}

	[self rightBarButtonDoneButton];
	
	_isShowMoreMenu = YES;
    UIButton *help = self.instructionHelpButton;
//    UIButton *share = self.shareButton;
    UIButton *addNew = self.addNewButton;
    UIButton *history = [self historyButton:NULL];
    
	_moreMenuButtons = @[help, /*share, */addNew, history];
	// AddNew
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"budgetID == %@ and hasData == YES", _currentBudget.uniqueID];
    addNew.enabled = [ExpenseListItem countOfEntitiesWithPredicate:predicate] > 0;
	// History
    history.enabled = [ExpenseListHistory countOfEntities] > 0;
	// Share
//    share.enabled = _currentBudget.category != nil;

	_moreMenuView = [self presentMoreMenuWithButtons:_moreMenuButtons pullDownView:self.tableView];
}

- (void)addItemButtonAction:(id)sender
{
    _currentBudget.updateDate = [NSDate date];

	[self createExpenseListItemWithBudgetID:_currentBudget.uniqueID];

    NSManagedObjectContext *context = A3SyncManager.sharedSyncManager.persistentContainer.viewContext;
    [context saveIfNeeded];

    _currentBudget = [ExpenseListBudget findFirstByAttribute:@"uniqueID" withValue:A3ExpenseListCurrentBudgetID];
    _tableDataSourceArray = [self loadBudgetFromDB];
    
    [self.tableView reloadData];
    [self setAddItemButtonPosition];
}

#pragma mark - Data Manipulate

- (void)validateEmptyItem:(ExpenseListItem *)item andAutoInsertCellBelow:(A3ExpenseListItemCell *)aCell
{
    // item 유효성 체크.
    //if ( _selectedItem != item && (item.itemName.length==0 && [item.price isEqualToNumber:@0] && [item.qty isEqualToNumber:@1]) ) {
    if ( item.itemName.length==0 && (!item.price || [item.price isEqualToNumber:@0]) && (!item.qty || [item.qty isEqualToNumber:@1]) ) {
        // 입력 포커스 후, 아무 입력도 없었던 경우.
        item.itemDate = [NSDate date];
        item.itemName = @"";
        item.price = @0;
        item.qty = @1;
        aCell.nameField.text = @"";
        aCell.priceField.text = [self.currencyFormatter stringFromNumber:@0];
        aCell.quantityField.text = @"1";
        aCell.subTotalLabel.text = [self.currencyFormatter stringFromNumber:@0];
        aCell.priceField.placeholder = @"";
        aCell.quantityField.placeholder = @"";
    }
    else {
        // 입력 포커스 후
        // price * qty 계산
        item.subTotal = @(item.price.doubleValue * item.qty.doubleValue);
        aCell.subTotalLabel.text = [self.currencyFormatter stringFromNumber:item.subTotal];
        
        
        // 자동 다음 행 추가.
        NSIndexPath * indexPath = [self.tableView indexPathForCell:aCell];
        
        
        // 상단에 빈 행이 있는 경우에는 자동추가하지 않음.
        for (int i=0; i < indexPath.row; i++) {
            ExpenseListItem *aItem = [_tableDataSourceArray objectAtIndex:i];
            if (aItem.itemDate == nil || ![aItem.hasData boolValue]) {
                return;
            }
        }
        
        if (indexPath.row == _tableDataSourceArray.count-1 && (item.itemName.length!=0 || [item.price isEqualToNumber:@0]==NO || [item.qty isEqualToNumber:@1]==NO)) {
            // 마지막 행인 경우, 자동으로 행 추가.
            [self addItemWithFocus:NO];
            
        }
        else if (indexPath.row < (_tableDataSourceArray.count-1) ) {
            // 다음 행, 아이템 추가 가능 체크.
            if (item.itemName.length==0 && [item.price isEqualToNumber:@0] && [item.qty isEqualToNumber:@1]) {
                return;
            }
            
            // 다음 행에 아이템 추가 (초기값).
            NSIndexPath * indexPath = [self.tableView indexPathForCell:aCell];
            ExpenseListItem * nextItem = [_tableDataSourceArray objectAtIndex:indexPath.row+1];
            if (!nextItem.itemDate || ![nextItem.hasData boolValue]) {
                A3ExpenseListItemCell * nextCell = (A3ExpenseListItemCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row+1 inSection:0]];
                
                nextItem.itemDate = [NSDate date];
                nextItem.price = @0;
                nextItem.qty = @1;
                nextItem.subTotal = @0;
                
                nextCell.priceField.text = [self.currencyFormatter stringFromNumber:nextItem.price];
                NSNumberFormatter *formatter = [NSNumberFormatter new];
                [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
                nextCell.quantityField.text = [formatter stringFromNumber:nextItem.qty];
                nextCell.subTotalLabel.text = [self.currencyFormatter stringFromNumber:@(nextItem.price.doubleValue * nextItem.qty.doubleValue)];
            }
        }
    }
}

- (NSMutableArray *)loadBudgetFromDB
{
    return [NSMutableArray arrayWithArray:[_currentBudget expenseItems]];
}

- (void)setAddItemButtonPosition
{
    CGRect rect = _addItemButton.frame;
    if (IS_IPHONE) {
        rect.origin.x = 1.0;
    }
    else {
        rect.origin.x = 14;
    }
    rect.origin.y = self.tableView.contentSize.height;
    rect.size.width = 44.0;
    rect.size.height = 44.0;
    _addItemButton.frame = rect;
}

- (void)expandContentSizeForAddItem
{
    UIEdgeInsets contentInset = self.tableView.contentInset;
    FNLOG(@"bottom : %f", contentInset.bottom);
    contentInset.bottom = contentInset.bottom + 44.0;
    self.tableView.contentInset = contentInset;
}

- (void)calculateAndDisplayResultWithAnimation:(BOOL)animation saveData:(BOOL)saveData {
    // 전체 사용금액 계산.
    double usedBudget = 0.0;
    for (ExpenseListItem *item in _tableDataSourceArray) {
        usedBudget += item.price.doubleValue * item.qty.doubleValue;
    }
    _currentBudget.usedAmount = @(usedBudget);
    
    // 헤더뷰 결과 반영.
    [self.headerView setResult:_currentBudget withAnimation:animation];
    // 현재 상태 저장.
	if (saveData) {
        NSManagedObjectContext *context = A3SyncManager.sharedSyncManager.persistentContainer.viewContext;
        [context saveIfNeeded];
	}
}

- (void)reloadBudgetDataWithAnimation:(BOOL)animation saveData:(BOOL)saveData {
    // 데이터 갱신.
    [self reloadBudgetDataCreateIfNotExist:saveData ];
    [self re_sort_DataSourceToSeparateValidAndEmpty];

    // 계산 & 화면 갱신.
    [self calculateAndDisplayResultWithAnimation:animation saveData:saveData ];
    [self.tableView reloadData];
	[self enableControls:YES];
}

- (void)reloadBudgetDataCreateIfNotExist:(BOOL)create {
    _currentBudget = [ExpenseListBudget findFirstByAttribute:@"uniqueID" withValue:A3ExpenseListCurrentBudgetID];

	if (!_currentBudget && create) {
		// 주제: 특별한 ID 할당이 필요
		// 배경:
		// Current Budget 은 iCloud 동기화를 사용하는 경우, 복수의 장비에서 수정 사항이 발생
		// iPhone 에서 수정한 내용이 iPad 에서 바로 반영이 되어야 하고, 별도의 budget 이 아닌
		// 같은 ExpenseListBudget 과 ExpenseListItem 이 편집의 대상이 됨
		// 한 장비에서 UUID 를 생성하고 오프라인 상태에 있던 다른 장비에서 UUID 를 또 생성한 경우,
		// 두 개의 서로다른 ID 가 발생하여 동기화를 할 방법이 없는 문제가 생김
		// History 상태에서는 수정사항이 발생하지 않으므로 History 로 넘길때 고유 ID 를 만들어 부여 함
		// 이는 ExpenseListBudget 뿐만 아니라 ExpenseListItem 도 동일함
		// 이를 지원하는 방법: Current ExpenseBudget 의 uniqueID 는 항상 A3ExpenseListCurrentBudgetID
		// ExpenseListItem 의 uniqueID 는 A3ExpenseListCurrentBudgetID + 순차 번호

		// iPhone 과 iPad 에서 동시에 데이터를 보여주어야 하는데, 동기화 정보가 장비를 넘어갈 때 마다 데이터를 지우고 만들고 하면,
		// 무한 반복 상황이 발생함. iPad 에서 18개를 만들고, iPhone 에서 받아서 데이터 없는 것을 지우고, 수정 사항이 생겼으므로,
		// iPad 와서 다시 9개를 만들면, 수정 사항이 다시 iPhone 으로 전달되어 또 지우고, 만들고, 지우고 ....
		// 결론: 최초 18개를 무조건 만들고 그 상태를 유지하기로 함
		int defaultCount = kDefaultItemCount_iPad;

        NSManagedObjectContext *context = A3SyncManager.sharedSyncManager.persistentContainer.viewContext;
        _currentBudget = [[ExpenseListBudget alloc] initWithContext:context];
		_currentBudget.uniqueID = A3ExpenseListCurrentBudgetID;
		_currentBudget.updateDate = [NSDate date];
        _currentBudget.isModified = @(NO);

		for (NSInteger idx = 0; idx < defaultCount; idx++) {
            ExpenseListItem *item = [[ExpenseListItem alloc] initWithContext:context];
			item.uniqueID = [self itemIDWithIndex:idx];
			item.updateDate = [NSDate date];
			item.budgetID = _currentBudget.uniqueID;
			item.order = [item makeOrderString];
			if (idx == 0) {
				item.itemDate = [NSDate date];
				item.itemName = @"";
				item.price = @0;

				item.qty = @1;
				item.subTotal = @0;
			}
		}

        [context saveIfNeeded];
	}
	_tableDataSourceArray = [self loadBudgetFromDB];
}

- (ExpenseListItem *)createExpenseListItemWithBudgetID:(NSString *)budgetID {
    NSManagedObjectContext *context = A3SyncManager.sharedSyncManager.persistentContainer.viewContext;
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"budgetID == %@", budgetID];
    ExpenseListItem *newItem = [[ExpenseListItem alloc] initWithContext:context];
	ExpenseListItem *lastItem = [ExpenseListItem findFirstWithPredicate:predicate sortedBy:@"uniqueID" ascending:NO];
	NSString *lastUniqueID = lastItem.uniqueID;
	NSInteger largestIndex = 0;
	if (lastUniqueID) {
		NSArray *components = [lastUniqueID componentsSeparatedByString:@"-"];
		if ([components count] >= 2) {
			largestIndex = [components[1] integerValue];
		}
	}
	newItem.uniqueID = [self itemIDWithIndex:largestIndex];
	newItem.updateDate = [NSDate date];
	newItem.order = [newItem makeOrderString];
	newItem.budgetID = budgetID;

	return newItem;
}

- (NSString *)itemIDWithIndex:(NSInteger)idx {
	return [NSString stringWithFormat:@"%@-%010ld", A3ExpenseListCurrentBudgetID, (long)idx];
}

#pragma mark Save Related

- (void)saveCurrentBudgetToHistory
{
	// 현재 예산에 새 ID 를 부여하고 history 로 전환
    _currentBudget.currencyCode = [self defaultCurrencyCode];

    NSManagedObjectContext *context = A3SyncManager.sharedSyncManager.persistentContainer.viewContext;
	ExpenseListBudget *budgetInHistory = (ExpenseListBudget *) [_currentBudget cloneInContext:context];
	budgetInHistory.uniqueID = [[NSUUID UUID] UUIDString];

    ExpenseListHistory * history = [[ExpenseListHistory alloc] initWithContext:context];
	history.uniqueID = [[NSUUID UUID] UUIDString];
	history.updateDate = [NSDate date];
	history.budgetID = budgetInHistory.uniqueID;

	for (ExpenseListItem *item in _tableDataSourceArray) {
		ExpenseListItem *itemInHistory = (ExpenseListItem *) [item cloneInContext:context];
		itemInHistory.uniqueID = [[NSUUID UUID] UUIDString];
		itemInHistory.budgetID = budgetInHistory.uniqueID;
	}

    [context saveIfNeeded];
}

#pragma mark - misc

- (void)moveToAddBudgetIfBudgetNotExistWithDelay:(CGFloat)delay {
    if (![[A3UserDefaults standardUserDefaults] boolForKey:A3V3InstructionDidShowForExpenseList]) {
        return;
    }
    
    if ([[A3SyncManager sharedSyncManager] boolForKey:A3ExpenseListIsAddBudgetCanceledByUser]) {
        return;
    }

    if ([[A3SyncManager sharedSyncManager] boolForKey:A3ExpenseListIsAddBudgetInitiatedOnce]) {
        return;
    }
    
    // 버젯이 없는 경우 이동한다.
    if (!_currentBudget || _currentBudget.category==nil ) {
		[[A3SyncManager sharedSyncManager] setBool:YES forKey:A3ExpenseListIsAddBudgetInitiatedOnce state:A3DataObjectStateModified];

        [self performSelector:@selector(moveToAddBudgetViewController) withObject:nil afterDelay:delay];
        _isAutoMovingAddBudgetView = YES;
    }
}

- (void)scrollToTopOfTableView {
	[UIView beginAnimations:A3AnimationIDKeyboardWillShow context:nil];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationCurve:7];
	[UIView setAnimationDuration:0.35];
	self.tableView.contentOffset = CGPointMake(0.0, -(self.navigationController.navigationBar.bounds.size.height + [A3UIDevice statusBarHeight] ) );
	[UIView commitAnimations];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	FNLOG(@"%ld", (long)[_tableDataSourceArray count]);
    return [_tableDataSourceArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    A3ExpenseListItemCell *cell = [tableView dequeueReusableCellWithIdentifier:ExpenseListMainCellIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[A3ExpenseListItemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ExpenseListMainCellIdentifier];
    }
	[self setupCell:cell atIndexPath:indexPath];
	FNLOG();

    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row == 0) {
		_tableCellStartY = cell.frame.origin.y;
	}
}

- (UITableViewCell *)cellIdenticalToCellAtIndexPath:(NSIndexPath *)indexPath forDragTableViewController:(ATSDragToReorderTableViewController *)dragTableViewController {
	A3ExpenseListItemCell *cell = [[A3ExpenseListItemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ExpenseListMainCellIdentifier];
	[self setupCell:cell atIndexPath:indexPath];

	return cell;
}

- (void)setupCell:(A3ExpenseListItemCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	ExpenseListItem *item = [_tableDataSourceArray objectAtIndex:indexPath.row];
	cell.delegate = self;

//    cell.nameField.userInteractionEnabled = YES;
//    cell.priceField.userInteractionEnabled = YES;
//    cell.quantityField.userInteractionEnabled = YES;
	
	if ([item.hasData boolValue] || indexPath.row == 0) {    // kjh 추후에 변경하도록
		cell.nameField.text = item.itemName;
		cell.priceField.text = [self.currencyFormatter stringFromNumber:item.price];
		cell.quantityField.text = item.qty.stringValue;
		cell.subTotalLabel.text = [self.currencyFormatter stringFromNumber:@(item.price.doubleValue * item.qty.doubleValue)];
	} else {
		cell.nameField.text = @"";
		cell.priceField.text = @"";
		cell.quantityField.text = @"";
		cell.subTotalLabel.text = @"";
		cell.nameField.placeholder = @"";
		cell.priceField.placeholder = @"";
		cell.quantityField.placeholder = @"";
	}
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    [_columnSectionView setNeedsDisplay];
    _addItemButton.userInteractionEnabled = _currentBudget == nil ? NO : YES;
    
    return _columnSectionView;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	ExpenseListItem *item = [_tableDataSourceArray objectAtIndex:indexPath.row];
	//if (item.itemDate == nil || ![item.hasData boolValue]) {
    if (![item.hasData boolValue]) {
		return NO;
	}

    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    int defaultItemCount = 1;
    
    if (IS_IPHONE) {
        defaultItemCount = kDefaultItemCount_iPhone;
    } else {
        defaultItemCount = kDefaultItemCount_iPad;
    }
    
    _selectedItem = nil;

    NSManagedObjectContext *context = A3SyncManager.sharedSyncManager.persistentContainer.viewContext;
    if (_tableDataSourceArray.count > defaultItemCount) {
        ExpenseListItem *aItem = _tableDataSourceArray[indexPath.row];
        [context deleteObject:aItem];

        [self reloadBudgetDataWithAnimation:YES saveData:NO ];
    }
    else {
        ExpenseListItem *aItem = _tableDataSourceArray[indexPath.row];
        aItem.itemDate = nil;
        aItem.itemName = nil;
        aItem.price = nil;
        aItem.qty = nil;
        aItem.subTotal = nil;
        aItem.hasData = @(NO);
        
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
            ExpenseListItem * aItem = (ExpenseListItem *)evaluatedObject;
            return ([aItem.hasData boolValue] && (aItem.itemName.length>0 || aItem.price || [aItem.qty compare:@1] == NSOrderedDescending));
        }];
        
        NSArray * filtered = [_tableDataSourceArray filteredArrayUsingPredicate:predicate];
        if (filtered.count==0) {
            ExpenseListItem *aItem = [_tableDataSourceArray objectAtIndex:0];
            aItem.itemName = @"";
            aItem.itemDate = [NSDate date];
            aItem.price = @0;
            aItem.qty = @1;
            aItem.hasData = @(NO);
        }
        
        [self reloadBudgetDataWithAnimation:YES saveData:NO ];
    }
    
    [context saveIfNeeded];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return IS_RETINA ? 56.0 : 57.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return indexPath.row == 0 ? (IS_RETINA ? 43.5 : 43) : 44.0;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
	FNLOG();
	[_tableDataSourceArray moveItemInSortedArrayFromIndex:sourceIndexPath.row toIndex:destinationIndexPath.row];
}

- (void)re_sort_DataSourceToSeparateValidAndEmpty {
    NSArray *hasDataArray = [_tableDataSourceArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"hasData == %@", @(YES)]];
    hasDataArray = [hasDataArray sortedArrayUsingComparator:^NSComparisonResult(ExpenseListItem * obj1, ExpenseListItem * obj2) {
        return [obj1.order integerValue] > [obj2.order integerValue];
    }];
    [hasDataArray enumerateObjectsUsingBlock:^(ExpenseListItem * obj, NSUInteger idx, BOOL *stop) {
        obj.order = [NSString orderStringWithOrder:idx + 1000000];
    }];

    NSArray *emptyDataArray = [_tableDataSourceArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"hasData == %@ || hasData == nil", @(NO)]];
    [emptyDataArray enumerateObjectsUsingBlock:^(ExpenseListItem * obj, NSUInteger idx, BOOL *stop) {
        obj.order = [NSString orderStringWithOrder:([hasDataArray count] + idx) + 1000000];
    }];
    
    [_tableDataSourceArray removeAllObjects];
    [_tableDataSourceArray addObjectsFromArray:hasDataArray];
    [_tableDataSourceArray addObjectsFromArray:emptyDataArray];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

	if (_topWhitePaddingView) {
		if (scrollView.contentOffset.y < -scrollView.contentInset.top ) {
			CGRect rect = _topWhitePaddingView.frame;
			rect.origin.y = -(fabs(scrollView.contentOffset.y) - scrollView.contentInset.top);
			rect.size.height = fabs(scrollView.contentOffset.y) - scrollView.contentInset.top;
			_topWhitePaddingView.frame = rect;
		} else {
			CGRect rect = _topWhitePaddingView.frame;
			rect.origin.y = 0.0;
			rect.size.height = 0.0;
			_topWhitePaddingView.frame = rect;
		}
	}
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	[self dismissNumberKeyboardWithAnimation:YES completion:NULL];
}

#pragma mark ATSDragToReorderTableViewController Delegate

- (BOOL)dragTableViewController:(ATSDragToReorderTableViewController *)dragTableViewController shouldHideDraggableIndicatorForDraggingToRow:(NSIndexPath *)destinationIndexPath {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self re_sort_DataSourceToSeparateValidAndEmpty];
        [self.tableView reloadData];

        NSManagedObjectContext *context = A3SyncManager.sharedSyncManager.persistentContainer.viewContext;
        [context saveIfNeeded];
    });
	return NO;
}

#pragma mark - BudgetSetting Delegate

- (void)setExpenseBudgetDataFor:(ExpenseListBudget *)aBudget
{
    _currentBudget = aBudget;
    
    [self reloadBudgetDataWithAnimation:YES saveData:NO ];
}

#pragma mark History Delegate

- (BOOL)isAddedBudget:(ExpenseListBudget *)aBudget{
    if (aBudget.category) {
        return YES;
    }
    
    return NO;
}

-(void)didSelectBudgetHistory:(ExpenseListBudget *)aBudget
{
    // 현재 화면의 데이터 저장, 입력된 데이터가 없는 경우는 제외.
    // - 새로 추가되어 편집중이던 예산
    // - 히스토리로부터 복원되어 수정된 적이 있는 예산
    // 위의 경우에만 저장이 되도록 한다.
	NSArray *expenseItemsHasData = [_currentBudget expenseItemsHasData];
    if ([expenseItemsHasData count] > 0 || [self isAddedBudget:_currentBudget]) {
        // 편집중이던 데이터는 히스토리에 저장.
        if ([_currentBudget.isModified boolValue]) {
            [self saveCurrentBudgetToHistory];
        }
    }
    
    [self clearCurrentBudget];

    // 선택된 히스토리 버젯으로 복원.
    NSManagedObjectContext *context = A3SyncManager.sharedSyncManager.persistentContainer.viewContext;
    NSDate *updateDate = [NSDate date];
    
	_currentBudget = (ExpenseListBudget *) [aBudget cloneInContext:context];
    _currentBudget.uniqueID = A3ExpenseListCurrentBudgetID;
	_currentBudget.updateDate = updateDate;
    _currentBudget.isModified = @(NO);

	[[A3SyncManager sharedSyncManager] setObject:aBudget.currencyCode forKey:A3ExpenseListUserDefaultsCurrencyCode state:A3DataObjectStateModified];

    self.currencyFormatter.currencyCode = [self defaultCurrencyCode];
	_headerView.currencyFormatter = self.currencyFormatter;

	[[aBudget expenseItems] enumerateObjectsUsingBlock:^(ExpenseListItem *item, NSUInteger idx, BOOL *stop) {
		ExpenseListItem *newCurrentItem = (ExpenseListItem *) [item cloneInContext:context];
		newCurrentItem.uniqueID = [self itemIDWithIndex:idx];
        FNLOG(@"uniqueID : %@", newCurrentItem.uniqueID);
		newCurrentItem.budgetID = _currentBudget.uniqueID;
	}];

    [context saveIfNeeded];

    _tableDataSourceArray = [self loadBudgetFromDB];

	[self calculateAndDisplayResultWithAnimation:YES saveData:YES ];
	[self.tableView reloadData];
	[self enableControls:YES];
}

-(void)didDismissExpenseHistoryViewController {
	[self enableControls:YES];
}

#pragma mark - A3ExpenseListItemCell Delegate

- (BOOL)cell:(A3ExpenseListItemCell *)cell textFieldShouldBeginEditing:(UITextField *)textField {
	FNLOG();
	[self dismissMoreMenu];
	[self.tableView setEditing:NO animated:YES];
	
	if (textField == cell.nameField) {
		if (_isNumberKeyboardVisible) {
			_isSwitchingTextField = YES;
			[self dismissNumberKeyboardWithAnimation:NO completion:^{
				[textField becomeFirstResponder];
			}];
			return NO;
		}
		if (_editingTextField && (_editingTextField == _editingCell.nameField)) {
			_isSwitchingTextField = YES;
		}
		return YES;
	} else {
		if (_editingTextField && _editingTextField == _editingCell.nameField) {
            if (textField == cell.priceField || textField == cell.quantityField) {
                _isSwitchingTextField = YES;
                self.nextEditingCell = cell;
                self.nextEditingTextField = textField;
            }
			[_editingTextField resignFirstResponder];
            return YES;
		}
		if (_isNumberKeyboardVisible) {
			if (_editingTextField && _editingTextField != textField) {
				// textFieldDidEndEditing은 _isSwitchingTextField 플랙을 끈다.
				_isSwitchingTextField = YES;
				[self cell:_editingCell textFieldDidEndEditing:_editingTextField];
				[self cell:cell textFieldDidBeginEditing:textField];
			}
		} else {
			self.editingCell = cell;
			[self presentNumberKeyboardForTextField:textField];
		}
	}
	return NO;
}

- (void)cell:(A3ExpenseListItemCell *)cell textFieldDidBeginEditing:(UITextField *)textField
{
	FNLOG();
	
	self.editingCell = cell;
	self.editingObject = textField;
	self.editingTextField = textField;
	self.textBeforeEditingTextField = textField.text;
	self.editingIndexPath = [self.tableView indexPathForCell:cell];
	_didPressNumberKey = NO;
	_didPressClearKey = NO;
	FNLOG(@"%ld, %ld", (long)_editingIndexPath.section, (long)_editingIndexPath.row);

	if (textField == cell.nameField) {
		textField.returnKeyType = UIReturnKeyDefault;
		textField.inputAccessoryView = [self keyboardAccessoryView];
		[self.keyboardAccessoryView undoRedoButtonStateChangeFor:textField];
	}
	else if (textField == cell.priceField) {
		A3NumberKeyboardViewController *keyboardViewController = self.numberKeyboardViewController;

		keyboardViewController.textInputTarget = textField;
		keyboardViewController.delegate = self;
		keyboardViewController.currencyCode = self.defaultCurrencyCode;
		keyboardViewController.keyboardType = A3NumberKeyboardTypeCurrency;
		[keyboardViewController.clearButton setTitle:@"" forState:UIControlStateNormal];
		[keyboardViewController.clearButton setEnabled:NO];
	}
	else if (textField == cell.quantityField) {
		A3NumberKeyboardViewController *keyboardViewController = self.numberKeyboardViewController;

		keyboardViewController.textInputTarget = textField;
		keyboardViewController.delegate = self;
		keyboardViewController.keyboardType = A3NumberKeyboardTypeInteger;
		[keyboardViewController.clearButton setTitle:@"" forState:UIControlStateNormal];
		[keyboardViewController.clearButton setEnabled:NO];
	}

	if (cell.nameField != textField) {
		self.textColorBeforeEditing = textField.textColor;

		textField.placeholder = @"";
		textField.text = [self.decimalFormatter stringFromNumber:@0];
        FNLOG(@"%@", textField.text);
        textField.textColor = [[A3UserDefaults standardUserDefaults] themeColor];

		UITextField *quantityField = cell.quantityField;
		if (quantityField == textField) {
			quantityField.textAlignment = [quantityField.text length] == 0 ? NSTextAlignmentRight : NSTextAlignmentCenter;
		}
	}

	[self.keyboardAccessoryView undoRedoButtonStateChangeFor:textField];
	[self.accessoryForNumberField undoRedoButtonStateChangeFor:textField];
	[self showEraseButtonIfNeeded];
	[self changeDirectionButtonStateFor:textField];

    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    ExpenseListItem *item = [_tableDataSourceArray objectAtIndex:indexPath.row];
    if (![item.hasData boolValue] && _selectedItem != item) {
        item.itemDate = [NSDate date];
        item.price = @0;
        item.qty = @1;
        item.subTotal = @0;

		if (_editingTextField != cell.priceField) {
			cell.priceField.text = [self.currencyFormatter stringFromNumber:item.price];
		}
		if (_editingTextField != cell.quantityField) {
			cell.quantityField.text = item.qty.stringValue;
		}
        cell.subTotalLabel.text = [self.currencyFormatter stringFromNumber:@(item.price.doubleValue * item.qty.doubleValue)];
    }
    
    _selectedItem = item;
}

- (void)cell:(A3ExpenseListItemCell *)cell textFieldValueDidChange:(UITextField *)textField {

}

- (BOOL)cell:(A3ExpenseListItemCell *)cell textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	[self.keyboardAccessoryView undoRedoButtonStateChangeFor:textField];
	[self changeDirectionButtonStateFor:textField];

	UITextField *quantityField = cell.quantityField;
	if (quantityField == textField && quantityField.textAlignment != NSTextAlignmentCenter) {
		quantityField.textAlignment = NSTextAlignmentCenter;
	}

	NSMutableString *resultString = [textField.text mutableCopy];
	[resultString replaceCharactersInRange:range withString:string];
	FNLOG(@"%@", resultString);
	[self.keyboardAccessoryView showEraseButton:[resultString length] || [_textBeforeEditingTextField length]];

	return YES;
}

- (void)cell:(A3ExpenseListItemCell *)cell textFieldDidEndEditing:(UITextField *)textField {
    void (^finalize)(void) = ^(){
        if (self.nextEditingCell && self.nextEditingTextField) {
            self.editingCell = self.nextEditingCell;
            [self presentNumberKeyboardForTextField:self.nextEditingTextField];
            
            self.nextEditingCell = nil;
            self.nextEditingTextField = nil;
        }
    };
    
	FNLOG();
	if (textField != cell.nameField) {
		if (_textColorBeforeEditing) {
			textField.textColor = _textColorBeforeEditing;
			_textColorBeforeEditing = nil;
		}

		if (!_didPressNumberKey && !_didPressClearKey) {
			textField.text = _textBeforeEditingTextField;
			_textBeforeEditingTextField = nil;
		}
	}

	if (cell.quantityField == textField) {
		cell.quantityField.textAlignment = [cell.quantityField.text length] == 0 ? NSTextAlignmentRight : NSTextAlignmentCenter;
	}
	
    NSIndexPath *index = [self.tableView indexPathForCell:cell];
    if ([_tableDataSourceArray count] < [index row]) {
		_editingTextField = nil;
        self.editingObject = nil;
        _isSwitchingTextField = NO;
        
        finalize();
        
        return;
    }

    ExpenseListItem *item = [_tableDataSourceArray objectAtIndex:index.row];
    NSDate * updateDate = [NSDate date];

	if (textField == cell.nameField) {
		item.itemName = textField.text;
	}
	else if (textField == cell.priceField) {
		FNLOG(@"%@", self.decimalFormatter);
        item.price = [self.decimalFormatter numberFromString:textField.text];
		FNLOG(@"item.price = %@", item.price);
        if (![item price]) {
            item.price = [self.currencyFormatter numberFromString:textField.text];
        }

		textField.text = [self.currencyFormatter stringFromNumber:item.price];
		FNLOG(@"textField.text = %@", textField.text);
	}
	else if (textField == cell.quantityField) {
		if (![textField.text length]) {
			textField.text = [self.decimalFormatter stringFromNumber:@0];
		}
		item.qty = [self.decimalFormatter numberFromString:textField.text];
	}

    // price * qty 계산
    item.subTotal = @(item.price.doubleValue * item.qty.doubleValue);
    cell.subTotalLabel.text = [self.currencyFormatter stringFromNumber:item.subTotal];
	item.hasData = @(YES);
	item.updateDate = updateDate;
    
    if ([item hasChanges]) {
        _currentBudget.isModified = @(YES);
    }

    // 전체 항목 계산 & 화면(헤더뷰) 반영.
    [self calculateAndDisplayResultWithAnimation:!_isSwitchingTextField saveData:YES ];

    // 유효성 체크, 유효하지 않은 아이템에 기본값 부여.
    if (!_isSwitchingTextField && [self isEmptyItemRow:item]) {
        // 아무 입력이 없었던 경우
        // 행에 출력된 초기값을 제거하여 공백 셀을 만든다.
        item.hasData = @(NO);
        
        if ([self isSameFocusingOnItemRow:item toTextField:textField] || index.row==0) {
            if (textField == [self editingObject]) {
                self.editingObject = nil;
                [self re_sort_DataSourceToSeparateValidAndEmpty];
                [self.tableView reloadData];
				FNLOG(@"TableView reload data!!!");
            }
            
            return;
        }

        _selectedItem = nil;
        
        item.itemDate = nil;
        item.itemName = nil;
        item.price = nil;
        item.qty = nil;
		item.updateDate = updateDate;
		
        cell.nameField.text = @"";
        cell.priceField.text = @"";
        cell.quantityField.text = @"";
        cell.subTotalLabel.text = @"";
        cell.priceField.placeholder = @"";
        cell.quantityField.placeholder = @"";
        if (textField == [self editingObject]) {
            self.editingObject = nil;
            [self re_sort_DataSourceToSeparateValidAndEmpty];
            [self.tableView reloadData];
			FNLOG(@"TableView reload data!!!");
        }
        NSManagedObjectContext *context = A3SyncManager.sharedSyncManager.persistentContainer.viewContext;
        [context saveIfNeeded];

		_editingTextField = nil;
		self.editingObject = nil;
        
        return;
    }

	if (!_isSwitchingTextField) {
		// 예외처리, itemName 편집 종료시, top scroll 적용.
		if (textField == cell.nameField && textField == [self editingObject]) {
			[self re_sort_DataSourceToSeparateValidAndEmpty];
			[self.tableView reloadData];
			FNLOG(@"TableView reload data!!!");
			[self scrollToTopOfTableView];
			self.editingObject = nil;
		}
		else {
			if (textField == [self editingObject]) {
				self.editingObject = nil;
				if (!_isSwitchingTextField) {
					[self re_sort_DataSourceToSeparateValidAndEmpty];
					[self.tableView reloadData];
				}
			}
		}
	}
	
	[self enableControls:YES];
    NSManagedObjectContext *context = A3SyncManager.sharedSyncManager.persistentContainer.viewContext;
    [context saveIfNeeded];

	_editingTextField = nil;
	self.editingObject = nil;
	_isSwitchingTextField = NO;
    
    finalize();
}

- (BOOL)isEmptyItemRow:(ExpenseListItem *)item {
    if (item.itemName.length==0 && (!item.price || [item.price isEqualToNumber:@0]) && (!item.qty || [item.qty isEqualToNumber:@1] || [item.qty isEqualToNumber:@0] )) {
        return YES;
    }

    return NO;
}

- (BOOL)isSameFocusingOnItemRow:(ExpenseListItem *)item toTextField:(UITextField *)textField {
    if (([self editingObject] != textField && _selectedItem == item)) {
        return YES;
    }

    return NO;
}

- (void)cell:(A3ExpenseListItemCell *)aCell textFieldDidPressDoneButton:(UITextField *)textField {
    self.editingObject = nil;
    
    NSIndexPath *index = [self.tableView indexPathForCell:aCell];
    ExpenseListItem *item = [_tableDataSourceArray objectAtIndex:index.row];
    [self validateEmptyItem:item andAutoInsertCellBelow:aCell];
    [self scrollToTopOfTableView];
    [self reloadBudgetDataWithAnimation:YES saveData:NO ];
}

- (BOOL)upwardRowAvailableFor:(A3ExpenseListItemCell *)sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];

    return indexPath.row != 0 ? YES : NO;
}

- (BOOL)downwardRowAvailableFor:(A3ExpenseListItemCell *)sender
{
    return YES;
}

- (void)moveUpRowFor:(NSIndexPath *)indexPath textField:(UITextField *)textField
{
    indexPath = [NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section];
    
    A3ExpenseListItemCell *cell = (A3ExpenseListItemCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    cell.quantityField.userInteractionEnabled = YES;
    [cell.quantityField becomeFirstResponder];
}

- (void)moveDownRowFor:(NSIndexPath *)indexPath textField:(UITextField *)textField
{
    if (indexPath.row == _tableDataSourceArray.count-1) {
        [self addItemWithFocus:YES];
    } else {
        indexPath = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
        A3ExpenseListItemCell *cell = (A3ExpenseListItemCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        cell.nameField.userInteractionEnabled = YES;
        [cell.nameField becomeFirstResponder];
    }
}

- (void)removeItemForCell:(A3ExpenseListItemCell *)sender responder:(UIResponder *)keyInputDelegate
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
    ExpenseListItem *aItem = _tableDataSourceArray[indexPath.row];

	UITextField *textField = (UITextField *) self.editingObject;
    textField.text = @"";
    if (sender.priceField == keyInputDelegate) {
        textField.placeholder = [self.currencyFormatter stringFromNumber:@0];
        aItem.price = @0;
    }
    else {
        textField.placeholder = @"";
        aItem.qty = @0;
    }
}

#pragma mark - Number Keyboard

- (void)presentNumberKeyboardForTextField:(UITextField *)textField {
	if (_isNumberKeyboardVisible) {
		return;
	}
	A3NumberKeyboardViewController *keyboardViewController;
	if (IS_IPHONE) {
		keyboardViewController = [[A3NumberKeyboardViewController_iPhone alloc] initWithNibName:@"A3NumberKeyboardSimplePrevNextVC_iPhone" bundle:nil];
	} else {
		keyboardViewController = [[A3NumberKeyboardSimpleVC_iPad alloc] initWithNibName:@"A3NumberKeyboardSimplePrevNextVC_iPad" bundle:nil];
	}

	self.numberKeyboardViewController = keyboardViewController;
	keyboardViewController.delegate = self;

	UIView *superview = IS_IPHONE ? self.view.superview : [[[A3AppDelegate instance] rootViewController_iPad] view];
	CGRect bounds = [A3UIDevice screenBoundsAdjustedWithOrientation];
	CGFloat keyboardHeight = keyboardViewController.keyboardHeight;
	UIView *keyboardView = keyboardViewController.view;
	[superview addSubview:keyboardView];

	_didPressClearKey = NO;
	_didPressNumberKey = NO;
	_isNumberKeyboardVisible = YES;

	A3ExpenseListAccessoryView *accessoryView = [self accessoryForNumberField];
	accessoryView.frame = CGRectMake(0, bounds.size.height - 45.0, bounds.size.width, 45.0);
	[superview addSubview:accessoryView];
	self.keyboardAccessoryView = accessoryView;

	[self cell:_editingCell textFieldDidBeginEditing:textField];

	keyboardView.frame = CGRectMake(0, bounds.size.height, bounds.size.width, keyboardHeight);
	[UIView animateWithDuration:0.3 animations:^{
		CGRect frame = keyboardView.frame;
		frame.origin.y -= keyboardHeight;
		keyboardView.frame = frame;

		frame = accessoryView.frame;
		frame.origin.y -= keyboardHeight;
		accessoryView.frame = frame;

//		UIEdgeInsets contentInset = self.tableView.contentInset;
//		contentInset.bottom = keyboardHeight + accessoryView.frame.size.height;
//		self.tableView.contentInset = contentInset;

		[self.tableView scrollToRowAtIndexPath:_editingIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
		FNLOG(@"%@", keyboardView.superview);
		FNLOG(@"%@", accessoryView.superview);

		FNLOGRECT(keyboardView.frame);
		FNLOGRECT(accessoryView.frame);
	} completion:^(BOOL finished) {
		[self addNumberKeyboardNotificationObservers];
	}];
}

- (void)dismissNumberKeyboardWithAnimation:(BOOL)animation completion:(void (^)(void))completion {
	if (!_isNumberKeyboardVisible) {
		return;
	}

	[self cell:_editingCell textFieldDidEndEditing:_editingTextField];

	_isNumberKeyboardVisible = NO;

	[self removeNumberKeyboardNotificationObservers];
	
	A3NumberKeyboardViewController *keyboardViewController = self.numberKeyboardViewController;
	UIView *keyboardView = keyboardViewController.view;
	UIView *accessoryView = [self accessoryForNumberField];

    void(^finalize)(void) = ^{
		[keyboardView removeFromSuperview];
		[keyboardViewController removeFromParentViewController];

		[accessoryView removeFromSuperview];

		self.accessoryForNumberField = nil;
		self.numberKeyboardViewController = nil;

		if (completion) {
			completion();
		}
	};

	if (animation) {
		[UIView animateWithDuration:0.3 animations:^{
			CGFloat keyboardHeight = keyboardViewController.keyboardHeight;
			CGRect frame = keyboardView.frame;
			frame.origin.y += keyboardHeight;
			keyboardView.frame = frame;

			frame = accessoryView.frame;
			frame.origin.y += keyboardHeight;
			accessoryView.frame = frame;
			
			UIEdgeInsets contentInset = self.tableView.contentInset;
			contentInset.bottom = keyboardHeight;
			self.tableView.contentInset = contentInset;
		} completion:^(BOOL finished) {
			finalize();
		}];
	} else {
		finalize();
	}
}

#pragma mark - NumberKeyboard

- (void)handleBigButton1 {
	if (self.editingObject == _editingCell.priceField) {

	}
	else if (self.editingObject == _editingCell.quantityField) {
		self.numberKeyboardViewController.bigButton1.selected = NO;
		self.numberKeyboardViewController.bigButton2.selected = NO;
	}
}

- (void)handleBigButton2 {
	if (self.editingObject == _editingCell.priceField) {
		self.numberKeyboardViewController.bigButton1.selected = YES;
		self.numberKeyboardViewController.bigButton2.selected = NO;
	}
	else if (self.editingObject == _editingCell.quantityField) {
		self.numberKeyboardViewController.bigButton1.selected = NO;
		self.numberKeyboardViewController.bigButton2.selected = NO;
	}
}

- (void)A3KeyboardController:(id)controller doneButtonPressedTo:(UIResponder *)keyInputDelegate {
	[self dismissNumberKeyboardWithAnimation:YES completion:NULL];
}

- (void)A3KeyboardController:(id)controller clearButtonPressedTo:(UIResponder *)keyInputDelegate {
	_didPressClearKey = YES;
	_didPressNumberKey = NO;
}

- (void)keyboardViewControllerDidValueChange:(A3NumberKeyboardViewController *)vc {
	_didPressNumberKey = YES;
	_didPressClearKey = NO;
}

#pragma mark - Number Keyboard, Calculator Button Notification

- (void)calculatorButtonAction {
	_calculatorTargetTextField = (UITextField *) self.editingObject;
	_calculatorTargetCell = (A3ExpenseListItemCell *) [self.tableView cellForCellSubview:(UIView *) self.editingObject];
	[self.editingObject resignFirstResponder];
	A3CalculatorViewController *viewController = [self presentCalculatorViewController];
	viewController.delegate = self;
}

- (void)calculatorDidDismissWithValue:(NSString *)value {
	_calculatorTargetTextField.text = value;
	[self cell:_calculatorTargetCell textFieldDidEndEditing:_calculatorTargetTextField];
}

- (A3ExpenseListAccessoryView *)keyboardAccessoryView {
	if (!_keyboardAccessoryView) {
		_keyboardAccessoryView = [[A3ExpenseListAccessoryView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, 45.0)];
		_keyboardAccessoryView.delegate = self;
	}
	return _keyboardAccessoryView;
}

- (A3ExpenseListAccessoryView *)accessoryForNumberField {
	if (!_accessoryForNumberField) {
		_accessoryForNumberField = [[A3ExpenseListAccessoryView alloc] initWithFrame:CGRectZero];
		_accessoryForNumberField.delegate = self;
	}
	return _accessoryForNumberField;
}

- (void)showEraseButtonIfNeeded
{
	[self.keyboardAccessoryView showEraseButton:[_editingTextField.text length] || [_textBeforeEditingTextField length]];
}

- (void)changeDirectionButtonStateFor:(UITextField *)textField
{
	_prevColumnAvail = YES;
	_nextColumnAvail = YES;

	if (textField == _editingCell.nameField) {
		_prevColumnAvail = [self upwardRowAvailableFor:_editingCell];
	}
	else if (textField == _editingCell.quantityField) {
		_nextColumnAvail = [self downwardRowAvailableFor:_editingCell];
	}
	[self.keyboardAccessoryView.prevButton setEnabled:_prevColumnAvail];
	[self.keyboardAccessoryView.nextButton setEnabled:_nextColumnAvail];
}

#pragma mark - Accessory button

- (BOOL)isPreviousEntryExists{
	return NO;
}

- (BOOL)isNextEntryExists{
	return NO;
}

- (void)prevButtonPressed {
	[self keyboardAccessoryPrevButtonTouchUp:nil];
}

- (void)nextButtonPressed {
	[self keyboardAccessoryNextButtonTouchUp:nil];
}

#pragma mark - KeyboardAccessoryView Delegate

- (void)keyboardAccessoryUndoButtonTouchUp:(id)sender {
	if ([[_editingTextField undoManager] canUndo]) {
		[[_editingTextField undoManager] undo];

		[self.keyboardAccessoryView undoRedoButtonStateChangeFor:_editingTextField];
		[self showEraseButtonIfNeeded];
	}
}

- (void)keyboardAccessoryRedoButtonTouchUp:(id)sender {
	if ([[_editingTextField undoManager] canRedo]) {
		[[_editingTextField undoManager] redo];

		[self.keyboardAccessoryView undoRedoButtonStateChangeFor:_editingTextField];
		[self showEraseButtonIfNeeded];
	}
}

- (void)keyboardAccessoryPrevButtonTouchUp:(id)sender {
	if (_editingTextField == _editingCell.quantityField) {
		_isSwitchingTextField = YES;
		[self cell:_editingCell textFieldDidEndEditing:_editingTextField];
		[self cell:_editingCell textFieldDidBeginEditing:_editingCell.priceField];
		_editingCell.priceField.userInteractionEnabled = YES;
		_isSwitchingTextField = NO;
	}
	else if (_editingTextField == _editingCell.priceField) {
		_isSwitchingTextField = YES;
		[self dismissNumberKeyboardWithAnimation:YES completion:^{
			_editingCell.nameField.userInteractionEnabled = YES;
			[_editingCell.nameField becomeFirstResponder];
			_isSwitchingTextField = NO;
		}];
	} else if (_editingTextField == _editingCell.nameField) {
		_isSwitchingTextField = YES;
		[_editingTextField resignFirstResponder];
		[self moveUpRowFor:_editingIndexPath textField:_editingTextField];
		_isSwitchingTextField = NO;
	}
}

- (void)keyboardAccessoryNextButtonTouchUp:(id)sender {
	if (_editingTextField == _editingCell.nameField) {
		_isSwitchingTextField = YES;
		[_editingCell.nameField resignFirstResponder];
		_editingCell.priceField.userInteractionEnabled = YES;
		[self presentNumberKeyboardForTextField:_editingCell.priceField];
		_isSwitchingTextField = NO;
	}
	else if (_editingTextField == _editingCell.priceField) {
		_isSwitchingTextField = YES;
		[self cell:_editingCell textFieldDidEndEditing:_editingCell.priceField];
		_editingCell.quantityField.userInteractionEnabled = YES;
		[self cell:_editingCell textFieldDidBeginEditing:_editingCell.quantityField];
		_isSwitchingTextField = NO;
	}
	else if (_editingTextField == _editingCell.quantityField) {
		_isSwitchingTextField = YES;
		[self dismissNumberKeyboardWithAnimation:YES completion:^{
			[self moveDownRowFor:_editingIndexPath textField:_editingTextField];
			_isSwitchingTextField = NO;
		}];
	}
}

- (void)keyboardAccessoryEraseButtonTouchUp:(id)sender {
	if (_editingTextField == _editingCell.nameField) {
		[self undoTextFieldEdit:@""];
		_textBeforeEditingTextField = @"";
		[self.keyboardAccessoryView undoRedoButtonStateChangeFor:_editingTextField];
	} else {
		_editingTextField.text = [self.decimalFormatter stringFromNumber:@0];
		_textBeforeEditingTextField = _editingTextField.text;
		[self.keyboardAccessoryView undoRedoButtonStateChangeFor:_editingTextField];
	}
	[self showEraseButtonIfNeeded];
}

- (void)undoTextFieldEdit: (NSString*)string
{
	[_editingTextField.undoManager registerUndoWithTarget:self
									selector:@selector(undoTextFieldEdit:)
									  object:_editingTextField.text];
	_editingTextField.text = string;
}

@end
