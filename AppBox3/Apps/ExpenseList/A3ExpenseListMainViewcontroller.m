//
//  A3ExpenseListMainViewController.m
//  A3TeamWork
//
//  Created by jeonghwan kim on 13. 11. 21..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3ExpenseListMainViewController.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+A3AppCategory.h"
#import "A3ExpenseListHeaderView.h"
#import "A3ExpenseListItemCell.h"
#import "A3ExpenseListAddBudgetViewController.h"
#import "A3ExpenseListHistoryViewController.h"
//#import "A3ExpenseListColumnSectionCell.h"
#import "A3ExpenseListColumnSectionView.h"
#import "ExpenseListBudget.h"
#import "ExpenseListItem.h"
#import "A3JHSelectTableViewController.h"
#import "A3JHTableViewSelectElement.h"
#import "A3DefaultColorDefines.h"
#import "A3RootViewController_iPad.h"
#import "A3AppDelegate.h"
#import "ExpenseListHistory.h"
//#import "UITableViewController+Extension.h"
//#import <objc/runtime.h>

#define kDefaultItemCount_iPhone    9
#define kDefaultItemCount_iPad      18

static BOOL _isAutoMovingAddBudgetView = NO;

@interface A3ExpenseListMainViewController () <UIPopoverControllerDelegate, A3ExpenseBudgetSettingDelegate, A3ExpenseListItemCellDelegate, UINavigationControllerDelegate, A3ExpenseListHistoryDelegate>
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
@property (nonatomic, strong) NSArray *tableDataSourceArray;
@property (nonatomic, strong) NSNumberFormatter *priceNumberformatter;
@property (nonatomic, strong) UIButton *addItemButton;
@property (strong, nonatomic) UIView *topWhitePaddingView;
@end

@implementation A3ExpenseListMainViewController
{
    ExpenseListBudget *_currentBudget;
    ExpenseListItem *_selectedItem;
	BOOL    _isShowMoreMenu;
    UITapGestureRecognizer *_tapGestureRecognizer;
}

#pragma mark - 

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        _isAutoMovingAddBudgetView = NO;
    }
    return self;
}

