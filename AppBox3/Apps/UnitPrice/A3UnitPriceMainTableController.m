//
//  A3UnitPriceMainTableController.m
//  A3TeamWork
//
//  Created by kihyunkim on 2014. 2. 22..
//  Copyright (c) 2014년 ALLABOUTAPPS. All rights reserved.
//

#import "A3UnitPriceMainTableController.h"
#import "A3UnitPriceInputView.h"
#import "A3UnitPriceSliderView.h"
#import "A3UnitPriceHistoryViewController.h"
#import "A3UnitPriceDetailTableController.h"
#import "UnitPriceInfo.h"
#import "UnitPriceHistory.h"
#import "A3UnitPriceCompareSliderCell.h"
#import "A3UnitPriceInfoCell.h"
#import "A3AppDelegate.h"
#import "UIViewController+NumberKeyboard.h"
#import "UIViewController+A3Addition.h"
#import "UILabel+BaseAlignment.h"
#import "UIViewController+iPad_rightSideView.h"
#import "UnitPriceHistory+extension.h"
#import "UnitPriceInfo+extension.h"
#import "A3UserDefaults.h"
#import "A3UnitDataManager.h"

NSString *const A3NotificationUnitPriceCurrencyCodeChanged = @"A3NotificationUnitPriceCurrencyCodeChanged";

@interface A3UnitPriceMainTableController () <UnitPriceInputDelegate, A3UnitPriceModifyDelegate, UnitPriceHistoryViewControllerDelegate>
{
    float price1UnitPrice;
    float price2UnitPrice;
}

@property (nonatomic, strong) UnitPriceInfo *price1;
@property (nonatomic, strong) UnitPriceInfo *price2;
@property (nonatomic, strong) UIBarButtonItem *historyBarItem;
@property (nonatomic, strong) UIBarButtonItem *composeBarItem;
@property (nonatomic, strong) UILabel *resultLB;
@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, strong) UINavigationController *modalNavigationController;
@property (nonatomic, strong) A3UnitDataManager *unitDataManager;
@property (nonatomic, strong) NSManagedObjectContext *privateContext;

@end

NSString *const A3UnitPriceCompareSliderCellID = @"A3UnitPriceCompareSliderCell";
NSString *const A3UnitPriceInfoCellID = @"A3UnitPriceInfoCell";

@implementation A3UnitPriceMainTableController {
	BOOL _barButtonEnabled;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	_barButtonEnabled = YES;

    self.navigationItem.title = NSLocalizedString(@"Unit Price", @"Unit Price");
    
    [self makeBackButtonEmptyArrow];
    [self leftBarButtonAppsButton];
    
    self.navigationItem.hidesBackButton = YES;
    
    self.composeBarItem.enabled = NO;
    self.navigationItem.rightBarButtonItems = @[self.historyBarItem, self.composeBarItem];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, (IS_IPAD)?28:15, 0, 0);
    self.tableView.contentInset = UIEdgeInsetsMake(-1, 0, 36, 0);
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorColor = [self tableViewSeparatorColor];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 1, self.view.bounds.size.width, IS_RETINA ? 0.5:1.0)];
    lineView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    lineView.backgroundColor = [UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0];
    [self.tableView addSubview:lineView];
    
    self.currencyFormatter.maximumFractionDigits = 2;
    [self updateUnitPrices:NO];

	[self registerContentSizeCategoryDidChangeNotification];
    
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currencyCodeChanged:) name:A3NotificationUnitPriceCurrencyCodeChanged object:nil];
	if (IS_IPAD) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainMenuDidHide) name:A3NotificationMainMenuDidHide object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rightSideViewWillHide) name:A3NotificationRightSideViewWillDismiss object:nil];
	}
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cloudStoreDidImport) name:A3NotificationCloudKeyValueStoreDidImport object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cloudStoreDidImport) name:A3NotificationCloudCoreDataStoreDidImport object:nil];
}

- (void)cloudStoreDidImport {
	_price1 = nil;
	_price2 = nil;

	[self.tableView reloadData];
	[self enableControls:_barButtonEnabled];
}

- (void)removeObserver {
	[self removeContentSizeCategoryDidChangeNotification];

	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationCloudKeyValueStoreDidImport object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationCloudCoreDataStoreDidImport object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationUnitPriceCurrencyCodeChanged object:nil];
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

- (void)dealloc {
	[self removeObserver];
}

- (void)cleanUp {
	[self removeObserver];
}

- (void)contentSizeDidChange:(NSNotification *) notification
{
    [self.tableView reloadData];
}

- (void)currencyCodeChanged:(NSNotification *)notification {
	NSString *currencyCode = [[NSUserDefaults standardUserDefaults] objectForKey:A3UnitPriceUserDefaultsCurrencyCode];
	[self.currencyFormatter setCurrencyCode:currencyCode];
    [self.currencyFormatter setMaximumFractionDigits:2];
	[self.tableView reloadData];
}

