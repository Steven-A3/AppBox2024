//
//  A3UnitConverterConvertTableViewController.m
//  A3TeamWork
//
//  Created by kihyunkim on 13. 10. 12..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3UnitConverterConvertTableViewController.h"
#import "A3UnitConverterTVActionCell.h"
#import "A3UnitConverterTVEqualCell.h"
#import "A3UnitConverterTVDataCell.h"
#import "A3PasscodeViewControllerProtocol.h"
#import "A3AppDelegate.h"
#import "A3NumberKeyboardViewController.h"
#import "A3KeyboardDelegate.h"
#import "UIViewController+NumberKeyboard.h"
#import "NSMutableArray+A3Sort.h"
#import "A3UnitDataManager.h"
#import "UIViewController+MMDrawerController.h"
#import "UIViewController+A3Addition.h"
#import "A3UnitConverterHistoryViewController.h"
#import "A3UnitConverterSelectViewController.h"
#import "UnitHistory.h"
#import "UnitHistoryItem.h"
#import "TemperatureConverter.h"
#import "UITableView+utility.h"
#import "UIViewController+iPad_rightSideView.h"
#import "UIColor+A3Addition.h"
#import "A3InstructionViewController.h"
#import "A3UserDefaultsKeys.h"
#import "A3SyncManager.h"
#import "A3UserDefaults+A3Defaults.h"
#import "A3SyncManager+NSUbiquitousKeyValueStore.h"
#import "UIViewController+tableViewStandardDimension.h"
#import "A3FMMoveTableViewController.h"

#define kInchesPerFeet  (0.3048/0.0254)

@interface A3UnitConverterConvertTableViewController () <UITextFieldDelegate,
		A3UnitSelectViewControllerDelegate, A3UnitConverterFavoriteEditDelegate, A3UnitConverterMenuDelegate,
		UIPopoverControllerDelegate, UIActivityItemSource, FMMoveTableViewDelegate, FMMoveTableViewDataSource,
		A3InstructionViewControllerDelegate, A3ViewControllerProtocol>

@property (nonatomic, strong) FMMoveTableView *fmMoveTableView;
@property (nonatomic, strong) NSMutableSet *swipedCells;
@property (nonatomic, strong) NSMutableArray *convertItems;
@property (nonatomic, strong) NSMutableDictionary *equalItem;
@property (nonatomic, strong) NSMutableDictionary *adItem;
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
@property (nonatomic, strong) UINavigationController *modalNavigationController;
@property (nonatomic, strong) A3InstructionViewController *instructionViewController;
@property (nonatomic, weak) UITextField *editingTextField;
@property (nonatomic, strong) UIView *keyboardAccessoryView;
@property (nonatomic, copy) UIColor *textColorBeforeEditing;

@end

@implementation A3UnitConverterConvertTableViewController {
    BOOL 		_draggingFirstRow;
	NSUInteger 	_selectedRow;
    BOOL			_isAddingUnit;
    BOOL			_isShowMoreMenu;
    BOOL        _isTemperatureMode;
	BOOL 		_isSwitchingFractionMode;
	BOOL			_barButtonEnabled;
	BOOL			_isNumberKeyboardVisible;
	BOOL			_didPressClearKey;
	BOOL			_didPressNumberKey;
}

NSString *const A3UnitConverterDataCellID = @"A3UnitConverterDataCell";
NSString *const A3UnitConverterActionCellID = @"A3UnitConverterActionCell";
NSString *const A3UnitConverterEqualCellID = @"A3UnitConverterEqualCell";
NSString *const A3UnitConverterAdCellID = @"A3UnitConverterAdCell";

- (void)cleanUp{
	[self dismissInstructionViewController:nil];
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

	_barButtonEnabled = YES;

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

	[_fmMoveTableView registerClass:[A3CurrencyTableViewCell class] forCellReuseIdentifier:A3UnitConverterAdCellID];
	[_fmMoveTableView registerClass:[A3UnitConverterTVDataCell class] forCellReuseIdentifier:A3UnitConverterDataCellID];
	[_fmMoveTableView registerNib:[UINib nibWithNibName:@"A3UnitConverterTVActionCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:A3UnitConverterActionCellID];
	[_fmMoveTableView registerNib:[UINib nibWithNibName:@"A3UnitConverterTVEqualCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:A3UnitConverterEqualCellID];

	_fmMoveTableView.rowHeight = 84.0;
	_fmMoveTableView.separatorColor = A3UITableViewSeparatorColor;
	_fmMoveTableView.separatorInset = UIEdgeInsetsZero;
	_fmMoveTableView.contentInset = UIEdgeInsetsMake(0, 0, 70.0, 0);
	_fmMoveTableView.showsVerticalScrollIndicator = NO;
	if ([_fmMoveTableView respondsToSelector:@selector(cellLayoutMarginsFollowReadableWidth)]) {
		_fmMoveTableView.cellLayoutMarginsFollowReadableWidth = NO;
	}

	_isTemperatureMode = [[_dataManager categoryNameForID:_categoryID] isEqualToString:@"Temperature"];

	[self.decimalFormatter setLocale:[NSLocale currentLocale]];

	[self.view addSubview:self.addButton];

	[self.addButton makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(self.view.centerX);
		make.centerY.equalTo(self.view.bottom).with.offset(-32);
		make.width.equalTo(@44);
		make.height.equalTo(@44);
	}];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rightSubViewWillHide:) name:A3NotificationRightSideViewWillDismiss object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainMenuDidHide) name:A3NotificationMainMenuDidHide object:nil];
	[self registerContentSizeCategoryDidChangeNotification];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cloudStoreDidImport) name:A3NotificationCloudKeyValueStoreDidImport object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cloudStoreDidImport) name:A3NotificationCloudCoreDataStoreDidImport object:nil];

    [self setupBannerViewForAdUnitID:AdMobAdUnitIDUnitConverter keywords:@[@"Shopping"] gender:kGADGenderMale adSize:IS_IPHONE ? kGADAdSizeBanner : kGADAdSizeLeaderboard];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)applicationDidEnterBackground {
	[self dismissInstructionViewController:nil];
	[self dismissNumberKeyboard];
}

- (void)applicationWillResignActive {
	[self resignFirstResponder];
}

- (void)cloudStoreDidImport {
    if ([self editingObject]) {
        return;
    }

	_convertItems = nil;
    [self.fmMoveTableView reloadData];
    [self enableControls:_barButtonEnabled];
}

- (void)removeObserver {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationCloudKeyValueStoreDidImport object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationCloudCoreDataStoreDidImport object:nil];
	[self removeContentSizeCategoryDidChangeNotification];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationRightSideViewWillDismiss object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationMainMenuDidHide object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	[self dismissNumberKeyboard];
	
	if ([self isMovingFromParentViewController] || [self isBeingDismissed]) {
		FNLOG();
		[self clearEverything];
		[self removeObserver];
	}
}

- (void)prepareClose {
	self.fmMoveTableView.delegate = nil;
	self.fmMoveTableView.dataSource = nil;
	[self removeObserver];
}

- (BOOL)resignFirstResponder {
	[self.editingObject resignFirstResponder];
	[self dismissNumberKeyboard];

	NSString *startingAppName = [[A3UserDefaults standardUserDefaults] objectForKey:kA3AppsStartingAppName];
	if ([startingAppName length] && ![startingAppName isEqualToString:A3AppName_UnitConverter]) {
		[self dismissInstructionViewController:nil];
	}

	return [super resignFirstResponder];
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

	_barButtonEnabled = enable;
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
	self.tabBarController.tabBar.tintColor = enable ? nil : disabledColor;
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
    
	[self showLeftNavigationItems];

    [self enableControls:YES];

    [_fmMoveTableView reloadData];

	[[A3SyncManager sharedSyncManager] setInteger:_categoryID forKey:A3UnitConverterDefaultSelectedCategoryID state:A3DataObjectStateModified];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];

	if ([self isMovingToParentViewController]) {
        [self setupInstructionView];
		if (IS_IPHONE && IS_PORTRAIT) {
			[self leftBarButtonAppsButton];
		}
	}
	if ([self.navigationController.navigationBar isHidden]) {
		[self.navigationController setNavigationBarHidden:NO animated:NO];
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
	[self.editingObject resignFirstResponder];
	[self setEditingObject:nil];
	[self dismissMoreMenu];
}