static NSString *CellIdentifier = @"Cell";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self makeBackButtonEmptyArrow];
	[self leftBarButtonAppsButton];
    [self registerContentSizeCategoryDidChangeNotification];
    
    self.title = @"Expense List";
    
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
    [self.tableView registerClass:[A3ExpenseListItemCell class] forCellReuseIdentifier:CellIdentifier];
    // 테이블 뷰 탭 제스쳐.
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnTableView:)];
    [self.tableView addGestureRecognizer:_tapGestureRecognizer];
    
    _columnSectionView = [[A3ExpenseListColumnSectionView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 45.0)];

    if (IS_IPHONE) {
        [self rightButtonMoreButton];
        self.tableView.separatorInset = UIEdgeInsetsMake(0, 15.0, 0, 0);
    }
    else {
        self.navigationItem.hidesBackButton = YES;
        self.tableView.separatorInset = UIEdgeInsetsMake(0, 28.0, 0, 0);
        
        UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"add06"]
                                                                style:UIBarButtonItemStylePlain
                                                               target:self
                                                               action:@selector(addNewButtonAction:)];
        UIBarButtonItem *history = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"history"]
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(historyButtonAction:)];
        UIBarButtonItem *share = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"share"]
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(shareButtonAction:)];
        
        self.navigationItem.rightBarButtonItems = @[history, add, share];
    }
    
    
    [self reloadBudgetDataAndRemoveEmptyItem];
    [self setupConstraintLayout];
    [self setupTopWhitePaddingView];
    [self expandContentSizeForAddItem];
    [self moveToAddBudgetIfBudgetNotExistWithDelay:1.0];
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
        [_headerView.detailInfoButton addTarget:self action:@selector(detailInfoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _headerView;
}

-(void)setCurrentBudgetId:(NSString *)currentBudgetId {
    [[NSUserDefaults standardUserDefaults] setObject:currentBudgetId forKey:key_currentBudgetId];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)setupConstraintLayout {
//    CGFloat rate = 0.0;
//    CGRect rect = _sep1View.frame;
//    if ( IS_IPAD ) {
//        rate = 344.0 / 705.0 * 100.0;
//    } else {
//        rate = 147.0 / 320.0 * 100.0;
//    }
//    rect.origin.x = rate;
//    rect.origin.y = 0.0;
//    rect.size.width = 1.0;
//    rect.size.height = self.view.frame.size.height;
//    _sep1View.frame = rect;

    
    
//    [_sep1View makeConstraints:^(MASConstraintMaker *make) {
//        CGFloat rate = 0.0;
//        if ( IS_IPAD ) {
//            rate = 344.0 / 705.0 * 100.0;
//        } else {
//            rate = 147.0 / 320.0 * 100.0;
//        }
//        
//        _sep1Const = make.leading.equalTo(@(self.view.frame.size.width / 100.0 * rate));
//        make.top.equalTo(@0);
//        make.width.equalTo(@1);
//        make.bottom.equalTo(@800);
//    }];
    
//
//    [_sep2View makeConstraints:^(MASConstraintMaker *make) {
//        CGFloat rate = 0.0;
//        if ( IS_IPAD ) {
//            rate = 474.0 / 705.0 * 100.0;
//        } else {
//            rate = 217.0 / 320.0 * 100.0;
//        }
//        
//        _sep2Const = make.leading.equalTo(@(self.view.frame.size.width / 100.0 * rate));
//        make.top.equalTo(self.view.top);
//        make.width.equalTo(@1);
//        make.height.equalTo(self.view.height);
//    }];
//    [_sep3View makeConstraints:^(MASConstraintMaker *make) {
//        
//        CGFloat rate = 0.0;
//        if ( IS_IPAD ) {
//            rate = 563.0 / 705.0 * 100.0;
//        } else {
//            rate = 251.0 / 320.0 * 100.0;
//        }
//        
//        _sep3Const = make.leading.equalTo(@(self.view.frame.size.width / 100.0 * rate));
//        make.top.equalTo(self.view.top);
//        make.width.equalTo(@1);
//        make.height.equalTo(self.view.height);
//    }];
}

-(NSString *)currentBudgetId {
    return [[NSUserDefaults standardUserDefaults] objectForKey:key_currentBudgetId];
}

- (void)appsButtonAction:(UIBarButtonItem *)barButtonItem {
	[self clearEverything];

	[super appsButtonAction:barButtonItem];
}

- (NSNumberFormatter *)priceNumberformatter
{
    if (!_priceNumberformatter) {
        _priceNumberformatter = [NSNumberFormatter new];
        [_priceNumberformatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        if (IS_IPHONE) {
            _priceNumberformatter.currencySymbol = @"";
        }
    }
    
    return _priceNumberformatter;
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
	@autoreleasepool {
        [self clearEverything];
	}
}

- (void)addItemWithFocus:(BOOL)focus
{
    ExpenseListItem *item = [ExpenseListItem MR_createEntity];
    [_currentBudget addExpenseItemsObject:item];
    item.num = @(_tableDataSourceArray.count);
    item.itemDate = [NSDate date];
    item.itemName = @"";
    item.price = @0;
    item.qty = @1;

	[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
    _tableDataSourceArray = [self loadBudgetFromDB];

    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        if (focus) {
            A3ExpenseListItemCell *cell = (A3ExpenseListItemCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_tableDataSourceArray.count-1 inSection:0]];
            [cell.nameTextField becomeFirstResponder];
        }
    }];
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_tableDataSourceArray.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
    [CATransaction commit];
}

- (void)clearEverything {
	[self dismissMoreMenu];
	[self.firstResponder resignFirstResponder];
	[self setFirstResponder:nil];
}

- (void)dismissMoreMenu {
	if ( !_isShowMoreMenu || IS_IPAD ) return;

	[self moreMenuDismissAction:[[self.view gestureRecognizers] lastObject] ];
	_isShowMoreMenu = NO;
}

