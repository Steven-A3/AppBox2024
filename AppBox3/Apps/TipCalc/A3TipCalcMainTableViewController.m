//
//  A3TipCalcMainViewController.m
//  A3TeamWork
//
//  Created by jeonghwan kim on 2/20/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "A3TipCalcMainTableViewController.h"
#import "A3TipCalcDataManager.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+NumberKeyboard.h"
#import "UIViewController+iPad_rightSideView.h"
#import "A3RoundedSideButton.h"
#import "A3TipCalcSettingViewController.h"
#import "UIViewController+MMDrawerController.h"
#import "A3TipCalcHeaderView.h"
#import "A3TipCalcHistoryViewController.h"
#import "A3JHTableViewRootElement.h"
#import "A3TableViewCheckMarkElement.h"
#import "A3TableViewInputElement.h"
#import "A3JHTableViewSelectElement.h"
#import "A3JHSelectTableViewController.h"
#import "A3JHTableViewEntryCell.h"
#import "A3PopoverTableViewController.h"
#import "A3DefaultColorDefines.h"
#import "A3ItemSelectListViewController.h"
#import "A3SearchViewController.h"
#import "A3CurrencySelectViewController.h"
#import "A3CalculatorViewController.h"
#import "UITableView+utility.h"
#import "UIColor+A3Addition.h"
#import "A3UserDefaultsKeys.h"
#import "A3SyncManager.h"
#import "A3SyncManager+NSUbiquitousKeyValueStore.h"
#import "A3StandardDetailTableViewController.h"

#define kColorPlaceHolder [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0]

typedef NS_ENUM(NSInteger, RowElementID) {
	RowElementID_SubTotal = 0,
    RowElementID_CostsBeforeTax,
    
    RowElementID_Costs,
    RowElementID_Tax,
    RowElementID_Tip,
    RowElementID_Split,
    
    RowElementID_Value,
    RowElementID_Option
};


@interface A3TipCalcMainTableViewController () <UITextFieldDelegate, UIActivityItemSource, UIPopoverControllerDelegate,
		CLLocationManagerDelegate,A3TipCalcDataManagerDelegate, A3TipCalcSettingsDelegate,
		A3TipCalcHistorySelectDelegate, A3JHSelectTableViewControllerProtocol, A3TableViewInputElementDelegate,
		A3SearchViewControllerDelegate, A3CalculatorViewControllerDelegate, A3ViewControllerProtocol
#ifdef __IPHONE_8_0
		, UIPopoverPresentationControllerDelegate
#endif
>

@property (nonatomic, strong) A3JHTableViewRootElement *tableDataSource;
@property (nonatomic, strong) NSArray * tableSectionTitles;
@property (nonatomic, strong) CellTextInputBlock cellTextInputBeginBlock;
@property (nonatomic, strong) CellTextInputBlock cellTextInputChangedBlock;
@property (nonatomic, strong) CellTextInputBlock cellTextInputFinishedBlock;
@property (nonatomic, strong) BasicBlock cellInputDoneButtonPressed;
@property (nonatomic, strong) UIPopoverController * localPopoverController;
@property (nonatomic, strong) A3TipCalcHeaderView * headerView;
@property (nonatomic, strong) A3TipCalcDataManager *dataManager;
@property (nonatomic, strong) UINavigationController *modalNavigationController;
@property (nonatomic, strong) A3TableViewInputElement *calculatorTargetElement;
@property (nonatomic, strong) NSIndexPath *calculatorTargetIndexPath;

@end

@implementation A3TipCalcMainTableViewController
{
    NSArray* _arrMenuButtons;
    UIView* _moreMenuView;
    BOOL _isShowMoreMenu;

	A3TableViewInputElement *_taxElement;

	BOOL _barButtonEnabled;
}

- (id)init {
	self = [super initWithStyle:UITableViewStyleGrouped];
	if (self) {
	}
	
	return self;
}

- (A3TipCalcDataManager *)dataManager {
	if (!_dataManager) {
		_dataManager = [A3TipCalcDataManager new];
		_dataManager.delegate = self;
	}
	return _dataManager;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self initialize];
    [self outputAllResultWithAnimation:NO];
    [self.headerView showDetailInfoButton];
    if (![self.dataManager hasCalcData] && [self.dataManager isTaxOptionOn]) {
        [self.dataManager getUSTaxRateByLocation];     // to calledFromAreaTax
    }
    [self refreshMoreButtonState];

	if (IS_IPAD) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainMenuViewDidHide) name:A3NotificationMainMenuDidHide object:nil];
	}
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cloudStoreDidImport) name:A3NotificationCloudKeyValueStoreDidImport object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cloudStoreDidImport) name:A3NotificationCloudCoreDataStoreDidImport object:nil];
	[self registerContentSizeCategoryDidChangeNotification];

    [[A3AppDelegate instance] popStartingAppInfo];
}

/*! Tip Calculator 의 경우에는 KeyValueStore 에는 CurrencyCode 만 저장이 된다.
 *  입력 데이터의 경우에는 Core Data 에 저장이 되므로, Core Data 변경 사항을 반영 해야 한다.
 *  KeyValue Store 의 변경 사항이던, Core Data 변경 사항이던 처리는 동일하게 진행한다.
 * \param
 * \returns
 */
- (void)cloudStoreDidImport {
    if (self.firstResponder) {
        return;
    }
    
	_dataManager = nil;
	_headerView.dataManager = self.dataManager;
	[self outputAllResultWithAnimation:YES];

	[self enableControls:_barButtonEnabled];
}