- (void)showLeftNavigationItems
{
	FNLOG(@"%@", self.tabBarController);

    // 현재 more탭바인지 여부 체크
    if (_isFromMoreTableViewController) {
        self.navigationItem.leftItemsSupplementBackButton = YES;
        self.navigationItem.hidesBackButton = NO;

    } else {
        // 아님
        [self makeBackButtonEmptyArrow];
        self.navigationItem.hidesBackButton = YES;
    }
	if (IS_IPAD || IS_PORTRAIT) {
		[self leftBarButtonAppsButton];
	} else {
		self.navigationItem.leftBarButtonItem = nil;
		self.navigationItem.hidesBackButton = YES;
	}
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];

	if (IS_IPHONE && IS_LANDSCAPE) {
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

- (void)appsButtonAction:(UIBarButtonItem *)barButtonItem {
	[super appsButtonAction:barButtonItem];
	[self setEditingObject:nil];

	if (IS_IPHONE) {
		if ([_moreMenuView superview]) {
			[self dismissMoreMenu];
			[self rightButtonMoreButton];
		}
	} else {
		[self enableControls:![[A3AppDelegate instance] rootViewController_iPad].showLeftView];
	}
}

- (void)moreButtonAction:(UIBarButtonItem *)button {
	[self dismissNumberKeyboard];
	[self.editingObject resignFirstResponder];
	[self setEditingObject:nil];

	[self rightBarButtonDoneButton];

    UIButton *share = [self shareButton];
    UIButton *history = [self historyButton:NULL];
    UIButton *help = [self instructionHelpButton];
    
    history.enabled = [UnitHistory MR_countOfEntities] > 0 ? YES : NO;
    
	_moreMenuButtons = @[help, share, history];
	_moreMenuView = [self presentMoreMenuWithButtons:_moreMenuButtons pullDownView:_fmMoveTableView];
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
	[self dismissMoreMenuView:_moreMenuView pullDownView:_fmMoveTableView completion:^{
	}];
	[self.view removeGestureRecognizer:gestureRecognizer];
}

- (void)shareButtonAction:(id)sender {
	[self dismissNumberKeyboard];
	[self clearEverything];

	[self shareAll:sender];
}

- (void)historyButtonAction:(UIButton *)button {
	[self dismissNumberKeyboard];
	[self clearEverything];

	A3UnitConverterHistoryViewController *viewController = [[A3UnitConverterHistoryViewController alloc] initWithNibName:nil bundle:nil];
	viewController.dataManager = self.dataManager;
	if (IS_IPHONE) {
		_modalNavigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
		[self presentViewController:_modalNavigationController animated:YES completion:NULL];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(historyViewControllerDidDismiss) name:A3NotificationChildViewControllerDidDismiss object:viewController];
	} else {
		[self enableControls:NO];
		[[[A3AppDelegate instance] rootViewController_iPad] presentRightSideViewController:viewController];
	}
}

- (void)historyViewControllerDidDismiss {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationChildViewControllerDidDismiss object:_modalNavigationController.childViewControllers[0]];
	_modalNavigationController = nil;
}

- (NSMutableArray *)convertItems {
	if (nil == _convertItems) {
        _convertItems = [NSMutableArray arrayWithArray:[self.dataManager unitConvertItemsForCategoryID:_categoryID]];
        
		[self addEqualAndPlus];
		if (_adItem) {
            NSInteger position = [_convertItems count] > 3 ? 4 : [_convertItems count];
            [_convertItems insertObject:_adItem atIndex:position];
		}
	}
	return _convertItems;
}

- (void)addEqualAndPlus {
	[_convertItems insertObject:self.equalItem atIndex:1];
}

- (NSMutableDictionary *)equalItem {
	if (!_equalItem) {
		_equalItem = [NSMutableDictionary dictionaryWithDictionary:@{@"title":@"=",@"order":@""}];
	}
	return _equalItem;
}

- (NSMutableDictionary *)adItem {
	if (!_adItem) {
		_adItem = [@{@"title":@"Ad", @"order":@""} mutableCopy];
	}
	return _adItem;
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
	[[A3SyncManager sharedSyncManager] setObject:unitValue forKey:A3UnitConverterTableViewUnitValueKey state:A3DataObjectStateModified];
}

- (NSNumber *)unitValue {
    NSNumber *_unitValue = [[A3SyncManager sharedSyncManager] objectForKey:A3UnitConverterTableViewUnitValueKey];
    
    if (!_unitValue) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"categoryID == %@", @(_categoryID)];
        UnitHistory *history = [UnitHistory MR_findFirstWithPredicate:predicate sortedBy:@"updateDate" ascending:NO];
		if (history) {
            _unitValue = @(history.value.floatValue);
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
	if ([self.editingObject isFirstResponder]) {
		[self.editingObject resignFirstResponder];
		[self setEditingObject:nil];
		return;
	}

	if ([self.swipedCells.allObjects count]) {
		[self unSwipeAll];
		return;
	}

	_isAddingUnit = YES;
	UIViewController *viewController = [self unitAddViewController];

    _modalNavigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    [self presentViewController:_modalNavigationController animated:YES completion:NULL];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unitAddViewControllerDidDismiss) name:A3NotificationChildViewControllerDidDismiss object:viewController];
}

- (void)unitAddViewControllerDidDismiss {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationChildViewControllerDidDismiss object:_modalNavigationController.childViewControllers[0]];
	_modalNavigationController = nil;
}

- (A3UnitConverterSelectViewController *)unitAddViewController {
    A3UnitConverterSelectViewController *viewController = [[A3UnitConverterSelectViewController alloc] initWithNibName:nil bundle:nil];
	viewController.dataManager = _dataManager;
    viewController.editingDelegate = self;
    viewController.delegate = self;
    viewController.isModal = NO;    // modal
	viewController.categoryID = _categoryID;
	viewController.currentUnitID = NSNotFound;

	return viewController;
}

- (A3UnitConverterSelectViewController *)unitSelectViewControllerWithSelectedUnit:(NSInteger)selectedIndex {
	A3UnitConverterSelectViewController *viewController = [[A3UnitConverterSelectViewController alloc] initWithNibName:nil bundle:nil];
	viewController.dataManager = _dataManager;
	viewController.categoryID = _categoryID;
	viewController.delegate = self;
    viewController.editingDelegate = self;
    viewController.hidesBottomBarWhenPushed = YES;
	if (selectedIndex >= 0 && selectedIndex <= ([_convertItems count] - 1) ) {
        viewController.currentUnitID = [_convertItems[selectedIndex] unsignedIntegerValue];
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

static NSString *const A3V3InstructionDidShowForUnitConverter = @"A3V3InstructionDidShowForUnitConverter";

- (void)setupInstructionView
{
    if (![[A3UserDefaults standardUserDefaults] boolForKey:A3V3InstructionDidShowForUnitConverter]) {
        [self showInstructionView];
    }
}

- (void)showInstructionView
{
	[self dismissNumberKeyboard];
    [self dismissMoreMenu];

	[[A3UserDefaults standardUserDefaults] setBool:YES forKey:A3V3InstructionDidShowForUnitConverter];
	[[A3UserDefaults standardUserDefaults] synchronize];

    UIStoryboard *instructionStoryBoard = [UIStoryboard storyboardWithName:IS_IPHONE ? A3StoryboardInstruction_iPhone : A3StoryboardInstruction_iPad bundle:nil];
    _instructionViewController = [instructionStoryBoard instantiateViewControllerWithIdentifier:@"UnitConverter"];
    self.instructionViewController.delegate = self;

	UIWindow *mainWindow = [UIApplication sharedApplication].keyWindow;
	[mainWindow addSubview:self.instructionViewController.view];
	[mainWindow.rootViewController addChildViewController:self.instructionViewController];

    self.instructionViewController.view.frame = self.tabBarController.view.frame;
    self.instructionViewController.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |
	UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin |
	UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight;

	if (IS_IOS7) {
		[self rotateAccordingToStatusBarOrientationAndSupportedOrientations];

		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(statusBarFrameOrOrientationChanged:)
													 name:UIApplicationDidChangeStatusBarOrientationNotification
												   object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(statusBarFrameOrOrientationChanged:)
													 name:UIApplicationDidChangeStatusBarFrameNotification
												   object:nil];
	}
}

- (void)dismissInstructionViewController:(UIView *)view
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarFrameNotification object:nil];

	[self.instructionViewController.view removeFromSuperview];
	[self.instructionViewController removeFromParentViewController];
	self.instructionViewController = nil;
}

