//
//  A3SalesCalcMainViewController.m
//  A3TeamWork
//
//  Created by jeonghwan kim on 13. 11. 17..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "A3SalesCalcMainViewController.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+NumberKeyboard.h"
#import "A3SalesCalcHeaderView.h"
#import "A3SalesCalcHistoryViewController.h"
#import "A3JHTableViewRootElement.h"
#import "A3JHSelectTableViewController.h"
#import "A3JHTableViewSelectElement.h"
#import "A3TableViewCheckMarkElement.h"
#import "A3TableViewInputElement.h"
#import "A3JHTableViewExpandableElement.h"
#import "A3JHTableViewEntryCell.h"
#import "A3SalesCalcData.h"
#import "A3SalesCalcPreferences.h"
#import "A3SalesCalcCalculator.h"
#import "A3SalesCalcDetailInfoPopOverView.h"
#import "A3DefaultColorDefines.h"
#import "A3TextViewElement.h"
#import "SalesCalcHistory.h"
#import "A3SearchViewController.h"
#import "UIViewController+iPad_rightSideView.h"
#import "A3CurrencySelectViewController.h"
#import "A3CalculatorViewController.h"
#import "UITableView+utility.h"
#import "A3UserDefaults.h"
#import "A3SyncManager.h"
#import "A3SyncManager+NSUbiquitousKeyValueStore.h"

enum A3TableElementCellType {
    A3TableElementCellType_Price = 100,
    A3TableElementCellType_Discount,
    A3TableElementCellType_Additional,
    A3TableElementCellType_Tax,
    A3TableElementCellType_Note
};

@interface A3SalesCalcMainViewController () <CLLocationManagerDelegate, UIPopoverControllerDelegate,
		A3JHSelectTableViewControllerProtocol, A3SalesCalcHistorySelectDelegate, A3TableViewInputElementDelegate,
		A3SearchViewControllerDelegate, A3CalculatorViewControllerDelegate>

@property (nonatomic, strong) A3JHTableViewRootElement *root;
@property (nonatomic, strong) A3SalesCalcPreferences *preferences;
@property (nonatomic, strong) CellTextInputBlock cellTextInputBeginBlock;
@property (nonatomic, strong) CellTextInputBlock cellTextInputChangedBlock;
@property (nonatomic, strong) CellTextInputBlock cellTextInputFinishedBlock;
@property (nonatomic, strong) CellTextInputBlock cellTextInputFinishAllBlock;
@property (nonatomic, strong) CellExpandedBlock cellExpandedBlock;
@property (nonatomic, strong) BasicBlock cellInputDoneButtonPressed;
@property (nonatomic, strong) A3SalesCalcHeaderView *headerView;
@property (nonatomic, strong) UIPopoverController *localPopoverController;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) A3TableViewInputElement *taxElement;
@property (nonatomic, strong) A3TableViewInputElement *price;
@property (nonatomic, strong) A3TextViewElement *notes;
@property (nonatomic, strong) UITextView *textViewResponder;
@property (nonatomic, strong) UINavigationController *modalNavigationController;
@property (nonatomic, strong) A3TableViewInputElement *calculatorTargetElement;
@property (nonatomic, strong) NSIndexPath *calculatorTargetIndexPath;
@property (nonatomic, assign) BOOL cancelInputNewCloudDataReceived;

@end

@implementation A3SalesCalcMainViewController
{
    NSNumber * _locationTax;
    NSString * _locationCode;
	BOOL _barButtonEnabled;
}

- (id)init {
	self = [super initWithStyle:UITableViewStyleGrouped];
	if (self) {
        // Custom initialization
        self.title = IS_IPHONE ? NSLocalizedString(@"Sales Calculator_Short", nil): NSLocalizedString(@"Sales Calculator", @"Sales Calculator");
        [self configureTableData];
        
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationTax = @0.0;
        [self getReverseGeocode];
	}
	
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	_barButtonEnabled = YES;

    [self makeBackButtonEmptyArrow];
	[self leftBarButtonAppsButton];
    [self rightButtonHistoryButton];
	[self enableControls:YES];
    
    self.tableView.tableHeaderView = self.headerView;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    self.tableView.separatorColor = COLOR_TABLE_SEPARATOR;
    if (IS_IPHONE) {
        self.tableView.separatorInset = UIEdgeInsetsMake(0, 15.0, 0, 0);
    } else {
        self.tableView.separatorInset = UIEdgeInsetsMake(0, 28.0, 0, 0);
        self.navigationItem.hidesBackButton = YES;
    }

    [self.headerView setResultData:[_preferences calcData] withAnimation:NO];

	if (IS_IPAD) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainMenuDidHide) name:A3NotificationMainMenuDidHide object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rightSideViewWillHide) name:A3NotificationRightSideViewWillDismiss object:nil];
	}
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cloudStoreDidImport) name:A3NotificationCloudKeyValueStoreDidImport object:nil];
	[self registerContentSizeCategoryDidChangeNotification];
}

- (void)cloudStoreDidImport {
	if (self.firstResponder) {
		_cancelInputNewCloudDataReceived = YES;
		[self.firstResponder resignFirstResponder];
	}

	[self setCurrencyFormatter:nil];
	_preferences = nil;

	self.headerView.currencyFormatter = self.currencyFormatter;

	[self configureTableData];
	[self.tableView reloadData];
	[self.headerView setResultData:self.preferences.calcData withAnimation:NO];
	[self.tableView setContentOffset:CGPointMake(0, -self.tableView.contentInset.top)];

	[self enableControls:_barButtonEnabled];
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

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	if ([self isMovingFromParentViewController] || [self isBeingDismissed]) {
		FNLOG();
		[self removeObserver];
	}
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

-(void)contentSizeDidChange:(NSNotification *)notification
{
    [_headerView setNeedsLayout];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)reloadSalesCalcData:(A3SalesCalcData *)aData
{
    [self.firstResponder resignFirstResponder];
    [self.textViewResponder resignFirstResponder];
	[self setFirstResponder:nil];
    _textViewResponder = nil;
    
    self.preferences.calcData = aData;
    
    NSMutableArray *sectionsArray = [NSMutableArray new];
    [sectionsArray addObject:[self knownValueTypeElements]];
    [sectionsArray addObject:[self valueAndPriceElementsFor:aData]];
    [sectionsArray addObject:[self advancedSectionWithData:aData]];

    [_headerView setResultData:aData withAnimation:YES];
    
    [self.root setSectionsArray:sectionsArray];
    [self.tableView reloadData];
}

- (void)rightButtonHistoryButton {
    UIImage *image = [UIImage imageNamed:@"history"];
    UIBarButtonItem *historyItem = [[UIBarButtonItem alloc] initWithImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(historyButtonAction:)];
	historyItem.tag = A3RightBarButtonTagHistoryButton;
    
    UIBarButtonItem *composeItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(saveToHistory:)];
	composeItem.tag = A3RightBarButtonTagComposeButton;
    
    self.navigationItem.rightBarButtonItems = @[historyItem, composeItem];
}

