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

#define kDefaultItemCount_iPhone    9
#define kDefaultItemCount_iPad      18

NSString *const A3ExpenseListCurrentBudgetID = @"A3ExpenseListCurrentBudgetID";
NSString *const A3ExpenseListCurrencyCode = @"A3ExpenseListCurrencyCode";
NSString *const A3NotificationExpenseListCurrencyCodeChanged = @"A3NotificationExpenseListCurrencyCodeChanged";
NSString *const A3ExpenseListIsAddBudgetCanceledByUser = @"A3ExpenseListIsAddBudgetCanceledByUser";

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
@property (nonatomic, strong) NSNumberFormatter *priceNumberFormatter;
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
}

NSString *const ExpenseListMainCellIdentifier = @"Cell";

- (void)viewDidLoad
{
    [super viewDidLoad];

	_isAutoMovingAddBudgetView = NO;

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
    [self.tableView addGestureRecognizer:_tapGestureRecognizer];
    
    _columnSectionView = [[A3ExpenseListColumnSectionView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 45.0)];

    [self makeRightBarButtons];
    [self reloadBudgetDataAndRemoveEmptyItem];
    [self setupTopWhitePaddingView];
    [self expandContentSizeForAddItem];
    [self moveToAddBudgetIfBudgetNotExistWithDelay:1.0];
    [self setupInstructionView];
    
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currencyCodeChanged:) name:A3NotificationExpenseListCurrencyCodeChanged object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:nil];

	if (IS_IPAD) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainMenuDidHide) name:A3NotificationMainMenuDidHide object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rightSideViewDidAppear) name:A3NotificationRightSideViewDidAppear object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rightSideViewWillDismiss) name:A3NotificationRightSideViewWillDismiss object:nil];
	}

	[self registerContentSizeCategoryDidChangeNotification];
}