// All of the rotation handling is thanks to Håvard Fossli's - https://github.com/hfossli
// answer: http://stackoverflow.com/a/4960988/793916
#pragma mark - Handling rotation of instruction view

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
	if (IS_IPHONE) {
		return UIInterfaceOrientationMaskPortrait;
	} else {
		return UIInterfaceOrientationMaskAll;
	}
}

- (void)statusBarFrameOrOrientationChanged:(NSNotification *)notification {
	/*
	 This notification is most likely triggered inside an animation block,
	 therefore no animation is needed to perform this nice transition.
	 */
	[self rotateAccordingToStatusBarOrientationAndSupportedOrientations];
}

// And to his AGWindowView: https://github.com/hfossli/AGWindowView
// Without the 'desiredOrientation' method, using showLockscreen in one orientation,
// then presenting it inside a modal in another orientation would display the view in the first orientation.
- (UIInterfaceOrientation)desiredOrientation {
	UIInterfaceOrientation statusBarOrientation = [[UIApplication sharedApplication] statusBarOrientation];
	UIInterfaceOrientationMask statusBarOrientationAsMask = UIInterfaceOrientationMaskFromOrientation(statusBarOrientation);
	if(self.supportedInterfaceOrientations & statusBarOrientationAsMask) {
		return statusBarOrientation;
	}
	else {
		if(self.supportedInterfaceOrientations & UIInterfaceOrientationMaskPortrait) {
			return UIInterfaceOrientationPortrait;
		}
		else if(self.supportedInterfaceOrientations & UIInterfaceOrientationMaskLandscapeLeft) {
			return UIInterfaceOrientationLandscapeLeft;
		}
		else if(self.supportedInterfaceOrientations & UIInterfaceOrientationMaskLandscapeRight) {
			return UIInterfaceOrientationLandscapeRight;
		}
		else {
			return UIInterfaceOrientationPortraitUpsideDown;
		}
	}
}

- (void)rotateAccordingToStatusBarOrientationAndSupportedOrientations {
	UIInterfaceOrientation orientation = [self desiredOrientation];
	CGFloat angle = UIInterfaceOrientationAngleOfOrientation(orientation);
	CGAffineTransform transform = CGAffineTransformMakeRotation(angle);

	[self setIfNotEqualTransform: transform
						   frame: self.instructionViewController.view.window.bounds];
}

- (void)setIfNotEqualTransform:(CGAffineTransform)transform frame:(CGRect)frame {
	if(!CGAffineTransformEqualToTransform(self.instructionViewController.view.transform, transform)) {
		self.instructionViewController.view.transform = transform;
	}
	if(!CGRectEqualToRect(self.instructionViewController.view.frame, frame)) {
		self.instructionViewController.view.frame = frame;
	}
}

#pragma mark - Action

- (void)shareAll:(id)sender {
	self.shareTextList = [NSMutableArray new];

	NSUInteger sourceID = [_convertItems[[self firstUnitIndex]] unsignedIntegerValue];
	NSString *sourceShortName = NSLocalizedStringFromTable([_dataManager unitNameForUnitID:sourceID categoryID:_categoryID], @"unitShort", nil);
	for (NSInteger index = 1; index < _convertItems.count; index++) {
		if ([_convertItems[index] isKindOfClass:[NSNumber class]]) {
			NSUInteger targetID = [_convertItems[index] unsignedIntegerValue];
			NSString *targetShortName = NSLocalizedStringFromTable([_dataManager unitNameForUnitID:targetID categoryID:_categoryID], @"unitShort", nil);
			NSString *convertInfoText = @"";

			float rate;
            if ([self isSeparatedRateCategory]) {
                rate = conversionTable[_categoryID][targetID] / conversionTable[_categoryID][sourceID];
            }
            else {
                rate = conversionTable[_categoryID][sourceID] / conversionTable[_categoryID][targetID];
            }

			if (_isTemperatureMode) {
				float celsiusValue = [TemperatureConverter convertToCelsiusFromUnit:[_dataManager unitNameForUnitID:sourceID categoryID:_categoryID] andTemperature:self.unitValue.floatValue];
				float targetValue = [TemperatureConverter convertCelsius:celsiusValue toUnit:[_dataManager unitNameForUnitID:targetID categoryID:_categoryID]];
				convertInfoText = [NSString stringWithFormat:@"%@ %@ = %@ %@",
															 [self.decimalFormatter stringFromNumber:self.unitValue],
															 sourceShortName,
															 [self.decimalFormatter stringFromNumber:@(targetValue)],
															 targetShortName];
			}
			else {
                float targetValue;
                if (_categoryID == 8) {
                    targetValue = [self getFuelValue:sourceID value:self.unitValue.floatValue];
                    switch (targetID) {
                        case 0:
                        case 1:
                        case 3:
                        case 4:
                            targetValue = targetValue / conversionTable[_categoryID][targetID];
                            break;
                        case 2:
                        case 5:
                        case 6:
                            targetValue = conversionTable[_categoryID][targetID] / targetValue;
                            break;
                    }
                }
                else {
                    targetValue = self.unitValue.floatValue * rate;
                }

                if ([[_dataManager unitNameForUnitID:sourceID categoryID:_categoryID] isEqualToString:@"feet inches"]) {
                    float value = [self.unitValue floatValue];
                    int feet = (int)value;
                    float inch = (value -feet) * kInchesPerFeet;

                    convertInfoText = [NSString stringWithFormat:@"%@ = %@ %@",
									[NSString stringWithFormat:@"%@ft %@in",
													[self.decimalFormatter stringFromNumber:@(feet)],
													[self.decimalFormatter stringFromNumber:@(inch)]],
									[self.decimalFormatter stringFromNumber:@(targetValue)],
									targetShortName];
                }
                else if ([[_dataManager unitNameForUnitID:targetID categoryID:_categoryID] isEqualToString:@"feet inches"]) {
                    float value = self.unitValue.floatValue * rate;
                    int feet = (int)value;
                    float inch = (value -feet) * kInchesPerFeet;
                    
                    convertInfoText = [NSString stringWithFormat:@"%@ %@ = %@",
									[self.decimalFormatter stringFromNumber:self.unitValue],
									sourceShortName,
									[NSString stringWithFormat:@"%@ft %@in",
													[self.decimalFormatter stringFromNumber:@(feet)],
													[self.decimalFormatter stringFromNumber:@(inch)]]];
                }
                else {
                    convertInfoText = [NSString stringWithFormat:@"%@ %@ = %@ %@",
									[self.decimalFormatter stringFromNumber:self.unitValue],
									sourceShortName,
									[self.decimalFormatter stringFromNumber:@(targetValue)],
									targetShortName];
                }
			}
			[_shareTextList addObject:convertInfoText];
		}
	}

	if (IS_IPHONE) {
		UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[self] applicationActivities:nil];
        activityController.completionWithItemsHandler = ^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {
            [self enableControls:YES];
            FNLOG(@"completed dialog - activity: %@ - finished flag: %d", activityType, completed);
        };
		[self presentViewController:activityController animated:YES completion:NULL];
	}
    else {
        if ([sender isKindOfClass:[UIButton class]]) {
            _sharePopoverController = [self presentActivityViewControllerWithActivityItems:@[self] fromSubView:sender completionHandler:^(NSString *activityType, BOOL completed) {
				[self enableControls:YES];
			}];
        }
        else {
			UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[self] applicationActivities:nil];
            activityController.completionWithItemsHandler = ^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {
                [self enableControls:YES];
                FNLOG(@"completed dialog - activity: %@ - finished flag: %d", activityType, completed);
            };
            UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:activityController];
            [popoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            _sharePopoverController = popoverController;
        }
	}

	if (IS_IPAD) {
		[self enableControls:NO];
		[self.navigationItem.rightBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem *buttonItem, NSUInteger idx, BOOL *stop) {
			[buttonItem setEnabled:NO];
		}];
	}
}