- (void)appsButtonAction:(UIBarButtonItem *)barButtonItem {
	[self.textViewResponder resignFirstResponder];

	[super appsButtonAction:barButtonItem];
	if (IS_IPAD) {
		[self enableControls:!self.A3RootViewController.showLeftView];
	}
}

- (void)enableControls:(BOOL)enable
{
	_barButtonEnabled = enable;
    if (enable) {
		[self.navigationItem.rightBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem *barButtonItem, NSUInteger idx, BOOL *stop) {
			switch (barButtonItem.tag) {
				case A3RightBarButtonTagHistoryButton:
                    barButtonItem.enabled = [SalesCalcHistory MR_countOfEntities] > 0 ? YES : NO;
					break;
				case A3RightBarButtonTagComposeButton:
                    barButtonItem.enabled = ([self.preferences.calcData.price doubleValue] > 0.0 && [self.preferences.calcData.discount doubleValue] > 0.0) ? YES : NO;
			}
		}];
    } else {
        [self.navigationItem.rightBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem *barButton, NSUInteger idx, BOOL *stop) {
            barButton.enabled = NO;
        }];
    }
	_headerView.detailInfoButton.enabled = enable;
	[self.navigationItem.leftBarButtonItem setEnabled:enable];
}

-(void)saveInputTextData:(A3SalesCalcData *)inputTextData {
	NSData *inputData = [NSKeyedArchiver archivedDataWithRootObject:inputTextData];
	[[A3SyncManager sharedSyncManager] setObject:inputData forKey:A3SalesCalcUserDefaultsSavedInputDataKey state:A3KeyValueDBStateModified];
}

-(void)saveToHistory:(id)sender {
    [self.firstResponder resignFirstResponder];
    [self.textViewResponder resignFirstResponder];
    
    BOOL result;
    A3TextViewElement *notes = (A3TextViewElement *)[self.root elementForIndexPath:[NSIndexPath indexPathForRow:2 inSection:2]];
    self.preferences.calcData.notes = notes.value;
    result = [self.preferences.calcData saveDataWithCurrencyCode:[self.currencyFormatter currencyCode]];
    
    if (result) {
        A3SalesCalcData *newData = [[A3SalesCalcData alloc] init];
        [self saveInputTextData:newData];
        [self reloadSalesCalcData:newData];
    }
    
    [self scrollToTopOfTableView];
	[self enableControls:YES];
}

#pragma mark - History

