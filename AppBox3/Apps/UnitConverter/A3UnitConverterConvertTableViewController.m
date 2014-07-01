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
#import "UIViewController+NumberKeyboard.h"
#import "NSMutableArray+A3Sort.h"
#import "NSUserDefaults+A3Defaults.h"
#import "UIViewController+MMDrawerController.h"
#import "UIViewController+A3Addition.h"
#import "A3UnitConverterHistoryViewController.h"
#import "A3UnitConverterSelectViewController.h"
#import "UnitItem.h"
#import "UnitFavorite+initialize.h"
#import "UnitConvertItem.h"
#import "UnitHistory.h"
#import "UnitHistoryItem.h"
#import "TemperatureConverter.h"
#import "UITableView+utility.h"
#import "UIViewController+iPad_rightSideView.h"
#import "UIColor+A3Addition.h"
#import "A3InstructionViewController.h"

#define kInchesPerFeet  (0.3048/0.0254)

NSString * const A3UnitConverterTableViewUnitValueKey = @"A3UnitConverterTableViewUnitValueKey";

@interface A3UnitConverterConvertTableViewController () <UITextFieldDelegate, ATSDragToReorderTableViewControllerDelegate,
		A3UnitSelectViewControllerDelegate, A3UnitConverterFavoriteEditDelegate, A3UnitConverterMenuDelegate,
		UIPopoverControllerDelegate, UIActivityItemSource, FMMoveTableViewDelegate, FMMoveTableViewDataSource,
		A3InstructionViewControllerDelegate>

@property (nonatomic, strong) FMMoveTableView *fmMoveTableView;
@property (nonatomic, strong) NSMutableSet *swipedCells;
@property (nonatomic, strong) NSMutableArray *convertItems;
@property (nonatomic, strong) NSMutableDictionary *equalItem;
@property (nonatomic, strong) NSMutableDictionary *text1Fields;
@property (nonatomic, strong) NSMutableDictionary *text2Fields;
@property (nonatomic, strong) NSArray *moreMenuButtons;
@property (nonatomic, strong) UIView *moreMenuView;
@property (nonatomic, strong) UIPopoverController *sharePopoverController;
@property (nonatomic, strong) NSMutableArray *shareTextList;
@property (nonatomic, strong) UIButton *addButton;
@property (nonatomic, strong) NSString *vcTitle;
@property (nonatomic, strong) NSNumber *unitValue;
@property (nonatomic, copy) NSString *textBeforeEditingTextField;
@property (nonatomic, copy) NSString *value1BeforeEditingTextField;
@property (nonatomic, copy) NSString *value2BeforeEditingTextField;
@property (strong, nonatomic) UINavigationController *modalNavigationController;
@property (nonatomic, strong) A3InstructionViewController *instructionViewController;
@end

@implementation A3UnitConverterConvertTableViewController {
    BOOL 		_draggingFirstRow;
	NSUInteger 	_selectedRow;
    BOOL		_isAddingUnit;
    BOOL		_isShowMoreMenu;
    
    BOOL        _isTemperatureMode;

	BOOL 		_isSwitchingFractionMode;
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
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	_fmMoveTableView = [[FMMoveTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
	_fmMoveTableView.delegate = self;
	_fmMoveTableView.dataSource = self;
	_fmMoveTableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;

	[self.view addSubview:_fmMoveTableView];
	[_fmMoveTableView makeConstraints:^(MASConstraintMaker *make) {
		make.edges.equalTo(self.view);
	}];

	self.vcTitle = self.title;

	[self setupSwipeRecognizers];

	[self makeBackButtonEmptyArrow];


	if (IS_IPHONE) {
        [self rightButtonMoreButton];
	} else {
		UIBarButtonItem *share = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"share"] style:UIBarButtonItemStylePlain target:self action:@selector(shareButtonAction:)];
        share.tag = A3RightBarButtonTagShareButton;
		UIBarButtonItem *history = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"history"] style:UIBarButtonItemStylePlain target:self action:@selector(historyButtonAction:)];
        history.tag = A3RightBarButtonTagHistoryButton;
		UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
		space.width = 24.0;
        UIBarButtonItem *help = [self instructionHelpBarButton];
        help.tag = A3RightBarButtonTagHelpButton;

		self.navigationItem.rightBarButtonItems = @[history, space, share, space, help];
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
		make.centerY.equalTo(self.view.bottom).with.offset(-32);
		make.width.equalTo(@44);
		make.height.equalTo(@44);
	}];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rightSubViewWillHide:) name:A3NotificationRightSideViewWillDismiss object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainMenuDidHide) name:A3NotificationMainMenuDidHide object:nil];
	[self registerContentSizeCategoryDidChangeNotification];
}

- (void)removeObserver {
	[self removeContentSizeCategoryDidChangeNotification];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationRightSideViewWillDismiss object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationMainMenuDidHide object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	if ([self isMovingFromParentViewController] || [self isBeingDismissed]) {
		FNLOG();
		[self clearEverything];
		[self removeObserver];
	}
}

- (void)dealloc {
	[self removeObserver];
}

- (void)mainMenuDidHide {
	[self enableControls:YES];
}

- (void)rightSubViewWillHide:(NSNotification *)noti
{
    [self enableControls:YES];
}