- (void)moreMenuDismissAction:(UITapGestureRecognizer *)gestureRecognizer {
	@autoreleasepool {
		[self rightButtonMoreButton];
		[self dismissMoreMenuView:_moreMenuView scrollView:self.tableView];
		[self.view removeGestureRecognizer:gestureRecognizer];
	}
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
	// Popver controller, iPad only.
    
	[self.navigationItem.rightBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem *buttonItem, NSUInteger idx, BOOL *stop) {
		[buttonItem setEnabled:YES];
	}];
	_sharePopoverController = nil;
}

-(void) didTapOnTableView:(UIGestureRecognizer *)recognizer {
    CGPoint tapLocation = [recognizer locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:tapLocation];
    
    if (indexPath) {
        NSLog(@"%@", NSStringFromCGPoint(tapLocation));
        
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
        _sharePopoverController.delegate = self;
        [self.navigationItem.rightBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem *buttonItem, NSUInteger idx, BOOL *stop) {
            [buttonItem setEnabled:NO];
        }];
        
        _headerView.detailInfoButton.enabled = NO;
    }
    
    A3ExpenseListHistoryViewController *viewController = [[A3ExpenseListHistoryViewController alloc] initWithStyle:UITableViewStylePlain];
    viewController.delegate = self;
    
    [self presentSubViewController:viewController];
}

- (void)shareButtonAction:(id)sender {
	@autoreleasepool {
		[self clearEverything];
        
        if (_isAutoMovingAddBudgetView) {
            return;
        }
        
        _sharePopoverController = [self presentActivityViewControllerWithActivityItems:@[@"test"] fromBarButtonItem:sender];
        if (IS_IPAD) {
            _sharePopoverController.delegate = self;
            [self.navigationItem.rightBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem *buttonItem, NSUInteger idx, BOOL *stop) {
                [buttonItem setEnabled:NO];
            }];
        }
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
    @autoreleasepool {
        [self.firstResponder resignFirstResponder];
		[self setFirstResponder:nil];
        
        if (_isAutoMovingAddBudgetView) {
            return;
        }
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                                  style:UIBarButtonItemStylePlain
                                                                                 target:self
                                                                                 action:@selector(doneButtonAction:)];
        _isShowMoreMenu = YES;
        _moreMenuButtons = @[self.shareButton, self.addNewButton, [self historyButton:NULL]];
        [self disableMoreButtonsIfBugdetNotExist];
        _moreMenuView = [self presentMoreMenuWithButtons:_moreMenuButtons tableView:self.tableView];
    };
}

- (void)addItemButtonAction:(id)sender
{
    _currentBudget.updateDate = [NSDate date];
    
    ExpenseListItem *item = [ExpenseListItem MR_createEntity];
    [_currentBudget addExpenseItemsObject:item];

	[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
    
    _currentBudget = [ExpenseListBudget MR_findFirstByAttribute:@"budgetId" withValue:[self currentBudgetId]];
    
    _tableDataSourceArray = [self loadBudgetFromDB];
    
    [self.tableView reloadData];
    [self setAddItemButtonPosition];
    //[self setExpandContentSizeForAddItem];
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
        aCell.priceTextField.text = [self.priceNumberformatter stringFromNumber:@0];
        aCell.qtyTextField.text = @"1";
        aCell.subTotalLabel.text = [self.priceNumberformatter stringFromNumber:@0];
        aCell.priceTextField.placeholder = @"";
        aCell.qtyTextField.placeholder = @"";
    }
    else {
        // 입력 포커스 후
        // price * qty 계산
        item.subTotal = @(item.price.floatValue * item.qty.floatValue);
        aCell.subTotalLabel.text = [self.priceNumberformatter stringFromNumber:item.subTotal];
        
        
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
                
                nextCell.priceTextField.text = [self.priceNumberformatter stringFromNumber:nextItem.price];
                NSNumberFormatter *formatter = [NSNumberFormatter new];
                [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
                nextCell.qtyTextField.text = [formatter stringFromNumber:nextItem.qty];
                nextCell.subTotalLabel.text = [self.priceNumberformatter stringFromNumber:@(nextItem.price.floatValue * nextItem.qty.floatValue)];
            }
        }
    }
}