- (void)rightSideViewWillHide
{
    [self enableControls:YES];
}

- (void)mainMenuDidHide {
	[self enableControls:YES];
}

- (void)enableControls:(BOOL)enable
{
	_barButtonEnabled = enable;
    if (enable) {
		self.composeBarItem.enabled = price1UnitPrice > 0 && price2UnitPrice > 0;
		self.historyBarItem.enabled = [UnitPriceHistory MR_countOfEntities] > 0;
    }
    else {
		self.composeBarItem.enabled = NO;
		self.historyBarItem.enabled = NO;
    }
    
	if (!IS_IPAD) return;
	self.navigationItem.leftBarButtonItem.enabled = enable;
}

- (void)appsButtonAction:(UIBarButtonItem *)barButtonItem {
	[super appsButtonAction:barButtonItem];

	if (IS_IPAD) {
		[self enableControls:!self.A3RootViewController.showLeftView];
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	if (![self isMovingToParentViewController]) {
		_price1 = nil;
		_price2 = nil;
		[self.tableView reloadData];
	}
    
	[self enableControls:YES];
}

- (UIView *)footerView {
	if (!_footerView) {
		_footerView = [UIView new];
		CGRect screenBounds = [A3UIDevice screenBoundsAdjustedWithOrientation];
		screenBounds.size.height = 30.0;
		_footerView.frame = screenBounds;
		[_footerView addSubview:[self resultLB]];

		[_resultLB makeConstraints:^(MASConstraintMaker *make) {
			make.left.equalTo(_footerView.left).with.offset(10);
			make.right.equalTo(_footerView.right).with.offset(-10);
			make.top.equalTo(_footerView.top).with.offset(8);
		}];
	}
	return _footerView;
}

- (UILabel *)resultLB
{
    if (!_resultLB) {
        _resultLB = [UILabel new];
        
        _resultLB.font = [UIFont systemFontOfSize:14.0];
        _resultLB.textColor = [UIColor colorWithRed:109.0/255.0 green:109.0/255.0 blue:114.0/255.0 alpha:1.0];
        _resultLB.textAlignment = NSTextAlignmentCenter;
		_resultLB.numberOfLines = 0;
        _resultLB.text = @"";
    }
    
    return _resultLB;
}

- (UIBarButtonItem *)composeBarItem
{
    if (!_composeBarItem) {
        _composeBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(composeButtonAction:)];
    }
    
    return _composeBarItem;
}

- (UIBarButtonItem *)historyBarItem
{
    if (!_historyBarItem) {
        _historyBarItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"history"] style:UIBarButtonItemStylePlain target:self action:@selector(historyButtonAction:)];
    }
    
    return _historyBarItem;
}

- (NSManagedObjectContext *)privateContext {
	if (!_privateContext) {
		_privateContext = [NSManagedObjectContext MR_newContext];
	}
	return _privateContext;
}

- (UnitPriceInfo *)price1
{
    if (!_price1) {
		_price1 = [UnitPriceInfo MR_createEntityInContext:_privateContext];
		_price1.uniqueID = [[NSUUID UUID] UUIDString];
		_price1.priceName = @"A";
		NSDictionary *store = [[NSUserDefaults standardUserDefaults] objectForKey:A3UnitPriceUserDefaultsPriceA];
		if (store) {
			[_price1 copyValueFrom:store];
		} else {
			[_price1 initValues];
		}
	}
    return _price1;
}

- (UnitPriceInfo *)price2
{
	if (!_price2) {
		_price2 = [UnitPriceInfo MR_createEntity];
		_price2.uniqueID = [[NSUUID UUID] UUIDString];
		_price2.priceName = @"B";
		NSDictionary *store = [[NSUserDefaults standardUserDefaults] objectForKey:A3UnitPriceUserDefaultsPriceB];
		if (store) {
			[_price2 copyValueFrom:store];
		} else {
			[_price2 initValues];
		}
	}
    return _price2;
}

- (A3UnitDataManager *)unitDataManager {
	if (!_unitDataManager) {
		_unitDataManager = [A3UnitDataManager new];
	}
	return _unitDataManager;
}

- (void)composeButtonAction:(UIButton *)button {
	// history 입력 및 데이타 초기화

	if (price1UnitPrice > 0 && price2UnitPrice > 0) {
		[self putHistory];
	}
	[self clearCalculation];
}

