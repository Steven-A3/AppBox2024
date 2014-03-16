//
//  A3UnitConverterConvertTableViewController.m
//  A3TeamWork
//
//  Created by kihyunkim on 13. 10. 12..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3UnitConverterConvertTableViewController.h"
#import "A3UnitConverterTabBarController.h"
#import "A3UnitConverterTVActionCell.h"
#import "A3UnitConverterTVEqualCell.h"
#import "A3UnitConverterTVDataCell.h"
#import "A3AppDelegate.h"
#import "A3NumberKeyboardViewController.h"
#import "UIViewController+A3AppCategory.h"
#import "NSMutableArray+A3Sort.h"
#import "NSUserDefaults+A3Defaults.h"
#import "UIViewController+MMDrawerController.h"
#import "NSString+conversion.h"
#import "UIViewController+A3Addition.h"
#import "A3UnitConverterHistoryViewController.h"
#import "A3UnitConverterSelectViewController.h"
#import "UnitItem.h"
#import "UnitFavorite+initialize.h"
#import "UnitConvertItem.h"
#import "UnitConvertItem+initialize.h"
#import "UnitHistory.h"
#import "UnitHistoryItem.h"
#import "A3FractionInputView.h"
#import "TemperatureConveter.h"
#import "FMMoveTableView.h"

#define kInchesPerFeet  (0.3048/0.0254)

@interface A3UnitConverterConvertTableViewController () <UITextFieldDelegate, ATSDragToReorderTableViewControllerDelegate,
		A3UnitSelectViewControllerDelegate, A3UnitConverterFavoriteEditDelegate, A3UnitConverterMenuDelegate,
		UIPopoverControllerDelegate, UIActivityItemSource, FMMoveTableViewDelegate, FMMoveTableViewDataSource>

@property (nonatomic, strong) FMMoveTableView *fmMoveTableView;
@property (nonatomic, strong) NSMutableSet *swipedCells;
@property (nonatomic, strong) NSMutableArray *convertItems;
//@property (nonatomic, strong) NSMutableArray *favorites;
@property (nonatomic, strong) NSMutableDictionary *equalItem;
@property (nonatomic, weak)	UITextField *firstResponder;
@property (nonatomic, strong) NSMutableDictionary *text1Fields;
@property (nonatomic, strong) NSMutableDictionary *text2Fields;
@property (nonatomic, strong) NSArray *moreMenuButtons;
@property (nonatomic, strong) UIView *moreMenuView;
@property (nonatomic, strong) UIPopoverController *sharePopoverController;
//@property (nonatomic, strong) UnitHistory *unitHistory;
@property (nonatomic, strong) A3FractionInputView *fractionInputView;
@property (nonatomic, strong) NSMutableArray *shareTextList;
@property (nonatomic, strong) UIButton *addButton;

@property (nonatomic, strong) NSString *vcTitle;

@property (nonatomic, strong) NSNumber *unitValue;

@end

@implementation A3UnitConverterConvertTableViewController {
    BOOL 		_draggingFirstRow;
	NSUInteger 	_selectedRow;
    BOOL		_isAddingUnit;
    BOOL		_isShowMoreMenu;
    
    BOOL        _isTemperatureMode;
    BOOL        _isFeetInchMode;
    
    BOOL shareItemEnabled;
    BOOL historyItemEnabled;
}

NSString *const A3UnitConverterDataCellID = @"A3UnitConverterDataCell";
NSString *const A3UnitConverterActionCellID = @"A3UnitConverterActionCell";
NSString *const A3UnitConverterEqualCellID = @"A3UnitConverterEqualCell";

- (void)cleanUp{
    _convertItems = nil;
    _equalItem = nil;
	_addButton = nil;
	_text1Fields = nil;
    _text2Fields = nil;
	_moreMenuButtons = nil;
//    _unitHistory = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	_fmMoveTableView = [[FMMoveTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
	_fmMoveTableView.delegate = self;
	_fmMoveTableView.dataSource = self;

	[self.view addSubview:_fmMoveTableView];
	[_fmMoveTableView makeConstraints:^(MASConstraintMaker *make) {
		make.edges.equalTo(self.view);
	}];

	self.vcTitle = self.title;

	[self setupSwipeRecognizers];

	[self makeBackButtonEmptyArrow];

	// Uncomment the following line to preserve selection between presentations.
	// self.clearsSelectionOnViewWillAppear = NO;

	// Uncomment the following line to display an Edit button in the navigation bar for this view controller.
	// self.navigationItem.rightBarButtonItem = self.editButtonItem;

	if (IS_IPHONE) {
//            [self rightButtonMoreButton];
		UIBarButtonItem *share = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"share"] style:UIBarButtonItemStylePlain target:self action:@selector(shareButtonAction:)];
		UIBarButtonItem *history = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"history"] style:UIBarButtonItemStylePlain target:self action:@selector(historyButtonAction:)];

		self.navigationItem.rightBarButtonItems = @[history, share];
	} else {
		UIBarButtonItem *share = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"share"] style:UIBarButtonItemStylePlain target:self action:@selector(shareButtonAction:)];
		UIBarButtonItem *history = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"history"] style:UIBarButtonItemStylePlain target:self action:@selector(historyButtonAction:)];
		UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
		space.width = 24.0;

		self.navigationItem.rightBarButtonItems = @[history, space, share];
	}

	[_fmMoveTableView registerClass:[A3UnitConverterTVDataCell class] forCellReuseIdentifier:A3UnitConverterDataCellID];
	[_fmMoveTableView registerNib:[UINib nibWithNibName:@"A3UnitConverterTVActionCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:A3UnitConverterActionCellID];
	[_fmMoveTableView registerNib:[UINib nibWithNibName:@"A3UnitConverterTVEqualCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:A3UnitConverterEqualCellID];

	_fmMoveTableView.rowHeight = 84.0;
	_fmMoveTableView.separatorColor = [self tableViewSeparatorColor];
	_fmMoveTableView.separatorInset = UIEdgeInsetsMake(0.0, 0.0, -1.0, 0.0);
	_fmMoveTableView.contentInset = UIEdgeInsetsMake(0, 0, 70.0, 0);
	_fmMoveTableView.showsVerticalScrollIndicator = NO;

	_isTemperatureMode = [_unitType.unitTypeName isEqualToString:@"Temperature"];

	[self.decimalFormatter setLocale:[NSLocale currentLocale]];

	[self.view addSubview:self.addButton];

	[self.addButton makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(self.view.centerX);
		make.bottom.equalTo(self.view.bottom).with.offset(-20);
	}];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rightSubViewDismissed:) name:@"A3_Pad_RightSubViewDismissed" object:nil];
}

- (void)rightSubViewDismissed:(NSNotification *)noti
{
    [self enableControls:YES];
}