- (void)removeObserver {
	FNLOG();
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

	[self.navigationItem.leftBarButtonItem setEnabled:enable];
	if (enable) {
		[self.navigationItem.rightBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem *barButtonItem, NSUInteger idx, BOOL *stop) {
			switch (barButtonItem.tag) {
				case A3RightBarButtonTagComposeButton:{
					NSPredicate *predicate = [NSPredicate predicateWithFormat:@"budget.budgetId == %@ and hasData == YES", _currentBudget.budgetId];
					[barButtonItem setEnabled:[ExpenseListItem MR_countOfEntitiesWithPredicate:predicate] > 0];
					break;
				}
				case A3RightBarButtonTagHistoryButton:
					[barButtonItem setEnabled:[ExpenseListHistory MR_countOfEntities] > 0];
					break;
				case A3RightBarButtonTagShareButton:
					[barButtonItem setEnabled:_currentBudget.category != nil];
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

- (void)enableMoreMenuButtons {
	// AddNew
	UIButton *button = [_moreMenuButtons objectAtIndex:1];
	if (button) {
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"budget.budgetId == %@ and hasData == YES", _currentBudget.budgetId];
		button.enabled = [ExpenseListItem MR_countOfEntitiesWithPredicate:predicate] > 0;
	}

	// History
	button = [_moreMenuButtons objectAtIndex:2];
	if (button) {
		button.enabled = [ExpenseListHistory MR_countOfEntities] > 0;
	}

	// Share
	button = [_moreMenuButtons objectAtIndex:0];
	if (button) {
		button.enabled = _currentBudget.category != nil;
	}
}

- (void)currencyCodeChanged:(NSNotification *)notification {
	_priceNumberFormatter = nil;
	[self setCurrencyFormatter:nil];

	_headerView.currencyFormatter = self.currencyFormatter;
	[self reloadBudgetDataWithAnimation:NO];
}

-(void)setupTopWhitePaddingView
{
    _topWhitePaddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.0)];
    _topWhitePaddingView.backgroundColor = [UIColor colorWithRed:239.0/255.0 green:239.0/255.0 blue:244.0/255.0 alpha:1.0];
    _topWhitePaddingView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
    [self.tableView addSubview:_topWhitePaddingView];
}

-(void)contentSizeDidChange:(NSNotification *)notification {
    [self reloadBudgetDataWithAnimation:NO];
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
        [_headerView.detailInfoButton addTarget:self action:@selector(detailInfoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _headerView;
}

- (void)makeRightBarButtons
{
//    if (IS_IPHONE) {
//        [self rightButtonMoreButton];
//        self.tableView.separatorInset = UIEdgeInsetsMake(0, 15.0, 0, 0);
//    }
//    else {
//        self.navigationItem.hidesBackButton = YES;
//        self.tableView.separatorInset = UIEdgeInsetsMake(0, 28.0, 0, 0);
//        
//        UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"add06"]
//                                                                style:UIBarButtonItemStylePlain
//                                                               target:self
//                                                               action:@selector(addNewButtonAction:)];
//		add.tag = A3RightBarButtonTagComposeButton;
//        UIBarButtonItem *history = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"history"]
//                                                                    style:UIBarButtonItemStylePlain
//                                                                   target:self
//                                                                   action:@selector(historyButtonAction:)];
//		history.tag = A3RightBarButtonTagHistoryButton;
//        UIBarButtonItem *share = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"share"]
//                                                                  style:UIBarButtonItemStylePlain
//                                                                 target:self
//                                                                  action:@selector(shareButtonAction:)];
//		share.tag = A3RightBarButtonTagShareButton;
//        
//        self.navigationItem.rightBarButtonItems = @[history, add, share];
//    }
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

    self.navigationItem.rightBarButtonItems = @[history, add];
}

-(void)setCurrentBudgetId:(NSString *)currentBudgetId {
	[[NSUserDefaults standardUserDefaults] setObject:currentBudgetId forKey:A3ExpenseListCurrentBudgetID];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSString *)currentBudgetId {
    return [[NSUserDefaults standardUserDefaults] objectForKey:A3ExpenseListCurrentBudgetID];
}

- (void)appsButtonAction:(UIBarButtonItem *)barButtonItem {
	[self clearEverything];

	[super appsButtonAction:barButtonItem];
	if (IS_IPAD) {
		[self enableControls:!self.A3RootViewController.showLeftView];
	}
}

- (NSNumberFormatter *)priceNumberFormatter
{
    if (!_priceNumberFormatter) {
        _priceNumberFormatter = [NSNumberFormatter new];
        [_priceNumberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [_priceNumberFormatter setMaximumFractionDigits:2];
		[_priceNumberFormatter setCurrencyCode:self.defaultCurrencyCode];
        if (IS_IPHONE) {
            _priceNumberFormatter.currencySymbol = @"";
        }
    }
    
    return _priceNumberFormatter;
}

- (NSString *)defaultCurrencyCode {
	NSString *currencyCode = [[NSUserDefaults standardUserDefaults] objectForKey:A3ExpenseListCurrencyCode];
	if (!currencyCode) {
		currencyCode = [[NSLocale currentLocale] objectForKey:NSLocaleCurrencyCode];
	}
	return currencyCode;
}

#pragma mark Instructiown Related
- (void)setupInstructionView
{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"ExpenseList"]) {
        [self showInstructionView];
    }
//    [self setupTwoFingerDoubleTapGestureToShowInstruction];
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showInstructionView)];
    [gesture setNumberOfTouchesRequired:2];
    [gesture setNumberOfTapsRequired:2];
    [gesture setDelaysTouchesBegan:YES];
    [self.view addGestureRecognizer:gesture];
    self.reservedTapGestureRecognizer = gesture;
}

- (void)showInstructionView
{
    UIStoryboard *instructionStoryBoard = [UIStoryboard storyboardWithName:IS_IPHONE ? @"Instruction_iPhone" : @"Instruction_iPad" bundle:nil];
    _instructionViewController = [instructionStoryBoard instantiateViewControllerWithIdentifier:@"ExpenseList"];
    self.instructionViewController.delegate = self;
    [self.navigationController.view addSubview:self.instructionViewController.view];
    self.instructionViewController.view.frame = self.navigationController.view.frame;
    self.instructionViewController.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight;
}