- (void)enableControls:(BOOL)enable
{
	if (!IS_IPAD) return;

	UIColor *disabledColor = [UIColor colorWithRGBRed:201 green:201 blue:201 alpha:255];
    [self.navigationItem.rightBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem *barButton, NSUInteger idx, BOOL *stop) {
        switch ([barButton tag]) {
            case A3RightBarButtonTagShareButton:
                barButton.enabled = enable;
                break;
                
            case A3RightBarButtonTagHistoryButton:
            {
                if (enable) {
                    barButton.enabled = [UnitHistory MR_countOfEntities] > 0;
                } else {
                    barButton.enabled = NO;
                }
            }
                break;
                
            case A3RightBarButtonTagHelpButton:
                barButton.enabled = YES;
                break;
                
            default:
                break;
        }
    }];

    
	[self.addButton setEnabled:enable];
	self.tabBarController.tabBar.selectedImageTintColor = enable ? nil : disabledColor;
	self.navigationItem.leftBarButtonItem.enabled = enable;

	NSIndexPath *firstRowIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
	A3UnitConverterTVDataCell *cell = (A3UnitConverterTVDataCell *) [self.fmMoveTableView cellForRowAtIndexPath:firstRowIndexPath];
	cell.valueField.textColor = enable ? [[A3AppDelegate instance] themeColor] : disabledColor;
	cell.value2Field.textColor = enable ? [[A3AppDelegate instance] themeColor] : disabledColor;
	cell.valueLabel.textColor = enable ? [[A3AppDelegate instance] themeColor] : disabledColor;
	cell.value2Label.textColor = enable ? [[A3AppDelegate instance] themeColor] : disabledColor;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.title = self.vcTitle;
	if (_isFromMoreTableViewController && IS_IPHONE) {
		NSStringDrawingContext *context = [NSStringDrawingContext new];
		CGRect bounds = [self.title boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:17]} context:context];
		if (bounds.size.width > 120) {
			UILabel *titleLabel = [UILabel new];
			titleLabel.numberOfLines = 2;
			titleLabel.bounds = CGRectMake(0, 0, 130, 44);
			titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
			titleLabel.text = self.title;
			titleLabel.font = [UIFont boldSystemFontOfSize:17];
			titleLabel.textAlignment = NSTextAlignmentCenter;
			self.navigationItem.titleView = titleLabel;
		}
	}
    
    A3UnitConverterTabBarController *tabBar = (A3UnitConverterTabBarController *)self.navigationController.tabBarController;
    if ([tabBar.unitTypes containsObject:self.unitType]) {
        NSUInteger vcIdx = [tabBar.unitTypes indexOfObject:self.unitType];
        [[NSUserDefaults standardUserDefaults] setUnitConverterCurrentUnitTap:vcIdx];
    }

	[self showLeftNavigationItems];

    [self enableControls:YES];

    [_fmMoveTableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];

	if ([self isMovingToParentViewController]) {
//		A3UnitConverterTabBarController *tabBar = (A3UnitConverterTabBarController *)self.navigationController.tabBarController;
//		if ([tabBar.unitTypes containsObject:self.unitType]) {
//			NSUInteger vcIdx = [tabBar.unitTypes indexOfObject:self.unitType];
//			[[NSUserDefaults standardUserDefaults] setUnitConverterCurrentUnitTap:vcIdx];
//		}
        [self setupInstructionView];
	}
}

- (void)viewWillLayoutSubviews {
	[super viewWillLayoutSubviews];
    
	if (IS_IPAD) {
		[self showLeftNavigationItems];
	}
}

- (void)contentSizeDidChange:(NSNotification *)notification {
	[_fmMoveTableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)clearEverything {
	[self.firstResponder resignFirstResponder];
	[self setFirstResponder:nil];
	[self dismissMoreMenu];
}

- (void)showLeftNavigationItems
{
	FNLOG(@"%@", self.tabBarController);

    // 현재 more탭바인지 여부 체크
    if (_isFromMoreTableViewController) {
        self.navigationItem.leftItemsSupplementBackButton = YES;

        self.navigationItem.hidesBackButton = NO;

		[self leftBarButtonAppsButton];
    } else {
        // 아님
        [self makeBackButtonEmptyArrow];
        self.navigationItem.hidesBackButton = YES;
        
		[self leftBarButtonAppsButton];
    }
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
		[self.A3RootViewController toggleLeftMenuViewOnOff];
		[self enableControls:!self.A3RootViewController.showLeftView];
	}
}

- (void)moreButtonAction:(UIBarButtonItem *)button {
	[self.firstResponder resignFirstResponder];
	[self setFirstResponder:nil];

	[self rightBarButtonDoneButton];

    UIButton *share = [self shareButton];
    UIButton *history = [self historyButton:NULL];
    UIButton *help = [self instructionHelpButton];
    
    history.enabled = [UnitHistory MR_countOfEntities] > 0 ? YES : NO;
    
	_moreMenuButtons = @[help, share, history];
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
	[self dismissMoreMenuView:_moreMenuView scrollView:_fmMoveTableView];
	[self.view removeGestureRecognizer:gestureRecognizer];
}

- (void)shareButtonAction:(id)sender {
	[self clearEverything];

	[self shareAll:sender];
}

- (void)historyButtonAction:(UIButton *)button {
	[self clearEverything];

	A3UnitConverterHistoryViewController *viewController = [[A3UnitConverterHistoryViewController alloc] initWithNibName:nil bundle:nil];
	if (IS_IPHONE) {
		_modalNavigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
		[self presentViewController:_modalNavigationController animated:YES completion:NULL];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(historyViewControllerDidDismiss) name:A3NotificationChildViewControllerDidDismiss object:viewController];
	} else {
		[self enableControls:NO];
		[self.A3RootViewController presentRightSideViewController:viewController];
	}
}

- (void)historyViewControllerDidDismiss {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationChildViewControllerDidDismiss object:_modalNavigationController.childViewControllers[0]];
	_modalNavigationController = nil;
}

