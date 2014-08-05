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
#import "A3DefaultColorDefines.h"
#import "ExpenseListHistory.h"
#import "NSString+conversion.h"
#import "ExpenseListItem+management.h"
#import "NSMutableArray+A3Sort.h"
#import "UIViewController+iPad_rightSideView.h"
#import "A3CalculatorViewController.h"
#import "UITableView+utility.h"
#import "A3InstructionViewController.h"
#import "ExpenseListBudget+extension.h"
#import "A3UserDefaults.h"
#import "A3SyncManager.h"
#import "NSManagedObject+extension.h"

#define kDefaultItemCount_iPhone    9
#define kDefaultItemCount_iPad      18

NSString *const A3ExpenseListCurrentBudgetID = @"CurrentBudget";
NSString *const A3NotificationExpenseListCurrencyCodeChanged = @"A3NotificationExpenseListCurrencyCodeChanged";

@interface A3ExpenseListMainViewController () <ATSDragToReorderTableViewControllerDelegate, UIPopoverControllerDelegate, A3ExpenseBudgetSettingDelegate, A3ExpenseListItemCellDelegate, UINavigationControllerDelegate, A3ExpenseListHistoryDelegate, A3CalculatorViewControllerDelegate, A3InstructionViewControllerDelegate>

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
}

NSString *const ExpenseListMainCellIdentifier = @"Cell";

- (void)viewDidLoad
{
    [super viewDidLoad];

	_isAutoMovingAddBudgetView = NO;
	_barButtonEnabled = YES;

    [self makeBackButtonEmptyArrow];
	[self leftBarButtonAppsButton];

    self.title = NSLocalizedString(@"Expense List", @"Expense List");

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
    self.tableView.separatorColor = COLOR_TABLE_SEPARATOR;
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
    [self moveToAddBudgetIfBudgetNotExistWithDelay:1.0];
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
}

- (void)cloudStoreDidImport {
	if (self.firstResponder) return;

	NSString *currencyCode = [[NSUserDefaults standardUserDefaults] objectForKey:A3ExpenseListUserDefaultsCurrencyCode];
	[self.currencyFormatter setCurrencyCode:currencyCode];

	[self reloadBudgetDataWithAnimation:YES saveData:NO ];

	[self enableControls:_barButtonEnabled];
}

- (void)removeObserver {
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
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	if ([self isMovingFromParentViewController] || [self isBeingDismissed]) {
		FNLOG();
		[self removeObserver];
	}
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    [self setupInstructionView];
}

- (void)dealloc {
	[self removeObserver];
}

- (void)cleanUp {
	[self removeObserver];
}

- (void)mainMenuDidHide {
	[self enableControls:YES];
}

- (void)rightSideViewDidAppear {
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
					[barButtonItem setEnabled:[ExpenseListItem MR_countOfEntitiesWithPredicate:predicate] > 0];
					break;
				}
				case A3RightBarButtonTagHistoryButton:
					[barButtonItem setEnabled:[ExpenseListHistory MR_countOfEntities] > 0];
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

- (void)currencyCodeChanged:(NSNotification *)notification {
	NSString *currencyCode = [[NSUserDefaults standardUserDefaults] objectForKey:A3ExpenseListUserDefaultsCurrencyCode];
	[self.currencyFormatter setCurrencyCode:currencyCode];
    
	if ([[A3SyncManager sharedSyncManager] isCloudEnabled]) {
        NSDate *updateDate = [NSDate date];
		NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
		[store setObject:currencyCode forKey:A3ExpenseListUserDefaultsCurrencyCode];
		[store setObject:updateDate forKey:A3ExpenseListUserDefaultsCloudUpdateDate];
		[store synchronize];
	}

	_headerView.currencyFormatter = self.currencyFormatter;
	[self reloadBudgetDataWithAnimation:NO saveData:NO ];
}

-(void)setupTopWhitePaddingView
{
    _topWhitePaddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.0)];
    _topWhitePaddingView.backgroundColor = [UIColor colorWithRed:239.0/255.0 green:239.0/255.0 blue:244.0/255.0 alpha:1.0];
    _topWhitePaddingView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
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
	[self clearEverything];

	[super appsButtonAction:barButtonItem];
	if (IS_IPAD) {
		[self enableControls:!self.A3RootViewController.showLeftView];
	}
}