-(NSArray *)loadBudgetFromDB
{
    NSArray *result = nil;

    if (_currentBudget) {
        [_currentBudget.expenseItems sortedArrayUsingDescriptors:nil];
        
        result = [[_currentBudget.expenseItems allObjects] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            ExpenseListItem *item1 = (ExpenseListItem *)obj1;
            ExpenseListItem *item2 = (ExpenseListItem *)obj2;
            //return [item1.itemDate compare:item2.itemDate];
            return [item1.num compare:item2.num];
        }];
        
        
        // 시뮬레이터에서 , iPhone->iPad, 기본 아이템 카운트가 안 맞는 경우가 있음.
        if (IS_IPAD && result.count < kDefaultItemCount_iPad) {
            NSUInteger leakCount = kDefaultItemCount_iPad - result.count;
            NSMutableArray * tempArray = [NSMutableArray arrayWithArray:result];
            
            for (int i=0; i < leakCount; i++) {
                ExpenseListItem *item = [ExpenseListItem MR_createEntity];
                [tempArray addObject:item];
                [_currentBudget addExpenseItemsObject:item];
            }
            
            result = tempArray;
        }
    };
    
    return result;
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
        
        if (IS_IPHONE) {
            for (UIBarButtonItem *aItem in _moreMenuButtons) {
                aItem.enabled = NO;
            }
        }
        else {
            for (UIBarButtonItem *aItem in self.navigationItem.rightBarButtonItems) {
                aItem.enabled = NO;
            }
        }
        
        int defaultCount = 1;
        
        if (IS_IPHONE) {
            defaultCount = kDefaultItemCount_iPhone;
        }
        else {
            defaultCount = kDefaultItemCount_iPad;
        }
        
        for (int i = 0; i < defaultCount; i++) {
            ExpenseListItem *item = [ExpenseListItem MR_createEntity];
            item.num = @(i);
            [_currentBudget addExpenseItemsObject:item];
            if (i==0) {
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
    [self disableMoreButtonsIfBugdetNotExist];
}

-(void)reloadBudgetDataAndRemoveEmptyItem {
    
    _currentBudget = [ExpenseListBudget MR_findFirstByAttribute:@"budgetId" withValue:[self currentBudgetId]];
    
    if (!_currentBudget) {
        [self reloadBudgetDataWithAnimation:NO];
        return;
        
    } else {
        _tableDataSourceArray = [self loadBudgetFromDB];
        
        // 값이 있는 데이터를 상위로.
        NSMutableArray * valideValueArray1 = [NSMutableArray new];
        NSMutableArray * noDateValueArray2 = [NSMutableArray new];
        
        
        for (ExpenseListItem * aItem in _tableDataSourceArray) {
            if ([aItem.hasData boolValue]) {
                [valideValueArray1 addObject:aItem];
            }
            else {
                // 유효한 아이템 데이터가 없는 경우, itemDate 를 없애고 순서에서 제외 시킨다.
                aItem.itemDate = nil;
                [noDateValueArray2 addObject:aItem];
            }
        }
        
        // 기록 당시 순서 고려하여 정렬 시작.
        NSMutableArray * result = [NSMutableArray new];
        // 1. 유효한 값 리스트, 순서에 맞춰 정렬 후, 대입.
        [result addObjectsFromArray:[valideValueArray1 sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            ExpenseListItem *item1 = (ExpenseListItem *)obj1;
            ExpenseListItem *item2 = (ExpenseListItem *)obj2;
            
            return [item1.num compare:item2.num];
        }]];
        
        // 2. 유효하지 않은 값 리스트, 대입.
        [result addObjectsFromArray:noDateValueArray2];
        
        // 3. 대입된 아이템들, 순서 재지정.
        for (int i =0 ; i < result.count; i++) {
            ExpenseListItem * aItem = [result objectAtIndex:i];
            if (i==0 && (aItem.itemDate == nil || ![aItem.hasData boolValue])) {
                aItem.itemDate = [NSDate date];   // 0번째 줄에서는 출력이 가능하도록...
                aItem.itemName = @"";
                aItem.price = @0;
                aItem.qty = @1;
            }
            aItem.num = @(i);
        }
        
        _tableDataSourceArray = result;
        
        [self reloadBudgetDataWithAnimation:NO];
    }
}
#pragma mark Save Related
-(void)saveCurrentBudget
{
	[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];

    NSLog(@"History count : %ld", (long)[[ExpenseListHistory MR_findAll] count]);
    NSLog(@"Budget count : %ld", (long)[[ExpenseListBudget MR_findAll] count]);
}