- (NSMutableArray *)convertItems {
	if (nil == _convertItems) {
        _convertItems = [NSMutableArray arrayWithArray:[UnitConvertItem MR_findAllSortedBy:@"order" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"item.type==%@", _unitType]]];
        
		[self addEqualAndPlus];
	}
	return _convertItems;
}

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
        _addButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_addButton setImage:[UIImage imageNamed:@"add01"] forState:UIControlStateNormal];
        [_addButton addTarget:self action:@selector(addUnitAction) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _addButton;
}

- (void)setUnitValue:(NSNumber *)unitValue {
    [[NSUserDefaults standardUserDefaults] setObject:unitValue forKey:A3UnitConverterTableViewUnitValueKey];
}

- (NSNumber *)unitValue {
    NSNumber *_unitValue = [[NSUserDefaults standardUserDefaults] objectForKey:A3UnitConverterTableViewUnitValueKey];
    
    if (!_unitValue) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"source.type == %@", _unitType];
        NSArray *histories = [UnitHistory MR_findAllSortedBy:@"updateDate" ascending:NO withPredicate:predicate];
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

- (void)addUnitAction {
	if ([self.firstResponder isFirstResponder]) {
		[self.firstResponder resignFirstResponder];
		[self setFirstResponder:nil];
		return;
	}

	if ([self.swipedCells.allObjects count]) {
		[self unSwipeAll];
		return;
	}

	_isAddingUnit = YES;
	UIViewController *viewController = [self unitAddViewController];

	if (IS_IPHONE) {
		_modalNavigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
		[self presentViewController:_modalNavigationController animated:YES completion:NULL];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unitAddViewControllerDidDismiss) name:A3NotificationChildViewControllerDidDismiss object:viewController];
	} else {
		[self enableControls:NO];
		[self.A3RootViewController presentRightSideViewController:viewController];
	}
}

- (void)unitAddViewControllerDidDismiss {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationChildViewControllerDidDismiss object:_modalNavigationController.childViewControllers[0]];
	_modalNavigationController = nil;
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
		viewController.placeHolder = NSLocalizedStringFromTable(selectedItem.item.unitName, @"unit", nil);
        
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

#pragma mark Instruction Related
- (void)setupInstructionView
{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"UnitConverter"]) {
        [self showInstructionView];
    }
}

- (void)showInstructionView
{
    [self dismissMoreMenu];
    UIStoryboard *instructionStoryBoard = [UIStoryboard storyboardWithName:IS_IPHONE ? @"Instruction_iPhone" : @"Instruction_iPad" bundle:nil];
    _instructionViewController = [instructionStoryBoard instantiateViewControllerWithIdentifier:@"UnitConverter"];
    self.instructionViewController.delegate = self;
    [self.tabBarController.view addSubview:self.instructionViewController.view];
    self.instructionViewController.view.frame = self.tabBarController.view.frame;
    self.instructionViewController.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight;
}

- (void)dismissInstructionViewController:(UIView *)view
{
    [self.instructionViewController.view removeFromSuperview];
    self.instructionViewController = nil;
}

#pragma mark - Action

- (void)shareAll:(id)sender {
	self.shareTextList = [NSMutableArray new];

	UnitConvertItem *first = _convertItems[0];
	for (NSInteger index = 1; index < _convertItems.count; index++) {
		if ([_convertItems[index] isKindOfClass:[UnitConvertItem class]]) {

			NSString *convertInfoText = @"";

			UnitConvertItem *item = _convertItems[index];
			float rate = first.item.conversionRate.floatValue / item.item.conversionRate.floatValue;

			if (_isTemperatureMode) {
				float celsiusValue = [TemperatureConverter convertToCelsiusFromUnit:first.item.unitName andTemperature:self.unitValue.floatValue];
				float targetValue = [TemperatureConverter convertCelsius:celsiusValue toUnit:item.item.unitName];
				convertInfoText = [NSString stringWithFormat:@"%@ %@ = %@ %@", [self.decimalFormatter stringFromNumber:self.unitValue], first.item.unitShortName, [self.decimalFormatter stringFromNumber:@(targetValue)], item.item.unitShortName];
			}
			else {
				float targetValue = self.unitValue.floatValue * rate;

                if ([first.item.unitName isEqualToString:@"feet inches"]) {
                    //float rate = [item.item.conversionRate floatValue] / [first.item.conversionRate floatValue];
                    float value = [self.unitValue floatValue];
                    int feet = (int)value;
                    float inch = (value -feet) * kInchesPerFeet;

                    convertInfoText = [NSString stringWithFormat:@"%@ = %@ %@", [NSString stringWithFormat:@"%@ft %@in", [self.decimalFormatter stringFromNumber:@(feet)], [self.decimalFormatter stringFromNumber:@(inch)]], [self.decimalFormatter stringFromNumber:@(targetValue)], item.item.unitShortName];
                }
                else if ([item.item.unitName isEqualToString:@"feet inches"]) {
                    float value = self.unitValue.floatValue * rate;
                    int feet = (int)value;
                    float inch = (value -feet) * kInchesPerFeet;
                    
                    convertInfoText = [NSString stringWithFormat:@"%@ %@ = %@", [self.decimalFormatter stringFromNumber:self.unitValue], first.item.unitShortName, [NSString stringWithFormat:@"%@ft %@in", [self.decimalFormatter stringFromNumber:@(feet)], [self.decimalFormatter stringFromNumber:@(inch)]]];
                }
                else {
                    convertInfoText = [NSString stringWithFormat:@"%@ %@ = %@ %@", [self.decimalFormatter stringFromNumber:self.unitValue], first.item.unitShortName, [self.decimalFormatter stringFromNumber:@(targetValue)], item.item.unitShortName];
                }
			}
			[_shareTextList addObject:convertInfoText];
		}
	}

	UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[self] applicationActivities:nil];
	[activityController setCompletionHandler:^(NSString *activityType, BOOL completed) {
		FNLOG(@"completed dialog - activity: %@ - finished flag: %d", activityType, completed);
	}];
	if (IS_IPHONE) {
		[self presentViewController:activityController animated:YES completion:NULL];
	}
    else {
        if ([sender isKindOfClass:[UIButton class]]) {
            _sharePopoverController = [self presentActivityViewControllerWithActivityItems:@[self] fromSubView:sender];
        }
        else {
            UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:activityController];
            [popoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            _sharePopoverController = popoverController;
        }
	}

	if (IS_IPAD) {
		[self enableControls:NO];
		_sharePopoverController.delegate = self;
		[self.navigationItem.rightBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem *buttonItem, NSUInteger idx, BOOL *stop) {
			[buttonItem setEnabled:NO];
		}];
	}
}