- (NSString *)defaultCurrencyCode {
	NSString *currencyCode = [[NSUserDefaults standardUserDefaults] objectForKey:A3ExpenseListUserDefaultsCurrencyCode];
	if (!currencyCode) {
		currencyCode = [[NSLocale currentLocale] objectForKey:NSLocaleCurrencyCode];
	}
	return currencyCode;
}

#pragma mark Instruction Related

static NSString *const A3V3InstructionDidShowForExpenseList = @"A3V3InstructionDidShowForExpenseList";

- (void)setupInstructionView
{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:A3V3InstructionDidShowForExpenseList]) {
        if (IS_IPHONE) {
            [self moreButtonAction:nil];
        }
        [self showInstructionView];
    }
}

- (void)showInstructionView
{
	[[NSUserDefaults standardUserDefaults] setBool:YES forKey:A3V3InstructionDidShowForExpenseList];
	[[NSUserDefaults standardUserDefaults] synchronize];

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
        [self moveToAddBudgetIfBudgetNotExistWithDelay:1.0];
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

	[[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];

	NSInteger focusingRow = [_currentBudget expenseItemsCount] - 1;

    _tableDataSourceArray = [self loadBudgetFromDB];
	[self.tableView reloadData];

    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        if (focus) {
            A3ExpenseListItemCell *cell = (A3ExpenseListItemCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:focusingRow inSection:0]];
            cell.nameTextField.userInteractionEnabled = YES;
            [cell.nameTextField becomeFirstResponder];
        }
    }];
    [CATransaction commit];
}

- (void)clearEverything {
	[self dismissMoreMenu];
	[self.firstResponder resignFirstResponder];
	[self setFirstResponder:nil];
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
	[self rightButtonMoreButton];
	[self dismissMoreMenuView:_moreMenuView scrollView:nil];
	[self.view removeGestureRecognizer:gestureRecognizer];
    
    UIEdgeInsets inset = self.tableView.contentInset;
    inset.top = 64;
    self.tableView.contentInset = inset;
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
            aCell.nameTextField.userInteractionEnabled = YES;
            [aCell.nameTextField becomeFirstResponder];
        }
        else if ( tapLocation.x > _sep1View.frame.origin.x && tapLocation.x < _sep2View.frame.origin.x) {
            aCell.priceTextField.userInteractionEnabled = YES;
            [aCell.priceTextField becomeFirstResponder];
        }
        else if ( tapLocation.x > _sep2View.frame.origin.x && tapLocation.x < _sep3View.frame.origin.x) {
            aCell.qtyTextField.userInteractionEnabled = YES;
            [aCell.qtyTextField becomeFirstResponder];
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
    [self clearEverything];

    // 현재 상태 저장.
    if ([_currentBudget.isModified boolValue]) {
        [self saveCurrentBudgetToHistory];
    }

	NSDate *updateDate = [NSDate date];
	[[NSUserDefaults standardUserDefaults] setObject:updateDate forKey:A3ExpenseListUserDefaultsUpdateDate];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:A3ExpenseListIsAddBudgetCanceledByUser];
    [[NSUserDefaults standardUserDefaults] synchronize];

	if ([[A3SyncManager sharedSyncManager] isCloudEnabled]) {
		NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
		[store setBool:NO forKey:A3ExpenseListIsAddBudgetCanceledByUser];
		[store setObject:updateDate forKey:A3ExpenseListUserDefaultsCloudUpdateDate];
		[store synchronize];
	}

	// 초기화.
    [self clearCurrentBudget];
    _tableDataSourceArray = nil;
    [self reloadBudgetDataWithAnimation:YES saveData:YES ];
    [self moveToAddBudgetIfBudgetNotExistWithDelay:1.0];
}

- (void)clearCurrentBudget {
    for (ExpenseListItem * item in [_currentBudget expenseItems]) {
        [item MR_deleteEntity];
    }
    
    [_currentBudget MR_deleteEntity];
    _currentBudget = nil;
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

- (void)historyButtonAction:(id)sender
{
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
		[self.A3RootViewController presentRightSideViewController:viewController];
	}
}

- (void)expenseHistoryViewControllerDidDismiss {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationChildViewControllerDidDismiss object:_modalNavigationController.childViewControllers[0]];
	_modalNavigationController = nil;
}