- (void)dismissInstructionViewController:(UIView *)view
{
    [self.instructionViewController.view removeFromSuperview];
    if ([self.instructionViewController isFirstInstruction]) {
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
    ExpenseListItem *item = [ExpenseListItem MR_createEntity];
    [_currentBudget addExpenseItemsObject:item];
    item.itemDate = [NSDate date];
    item.itemName = @"";
    item.price = @0;
    item.qty = @1;
	item.order = [item makeOrderString];

	[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];

	NSInteger focusingRow = _currentBudget.expenseItems.count - 1;

    _tableDataSourceArray = [self loadBudgetFromDB];
	[self.tableView reloadData];

    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        if (focus) {
            A3ExpenseListItemCell *cell = (A3ExpenseListItemCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:focusingRow inSection:0]];
            [cell.nameTextField becomeFirstResponder];
        }
    }];
//    [self.tableView beginUpdates];
//    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_tableDataSourceArray.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
//    [self.tableView endUpdates];
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

	[self moreMenuDismissAction:[[self.view gestureRecognizers] lastObject] ];
	_isShowMoreMenu = NO;
}

- (void)moreMenuDismissAction:(UITapGestureRecognizer *)gestureRecognizer {
	[self rightButtonMoreButton];
	[self dismissMoreMenuView:_moreMenuView scrollView:self.tableView];
	[self.view removeGestureRecognizer:gestureRecognizer];
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
	// Popver controller, iPad only.

	[self enableControls:YES];
	_sharePopoverController = nil;
}

- (void) didTapOnTableView:(UIGestureRecognizer *)recognizer {
    CGPoint tapLocation = [recognizer locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:tapLocation];
	FNLOG(@"%ld", (long)indexPath.row);
    
    if (indexPath) {
        FNLOG(@"%@", NSStringFromCGPoint(tapLocation));
        
        A3ExpenseListItemCell *aCell = (A3ExpenseListItemCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        
        if (tapLocation.x < _sep1View.frame.origin.x) {
            [aCell.nameTextField becomeFirstResponder];
        } else if ( tapLocation.x > _sep1View.frame.origin.x && tapLocation.x < _sep2View.frame.origin.x) {
            [aCell.priceTextField becomeFirstResponder];
        } else if ( tapLocation.x > _sep2View.frame.origin.x && tapLocation.x < _sep3View.frame.origin.x) {
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
    [self saveCurrentBudgetToHistory];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:A3ExpenseListIsAddBudgetCanceledByUser];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // 초기화.
    _currentBudget = nil;
    _tableDataSourceArray = nil;
    [self setCurrentBudgetId:nil];
    [self reloadBudgetDataWithAnimation:YES];
    [self moveToAddBudgetIfBudgetNotExistWithDelay:1.0];
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
    _isAutoMovingAddBudgetView = NO;
    
    A3ExpenseListAddBudgetViewController *viewController = [[A3ExpenseListAddBudgetViewController alloc] initWithStyle:UITableViewStyleGrouped
                                                                                                 withExpenseListBudget:_currentBudget];
    viewController.delegate = self;
    
    if ( IS_IPHONE ) {
        UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:viewController];
        [self presentViewController:navCtrl animated:YES completion:^{
            [viewController showKeyboard];
        }];
        
    } else {
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

	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", @"Done")
																			  style:UIBarButtonItemStylePlain
																			 target:self
																			 action:@selector(doneButtonAction:)];
	_isShowMoreMenu = YES;
	_moreMenuButtons = @[self.shareButton, self.addNewButton, [self historyButton:NULL]];
	[self enableMoreMenuButtons];
	_moreMenuView = [self presentMoreMenuWithButtons:_moreMenuButtons tableView:self.tableView];
}

- (void)addItemButtonAction:(id)sender
{
    _currentBudget.updateDate = [NSDate date];
    
    ExpenseListItem *item = [ExpenseListItem MR_createEntity];
    [_currentBudget addExpenseItemsObject:item];
	item.order = [item makeOrderString];

	[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
    
    _currentBudget = [ExpenseListBudget MR_findFirstByAttribute:@"budgetId" withValue:[self currentBudgetId]];
    
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
//        item.itemDate = nil;
//        item.itemName = nil;
//        item.price = nil;
//        item.qty = nil;
//        aCell.nameTextField.text = @"";
//        aCell.priceTextField.text = @"";
//        aCell.qtyTextField.text = @"";
//        aCell.subTotalLabel.text = @"";
//        aCell.priceTextField.placeholder = @"";
//        aCell.qtyTextField.placeholder = @"";
        item.itemDate = [NSDate date];
        item.itemName = @"";
        item.price = @0;
        item.qty = @1;
        aCell.nameTextField.text = @"";
        aCell.priceTextField.text = [self.priceNumberFormatter stringFromNumber:@0];
        aCell.qtyTextField.text = @"1";
        aCell.subTotalLabel.text = [self.priceNumberFormatter stringFromNumber:@0];
        aCell.priceTextField.placeholder = @"";
        aCell.qtyTextField.placeholder = @"";
    }
    else {
        // 입력 포커스 후
        // price * qty 계산
        item.subTotal = @(item.price.floatValue * item.qty.floatValue);
        aCell.subTotalLabel.text = [self.priceNumberFormatter stringFromNumber:item.subTotal];
        
        
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
                
                nextCell.priceTextField.text = [self.priceNumberFormatter stringFromNumber:nextItem.price];
                NSNumberFormatter *formatter = [NSNumberFormatter new];
                [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
                nextCell.qtyTextField.text = [formatter stringFromNumber:nextItem.qty];
                nextCell.subTotalLabel.text = [self.priceNumberFormatter stringFromNumber:@(nextItem.price.floatValue * nextItem.qty.floatValue)];
            }
        }
    }
}