- (void)shareActionForSourceIndex:(NSUInteger)sourceIdx targetIndex:(NSUInteger)targetIdx sender:(id)sender {
	self.shareTextList = [NSMutableArray new];

	NSString *convertInfoText = @"";
	NSUInteger sourceID = [_convertItems[sourceIdx] unsignedIntegerValue];
	NSString *sourceShortName = NSLocalizedStringFromTable([_dataManager unitNameForUnitID:sourceID categoryID:_categoryID], @"unitShort", nil);
	NSUInteger targetID = [_convertItems[targetIdx] unsignedIntegerValue];
	NSString *targetShortName = NSLocalizedStringFromTable([_dataManager unitNameForUnitID:targetID categoryID:_categoryID], @"unitShort", nil);

	float rate;
    if ([self isSeparatedRateCategory]) {
        rate = conversionTable[_categoryID][targetID] / conversionTable[_categoryID][sourceID];
    }
    else {
        rate = conversionTable[_categoryID][sourceID] / conversionTable[_categoryID][targetID];
    }

	if (_isTemperatureMode) {
		float celsiusValue = [TemperatureConverter convertToCelsiusFromUnit:[_dataManager unitNameForUnitID:sourceID categoryID:_categoryID] andTemperature:self.unitValue.floatValue];
		float targetValue = [TemperatureConverter convertCelsius:celsiusValue toUnit:[_dataManager unitNameForUnitID:targetID categoryID:_categoryID]];
		convertInfoText = [NSString stringWithFormat:@"%@ %@ = %@ %@",
						[self.decimalFormatter stringFromNumber:self.unitValue],
						sourceShortName,
						[self.decimalFormatter stringFromNumber:@(targetValue)],
						targetShortName];
	}
	else {
		float targetValue = self.unitValue.floatValue * rate;
        if (_categoryID == 8) {
            targetValue = [self getFuelValue:sourceID value:self.unitValue.floatValue];
            switch (targetID) {
                case 0:
                case 1:
                case 3:
                case 4:
                    targetValue = targetValue / conversionTable[_categoryID][targetID];
                    break;
                case 2:
                case 5:
                case 6:
                    targetValue = conversionTable[_categoryID][targetID] / targetValue;
                    break;
            }
        }

        if ([[_dataManager unitNameForUnitID:sourceID categoryID:_categoryID] isEqualToString:@"feet inches"]) {
            float value = [self.unitValue floatValue];
            int feet = (int)value;
            float inch = (value -feet) * kInchesPerFeet;
            
            convertInfoText = [NSString stringWithFormat:@"%@ = %@ %@",
							[NSString stringWithFormat:@"%@ft %@in",
											[self.decimalFormatter stringFromNumber:@(feet)],
											[self.decimalFormatter stringFromNumber:@(inch)]],
							[self.decimalFormatter stringFromNumber:@(targetValue)],
							targetShortName];
        }
        else if ([[_dataManager unitNameForUnitID:targetIdx categoryID:_categoryID] isEqualToString:@"feet inches"]) {
            float value = self.unitValue.floatValue * rate;
            int feet = (int)value;
            float inch = (value -feet) * kInchesPerFeet;
            
            convertInfoText = [NSString stringWithFormat:@"%@ %@ = %@",
							[self.decimalFormatter stringFromNumber:self.unitValue],
							sourceShortName,
							[NSString stringWithFormat:@"%@ft %@in",
											[self.decimalFormatter stringFromNumber:@(feet)],
											[self.decimalFormatter stringFromNumber:@(inch)]]];
        }
        else {
            convertInfoText = [NSString stringWithFormat:@"%@ %@ = %@ %@",
							[self.decimalFormatter stringFromNumber:self.unitValue],
							sourceShortName,
							[self.decimalFormatter stringFromNumber:@(targetValue)],
							targetShortName];
        }
	}
	[_shareTextList addObject:convertInfoText];

	_sharePopoverController = [self presentActivityViewControllerWithActivityItems:@[self] fromSubView:sender completionHandler:^(NSString *activityType, BOOL completed) {
		[self enableControls:YES];
	}];
	if (IS_IPAD) {
		[self enableControls:NO];

		[self.navigationItem.rightBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem *buttonItem, NSUInteger idx, BOOL *stop) {
			[buttonItem setEnabled:NO];
		}];
	}
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
        for (int i=0; i<_shareTextList.count; i++) {
            [txt appendString:_shareTextList[i]];
            [txt appendString:@"<br/>"];
        }
		return [self shareMailMessageWithHeader:NSLocalizedString(@"I'd like to share a conversion with you.", nil)
									   contents:txt
										   tail:NSLocalizedString(@"You can convert more in the AppBox Pro.", nil)];
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
    return NSLocalizedString(@"Share Unit Converter data", @"Share unit converting data");
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(FMMoveTableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	// Return the number of rows in the section.

	NSInteger numberOfRows = [self.convertItems count];

	if (tableView.movingIndexPath && tableView.movingIndexPath.section != tableView.initialIndexPathForMovingRow.section)
	{
		if (section == tableView.movingIndexPath.section) {
			numberOfRows++;
		}
		else if (section == tableView.initialIndexPathForMovingRow.section) {
			numberOfRows--;
		}
	}

	return numberOfRows;
}