- (void)removeObserver {
	FNLOG();
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationCloudCoreDataStoreDidImport object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationCloudKeyValueStoreDidImport object:nil];
	[self removeContentSizeCategoryDidChangeNotification];
	if (IS_IPAD) {
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

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	[self enableControls:YES];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	if (IS_IPHONE && IS_PORTRAIT) {
		[self leftBarButtonAppsButton];
	}
	if ([self isBeingPresented] || [self isMovingToParentViewController]) {
        FNLOG(@"==============================");
        FNLOG(@"Calling presentInterstitialAds");
        FNLOG(@"==============================");
		[self presentInterstitialAds];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	if ([self isMovingFromParentViewController] || [self isBeingDismissed]) {
		FNLOG();
		[self removeObserver];
	}
}

- (void)contentSizeDidChange:(NSNotification *)notification {
    [_headerView setNeedsLayout];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)cleanUp {
	[self removeObserver];
}

- (void)dealloc {
	[self removeObserver];
}

#pragma mark -

- (void)mainMenuViewDidHide {
	[self enableControls:YES];
}

- (void)rightSideViewWillDismiss {
	if (IS_IPAD) {
		[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationRightSideViewWillDismiss object:nil];
	}
	[self enableControls:YES];
}

- (void)initialize {
	_barButtonEnabled = YES;

    [self makeBackButtonEmptyArrow];
	if (IS_IPAD || IS_PORTRAIT) {
		[self leftBarButtonAppsButton];
	} else {
		self.navigationItem.leftBarButtonItem = nil;
		self.navigationItem.hidesBackButton = YES;
	}
    [self rightBarButtons];
    self.title = NSLocalizedString(A3AppName_TipCalculator, nil);
    
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.separatorInset = UIEdgeInsetsMake(0.0, IS_IPHONE ? 15.0 : 28.0, 0.0, 0.0);
    self.tableView.separatorColor = COLOR_TABLE_SEPARATOR;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    self.tableView.tableHeaderView = [self headerView];
    
    [self reloadTableDataSource];
}

- (void)disposeInitializedCondition
{
    [self.firstResponder resignFirstResponder];
	[self setFirstResponder:nil];
    
    if (IS_IPHONE) {
        [self dismissMoreMenu];
    }
    
    if (self.localPopoverController) {
        [self.localPopoverController dismissPopoverAnimated:YES];
        self.localPopoverController = nil;
    }
}

- (void)enableControls:(BOOL)enable {
	_barButtonEnabled = enable;
    self.headerView.detailInfoButton.enabled = enable;
    self.navigationItem.leftBarButtonItem.enabled = enable;
	self.headerView.beforeSplitButton.enabled = enable;
	self.headerView.perPersonButton.enabled = enable;

	UIColor *color = enable ? [[A3AppDelegate instance] themeColor] : [UIColor colorWithRGBRed:201 green:201 blue:201 alpha:255];
	[self.headerView.beforeSplitButton setTitleColor:color forState:UIControlStateNormal];
	[self.headerView.perPersonButton setTitleColor:color forState:UIControlStateNormal];

//	if ([self.headerView.beforeSplitButton isSelected]) {
//		[self.headerView.beforeSplitButton setBorderColor:color];
//	}
//	if ([self.headerView.perPersonButton isSelected]) {
//		[self.headerView.perPersonButton setBorderColor:color];
//	}

	if (enable) {
        [self refreshMoreButtonState];
    } else {
		[self.navigationItem.rightBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem *barButtonItem, NSUInteger idx, BOOL *stop) {
			[barButtonItem setEnabled:NO];
		}];
	}
}

- (void)refreshMoreButtonState {
	if (IS_IPHONE) {
		if (_isShowMoreMenu) {
			UIButton *save = [_arrMenuButtons objectAtIndex:0];
			save.enabled = [self.dataManager.tipCalcData.costs isEqualToNumber:@0] ? NO : YES;
			UIBarButtonItem *share = [_arrMenuButtons objectAtIndex:1];
			share.enabled = [self.dataManager.tipCalcData.costs isEqualToNumber:@0] ? NO : YES;
		}
        else {
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
	}
	else {
		[self.navigationItem.rightBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem *barButton, NSUInteger idx, BOOL *stop) {
			switch ((A3RightBarButtonTag)barButton.tag) {
				case A3RightBarButtonTagComposeButton:
				case A3RightBarButtonTagShareButton:
					barButton.enabled = ([self.dataManager.tipCalcData.costs doubleValue] > 0.0 && [self.dataManager.tipCalcData.tip doubleValue] > 0.0);
					break;
				case A3RightBarButtonTagHistoryButton:
					barButton.enabled = [TipCalcHistory MR_countOfEntities] > 0;
					break;
				case A3RightBarButtonTagSettingsButton:
					barButton.enabled = YES;
					break;
                case A3RightBarButtonTagHelpButton:
                    barButton.enabled = YES;
                    break;
			}
		}];

	}
}

- (A3TipCalcHeaderView *)headerView
{
	CGRect frame = CGRectZero;
    if (!_headerView) {
        _headerView = [[A3TipCalcHeaderView alloc] initWithFrame:frame dataManager:self.dataManager];
		_headerView.dataManager = self.dataManager;
        [_headerView.beforeSplitButton addTarget:self action:@selector(beforeSplitButtonTouchedUp:) forControlEvents:UIControlEventTouchUpInside];
        [_headerView.perPersonButton addTarget:self action:@selector(perPersonButtonTouchedUp:) forControlEvents:UIControlEventTouchUpInside];
        [_headerView.detailInfoButton addTarget:self action:@selector(detailInfoButtonTouchedUp:) forControlEvents:UIControlEventTouchUpInside];
    }
	if ([self.dataManager isSplitOptionOn]) {
		if (IS_IPAD) {
			frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 193);
		}
		else {
			frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 134);
		}
	}
	else {
		if (IS_IPAD) {
			frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 158);
		}
		else {
			frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 104);
		}
	}
	_headerView.frame = frame;

    return _headerView;
}