-(void)historyButtonAction:(id)sender
{
    [self.firstResponder resignFirstResponder];
	[self setFirstResponder:nil];

    [self.textViewResponder resignFirstResponder];
    A3SalesCalcHistoryViewController *viewController = [[A3SalesCalcHistoryViewController alloc] initWithStyle:UITableViewStylePlain];
    viewController.delegate = self;

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

-(void)didSelectHistoryData:(A3SalesCalcData *)aData
{
    self.preferences.calcData = aData;
    [self saveInputTextData:aData];
    
	[[A3SyncManager sharedSyncManager] setObject:aData.currencyCode forKey:A3SalesCalcUserDefaultsCurrencyCode state:A3KeyValueDBStateModified];

	[self setCurrencyFormatter:nil];
	self.headerView.currencyFormatter = self.currencyFormatter;
    
    NSMutableArray *sectionsArray = [NSMutableArray new];
    [sectionsArray addObject:[self knownValueTypeElements]];
    [sectionsArray addObject:[self valueAndPriceElementsFor:aData]];
    [sectionsArray addObject:[self advancedSectionWithData:aData]];
    
    [_headerView setResultData:aData withAnimation:YES];
    
    [self.root setSectionsArray:sectionsArray];
    [self.tableView reloadData];
}

-(void)clearSelectHistoryData {
	[self enableControls:YES];
}

-(void)dismissHistoryViewController {
	[self enableControls:YES];
    _headerView.detailInfoButton.enabled = YES;
}

#pragma mark -

- (A3JHTableViewRootElement *)root {
	if (!_root) {
		_root = [A3JHTableViewRootElement new];
		_root.tableView = self.tableView;
		_root.viewController = self;
	}
	return _root;
}

- (A3SalesCalcPreferences *)preferences {
	if (!_preferences) {
		_preferences = [A3SalesCalcPreferences new];
        NSData * saveData = [[A3SyncManager sharedSyncManager] objectForKey:A3SalesCalcUserDefaultsSavedInputDataKey];
        if (saveData) {
            A3SalesCalcData * calcData = (A3SalesCalcData * )[NSKeyedUnarchiver unarchiveObjectWithData:saveData];
            _preferences.calcData = calcData;
            
            if ( ![_preferences.calcData.additionalOff isEqualToNumber:@0] || ![_preferences.calcData.tax isEqualToNumber:@0] ) {
                _preferences.initializedBySaveData = YES;
            }

        } else {
            _preferences.calcData.shownPriceType = ShowPriceType_Origin;
            _preferences.calcData.priceType = A3TableViewValueTypeCurrency;
            _preferences.calcData.discountType = A3TableViewValueTypePercent;
            _preferences.calcData.additionalOffType = A3TableViewValueTypePercent;
            _preferences.calcData.taxType = A3TableViewValueTypePercent;
            _preferences.initializedBySaveData = NO;
        }
	}
	return _preferences;
}

-(A3SalesCalcHeaderView *)headerView {
    
    if (!_headerView) {
        _headerView = [[A3SalesCalcHeaderView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, IS_IPAD? 158.0 : 104.0 )];
		_headerView.currencyFormatter = self.currencyFormatter;
        [_headerView.detailInfoButton addTarget:self action:@selector(detailInfoButtonTouchedUp) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _headerView;
}

-(void)detailInfoButtonTouchedUp {
    [self.firstResponder resignFirstResponder];
	[self setFirstResponder:nil];
    [self.textViewResponder resignFirstResponder];
    
    _headerView.detailInfoButton.enabled = NO;
    
    A3SalesCalcDetailInfoPopOverView *infoView = [[A3SalesCalcDetailInfoPopOverView alloc] initWithStyle:UITableViewStylePlain];
    
    if ([UIScreen mainScreen].bounds.size.height == 480.0) {
        infoView.tableView.scrollEnabled = YES;
    } else {
        infoView.tableView.scrollEnabled = NO;
    }
    infoView.tableView.showsVerticalScrollIndicator = NO;
    [infoView setResult:_preferences.calcData];
    self.localPopoverController = [[UIPopoverController alloc] initWithContentViewController:infoView];
    self.localPopoverController.backgroundColor = [UIColor whiteColor];
    self.localPopoverController.delegate = self;
    [self.localPopoverController setPopoverContentSize:CGSizeMake(224, 311) animated:NO];
    [self.localPopoverController presentPopoverFromRect:[_headerView convertRect:_headerView.detailInfoButton.frame fromView:self.view]
                                                 inView:self.view
                               permittedArrowDirections:UIPopoverArrowDirectionUp
                                               animated:YES];

    [self.localPopoverController setPopoverContentSize:CGSizeMake(224, infoView.tableView.contentSize.height) animated:NO];
    
    // 기타 & 버튼들, 비활성 처리.
	[self enableControls:NO];
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
	[self enableControls:YES];
}

- (NSString *)defaultCurrencyCode {
	NSString *currencyCode = [[A3SyncManager sharedSyncManager] objectForKey:A3SalesCalcUserDefaultsCurrencyCode];
	if (!currencyCode) {
		currencyCode = [[NSLocale currentLocale] objectForKey:NSLocaleCurrencyCode];
	}
	return currencyCode;
}

#pragma mark TableView DataSource Configuration

- (void)configureTableData {
	_preferences = [self preferences];

	NSMutableArray *sectionsArray = [NSMutableArray new];
	[sectionsArray addObject:[self knownValueTypeElements] ];
	[sectionsArray addObject:[self valueAndPriceElementsFor:nil]];
	//[sectionsArray addObject:[self expandable:nil]];
	[sectionsArray addObject:[self advancedSectionWithData:nil]];

	[self.root setSectionsArray:sectionsArray];
//        [self adjustElementValue];
}

- (id)knownValueTypeElements
{
    NSMutableArray *elements = [NSMutableArray new];
    
    A3TableViewCheckMarkElement *originPrice = [A3TableViewCheckMarkElement new];
    originPrice.title = NSLocalizedString(@"Original Price", @"Original Price");
    originPrice.identifier = 0;
    originPrice.checked = _preferences.calcData.shownPriceType == ShowPriceType_Origin;
    [elements addObject:originPrice];
    
    A3TableViewCheckMarkElement *salePrice = [A3TableViewCheckMarkElement new];
    //salePrice.title = @"Sale Price";
    salePrice.title = IS_IPAD? NSLocalizedString(@"Sale Price with Tax", @"Sale Price with Tax") : NSLocalizedString(@"Sale Price w/Tax", @"Sale Price w/Tax");
    salePrice.identifier = 0;
    salePrice.checked = _preferences.calcData.shownPriceType == ShowPriceType_SalePriceWithTax;
    [elements addObject:salePrice];
    
    return elements;
}

- (NSString *)originalPriceTitle {
	return _preferences.calcData.shownPriceType == ShowPriceType_Origin ?
			NSLocalizedString(@"Original Price", @"Original Price") :
			(IS_IPAD ?
					NSLocalizedString(@"Sale Price with Tax", @"Sale Price with Tax") :
					NSLocalizedString(@"Sale Price w/Tax", @"Sale Price w/Tax"));
}

- (id)valueAndPriceElementsFor:(A3SalesCalcData *)aData
{
    NSMutableArray *elements = [NSMutableArray new];

    if (!_price) {
        _price = [A3TableViewInputElement new];
    }
    _price.title = [self originalPriceTitle];
    _price.inputType = A3TableViewEntryTypeCurrency;
	_price.valueType = _preferences.calcData.priceType;
    _price.prevEnabled = NO;
    _price.nextEnabled = YES;
    _price.onEditingBegin = [self cellTextInputBeginBlock];
    _price.onEditingValueChanged = [self cellTextInputChangedBlock];
//    _price.onEditingFinished = [self cellTextInputFinishedBlock];
    _price.onEditingFinishAll = [self cellTextInputFinishAllBlock];
    _price.doneButtonPressed = [self cellInputDoneButtonPressed];
    _price.identifier = A3TableElementCellType_Price;
	_price.delegate = self;
	_price.currencyCode = self.defaultCurrencyCode;

    [elements addObject:_price];
    if (aData) {
        // 세일된 가격
        _price.value = [self.decimalFormatter stringFromNumber:aData.price];
    }
    else {
        _price.value = [self.decimalFormatter stringFromNumber:self.preferences.calcData.price];
    }
    
    A3TableViewInputElement *discount = [A3TableViewInputElement new];
    discount.title = NSLocalizedString(@"Discount", @"Discount");
    discount.inputType = A3TableViewEntryTypePercent;
	discount.valueType = self.preferences.calcData.discountType;
    discount.prevEnabled = YES;
    discount.nextEnabled = YES;
    discount.onEditingBegin = [self cellTextInputBeginBlock];
    discount.onEditingValueChanged = [self cellTextInputChangedBlock];
    discount.onEditingFinishAll = [self cellTextInputFinishAllBlock];
    discount.doneButtonPressed = [self cellInputDoneButtonPressed];
    discount.identifier = A3TableElementCellType_Discount;
	discount.currencyCode = self.defaultCurrencyCode;

    [elements addObject:discount];
    if (aData) {
        discount.value = [self.decimalFormatter stringFromNumber:aData.discount];
        discount.valueType = aData.discountType;
    } else {
        discount.value = [self.decimalFormatter stringFromNumber:self.preferences.calcData.discount];
    }
    
    return elements;
}

- (NSArray *)advancedSectionWithData:(A3SalesCalcData *)aData {
    NSMutableArray *elements = [NSMutableArray new];
    
    A3TableViewInputElement *additional = [A3TableViewInputElement new];
    additional.title = NSLocalizedString(@"Additional Off", @"Additional Off");
    additional.placeholder = NSLocalizedString(@"Optional", @"Optional");
    additional.inputType = A3TableViewEntryTypePercent;
	additional.valueType = self.preferences.calcData.additionalOffType;
    additional.prevEnabled = YES;
    additional.nextEnabled = YES;
    additional.onEditingBegin = [self cellTextInputBeginBlock];
    additional.onEditingValueChanged = [self cellTextInputChangedBlock];
//    additional.onEditingFinished = [self cellTextInputFinishedBlock];
    additional.onEditingFinishAll = [self cellTextInputFinishAllBlock];
    additional.doneButtonPressed = [self cellInputDoneButtonPressed];
    additional.identifier = A3TableElementCellType_Additional;
	additional.delegate = self;
	additional.currencyCode = self.defaultCurrencyCode;
    if (aData) {
        additional.value = [self.decimalFormatter stringFromNumber:aData.additionalOff];
        additional.valueType = aData.additionalOffType;
    } else {
        additional.value = [self.decimalFormatter stringFromNumber:self.preferences.calcData.additionalOff];
    }
    
    A3TableViewInputElement *tax = [A3TableViewInputElement new];
    tax.title = NSLocalizedString(@"Tax", @"Tax");
    tax.placeholder = NSLocalizedString(@"Optional", @"Optional");
    tax.inputType = A3TableViewEntryTypePercent;
	tax.valueType = self.preferences.calcData.taxType;
    tax.prevEnabled = YES;
    tax.nextEnabled = YES;
    tax.onEditingBegin = [self cellTextInputBeginBlock];
    tax.onEditingValueChanged = [self cellTextInputChangedBlock];
//    tax.onEditingFinished = [self cellTextInputFinishedBlock];
    tax.onEditingFinishAll = [self cellTextInputFinishAllBlock];
    tax.doneButtonPressed = [self cellInputDoneButtonPressed];
    tax.identifier = A3TableElementCellType_Tax;
	tax.delegate = self;
	tax.currencyCode = self.defaultCurrencyCode;
    if (aData) {
        tax.value = [self.decimalFormatter stringFromNumber:aData.tax];
        tax.valueType = aData.taxType;
    }
    else {
        tax.value = [self.decimalFormatter stringFromNumber:self.preferences.calcData.tax];
    }
    
    _taxElement = tax;
    [self reloadLocationTax];
    
    if (!_notes) {
        _notes = [A3TextViewElement new];
    }
    _notes.identifier = A3TableElementCellType_Note;
    __weak A3SalesCalcMainViewController *weakSelf = self;
    _notes.onEditingBegin = ^(A3TextViewElement *element, UITextView *textView) {
        weakSelf.textViewResponder = textView;
    };
	_notes.onEditingDidEnd = ^(A3TextViewElement *element, UITextView *textView) {
		[weakSelf.tableView setContentOffset:CGPointMake(0, -weakSelf.tableView.contentInset.top )];
		if (weakSelf.cancelInputNewCloudDataReceived) {
			weakSelf.cancelInputNewCloudDataReceived = NO;
			return;
		}
		weakSelf.preferences.calcData.notes = textView.text;
		[weakSelf saveInputTextData:weakSelf.preferences.calcData];
	};
    if (aData) {
        _notes.value = aData.notes;
    }
    else {
        _notes.value = self.preferences.calcData.notes;
    }
    
    [elements addObject:additional];
    [elements addObject:tax];
    [elements addObject:_notes];
    
    return elements;
}

#pragma mark - Input Related
- (CellTextInputBlock)cellTextInputBeginBlock
{
    if (!_cellTextInputBeginBlock) {
		__typeof(self) __weak  weakSelf = self;
        _cellTextInputBeginBlock = ^(A3TableViewInputElement *element, UITextField *textField) {
            weakSelf.firstResponder = textField;
			[weakSelf addNumberKeyboardNotificationObservers];
        };
    }
    
    return _cellTextInputBeginBlock;
}

- (CellTextInputBlock)cellTextInputChangedBlock
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

// 계산 값 입력을 마친 경우에 호출됨.
- (CellTextInputBlock)cellTextInputFinishAllBlock {
    if (!_cellTextInputFinishAllBlock) {
        __typeof(self) __weak weakSelf = self;
        
        _cellTextInputFinishAllBlock = ^(A3TableViewInputElement *element, UITextField *textField) {
            if (weakSelf.firstResponder == textField) {
                weakSelf.firstResponder = nil;
            }
			[weakSelf removeNumberKeyboardNotificationObservers];

			if (weakSelf.cancelInputNewCloudDataReceived) {
				weakSelf.cancelInputNewCloudDataReceived = NO;
				return;
			}


			NSNumber *inputNumber = ([textField.text length] == 0 && [element.value length] > 0) ? [weakSelf.decimalFormatter numberFromString:element.value] : [weakSelf.decimalFormatter numberFromString:textField.text];

            switch (element.identifier) {
                case A3TableElementCellType_Price:
                case A3TableElementCellType_Discount:
                case A3TableElementCellType_Additional:
                case A3TableElementCellType_Tax:
                {
                    element.value = [weakSelf.decimalFormatter stringFromNumber:inputNumber];
                }
                    break;
                    
                default:
                {
                    if (textField.text && textField.text.length!=0) {
                        element.value = textField.text;
                    }
                }
                    break;
            }

            // InputString set to value.
            if (element.identifier == A3TableElementCellType_Price) {
                [weakSelf.preferences.calcData setPrice:inputNumber];
                [weakSelf.preferences.calcData setPriceType:element.valueType];
            }
            else if (element.identifier == A3TableElementCellType_Discount) {
                [weakSelf.preferences.calcData setDiscount:inputNumber];
                [weakSelf.preferences.calcData setDiscountType:element.valueType];
            }
            else if (element.identifier == A3TableElementCellType_Additional) {
                [weakSelf.preferences.calcData setAdditionalOff:inputNumber];
                [weakSelf.preferences.calcData setAdditionalOffType:element.valueType];
				textField.placeholder = NSLocalizedString(@"Optional", @"Optional");
            }
            else if (element.identifier == A3TableElementCellType_Tax) {
                [weakSelf.preferences.calcData setTax:inputNumber];
                [weakSelf.preferences.calcData setTaxType:element.valueType];
				textField.placeholder = NSLocalizedString(@"Optional", @"Optional");
            }
            else if (element.identifier == A3TableElementCellType_Note) {
                [weakSelf.preferences.calcData setNotes:element.value];
                if ([textField.text length] == 0) {
                    textField.placeholder = NSLocalizedString(@"Notes", @"Notes");
                }
                else {
                    textField.placeholder = [textField text];
                }
            }

			if (element.valueType == A3TableViewValueTypePercent) {
                NSNumberFormatter *percentFormatter = [NSNumberFormatter new];

                if ((!element || ![element value]) && [textField.text length] == 0) {
                    if (element.identifier == A3TableElementCellType_Discount) {
                        element.value = @"0";

                        if ([element valueType] == A3TableViewValueTypePercent) {
                            [percentFormatter setNumberStyle:NSNumberFormatterPercentStyle];
                            textField.text = [percentFormatter stringFromNumber:@(0)];
                        }
                        else {
                            textField.text = [weakSelf.currencyFormatter stringFromNumber:@(0)];
                        }
                    }
                }
                else {
                    if (element.identifier == A3TableElementCellType_Discount || (element.identifier == A3TableElementCellType_Tax && [weakSelf.preferences.calcData shownPriceType] == ShowPriceType_SalePriceWithTax)) {
                        if ([element valueType] == A3TableViewValueTypePercent) {
                            textField.text = [weakSelf.percentFormatter stringFromNumber:@([inputNumber doubleValue]/ 100.0)];
                        }
                        else {
                            textField.text = [weakSelf.currencyFormatter stringFromNumber:inputNumber];
                        }
                    }
                    else {
                        if ([element.value doubleValue] > 0) {
                            if ([element valueType] == A3TableViewValueTypePercent) {
								textField.text = [weakSelf.percentFormatter stringFromNumber:@([inputNumber doubleValue] / 100.0)];
                            }
                            else {
                                textField.text = [weakSelf.currencyFormatter stringFromNumber:inputNumber];
                            }
                        }
                        else {
                            textField.text = @"";
                        }
                    }
                }
            }
            else {
                // update currency to percent
                NSNumber *currency;
                NSNumber *percent;
                NSIndexPath * indexPath = [weakSelf.root indexPathForElement:element];
                UITableViewCell *cell = [weakSelf.tableView cellForRowAtIndexPath:indexPath];
				BOOL showPlaceholderWhenValueIsEmpty = NO;
                
                switch (element.identifier) {
                    case A3TableElementCellType_Price:
                        [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                        break;
                    case A3TableElementCellType_Additional:
                    case A3TableElementCellType_Tax:
						showPlaceholderWhenValueIsEmpty = YES;
					case A3TableElementCellType_Discount:
                    {
                        if (element.identifier == A3TableElementCellType_Discount && element.valueType == A3TableViewValueTypeCurrency) {
                            currency = weakSelf.preferences.calcData.discount;
                            percent = [A3SalesCalcCalculator discountPercentForCalcData:weakSelf.preferences.calcData];
                        }
                        else if (element.identifier == A3TableElementCellType_Additional && element.valueType == A3TableViewValueTypeCurrency) {
                            currency = weakSelf.preferences.calcData.additionalOff;
                            percent = [A3SalesCalcCalculator additionalOffPercentForCalcData:weakSelf.preferences.calcData];
                        }
                        else if (element.identifier == A3TableElementCellType_Tax && element.valueType == A3TableViewValueTypeCurrency) {
                            currency = weakSelf.preferences.calcData.tax;
                            percent = [A3SalesCalcCalculator taxPercentForCalcData:weakSelf.preferences.calcData];
                        }
                        
                        [weakSelf updateTableViewCell:cell atIndexPath:indexPath textFieldTextToCurrency:currency andPercent:percent showPlaceholder:showPlaceholderWhenValueIsEmpty ];
                    }
                        break;
                }
            }
            [weakSelf enableControls:YES];
            [weakSelf reloadPercentValuesToTableDataSource];
            [weakSelf saveInputTextData:weakSelf.preferences.calcData];

            // 계산 결과 반영.
            [weakSelf.headerView setResultData:weakSelf.preferences.calcData withAnimation:YES];
            
            // 계산 결과 저장.
            if (NO == [weakSelf.preferences didSaveBefore]) {
                [weakSelf.preferences setOldCalcData:weakSelf.preferences.calcData];
            }
        };
    }
    
    return _cellTextInputFinishAllBlock;
}

-(BasicBlock)cellInputDoneButtonPressed {
    
    if (!_cellInputDoneButtonPressed) {
        __weak A3SalesCalcMainViewController * weakSelf = self;
        _cellInputDoneButtonPressed = ^(id sender){
			weakSelf.firstResponder = nil;

            if (weakSelf.preferences.calcData == nil) {
                return;
            }

            if (!weakSelf.preferences.calcData.price || [weakSelf.preferences.calcData.price isEqualToNumber:@0] ||
                !weakSelf.preferences.calcData.discount || [weakSelf.preferences.calcData.discount isEqualToNumber:@0])
                return;

            [weakSelf scrollToTopOfTableView];
        };
    }
    
    return _cellInputDoneButtonPressed;
}

-(CellExpandedBlock)cellExpandedBlock
{
    if (!_cellExpandedBlock) {
        __weak A3SalesCalcMainViewController * weakSelf = self;
        _cellExpandedBlock = ^(A3JHTableViewExpandableElement *element) {
            weakSelf.firstResponder = nil;
            [weakSelf.tableView reloadData];
        };
    }
    
    return _cellExpandedBlock;
}


- (void)selectTableViewController:(A3JHSelectTableViewController *)viewController selectedItemIndex:(NSInteger)index indexPathOrigin:(NSIndexPath *)indexPathOrigin {
	[self.navigationController popViewControllerAnimated:YES];
	viewController.root.selectedIndex = index;
    
	[self.tableView reloadRowsAtIndexPaths:@[indexPathOrigin] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.root numberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.root numberOfRowsInSection:section];
}

//static NSString *CellIdentifier = @"Cell";

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if ( [_locationCode isEqualToString:@"US"] && ([_taxElement.value isEqualToNumber:@0] || !_taxElement.value)) {
//        _taxElement.value = _locationTax;
//    }
    
    UITableViewCell *cell = [self.root cellForRowAtIndexPath:indexPath];
    
    if ([cell isKindOfClass:[A3JHTableViewEntryCell class]]) {
        ((A3JHTableViewEntryCell *)cell).textField.textColor = COLOR_TABLE_DETAIL_TEXTLABEL;
        ((A3JHTableViewEntryCell *)cell).textField.font = [UIFont systemFontOfSize:17];
    }
    
    if (indexPath.section==1 && indexPath.row==2) {
        // ExpanableCell selectionStyle
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    [self updateTableViewCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)updateTableViewCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath {
    A3JHTableViewElement *element = [self.root elementForIndexPath:indexPath];
    switch (element.identifier) {
        case A3TableElementCellType_Price:
            break;

        case A3TableElementCellType_Discount:
        {
            A3TableViewInputElement *discount = (A3TableViewInputElement *)element;
            if (discount.valueType == A3TableViewValueTypeCurrency) {
                NSNumber *value = [self.decimalFormatter numberFromString:[discount value]];
                [self updateTableViewCell:cell atIndexPath:indexPath textFieldTextToCurrency:value andPercent:[A3SalesCalcCalculator discountPercentForCalcData:self.preferences.calcData] showPlaceholder:NO ];
            }
        }
            break;

        case A3TableElementCellType_Additional:
        {
            if (!element.value || (element && ([element.value length] == 0 || [element.value isEqualToString:@"0"]))) {
                ((A3JHTableViewEntryCell *)cell).textField.text = @"";
                ((A3JHTableViewEntryCell *)cell).textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Optional", @"Optional")
                                                                                                                   attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:17]} ];
            }
            else {
                A3TableViewInputElement *additional = (A3TableViewInputElement *)element;
                if (additional.valueType == A3TableViewValueTypeCurrency) {
                    NSNumber *value = [self.decimalFormatter numberFromString:[additional value]];
                    [self updateTableViewCell:cell atIndexPath:indexPath textFieldTextToCurrency:value andPercent:[A3SalesCalcCalculator additionalOffPercentForCalcData:self.preferences.calcData] showPlaceholder:NO ];
                }
            }
        }
            break;
            
        case A3TableElementCellType_Tax:
        {
            if ([_preferences.calcData shownPriceType] == ShowPriceType_Origin) {
                if (!element.value || (element && ([element.value length] == 0 || [element.value isEqualToString:@"0"]))) {
                    ((A3JHTableViewEntryCell *)cell).textField.text = @"";
                    ((A3JHTableViewEntryCell *)cell).textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Optional", @"Optional")
                                                                                                                       attributes:@{ //NSForegroundColorAttributeName : [UIColor redColor],
                                                                                                                                    NSFontAttributeName : [UIFont systemFontOfSize:17] } ];
                }
                else {
                    A3TableViewInputElement *tax = (A3TableViewInputElement *)element;
                    if (tax.valueType == A3TableViewValueTypeCurrency) {
                        NSNumber *value = [self.decimalFormatter numberFromString:[tax value]];
                        [self updateTableViewCell:cell atIndexPath:indexPath textFieldTextToCurrency:value andPercent:[A3SalesCalcCalculator taxPercentForCalcData:self.preferences.calcData] showPlaceholder:YES ];
                    }
                }
            }
        }
            break;

        default:
            break;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        A3TableViewCheckMarkElement * row0 = _root.sectionsArray[0][0];
        A3TableViewCheckMarkElement * row1 = _root.sectionsArray[0][1];
        row0.checked = indexPath.row==0 ? YES : NO;
        row1.checked = indexPath.row==1 ? YES : NO;
        _preferences.calcData.shownPriceType = indexPath.row;
        if ([_preferences.calcData shownPriceType] == ShowPriceType_SalePriceWithTax && (![self.preferences.calcData tax] || [[self.preferences.calcData tax] isEqualToNumber:@0])) {
            [self reloadLocationTax];
        }

        [_headerView setResultData:self.preferences.calcData withAnimation:YES];
        [_headerView setNeedsLayout];
        
        _price.title = [self originalPriceTitle];
        A3JHTableViewEntryCell *cell = (A3JHTableViewEntryCell *)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
        cell.textLabel.text = _price.title;
        
        //[self.tableView reloadData];
        [self reloadPercentValuesToTableDataSource];
        
        if ([self.preferences didSaveBefore]==NO) {
            [self.preferences setOldCalcData:_preferences.calcData];
            [self saveInputTextData:self.preferences.calcData];
        }
    }
    
	[self.root didSelectRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1 && indexPath.row == 3) {
        // Advanced 섹션 첫번째 셀 높이, 하드코딩..
        return IS_RETINA? 43.5 : 43.0;
    }
    
	return [self.root heightForRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([cell isKindOfClass:[A3JHTableViewEntryCell class]]) {
		[(A3JHTableViewEntryCell *) cell calculateTextFieldFrame];
	}
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section==0) {
        return NSLocalizedString(@"KNOWN VALUE", @"KNOWN VALUE");
    }
    
    return nil;
}

-(void)scrollToTopOfTableView {
    if (IS_LANDSCAPE) {
        [UIView beginAnimations:A3AnimationIDKeyboardWillShow context:nil];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationCurve:7];
        [UIView setAnimationDuration:0.35];
        self.tableView.contentOffset = CGPointMake(0.0, -(self.navigationController.navigationBar.bounds.size.height + [[UIApplication sharedApplication] statusBarFrame].size.width));
        [UIView commitAnimations];
    } else {
        [UIView beginAnimations:A3AnimationIDKeyboardWillShow context:nil];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationCurve:7];
        [UIView setAnimationDuration:0.35];
        self.tableView.contentOffset = CGPointMake(0.0, -(self.navigationController.navigationBar.bounds.size.height + [[UIApplication sharedApplication] statusBarFrame].size.height));
        [UIView commitAnimations];
    }
}