- (CGFloat)tableView:(FMMoveTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (tableView.movingIndexPath != nil) {
		indexPath = [tableView adaptedIndexPathForRowAtIndexPath:indexPath];
	}

	if (self.convertItems[indexPath.row] == _adItem) {
		return [self bannerHeight];
	}
	return 84;
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
	} else if (_convertItems[indexPath.row] == _adItem) {
		cell = [tableView dequeueReusableCellWithIdentifier:A3UnitConverterAdCellID];
        UIView *bannerView = [self bannerView];
        [cell addSubview:bannerView];

		[bannerView remakeConstraints:^(MASConstraintMaker *make) {
			make.edges.equalTo(cell).insets(UIEdgeInsetsMake(0, 0, 1, 0));
		}];
	} else if ([ [self.convertItems objectAtIndex:indexPath.row] isKindOfClass:[NSNumber class] ]) {
		A3UnitConverterTVDataCell *dataCell;
		dataCell = [tableView dequeueReusableCellWithIdentifier:A3UnitConverterDataCellID];

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

	NSUInteger targetID = [self.convertItems[dataIndex] unsignedIntegerValue];

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
	NSString *targetUnitName = [_dataManager unitNameForUnitID:targetID categoryID:_categoryID];
	[self.text1Fields setObject:dataCell.valueField forKey:targetUnitName];
	[self.text2Fields setObject:dataCell.value2Field forKey:targetUnitName];

	BOOL isFeetInchMode = NO;
	if ([targetUnitName isEqualToString:@"feet inches"]) {
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

		if (IS_IPHONE && dataCell.inputType == UnitInput_FeetInch) {
			dataCell.codeLabel.text = NSLocalizedStringFromTable(targetUnitName, @"unitShort", nil);
			dataCell.rateLabel.text = NSLocalizedStringFromTable(targetUnitName, @"unit", nil);
		} else {
			dataCell.codeLabel.text = NSLocalizedStringFromTable(targetUnitName, @"unit", nil);
			dataCell.rateLabel.text = NSLocalizedStringFromTable(targetUnitName, @"unitShort", nil);
		}
	}
    else {
		dataCell.valueField.textColor = [UIColor blackColor];
		dataCell.value2Field.textColor = [UIColor blackColor];
		dataCell.valueLabel.textColor = [UIColor blackColor];
		dataCell.value2Label.textColor = [UIColor blackColor];
		dataCell.rateLabel.text = @"";

		float conversionRate = 0;

		NSUInteger sourceID = [_convertItems[[self firstUnitIndex]] unsignedIntegerValue];
		NSString *sourceUnitName = [_dataManager unitNameForUnitID:sourceID categoryID:_categoryID];
		if (_isTemperatureMode) {
			// 먼저 입력된 값을 섭씨기준의 온도로 변환한다.
			// 섭씨온도를 해당 unit값으로 변환한다
			float celsiusValue = [TemperatureConverter convertToCelsiusFromUnit:sourceUnitName andTemperature:value.floatValue];
			value = @([TemperatureConverter convertCelsius:celsiusValue toUnit:targetUnitName]);
		}
		else {
            if (_categoryID == 8) { // Fuel Consumption
                float targetValue = value.floatValue;
                targetValue = [self getFuelValue:sourceID value:targetValue];
                switch (targetID) {
                    case 0:
                    case 1:
                    case 3:
                    case 4:
                        targetValue = targetValue / conversionTable[_categoryID][targetID];
                        break;
                    case 2:
                    case 5:
                    case 6:
                        targetValue = conversionTable[_categoryID][targetID] / targetValue;
                        break;
                }
                value = @(targetValue);
            } else {
                if ([self isSeparatedRateCategory]) {
                    conversionRate = conversionTable[_categoryID][targetID] / conversionTable[_categoryID][sourceID];
                }
                else {
                    conversionRate = conversionTable[_categoryID][sourceID] / conversionTable[_categoryID][targetID];
                }
                value = @(value.floatValue * conversionRate);
            }
		}

		// code 및 rate 정보 표시
		dataCell.codeLabel.text = NSLocalizedStringFromTable(targetUnitName, @"unit", nil);
		// 온도 모드, Fuel Consumption 에서는 rate 값에 일정 비율이 없으므로 표시하지 않는다.
		if (_isTemperatureMode) {
			dataCell.rateLabel.text = [TemperatureConverter rateStringFromTemperUnit:sourceUnitName
																		toTemperUnit:targetUnitName];
		}
        else if (_categoryID == 8) {
            dataCell.rateLabel.text = [NSString stringWithFormat:@"%@", NSLocalizedStringFromTable(targetUnitName, @"unitShort", nil)];
        }
		else {
			dataCell.rateLabel.text = [NSString stringWithFormat:@"%@, %@ = %@",
							NSLocalizedStringFromTable(targetUnitName, @"unitShort", nil),
							NSLocalizedString(@"rate", nil),
							[self.decimalFormatter stringFromNumber:@(conversionRate)]];
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

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

	[self dismissNumberKeyboard];

	if ([self.swipedCells.allObjects count]) {
		[self unSwipeAll];
		return;
	}

	[self clearEverything];

	id object = self.convertItems[indexPath.row];

	if (object != _equalItem && object != _adItem) {
		_selectedRow = indexPath.row;
		_isAddingUnit = NO;
		A3UnitConverterSelectViewController *viewController = [self unitSelectViewControllerWithSelectedUnit:_selectedRow];
		if (IS_IPHONE) {
			viewController.isModal = YES;
			[self.navigationController pushViewController:viewController animated:YES];
		}
        else {
			viewController.isModal = YES;
            _modalNavigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
            [self presentViewController:_modalNavigationController animated:YES completion:NULL];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unitAddViewControllerDidDismiss) name:A3NotificationChildViewControllerDidDismiss object:viewController];
		}
	}
	else {

	}
}

#pragma mark - FMMoveTableView

- (void)moveTableView:(FMMoveTableView *)tableView moveRowFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	[_convertItems exchangeObjectAtIndex:fromIndexPath.row withObjectAtIndex:toIndexPath.row];
	[_dataManager replaceConvertItems:[_convertItems copy] forCategory:_categoryID];

	dispatch_async(dispatch_get_main_queue(), ^{
		[_convertItems removeObject:_equalItem];
		[_convertItems removeObject:_adItem];
		
		[_convertItems insertObject:_equalItem atIndex:1];
		if (_adItem) {
            NSInteger position = [_convertItems count] > 3 ? 4 : [_convertItems count];
			[_convertItems insertObject:_adItem atIndex:position];
		}
		[_fmMoveTableView reloadData];
	});
}

- (BOOL)moveTableView:(FMMoveTableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	return indexPath.row != 1 && (self.convertItems[indexPath.row] != _adItem);
}

- (NSIndexPath *)moveTableView:(FMMoveTableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
	if (proposedDestinationIndexPath.row == 1) {
		return [NSIndexPath indexPathForRow:2 inSection:proposedDestinationIndexPath.section];
	}
	return proposedDestinationIndexPath;
}

#pragma mark - A3UnitSelectViewControllerDelegate

- (void)didCancelUnitSelect
{
	if (IS_IPAD) {
		[self rightBarItemsEnabling:YES];
	}
}

- (void)selectViewController:(UIViewController *)viewController didSelectCategoryID:(NSUInteger)categoryID unitID:(NSUInteger)unitID {
	if (IS_IPAD) {
		[self rightBarItemsEnabling:YES];
	}

	if (_isAddingUnit) {
		if ([_convertItems containsObject:@(unitID)]) {
			return;
		}

		[_convertItems addObject:@(unitID)];
		[_dataManager addUnitToConvertItemForUnit:unitID categoryID:_categoryID];

		[_fmMoveTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[_convertItems count] - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationRight];

		double delayInSeconds = 0.3;
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
		dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
			[_fmMoveTableView reloadData];
		});
	}
	else {
		// 선택된 unitItem이 이미 convertItems에 추가된 unit이면, swap을 한다.
		NSInteger existingIndex = [_convertItems indexOfObject:@(unitID)];
		if (existingIndex != NSNotFound) {
			if (_selectedRow == 0) {
				NSIndexPath *sourceIndexPath = [NSIndexPath indexPathForRow:existingIndex inSection:0];
				NSIndexPath *targetIndexPath;
				if (sourceIndexPath.row == 0) {
					targetIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
				} else {
					targetIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
				}

				[self swapCellOfFromIndexPath:sourceIndexPath toIndexPath:targetIndexPath];
			}
			else {
				// 선택된 unitItem이 첫번째 unit이면, swap한다.
				if (existingIndex == 0) {
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
					NSIndexPath *targetIndexPath = [NSIndexPath indexPathForRow:existingIndex inSection:0];

					[self swapCellOfFromIndexPath:sourceIndexPath toIndexPath:targetIndexPath];
				}
			}
		}
				// 아니면, 현재 unit을 교체한다.
		else {
			[_convertItems replaceObjectAtIndex:_selectedRow withObject:@(unitID)];
			[_dataManager replaceConvertItems:[_convertItems copy] forCategory:_categoryID];

			[_fmMoveTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_selectedRow inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];

			double delayInSeconds = 0.3;
			dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
			dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
				[_fmMoveTableView reloadData];
			});
		}
	}
}