- (void)enableControls:(BOOL) onoff
{
    UIBarButtonItem *shareItem = self.navigationItem.rightBarButtonItems[2];
    UIBarButtonItem *historyItem = self.navigationItem.rightBarButtonItems[0];
    
    if (onoff) {
        
        self.navigationItem.leftBarButtonItem.enabled = YES;
        shareItem.enabled = shareItemEnabled;
        historyItem.enabled = historyItemEnabled;
        
    }
    else {
        
        shareItemEnabled = shareItem.enabled;
        historyItemEnabled = historyItem.enabled;
        
        self.navigationItem.leftBarButtonItem.enabled = NO;
        shareItem.enabled = NO;
        historyItem.enabled = NO;
    }
    
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

	if ([self isMovingToParentViewController]) {
		A3UnitConverterTabBarController *tabBar = (A3UnitConverterTabBarController *)self.navigationController.tabBarController;
		if ([tabBar.unitTypes containsObject:self.unitType]) {
			NSUInteger vcIdx = [tabBar.unitTypes indexOfObject:self.unitType];
			[[NSUserDefaults standardUserDefaults] setUnitConverterCurrentUnitTap:vcIdx];
		}
		[self registerContentSizeCategoryDidChangeNotification];
	}
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.title = self.vcTitle;
    
    // left navi item보이기
    [self showLeftNaviItems];
    
    [self refreshRightBarItems];
    
    [_fmMoveTableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self clearEverything];
}

- (void)viewWillLayoutSubviews {
	[super viewWillLayoutSubviews];
    
	if (IS_IPAD) {
        [self showLeftNaviItems];
	}
}

- (void)contentSizeDidChange:(NSNotification *)notification {
	[_fmMoveTableView reloadData];
}

- (void)dealloc {
	[self removeObserver];
}

- (void)refreshRightBarItems
{
    UIBarButtonItem *historyItem = self.navigationItem.rightBarButtonItems[0];
    
    // history
    NSArray *histories = [UnitHistory MR_findAll];
    if (histories.count == 0) {
        historyItem.enabled = NO;
    } else {
        historyItem.enabled = YES;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)clearEverything {
	@autoreleasepool {
		[_firstResponder resignFirstResponder];
		[self dismissMoreMenu];
	}
}

- (void)showLeftNaviItems
{
    // 현재 more탭바인지 여부 체크
    if (self.navigationController == self.tabBarController.moreNavigationController) {
        self.navigationItem.leftItemsSupplementBackButton = YES;
        // more 탭바

        self.navigationItem.hidesBackButton = NO;
        
        if (IS_IPAD) {
            if (IS_LANDSCAPE) {
                self.navigationItem.leftBarButtonItem = nil;
            }
            else {
                UIBarButtonItem *appsItem = [[UIBarButtonItem alloc] initWithTitle:@"Apps" style:UIBarButtonItemStylePlain target:self action:@selector(appsButtonAction)];
                self.navigationItem.leftBarButtonItem = appsItem;
            }
        }
        else {
            UIBarButtonItem *appsItem = [[UIBarButtonItem alloc] initWithTitle:@"Apps" style:UIBarButtonItemStylePlain target:self action:@selector(appsButtonAction)];
            self.navigationItem.leftBarButtonItem = appsItem;
        }
    } else {
        // 아님
        [self makeBackButtonEmptyArrow];
        self.navigationItem.hidesBackButton = YES;
        
		[self leftBarButtonAppsButton];
    }
}

- (void)appsButtonAction {
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

- (void)moreButtonAction:(UIButton *)button {
	[_firstResponder resignFirstResponder];

	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonAction:)];

	_moreMenuButtons = @[self.shareButton, [self historyButton:NULL]];
	_moreMenuView = [self presentMoreMenuWithButtons:_moreMenuButtons tableView:_fmMoveTableView];
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

	[self rightButtonMoreButton];
	[self dismissMoreMenuView:_moreMenuView tableView:_fmMoveTableView];
	[self.view removeGestureRecognizer:gestureRecognizer];
}

- (void)shareButtonAction:(id)sender {
	[self clearEverything];

	[self shareAll:sender];
}

- (void)historyButtonAction:(UIButton *)button {
		[self clearEverything];
        
        A3UnitConverterHistoryViewController *viewController = [[A3UnitConverterHistoryViewController alloc] initWithNibName:nil bundle:nil];
		[self presentSubViewController:viewController];
        
        _unitValue = nil;
        
        if (IS_IPAD) {
            [self enableControls:NO];
        }
}

- (NSMutableArray *)convertItems {
	if (nil == _convertItems) {
        
        // UnitFavorite 초기화
        if ([[UnitFavorite MR_numberOfEntities] isEqualToNumber:@0 ]) {
            [UnitFavorite reset];
        }
        
        // UnitConvertItem 초기화
        if ([[UnitConvertItem MR_numberOfEntities] isEqualToNumber:@0 ]) {
            [UnitConvertItem reset];
        }
        
        _convertItems = [NSMutableArray arrayWithArray:[UnitConvertItem MR_findAllSortedBy:@"order" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"item.type==%@", _unitType]]];
        
		[self addEqualAndPlus];
	}
	return _convertItems;
}

/*
- (NSMutableArray *)favorites {
	if (nil == _favorites) {
        if ([[UnitFavorite MR_numberOfEntities] isEqualToNumber:@0 ]) {
            [UnitFavorite reset];
        }
        _favorites = [NSMutableArray arrayWithArray:[UnitFavorite MR_findByAttribute:@"type" withValue:_unitType andOrderBy:@"order" ascending:YES]];
        
		[self addEqualAndPlus];
	}
	return _favorites;
}
 */

- (void)addEqualAndPlus {
	[_convertItems insertObjectToSortedArray:self.equalItem atIndex:1];
}

- (NSMutableDictionary *)equalItem {
	if (!_equalItem) {
		_equalItem = [NSMutableDictionary dictionaryWithDictionary:@{@"title":@"=",@"order":@""}];
	}
	return _equalItem;
}

- (UIButton *)addButton
{
    if (!_addButton) {
        _addButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_addButton setImage:[UIImage imageNamed:@"add01"] forState:UIControlStateNormal];
        _addButton.frame = CGRectMake(0, 0, 44, 44);
        [_addButton addTarget:self action:@selector(addUnitAction) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _addButton;
}

/*
- (UnitHistory *)unitHistory {
	if (!_unitHistory) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"source.type == %@", _unitType];
        NSArray *histories = [UnitHistory MR_findAllSortedBy:@"date" ascending:NO withPredicate:predicate];
        if (histories.count > 0) {
            _unitHistory = histories[0];
        }
        else {
            [self putHistoryWithValue:@1.0];
        }
	}
	return _unitHistory;
}
 */

- (NSNumber *)unitValue {
    if (!_unitValue) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"source.type == %@", _unitType];
        NSArray *histories = [UnitHistory MR_findAllSortedBy:@"date" ascending:NO withPredicate:predicate];
        if (histories.count > 0) {
            UnitHistory *last = histories[0];
            _unitValue = @(last.value.floatValue);
        }
        else {
            _unitValue = @1.0;
        }
    }
    return _unitValue;
}

- (NSMutableDictionary *)text1Fields {
	if (!_text1Fields) {
		_text1Fields = [NSMutableDictionary new];
	}
	return _text1Fields;
}

- (NSMutableDictionary *)text2Fields {
	if (!_text2Fields) {
		_text2Fields = [NSMutableDictionary new];
	}
	return _text2Fields;
}

- (A3FractionInputView *) fractionInputView
{
    if (!_fractionInputView) {
        _fractionInputView = [[A3FractionInputView alloc] initWithFrame:CGRectZero];
        _fractionInputView.numField.delegate = self;
        _fractionInputView.denumField.delegate = self;
    }

    return _fractionInputView;
}

- (void)addUnitAction {
	@autoreleasepool {
		if ([_firstResponder isFirstResponder]) {
			[_firstResponder resignFirstResponder];
			return;
		}
        
		if ([self.swipedCells.allObjects count]) {
			[self unSwipeAll];
			return;
		}
        
        _isAddingUnit = YES;
        UIViewController *viewController = [self unitAddViewController];
        
        [self presentSubViewController:viewController];
	}
}