#pragma mark - etc_countries Rate List

// 미국 판매세 세율은 일반 상품에 적용되는 세율과 식당에 적용되는 세율이 다른 경우가 있습니다.
// Sales Calc는 일반 상품에 적용되는 세금을 이용합니다.
// Tip Calc는 식당에 적용되는 세율을 적용합니다.
// 최종 업데이트는 5월 23일 Wikipedia 정보 기준입니다.
- (NSDictionary *)knownUSTaxes {
	return @{
             @"AL" : @4,		// Alabama
             @"AK" : @0,		// Alaska
             @"AZ" : @5.6,		// Arizona
             @"AR" : @6.5,		// Arkansas
             @"CA" : @7.5,		// California
             @"CO" : @2.9,		// Colorado
             @"CT" : @6.35,		// Connecticut
             @"DE" : @0,		// Delaware
             @"DC" : @6,		// District of Columbia, 10%
             @"FL" : @6,		// Florida, 9%
             @"GA" : @4,		// Georgia
             @"GU" : @4,		// Guam
             @"HI" : @4,		// Hawaii
             @"ID" : @6,		// Idaho
             @"IL" : @6.25,		// Illinois, 8.25%
             @"IN" : @7,		// Indiana, 9%
             @"IA" : @6,		// Iowa
             @"KS" : @6.15,		// Kansas
             @"KY" : @6,		// Kentucky
             @"LA" : @4,		// Louisiana
             @"ME" : @5.5,		// Maine, 7%
             @"MD" : @6,		// Maryland
             @"MA" : @6.25,		// Massachusetts, 7%
             @"MI" : @6,		// Michigan
             @"MN" : @6.875,	// Minnesota, 10.775%
             @"MS" : @7,		// Mississippi
             @"MO" : @4.225,	// Missouri
             @"MT" : @0,		// Montana
             @"NE" : @5.5,		// Nebraska, 9.5%
             @"NV" : @6.85,		// Nevada
             @"NH" : @0,		// New Hampshire, 9%
             @"NJ" : @7,		// New Jersey
             @"NM" : @5.125,	// New Mexico
             @"NY" : @4,		// New York
             @"NC" : @4.75,		// North Carolina, 8.5
             @"ND" : @5,		// North Dakota
             @"OH" : @5.75,		// Ohio
             @"OK" : @8.517,	// Oklahoma
             @"OR" : @0,		// Oregon
             @"PA" : @6,		// Pennsylvania
             @"PR" : @7,		// Puerto Rico
             @"RI" : @7,		// Rhode Island, 8%
             @"SC" : @6,		// South Carolina, 10.5%
             @"SD" : @4,		// South Dakota
             @"TN" : @7,		// Tennessee
             @"TX" : @6.25,		// Texas
             @"UT" : @4.7,		// Utah
             @"VT" : @6,		// Vermont, 9%
             @"VA" : @4.3,		// Virginia, 5.3%
             @"WA" : @6.5,		// Washington, 10%
             @"WV" : @6,		// West Virginia
             @"WI" : @5,		// Wisconsin
			 @"WY" : @4,		// Wyoming
             };
}