#pragma mark - A3UnitConverterFavoriteEditDelegate

- (void)favoritesEdited
{
    
}

#pragma mark - UITextField delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	if (IS_IPHONE && IS_LANDSCAPE) return NO;

	A3UnitConverterTVDataCell *cell = (A3UnitConverterTVDataCell *) [_fmMoveTableView cellForCellSubview:textField];
	if (!cell) return NO;
	NSIndexPath *indexPath = [_fmMoveTableView indexPathForCell:cell];
    [self dismissMoreMenu];

	if(indexPath.row == 0) {
		[self unSwipeAll];
		if (_isNumberKeyboardVisible) {
			if (_editingTextField != textField) {
				_isSwitchingFractionMode = YES;
				[self textFieldDidEndEditing:_editingTextField];
				_editingTextField.textColor = [UIColor colorWithRed:199.0/255.0 green:199.0/255.0 blue:205.0/255.0 alpha:1.0];
				[self textFieldDidBeginEditing:textField];
				textField.textColor = [[A3AppDelegate instance] themeColor];
				_isSwitchingFractionMode = NO;

			}
		} else {
			if (cell.inputType == UnitInput_FeetInch) {
				if (cell.valueField == textField) {
					self.value1BeforeEditingTextField = [textField text];
					cell.valueField.textColor = [[A3AppDelegate instance] themeColor];
					cell.value2Field.textColor = [UIColor colorWithRed:199.0/255.0 green:199.0/255.0 blue:205.0/255.0 alpha:1.0];
				}
				else if (cell.value2Field == textField) {
					self.value2BeforeEditingTextField = [textField text];
					cell.valueField.textColor = [UIColor colorWithRed:199.0/255.0 green:199.0/255.0 blue:205.0/255.0 alpha:1.0];
					cell.value2Field.textColor = [[A3AppDelegate instance] themeColor];
				}
			}
			[self presentNumberKeyboardForTextField:textField];
		}
		return NO;
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

	self.editingObject = textField;
	_editingTextField = textField;

	A3UnitConverterTVDataCell *cell = (A3UnitConverterTVDataCell *) [_fmMoveTableView cellForCellSubview:textField];
	if (!cell) return;

	if (!_isSwitchingFractionMode && [textField.text length]) {
		self.textBeforeEditingTextField = textField.text;
		float value = [[self.decimalFormatter numberFromString:textField.text] floatValue];
        
        if (cell.inputType == UnitInput_FeetInch) {
            // 0.3048, 0.0254
            // feet inch 값을 inch값으로 변화시킨다.
            float feet = [[self.decimalFormatter numberFromString:cell.valueField.text] floatValue];
            float inch = [[self.decimalFormatter numberFromString:cell.value2Field.text] floatValue];
            value = feet + inch/kInchesPerFeet;
            FNLOG(@"Feet : %f / Inch : %f", feet, inch);
            FNLOG(@"Calculated : %f", value);
        }
        
        if ([self.unitValue floatValue] != 1.0 || ([self.unitValue floatValue] != 1.0 && [UnitHistory MR_countOfEntities] > 0)) {
			[self putHistoryWithValue:@(value)];
		}
	}

    textField.text = [self.decimalFormatter stringFromNumber:@0];
    
	A3NumberKeyboardViewController *keyboardVC = self.numberKeyboardViewController;
	keyboardVC.textInputTarget = textField;
	
	switch (cell.inputType) {
		case UnitInput_Normal:
			textField.inputAccessoryView = nil;
			break;
		case UnitInput_Fraction:
			[keyboardVC.fractionButton setSelected:YES];
			[self addKeyboardAccessoryView];
			break;
		case UnitInput_FeetInch:
			[keyboardVC.fractionButton setTitle:@"" forState:UIControlStateNormal];
			[keyboardVC.fractionButton setEnabled:NO];
			[self addKeyboardAccessoryView];
			break;
	}
	if (cell.inputType != UnitInput_Normal) {
		if (cell.valueField == textField) {
			cell.valueField.textColor = [[A3AppDelegate instance] themeColor];
			cell.value2Field.textColor = [UIColor colorWithRed:199.0/255.0 green:199.0/255.0 blue:205.0/255.0 alpha:1.0];
		}
		else if (cell.value2Field == textField) {
			cell.valueField.textColor = [UIColor colorWithRed:199.0/255.0 green:199.0/255.0 blue:205.0/255.0 alpha:1.0];
			cell.value2Field.textColor = [[A3AppDelegate instance] themeColor];
		}
	} else {
		cell.valueField.textColor = [[A3AppDelegate instance] themeColor];
	}

	[self updateTextFieldsWithSourceTextField:textField];
	[cell updateMultiTextFieldModeConstraintsWithEditingTextField:textField];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];

	[self setEditingObject:nil];

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

	if (!_didPressClearKey && !_didPressNumberKey) {
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
	
	cell.valueField.textColor = [[A3AppDelegate instance] themeColor];
	cell.value2Field.textColor = [[A3AppDelegate instance] themeColor];
}

- (void)textFieldDidChange:(NSNotification *)notification {
	UITextField *textField = [notification object];
	[self updateTextFieldsWithSourceTextField:textField];

	A3UnitConverterTVDataCell *cell = (A3UnitConverterTVDataCell *) [_fmMoveTableView cellForCellSubview:textField];
	[cell updateMultiTextFieldModeConstraintsWithEditingTextField:textField];
}

- (NSUInteger)indexForUnitName:(NSString *)name {
	NSUInteger targetIndex = [self.convertItems indexOfObjectPassingTest:^BOOL(NSNumber *object, NSUInteger idx, BOOL *stop) {
		return [object isKindOfClass:[NSNumber class]] &&
				[[_dataManager unitNameForUnitID:[object integerValue] categoryID:_categoryID] isEqualToString:name];
	}];
	return targetIndex;
}

- (NSUInteger)firstUnitIndex {
	return [self.convertItems indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
		return [obj isKindOfClass:[NSNumber class]];
	}];
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
        if ([cell.valueField.text floatValue] > 0 || [cell.value2Field.text floatValue] > 0) {
            self.unitValue = @(fromValue);
        }
        else {
            fromValue = [self.unitValue floatValue];
        }
    }
    else {
        self.unitValue = @(fromValue);
    }

	NSUInteger sourceID = [_convertItems[[self firstUnitIndex]] unsignedIntegerValue];
	NSString *zeroKey = [_dataManager unitNameForUnitID:sourceID categoryID:_categoryID];

	for (NSString *key in [_text1Fields allKeys]) {

		if ([zeroKey isEqualToString:key]) {
			continue;
		}

		UITextField *targetTextField = _text1Fields[key];

		NSUInteger targetIndex = [self indexForUnitName:key];
		if (targetIndex != NSNotFound) {
			NSUInteger targetID = [_convertItems[targetIndex] unsignedIntegerValue];
			NSString *targetUnitName = [_dataManager unitNameForUnitID:targetID categoryID:_categoryID];

			if (_isTemperatureMode) {
				// 먼저 입력된 값을 섭씨기준의 온도로 변환한다.
				// 섭씨온도를 해당 unit값으로 변환한다
				float celsiusValue = [TemperatureConverter convertToCelsiusFromUnit:zeroKey andTemperature:fromValue];
				float targetValue = [TemperatureConverter convertCelsius:celsiusValue toUnit:targetUnitName];
				targetTextField.text = [self.decimalFormatter stringFromNumber:@(targetValue)];
			}
            else if (_categoryID == 8) {
                float value = [self getFuelValue:sourceID value:fromValue];
                switch (targetID) {
                    case 0:
                    case 1:
                    case 3:
                    case 4:
                        value = value / conversionTable[_categoryID][targetID];
                        break;
                    case 2:
                    case 5:
                    case 6:
                        value = conversionTable[_categoryID][targetID] / value;
                        break;
                }
                targetTextField.text = [self.decimalFormatter stringFromNumber:@(value)];
            }
			else
            {
				BOOL isFeetInchMode = NO;
				if ([key isEqualToString:@"feet inches"]) {
					isFeetInchMode = YES;
				}
                
				float rate;
                if ([self isSeparatedRateCategory]) {
                    rate = (float) (conversionTable[_categoryID][targetID] / conversionTable[_categoryID][sourceID]);
                }
                else {
                    rate = (float) (conversionTable[_categoryID][sourceID] / conversionTable[_categoryID][targetID]);
                }

				if (isFeetInchMode) {
					// 0.3048, 0.0254
					// feet 계산
					float value = fromValue * rate;
					int feet = (int)value;
					float inch = (value -feet) * kInchesPerFeet;
					targetTextField.text = [self.decimalFormatter stringFromNumber:@(feet)];
					UITextField *targetValue2TextFiled = _text2Fields[key];
					targetValue2TextFiled.text = [self.decimalFormatter stringFromNumber:@(inch)];
				}
				else {
					targetTextField.text = [self.decimalFormatter stringFromNumber:@(fromValue*rate)];
				}
			}
			targetTextField.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:65];
		}
	}
}