- (UIView *)keyboardAccessoryView {
    UIView *accessoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 45)];
    accessoryView.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:248/255.0 alpha:1.0];
    UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), IS_RETINA ? 0.5 : 1)];
    topLine.backgroundColor = [UIColor colorWithRed:178/255.0 green:178/255.0 blue:178/255.0 alpha:1.0];
    UIButton *percentButton15 = [UIButton buttonWithType:UIButtonTypeCustom];
    [percentButton15 setTitle:@"15%" forState:UIControlStateNormal];
    [percentButton15 setTitleColor:[A3AppDelegate instance].themeColor forState:UIControlStateNormal];
    [percentButton15 setTitleColor:[UIColor colorWithRed:128/255.0 green:128/255.0 blue:128/255.0 alpha:1.0] forState:UIControlStateHighlighted];
    percentButton15.frame = CGRectMake(15, 0, 50, 45);
    percentButton15.tag = 15;
    [percentButton15 addTarget:self action:@selector(keyboardAccessoryButtonTouchedUp:) forControlEvents:UIControlEventTouchUpInside];

    UIButton *percentButton20 = [UIButton buttonWithType:UIButtonTypeCustom];
    [percentButton20 setTitle:@"20%" forState:UIControlStateNormal];
    [percentButton20 setTitleColor:[A3AppDelegate instance].themeColor forState:UIControlStateNormal];
    [percentButton20 setTitleColor:[UIColor colorWithRed:128/255.0 green:128/255.0 blue:128/255.0 alpha:1.0] forState:UIControlStateHighlighted];
    percentButton20.frame = CGRectMake(15 + 50 + 10, 0, 50, 45);
    percentButton20.tag = 20;
    [percentButton20 addTarget:self action:@selector(keyboardAccessoryButtonTouchedUp:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *percentButton25 = [UIButton buttonWithType:UIButtonTypeCustom];
    [percentButton25 setTitle:@"25%" forState:UIControlStateNormal];
    [percentButton25 setTitleColor:[A3AppDelegate instance].themeColor forState:UIControlStateNormal];
    [percentButton25 setTitleColor:[UIColor colorWithRed:128/255.0 green:128/255.0 blue:128/255.0 alpha:1.0] forState:UIControlStateHighlighted];
    percentButton25.frame = CGRectMake(15 + 50 + 10 + 50 + 10, 0, 50, 45);
    percentButton25.tag = 25;
    [percentButton25 addTarget:self action:@selector(keyboardAccessoryButtonTouchedUp:) forControlEvents:UIControlEventTouchUpInside];
    
    [accessoryView addSubview:percentButton15];
    [accessoryView addSubview:percentButton20];
    [accessoryView addSubview:percentButton25];
    [accessoryView addSubview:topLine];

	[percentButton25 makeConstraints:^(MASConstraintMaker *make) {
		make.right.equalTo(accessoryView.right).with.offset(-28);
		make.centerY.equalTo(accessoryView.centerY);
	}];

	[percentButton20 makeConstraints:^(MASConstraintMaker *make) {
		make.right.equalTo(percentButton25.left).with.offset(-25);
		make.centerY.equalTo(accessoryView.centerY);
	}];

	[percentButton15 makeConstraints:^(MASConstraintMaker *make) {
		make.right.equalTo(percentButton20.left).with.offset(-25);
		make.centerY.equalTo(accessoryView.centerY);
	}];

    return accessoryView;
}

#pragma mark - button event
- (void)detailInfoButtonTouchedUp:(UIButton* )aSender
{
    if (self.localPopoverController) {
        [self disposeInitializedCondition];
        return;
    }
    
    if (self.firstResponder) {
        [self.firstResponder resignFirstResponder];
        return;
    }
    
    [self dismissMoreMenu];
    
    NSMutableArray *titles = [NSMutableArray new];
    NSMutableArray *details = [NSMutableArray new];
    NSMutableArray *values;
    
	__weak NSNumberFormatter *formatter = self.dataManager.currencyFormatter;

    if ([self.dataManager tipSplitOption] == TipSplitOption_BeforeSplit) {
        values = [NSMutableArray new];
        [values addObject:[formatter stringFromNumber:[self.dataManager costBeforeTax]]];
        [values addObject:[formatter stringFromNumber:[self.dataManager taxValue]]];
        [titles addObject:@[NSLocalizedString(@"Amount", @"Amount"), NSLocalizedString(@"Tax", @"Tax")]];
        [details addObject:values];
        
        values = [NSMutableArray new];
        [values addObject:[formatter stringFromNumber:[self.dataManager subtotal]]];
        [values addObject:[formatter stringFromNumber:[self.dataManager tipValueWithRounding]]];
        [titles addObject:@[NSLocalizedString(@"Subtotal", @"Subtotal"), NSLocalizedString(@"Tip", @"Tip")]];
        [details addObject:values];
    }
    else if ([self.dataManager tipSplitOption] == TipSplitOption_PerPerson) {
        values = [NSMutableArray new];
        [values addObject:[formatter stringFromNumber:[self.dataManager costBeforeTaxWithSplit]]];
        [values addObject:[formatter stringFromNumber:[self.dataManager taxValueWithSplit]]];
        [titles addObject:@[NSLocalizedString(@"Amount", @"Amount"), NSLocalizedString(@"Tax", @"Tax")]];
        [details addObject:values];
        
        values = [NSMutableArray new];
        [values addObject:[formatter stringFromNumber:[self.dataManager subtotalWithSplit]]];
        [values addObject:[formatter stringFromNumber:[self.dataManager tipValueWithSplitWithRounding:YES]]];
        [titles addObject:@[NSLocalizedString(@"Subtotal", @"Subtotal"), NSLocalizedString(@"Tip", @"Tip")]];
        [details addObject:values];
    }

	if (IS_IOS7 || IS_IPAD) {
		A3PopoverTableViewController *popoverTableViewController = [[A3PopoverTableViewController alloc] initWithStyle:UITableViewStylePlain];
		[popoverTableViewController setSectionArrayForTitles:titles withDetails:details];
		self.localPopoverController = [[UIPopoverController alloc] initWithContentViewController:popoverTableViewController];
		self.localPopoverController.backgroundColor = [UIColor whiteColor];
		self.localPopoverController.delegate = self;
		[self.localPopoverController presentPopoverFromRect:_headerView.detailInfoButton.frame
													 inView:self.view
								   permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
		[self.localPopoverController setPopoverContentSize:CGSizeMake(320, popoverTableViewController.tableView.contentSize.height)
												  animated:NO];
	} else {
		A3StandardDetailTableViewController *detailViewController = [[A3StandardDetailTableViewController alloc] initWithTitles:titles details:details];
		detailViewController.title = NSLocalizedString(@"Detail", @"Detail");
		detailViewController.modalPresentationStyle = UIModalPresentationPopover;
		[detailViewController setPreferredContentSize:CGSizeMake(320, detailViewController.tableView.contentSize.height)];
		UIPopoverPresentationController *popoverPresentationController = detailViewController.popoverPresentationController;
		popoverPresentationController.sourceView = _headerView.detailInfoButton;
		popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUp;
		popoverPresentationController.delegate = self;
		[self presentViewController:detailViewController animated:YES completion:nil];
	}

	[self enableControls:NO];
}

#ifdef __IPHONE_8_0
- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
	return UIModalPresentationFullScreen;
}

- (UIViewController *)presentationController:(UIPresentationController *)controller viewControllerForAdaptivePresentationStyle:(UIModalPresentationStyle)style {
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller.presentedViewController];
	return navigationController;
}