- (NSMutableArray *)loadBudgetFromDB
{
	FNLOG();
    NSArray *result = nil;

    if (_currentBudget) {
		// Delete !hasData rows and recreate it with required number of rows
		for (ExpenseListItem *item in _currentBudget.expenseItems) {
			if (![item.hasData boolValue]) {
				[item MR_deleteEntity];
			}
		}

		NSInteger minimumNumberOfRows = IS_IPHONE ? kDefaultItemCount_iPhone : kDefaultItemCount_iPad;

		if ([_currentBudget.expenseItems count] < minimumNumberOfRows) {
			NSUInteger leakCount = minimumNumberOfRows - [_currentBudget.expenseItems count];

			for (NSInteger idx = 0; idx < leakCount; idx++) {
				ExpenseListItem *item = [ExpenseListItem MR_createEntity];
				item.order = [item makeOrderString];
				[_currentBudget addExpenseItemsObject:item];
			}
		}
		[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];

		NSSortDescriptor *sortByOrder = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
		result = [_currentBudget.expenseItems sortedArrayUsingDescriptors:@[sortByOrder]];
	};
    
    return [NSMutableArray arrayWithArray:result];
}

- (void)setAddItemButtonPosition
{
    CGRect rect = _addItemButton.frame;
    if (IS_IPHONE) {
        rect.origin.x = 1.0;//self.view.frame.size.width/100.0 * (17.0/320.0*100);
    } else {
        rect.origin.x = 14;//self.view.frame.size.width/100.0 * (17.0/320.0*100);
    }
    rect.origin.y = self.tableView.contentSize.height;
    rect.size.width = 44.0;
    rect.size.height = 44.0;
    _addItemButton.frame = rect;
}

- (void)expandContentSizeForAddItem
{
    UIEdgeInsets contentInset = self.tableView.contentInset;
    NSLog(@"bottom : %f", contentInset.bottom);
    contentInset.bottom = contentInset.bottom + 44.0;
    self.tableView.contentInset = contentInset;
}

-(void)calculateAndDisplayResultWithAnimation:(BOOL)animation
{
    // 전체 사용금액 계산.
    float usedBudget = 0.0;
    for (ExpenseListItem *item in _tableDataSourceArray) {
        usedBudget += item.price.floatValue * item.qty.floatValue;
    }
    _currentBudget.usedAmount = @(usedBudget);
    
    // 헤더뷰 결과 반영.
    [self.headerView setResult:_currentBudget withAnimation:animation];
    // 현재 상태 저장.
    [self saveCurrentBudget];
}