- (A3UnitConverterSelectViewController *)unitAddViewController {
    A3UnitConverterSelectViewController *viewController = [[A3UnitConverterSelectViewController alloc] initWithNibName:nil bundle:nil];
    viewController.editingDelegate = self;
    viewController.delegate = self;
    viewController.shouldPopViewController = NO;    // modal
    
    // toss unit data
    viewController.convertItems = self.convertItems;
    viewController.selectedItem = nil;
    viewController.favorites = [NSMutableArray arrayWithArray:[UnitFavorite MR_findByAttribute:@"item.type" withValue:_unitType andOrderBy:@"order" ascending:YES]];
    viewController.allData = [NSMutableArray arrayWithArray:[UnitItem MR_findByAttribute:@"type" withValue:_unitType andOrderBy:@"unitName" ascending:YES]];
    
	return viewController;
}

- (A3UnitConverterSelectViewController *)unitSelectViewControllerWithSelectedUnit:(NSInteger)selectedIndex {
    
	A3UnitConverterSelectViewController *viewController = [[A3UnitConverterSelectViewController alloc] initWithNibName:nil bundle:nil];
	viewController.delegate = self;
    viewController.editingDelegate = self;
    viewController.hidesBottomBarWhenPushed = YES;
	if (selectedIndex >= 0 && selectedIndex <= ([_convertItems count] - 1) ) {
		UnitConvertItem *selectedItem = _convertItems[selectedIndex];
		viewController.placeHolder = selectedItem.item.unitName;
        
        // toss unit data
        viewController.selectedItem = selectedItem;
        viewController.favorites = [NSMutableArray arrayWithArray:[UnitFavorite MR_findByAttribute:@"item.type" withValue:_unitType andOrderBy:@"order" ascending:YES]];
        viewController.allData = [NSMutableArray arrayWithArray:[UnitItem MR_findByAttribute:@"type" withValue:_unitType andOrderBy:@"unitName" ascending:YES]];
        viewController.convertItems = self.convertItems;
	}
    
	return viewController;
}

- (void)rightBarItemsEnabling:(BOOL)onoff
{
    for (UIBarButtonItem *barItem in self.navigationItem.rightBarButtonItems) {
        barItem.enabled = onoff;
    }
}

#pragma mark - Action

- (void)shareAll:(id)sender {
	@autoreleasepool {
        
        self.shareTextList = [NSMutableArray new];
    
        UnitConvertItem *first = _convertItems[0];
        for (NSInteger index = 1; index < _convertItems.count; index++) {
            if ([_convertItems[index] isKindOfClass:[UnitConvertItem class]]) {
                
                NSString *convertInfoText = @"";
                
                UnitConvertItem *item = _convertItems[index];
                float rate = first.item.conversionRate.floatValue / item.item.conversionRate.floatValue;
                
                if (_isTemperatureMode) {
                    float celsiusValue = [TemperatureConveter convertToCelsiusFromUnit:first.item.unitName andTemperature:self.unitValue.floatValue];
                    float targetValue = [TemperatureConveter convertCelsius:celsiusValue toUnit:item.item.unitName];
                    convertInfoText = [NSString stringWithFormat:@"%@ %@ = %@ %@", [self.decimalFormatter stringFromNumber:self.unitValue], first.item.unitShortName, [self.decimalFormatter stringFromNumber:@(targetValue)], item.item.unitShortName];
                }
                else {
                    float targetValue = self.unitValue.floatValue * rate;
                    convertInfoText = [NSString stringWithFormat:@"%@ %@ = %@ %@", [self.decimalFormatter stringFromNumber:self.unitValue], first.item.unitShortName, [self.decimalFormatter stringFromNumber:@(targetValue)], item.item.unitShortName];
                }
                [_shareTextList addObject:convertInfoText];
            }
        }
        
        UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[self] applicationActivities:nil];
        [activityController setCompletionHandler:^(NSString *activityType, BOOL completed) {
            NSLog(@"completed dialog - activity: %@ - finished flag: %d", activityType, completed);
        }];
        if (IS_IPHONE) {
            [self presentViewController:activityController animated:YES completion:NULL];
        } else {
            UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:activityController];
            [popoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            _sharePopoverController = popoverController;
        }
        
        if (IS_IPAD) {
			_sharePopoverController.delegate = self;
			[self.navigationItem.rightBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem *buttonItem, NSUInteger idx, BOOL *stop) {
				[buttonItem setEnabled:NO];
			}];
		}
	}
}

- (void)shareActionForSourceIndex:(NSUInteger)sourceIdx targetIndex:(NSUInteger)targetIdx sender:(id)sender {
	@autoreleasepool {
        
        self.shareTextList = [NSMutableArray new];
        
        UnitConvertItem *first = _convertItems[sourceIdx];
        UnitConvertItem *item = _convertItems[targetIdx];
        NSString *convertInfoText = @"";
        float rate = first.item.conversionRate.floatValue / item.item.conversionRate.floatValue;
        
        if (_isTemperatureMode) {
            float celsiusValue = [TemperatureConveter convertToCelsiusFromUnit:first.item.unitName andTemperature:self.unitValue.floatValue];
            float targetValue = [TemperatureConveter convertCelsius:celsiusValue toUnit:item.item.unitName];
            convertInfoText = [NSString stringWithFormat:@"%@ %@ = %@ %@", [self.decimalFormatter stringFromNumber:self.unitValue], first.item.unitShortName, [self.decimalFormatter stringFromNumber:@(targetValue)], item.item.unitShortName];
        }
        else {
            float targetValue = self.unitValue.floatValue * rate;
            convertInfoText = [NSString stringWithFormat:@"%@ %@ = %@ %@", [self.decimalFormatter stringFromNumber:self.unitValue], first.item.unitShortName, [self.decimalFormatter stringFromNumber:@(targetValue)], item.item.unitShortName];
        }
        [_shareTextList addObject:convertInfoText];
        
		_sharePopoverController = [self presentActivityViewControllerWithActivityItems:@[self] fromSubView:sender];
        if (IS_IPAD) {
			_sharePopoverController.delegate = self;
			[self.navigationItem.rightBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem *buttonItem, NSUInteger idx, BOOL *stop) {
				[buttonItem setEnabled:NO];
			}];
		}
	}
}

#pragma mark - UIPopOVerControllerDelegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    if (IS_IPAD) {
        [self.navigationItem.rightBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem *buttonItem, NSUInteger idx, BOOL *stop) {
            [buttonItem setEnabled:YES
             ];
        }];
    }
}

#pragma mark - UIActivityItemSource