- (void)popoverPresentationControllerDidDismissPopover:(UIPopoverPresentationController *)popoverPresentationController {
	[self enableControls:YES];
}
#endif

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
	[self enableControls:YES];
	self.localPopoverController = nil;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];

	if (IS_IPHONE && IS_LANDSCAPE) {
		[self leftBarButtonAppsButton];
	}
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	if (self.localPopoverController) {
		[self.localPopoverController dismissPopoverAnimated:NO];
		self.localPopoverController = nil;
		[self detailInfoButtonTouchedUp:nil];
	}
	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (void)beforeSplitButtonTouchedUp:(id)aSender
{
    [self disposeInitializedCondition];
    
    _headerView.beforeSplitButton.selected = YES;
    _headerView.perPersonButton.selected = NO;
	self.dataManager.tipSplitOption = TipSplitOption_BeforeSplit;
    
    [self outputAllResultWithAnimation:YES];
}

- (void)perPersonButtonTouchedUp:(id)aSender {
    [self disposeInitializedCondition];

    _headerView.beforeSplitButton.selected = NO;
    _headerView.perPersonButton.selected = YES;
	self.dataManager.tipSplitOption = TipSplitOption_PerPerson;
    
    [self outputAllResultWithAnimation:YES];
}

#pragma mark KeyboardAccessoryView Button
- (void)keyboardAccessoryButtonTouchedUp:(UIButton *)sender {
    ((UITextField *)self.firstResponder).text = [NSString stringWithFormat:@"%ld", (long)[sender tag]];
}

#pragma mark - Table Data Configuration

- (A3JHTableViewRootElement *)tableDataSource {
	if (!_tableDataSource) {
		_tableDataSource = [A3JHTableViewRootElement new];
		_tableDataSource.tableView = self.tableView;
        _tableDataSource.viewController = self;
	}
	return _tableDataSource;
}

- (void)reloadTableDataSource {
    // Sections
    NSMutableArray *sections = [NSMutableArray new];
    // Section 0
    if ([self.dataManager isTaxOptionOn]) {
		[sections addObject:NSLocalizedString(@"KNOWN VALUE", @"KNOWN VALUE")];
    }
    // Section 1
    [sections addObject:@""];
    // Section 2
    if ([self.dataManager isRoundingOptionSwitchOn]) {
		[sections addObject:NSLocalizedString(@"ROUNDING", @"ROUNDING")];
    }
    
    self.tableSectionTitles = sections;
    
    
    // Rows
    NSMutableArray * sectionsRows = [NSMutableArray new];
    if ([self.dataManager isTaxOptionOn]) {
        [sectionsRows addObject:[self tableSectionDataAtSection:0]];
    }
    
    [sectionsRows addObject:[self tableSectionDataAtSection:1]];
    
    if ([self.dataManager isRoundingOptionSwitchOn]) {
        [sectionsRows addObject:[self tableSectionDataAtSection:2]];
    }
    
    self.tableDataSource.sectionsArray = sectionsRows;
}