- (void)shareActionForSourceIndex:(NSUInteger)sourceIdx targetIndex:(NSUInteger)targetIdx sender:(id)sender {
	self.shareTextList = [NSMutableArray new];

	UnitConvertItem *first = _convertItems[sourceIdx];
	UnitConvertItem *item = _convertItems[targetIdx];
	NSString *convertInfoText = @"";
	float rate = first.item.conversionRate.floatValue / item.item.conversionRate.floatValue;

	if (_isTemperatureMode) {
		float celsiusValue = [TemperatureConverter convertToCelsiusFromUnit:first.item.unitName andTemperature:self.unitValue.floatValue];
		float targetValue = [TemperatureConverter convertCelsius:celsiusValue toUnit:item.item.unitName];
		convertInfoText = [NSString stringWithFormat:@"%@ %@ = %@ %@", [self.decimalFormatter stringFromNumber:self.unitValue], first.item.unitShortName, [self.decimalFormatter stringFromNumber:@(targetValue)], item.item.unitShortName];
	}
	else {
		float targetValue = self.unitValue.floatValue * rate;
        
        if ([first.item.unitName isEqualToString:@"feet inches"]) {
            //float rate = [item.item.conversionRate floatValue] / [first.item.conversionRate floatValue];
            float value = [self.unitValue floatValue];
            int feet = (int)value;
            float inch = (value -feet) * kInchesPerFeet;
            
            convertInfoText = [NSString stringWithFormat:@"%@ = %@ %@", [NSString stringWithFormat:@"%@ft %@in", [self.decimalFormatter stringFromNumber:@(feet)], [self.decimalFormatter stringFromNumber:@(inch)]], [self.decimalFormatter stringFromNumber:@(targetValue)], item.item.unitShortName];
        }
        else if ([item.item.unitName isEqualToString:@"feet inches"]) {
            //            float rate =  [item.item.conversionRate floatValue] / [first.item.conversionRate floatValue];
            float value = self.unitValue.floatValue * rate;
            int feet = (int)value;
            float inch = (value -feet) * kInchesPerFeet;
            
            convertInfoText = [NSString stringWithFormat:@"%@ %@ = %@", [self.decimalFormatter stringFromNumber:self.unitValue], first.item.unitShortName, [NSString stringWithFormat:@"%@ft %@in", [self.decimalFormatter stringFromNumber:@(feet)], [self.decimalFormatter stringFromNumber:@(inch)]]];
        }
        else {
            convertInfoText = [NSString stringWithFormat:@"%@ %@ = %@ %@", [self.decimalFormatter stringFromNumber:self.unitValue], first.item.unitShortName, [self.decimalFormatter stringFromNumber:@(targetValue)], item.item.unitShortName];
        }
	}
	[_shareTextList addObject:convertInfoText];

	_sharePopoverController = [self presentActivityViewControllerWithActivityItems:@[self] fromSubView:sender];
	if (IS_IPAD) {
		[self enableControls:NO];

		_sharePopoverController.delegate = self;
		[self.navigationItem.rightBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem *buttonItem, NSUInteger idx, BOOL *stop) {
			[buttonItem setEnabled:NO];
		}];
	}
}

#pragma mark - UIPopOVerControllerDelegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
	[self enableControls:YES];
}

#pragma mark - UIActivityItemSource