- (void)shareButtonAction:(id)sender {
	[self clearEverything];

	if (_isAutoMovingAddBudgetView) {
		return;
	}

	_sharePopoverController = [self presentActivityViewControllerWithActivityItems:@[@"test"] fromBarButtonItem:sender];
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
		A3RootViewController_iPad *rootViewController = [[A3AppDelegate instance] rootViewController];
        [rootViewController presentCenterViewController:[[A3NavigationController alloc] initWithRootViewController:viewController] fromViewController:self withCompletion:^{
            [viewController showKeyboard];
        }];
    }
}

- (void)moreButtonAction:(UIButton *)button
{
	[self.firstResponder resignFirstResponder];

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
    addNew.enabled = [ExpenseListItem MR_countOfEntitiesWithPredicate:predicate] > 0;
	// History
    history.enabled = [ExpenseListHistory MR_countOfEntities] > 0;
	// Share
//    share.enabled = _currentBudget.category != nil;

	_moreMenuView = [self presentMoreMenuWithButtons:_moreMenuButtons tableView:self.tableView];
}

- (void)addItemButtonAction:(id)sender
{
    _currentBudget.updateDate = [NSDate date];

	[self createExpenseListItemWithBudgetID:_currentBudget.uniqueID];

	[[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    
    _currentBudget = [ExpenseListBudget MR_findFirstByAttribute:@"uniqueID" withValue:A3ExpenseListCurrentBudgetID];
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
        aCell.nameTextField.text = @"";
        aCell.priceTextField.text = [self.currencyFormatter stringFromNumber:@0];
        aCell.qtyTextField.text = @"1";
        aCell.subTotalLabel.text = [self.currencyFormatter stringFromNumber:@0];
        aCell.priceTextField.placeholder = @"";
        aCell.qtyTextField.placeholder = @"";
    }
    else {
        // 입력 포커스 후
        // price * qty 계산
        item.subTotal = @(item.price.floatValue * item.qty.floatValue);
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
                
                nextCell.priceTextField.text = [self.currencyFormatter stringFromNumber:nextItem.price];
                NSNumberFormatter *formatter = [NSNumberFormatter new];
                [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
                nextCell.qtyTextField.text = [formatter stringFromNumber:nextItem.qty];
                nextCell.subTotalLabel.text = [self.currencyFormatter stringFromNumber:@(nextItem.price.floatValue * nextItem.qty.floatValue)];
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
    float usedBudget = 0.0;
    for (ExpenseListItem *item in _tableDataSourceArray) {
        usedBudget += item.price.floatValue * item.qty.floatValue;
    }
    _currentBudget.usedAmount = @(usedBudget);
    
    // 헤더뷰 결과 반영.
    [self.headerView setResult:_currentBudget withAnimation:animation];
    // 현재 상태 저장.
	if (saveData) {
		[self saveCurrentBudget];
	}
}

- (void)reloadBudgetDataWithAnimation:(BOOL)animation saveData:(BOOL)saveData {
    // 데이터 갱신.
    [self reloadBudgetDataCreateIfNotExist:saveData ];

    // 계산 & 화면 갱신.
    [self calculateAndDisplayResultWithAnimation:animation saveData:saveData ];
    [self.tableView reloadData];
	[self enableControls:YES];
}

- (void)reloadBudgetDataCreateIfNotExist:(BOOL)create {
    _currentBudget = [ExpenseListBudget MR_findFirstByAttribute:@"uniqueID" withValue:A3ExpenseListCurrentBudgetID];

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

		_currentBudget = [ExpenseListBudget MR_createEntity];
		_currentBudget.uniqueID = A3ExpenseListCurrentBudgetID;
		_currentBudget.updateDate = [NSDate date];
        _currentBudget.isModified = @(NO);

		for (NSInteger idx = 0; idx < defaultCount; idx++) {
			ExpenseListItem *item = [ExpenseListItem MR_createEntity];
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

		[[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
	}
	_tableDataSourceArray = [self loadBudgetFromDB];
}

- (ExpenseListItem *)createExpenseListItemWithBudgetID:(NSString *)budgetID {
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"budgetID == %@", budgetID];
	ExpenseListItem *newItem = [ExpenseListItem MR_createEntity];
	ExpenseListItem *lastItem = [ExpenseListItem MR_findFirstWithPredicate:predicate sortedBy:@"uniqueID" ascending:NO];
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

- (void)saveCurrentBudget
{
	[[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];

    FNLOG(@"History count : %ld", (long)[ExpenseListHistory MR_countOfEntities]);
    FNLOG(@"Budget count : %ld", (long)[ExpenseListBudget MR_countOfEntities]);
}

- (void)saveCurrentBudgetToHistory
{
	// 현재 예산에 새 ID 를 부여하고 history 로 전환
    _currentBudget.currencyCode = [self defaultCurrencyCode];

    NSManagedObjectContext *savingContext = [NSManagedObjectContext MR_newContext];
	ExpenseListBudget *budgetInHistory = (ExpenseListBudget *) [_currentBudget cloneInContext:savingContext];
	budgetInHistory.uniqueID = [[NSUUID UUID] UUIDString];

	ExpenseListHistory * history = [ExpenseListHistory MR_createEntityInContext:savingContext];
	history.uniqueID = [[NSUUID UUID] UUIDString];
	history.updateDate = [NSDate date];
	history.budgetID = budgetInHistory.uniqueID;

	for (ExpenseListItem *item in _tableDataSourceArray) {
		ExpenseListItem *itemInHistory = (ExpenseListItem *) [item cloneInContext:savingContext];
		itemInHistory.uniqueID = [[NSUUID UUID] UUIDString];
		itemInHistory.budgetID = budgetInHistory.uniqueID;
	}

    [savingContext MR_saveToPersistentStoreAndWait];
    
	FNLOG(@"History count : %ld", (long)[ExpenseListHistory MR_countOfEntities]);
	FNLOG(@"Budget count : %ld", (long)[ExpenseListBudget MR_countOfEntities]);
}

#pragma mark - misc

- (void)moveToAddBudgetIfBudgetNotExistWithDelay:(CGFloat)delay {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:A3V3InstructionDidShowForExpenseList]) {
        return;
    }
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:A3ExpenseListIsAddBudgetCanceledByUser]) {
        return;
    }

    if ([[NSUserDefaults standardUserDefaults] boolForKey:A3ExpenseListIsAddBudgetInitiatedOnce]) {
        return;
    }
    
    // 버젯이 없는 경우 이동한다.
    if (!_currentBudget || _currentBudget.category==nil ) {
		NSDate *updateDate = [NSDate date];
		[[NSUserDefaults standardUserDefaults] setObject:updateDate forKey:A3ExpenseListUserDefaultsUpdateDate];
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:A3ExpenseListIsAddBudgetInitiatedOnce];
		[[NSUserDefaults standardUserDefaults] synchronize];

		if ([[A3SyncManager sharedSyncManager] isCloudEnabled]) {
			NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
			[store setObject:@YES forKey:A3ExpenseListIsAddBudgetInitiatedOnce];
			[store setObject:updateDate forKey:A3ExpenseListUserDefaultsCloudUpdateDate];
			[store synchronize];
		}

        [self performSelector:@selector(moveToAddBudgetViewController) withObject:nil afterDelay:delay];
        _isAutoMovingAddBudgetView = YES;
    }
}

-(void)scrollToTopOfTableView {
    if (IS_LANDSCAPE) {
        [UIView beginAnimations:A3AnimationIDKeyboardWillShow context:nil];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationCurve:7];
        [UIView setAnimationDuration:0.35];
        self.tableView.contentOffset = CGPointMake(0.0, CGPointMake(0.0, -(self.navigationController.navigationBar.bounds.size.height + [[UIApplication sharedApplication] statusBarFrame].size.width)).y);
        [UIView commitAnimations];
    }
    else {
        [UIView beginAnimations:A3AnimationIDKeyboardWillShow context:nil];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationCurve:7];
        [UIView setAnimationDuration:0.35];
        self.tableView.contentOffset = CGPointMake(0.0, CGPointMake(0.0, -(self.navigationController.navigationBar.bounds.size.height + [[UIApplication sharedApplication] statusBarFrame].size.height)).y);
        [UIView commitAnimations];
    }
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

    cell.nameTextField.userInteractionEnabled = NO;
    cell.priceTextField.userInteractionEnabled = NO;
    cell.qtyTextField.userInteractionEnabled = NO;
    
	if ([item.hasData boolValue] || indexPath.row == 0) {    // kjh 추후에 변경하도록
		cell.nameTextField.text = item.itemName;
		cell.priceTextField.text = [self.currencyFormatter stringFromNumber:item.price];
		cell.qtyTextField.text = item.qty.stringValue;
		cell.subTotalLabel.text = [self.currencyFormatter stringFromNumber:@(item.price.floatValue * item.qty.floatValue)];
	} else {
		cell.nameTextField.text = @"";
		cell.priceTextField.text = @"";
		cell.qtyTextField.text = @"";
		cell.subTotalLabel.text = @"";
		cell.nameTextField.placeholder = @"";
		cell.priceTextField.placeholder = @"";
		cell.qtyTextField.placeholder = @"";
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
    
    if (_tableDataSourceArray.count > defaultItemCount) {
        ExpenseListItem *aItem = _tableDataSourceArray[indexPath.row];
        [aItem MR_deleteEntity];
		[[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];

        [self re_sort_DataSourceToSeparateValidAndEmpty];
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
		[[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        
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
			[[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        }
        
        [self re_sort_DataSourceToSeparateValidAndEmpty];
        [self reloadBudgetDataWithAnimation:YES saveData:NO ];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return IS_RETINA ? 56.0 : 57.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return indexPath.row == 0 ? (IS_RETINA ? 43.5 : 43) : 44.0;
}

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

#pragma mark ATSDragToReorderTableViewController Delegate
- (BOOL)dragTableViewController:(ATSDragToReorderTableViewController *)dragTableViewController shouldHideDraggableIndicatorForDraggingToRow:(NSIndexPath *)destinationIndexPath {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self re_sort_DataSourceToSeparateValidAndEmpty];
        [self.tableView reloadData];
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
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
    NSManagedObjectContext * savingContext = [NSManagedObjectContext MR_defaultContext];
    NSDate *updateDate = [NSDate date];
    
	_currentBudget = (ExpenseListBudget *) [aBudget cloneInContext:savingContext];
    _currentBudget.uniqueID = A3ExpenseListCurrentBudgetID;
	_currentBudget.updateDate = updateDate;
    _currentBudget.isModified = @(NO);

	[[NSUserDefaults standardUserDefaults] setObject:aBudget.currencyCode forKey:A3ExpenseListUserDefaultsCurrencyCode];
	[[NSUserDefaults standardUserDefaults] synchronize];
    
	if ([[A3SyncManager sharedSyncManager] isCloudEnabled]) {
		NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
		[store setObject:aBudget.currencyCode forKey:A3ExpenseListUserDefaultsCurrencyCode];
		[store setObject:updateDate forKey:A3ExpenseListUserDefaultsCloudUpdateDate];
		[store synchronize];
	}
    
    self.currencyFormatter.currencyCode = [self defaultCurrencyCode];
	_headerView.currencyFormatter = self.currencyFormatter;

	[[aBudget expenseItems] enumerateObjectsUsingBlock:^(ExpenseListItem *item, NSUInteger idx, BOOL *stop) {
		ExpenseListItem *newCurrentItem = (ExpenseListItem *) [item cloneInContext:savingContext];
		newCurrentItem.uniqueID = [self itemIDWithIndex:idx];
        FNLOG(@"uniqueID : %@", newCurrentItem.uniqueID);
		newCurrentItem.budgetID = _currentBudget.uniqueID;
	}];

    [savingContext MR_saveToPersistentStoreAndWait];
    
    _tableDataSourceArray = [self loadBudgetFromDB];

	[self calculateAndDisplayResultWithAnimation:YES saveData:YES ];
	[self.tableView reloadData];
	[self enableControls:YES];
}

-(void)didDismissExpenseHistoryViewController {
	[self enableControls:YES];
}

#pragma mark - A3ExpenseListItemCell Delegate

-(void)itemCellTextFieldBeginEditing:(A3ExpenseListItemCell *)aCell textField:(UITextField *)textField
{
	[self setFirstResponder:textField];
    [self dismissMoreMenu];
    [self.tableView setEditing:NO animated:YES];
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:aCell];
    ExpenseListItem *item = [_tableDataSourceArray objectAtIndex:indexPath.row];
    if (![item.hasData boolValue] && _selectedItem != item) {
        item.itemDate = [NSDate date];
        item.price = @0;
        item.qty = @1;
        item.subTotal = @0;
        
        aCell.priceTextField.text = [self.currencyFormatter stringFromNumber:item.price];
        aCell.qtyTextField.text = item.qty.stringValue;
        aCell.subTotalLabel.text = [self.currencyFormatter stringFromNumber:@(item.price.floatValue * item.qty.floatValue)];
    }
    
    _selectedItem = item;
	[self addNumberKeyboardNotificationObservers];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)textFieldDidChange:(NSNotification *)notification
{
    UITextField *textField = notification.object;
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:CGPointMake(100, [textField convertPoint:textField.center toView:self.tableView].y)];
    if (!indexPath) {
        return;
    }
    
    A3ExpenseListItemCell *aCell = (A3ExpenseListItemCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    ExpenseListItem *item = [_tableDataSourceArray objectAtIndex:indexPath.row];
	if (textField == aCell.nameTextField) {
		item.itemName = textField.text;
	}
	else if (textField == aCell.priceTextField) {
		item.price = @([textField.text floatValueEx]);
	}
	else if (textField == aCell.qtyTextField) {
		[self.decimalFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
		item.qty = [self.decimalFormatter numberFromString:textField.text];
	}
    
    // price * qty 계산
    item.subTotal = @(item.price.floatValue * item.qty.floatValue);
    aCell.subTotalLabel.text = [self.currencyFormatter stringFromNumber:item.subTotal];
    
    // 전체 항목 계산 & 화면(헤더뷰) 반영.
//    [self calculateAndDisplayResultWithAnimation:YES];
}

-(void)itemCellTextFieldChanged:(A3ExpenseListItemCell *)aCell textField:(UITextField *)textField
{

}

-(void)itemCellTextFieldFinished:(A3ExpenseListItemCell *)aCell textField:(UITextField *)textField
{
    if (textField == self.firstResponder) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
        [self removeNumberKeyboardNotificationObservers];
    }

    textField.userInteractionEnabled = NO;
    
    NSIndexPath *index = [self.tableView indexPathForCell:aCell];
    if ([_tableDataSourceArray count] < [index row]) {
        self.firstResponder = nil;
        return;
    }

    ExpenseListItem *item = [_tableDataSourceArray objectAtIndex:index.row];
    NSDate * updateDate = [NSDate date];

	if (textField == aCell.nameTextField) {
		item.itemName = textField.text;
	}
	else if (textField == aCell.priceTextField) {
        item.price = [self.decimalFormatter numberFromString:textField.text];
        if (![item price]) {
            item.price = [self.decimalFormatter numberFromString:[textField.text stringByReplacingOccurrencesOfString:[self.currencyFormatter currencySymbol] withString:@""]];
        }
		textField.text = [self.currencyFormatter stringFromNumber:item.price];
	}
	else if (textField == aCell.qtyTextField) {
		[self.decimalFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
		if (![textField.text length]) {
			textField.text = [self.decimalFormatter stringFromNumber:@0];
		}
		item.qty = [self.decimalFormatter numberFromString:textField.text];
	}

    // price * qty 계산
    item.subTotal = @(item.price.floatValue * item.qty.floatValue);
    aCell.subTotalLabel.text = [self.currencyFormatter stringFromNumber:item.subTotal];
	item.hasData = @(YES);
	item.updateDate = updateDate;
    
    if ([item hasChanges]) {
        _currentBudget.isModified = @(YES);
    }

    // 전체 항목 계산 & 화면(헤더뷰) 반영.
    [self calculateAndDisplayResultWithAnimation:YES saveData:YES ];

    // 유효성 체크, 유효하지 않은 아이템에 기본값 부여.
    if ([self isEmptyItemRow:item]) {
        // 아무 입력이 없었던 경우
        // 행에 출력된 초기값을 제거하여 공백 셀을 만든다.
        item.hasData = @(NO);
        
        if ([self isSameFocusingOnItemRow:item toTextField:textField] || index.row==0) {
            if (textField == [self firstResponder]) {
                self.firstResponder = nil;
                [self re_sort_DataSourceToSeparateValidAndEmpty];
                [self.tableView reloadData];
            }
            return;
        }

        _selectedItem = nil;
        
        item.itemDate = nil;
        item.itemName = nil;
        item.price = nil;
        item.qty = nil;
		item.updateDate = updateDate;
		
        aCell.nameTextField.text = @"";
        aCell.priceTextField.text = @"";
        aCell.qtyTextField.text = @"";
        aCell.subTotalLabel.text = @"";
        aCell.priceTextField.placeholder = @"";
        aCell.qtyTextField.placeholder = @"";
        if (textField == [self firstResponder]) {
            self.firstResponder = nil;
            [self re_sort_DataSourceToSeparateValidAndEmpty];
            [self.tableView reloadData];
        }
		[[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        return;
    }

    // 예외처리, itemName 편집 종료시, top scroll 적용.
    if (textField == aCell.nameTextField && textField == [self firstResponder]) {
        [self re_sort_DataSourceToSeparateValidAndEmpty];
        [self.tableView reloadData];
        [self scrollToTopOfTableView];
        self.firstResponder = nil;
    }
    else {
        if (textField == [self firstResponder]) {
            self.firstResponder = nil;
            [self re_sort_DataSourceToSeparateValidAndEmpty];
            [self.tableView reloadData];
        }
    }

	[self enableControls:YES];
}



- (BOOL)isEmptyItemRow:(ExpenseListItem *)item {
    if (item.itemName.length==0 && (!item.price || [item.price isEqualToNumber:@0]) && (!item.qty || [item.qty isEqualToNumber:@1] || [item.qty isEqualToNumber:@0] )) {
        return YES;
    }

    return NO;
}

- (BOOL)isSameFocusingOnItemRow:(ExpenseListItem *)item toTextField:(UITextField *)textField {
    if (([self firstResponder] != textField && _selectedItem == item)) {
        return YES;
    }
    
    return NO;
}

-(void)itemCellTextFieldDonePressed:(A3ExpenseListItemCell *)aCell
{
    self.firstResponder = nil;
    
    NSIndexPath *index = [self.tableView indexPathForCell:aCell];
    ExpenseListItem *item = [_tableDataSourceArray objectAtIndex:index.row];
    [self validateEmptyItem:item andAutoInsertCellBelow:aCell];
    [self scrollToTopOfTableView];
    [self reloadBudgetDataWithAnimation:YES saveData:NO ];
}

-(BOOL)upwardRowAvailableFor:(A3ExpenseListItemCell *)sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];

    return indexPath.row != 0 ? YES : NO;
}

-(BOOL)downwardRowAvailableFor:(A3ExpenseListItemCell *)sender
{
    return YES;
}

-(void)moveUpRowFor:(A3ExpenseListItemCell *)sender textField:(UITextField *)textField
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    indexPath = [NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section];
    
    A3ExpenseListItemCell *cell = (A3ExpenseListItemCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    cell.qtyTextField.userInteractionEnabled = YES;
    [cell.qtyTextField becomeFirstResponder];
}

-(void)moveDownRowFor:(A3ExpenseListItemCell *)sender textField:(UITextField *)textField
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    
    if (indexPath.row == _tableDataSourceArray.count-1) {
        [self addItemWithFocus:YES];
    } else {
        indexPath = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
        A3ExpenseListItemCell *cell = (A3ExpenseListItemCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        cell.nameTextField.userInteractionEnabled = YES;
        [cell.nameTextField becomeFirstResponder];
    }
}

-(void)removeItemForCell:(A3ExpenseListItemCell *)sender responder:(UIResponder *)keyInputDelegate
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
    ExpenseListItem *aItem = _tableDataSourceArray[indexPath.row];

	UITextField *textField = (UITextField *) self.firstResponder;
    textField.text = @"";
    if (sender.priceTextField == keyInputDelegate) {
        textField.placeholder = [self.currencyFormatter stringFromNumber:@0];
        aItem.price = @0;
    }
    else {
        textField.placeholder = @"";
        aItem.qty = @0;
    }
}

#pragma mark - Number Keyboard, Calculator Button Notification

- (void)calculatorButtonAction {
	_calculatorTargetTextField = (UITextField *) self.firstResponder;
	_calculatorTargetCell = (A3ExpenseListItemCell *) [self.tableView cellForCellSubview:(UIView *) self.firstResponder];
	[self.firstResponder resignFirstResponder];
	A3CalculatorViewController *viewController = [self presentCalculatorViewController];
	viewController.delegate = self;
}

- (void)calculatorDidDismissWithValue:(NSString *)value {
	_calculatorTargetTextField.text = value;
	[self itemCellTextFieldFinished:_calculatorTargetCell textField:_calculatorTargetTextField];
}

@end