- (NSArray *)tableSectionDataAtSection:(NSInteger)section {
    NSArray * result;
    
    switch (section) {
        case 0:     // KNOWN VALUE
        {
            A3TableViewCheckMarkElement *subtotal = [A3TableViewCheckMarkElement new];
            subtotal.title = NSLocalizedString(@"Amount After Tax", @"Amount After Tax");
            subtotal.identifier = RowElementID_SubTotal;
            subtotal.checked = [self.dataManager knownValue] == TCKnownValue_CostAfterTax ? YES : NO;
            
            A3TableViewCheckMarkElement *costsBeforeTax = [A3TableViewCheckMarkElement new];
            costsBeforeTax.title = NSLocalizedString(@"Amount Before Tax", @"Amount Before Tax");
            costsBeforeTax.identifier = RowElementID_CostsBeforeTax;
            costsBeforeTax.checked = [self.dataManager knownValue] == TCKnownValue_CostsBeforeTax ? YES : NO;
            
            result = @[subtotal, costsBeforeTax];
        }
            break;
            
        case 1:     // input Section
        {
            NSMutableArray *elements = [NSMutableArray new];
            A3TableViewInputElement *costs = [A3TableViewInputElement new];
			costs.delegate = self;
            if ([self.dataManager.tipCalcData.showTax boolValue]) {
				if ([[[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode] isEqualToString:@"es"]) {
					costs.title = NSLocalizedString(@"Amount", nil);
				} else {
					costs.title = [self.dataManager knownValue] == TCKnownValue_CostAfterTax ? NSLocalizedString(@"Amount After Tax", @"Amount After Tax") : NSLocalizedString(@"Amount Before Tax", @"Amount Before Tax");
				}
			}
            else {
                costs.title = NSLocalizedString(@"Cost", @"Cost");
            }
            
            costs.value = [self.decimalFormatter stringFromNumber:[self.dataManager.tipCalcData costs]];
            costs.inputType = A3TableViewEntryTypeCurrency;
            costs.prevEnabled = NO;
            costs.nextEnabled = YES;
            costs.valueType = A3TableViewValueTypeCurrency;
            costs.onEditingBegin = [self cellTextInputBeginBlock];
            costs.onEditingValueChanged = [self cellTextInputChangedBlock];
            costs.onEditingFinished = [self cellTextInputFinishedBlock];
            costs.doneButtonPressed = [self cellInputDoneButtonPressed];
            costs.identifier = RowElementID_Costs;
			costs.currencyCode = self.dataManager.currencyCode;
			[elements addObject:costs];

            if ([self.dataManager isTaxOptionOn]) {
                A3TableViewInputElement *tax = [A3TableViewInputElement new];
				tax.delegate = self;
                tax.title = NSLocalizedString(@"Tax", @"Tax");
                tax.value = [self.decimalFormatter stringFromNumber:[self.dataManager.tipCalcData tax]];
                tax.inputType = A3TableViewEntryTypePercent;
                tax.prevEnabled = YES;
                tax.nextEnabled = YES;
                tax.valueType = [self.dataManager.tipCalcData.isPercentTax boolValue] ? A3TableViewValueTypePercent : A3TableViewValueTypeCurrency;
                tax.onEditingBegin = [self cellTextInputBeginBlock];
                tax.onEditingValueChanged = [self cellTextInputChangedBlock];
                tax.onEditingFinished = [self cellTextInputFinishedBlock];
                tax.doneButtonPressed = [self cellInputDoneButtonPressed];
                tax.identifier = RowElementID_Tax;
				tax.currencyCode = self.dataManager.currencyCode;
                _taxElement = tax;
                [elements addObject:tax];
            }

            A3TableViewInputElement *tip = [A3TableViewInputElement new];
			tip.delegate = self;
            tip.title = NSLocalizedString(@"Tip", @"Tip");
            tip.value = [self.decimalFormatter stringFromNumber:[self.dataManager.tipCalcData tip]];
            tip.inputType = A3TableViewEntryTypePercent;
            tip.prevEnabled = YES;
            tip.nextEnabled = YES;
            tip.valueType = [self.dataManager.tipCalcData.isPercentTip boolValue] ? A3TableViewValueTypePercent : A3TableViewValueTypeCurrency;
            tip.onEditingBegin = [self cellTextInputBeginBlock];
            tip.onEditingValueChanged = [self cellTextInputChangedBlock];
            tip.onEditingFinished = [self cellTextInputFinishedBlock];
            tip.doneButtonPressed = [self cellInputDoneButtonPressed];
            tip.identifier = RowElementID_Tip;
			tip.currencyCode = self.dataManager.currencyCode;
            [elements addObject:tip];

            if ([self.dataManager isSplitOptionOn]) {
                A3TableViewInputElement *split = [A3TableViewInputElement new];
				split.delegate = self;
                split.title = NSLocalizedString(@"Split", @"Split");
                split.value = [self.decimalFormatter stringFromNumber:[self.dataManager.tipCalcData split]];
                split.inputType = A3TableViewEntryTypeInteger;
                split.prevEnabled = YES;
                split.nextEnabled = NO;
                split.onEditingBegin = [self cellTextInputBeginBlock];
                split.onEditingValueChanged = [self cellTextInputChangedBlock];
                split.onEditingFinished = [self cellTextInputFinishedBlock];
                split.doneButtonPressed = [self cellInputDoneButtonPressed];
                split.identifier = RowElementID_Split;
                [elements addObject:split];
            }

            result = elements;
        }
            break;

        case 2:     //ROUNDING METHOD
        {
            A3JHTableViewSelectElement * value = [A3JHTableViewSelectElement new];
            value.title = NSLocalizedString(@"Value", @"Value");
            value.items = @[NSLocalizedString(@"Tip", @"Tip"), NSLocalizedString(@"Total", @"Total"), NSLocalizedString(@"Total Per Person", @"Total Per Person"), NSLocalizedString(@"Tip Per Person", @"Tip Per Person")];
            value.selectedIndex = [self.dataManager roundingMethodValue];
            value.identifier = RowElementID_Value;
            
            A3JHTableViewSelectElement * option = [A3JHTableViewSelectElement new];
            option.title = NSLocalizedString(@"Methods", @"Methods");
            option.items = @[NSLocalizedString(@"Exact", @"Exact"), NSLocalizedString(@"Up", @"Up"), NSLocalizedString(@"Down", @"Down"), NSLocalizedString(@"Off", @"Off")];
            option.selectedIndex = [self.dataManager roundingMethodOption];
            option.identifier = RowElementID_Option;
            result = @[value, option];
        }
            break;
            
        default:
            break;
    }
    
    return result;
}

#pragma mark - Table InputElement Manipulate Blocks

-(CellTextInputBlock)cellTextInputBeginBlock
{
    if (!_cellTextInputBeginBlock) {
        __weak A3TipCalcMainTableViewController * weakSelf = self;
        _cellTextInputBeginBlock = ^(A3TableViewInputElement *element, UITextField *textField) {
            weakSelf.firstResponder = textField;
            [weakSelf dismissMoreMenu];
			[weakSelf addNumberKeyboardNotificationObservers];
            
            if (element.identifier == RowElementID_Tip) {
                textField.inputAccessoryView = [weakSelf keyboardAccessoryView];
            }
            else {
                textField.inputAccessoryView = nil;
            }
        };
    }
    
    return _cellTextInputBeginBlock;
}

-(CellTextInputBlock)cellTextInputChangedBlock
{
	__typeof(self) __weak weakSelf = self;

    if (!_cellTextInputChangedBlock) {
        _cellTextInputChangedBlock = ^(A3TableViewInputElement *element, UITextField *textField) {
			A3JHTableViewEntryCell *cell = (A3JHTableViewEntryCell *) [weakSelf.tableView cellForCellSubview:textField];
			[cell setNeedsLayout];
        };
    }
    
    return _cellTextInputChangedBlock;
}

-(CellTextInputBlock)cellTextInputFinishedBlock
{
    if (!_cellTextInputFinishedBlock) {
        __weak A3TipCalcMainTableViewController * weakSelf = self;
        
        _cellTextInputFinishedBlock = ^(A3TableViewInputElement *element, UITextField *textField) {
			[weakSelf removeNumberKeyboardNotificationObservers];

            NSNumber *value;
            if ([textField.text length] == 0) {
                value = [weakSelf.decimalFormatter numberFromString:[element value]];
            }
            else {
                value = [weakSelf.decimalFormatter numberFromString:textField.text];
                element.value = textField.text;
            }
            
            switch (element.identifier) {
                case RowElementID_Costs:
                {
                    [weakSelf.dataManager setTipCalcDataCost:value];
					break;
				}
                case RowElementID_Tax:
                {
					[weakSelf.dataManager setTipCalcDataTax:value
											  isPercentType:[element valueType] == A3TableViewValueTypePercent ? YES : NO ];
					break;
				}
                case RowElementID_Tip:
                {
					[weakSelf.dataManager setTipCalcDataTip:value
											  isPercentType:[element valueType] == A3TableViewValueTypePercent ? YES : NO];
					break;
				}
                case RowElementID_Split:
                {
                    [weakSelf.dataManager setTipCalcDataSplit:value];
					element.value = [weakSelf.decimalFormatter stringFromNumber:weakSelf.dataManager.tipCalcData.split];
					break;
				}

                default:
                    break;
            }
            
            [weakSelf.headerView showDetailInfoButton];
            [weakSelf.headerView setResult:weakSelf.dataManager.tipCalcData withAnimation:YES];
            [weakSelf refreshMoreButtonState];
			[[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];

			A3JHTableViewEntryCell *cell = (A3JHTableViewEntryCell *) [weakSelf.tableView cellForCellSubview:textField];
			[cell setNeedsLayout];

			if (weakSelf.firstResponder == textField) {
				weakSelf.firstResponder = nil;
			}
		};
    }
    
    return _cellTextInputFinishedBlock;
}

- (BasicBlock)cellInputDoneButtonPressed {
    if (!_cellInputDoneButtonPressed) {
        __weak A3TipCalcMainTableViewController * weakSelf = self;
        _cellInputDoneButtonPressed = ^(id sender){
            if ([weakSelf.dataManager hasCalcData]) {
                [weakSelf scrollToTopOfTableView];
            }
        };
    }
    
    return _cellInputDoneButtonPressed;
}

-(void)scrollToTopOfTableView {
	[UIView beginAnimations:A3AnimationIDKeyboardWillShow context:nil];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationCurve:7];
	[UIView setAnimationDuration:0.35];
	self.tableView.contentOffset = CGPointMake(0.0, -(self.navigationController.navigationBar.bounds.size.height + [A3UIDevice statusBarHeight]));
	[UIView commitAnimations];
}

#pragma mark Settings

- (void)tipCalcSettingsChanged {
    [_headerView setResult:self.dataManager.tipCalcData withAnimation:YES];
    self.tableView.tableHeaderView = [self headerView];
    [self reloadTableDataSource];
    [self.tableView reloadData];
    [_headerView showDetailInfoButton];

	if (IS_IPAD && [[A3AppDelegate instance] rootViewController].showRightView) {
		[self enableControls:NO];
	}
}

- (void)dismissTipCalcSettingsViewController {
	[self enableControls:YES];
}

#pragma mark A3TipCalcHistorySelectDelegate

- (void)didSelectHistoryData:(TipCalcHistory *)aHistory {
	[self.dataManager saveToHistory];

    [self.dataManager historyToRecently:aHistory];
	FNLOG(@"%@", self.dataManager.tipCalcData);

    [self reloadTableDataSource];

    self.tableView.tableHeaderView = [self headerView];
    [_headerView showDetailInfoButton];
    [_headerView setResult:self.dataManager.tipCalcData withAnimation:YES];
    [self.tableView reloadData];
}

- (void)clearSelectHistoryData {

}

- (void)dismissHistoryViewController {
	[self enableControls:YES];
}

- (void)tipCalcRoundingChanged {
    [_headerView setResult:self.dataManager.tipCalcData withAnimation:YES];
    [self reloadTableDataSource];
    [self.tableView reloadData];
}

#pragma mark A3SelectTableViewController Delegate

-(void)selectTableViewController:(A3JHSelectTableViewController *)viewController selectedItemIndex:(NSInteger)index indexPathOrigin:(NSIndexPath *)indexPathOrigin {
	[self enableControls:YES];
    viewController.root.selectedIndex = index;
    
    if ([viewController.root.title isEqualToString:NSLocalizedString(@"Methods", @"Methods")]) {
		self.dataManager.roundingMethodOption = (TCRoundingMethodOption) index;
    }
    else {
		self.dataManager.roundingMethodValue = (TCRoundingMethodValue) index;
    }
    
    [self.headerView showDetailInfoButton];
    [self.headerView setResult:self.dataManager.tipCalcData withAnimation:YES];
    [self refreshMoreButtonState];
    [self.tableView reloadData];
}

#pragma mark Location Manager Delegate

- (void)dataManager:(id)manager taxValueUpdated:(NSNumber *)taxRate {
	[self.dataManager setTipCalcDataTax:taxRate isPercentType:YES];
    _taxElement.value = [self.decimalFormatter stringFromNumber:taxRate];
    _taxElement.valueType = A3TableViewValueTypePercent;

	[self.tableView reloadData];
}

#pragma mark - private
- (void)outputAllResultWithAnimation:(BOOL)animate
{
    [_headerView setResult:self.dataManager.tipCalcData withAnimation:animate];
    [self reloadTableDataSource];
    [self.tableView reloadData];
    
    if ([self.dataManager tipSplitOption] == TipSplitOption_BeforeSplit) {
        _headerView.beforeSplitButton.selected = YES;
        _headerView.perPersonButton.selected = NO;
    }
    else {
        _headerView.beforeSplitButton.selected = NO;
        _headerView.perPersonButton.selected = YES;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.tableDataSource numberOfSections];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.tableSectionTitles objectAtIndex:section];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    NSString *title = [self.tableSectionTitles objectAtIndex:section];
    if ([title length] == 0) {
        return 35;
    }
    
    return 55;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if ([self.tableSectionTitles count] - 1 == section) {
        return 0;
    }

    return 0.01;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.tableDataSource numberOfRowsInSection:section];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [self.tableDataSource cellForRowAtIndexPath:indexPath];
    [self updateTableViewCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)updateTableViewCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath {
    A3JHTableViewElement * element = [self.tableDataSource elementForIndexPath:indexPath];
    
    if ([cell isKindOfClass:[A3JHTableViewEntryCell class]]) {
        ((A3JHTableViewEntryCell *)cell).textField.textColor = [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
        ((A3JHTableViewEntryCell *)cell).textField.font = [UIFont systemFontOfSize:17];
    }
    
    switch (element.identifier) {
        case RowElementID_Value:
        case RowElementID_Option:
            cell.detailTextLabel.textColor = [UIColor colorWithRed:128/255.0 green:128/255.0 blue:128/255.0 alpha:1.0];
            break;
        case RowElementID_Split:
            ((A3JHTableViewEntryCell *)cell).textField.placeholder = @"";
            ((A3JHTableViewEntryCell *)cell).textField.clearButtonMode = UITextFieldViewModeNever;
            break;
        default:
            break;
    }
}

#pragma mark - tableview delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self dismissMoreMenu];
    
    A3JHTableViewElement *element = [self.tableDataSource elementForIndexPath:indexPath];
    
    switch (element.identifier) {
        case RowElementID_SubTotal:
        case RowElementID_CostsBeforeTax:
        {
            A3TableViewCheckMarkElement *subtotal = (A3TableViewCheckMarkElement *)[self.tableDataSource elementForIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            A3TableViewCheckMarkElement *beforeTax = (A3TableViewCheckMarkElement *)[self.tableDataSource elementForIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
            UITableViewCell *subtotalCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            UITableViewCell *beforeTaxCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
            
            if (indexPath.row == RowElementID_SubTotal) {
                subtotal.checked = YES;
                beforeTax.checked = NO;
                subtotalCell.accessoryType = UITableViewCellAccessoryCheckmark;
                beforeTaxCell.accessoryType = UITableViewCellAccessoryNone;
				self.dataManager.knownValue = TCKnownValue_CostAfterTax;
            }
            else {
                subtotal.checked = NO;
                beforeTax.checked = YES;
                subtotalCell.accessoryType = UITableViewCellAccessoryNone;
                beforeTaxCell.accessoryType = UITableViewCellAccessoryCheckmark;
				self.dataManager.knownValue = TCKnownValue_CostsBeforeTax;
            }
            
            if ([self.dataManager.tipCalcData.beforeSplit intValue] == 0) {
                _headerView.beforeSplitButton.selected = YES;
                _headerView.perPersonButton.selected = NO;
            }
            else {
                _headerView.beforeSplitButton.selected = NO;
                _headerView.perPersonButton.selected = YES;
            }
            
            [_headerView setResult:self.dataManager.tipCalcData withAnimation:YES];
            

            UITableViewCell *costs = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
            costs.textLabel.text = [self.dataManager knownValue] == TCKnownValue_CostAfterTax ? NSLocalizedString(@"Amount After Tax", @"Amount After Tax") : NSLocalizedString(@"Amount Before Tax", @"Amount Before Tax");

			[[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
			break;
		}

        case RowElementID_Costs:
        case RowElementID_Tax:
        case RowElementID_Tip:
        case RowElementID_Split:
        {
            A3JHTableViewEntryCell * cell = (A3JHTableViewEntryCell *)[tableView cellForRowAtIndexPath:indexPath];
            [cell.textField becomeFirstResponder];
			break;
		}

        case RowElementID_Value:
        case RowElementID_Option:
        {
            [self disposeInitializedCondition];
            
            A3JHTableViewSelectElement *selectItem = (A3JHTableViewSelectElement *)[self.tableDataSource elementForIndexPath:indexPath];
            A3ItemSelectListViewController *selectTableViewController = [[A3ItemSelectListViewController alloc] initWithStyle:UITableViewStyleGrouped];
            selectTableViewController.root = selectItem;
            selectTableViewController.delegate = self;
            selectTableViewController.indexPathOfOrigin = indexPath;
            if (IS_IPHONE) {
                [self.navigationController pushViewController:selectTableViewController animated:YES];
            }
            else {
				[self enableControls:NO];
				[[[A3AppDelegate instance] rootViewController] presentRightSideViewController:selectTableViewController];
				[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rightSideViewWillDismiss) name:A3NotificationRightSideViewWillDismiss object:nil];
			}
            
			break;
		}

        default:
            break;
    }
}

#pragma mark - apps & more button stuff

- (void)appsButtonAction:(UIBarButtonItem *)barButtonItem {
	[self.firstResponder resignFirstResponder];
	
	[self disposeInitializedCondition];
	
	if (IS_IPHONE) {
		[self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
		
		if ([_moreMenuView superview]) {
			[self rightBarButtons];
		}
	}
	else {
		[[[A3AppDelegate instance] rootViewController] toggleLeftMenuViewOnOff];
		[self enableControls:NO];
	}
}

- (void)moreButtonAction:(UIBarButtonItem *)button {
	[self disposeInitializedCondition];

	[self rightBarButtonDoneButton];

	_arrMenuButtons = @[self.composeButton, self.shareButton, [self historyButton:[TipCalcHistory class]], self.settingsButton];
	_moreMenuView = [self presentMoreMenuWithButtons:_arrMenuButtons tableView:self.tableView];
	_isShowMoreMenu = YES;

	[self refreshMoreButtonState];
}

- (void)composeButtonAction:(UIButton *)button {
	[self saveToHistoryAndInitialize:button];
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
	[self dismissMoreMenuView:_moreMenuView scrollView:self.tableView];
	[self.view removeGestureRecognizer:gestureRecognizer];
}

- (void)rightBarButtons {
    if (IS_IPHONE) {
		[self rightButtonMoreButton];
	}
    else {
        self.navigationItem.hidesBackButton = YES;
        
        UIBarButtonItem *share = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"share"] style:UIBarButtonItemStylePlain target:self action:@selector(shareButtonAction:)];
        share.tag = A3RightBarButtonTagShareButton;
        UIBarButtonItem *saveItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(saveToHistoryAndInitialize:)];
        saveItem.tag = A3RightBarButtonTagComposeButton;
        UIBarButtonItem *history = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"history"] style:UIBarButtonItemStylePlain target:self action:@selector(historyButtonAction:)];
		history.tag = A3RightBarButtonTagHistoryButton;
        UIBarButtonItem *settings = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"general"] style:UIBarButtonItemStylePlain target:self action:@selector(settingsButtonAction:)];
        settings.tag = A3RightBarButtonTagSettingsButton;
        UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        space.width = 24.0;
        
        self.navigationItem.rightBarButtonItems = @[settings, space, history, space, saveItem, space, share];
    }
}