- (void)historyButtonAction:(UIButton *)button {
	A3UnitPriceHistoryViewController *viewController = [[A3UnitPriceHistoryViewController alloc] initWithNibName:nil bundle:nil];
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

#pragma mark - UnitHistoryViewController delegate

- (void)didHistoryDeletedHistoryViewController:(UIViewController *)viewController
{
    NSArray *histories = [UnitPriceHistory MR_findAll];
    if (histories.count>0) {
        self.historyBarItem.enabled = YES;
    }
    else {
        self.historyBarItem.enabled = NO;
    }
}

- (void)historyViewController:(UIViewController *)viewController selectHistory:(UnitPriceHistory *)history
{
    if (history) {
        FNLOG(@"Selected History\n%@", [history description]);
		for (UnitPriceInfo *item in [history unitPrices]) {
			if ([item.priceName isEqualToString:@"A"]) {
				_price1.price = item.price;
				_price1.unitCategoryID = item.unitCategoryID;
				_price1.unitID = item.unitID;
				_price1.size = item.size;
				_price1.quantity = item.quantity;
				_price1.discountPercent = item.discountPercent;
				_price1.discountPrice = item.discountPrice;
				_price1.note = item.note;
			} else {
				_price2.price = item.price;
				_price2.unitCategoryID = item.unitCategoryID;
				_price2.unitID = item.unitID;
				_price2.size = item.size;
				_price2.quantity = item.quantity;
				_price2.discountPercent = item.discountPercent;
				_price2.discountPrice = item.discountPrice;
				_price2.note = item.note;
			}
		}

		[self saveDataToUserDefaults];
        [self updateUnitPrices:NO];

	}
}

#pragma mark - A3UnitPriceInfoModifyDelegate

- (void)unitPriceInfoChanged:(UnitPriceInfo *)price
{
    // unit 보정 과정
    UnitPriceInfo *priceSelf;
    UnitPriceInfo *priceOther;
    
    if (price == _price1) {
        priceSelf = _price1;
        priceOther = _price2;
    } else {
        priceSelf = _price2;
        priceOther = _price1;
    }
    
    if (validUnit(priceSelf.unitID) && !validUnit(priceOther.unitID)) {
		priceOther.unitCategoryID = priceSelf.unitCategoryID;
        priceOther.unitID = priceSelf.unitID;
    }
    else if (validUnit(priceSelf.unitID) && validUnit(priceOther.unitID) && ![priceSelf.unitCategoryID isEqualToNumber:priceOther.unitCategoryID]) {
        // 얼럿창
		priceOther.unitCategoryID = priceSelf.unitCategoryID;
        priceOther.unitID = priceSelf.unitID;
    }

	[self saveDataToUserDefaults];
    
    [self updateUnitPrices:YES];

}

- (void)saveDataToUserDefaults {
	[self.unitDataManager saveUnitPriceData:[_price1 dictionaryRepresentation] forKey:A3UnitPriceUserDefaultsPriceA];
	[self.unitDataManager saveUnitPriceData:[_price2 dictionaryRepresentation] forKey:A3UnitPriceUserDefaultsPriceB];
}

#pragma mark - UnitPriceInputDelegate

- (void)inputViewTapped:(A3UnitPriceInputView *)inputView
{
    if (inputView.tag == 1) {

		UIStoryboard *storyboard = [UIStoryboard storyboardWithName:IS_IPAD ? @"UnitPriceStoryboard_iPad" : @"UnitPriceStoryboard" bundle:nil];
        A3UnitPriceDetailTableController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"A3UnitPriceDetailTableController"];
        viewController.delegate = self;
        viewController.isPriceA = YES;
        viewController.price = self.price1;
        [self.navigationController pushViewController:viewController animated:YES];
    }
    else if (inputView.tag == 2) {

		UIStoryboard *storyboard = [UIStoryboard storyboardWithName:IS_IPAD ? @"UnitPriceStoryboard_iPad" : @"UnitPriceStoryboard" bundle:nil];
        A3UnitPriceDetailTableController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"A3UnitPriceDetailTableController"];
        viewController.delegate = self;
        viewController.isPriceA = NO;
        viewController.price = self.price2;
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

#pragma mark - Calculation

- (void)updateUnitPrices:(BOOL) historyUpdate
{
    // init price calculation result
    price1UnitPrice = 0.0;
    price2UnitPrice = 0.0;
    
    // 다시 계산. price 결과 들이 업데이트된다.
    [self.tableView reloadData];
    
    // 새로 계산이 되었으면 ...
    if (price1UnitPrice>0 && price2UnitPrice>0) {
        
        // put History -> compose버튼을 누르는 시점으로 바꾸면서, 히스토리에 저장하지 않는다.
        if (historyUpdate) {
//            [self putHistory];
        }
    }
}

- (void)putHistory
{
    FNLOG(@"+ putHistory !!");
    
    UnitPriceHistory *history = [UnitPriceHistory MR_createEntity];
	history.uniqueID = [[NSUUID UUID] UUIDString];
    NSDate *keyDate = [NSDate date];
    history.updateDate = keyDate;
    
    UnitPriceInfo *priceAItem = [UnitPriceInfo MR_createEntity];
	priceAItem.uniqueID = [[NSUUID UUID] UUIDString];
	priceAItem.updateDate = [NSDate date];
	priceAItem.priceName = @"A";
    priceAItem.price = [self.price1 price];
	priceAItem.unitCategoryID = _price1.unitCategoryID;
    priceAItem.unitID = _price1.unitID;
    priceAItem.size = _price1.size;
    priceAItem.quantity = _price1.quantity;
    priceAItem.discountPercent = _price1.discountPercent;
    priceAItem.discountPrice = _price1.discountPrice;
    priceAItem.note = _price1.note;
	priceAItem.historyID = history.uniqueID;
    
    UnitPriceInfo *priceBItem = [UnitPriceInfo MR_createEntity];
	priceBItem.uniqueID = [[NSUUID UUID] UUIDString];
	priceBItem.updateDate = [NSDate date];
	priceBItem.priceName = @"B";
    priceBItem.price = [self.price2 price];
	priceBItem.unitCategoryID = _price2.unitCategoryID;
    priceBItem.unitID = _price2.unitID;
    priceBItem.size = _price2.size;
    priceBItem.quantity = _price2.quantity;
    priceBItem.discountPercent = _price2.discountPercent;
    priceBItem.discountPrice = _price2.discountPrice;
    priceBItem.note = _price2.note;
	priceBItem.historyID = history.uniqueID;
    
	[[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];

    self.historyBarItem.enabled = YES;
}

- (void)clearCalculation
{
    FNLOG(@"clearCalculation");
    
    price1UnitPrice = 0;
    price2UnitPrice = 0;

	[_price1 initValues];
	[_price2 initValues];

	[self saveDataToUserDefaults];

    [self.tableView reloadData];
}

#pragma mark - Cell Configure

- (NSString *)shortUnitNameForPriceInfo:(UnitPriceInfo *)priceInfo {
	if (!validUnit(priceInfo.unitID)  || !validUnit(priceInfo.unitCategoryID)) return @"";
	return NSLocalizedStringFromTable([self.unitDataManager unitNameForUnitID:[priceInfo.unitID unsignedIntegerValue] categoryID:[priceInfo.unitCategoryID unsignedIntegerValue]],
	@"unitShort", nil);
}

- (NSString *)unitNameForPriceInfo:(UnitPriceInfo *)priceInfo {
	if (!validUnit(priceInfo.unitID) || !validUnit(priceInfo.unitCategoryID)) return @"";
	return NSLocalizedStringFromTable([self.unitDataManager unitNameForUnitID:[priceInfo.unitID unsignedIntegerValue] categoryID:[priceInfo.unitCategoryID unsignedIntegerValue]],
	@"unit", nil);
}

- (void)configureCompareCell:(A3UnitPriceCompareSliderCell *)cell
{
    [cell.upSliderView labelFontSetting];
//    cell.upSliderView.displayColor = [UIColor colorWithRed:255.0/255.0 green:45.0/255.0 blue:85.0/255.0 alpha:1.0];
    cell.upSliderView.markLabel.text = @"A";
    cell.upSliderView.layoutType = Slider_UpperOfTwo;
    cell.upSliderView.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:248/255.0 alpha:1.0];
    cell.upSliderView.priceNumLabel.hidden = YES;
    cell.upSliderView.priceLabel.hidden = YES;
    [cell.downSliderView labelFontSetting];
//    cell.downSliderView.displayColor = [UIColor colorWithRed:76.0/255.0 green:217.0/255.0 blue:100.0/255.0 alpha:1.0];
    cell.downSliderView.markLabel.text = @"B";
    cell.downSliderView.layoutType = Slider_LowerOfTwo;
    cell.downSliderView.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:248/255.0 alpha:1.0];
    cell.downSliderView.priceNumLabel.hidden = YES;
    cell.downSliderView.priceLabel.hidden = YES;
    
    cell.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:248/255.0 alpha:1.0];
 
    double unitPrice1 = 0;
    NSString *unitPriceTxt1 = @"";
    NSString *unitShortName1;
    NSString *priceTxt1;
    
    priceTxt1 = [self.currencyFormatter stringFromNumber:@(self.price1.price.doubleValue)];
    unitShortName1 = validUnit(self.price1.unitID) ? [self shortUnitNameForPriceInfo:self.price1] : NSLocalizedString(@"None", @"None");

    double priceValue1 = self.price1.price.doubleValue;
    NSInteger sizeValue1 = (self.price1.size.integerValue <= 0) ? 1 : self.price1.size.integerValue;
    NSInteger quantityValue1 = self.price1.quantity.integerValue;
    
    // 할인값
    double discountValue1 = 0;
    if (self.price1.discountPrice.doubleValue > 0) {
        discountValue1 = self.price1.discountPrice.doubleValue;
        discountValue1 = MIN(discountValue1, priceValue1);
    }
    else if (self.price1.discountPercent.doubleValue > 0) {
        discountValue1 = priceValue1 * self.price1.discountPercent.doubleValue;
    }
    
    if ((priceValue1>0) && (sizeValue1>0) && (quantityValue1>0)) {
        unitPrice1 = (priceValue1 - discountValue1) / (sizeValue1 * quantityValue1);
        
        if (unitPrice1 > 0) {
            if (validUnit(self.price1.unitID)) {
                unitPriceTxt1 = [NSString stringWithFormat:@"%@/%@", [self.currencyFormatter stringFromNumber:@(unitPrice1)], unitShortName1];
            }
            else {
                unitPriceTxt1 = [self.currencyFormatter stringFromNumber:@(unitPrice1)];
            }
            
            cell.upSliderView.progressBarHidden = NO;
        }
        else if (unitPrice1 == 0) {
            if (validUnit(self.price1.unitID)) {
                unitPriceTxt1 = [NSString stringWithFormat:@"%@/%@", [self.currencyFormatter stringFromNumber:@(unitPrice1)], unitShortName1];
            }
            else {
                unitPriceTxt1 = [self.currencyFormatter stringFromNumber:@(unitPrice1)];
                
            }
            
            cell.upSliderView.progressBarHidden = YES;
        }
        else {
            if (validUnit(self.price1.unitID)) {
                unitPriceTxt1 = [NSString stringWithFormat:@"-%@/%@", [self.currencyFormatter stringFromNumber:@(unitPrice1*-1)], unitShortName1];
            }
            else {
                unitPriceTxt1 = [NSString stringWithFormat:@"-%@", [self.currencyFormatter stringFromNumber:@(unitPrice1*-1)]];
                
            }
            
            cell.upSliderView.progressBarHidden = YES;
        }
    }
    else {
        cell.upSliderView.progressBarHidden = YES;
    }
    
    // slider1
    cell.upSliderView.unitPriceNumLabel.text = unitPriceTxt1;
    cell.upSliderView.priceNumLabel.text = priceTxt1;
    cell.upSliderView.unitPriceValue = unitPrice1;
    cell.upSliderView.priceValue = self.price1.price.floatValue;
    
    price1UnitPrice = unitPrice1;
    
    double unitPrice2 = 0;
    NSString *unitPriceTxt2 = @"";
    NSString *unitShortName2;
    NSString *priceTxt2;

    priceTxt2 = [self.currencyFormatter stringFromNumber:@(self.price2.price.doubleValue)];
    unitShortName2 = validUnit(self.price2.unitID) ? [self shortUnitNameForPriceInfo:self.price2] : NSLocalizedString(@"None", @"None");

    float priceValue2 = self.price2.price.floatValue;
    NSInteger sizeValue2 = (self.price2.size.integerValue <= 0) ? 1:self.price2.size.integerValue;
    NSInteger quantityValue2 = self.price2.quantity.integerValue;
    
    // 할인값
    NSString *discountText2 = [self.currencyFormatter stringFromNumber:@(0)];
    float discountValue2 = 0;
    if (self.price2.discountPrice.floatValue > 0) {
        discountText2 = [self.currencyFormatter stringFromNumber:@(self.price2.discountPrice.doubleValue)];
        discountValue2 = self.price2.discountPrice.floatValue;
        discountValue2 = MIN(discountValue2, priceValue2);
    }
    else if (self.price2.discountPercent.floatValue > 0) {
        discountText2 = [self.percentFormatter stringFromNumber:@(self.price2.discountPercent.doubleValue)];
        discountValue2 = priceValue2 * self.price2.discountPercent.floatValue;
    }
    
    if ((priceValue2>0) && (sizeValue2>0) && (quantityValue2>0)) {
        
        float price1CnvRate, price2CnvRate;
        
        if (validUnit(_price1.unitID) && validUnit(_price2.unitID)) {
            price1CnvRate = (float) conversionTable[[_price1.unitCategoryID unsignedIntegerValue]][[_price1.unitID unsignedIntegerValue]];
            price2CnvRate = (float) conversionTable[[_price2.unitCategoryID unsignedIntegerValue]][[_price2.unitID unsignedIntegerValue]];
        }
        else if (validUnit(_price1.unitID) && !validUnit(_price2.unitID)) {
            price1CnvRate = (float) conversionTable[[_price1.unitCategoryID unsignedIntegerValue]][[_price1.unitID unsignedIntegerValue]];
            price2CnvRate = (float) conversionTable[[_price1.unitCategoryID unsignedIntegerValue]][[_price1.unitID unsignedIntegerValue]];
        }
        else if (!validUnit(_price1.unitID) && validUnit(_price2.unitID)) {
            price1CnvRate = (float) conversionTable[[_price2.unitCategoryID unsignedIntegerValue]][[_price2.unitID unsignedIntegerValue]];
            price2CnvRate = (float) conversionTable[[_price2.unitCategoryID unsignedIntegerValue]][[_price2.unitID unsignedIntegerValue]];
        }
        else {
            price1CnvRate = 1;
            price2CnvRate = 1;
        }
        
        float rate = price2CnvRate / price1CnvRate;
        
        unitPrice2 = (priceValue2 - discountValue2) / (sizeValue2 * quantityValue2 * rate);
        
        if (unitPrice2 > 0) {
            if (validUnit(self.price2.unitID)) {
                if (self.price1.unitID != self.price2.unitID) {
                    float normalPrice2 = (priceValue2 - discountValue2) / (sizeValue2 * quantityValue2);
                    
                    if (IS_IPAD) {
                        unitPriceTxt2 = [NSString stringWithFormat:@"%@/%@ (%@/%@)", [self.currencyFormatter stringFromNumber:@(unitPrice2)], unitShortName1, [self.currencyFormatter stringFromNumber:@(normalPrice2)], unitShortName2];
                    }
                    else {
                        unitPriceTxt2 = [NSString stringWithFormat:@"%@/%@", [self.currencyFormatter stringFromNumber:@(unitPrice2)], unitShortName1];
                    }
                    
                }
                else {
                    unitPriceTxt2 = [NSString stringWithFormat:@"%@/%@", [self.currencyFormatter stringFromNumber:@(unitPrice2)], unitShortName2];
                }
            }
            else {
                unitPriceTxt2 = [self.currencyFormatter stringFromNumber:@(unitPrice2)];
            }
            
            cell.downSliderView.progressBarHidden = NO;
        }
        else if (unitPrice2 == 0) {
            if (validUnit(self.price2.unitID)) {
                unitPriceTxt2 = [NSString stringWithFormat:@"%@/%@", [self.currencyFormatter stringFromNumber:@(unitPrice2)], unitShortName2];
            }
            else {
                unitPriceTxt2 = [self.currencyFormatter stringFromNumber:@(unitPrice2)];
                
            }
            
            cell.downSliderView.progressBarHidden = YES;
        }
        else {
            if (validUnit(self.price2.unitID)) {
                unitPriceTxt2 = [NSString stringWithFormat:@"-%@/%@", [self.currencyFormatter stringFromNumber:@(unitPrice2*-1)], unitShortName2];
            }
            else {
                unitPriceTxt2 = [NSString stringWithFormat:@"-%@", [self.currencyFormatter stringFromNumber:@(unitPrice2*-1)]];
            }
            
            cell.downSliderView.progressBarHidden = YES;
        }
    }
    else {
        cell.downSliderView.progressBarHidden = YES;
    }
    
    // slider2
    cell.downSliderView.unitPriceNumLabel.text = unitPriceTxt2;
    cell.downSliderView.priceNumLabel.text = priceTxt2;
    cell.downSliderView.unitPriceValue = unitPrice2;
    cell.downSliderView.priceValue = self.price2.price.floatValue;
    
    price2UnitPrice = unitPrice2;
    
    unitPrice1 = [[self.decimalFormatter numberFromString:[self.decimalFormatter stringFromNumber:@(unitPrice1)]] doubleValue];
    unitPrice2 = [[self.decimalFormatter numberFromString:[self.decimalFormatter stringFromNumber:@(unitPrice2)]] doubleValue];
    
    double maxPrice = MAX(unitPrice1, unitPrice2);
    double minPrice = MIN(unitPrice1, unitPrice2);
    cell.upSliderView.maxValue = maxPrice;
    cell.upSliderView.minValue = minPrice;
    cell.downSliderView.maxValue = maxPrice;
    cell.downSliderView.minValue = minPrice;
    [cell.upSliderView setLayoutWithAnimated];
    [cell.downSliderView setLayoutWithAnimated];
    
    if (IS_IPAD) {
        CGRect rect = cell.upSliderView.frame;
        rect.origin.y = 27;
        cell.upSliderView.frame = rect;
        
        rect = cell.downSliderView.frame;
        rect.origin.y = 122;
        cell.downSliderView.frame = rect;

        [cell.upSliderView.unitPriceLabel adjustBaselineForContainView:cell.contentView fromBottomDistance:172];
        [cell.upSliderView.priceLabel adjustBaselineForContainView:cell.contentView fromBottomDistance:172];
        [cell.upSliderView.unitPriceNumLabel adjustBaselineForContainView:cell.contentView fromBottomDistance:115];
        [cell.upSliderView.priceNumLabel adjustBaselineForContainView:cell.contentView fromBottomDistance:115];
        [cell.downSliderView.unitPriceNumLabel adjustBaselineForContainView:cell.contentView fromBottomDistance:28];
        [cell.downSliderView.priceNumLabel adjustBaselineForContainView:cell.contentView fromBottomDistance:28];
    }
    else {
        CGRect rect = cell.downSliderView.frame;
        rect.origin.y = 82;
        cell.downSliderView.frame = rect;
        
        [cell.upSliderView.unitPriceLabel adjustBaselineForContainView:cell.contentView fromBottomDistance:135];
        [cell.upSliderView.priceLabel adjustBaselineForContainView:cell.contentView fromBottomDistance:135];
        [cell.upSliderView.unitPriceNumLabel adjustBaselineForContainView:cell.contentView fromBottomDistance:90];
        [cell.upSliderView.priceNumLabel adjustBaselineForContainView:cell.contentView fromBottomDistance:90];
        [cell.downSliderView.unitPriceNumLabel adjustBaselineForContainView:cell.contentView fromBottomDistance:23];
        [cell.downSliderView.priceNumLabel adjustBaselineForContainView:cell.contentView fromBottomDistance:23];
    }
    
    if (unitPrice1 > unitPrice2) {
        cell.upSliderView.displayColor = [UIColor colorWithRed:255.0/255.0 green:45.0/255.0 blue:85.0/255.0 alpha:1.0];
        cell.downSliderView.displayColor = [UIColor colorWithRed:76.0/255.0 green:217.0/255.0 blue:100.0/255.0 alpha:1.0];
    }
    else if (unitPrice1 == unitPrice2) {
        cell.upSliderView.displayColor = [UIColor colorWithRed:255.0/255.0 green:45.0/255.0 blue:85.0/255.0 alpha:1.0];
        cell.downSliderView.displayColor = [UIColor colorWithRed:255.0/255.0 green:45.0/255.0 blue:85.0/255.0 alpha:1.0];
    }
    else {
        cell.upSliderView.displayColor = [UIColor colorWithRed:76.0/255.0 green:217.0/255.0 blue:100.0/255.0 alpha:1.0];
        cell.downSliderView.displayColor = [UIColor colorWithRed:255.0/255.0 green:45.0/255.0 blue:85.0/255.0 alpha:1.0];
    }

    if (price1UnitPrice>0 && price2UnitPrice>0) {
        
        if (price1UnitPrice < price2UnitPrice) {
            self.resultLB.text = [NSString stringWithFormat:NSLocalizedString(@"The best unit price is A at %@", @"The best unit price is A at %@"), unitPriceTxt1];
        }
        else if (price1UnitPrice > price2UnitPrice) {
            self.resultLB.text = [NSString stringWithFormat:NSLocalizedString(@"The best unit price is B at %@", @"The best unit price is B at %@"), unitPriceTxt2];
        }
        else {
            self.resultLB.text = [NSString stringWithFormat:NSLocalizedString(@"The unit price is the same at %@", @"The unit price is same at %@"), unitPriceTxt1];
        }
    }
    else {
        self.resultLB.text = @"";
    }

	[self enableControls:YES];
}