- (NSString *)activityViewController:(UIActivityViewController *)activityViewController subjectForActivityType:(NSString *)activityType
{
    if ([activityType isEqualToString:UIActivityTypeMail]) {
        return @"Unit Converter in the AppBox Pro";
    }
    
    return @"";
}

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType
{
    if ([activityType isEqualToString:UIActivityTypeMail]) {
        
        NSMutableString *txt = [NSMutableString new];
        [txt appendString:@"<html><body>I'd like to share a conversion with you.<br/><br/>"];
        for (int i=0; i<_shareTextList.count; i++) {
            [txt appendString:_shareTextList[i]];
            [txt appendString:@"<br/>"];
        }
        [txt appendString:@"<br/>You can convert more in the AppBox Pro.<br/><a href='https://itunes.apple.com/us/app/appbox-pro-swiss-army-knife/id318404385?mt=8'>https://itunes.apple.com/us/app/appbox-pro-swiss-army-knife/id318404385?mt=8</a></body></html>"];
        
        return txt;
    }
    else {
        NSMutableString *txt = [NSMutableString new];
        for (int i=0; i<_shareTextList.count; i++) {
            [txt appendString:_shareTextList[i]];
            [txt appendString:@"\n"];
        }
        [txt appendString:@"\nCheck out the AppBox Pro!"];
        
        return txt;
    }
}

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController
{
    return @"Share unit converting data";
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
    return [self.convertItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	@autoreleasepool {
		UITableViewCell *cell=nil;

		if ([_fmMoveTableView movingIndexPath]) {
			FNLOG(@"%@", indexPath);
			indexPath = [_fmMoveTableView adaptedIndexPathForRowAtIndexPath:indexPath];
			FNLOG(@"FMMoveTableView adaptedIndexPath : %@", indexPath);
		}

		if ([self.convertItems objectAtIndex:indexPath.row] == self.equalItem) {
			A3UnitConverterTVEqualCell *equalCell = [self reusableEqualCellForTableView:tableView];
			cell = equalCell;
		}
        else if ([ [self.convertItems objectAtIndex:indexPath.row] isKindOfClass:[UnitConvertItem class] ]) {
			A3UnitConverterTVDataCell *dataCell;
			dataCell = [tableView dequeueReusableCellWithIdentifier:A3UnitConverterDataCellID forIndexPath:indexPath];

			if (nil == dataCell) {
				dataCell = [[A3UnitConverterTVDataCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:A3UnitConverterDataCellID];
				dataCell.menuDelegate = self;
			}
            
			[self configureDataCell:dataCell atIndexPath:indexPath];
            
			cell = dataCell;
		}

		return cell;
	}
}

- (void)configureDataCell:(A3UnitConverterTVDataCell *)dataCell atIndexPath:(NSIndexPath *)indexPath {
    @autoreleasepool {
		dataCell.menuDelegate = self;
        
		NSInteger dataIndex = indexPath.row;
        
		dataCell.valueField.delegate = self;
        dataCell.value2Field.delegate = self;
        
		UnitConvertItem *convertItem = self.convertItems[dataIndex];

        // <- dictionary key reset
        NSSet *keys = [_text1Fields keysOfEntriesPassingTest:^BOOL(id key, id obj, BOOL *stop) {
			if (obj == dataCell.valueField) {
				*stop = YES;
				return YES;
			}
			return NO;
		}];
		if ([keys count]>0) {
			NSString *key = keys.allObjects[0];
            [self.text1Fields removeObjectForKey:key];
		}
        
        NSSet *keys2 = [_text2Fields keysOfEntriesPassingTest:^BOOL(id key, id obj, BOOL *stop) {
			if (obj == dataCell.value2Field) {
				*stop = YES;
				return YES;
			}
			return NO;
		}];
		if ([keys2 count]>0) {
			NSString *key2 = keys2.allObjects[0];
            [self.text2Fields removeObjectForKey:key2];
		}
        // ->
        
        [self.text1Fields setObject:dataCell.valueField forKey:convertItem.item.unitName];
        [self.text2Fields setObject:dataCell.value2Field forKey:convertItem.item.unitName];
        
        BOOL isFeetInchMode = NO;
        if ([convertItem.item.unitName isEqualToString:@"feet inches"]) {
            // 0.3048, 0.0254
            isFeetInchMode = YES;
            dataCell.inputType = UnitInput_FeetInch;
        } else {
            dataCell.inputType = UnitInput_Normal;
        }
        
		NSNumber *value;
		value = self.unitValue;
        
		if (dataIndex == 0) {
			dataCell.valueField.textColor = _fmMoveTableView.tintColor;
            dataCell.value2Field.textColor = _fmMoveTableView.tintColor;
            dataCell.valueLabel.textColor = _fmMoveTableView.tintColor;
            dataCell.value2Label.textColor = _fmMoveTableView.tintColor;
			dataCell.rateLabel.text = @"";
            
            if (!value) {
                value = @(1);
            }
            
            dataCell.codeLabel.text = convertItem.item.unitShortName;
            dataCell.rateLabel.text = convertItem.item.unitName;
            
		} else {
            
            dataCell.valueField.textColor = [UIColor blackColor];
            dataCell.value2Field.textColor = [UIColor blackColor];
            dataCell.valueLabel.textColor = [UIColor blackColor];
            dataCell.value2Label.textColor = [UIColor blackColor];
            dataCell.rateLabel.text = @"";
            
            float convesionRate = 0;
            
			UnitConvertItem *convertItemZero = nil;
			for (id object in self.convertItems) {
				if ([object isKindOfClass:[UnitConvertItem class]]) {
					convertItemZero = object;
					break;
				}
			}
            
            if (_isTemperatureMode) {
                // 먼저 입력된 값을 섭씨기준의 온도로 변환한다.
                // 섭씨온도를 해당 unit값으로 변환한다
                float celsiusValue = [TemperatureConveter convertToCelsiusFromUnit:convertItemZero.item.unitName andTemperature:value.floatValue];
                value = @([TemperatureConveter convertCelsius:celsiusValue toUnit:convertItem.item.unitName]);
                
            }
            else {
                convesionRate = convertItemZero.item.conversionRate.floatValue / convertItem.item.conversionRate.floatValue;
                value = @(value.floatValue * convesionRate);
            }
            
            // code 및 rate 정보 표시
            dataCell.codeLabel.text = convertItem.item.unitName;
            // 온도 모드에서는 rate값에 일정 비율이 없으므로 표시하지 않는다.
            if (_isTemperatureMode) {
                dataCell.rateLabel.text = [TemperatureConveter rateStringFromTemperUnit:convertItemZero.item.unitName toTemperUnit:convertItem.item.unitName];
            }
            else {
                dataCell.rateLabel.text = [NSString stringWithFormat:@"%@, rate = %@", convertItem.item.unitShortName, [self.decimalFormatter stringFromNumber:@(convesionRate)]];
            }
		}

        // 계산값 표시
        if (isFeetInchMode) {
            // 0.3048, 0.0254
            // feet 계산
            int feet = (int)value.floatValue;
            float inch = (value.floatValue - feet)*kInchesPerFeet;
            dataCell.valueField.text = [self.decimalFormatter stringFromNumber:@(feet)];
            dataCell.value2Field.text = [self.decimalFormatter stringFromNumber:@(inch)];
        }
        else {
            dataCell.valueField.text = [self.decimalFormatter stringFromNumber:value];
        }
	}
}

- (A3UnitConverterTVActionCell *)reusableActionCellForTableView:(UITableView *)tableView {
	A3UnitConverterTVActionCell *cell;
	cell = [tableView dequeueReusableCellWithIdentifier:A3UnitConverterActionCellID];
	if (nil == cell) {
		cell = [[A3UnitConverterTVActionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:A3UnitConverterActionCellID];
	}
	return cell;
}

- (A3UnitConverterTVEqualCell *)reusableEqualCellForTableView:(UITableView *)tableView {
	A3UnitConverterTVEqualCell *cell;
	cell = [tableView dequeueReusableCellWithIdentifier:A3UnitConverterEqualCellID];
	if (nil == cell) {
		cell = [[A3UnitConverterTVEqualCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:A3UnitConverterEqualCellID];

	}
	return cell;
}

- (void)configurePlusCell:(A3UnitConverterTVActionCell *)actionCell {
    //	actionCell.centerButton.titleLabel.font = [UIFont fontWithName:@"FontAwesome" size:25.0];
    //	[actionCell.centerButton setTitleColor:nil forState:UIControlStateNormal];
	[actionCell.centerButton addTarget:self action:@selector(addUnitAction) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	@autoreleasepool {
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
		if ([_firstResponder isFirstResponder]) {
			[_firstResponder resignFirstResponder];
			return;
		}
        
		if ([self.swipedCells.allObjects count]) {
			[self unSwipeAll];
			return;
		}
        
		[self clearEverything];
        
		id object = self.convertItems[indexPath.row];
        
		if (object != _equalItem) {
			_selectedRow = indexPath.row;
			_isAddingUnit = NO;
			A3UnitConverterSelectViewController *viewController = [self unitSelectViewControllerWithSelectedUnit:_selectedRow];
			if (IS_IPHONE) {
                viewController.shouldPopViewController = YES;
				[self.navigationController pushViewController:viewController animated:YES];
			} else {
                viewController.shouldPopViewController = NO;
				A3RootViewController_iPad *rootViewController = [[A3AppDelegate instance] rootViewController];
                [rootViewController presentRightSideViewController:viewController];
                
                // share, history, more item disable 처리하기
                [self rightBarItemsEnabling:NO];
			}
		}
        else {
            
		}
	}
}

#pragma mark - FMMoveTableView

- (void)moveTableView:(FMMoveTableView *)tableView moveRowFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	@autoreleasepool {
		NSInteger equalIndex;

		equalIndex = [self.convertItems indexOfObject:self.equalItem];

		if (equalIndex != 1) {
			FNLOG(@"equal index %ld is not 1.", (long)equalIndex);
			[self.convertItems moveItemInSortedArrayFromIndex:equalIndex toIndex:1];
			[_fmMoveTableView moveRowAtIndexPath:[NSIndexPath indexPathForRow:equalIndex inSection:0] toIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
			if (equalIndex == 0) {
				[_fmMoveTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]]  withRowAnimation:UITableViewRowAnimationNone];
			}
		}

		if ((_draggingFirstRow && (toIndexPath.row != 0)) || (toIndexPath.row == 0)) {
			double delayInSeconds = 0.3;
			dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
			dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
				[_fmMoveTableView reloadData];

				// khkim_131217 : 드래그를 통해서 값이 업데이트 될때도 history에 추가한다.
				A3UnitConverterTVDataCell *cell = (A3UnitConverterTVDataCell *)[_fmMoveTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
				UITextField *textField;
				float fromValue;
				if (cell.inputType == UnitInput_Normal) {
					textField = cell.valueField;
					fromValue = [textField.text floatValueEx];
				}
				else if (cell.inputType == UnitInput_Fraction) {
					float num = [cell.valueField.text floatValueEx] > 1 ? [cell.valueField.text floatValueEx]:1;
					float denum = [cell.value2Field.text floatValueEx] > 1 ? [cell.value2Field.text floatValueEx]:1;
					fromValue = num / denum;
				}
				else if (cell.inputType == UnitInput_FeetInch) {
					// 0.3048, 0.0254
					// feet inch 값을 inch값으로 변화시킨다.
					float feet = [cell.valueField.text floatValueEx] > 1 ? [cell.valueField.text floatValueEx]:1;
					float inch = [cell.value2Field.text floatValueEx];
					fromValue = feet + inch/kInchesPerFeet;
					NSLog(@"Feet : %f / Inch : %f", feet, inch);
					NSLog(@"Calculated : %f", fromValue);
				}
				else {
					fromValue = 1;
				}
				[self putHistoryWithValue:@(fromValue)];
			});
		}
	}
}

- (BOOL)moveTableView:(FMMoveTableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	return [[self.convertItems objectAtIndex:indexPath.row] isKindOfClass:[UnitConvertItem class]];
}

- (NSIndexPath *)moveTableView:(FMMoveTableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
	return proposedDestinationIndexPath;
}

#pragma mark - A3UnitSelectViewControllerDelegate

- (void)didUnitSelectCancled
{
    @autoreleasepool {
        
        if (IS_IPAD) {
            [self rightBarItemsEnabling:YES];
        }
    }
}

- (void)selectViewController:(UIViewController *)viewController unitSelectedWithItem:(UnitItem *)selectedItem
{
    @autoreleasepool {
        
        if (IS_IPAD) {
            [self rightBarItemsEnabling:YES];
        }
        
        if (_isAddingUnit) {
            if (selectedItem) {
                
                // 존재 유무 체크
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"item==%@", selectedItem];
                NSArray *items = [_convertItems filteredArrayUsingPredicate:predicate];
                if (items.count > 0) {
                    // 이미 존재하는 unitItem임
                    return;
                }
                
                UnitConvertItem *convertItem = [UnitConvertItem MR_createEntity];
                convertItem.item = selectedItem;

                NSUInteger idx = [_convertItems count];
                [self.convertItems insertObjectToSortedArray:convertItem atIndex:idx];
				[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
                
                [_fmMoveTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
                
                double delayInSeconds = 0.3;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [_fmMoveTableView reloadData];
                });
            }
        }
        else {
            // 선택된 unitItem이 이미 convertItems에 추가된 unit이면, swap을 한다.
            if (selectedItem) {
                
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"item==%@", selectedItem];
                NSArray *filtered = [_convertItems filteredArrayUsingPredicate:predicate];
                if (filtered.count > 0) {
                    if (_selectedRow == 0) {
                        NSUInteger pickedUnitIdx = [_convertItems indexOfObject:filtered[0]];
                        
                        NSIndexPath *sourceIndexPath = [NSIndexPath indexPathForRow:pickedUnitIdx inSection:0];
                        NSIndexPath *targetIndexPath;
                        if (sourceIndexPath.row == 0) {
                            targetIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                        } else {
                            targetIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                        }
                        
                        [self swapCellOfFromIndexPath:sourceIndexPath toIndexPath:targetIndexPath];
                    }
                    else {
                        NSUInteger pickedUnitIdx = [_convertItems indexOfObject:filtered[0]];
                        
                        // 선택된 unitItem이 첫번째 unit이면, swap한다.
                        if (pickedUnitIdx == 0) {
                            NSIndexPath *sourceIndexPath = [NSIndexPath indexPathForRow:_selectedRow inSection:0];
                            NSIndexPath *targetIndexPath;
                            if (sourceIndexPath.row == 0) {
                                targetIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                            } else {
                                targetIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                            }
                            
                            [self swapCellOfFromIndexPath:sourceIndexPath toIndexPath:targetIndexPath];
                        }
                        // 선택된 unitItem이 첫번째 unit이 아닐경우, swap한다.
                        else {
                            
                            NSIndexPath *sourceIndexPath = [NSIndexPath indexPathForRow:_selectedRow inSection:0];
                            NSIndexPath *targetIndexPath = [NSIndexPath indexPathForRow:pickedUnitIdx inSection:0];
                            
                            [self swapCellOfFromIndexPath:sourceIndexPath toIndexPath:targetIndexPath];
                        }
                    }
                }
                // 아니면, 현재 unit을 교체한다.
                else {
                    UnitConvertItem *replacedItem = _convertItems[_selectedRow];
                    replacedItem.item = selectedItem;
					[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
                    
                    [_fmMoveTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_selectedRow inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
                    
                    double delayInSeconds = 0.3;
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                        [_fmMoveTableView reloadData];
                    });
                }
            }
        }
	}
}