- (void)shareButtonAction:(id)sender {
    if (self.localPopoverController) {
        [self disposeInitializedCondition];
        return;
    }

	[self disposeInitializedCondition];

	self.localPopoverController = [self presentActivityViewControllerWithActivityItems:@[self] fromBarButtonItem:sender completionHandler:^(NSString *activityType, BOOL completed) {
		[self enableControls:YES];
		self.localPopoverController = nil;
	}];
	self.localPopoverController.delegate = self;
    if (IS_IPAD) {
		[self enableControls:NO];
    }
}

- (void)historyButtonAction:(UIButton *)button {
    [self disposeInitializedCondition];
	[self enableControls:NO];
    
    A3TipCalcHistoryViewController* viewController = [[A3TipCalcHistoryViewController alloc] init];
    viewController.delegate = self;

	if (IS_IPHONE) {
		_modalNavigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
		[self presentViewController:_modalNavigationController animated:YES completion:NULL];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(historyViewControllerDidDismiss) name:A3NotificationChildViewControllerDidDismiss object:viewController];
	} else {
		[[[A3AppDelegate instance] rootViewController] presentRightSideViewController:viewController];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rightSideViewWillDismiss) name:A3NotificationRightSideViewWillDismiss object:nil];
	}
}

- (void)historyViewControllerDidDismiss {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationChildViewControllerDidDismiss object:_modalNavigationController.childViewControllers[0]];
	_modalNavigationController = nil;
}