-(void)saveCurrentBudgetToHistory
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

    NSLog(@"History count : %ld", (long)[[ExpenseListHistory MR_findAll] count]);
    NSLog(@"Budget count : %ld", (long)[[ExpenseListBudget MR_findAll] count]);
}

#pragma mark - misc
- (void)disableMoreButtonsIfBugdetNotExist {

    if (IS_IPHONE) {
        // AddNew
        UIButton *aBtn = [_moreMenuButtons objectAtIndex:1];
        if (aBtn) {
            NSSet *filteredSet = [_currentBudget.expenseItems filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"hasData == YES"]];
            aBtn.enabled = [filteredSet count] > 0 ? YES : NO;
        }

        // History
        aBtn = [_moreMenuButtons objectAtIndex:2];
        if (aBtn) {
            NSArray * budgets = [ExpenseListHistory MR_findAll];
            aBtn.enabled = (!budgets || budgets.count == 0) ? NO : YES;
        }

        // Share
        aBtn = [_moreMenuButtons objectAtIndex:0];
        if (aBtn) {
            aBtn.enabled = (!_currentBudget || _currentBudget.category == nil) ? NO : YES;
        }
    }
    else if (IS_IPAD) {
        // AddNew
        UIBarButtonItem *aBtn = [self.navigationItem.rightBarButtonItems objectAtIndex:1];
        if (aBtn) {
            NSSet *filteredSet = [_currentBudget.expenseItems filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"hasData == YES"]];
            aBtn.enabled = [filteredSet count] > 0 ? YES : NO;
        }
        
        // History
        aBtn = [self.navigationItem.rightBarButtonItems objectAtIndex:0];
        if (aBtn) {
            NSArray * budgets = [ExpenseListHistory MR_findAll];
            aBtn.enabled = (!budgets || budgets.count == 0) ? NO : YES;
        }
        
        // Share
        aBtn = [self.navigationItem.rightBarButtonItems objectAtIndex:2];
        if (aBtn) {
            aBtn.enabled = (!_currentBudget || _currentBudget.category == nil) ? NO : YES;
        }
        
        _headerView.detailInfoButton.enabled = YES;
    }
}

- (void)moveToAddBudgetIfBudgetNotExistWithDelay:(CGFloat)delay {
    
    // 입력된 아이템이 있을 경우, 이동하지 않는다.
//    for (ExpenseListItem *item in _tableDataSourceArray) {
//        if (item.itemDate) {
//            return;
//        }
//    }
    // 버젯이 없는 경우 이동한다.
    if (!_currentBudget || _currentBudget.category==nil) {
        [self performSelector:@selector(moveToAddBudgetViewController) withObject:nil afterDelay:delay];
        _isAutoMovingAddBudgetView = YES;
    }
}