-(void)reloadBudgetDataWithAnimation:(BOOL)animation
{
    // 데이터 갱신.
    _currentBudget = [ExpenseListBudget MR_findFirstByAttribute:@"budgetId" withValue:[self currentBudgetId]];
    
    if (!_currentBudget) {
        _currentBudget = [ExpenseListBudget MR_createEntity];
        _currentBudget.budgetId = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]];
        
        int defaultCount = 1;
        
        if (IS_IPHONE) {
            defaultCount = kDefaultItemCount_iPhone;
        }
        else {
            defaultCount = kDefaultItemCount_iPad;
        }
        
        for (NSInteger i = 0; i < defaultCount; i++) {
            ExpenseListItem *item = [ExpenseListItem MR_createEntity];
			item.order = [item makeOrderString];
            [_currentBudget addExpenseItemsObject:item];
            if (i == 0) {
                item.itemDate = [NSDate date];
                item.itemName = @"";
                item.price = @0;
                item.qty = @1;
                item.subTotal = @0;
            }
        }
        
        [self setCurrentBudgetId:_currentBudget.budgetId];
    }
    
    // 계산 & 화면 갱신.
    [self calculateAndDisplayResultWithAnimation:animation];
    _tableDataSourceArray = [self loadBudgetFromDB];
    [self.tableView reloadData];
	[self enableControls:YES];
}

- (void)reloadBudgetDataAndRemoveEmptyItem {
    _currentBudget = [ExpenseListBudget MR_findFirstByAttribute:@"budgetId" withValue:[self currentBudgetId]];

    if (_currentBudget) {
		_tableDataSourceArray = [self loadBudgetFromDB];
    }
	[self reloadBudgetDataWithAnimation:NO];
}

#pragma mark Save Related

- (void)saveCurrentBudget
{
	[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];

    FNLOG(@"History count : %ld", (long)[ExpenseListHistory MR_countOfEntities]);
    FNLOG(@"Budget count : %ld", (long)[ExpenseListBudget MR_countOfEntities]);
}

- (void)saveCurrentBudgetToHistory
{
    NSDate * updateDate = [NSDate date];

    ExpenseListHistory * history = [ExpenseListHistory MR_findFirstByAttribute:@"budgetData" withValue:_currentBudget];

    if (!history) {
        history = [ExpenseListHistory MR_createEntity];
        history.budgetData = _currentBudget;
        history.updateDate = updateDate;
        _currentBudget.expenseHistory = history;
    }
    
    if (history) {
        history.updateDate = updateDate;
    }

	[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];

    FNLOG(@"History count : %ld", (long)[ExpenseListHistory MR_countOfEntities]);
    FNLOG(@"Budget count : %ld", (long)[ExpenseListBudget MR_countOfEntities]);
}

#pragma mark - misc

- (void)moveToAddBudgetIfBudgetNotExistWithDelay:(CGFloat)delay {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"ExpenseList"]) {
        return;
    }
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:A3ExpenseListIsAddBudgetCanceledByUser]) {
        return;
    }
    
    // 버젯이 없는 경우 이동한다.
    if (!_currentBudget || _currentBudget.category==nil) {
        [self performSelector:@selector(moveToAddBudgetViewController) withObject:nil afterDelay:delay];
        _isAutoMovingAddBudgetView = YES;
    }
}