- (void)settingsButtonAction:(UIButton *)button {
	[self disposeInitializedCondition];
	[self enableControls:NO];

	A3TipCalcSettingViewController *viewController = [[A3TipCalcSettingViewController alloc] initWithStyle:UITableViewStyleGrouped];
	viewController.dataManager = self.dataManager;
	viewController.delegate = self;

	if (IS_IPHONE) {
		_modalNavigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
		[self presentViewController:_modalNavigationController animated:YES completion:NULL];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingsViewControllerDidDismiss) name:A3NotificationChildViewControllerDidDismiss object:viewController];
	} else {
		[[[A3AppDelegate instance] rootViewController] presentRightSideViewController:viewController];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rightSideViewWillDismiss) name:A3NotificationRightSideViewWillDismiss object:nil];
	}
}

- (void)settingsViewControllerDidDismiss {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationChildViewControllerDidDismiss object:_modalNavigationController.childViewControllers[0]];
	_modalNavigationController = nil;
}

- (void)saveToHistoryAndInitialize:(id)sender {
    [self disposeInitializedCondition];
    
    [self.dataManager saveToHistory];

	if ([self.dataManager isTaxOptionOn]) {
		[self.dataManager getUSTaxRateByLocation];     // to calledFromAreaTax
	}

	// Initialize
	[self.headerView showDetailInfoButton];
	//[self.headerView setResult:[self.dataManager tipCalcData] withAnimation:YES];
	self.tableView.tableHeaderView = self.headerView;
	[self.headerView setResult:nil withAnimation:YES];
	[self reloadTableDataSource];
	[self.tableView reloadData];
	[self refreshMoreButtonState];
}