-(void)scrollToTopOfTableView {
//    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    if (IS_LANDSCAPE) {
        [UIView beginAnimations:@"KeyboardWillShow" context:nil];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationCurve:7];
        [UIView setAnimationDuration:0.35];
        self.tableView.contentOffset = CGPointMake(0.0, CGPointMake(0.0, -(self.navigationController.navigationBar.bounds.size.height + [[UIApplication sharedApplication] statusBarFrame].size.width)).y);
        [UIView commitAnimations];
    }
    else {
        [UIView beginAnimations:@"KeyboardWillShow" context:nil];
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
    return [_tableDataSourceArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    A3ExpenseListItemCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[A3ExpenseListItemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    ExpenseListItem *item = [_tableDataSourceArray objectAtIndex:indexPath.row];
    cell.delegate = self;

    if ([item.hasData boolValue] || indexPath.row == 0) {    // kjh 추후에 변경하도록
        cell.nameTextField.text = item.itemName;
        cell.priceTextField.text = [self.priceNumberformatter stringFromNumber:item.price];
        cell.qtyTextField.text = item.qty.stringValue;
        cell.subTotalLabel.text = [self.priceNumberformatter stringFromNumber:@(item.price.floatValue * item.qty.floatValue)];
    } else {
        cell.nameTextField.text = @"";
        cell.priceTextField.text = @"";
        cell.qtyTextField.text = @"";
        cell.subTotalLabel.text = @"";
        cell.nameTextField.placeholder = @"";
        cell.priceTextField.placeholder = @"";
        cell.qtyTextField.placeholder = @"";
    }
    
    return cell;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    [_columnSectionView setNeedsDisplay];
    _addItemButton.userInteractionEnabled = _currentBudget == nil ? NO : YES;
    
    return _columnSectionView;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	ExpenseListItem *item = [_tableDataSourceArray objectAtIndex:indexPath.row];
	//if (item.itemDate == nil || ![item.hasData boolValue]) {
    if (![item.hasData boolValue]) {
		return NO;
	}

    return YES;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
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

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return IS_RETINA ? 56.0 : 57.0;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return indexPath.row == 0 ? (IS_RETINA ? 43.5 : 43) : 44.0;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
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

#pragma mark - TableView Elements Delegate

//-(void)selectTableViewController:(A3JHSelectTableViewController *)viewController selectedItemIndex:(NSInteger)index indexPathOrigin:(NSIndexPath *)indexPathOrigin
//{
//    
//}


#pragma mark - Delegate
#pragma mark BudgetSetting Delegate
-(void)setExpenseBudgetDataFor:(ExpenseListBudget *)aBudget
{
//    if (!aBudget) {
//        return;     // 초기화 된 경우, 현재의 상태를 그대로 유지하도록 함.
//    }
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
        temp.num = item.num;
        temp.price = item.price;
        temp.qty = item.qty;
        temp.subTotal = item.subTotal;
        temp.hasData = item.hasData;
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
    [self disableMoreButtonsIfBugdetNotExist];
    NSLog(@"History : %ld", (long)[[ExpenseListHistory MR_findAll] count]);
    NSLog(@"Budget : %ld", (long)[[ExpenseListBudget MR_findAll] count]);
    NSLog(@"Items : %ld", (long)[[ExpenseListItem MR_findAll] count]);
}

#pragma mark - A3ExpenseListItemCell Delegate
-(void)itemCellTextFieldBeginEditing:(A3ExpenseListItemCell *)aCell textField:(UITextField *)textField
{
	[self setFirstResponder:textField];
    [self dismissMoreMenu];
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:aCell];
    ExpenseListItem *item = [_tableDataSourceArray objectAtIndex:indexPath.row];
    if (![item.hasData boolValue] && _selectedItem != item) {
        item.itemDate = [NSDate date];
        item.price = @0;
        item.qty = @1;
        item.subTotal = @0;
        
        aCell.priceTextField.text = [self.priceNumberformatter stringFromNumber:item.price];
        aCell.qtyTextField.text = item.qty.stringValue;
        aCell.subTotalLabel.text = [self.priceNumberformatter stringFromNumber:@(item.price.floatValue * item.qty.floatValue)];
    }
    
    _selectedItem = item;
}

-(void)itemCellTextFieldChanged:(A3ExpenseListItemCell *)aCell textField:(UITextField *)textField
{
//    NSIndexPath *index = [self.tableView indexPathForCell:aCell];
//    ExpenseListItem *item = [_tableDataSourceArray objectAtIndex:index.row];
//    
//    if (textField.text.length==0 && aCell.nameTextField != textField) {
//        textField.text = textField.placeholder;
//    } else {
//        if (textField == aCell.nameTextField) {
//            item.itemName = textField.text;
//        } else if (textField == aCell.priceTextField) {
//            item.price = @(textField.text.floatValue);
//            textField.text = [self.priceNumberformatter stringFromNumber:item.price];
//        } else if (textField == aCell.qtyTextField) {
//            item.qty = @(textField.text.floatValue);
//        }
//        
//        // 입력 포커스 후, 아무 입력도 없었던 경우.
//        if (item.itemName.length==0 && [item.price isEqualToNumber:@0] && [item.qty isEqualToNumber:@1]) {
//            item.itemDate = nil;
//            item.itemName = nil;
//            item.price = nil;
//            item.qty = nil;
//            aCell.nameTextField.text = @"";
//            aCell.priceTextField.text = @"";
//            aCell.qtyTextField.text = @"";
//            aCell.subTotalLabel.text = @"";
//            aCell.priceTextField.placeholder = @"";
//            aCell.qtyTextField.placeholder = @"";
//        }
//    }
}

-(void)itemCellTextFieldFinished:(A3ExpenseListItemCell *)aCell textField:(UITextField *)textField
{
    NSIndexPath *index = [self.tableView indexPathForCell:aCell];
    ExpenseListItem *item = [_tableDataSourceArray objectAtIndex:index.row];
    
    if (textField.text.length==0 && aCell.nameTextField != textField) {
        textField.text = textField.placeholder;
    }
    else {
        if (textField == aCell.nameTextField) {
            item.itemName = textField.text;
        }
        else if (textField == aCell.priceTextField) {
            item.price = @(textField.text.floatValue);
            textField.text = [self.priceNumberformatter stringFromNumber:item.price];
        }
        else if (textField == aCell.qtyTextField) {
            item.qty = @(textField.text.floatValue);
        }
    }
    
    // price * qty 계산
    item.subTotal = @(item.price.floatValue * item.qty.floatValue);
    aCell.subTotalLabel.text = [self.priceNumberformatter stringFromNumber:item.subTotal];
    
    // 전체 항목 계산 & 화면(헤더뷰) 반영.
    [self calculateAndDisplayResultWithAnimation:YES];

    // 유효성 체크, 유효하지 않은 아이템에 기본값 부여.
    if ([self isEmptyItemRow:item]) {
        // 아무 입력이 없었던 경우
        // 행에 출력된 초기값을 제거하여 공백 셀을 만든다.
        item.hasData = @(NO);
        
        if ([self isSameFocusingOnItemRow:item toTextField:textField] || index.row==0) {
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
        self.firstResponder = nil;
        return;
    }

    // 유효한 아이템 구분. itemName 에 빈 스트링 입력.
    item.hasData = @(YES);
    
    // More Button 활성화.
    [self disableMoreButtonsIfBugdetNotExist];
    
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
//    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
//    
//    return indexPath.row < _tableDataSourceArray.count-1 ? YES : NO;
    return YES;
}

-(void)moveUpRowFor:(A3ExpenseListItemCell *)sender textField:(UITextField *)textField
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    indexPath = [NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section];
    
    A3ExpenseListItemCell *cell = (A3ExpenseListItemCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    [cell.nameTextField becomeFirstResponder];
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
        NSNumberFormatter *formatter = [NSNumberFormatter new];
        formatter.numberStyle = NSNumberFormatterCurrencyStyle;
        textField.placeholder = [formatter stringFromNumber:@0];
        aItem.price = @0;
    }
    else {
        textField.placeholder = @"";
        aItem.qty = @0;
    }
}

@end