-(void)scrollToTopOfTableView {
//    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
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

- (UITableViewCell *)cellIdenticalToCellAtIndexPath:(NSIndexPath *)indexPath forDragTableViewController:(ATSDragToReorderTableViewController *)dragTableViewController {
	A3ExpenseListItemCell *cell = [[A3ExpenseListItemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ExpenseListMainCellIdentifier];
	[self setupCell:cell atIndexPath:indexPath];

	return cell;
}

- (BOOL)dragTableViewController:(ATSDragToReorderTableViewController *)dragTableViewController shouldHideDraggableIndicatorForDraggingToRow:(NSIndexPath *)destinationIndexPath {
	return NO;
}

- (void)setupCell:(A3ExpenseListItemCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	ExpenseListItem *item = [_tableDataSourceArray objectAtIndex:indexPath.row];
	cell.delegate = self;

	if ([item.hasData boolValue] || indexPath.row == 0) {    // kjh 추후에 변경하도록
		cell.nameTextField.text = item.itemName;
		cell.priceTextField.text = [self.priceNumberFormatter stringFromNumber:item.price];
		cell.qtyTextField.text = item.qty.stringValue;
		cell.subTotalLabel.text = [self.priceNumberFormatter stringFromNumber:@(item.price.floatValue * item.qty.floatValue)];
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
		[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];

        [self reloadBudgetDataWithAnimation:YES];
    }
    else {
        ExpenseListItem *aItem = _tableDataSourceArray[indexPath.row];
        aItem.itemDate = nil;
        aItem.itemName = nil;
        aItem.price = nil;
        aItem.qty = nil;
        aItem.subTotal = nil;
        aItem.hasData = @(NO);
		[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
        
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
			[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
        }
        
        [self reloadBudgetDataWithAnimation:YES];
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

#pragma mark - BudgetSetting Delegate

- (void)setExpenseBudgetDataFor:(ExpenseListBudget *)aBudget
{
    _currentBudget = aBudget;
    
    if (_currentBudget) {
        [self setCurrentBudgetId:_currentBudget.budgetId];
    }
    
    [self reloadBudgetDataWithAnimation:YES];
}

#pragma mark History Delegate

- (BOOL)isAddedBudged:(ExpenseListBudget *)aBudget{
    if (aBudget.category) {
        return YES;
    }
    
    return NO;
}

-(void)didSelectBudgetHistory:(ExpenseListBudget *)aBudget
{
    // 현재 화면의 데이터 저장, 입력된 데이터가 없는 경우는 제외.
    NSSet *filtteredSet = [_currentBudget.expenseItems filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"hasData == YES"]];
    if ([filtteredSet count] == 0 && ![self isAddedBudged:_currentBudget]) {
        [ExpenseListItem MR_deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"budget == %@", _currentBudget]];
        [_currentBudget MR_deleteEntity];
        _currentBudget = nil;
    }
    else if ([filtteredSet count] > 0 || [self isAddedBudged:_currentBudget]) {
        // 편집중이던 데이터는 히스토리에 저장.
        [self saveCurrentBudgetToHistory];
    }

    // deepcopy 형태로 복원. 기존 히스토리를 건드리지 않기 위함.
    //_currentBudget = aBudget;
    _currentBudget = [ExpenseListBudget MR_createEntity];
    _currentBudget.budgetId = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]];
    _currentBudget.category = aBudget.category;
    _currentBudget.date = aBudget.date;
    _currentBudget.location = aBudget.location;
    _currentBudget.notes = aBudget.notes;
    _currentBudget.paymentType = aBudget.paymentType;
    _currentBudget.title = aBudget.title;
    _currentBudget.totalAmount = aBudget.totalAmount;
    _currentBudget.updateDate = [NSDate date];
    _currentBudget.usedAmount = aBudget.usedAmount;
    for (ExpenseListItem *item in aBudget.expenseItems) {
        ExpenseListItem *temp = [ExpenseListItem MR_createEntity];
        temp.itemDate = item.itemDate;
        temp.itemName = item.itemName;
        temp.price = item.price;
        temp.qty = item.qty;
        temp.subTotal = item.subTotal;
        temp.hasData = item.hasData;
		temp.order = [item makeOrderString];
        temp.budget = _currentBudget;
    }

    [self setCurrentBudgetId:_currentBudget.budgetId];
    
    _tableDataSourceArray = [self loadBudgetFromDB];
    
    if (_currentBudget) {
        [self setCurrentBudgetId:_currentBudget.budgetId];
    }
    
    [self reloadBudgetDataWithAnimation:YES];
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
        
        aCell.priceTextField.text = [self.priceNumberFormatter stringFromNumber:item.price];
        aCell.qtyTextField.text = item.qty.stringValue;
        aCell.subTotalLabel.text = [self.priceNumberFormatter stringFromNumber:@(item.price.floatValue * item.qty.floatValue)];
    }
    
    _selectedItem = item;
	[self addNumberKeyboardNotificationObservers];
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
		//textField.text = [self.priceNumberFormatter stringFromNumber:item.price];
	}
	else if (textField == aCell.qtyTextField) {
		[self.decimalFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
//		if (![textField.text length]) {
//			textField.text = [self.decimalFormatter stringFromNumber:@0];
//		}
		item.qty = [self.decimalFormatter numberFromString:textField.text];
	}
    
    // price * qty 계산
    item.subTotal = @(item.price.floatValue * item.qty.floatValue);
    aCell.subTotalLabel.text = [self.priceNumberFormatter stringFromNumber:item.subTotal];
    
    // 전체 항목 계산 & 화면(헤더뷰) 반영.
    [self calculateAndDisplayResultWithAnimation:YES];
}