#pragma mark Share Activities

- (NSString *)activityViewController:(UIActivityViewController *)activityViewController subjectForActivityType:(NSString *)activityType
{
	if ([activityType isEqualToString:UIActivityTypeMail]) {
		return NSLocalizedString(@"Tip Calculator using AppBox Pro", nil);
	}
    
	return @"";
}

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType
{
	if ([activityType isEqualToString:UIActivityTypeMail]) {
		return [self shareMailMessageWithHeader:NSLocalizedString(@"I'd like to share a calculation with you.", nil)
									   contents:[self.dataManager sharedDataIsMail:YES]
										   tail:NSLocalizedString(@"You can calculate more in the AppBox Pro.", nil)];
	}
	else {
        NSString *shareString = [self.dataManager sharedDataIsMail:NO];
        shareString = [shareString stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
		return shareString;
	}
}

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController
{
	return NSLocalizedString(@"Share Currency Converter Data", @"Share Currency Converter Data");
}

#pragma mark - Number Keyboard Currency Button Notification

- (void)currencySelectButtonAction:(NSNotification *)notification {
	[self.firstResponder resignFirstResponder];
	A3CurrencySelectViewController *viewController = [self presentCurrencySelectViewControllerWithCurrencyCode:notification.object];
	viewController.delegate = self;
}

- (void)searchViewController:(UIViewController *)viewController itemSelectedWithItem:(NSString *)currencyCode {
	[[A3SyncManager sharedSyncManager] setObject:currencyCode forKey:A3TipCalcUserDefaultsCurrencyCode state:A3DataObjectStateModified];

	[self.dataManager setCurrencyFormatter:nil];

	self.dataManager.tipCalcData.currencyCode = currencyCode;

	[self outputAllResultWithAnimation:YES];
	[self.tableView setContentOffset:CGPointMake(0, -self.tableView.contentInset.top) animated:YES];
}

#pragma mark - Number Keyboard, Calculator Button Notification

- (void)calculatorButtonAction {
	_calculatorTargetIndexPath = [self.tableView indexPathForCellSubview:(UIView *) self.firstResponder];
	_calculatorTargetElement = (A3TableViewInputElement *) [self.tableDataSource elementForIndexPath:_calculatorTargetIndexPath];
	[self.firstResponder resignFirstResponder];

	A3CalculatorViewController *viewController = [self presentCalculatorViewController];
	viewController.delegate = self;
}

- (void)calculatorDidDismissWithValue:(NSString *)value {
	A3JHTableViewEntryCell *cell = (A3JHTableViewEntryCell *) [self.tableDataSource cellForRowAtIndexPath:_calculatorTargetIndexPath];
	cell.textField.text = value;
	_cellTextInputFinishedBlock(_calculatorTargetElement, cell.textField);
	[self.tableView reloadRowsAtIndexPaths:@[_calculatorTargetIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (NSNumberFormatter *)currencyFormatterForTableViewInputElement {
	return [self.dataManager currencyFormatter];
}

#pragma mark - A3ViewControllerProtocol

- (BOOL)shouldAllowExtensionPointIdentifier:(NSString *)extensionPointIdentifier {
	return NO;
}

@end