#pragma mark - A3UnitConverterFavoriteEditDelegate

- (void)favoritesEdited
{
    
}

#pragma mark - UITextField delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	@autoreleasepool {
        
        NSMutableDictionary *currentTextFields = (textField.tag==1) ? _text1Fields : _text2Fields;
        
		NSSet *keys = [currentTextFields keysOfEntriesPassingTest:^BOOL(id key, id obj, BOOL *stop) {
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
        
		NSUInteger index = [self indexForUnitName:key];
		if (index == NSNotFound) {
			return NO;
		}
        
		if(index == 0) {
			[self unSwipeAll];
            
			if ([textField.text length]) {
				float value = [textField.text floatValueEx];
				if (value > 1.0) {
					[self putHistoryWithValue:@(value)];
                    _unitValue = nil;
                    [self unitValue];
//					_unitHistory = nil;
//					[self unitHistory];
				}
				textField.text = @"";
			}
            
			A3NumberKeyboardViewController *keyboardVC = [self normalNumberKeyboard];
			self.numberKeyboardViewController = keyboardVC;
			keyboardVC.textInputTarget = textField;
			keyboardVC.delegate = self;
			self.numberKeyboardViewController = keyboardVC;
			textField.inputView = [keyboardVC view];
            self.numberKeyboardViewController.keyboardType = A3NumberKeyboardTypeFraction;
            A3UnitConverterTVDataCell *cell = (A3UnitConverterTVDataCell *)[_fmMoveTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            if (cell.inputType == UnitInput_Fraction) {
                self.numberKeyboardViewController.bigButton1.selected = YES;
                self.numberKeyboardViewController.bigButton2.selected = NO;
            }
            else {
                self.numberKeyboardViewController.bigButton1.selected = NO;
                self.numberKeyboardViewController.bigButton2.selected = YES;
            }
            
			return YES;
		} else {
			[_firstResponder resignFirstResponder];
            
			// shifted 0 : shift self
			// shifted 1 and it is me. unshift self
			// shifted 1 and it is not me. unshift him and shift me.
			NSArray *swipped = self.swipedCells.allObjects;
			if (![swipped count]) {

                // khkim_131217 : requirement 수정사항
                // 셀을 탭할때 more mene 보이지 않는다
                /*
				id cell = [_fmMoveTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
                
				[self shiftLeft:cell];
                 */
			} else {
				[self unSwipeAll];
			}
			return NO;
		}
	}
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	@autoreleasepool {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:nil];

        _firstResponder = textField;
        //[self.normalNumberKeyboard reloadPrevNextButtons];
	}
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
		//self.numberKeyboardViewController = nil;

        // 숫자 입력 보정여부
        double value = [textField.text doubleValue];
        A3UnitConverterTVDataCell *cell = (A3UnitConverterTVDataCell *)[_fmMoveTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        
        if ((cell.inputType == UnitInput_FeetInch) && (textField.tag == 2)) {
            // UnitInput_FeetInch 에서 두번째 textField를 입력 보정을 하지 않는다.
        }
        else {
            // 온도는 0도 입력가능하다
            if (_isTemperatureMode) {
                
            }
            else {
                if (value == 0.0) {
                    value = 1.0;
                }
            }
        }
        
        textField.text = [self.decimalFormatter stringFromNumber:@(value)];
        [self updateTextFieldsWithSourceTextField:textField];

		[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
	}
}

- (NSUInteger)indexForUnitName:(NSString *)name {
	NSUInteger targetIndex = [self.convertItems indexOfObjectPassingTest:^BOOL(UnitConvertItem *object, NSUInteger idx, BOOL *stop) {
		if ([object isKindOfClass:[NSMutableDictionary class]]) return NO;
		return ([object.item.unitName isEqualToString:name]);
	}];
	return targetIndex;
}

- (void)updateTextFieldsWithSourceTextField:(UITextField *)textField {
	@autoreleasepool {
        
        A3UnitConverterTVDataCell *cell = (A3UnitConverterTVDataCell *)[_fmMoveTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        
        if (cell.inputType == UnitInput_FeetInch || cell.inputType == UnitInput_Fraction) {
            // khkim_131217 : requirement 수정
            // x/y의 x,y 사이의 간격 없애기 : textfield size 조절하기
            NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:textField.font, NSFontAttributeName, nil];
            CGSize txtFdSize = [textField.text sizeWithAttributes:attributes];
            CGRect txtFdRect = textField.frame;
            txtFdRect.size.width = txtFdSize.width;
            textField.frame = txtFdRect;
        }
        
        float fromValue;
        
        if (cell.inputType == UnitInput_Normal) {
            textField = cell.valueField;
            fromValue = [textField.text floatValueEx];
        }
        else if (cell.inputType == UnitInput_Fraction) {
            float num = [cell.valueField.text floatValueEx] > 1 ? [cell.valueField.text floatValueEx]:1;
            float denum = [cell.value2Field.text floatValueEx] > 1 ? [cell.value2Field.text floatValueEx]:1;
            fromValue = num / denum;
        }
        else if (cell.inputType == UnitInput_FeetInch) {
            // 0.3048, 0.0254
            // feet inch 값을 inch값으로 변화시킨다.
            float feet = [cell.valueField.text floatValueEx] > 1 ? [cell.valueField.text floatValueEx]:1;
            float inch = [cell.value2Field.text floatValueEx];
            fromValue = feet + inch/kInchesPerFeet;
            NSLog(@"Feet : %f / Inch : %f", feet, inch);
            NSLog(@"Calculated : %f", fromValue);
        }
        else {
            fromValue = 1;
        }
		
		self.unitValue = @(fromValue);
        
		NSInteger fromIndex = 0;
        UnitConvertItem *zeroConvertItem = _convertItems[0];
        NSString *zeroKey = zeroConvertItem.item.unitName;
        
		for (NSString *key in [_text1Fields allKeys]) {
            
            if ([zeroKey isEqualToString:key]) {
				continue;
			}
            
			UITextField *targetTextField = _text1Fields[key];
			
			UnitConvertItem *sourceUnit = self.convertItems[fromIndex];
			NSUInteger targetIndex = [self indexForUnitName:key];
			if (targetIndex != NSNotFound) {
				UnitConvertItem *targetUnit = self.convertItems[targetIndex];
                
                if (_isTemperatureMode) {
                    // 먼저 입력된 값을 섭씨기준의 온도로 변환한다.
                    // 섭씨온도를 해당 unit값으로 변환한다
                    float celsiusValue = [TemperatureConveter convertToCelsiusFromUnit:sourceUnit.item.unitName andTemperature:fromValue];
                    float targetValue = [TemperatureConveter convertCelsius:celsiusValue toUnit:targetUnit.item.unitName];
                    targetTextField.text = [self.decimalFormatter stringFromNumber:@(targetValue)];
                }
                else {
                    BOOL isFeetInchMode = NO;
                    if ([key isEqualToString:@"feet inches"]) {
                        isFeetInchMode = YES;
                    }
                    if (isFeetInchMode) {
                        // 0.3048, 0.0254
                        // feet 계산
                        float rate = [sourceUnit.item.conversionRate floatValue] / [targetUnit.item.conversionRate floatValue];
                        float value = fromValue * rate;
                        int feet = (int)value;
                        float inch = (value -feet) * kInchesPerFeet;
                        targetTextField.text = [self.decimalFormatter stringFromNumber:@(feet)];
                        UITextField *targetValue2TextFiled = _text2Fields[key];
                        targetValue2TextFiled.text = [self.decimalFormatter stringFromNumber:@(inch)];
                    }
                    else {
                        float rate = [sourceUnit.item.conversionRate floatValue] / [targetUnit.item.conversionRate floatValue];
                        targetTextField.text = [self.decimalFormatter stringFromNumber:@(fromValue*rate)];
                    }
                }
			}
		}
	}
}

#pragma mark - A3UnitConverterMenuDelegate

- (void)menuAdded
{
    [self clearEverything];
}

- (void)swapCellOfFromIndexPath:(NSIndexPath *)fromIp toIndexPath:(NSIndexPath *)toIp
{
    
    [self.convertItems exchangeObjectInSortedArrayAtIndex:fromIp.row withObjectAtIndex:toIp.row];
	[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
    [_fmMoveTableView reloadRowsAtIndexPaths:@[fromIp, toIp] withRowAnimation:UITableViewRowAnimationMiddle];
    
    double delayInSeconds = 0.3;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [_fmMoveTableView reloadData];
    });
}