- (void)configureInfo1Cell:(A3UnitPriceInfoCell *)cell
{
    cell.inputView.delegate = self;
    cell.inputView.tag = 1;
    cell.inputView.markLabel.text = @"A";
    [cell.inputView loadFontSettings];
    
    NSString *unitPriceTxt = [self.price1 unitPriceStringWithFormatter:self.currencyFormatter showUnit:IS_IPAD ];
    NSString *unitShortName = @"";
    NSString *unitName = @"";
    NSString *priceTxt = @"";
    NSString *sizeTxt = @"";

	NSNumberFormatter *decimalFormatter = [NSNumberFormatter new];
	[decimalFormatter setNumberStyle:NSNumberFormatterDecimalStyle];

	UnitPriceInfo *priceInfo = self.price1;
    
    priceTxt = [self.currencyFormatter stringFromNumber:@(priceInfo.price.doubleValue)];
	sizeTxt = priceInfo.size.doubleValue != 0.0 ? [decimalFormatter stringFromNumber:priceInfo.size] : @"-";

	unitShortName = validUnit(priceInfo.unitID) ? [self shortUnitNameForPriceInfo:priceInfo] : NSLocalizedString(@"None", @"None");
	unitName = validUnit(priceInfo.unitID) ? [self unitNameForPriceInfo:priceInfo] : NSLocalizedString(@"None", @"None");

    // 할인값
    NSString *discountText = [self.currencyFormatter stringFromNumber:@(0)];
    if (priceInfo.discountPrice.doubleValue > 0) {
        discountText = [self.currencyFormatter stringFromNumber:@(priceInfo.discountPrice.doubleValue)];
    }
    else if (priceInfo.discountPercent.doubleValue > 0) {
        discountText = [self.percentFormatter stringFromNumber:@(priceInfo.discountPercent.doubleValue)];
    }

    // input1
    cell.inputView.priceLabel.text = priceTxt;
    cell.inputView.unitLabel.text = IS_IPHONE ? unitShortName : unitName;
    cell.inputView.sizeLabel.text = sizeTxt;
    cell.inputView.quantityLabel.text = priceInfo.quantity ? [decimalFormatter stringFromNumber:priceInfo.quantity]:[decimalFormatter stringFromNumber:@0];
    cell.inputView.discountLabel.text = discountText;
    [cell.inputView.unitPriceBtn setTitle:unitPriceTxt forState:UIControlStateNormal];
}