- (NSString *)activityViewController:(UIActivityViewController *)activityViewController subjectForActivityType:(NSString *)activityType
{
    if ([activityType isEqualToString:UIActivityTypeMail]) {
        return NSLocalizedString(@"Unit Converter using AppBox Pro", @"Unit Converter using AppBox Pro");
    }
    
    return @"";
}

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType
{
    if ([activityType isEqualToString:UIActivityTypeMail]) {
        
        NSMutableString *txt = [NSMutableString new];
		[txt appendFormat:@"<html><body>%@<br/><br/>", NSLocalizedString(@"I'd like to share a conversion with you.", nil)];
        for (int i=0; i<_shareTextList.count; i++) {
            [txt appendString:_shareTextList[i]];
            [txt appendString:@"<br/>"];
        }
		[txt appendFormat:@"<br/><br/>%@<br/><img style='border:0;' src='http://apns.allaboutapps.net/allaboutapps/appboxIcon60.png' alt='AppBox Pro'><br/><a href='https://itunes.apple.com/app/id318404385'>%@</a></body></html>",
						  NSLocalizedString(@"You can convert more in the AppBox Pro.", nil),
						  NSLocalizedString(@"Download from AppStore", nil)];
        
        return txt;
    }
    else {
        NSMutableString *txt = [NSMutableString new];
        for (int i=0; i<_shareTextList.count; i++) {
            [txt appendString:_shareTextList[i]];
            [txt appendString:@"\n"];
        }
		//[txt appendString:NSLocalizedString(@"Check out the AppBox Pro!", @"Check out the AppBox Pro!")];
        
        return txt;
    }
}

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController
{
    return NSLocalizedString(@"Share unit converting data", @"Share unit converting data");
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

- (void)configureDataCell:(A3UnitConverterTVDataCell *)dataCell atIndexPath:(NSIndexPath *)indexPath {
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

		dataCell.codeLabel.text = NSLocalizedStringFromTable(convertItem.item.unitName, @"unit", nil);
		dataCell.rateLabel.text = NSLocalizedStringFromTable(convertItem.item.unitShortName, @"unitShort", nil);
	}
    else {
		dataCell.valueField.textColor = [UIColor blackColor];
		dataCell.value2Field.textColor = [UIColor blackColor];
		dataCell.valueLabel.textColor = [UIColor blackColor];
		dataCell.value2Label.textColor = [UIColor blackColor];
		dataCell.rateLabel.text = @"";

		float conversionRate = 0;

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
			float celsiusValue = [TemperatureConverter convertToCelsiusFromUnit:convertItemZero.item.unitName andTemperature:value.floatValue];
			value = @([TemperatureConverter convertCelsius:celsiusValue toUnit:convertItem.item.unitName]);

		}
		else {
			conversionRate = convertItemZero.item.conversionRate.floatValue / convertItem.item.conversionRate.floatValue;
			value = @(value.floatValue * conversionRate);
		}

		// code 및 rate 정보 표시
		dataCell.codeLabel.text = NSLocalizedStringFromTable(convertItem.item.unitName, @"unit", nil);
		// 온도 모드에서는 rate값에 일정 비율이 없으므로 표시하지 않는다.
		if (_isTemperatureMode) {
//            dataCell.codeLabel.text = NSLocalizedStringFromTable(convertItem.item.unitShortName, @"unitShort", nil);
			dataCell.rateLabel.text = [TemperatureConverter rateStringFromTemperUnit:convertItemZero.item.unitName toTemperUnit:convertItem.item.unitName];
		}
		else {
			dataCell.rateLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@, rate = %@", @"%@, rate = %@"), convertItem.item.unitShortName, [self.decimalFormatter stringFromNumber:@(conversionRate)]];
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
	[dataCell updateMultiTextFieldModeConstraintsWithEditingTextField:nil];
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
	[actionCell.centerButton addTarget:self action:@selector(addUnitAction) forControlEvents:UIControlEventTouchUpInside];
    actionCell.centerButton.tintColor = [A3AppDelegate instance].themeColor;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

	if ([self.firstResponder isFirstResponder]) {
		[self.firstResponder resignFirstResponder];
		[self setFirstResponder:nil];
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
			[self enableControls:NO];

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

#pragma mark - FMMoveTableView

- (void)moveTableView:(FMMoveTableView *)tableView moveRowFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	[self.convertItems moveItemInSortedArrayFromIndex:fromIndexPath.row toIndex:toIndexPath.row];
	[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];

	dispatch_async(dispatch_get_main_queue(), ^{
		NSInteger equalIndex;
		equalIndex = [self.convertItems indexOfObject:self.equalItem];

		if (equalIndex != 1) {
			FNLOG(@"equal index %ld is not 1.", (long)equalIndex);
			FNLOG(@"%@", _convertItems);
			[self.convertItems moveItemInSortedArrayFromIndex:equalIndex toIndex:1];
			FNLOG(@"%@", _convertItems);
			[_fmMoveTableView moveRowAtIndexPath:[NSIndexPath indexPathForRow:equalIndex inSection:0] toIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
			if (equalIndex == 0) {
				[_fmMoveTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]]  withRowAnimation:UITableViewRowAnimationNone];
			}
			[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
		}
	});

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
				fromValue = [[self.decimalFormatter numberFromString:textField.text] floatValue];
			}
			else if (cell.inputType == UnitInput_Fraction) {
				float num = [[self.decimalFormatter numberFromString:textField.text] floatValue];
				float deviderNumber = [[self.decimalFormatter numberFromString:textField.text] floatValue];
				fromValue = num / deviderNumber;
			}
			else if (cell.inputType == UnitInput_FeetInch) {
				// 0.3048, 0.0254
				// feet inch 값을 inch값으로 변화시킨다.
				float feet = [[self.decimalFormatter numberFromString:cell.valueField.text] floatValue];
				float inch = [[self.decimalFormatter numberFromString:cell.value2Field.text] floatValue];
				fromValue = feet + inch/kInchesPerFeet;
				FNLOG(@"Feet : %f / Inch : %f", feet, inch);
				FNLOG(@"Calculated : %f", fromValue);
			}
			else {
				fromValue = 1;
			}
            
            if (fromValue != 1 && [UnitHistory MR_countOfEntities] != 0 ) {
                [self putHistoryWithValue:@(fromValue)];
            }
		});
	}
}

- (BOOL)moveTableView:(FMMoveTableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	return indexPath.row != 1;
}

- (NSIndexPath *)moveTableView:(FMMoveTableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
	if (proposedDestinationIndexPath.row == 1) {
		return [NSIndexPath indexPathForRow:2 inSection:proposedDestinationIndexPath.section];
	}
	return proposedDestinationIndexPath;
}

#pragma mark - A3UnitSelectViewControllerDelegate

- (void)didUnitSelectCancled
{
	if (IS_IPAD) {
		[self rightBarItemsEnabling:YES];
	}
}