- (void)swapActionForCell:(UITableViewCell *)cell {
	@autoreleasepool {
		[self unSwipeAll];
        
		UITableViewCell<A3TableViewSwipeCellDelegate> *swipedCell = (UITableViewCell <A3TableViewSwipeCellDelegate> *) cell;
		[swipedCell removeMenuView];
        
		NSIndexPath *sourceIndexPath = [_fmMoveTableView indexPathForCell:cell];
		NSIndexPath *targetIndexPath;
		if (sourceIndexPath.row == 0) {
			targetIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
		} else {
			targetIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
		}

        [self swapCellOfFromIndexPath:sourceIndexPath toIndexPath:targetIndexPath];
	}
}

- (void)shareActionForCell:(UITableViewCell *)cell sender:(id)sender {
	@autoreleasepool {
		NSIndexPath *indexPath = [_fmMoveTableView indexPathForCell:cell];
		NSInteger targetIdx = indexPath.row == 0 ? 2 : indexPath.row;
		NSAssert(self.convertItems[indexPath.row] != _equalItem, @"Selected row must not the equal cell");
		[self shareActionForSourceIndex:0 targetIndex:targetIdx sender:sender ];
        
        [self unSwipeAll];
	}
}

- (void)deleteActionForCell:(UITableViewCell *)cell
{
    @autoreleasepool {
		[self unSwipeAll];
        
		UITableViewCell<A3TableViewSwipeCellDelegate> *swipedCell = (UITableViewCell <A3TableViewSwipeCellDelegate> *) cell;
		[swipedCell removeMenuView];
        
        if ([_convertItems count] < 4) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
															message:@"To convert values, need two units."
														   delegate:nil
												  cancelButtonTitle:@"OK"
												  otherButtonTitles:nil];
			[alert show];
			return;
		}
        
		NSIndexPath *indexPath = [_fmMoveTableView indexPathForCell:cell];
		UnitConvertItem *convertItem = self.convertItems[indexPath.row];
		if ([convertItem isKindOfClass:[UnitConvertItem class]]) {
			[self.text1Fields removeObjectForKey:convertItem.item.unitName];
            [self.text2Fields removeObjectForKey:convertItem.item.unitName];
            
			[convertItem MR_deleteEntity];
			[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
			[self.convertItems removeObjectAtIndex:indexPath.row];
            
			[_fmMoveTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
            
			if (indexPath.row == 0) {
				_convertItems = nil;
				[self convertItems];
                
				[_fmMoveTableView moveRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] toIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                
				double delayInSeconds = 0.3;
				dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
				dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
					[_fmMoveTableView reloadRowsAtIndexPaths:[_fmMoveTableView indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationMiddle];
				});
			}
		}
	}
}