- (float)getFuelValue:(NSUInteger)type value:(float)value{
    double result = 0.0;
    switch (type) {
        case 0:
        case 1:
        case 3:
        case 4:
            result = conversionTable[_categoryID][type] * value;
            break;
        case 2:
        case 5:
        case 6:
            result = conversionTable[_categoryID][type] / value;
            break;
    }
    return result;
}

- (void)presentNumberKeyboardForTextField:(UITextField *)textField {
	if (_isNumberKeyboardVisible) {
		return;
	}
	_isNumberKeyboardVisible = YES;

	self.numberKeyboardViewController = [self simpleUnitConverterNumberKeyboard];
	
	A3NumberKeyboardViewController *keyboardViewController = self.numberKeyboardViewController;

	CGRect bounds = [A3UIDevice screenBoundsAdjustedWithOrientation];
	CGFloat keyboardHeight = keyboardViewController.keyboardHeight;
	UIView *keyboardView = keyboardViewController.view;
	[self.tabBarController.view addSubview:keyboardView];

	keyboardViewController.delegate = self;
	keyboardViewController.keyboardType = A3NumberKeyboardTypeCurrency;
	keyboardViewController.keyboardType = A3NumberKeyboardTypeReal;

	[self textFieldDidBeginEditing:textField];

	keyboardViewController.textInputTarget = textField;

	_didPressClearKey = NO;
	_didPressNumberKey = NO;
	
	keyboardView.frame = CGRectMake(0, bounds.size.height, bounds.size.width, keyboardHeight);
	
	if (_keyboardAccessoryView) {
		_keyboardAccessoryView.frame = CGRectMake(0, keyboardView.frame.origin.y - 45, bounds.size.width, 45);
	}
	
	[UIView animateWithDuration:0.3 animations:^{
		CGRect frame = keyboardView.frame;
		frame.origin.y -= keyboardHeight;
		keyboardView.frame = frame;
		
		if (_keyboardAccessoryView) {
			frame = _keyboardAccessoryView.frame;
			frame.origin.y -= keyboardHeight;
			_keyboardAccessoryView.frame = frame;
		}
	} completion:^(BOOL finished) {
		[self addNumberKeyboardNotificationObservers];
	}];
	
}

- (void)dismissNumberKeyboard {
	if (!_isNumberKeyboardVisible) {
		return;
	}

	[self textFieldDidEndEditing:_editingTextField];
	
	A3NumberKeyboardViewController *keyboardViewController = self.numberKeyboardViewController;
	UIView *keyboardView = keyboardViewController.view;
	[UIView animateWithDuration:0.3 animations:^{
		CGFloat keyboardHeight = keyboardViewController.keyboardHeight;
		CGRect frame = keyboardView.frame;
		frame.origin.y += keyboardHeight;
		keyboardView.frame = frame;
		
		if (_keyboardAccessoryView) {
			CGRect frame = _keyboardAccessoryView.frame;
			frame.origin.y += keyboardHeight + _keyboardAccessoryView.frame.size.height;
			_keyboardAccessoryView.frame = frame;
		}
	} completion:^(BOOL finished) {
		[keyboardView removeFromSuperview];
		[keyboardViewController removeFromParentViewController];
		self.numberKeyboardViewController = nil;
		_isNumberKeyboardVisible = NO;
		
		[_keyboardAccessoryView removeFromSuperview];
		_keyboardAccessoryView = nil;
	}];
}

#pragma mark - A3UnitConverterMenuDelegate

- (BOOL)isCategoryNameEqualWithName:(NSString *)name
{
    return [[_dataManager categoryNameForID:_categoryID] isEqualToString:name];
}

- (BOOL)isSeparatedRateCategory
{
    if ([self isCategoryNameEqualWithName:@"Cooking"]) {
        return YES;
    }
    
    return NO;
}

- (void)menuAdded
{
    [self clearEverything];
}