- (void)configureInfo2Cell:(A3UnitPriceInfoCell *)cell
{
    cell.inputView.delegate = self;
    cell.inputView.tag = 2;
    cell.inputView.markLabel.text = @"B";
    [cell.inputView loadFontSettings];
    
    NSString *unitPriceTxt = [self.price2 unitPrice2StringWithPrice1:self.price1 formatter:self.currencyFormatter showUnit:IS_IPAD ];
    NSString *unitShortName;
    NSString *unitName;
    NSString *priceTxt;
    NSString *sizeTxt;

	NSNumberFormatter *decimalFormatter = [NSNumberFormatter new];
	[decimalFormatter setNumberStyle:NSNumberFormatterDecimalStyle];

    UnitPriceInfo *priceInfo = self.price2;
    
    priceTxt = [self.currencyFormatter stringFromNumber:@(priceInfo.price.doubleValue)];
    unitShortName = validUnit(priceInfo.unitID) ? [self shortUnitNameForPriceInfo:priceInfo] : NSLocalizedString(@"None", @"None");
    unitName = validUnit(priceInfo.unitID) ? [self unitNameForPriceInfo:priceInfo] : NSLocalizedString(@"None", @"None");
    sizeTxt = priceInfo.size.doubleValue != 0.0 ? [decimalFormatter stringFromNumber:priceInfo.size] : @"-";
    
    // 할인값
    NSString *discountText = [self.currencyFormatter stringFromNumber:@(0)];
    if (priceInfo.discountPrice.floatValue > 0) {
        discountText = [self.currencyFormatter stringFromNumber:@(priceInfo.discountPrice.doubleValue)];
    }
    else if (priceInfo.discountPercent.floatValue > 0) {
        discountText = [self.percentFormatter stringFromNumber:@(priceInfo.discountPercent.doubleValue)];
    }

    // input2
    cell.inputView.priceLabel.text = priceTxt;
    cell.inputView.unitLabel.text = IS_IPHONE ? unitShortName : unitName;
    cell.inputView.sizeLabel.text = sizeTxt;
    cell.inputView.quantityLabel.text = priceInfo.quantity ? [decimalFormatter stringFromNumber:priceInfo.quantity] : [decimalFormatter stringFromNumber:@0];
    cell.inputView.discountLabel.text = discountText;
    [cell.inputView.unitPriceBtn setTitle:unitPriceTxt forState:UIControlStateNormal];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell=nil;

	if (indexPath.section == 0) {
		A3UnitPriceCompareSliderCell *compareCell = [tableView dequeueReusableCellWithIdentifier:A3UnitPriceCompareSliderCellID forIndexPath:indexPath];
		[self configureCompareCell:compareCell];

		cell = compareCell;
	}
	else {

		if (indexPath.section == 1) {
			A3UnitPriceInfoCell *infoCell = [tableView dequeueReusableCellWithIdentifier:A3UnitPriceInfoCellID forIndexPath:indexPath];
			[self configureInfo1Cell:infoCell];

			cell = infoCell;
		}
		else {
			A3UnitPriceInfoCell *infoCell = [tableView dequeueReusableCellWithIdentifier:A3UnitPriceInfoCellID forIndexPath:indexPath];
			[self configureInfo2Cell:infoCell];

			cell = infoCell;
		}
	}

	cell.selectionStyle = UITableViewCellSelectionStyleNone;

	return cell;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        return self.footerView;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return IS_IPAD ? 226 : 166;
    }
    
    if (IS_RETINA) {
        return IS_IPAD ? 192.5 : 178.5;
    }
    else {
        return IS_IPAD ? 193 : 179;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    else if (section == 1){
        return 24.0;
    }
    else {
        return 34.0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        return 31.0;
    }
    return 1;
}

- (NSString *)defaultCurrencyCode {
	NSString *currencyCode = [[NSUserDefaults standardUserDefaults] objectForKey:A3UnitPriceUserDefaultsCurrencyCode];
	if (!currencyCode) {
		currencyCode = [[NSLocale currentLocale] objectForKey:NSLocaleCurrencyCode];
	}
	return currencyCode;
}

@end