#pragma mark - A3KeyboardDelegate

- (BOOL)isPreviousEntryExists{
    A3UnitConverterTVDataCell *cell = (A3UnitConverterTVDataCell *)[_fmMoveTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    if ((cell.inputType==UnitInput_Fraction) && (_firstResponder.tag == 2)) {
        return YES;
    }
    else if ((cell.inputType==UnitInput_FeetInch) && (_firstResponder.tag == 2)) {
        return YES;
    }
    else {
        return NO;
    }
}

- (BOOL)isNextEntryExists{
    A3UnitConverterTVDataCell *cell = (A3UnitConverterTVDataCell *)[_fmMoveTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    if ((cell.inputType==UnitInput_Fraction) && (_firstResponder.tag == 1)) {
        return YES;
    }
    else if ((cell.inputType==UnitInput_FeetInch) && (_firstResponder.tag == 1)) {
        return YES;
    }
    else {
        return NO;
    }
}

- (NSString *)stringForBigButton1
{
    return @"x/y";
}

- (NSString *)stringForBigButton2
{
    return @"Cal";
}

- (void)prevButtonPressed{
    A3UnitConverterTVDataCell *cell = (A3UnitConverterTVDataCell *)[_fmMoveTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    if ((cell.inputType==UnitInput_Fraction) && (_firstResponder.tag == 2)) {
        [cell.valueField becomeFirstResponder];
    }
    else if ((cell.inputType==UnitInput_FeetInch) && (_firstResponder.tag == 2)) {
        [cell.valueField becomeFirstResponder];
    }
}

- (void)nextButtonPressed{
    A3UnitConverterTVDataCell *cell = (A3UnitConverterTVDataCell *)[_fmMoveTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    if ((cell.inputType==UnitInput_Fraction) && (_firstResponder.tag == 1)) {
        [cell.value2Field becomeFirstResponder];
    }
    else if ((cell.inputType==UnitInput_FeetInch) && (_firstResponder.tag == 1)) {
        [cell.value2Field becomeFirstResponder];
    }
}

- (void)handleBigButton1
{
    A3UnitConverterTVDataCell *cell = (A3UnitConverterTVDataCell* )[_fmMoveTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    // feet inch에서는 모드 변경없이 UnitInput_FeetInch으로 고정한다.
    if (cell.inputType == UnitInput_FeetInch) {
        return;
    }
    
    cell.inputType = UnitInput_Fraction;
    [self.numberKeyboardViewController reloadPrevNextButtons];
    self.numberKeyboardViewController.bigButton1.selected = YES;
    self.numberKeyboardViewController.bigButton2.selected = NO;
}

- (void)handleBigButton2
{
    A3UnitConverterTVDataCell *cell = (A3UnitConverterTVDataCell* )[_fmMoveTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    // feet inch에서는 모드 변경없이 UnitInput_FeetInch으로 고정한다.
    if (cell.inputType == UnitInput_FeetInch) {
        return;
    }
    
    cell.inputType = UnitInput_Normal;
    [self.numberKeyboardViewController reloadPrevNextButtons];
    self.numberKeyboardViewController.bigButton1.selected = NO;
    self.numberKeyboardViewController.bigButton2.selected = YES;
}

- (void)A3KeyboardController:(id)controller clearButtonPressedTo:(UIResponder *)keyInputDelegate {
	UITextField *textField = (UITextField *) self.numberKeyboardViewController.textInputTarget;
	if ([textField isKindOfClass:[UITextField class]]) {
		textField.text = @"";
	}
}

- (void)A3KeyboardController:(id)controller doneButtonPressedTo:(UIResponder *)keyInputDelegate {
	
    A3UnitConverterTVDataCell *cell = (A3UnitConverterTVDataCell *)[_fmMoveTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    if (cell.inputType == UnitInput_Fraction) {
        float num = cell.valueField.text.floatValue > 1 ? cell.valueField.text.floatValue:1;
        float denum = cell.value2Field.text.floatValue > 1 ? cell.value2Field.text.floatValue:1;
        float value = num / denum;
        cell.inputType = UnitInput_Normal;
        cell.valueField.text = [self.decimalFormatter stringFromNumber:@(value)];
    }
    
    [self.numberKeyboardViewController.textInputTarget resignFirstResponder];
}



#pragma mark - History

- (void)putHistoryWithValue:(NSNumber *)value {
	@autoreleasepool {
		UnitConvertItem *baseUnit = self.convertItems[0];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"source.type == %@", _unitType];
        NSArray *histories = [UnitHistory MR_findAllSortedBy:@"date" ascending:NO withPredicate:predicate];
        
		// Compare code and value.
        if (histories.count > 0) {
            UnitHistory *latestHistory = histories[0];
            if (latestHistory) {
                if ([latestHistory.source.type.unitTypeName isEqualToString:baseUnit.item.type.unitTypeName] &&
                    [latestHistory.source.unitName isEqualToString:baseUnit.item.unitName] && [value isEqualToNumber:latestHistory.value])
                {
                    
                    FNLOG(@"Does not make new history for same code and value, in history %@, %@", latestHistory.value, value);
                    return;
                }
            }
        }
		
        
		UnitHistory *history = [UnitHistory MR_createEntity];
		NSDate *keyDate = [NSDate date];
		history.date = keyDate;
		history.source = baseUnit.item;
		history.value = value;
        
		NSInteger historyItemCount = MIN([self.convertItems count] - 2, 4);
		NSInteger idx = 0;
		NSMutableSet *targets = [[NSMutableSet alloc] init];
		for (; idx < historyItemCount; idx++) {
			UnitHistoryItem *item = [UnitHistoryItem MR_createEntity];
			UnitConvertItem *convetItem = self.convertItems[idx + 2];
            item.unit = convetItem.item;
			item.order = convetItem.order;
			[targets addObject:item];
		}
		history.targets = targets;

		[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
        
		_unitValue = nil;
        
        [self refreshRightBarItems];
	}
}

#pragma mark -- Swipe Gesture

const CGFloat kUnitCellVisibleWidth = 100.0;

// Setup a left and right swipe recognizer.
-(void)setupSwipeRecognizers
{
	UISwipeGestureRecognizer* leftSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
	leftSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
	[_fmMoveTableView addGestureRecognizer:leftSwipeRecognizer];

	UISwipeGestureRecognizer* rightSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
	rightSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
	[_fmMoveTableView addGestureRecognizer:rightSwipeRecognizer];

	[self setSwipedCells:[NSMutableSet set]];
}

// Called when a swipe is performed.
- (void)swipe:(UISwipeGestureRecognizer *)recognizer
{
	FNLOG();
	bool doneSwiping = recognizer && (recognizer.state == UIGestureRecognizerStateEnded);

	if (doneSwiping)
	{
		// find the swiped cell
		CGPoint location = [recognizer locationInView:_fmMoveTableView];
		NSIndexPath* indexPath = [_fmMoveTableView indexPathForRowAtPoint:location];
		UITableViewCell<A3TableViewSwipeCellDelegate> *swipedCell = (UITableViewCell <A3TableViewSwipeCellDelegate> *) [_fmMoveTableView cellForRowAtIndexPath:indexPath];

		BOOL shouldShowMenu = NO;
		if ([swipedCell respondsToSelector:@selector(cellShouldShowMenu)]) {
			shouldShowMenu = [swipedCell cellShouldShowMenu];
		}
		if (!shouldShowMenu) return;

		CGFloat shiftLength = kUnitCellVisibleWidth;
		if ([swipedCell respondsToSelector:@selector(menuWidth:)]) {
			shiftLength = [swipedCell menuWidth:[_fmMoveTableView numberOfRowsInSection:0] > 3 ];
		}
		if ((recognizer.direction==UISwipeGestureRecognizerDirectionLeft) && (swipedCell.frame.origin.x==0) )
		{
			[self shiftRight:self.swipedCells];  // animate all cells left
			[self shiftLeft:swipedCell];       // animate swiped cell right
		}
		else if ((recognizer.direction == UISwipeGestureRecognizerDirectionRight) && (swipedCell.frame.origin.x == -shiftLength))
		{
			[self shiftRight:[NSMutableSet setWithObject:swipedCell]]; // animate current cell left
		}

	}
}

// Animates the cells to the right.
-(void)shiftRight:(NSMutableSet*)cells
{
	if ([cells count]>0)
	{
		for (UITableViewCell<A3TableViewSwipeCellDelegate>* cell in  cells)
		{
			// shift the cell left and remove its menu view
			CGRect newFrame;
			newFrame = CGRectOffset(cell.frame, -cell.frame.origin.x, 0.0);
			[UIView animateWithDuration:0.2 animations:^{
				cell.frame = newFrame;
			} completion:^(BOOL finished) {
				if ([cell respondsToSelector:@selector(removeMenuView)]) {
					if (cell.frame.origin.x == 0.0)
						[cell removeMenuView];
				}

				NSMutableArray *reloadRows = [NSMutableArray new];
				NSIndexPath *indexPath = [_fmMoveTableView indexPathForCell:cell];
				if (indexPath) {
					[reloadRows addObject:indexPath];
				}
				[_fmMoveTableView reloadRowsAtIndexPaths:reloadRows withRowAnimation:UITableViewRowAnimationNone];
			}];
		}

		// update the set of swiped cells
		[self.swipedCells minusSet:cells];
	}
}


// Animates the cells to the left offset with kUnitCellVisibleWidth
-(void)shiftLeft:(UITableViewCell<A3TableViewSwipeCellDelegate> *)cell {
	FNLOG();

	bool cellAlreadySwiped = [self.swipedCells containsObject:cell];
	if (!cellAlreadySwiped) {
		// add the cell menu view and shift the cell to the right
		if ([cell respondsToSelector:@selector(addMenuView:)]) {
			[cell addMenuView:[_fmMoveTableView numberOfRowsInSection:0] > 3 ];
		}
		CGFloat shiftLength = kUnitCellVisibleWidth;
		if ([cell respondsToSelector:@selector(menuWidth:)]) {
			shiftLength = [cell menuWidth:[_fmMoveTableView numberOfRowsInSection:0] > 3 ];
		}
		CGRect newFrame;
		newFrame = CGRectOffset(cell.frame, -shiftLength, 0.0);
		[UIView animateWithDuration:0.2 animations:^{
			cell.frame = newFrame;
		}];

		// update the set of swiped cells
		[self.swipedCells addObject:cell];
	}
}


#pragma mark - UIScrollViewDelegate

- (void)unSwipeAll {
	FNLOG();
	[self shiftRight:self.swipedCells];
}

#pragma mark -- THE END

@end