- (void)reloadPercentValuesToTableDataSource {
    NSNumber *currency;
    NSNumber *percent;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:1];
    A3TableViewInputElement *element = (A3TableViewInputElement *)[self.root elementForIndexPath:indexPath];
    if (element.valueType == A3TableViewValueTypeCurrency) {
        currency = self.preferences.calcData.discount;
        percent = [A3SalesCalcCalculator discountPercentForCalcData:self.preferences.calcData];
        A3JHTableViewEntryCell *cell = (A3JHTableViewEntryCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        if (cell && cell.textField != self.firstResponder) {
            [self updateTableViewCell:cell atIndexPath:indexPath textFieldTextToCurrency:currency andPercent:percent showPlaceholder:NO ];
        }
    }
    
    indexPath = [NSIndexPath indexPathForRow:0 inSection:2];
    element = (A3TableViewInputElement *)[self.root elementForIndexPath:indexPath];
    if (element.valueType == A3TableViewValueTypeCurrency) {
        currency = self.preferences.calcData.additionalOff;
        percent = [A3SalesCalcCalculator additionalOffPercentForCalcData:self.preferences.calcData];
        A3JHTableViewEntryCell *cell = (A3JHTableViewEntryCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        if (cell && cell.textField != self.firstResponder) {
            [self updateTableViewCell:cell atIndexPath:indexPath textFieldTextToCurrency:currency andPercent:percent showPlaceholder:NO ];
        }
    }
    
    indexPath = [NSIndexPath indexPathForRow:1 inSection:2];
    element = (A3TableViewInputElement *)[self.root elementForIndexPath:indexPath];
    if (element.valueType == A3TableViewValueTypeCurrency) {
        currency = self.preferences.calcData.tax;
        percent = [A3SalesCalcCalculator taxPercentForCalcData:self.preferences.calcData];
        A3JHTableViewEntryCell *cell = (A3JHTableViewEntryCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        if (cell && cell.textField != self.firstResponder) {
            [self updateTableViewCell:cell atIndexPath:indexPath textFieldTextToCurrency:currency andPercent:percent showPlaceholder:YES ];
        }
    }
    else {
        A3JHTableViewEntryCell *cell = (A3JHTableViewEntryCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        if ([self.preferences.calcData shownPriceType] == ShowPriceType_SalePriceWithTax) {
            cell.textField.text = [self.percentFormatter stringFromNumber:@([[self.preferences.calcData tax] doubleValue] / 100.0)];
        }
        else {
            if ([self.preferences.calcData.tax doubleValue] > 0) {
				cell.textField.text = [self.percentFormatter stringFromNumber:@([[self.preferences.calcData tax] doubleValue] / 100.0)];
            }
            else {
                cell.textField.text = @"";
            }
        }
    }
}

- (void)updateTableViewCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath textFieldTextToCurrency:(NSNumber *)amount andPercent:(NSNumber *)percent showPlaceholder:(BOOL)showPlaceholder {
	// IndexPath 2,1 = Tax
    if ([indexPath section] == 2 && [indexPath row] == 1) {
        if ((!amount || [amount isEqualToNumber:@0]) && [self.preferences.calcData shownPriceType] != ShowPriceType_SalePriceWithTax) {
            ((A3JHTableViewEntryCell *)cell).textField.text = @"";
            return;
        }
    } else {
        if ((!amount || [amount isEqualToNumber:@0]) && showPlaceholder) {
            ((A3JHTableViewEntryCell *)cell).textField.text = @"";
            return;
        }
    }
    
    NSMutableString *text = [NSMutableString new];
    [text appendString:[self.currencyFormatter stringFromNumber:amount]];

	NSNumberFormatter *formatter = [NSNumberFormatter new];
    formatter.numberStyle = NSNumberFormatterPercentStyle;
    formatter.allowsFloats = YES;
    formatter.minimumFractionDigits = 1;
	// NaN (Not a Number) 이 표시되는 것을 방지하기 위해서 percent 가 NaN인 경우 0으로 대치
	double percentValue = [percent doubleValue];
	if ([percent isEqualToNumber:@(NAN)]) {
		percentValue = 0.0;
	}
	[text appendFormat:@" (%@)", [formatter stringFromNumber:@(percentValue / 100.0)] ];
    
    ((A3JHTableViewEntryCell *)cell).textField.text = text;
}

#pragma mark CLLocationManager stuff

//bool kIsFirstTipCalcGeocodeTemp = YES; // temp
- (void)getReverseGeocode
{
    if(_locationManager == nil)
        return;
    
	//if (!self.delegate) return;
    
	_locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    [_locationManager startUpdatingLocation];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
	if (!_locationManager)
        return;

	[manager stopUpdatingLocation];

	CLGeocoder* geocoder = [[CLGeocoder alloc] init];

	[geocoder reverseGeocodeLocation: _locationManager.location completionHandler:^(NSArray *placemarks, NSError *error) {

		FNLOG(@"ori------");
		CLPlacemark *placemark = [placemarks objectAtIndex:0];
		FNLOG(@"%@", placemark.ISOcountryCode);// 1
		FNLOG(@"%@", placemark.country);
		FNLOG(@"%@", placemark.postalCode);
		FNLOG(@"%@", placemark.administrativeArea);//4
		FNLOG(@"%@", placemark.subAdministrativeArea);
		FNLOG(@"%@", placemark.locality);
		FNLOG(@"%@", placemark.subLocality);
		FNLOG(@"%@", placemark.thoroughfare);
		FNLOG(@"%@", placemark.subThoroughfare);
		FNLOG(@"--------");

		if ([placemark.ISOcountryCode isEqualToString:@"US"] &&
				[placemark.administrativeArea length]) {
			NSNumber *knownTax = self.knownUSTaxes[placemark.administrativeArea];
			if (knownTax) {
				_locationTax = knownTax;
				_locationCode = @"US";
				[self reloadLocationTax];
				[self.tableView reloadData];
			}   
		}

		_locationManager.delegate = nil;
		_locationManager = nil;
	}];
}

- (void)reloadLocationTax {
    if (_taxElement && [_locationCode isEqualToString:@"US"]) {
        _taxElement.value = [self.decimalFormatter stringFromNumber:_locationTax];
        self.preferences.calcData.tax = _locationTax;
    }
}

#pragma mark - Number Keyboard Currency Button Notification

- (void)currencySelectButtonAction:(NSNotification *)notification {
	[self.firstResponder resignFirstResponder];
	A3CurrencySelectViewController *viewController = [self presentCurrencySelectViewControllerWithCurrencyCode:notification.object];
	viewController.delegate = self;
}

- (void)searchViewController:(UIViewController *)viewController itemSelectedWithItem:(NSString *)currencyCode {
	[[A3SyncManager sharedSyncManager] setObject:currencyCode forKey:A3SalesCalcUserDefaultsCurrencyCode state:A3KeyValueDBStateModified];

	[self setCurrencyFormatter:nil];
	self.headerView.currencyFormatter = self.currencyFormatter;

	[self configureTableData];
	[self.tableView reloadData];
	[self.headerView setResultData:self.preferences.calcData withAnimation:NO];
	[self.tableView setContentOffset:CGPointMake(0, -self.tableView.contentInset.top)];
}

#pragma mark - Number Keyboard, Calculator Button Notification

- (void)calculatorButtonAction {
	_calculatorTargetIndexPath = [self.tableView indexPathForCellSubview:(UIView *) self.firstResponder];
	_calculatorTargetElement = (A3TableViewInputElement *) [self.root elementForIndexPath:_calculatorTargetIndexPath];
	[self.firstResponder resignFirstResponder];
	A3CalculatorViewController *viewController = [self presentCalculatorViewController];
	viewController.delegate = self;
}

- (void)calculatorDidDismissWithValue:(NSString *)value {
	A3JHTableViewEntryCell *cell = (A3JHTableViewEntryCell *) [self.root cellForRowAtIndexPath:_calculatorTargetIndexPath];
	cell.textField.text = value;
	self.cellTextInputFinishAllBlock(_calculatorTargetElement, cell.textField);
}

- (NSNumberFormatter *)currencyFormatterForTableViewInputElement {
	return self.currencyFormatter;
}

@end