- (void)selectViewController:(UIViewController *)viewController unitSelectedWithItem:(UnitItem *)selectedItem
{
	if (IS_IPAD) {
		[self rightBarItemsEnabling:YES];
	}

	if (_isAddingUnit) {
		if (selectedItem) {

			// 존재 유무 체크
			NSPredicate *predicate = [NSPredicate predicateWithFormat:@"item == %@", selectedItem];
			NSArray *items = [_convertItems filteredArrayUsingPredicate:predicate];
			if (items.count > 0) {
				// 이미 존재하는 unitItem임
				return;
			}

			UnitConvertItem *convertItem = [UnitConvertItem MR_createEntity];
			convertItem.uniqueID = [[NSUUID UUID] UUIDString];
			convertItem.updateDate = [NSDate date];
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
			NSPredicate *predicate = [NSPredicate predicateWithFormat:@"item == %@", selectedItem];
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

#pragma mark - A3UnitConverterFavoriteEditDelegate

- (void)favoritesEdited
{
    
}

#pragma mark - UITextField delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	A3UnitConverterTVDataCell *cell = (A3UnitConverterTVDataCell *) [_fmMoveTableView cellForCellSubview:textField];
	if (!cell) return NO;
	NSIndexPath *indexPath = [_fmMoveTableView indexPathForCell:cell];
    [self dismissMoreMenu];

	if(indexPath.row == 0) {
		[self unSwipeAll];
        if (cell.inputType == UnitInput_FeetInch) {
            if (cell.valueField == textField) {
                self.value1BeforeEditingTextField = [textField text];
            }
            else if (cell.value2Field == textField) {
                self.value2BeforeEditingTextField = [textField text];
            }
        }
        
		return YES;
	}
    else {
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

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	FNLOG();
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:nil];

	self.firstResponder = textField;

	A3UnitConverterTVDataCell *cell = (A3UnitConverterTVDataCell *) [_fmMoveTableView cellForCellSubview:textField];
	if (!cell) return;

	if (!_isSwitchingFractionMode && [textField.text length]) {
		self.textBeforeEditingTextField = textField.text;

		float value = [[self.decimalFormatter numberFromString:textField.text] floatValue];
//		if (value != 0.0 && value != [[self unitValue] floatValue]) {
//        if ([self.unitValue integerValue] != 1 && [UnitHistory MR_countOfEntities] != 0 ) {
        if ([self.unitValue integerValue] != 1 || ([self.unitValue integerValue] != 1 && [UnitHistory MR_countOfEntities] > 0)) {
			[self putHistoryWithValue:@(value)];
			self.unitValue = nil;
			[self unitValue];
		}
	}
	textField.text = @"";

	A3NumberKeyboardViewController *keyboardVC = [self simpleUnitConverterNumberKeyboard];
	self.numberKeyboardViewController = keyboardVC;
	keyboardVC.textInputTarget = textField;
	keyboardVC.delegate = self;
	textField.inputView = [keyboardVC view];

	self.numberKeyboardViewController.keyboardType = A3NumberKeyboardTypeReal;

	switch (cell.inputType) {
		case UnitInput_Normal:
			textField.inputAccessoryView = nil;
			break;
		case UnitInput_Fraction:
			[keyboardVC.fractionButton setSelected:YES];
			[self addKeyboardAccessoryToTextField:textField];
			break;
		case UnitInput_FeetInch:
			[self addKeyboardAccessoryToTextField:textField];
			[keyboardVC.fractionButton setTitle:@"" forState:UIControlStateNormal];
			[keyboardVC.fractionButton setEnabled:NO];
			break;
	}

	[cell updateMultiTextFieldModeConstraintsWithEditingTextField:textField];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];

	[self setFirstResponder:nil];

	A3UnitConverterTVDataCell *cell = (A3UnitConverterTVDataCell *) [_fmMoveTableView cellForCellSubview:textField];

	if (_isSwitchingFractionMode) {
		[cell updateMultiTextFieldModeConstraintsWithEditingTextField:textField];
		return;
	}

	if (cell.inputType == UnitInput_Fraction) {
		float num = cell.valueField.text.floatValue > 1 ? cell.valueField.text.floatValue:1;
		float divider = cell.value2Field.text.floatValue > 1 ? cell.value2Field.text.floatValue:1;
		float value = num / divider;
		cell.inputType = UnitInput_Normal;
		cell.valueField.text = [self.decimalFormatter stringFromNumber:@(value)];
	}

	if (![textField.text length]) {
		textField.text = _textBeforeEditingTextField;
	}

	// 숫자 입력 보정여부
	double value = [[self.decimalFormatter numberFromString:textField.text] doubleValue];

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
	[cell updateMultiTextFieldModeConstraintsWithEditingTextField:nil];

	[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
}

- (void)textFieldDidChange:(NSNotification *)notification {
	UITextField *textField = [notification object];
	[self updateTextFieldsWithSourceTextField:textField];

	A3UnitConverterTVDataCell *cell = (A3UnitConverterTVDataCell *) [_fmMoveTableView cellForCellSubview:textField];
	[cell updateMultiTextFieldModeConstraintsWithEditingTextField:textField];
}

- (NSUInteger)indexForUnitName:(NSString *)name {
	NSUInteger targetIndex = [self.convertItems indexOfObjectPassingTest:^BOOL(UnitConvertItem *object, NSUInteger idx, BOOL *stop) {
		if ([object isKindOfClass:[NSMutableDictionary class]]) return NO;
		return ([object.item.unitName isEqualToString:name]);
	}];
	return targetIndex;
}

- (void)updateTextFieldsWithSourceTextField:(UITextField *)textField {
	A3UnitConverterTVDataCell *cell = (A3UnitConverterTVDataCell *) [_fmMoveTableView cellForCellSubview:textField];

	float fromValue;

	if (cell.inputType == UnitInput_Normal) {
		textField = cell.valueField;
		fromValue = [[self.decimalFormatter numberFromString:textField.text] floatValue];
	}
	else if (cell.inputType == UnitInput_Fraction) {
		float num = [[self.decimalFormatter numberFromString:cell.valueField.text] floatValue];
		float denum = [[self.decimalFormatter numberFromString:cell.value2Field.text] floatValue];
		fromValue = num / denum;
	}
	else if (cell.inputType == UnitInput_FeetInch) {
		// 0.3048, 0.0254
		// feet inch 값을 inch값으로 변화시킨다.
		float feet = [[self.decimalFormatter numberFromString:cell.valueField.text] floatValue];
		float inch = [[self.decimalFormatter numberFromString:cell.value2Field.text] floatValue];
		fromValue = feet + inch/kInchesPerFeet;
		FNLOG(@"Feet : %f / Inch : %f", feet, inch);
		FNLOG(@"Calculated : %f", fromValue);
	}
	else {
		fromValue = 1;
	}

    if (cell.inputType == UnitInput_FeetInch) {
        if ([cell.valueField.text floatValue] > 0 && [cell.value2Field.text floatValue] > 0) {
            self.unitValue = @(fromValue);
        }
        else {
            fromValue = [self.unitValue floatValue];
        }
    }
    else {
        self.unitValue = @(fromValue);
    }

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
				float celsiusValue = [TemperatureConverter convertToCelsiusFromUnit:sourceUnit.item.unitName andTemperature:fromValue];
				float targetValue = [TemperatureConverter convertCelsius:celsiusValue toUnit:targetUnit.item.unitName];
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
			targetTextField.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:65];
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
	[self unSwipeAll];

	UITableViewCell<A3FMMoveTableViewSwipeCellDelegate> *swipedCell = (UITableViewCell <A3FMMoveTableViewSwipeCellDelegate> *) cell;
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

- (void)shareActionForCell:(UITableViewCell *)cell sender:(id)sender {
	NSIndexPath *indexPath = [_fmMoveTableView indexPathForCell:cell];
    if (indexPath.row == 0) {
        [self shareAll:sender];
    }
    else {
        NSAssert(self.convertItems[indexPath.row] != _equalItem, @"Selected row must not the equal cell");
        [self shareActionForSourceIndex:0 targetIndex:indexPath.row sender:sender ];
    }

	[self unSwipeAll];
}

- (void)deleteActionForCell:(UITableViewCell *)cell
{
	[self unSwipeAll];

	UITableViewCell<A3FMMoveTableViewSwipeCellDelegate> *swipedCell = (UITableViewCell <A3FMMoveTableViewSwipeCellDelegate> *) cell;
	[swipedCell removeMenuView];

	if ([_convertItems count] < 4) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
														message:NSLocalizedString(@"To convert values, need two units.", @"To convert values, need two units.")
													   delegate:nil
											  cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
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

#pragma mark - A3KeyboardDelegate

- (BOOL)isPreviousEntryExists{
	A3UnitConverterTVDataCell *cell = (A3UnitConverterTVDataCell *) [_fmMoveTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
	UIView *viewInRespond = (UIView *) self.firstResponder;
    if ((cell.inputType==UnitInput_Fraction) && (viewInRespond.tag == 2)) {
        return YES;
    }
    else if ((cell.inputType==UnitInput_FeetInch) && (viewInRespond.tag == 2)) {
        return YES;
    }
    else {
        return NO;
    }
}

- (BOOL)isNextEntryExists{
    A3UnitConverterTVDataCell *cell = (A3UnitConverterTVDataCell *)[_fmMoveTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
	UIView *viewInRespond = (UIView *) self.firstResponder;
    if ((cell.inputType==UnitInput_Fraction) && (viewInRespond.tag == 1)) {
        return YES;
    }
    else if ((cell.inputType==UnitInput_FeetInch) && (viewInRespond.tag == 1)) {
        return YES;
    }
    else {
        return NO;
    }
}

- (void)prevButtonPressed{
    A3UnitConverterTVDataCell *cell = (A3UnitConverterTVDataCell *)[_fmMoveTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
	UIView *viewInRespond = (UIView *) self.firstResponder;
	_isSwitchingFractionMode = YES;
    if ((cell.inputType==UnitInput_Fraction) && (viewInRespond.tag == 2)) {
        [cell.valueField becomeFirstResponder];
    }
    else if ((cell.inputType==UnitInput_FeetInch) && (viewInRespond.tag == 2)) {
        if ([cell.value2Field.text length] == 0) {
            cell.value2Field.text = self.value2BeforeEditingTextField;
        }
        self.textBeforeEditingTextField = cell.valueField.text;
        [cell.valueField becomeFirstResponder];
    }
	_isSwitchingFractionMode = NO;
}

- (void)nextButtonPressed{
    A3UnitConverterTVDataCell *cell = (A3UnitConverterTVDataCell *)[_fmMoveTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
	UIView *viewInRespond = (UIView *) self.firstResponder;
	_isSwitchingFractionMode = YES;
    if ((cell.inputType==UnitInput_Fraction) && (viewInRespond.tag == 1)) {
        [cell.value2Field becomeFirstResponder];
    }
    else if ((cell.inputType==UnitInput_FeetInch) && (viewInRespond.tag == 1)) {
        if ([cell.valueField.text length] == 0) {
            cell.valueField.text = self.value1BeforeEditingTextField;
        }
        self.textBeforeEditingTextField = cell.value2Field.text;
        [cell.value2Field becomeFirstResponder];
    }
	_isSwitchingFractionMode = NO;
}

- (void)keyboardViewController:(A3NumberKeyboardViewController *)vc fractionButtonPressed:(UIButton *)button {
	A3UnitConverterTVDataCell *cell = (A3UnitConverterTVDataCell *) [_fmMoveTableView cellForCellSubview:(UIView *) self.firstResponder];
	__weak UITextField *textField = (UITextField *) vc.textInputTarget;
	if ([cell isKindOfClass:[A3UnitConverterTVDataCell class]]) {
		switch (cell.inputType) {
			case UnitInput_Normal:
				cell.inputType = UnitInput_Fraction;
				cell.value2Field.text = @"";
				[cell updateMultiTextFieldModeConstraintsWithEditingTextField:textField];
				_isSwitchingFractionMode = YES;
				[self addKeyboardAccessoryToTextField:textField];
				FNLOG();
				[textField resignFirstResponder];
				[textField becomeFirstResponder];
				FNLOG();
				_isSwitchingFractionMode = NO;
				[self.numberKeyboardViewController.fractionButton setSelected:YES];
				break;
			case UnitInput_Fraction:
				cell.inputType = UnitInput_Normal;
				_isSwitchingFractionMode = YES;
				textField.inputAccessoryView = nil;
				[textField resignFirstResponder];
				[textField becomeFirstResponder];
				_isSwitchingFractionMode = NO;
				[self.numberKeyboardViewController.fractionButton setSelected:NO];
				break;
			case UnitInput_FeetInch:
				break;
		}
	}
}

- (void)addKeyboardAccessoryToTextField:(UITextField *)field {
	UIToolbar *keyboardAccessoryToolbar = [UIToolbar new];
	[keyboardAccessoryToolbar sizeToFit];
	UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	UIBarButtonItem *prevButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Prev", @"Prev") style:UIBarButtonItemStylePlain target:self action:@selector(prevButtonPressed)];
	UIBarButtonItem *nextButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Next", @"Next") style:UIBarButtonItemStylePlain target:self action:@selector(nextButtonPressed)];
	[prevButtonItem setEnabled:[self isPreviousEntryExists]];
    prevButtonItem.tintColor = [A3AppDelegate instance].themeColor;
	[nextButtonItem setEnabled:[self isNextEntryExists]];
    nextButtonItem.tintColor = [A3AppDelegate instance].themeColor;
	keyboardAccessoryToolbar.items = @[flexibleSpace, prevButtonItem, nextButtonItem];
	field.inputAccessoryView = keyboardAccessoryToolbar;
}

- (void)keyboardViewController:(A3NumberKeyboardViewController *)vc plusMinusButtonPressed:(UIButton *)button {
	A3UnitConverterTVDataCell *cell = (A3UnitConverterTVDataCell *) [_fmMoveTableView cellForCellSubview:(UIView *) self.firstResponder];
	if ([cell isKindOfClass:[A3UnitConverterTVDataCell class]]) {
		__weak UITextField *textField = cell.valueField;
		if ([textField.text length]) {
			if ([[textField.text substringToIndex:1] isEqualToString:@"-"]) {
				textField.text = [cell.valueField.text stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
			} else {
				textField.text = [cell.valueField.text stringByReplacingCharactersInRange:NSMakeRange(0,0) withString:@"-"];
			}
		} else {
			textField.text = @"-";
		}
		[self updateTextFieldsWithSourceTextField:textField];
		[cell updateMultiTextFieldModeConstraintsWithEditingTextField:(UITextField *) self.firstResponder];
	}
}

- (void)A3KeyboardController:(id)controller clearButtonPressedTo:(UIResponder *)keyInputDelegate {
	UITextField *textField = (UITextField *) keyInputDelegate;
	textField.text = @"";
	_textBeforeEditingTextField = @"";
}

- (void)A3KeyboardController:(id)controller doneButtonPressedTo:(UIResponder *)keyInputDelegate {
    [self.numberKeyboardViewController.textInputTarget resignFirstResponder];
}

#pragma mark - History

- (void)putHistoryWithValue:(NSNumber *)value {
	UnitConvertItem *baseUnit = self.convertItems[0];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"source.type == %@", _unitType];
	NSArray *histories = [UnitHistory MR_findAllSortedBy:@"updateDate" ascending:NO withPredicate:predicate];

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
	history.uniqueID = [[NSUUID UUID] UUIDString];
	NSDate *keyDate = [NSDate date];
	history.updateDate = keyDate;
	history.source = baseUnit.item;
	history.value = value;

	NSInteger historyItemCount = MIN([self.convertItems count] - 2, 4);
	NSInteger idx = 0;
	NSMutableSet *targets = [[NSMutableSet alloc] init];
	for (; idx < historyItemCount; idx++) {
		UnitHistoryItem *item = [UnitHistoryItem MR_createEntity];
		UnitConvertItem *convertItem = self.convertItems[idx + 2];
		item.unit = convertItem.item;
		item.order = convertItem.order;
		[targets addObject:item];
	}
	history.targets = targets;

	[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];

	self.unitValue = nil;

	[self enableControls:YES];
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
		UITableViewCell<A3FMMoveTableViewSwipeCellDelegate> *swipedCell = (UITableViewCell <A3FMMoveTableViewSwipeCellDelegate> *) [_fmMoveTableView cellForRowAtIndexPath:indexPath];

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
		for (UITableViewCell<A3FMMoveTableViewSwipeCellDelegate>* cell in  cells)
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
-(void)shiftLeft:(UITableViewCell<A3FMMoveTableViewSwipeCellDelegate> *)cell {
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