-(void)itemCellTextFieldChanged:(A3ExpenseListItemCell *)aCell textField:(UITextField *)textField
{
//    NSIndexPath *index = [self.tableView indexPathForCell:aCell];
//    ExpenseListItem *item = [_tableDataSourceArray objectAtIndex:index.row];
//    
//	if (textField == aCell.nameTextField) {
//		item.itemName = textField.text;
//	}
//	else if (textField == aCell.priceTextField) {
//		item.price = @([textField.text floatValueEx]);
//		textField.text = [self.priceNumberFormatter stringFromNumber:item.price];
//	}
//	else if (textField == aCell.qtyTextField) {
//		[self.decimalFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
//		if (![textField.text length]) {
//			textField.text = [self.decimalFormatter stringFromNumber:@0];
//		}
//		item.qty = [self.decimalFormatter numberFromString:textField.text];
//	}
//    
//    // price * qty 계산
//    item.subTotal = @(item.price.floatValue * item.qty.floatValue);
//    aCell.subTotalLabel.text = [self.priceNumberFormatter stringFromNumber:item.subTotal];
//    
//    // 전체 항목 계산 & 화면(헤더뷰) 반영.
//    [self calculateAndDisplayResultWithAnimation:YES];
}

-(void)itemCellTextFieldFinished:(A3ExpenseListItemCell *)aCell textField:(UITextField *)textField
{
	[self removeNumberKeyboardNotificationObservers];
    NSIndexPath *index = [self.tableView indexPathForCell:aCell];
    ExpenseListItem *item = [_tableDataSourceArray objectAtIndex:index.row];

	if (textField == aCell.nameTextField) {
		item.itemName = textField.text;
	}
	else if (textField == aCell.priceTextField) {
		item.price = @([textField.text floatValueEx]);
		textField.text = [self.priceNumberFormatter stringFromNumber:item.price];
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
    aCell.subTotalLabel.text = [self.priceNumberFormatter stringFromNumber:item.subTotal];
    
    // 전체 항목 계산 & 화면(헤더뷰) 반영.
    [self calculateAndDisplayResultWithAnimation:YES];

    // 유효성 체크, 유효하지 않은 아이템에 기본값 부여.
    if ([self isEmptyItemRow:item]) {
        // 아무 입력이 없었던 경우
        // 행에 출력된 초기값을 제거하여 공백 셀을 만든다.
        item.hasData = @(NO);
        
        if ([self isSameFocusingOnItemRow:item toTextField:textField] || index.row==0) {
            if (textField == [self firstResponder]) {
                self.firstResponder = nil;
            }
            return;
        }

        _selectedItem = nil;
        
        item.itemDate = nil;
        item.itemName = nil;
        item.price = nil;
        item.qty = nil;
        aCell.nameTextField.text = @"";
        aCell.priceTextField.text = @"";
        aCell.qtyTextField.text = @"";
        aCell.subTotalLabel.text = @"";
        aCell.priceTextField.placeholder = @"";
        aCell.qtyTextField.placeholder = @"";
        if (textField == [self firstResponder]) {
            self.firstResponder = nil;
        }
        
        return;
    }

    // 유효한 아이템 구분. itemName 에 빈 스트링 입력.
    item.hasData = @(YES);

    // 예외처리, itemName 편집 종료시, top scroll 적용.
    if (textField == aCell.nameTextField && textField == [self firstResponder]) {
        [self scrollToTopOfTableView];
        self.firstResponder = nil;
    }
    else {
        if (textField == [self firstResponder]) {
            self.firstResponder = nil;
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
    [self reloadBudgetDataWithAnimation:YES];
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
        textField.placeholder = [self.priceNumberFormatter stringFromNumber:@0];
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