- (void)swapCellOfFromIndexPath:(NSIndexPath *)fromIp toIndexPath:(NSIndexPath *)toIp
{
	[_convertItems exchangeObjectAtIndex:fromIp.row withObjectAtIndex:toIp.row];
	[_dataManager replaceConvertItems:[_convertItems copy] forCategory:_categoryID];

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
		targetIndexPath = [NSIndexPath indexPathForRow:_adItem ? 3 : 2 inSection:0];
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

    NSInteger numberOfUnits = [_convertItems count];
    if (_adItem && [_convertItems containsObject:_adItem]) numberOfUnits--;
    if (_equalItem && [_convertItems containsObject:_equalItem]) numberOfUnits--;
    
	if (numberOfUnits <= 2) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:NSLocalizedString(@"You need two units at least to convert values.", nil)
                                                       delegate:nil
											  cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
											  otherButtonTitles:nil];
		[alert show];
		return;
	}

	NSIndexPath *indexPath = [_fmMoveTableView indexPathForCell:cell];
	NSUInteger targetID = [self.convertItems[indexPath.row] unsignedIntegerValue];
	NSString *targetName = [_dataManager unitNameForUnitID:targetID categoryID:_categoryID];
	NSNumber *convertItem = self.convertItems[indexPath.row];
	if ([convertItem isKindOfClass:[NSNumber class]]) {
		[self.text1Fields removeObjectForKey:targetName];
		[self.text2Fields removeObjectForKey:targetName];

		[self.convertItems removeObjectAtIndex:indexPath.row];

		[_fmMoveTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
		[_dataManager replaceConvertItems:[self.convertItems copy] forCategory:_categoryID];

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
	UIView *viewInRespond = (UIView *) self.editingObject;
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
	UIView *viewInRespond = (UIView *) self.editingObject;
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
	UIView *viewInRespond = (UIView *) self.editingObject;
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
	
	[_keyboardAccessoryView removeFromSuperview];
	_keyboardAccessoryView = nil;
	[self addKeyboardAccessoryView];
}

- (void)nextButtonPressed{
    A3UnitConverterTVDataCell *cell = (A3UnitConverterTVDataCell *)[_fmMoveTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
	UIView *viewInRespond = (UIView *) self.editingObject;
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
	
	[_keyboardAccessoryView removeFromSuperview];
	_keyboardAccessoryView = nil;
	[self addKeyboardAccessoryView];
}

- (void)keyboardViewController:(A3NumberKeyboardViewController *)vc fractionButtonPressed:(UIButton *)button {
	A3UnitConverterTVDataCell *cell = (A3UnitConverterTVDataCell *) [_fmMoveTableView cellForCellSubview:(UIView *) self.editingObject];
	__weak UITextField *textField = (UITextField *) vc.textInputTarget;
	if ([cell isKindOfClass:[A3UnitConverterTVDataCell class]]) {
		switch (cell.inputType) {
			case UnitInput_Normal:
				[cell setInputType:UnitInput_Fraction];
				cell.value2Field.text = @"";
				[self addKeyboardAccessoryView];
				[textField reloadInputViews];
				[self.numberKeyboardViewController.fractionButton setSelected:YES];
				break;
			case UnitInput_Fraction:
				[cell setInputType:UnitInput_Normal];
				_isSwitchingFractionMode = YES;
				[textField reloadInputViews];
				if (textField == cell.value2Field) {
					[self textFieldDidEndEditing:textField];
					[self textFieldDidBeginEditing:cell.valueField];
				}
				_isSwitchingFractionMode = NO;
				[_keyboardAccessoryView removeFromSuperview];
				_keyboardAccessoryView = nil;
				[self.numberKeyboardViewController.fractionButton setSelected:NO];
				break;
			case UnitInput_FeetInch:
				break;
		}
	}
}

- (UIView *)keyboardAccessoryView {
	UIToolbar *keyboardAccessoryToolbar = [UIToolbar new];
	[keyboardAccessoryToolbar sizeToFit];
	UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

	UIBarButtonItem *prevButtonItem;
	UIBarButtonItem *nextButtonItem;

	if ([A3UIDevice shouldUseImageForPrevNextButton]) {
		UIButton *prevButton = [UIButton buttonWithType:UIButtonTypeSystem];
		[prevButton setTitle:@"o" forState:UIControlStateNormal];
		prevButton.titleLabel.font = [UIFont fontWithName:@"appbox" size:38];
		[prevButton addTarget:self action:@selector(prevButtonPressed) forControlEvents:UIControlEventTouchUpInside];
		[prevButton sizeToFit];
		prevButton.tintColor = [[A3AppDelegate instance] themeColor];
		prevButtonItem = [[UIBarButtonItem alloc] initWithCustomView:prevButton];

		UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeSystem];
		[nextButton setTitle:@"n" forState:UIControlStateNormal];
		nextButton.titleLabel.font = [UIFont fontWithName:@"appbox" size:38];
		[nextButton addTarget:self action:@selector(nextButtonPressed) forControlEvents:UIControlEventTouchUpInside];
		[nextButton sizeToFit];
		nextButton.tintColor = [[A3AppDelegate instance] themeColor];
		nextButtonItem = [[UIBarButtonItem alloc] initWithCustomView:nextButton];
	} else {
		prevButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Prev", @"Prev") style:UIBarButtonItemStylePlain target:self action:@selector(prevButtonPressed)];
		nextButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Next", @"Next") style:UIBarButtonItemStylePlain target:self action:@selector(nextButtonPressed)];
	}
	[prevButtonItem setEnabled:[self isPreviousEntryExists]];
    prevButtonItem.tintColor = [A3AppDelegate instance].themeColor;
	[nextButtonItem setEnabled:[self isNextEntryExists]];
    nextButtonItem.tintColor = [A3AppDelegate instance].themeColor;
	keyboardAccessoryToolbar.items = @[flexibleSpace, prevButtonItem, nextButtonItem];

	return keyboardAccessoryToolbar;
}

- (void)addKeyboardAccessoryView {
	if (_keyboardAccessoryView) {
		return;
	}
	UIView *accessoryView = [self keyboardAccessoryView];
	self.keyboardAccessoryView = accessoryView;
	CGRect keyboardFrame = self.numberKeyboardViewController.view.frame;
	accessoryView.frame = CGRectMake(0, keyboardFrame.origin.y - 45, keyboardFrame.size.width, 45);
	[self.tabBarController.view addSubview:accessoryView];
}

- (void)keyboardViewController:(A3NumberKeyboardViewController *)vc plusMinusButtonPressed:(UIButton *)button {
	A3UnitConverterTVDataCell *cell = (A3UnitConverterTVDataCell *) [_fmMoveTableView cellForCellSubview:(UIView *) self.editingObject];
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
		[cell updateMultiTextFieldModeConstraintsWithEditingTextField:(UITextField *) self.editingObject];
	}
}

- (void)A3KeyboardController:(id)controller clearButtonPressedTo:(UIResponder *)keyInputDelegate {
	_didPressClearKey = YES;
	_didPressNumberKey = NO;
	UITextField *textField = (UITextField *) keyInputDelegate;
	textField.text = [self.decimalFormatter stringFromNumber:@0];
	_textBeforeEditingTextField = textField.text;
	[self updateTextFieldsWithSourceTextField:textField];
}

- (void)A3KeyboardController:(id)controller doneButtonPressedTo:(UIResponder *)keyInputDelegate {
	[self dismissNumberKeyboard];
}

- (void)keyboardViewControllerDidValueChange:(A3NumberKeyboardViewController *)vc {
	[self updateTextFieldsWithSourceTextField:_editingTextField];

	A3UnitConverterTVDataCell *cell = (A3UnitConverterTVDataCell *) [_fmMoveTableView cellForCellSubview:_editingTextField];
	[cell updateMultiTextFieldModeConstraintsWithEditingTextField:_editingTextField];
	_didPressNumberKey = YES;
}

#pragma mark - History

- (void)putHistoryWithValue:(NSNumber *)value {
	NSString *categoryName = [_dataManager categoryNameForID:_categoryID];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"categoryID == %@", categoryName];
	UnitHistory *latestHistory = [UnitHistory MR_findFirstWithPredicate:predicate sortedBy:@"updateDate" ascending:NO];

	// Compare code and value.
	if (latestHistory && [latestHistory.unitID isEqualToNumber:_convertItems[[self firstUnitIndex]]] && [value isEqualToNumber:latestHistory.value])
	{
		FNLOG(@"Does not make new history for same code and value, in history %@, %@", latestHistory.value, value);
		return;
	}

	NSManagedObjectContext *savingContext = [NSManagedObjectContext MR_rootSavingContext];
	UnitHistory *history = [UnitHistory MR_createEntityInContext:savingContext];
	history.uniqueID = [[NSUUID UUID] UUIDString];
	history.updateDate = [NSDate date];
	history.unitID = _convertItems[[self firstUnitIndex]];
	history.categoryID = @(_categoryID);
	history.value = value;

	[_convertItems enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		if (idx == 0) return;
		if (obj == self.equalItem) return;
		if (obj == self.adItem) return;
		
		UnitHistoryItem *item = [UnitHistoryItem MR_createEntityInContext:savingContext];
		item.uniqueID = [[NSUUID UUID] UUIDString];
		item.updateDate = [NSDate date];
		item.unitHistoryID = history.uniqueID;
		item.targetUnitItemID = obj;
		item.order = [NSString stringWithFormat:@"%010ld", (long)idx];
	}];

	[savingContext MR_saveToPersistentStoreAndWait];

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
		if (indexPath.row == 0 && self.editingObject) return;

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

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	[self dismissNumberKeyboard];
}

- (void)unSwipeAll {
	FNLOG();
	[self shiftRight:self.swipedCells];
}

#pragma mark - AdMob Did Receive Ad

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView {
    if (_adItem && [_convertItems containsObject:_adItem]) {
        return;
    }
    NSInteger position = [_convertItems count] > 3 ? 4 : [_convertItems count];
    [_convertItems insertObject:[self adItem] atIndex:position];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:position inSection:0];
    [_fmMoveTableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
