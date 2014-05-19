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
#import "UnitItem.h"
#import "UnitPriceInfo.h"
#import "UnitPriceHistory.h"
#import "UnitPriceHistoryItem.h"
#import "A3UnitPriceCompareSliderCell.h"
#import "A3UnitPriceInfoCell.h"

#import "A3AppDelegate.h"
#import "UIViewController+A3AppCategory.h"
#import "UIViewController+A3Addition.h"
#import "UILabel+BaseAlignment.h"
#import "UIViewController+iPad_rightSideView.h"
#import "UIViewController+navigation.h"

NSString *const A3UnitPriceCurrencyCode = @"A3UnitPriceCurrencyCode";
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
@property (strong, nonatomic) UINavigationController *modalNavigationController;

@end

NSString *const A3UnitPriceCompareSliderCellID = @"A3UnitPriceCompareSliderCell";
NSString *const A3UnitPriceInfoCellID = @"A3UnitPriceInfoCell";

@implementation A3UnitPriceMainTableController

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

    self.navigationItem.title = @"Unit Price";
    
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
    
    [self updateUnitPrices:NO];

	[self registerContentSizeCategoryDidChangeNotification];
    
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currencyCodeChanged:) name:A3NotificationUnitPriceCurrencyCodeChanged object:nil];
	if (IS_IPAD) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainMenuDidHide) name:A3NotificationMainMenuDidHide object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rightSideViewWillHide) name:A3NotificationRightSideViewWillDismiss object:nil];
	}
}

- (void)removeObserver {
	[self removeContentSizeCategoryDidChangeNotification];

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
	NSString *currencyCode = [[NSUserDefaults standardUserDefaults] objectForKey:A3UnitPriceCurrencyCode];
	[self.currencyFormatter setCurrencyCode:currencyCode];
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

	[self enableControls:YES];
}

- (UILabel *)resultLB
{
    if (!_resultLB) {
        _resultLB = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 30)];
        
        _resultLB.font = [UIFont systemFontOfSize:14.0];
        _resultLB.textColor = [UIColor colorWithRed:109.0/255.0 green:109.0/255.0 blue:114.0/255.0 alpha:1.0];
        _resultLB.textAlignment = NSTextAlignmentCenter;
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

- (UnitPriceInfo *)price1
{
    if (!_price1) {
        _price1 = [UnitPriceInfo MR_findFirstByAttribute:@"priceName" withValue:@"A"];
        if (!_price1) {
            _price1 = [UnitPriceInfo MR_createEntity];
            _price1.priceName = @"A";
			[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
        }
    }
    return _price1;
}

- (UnitPriceInfo *)price2
{
    if (!_price2) {
        _price2 = [UnitPriceInfo MR_findFirstByAttribute:@"priceName" withValue:@"B"];
        if (!_price2) {
            _price2 = [UnitPriceInfo MR_createEntity];
            _price2.priceName = @"B";
			[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
        }
    }
    return _price2;
}

- (void)composeButtonAction:(UIButton *)button {
	// history 입력 및 데이타 초기화

	if (price1UnitPrice>0 && price2UnitPrice>0) {
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
    NSArray *historys = [UnitPriceHistory MR_findAll];
    if (historys.count>0) {
        self.historyBarItem.enabled = YES;
    }
    else {
        self.historyBarItem.enabled = NO;
    }
}

- (void)historyViewController:(UIViewController *)viewController selectHistory:(UnitPriceHistory *)history
{
    if (history) {
        NSLog(@"Selected History\n%@", [history description]);
		for (UnitPriceHistoryItem *item in history.unitPrices) {
			if ([item.orderInComparison isEqualToString:@"A"]) {
				_price1.price = item.price;
				_price1.unit = item.unit;
				_price1.size = item.size;
				_price1.quantity = item.quantity;
				_price1.discountPercent = item.discountPercent;
				_price1.discountPrice = item.discountPrice;
				_price1.note = item.note;
			} else {
				_price2.price = item.price;
				_price2.unit = item.unit;
				_price2.size = item.size;
				_price2.quantity = item.quantity;
				_price2.discountPercent = item.discountPercent;
				_price2.discountPrice = item.discountPrice;
				_price2.note = item.note;
			}
		}

		[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
        
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
    }
    else if (price == _price2) {
        priceSelf = _price2;
        priceOther = _price1;
    }
    
    if (priceSelf.unit && !priceOther.unit) {
        priceOther.unit = priceSelf.unit;
    }
    else if (priceSelf.unit && priceOther.unit && (priceSelf.unit.type != priceOther.unit.type)) {
        // 얼럿창
        priceOther.unit = priceSelf.unit;
    }

	[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
    
    [self updateUnitPrices:YES];

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
    NSDate *keyDate = [NSDate date];
    history.date = keyDate;
    
    UnitPriceHistoryItem *priceAItem = [UnitPriceHistoryItem MR_createEntity];
	priceAItem.orderInComparison = @"A";
    priceAItem.price = _price1.price;
    priceAItem.unit = _price1.unit;
    priceAItem.size = _price1.size;
    priceAItem.quantity = _price1.quantity;
    priceAItem.discountPercent = _price1.discountPercent;
    priceAItem.discountPrice = _price1.discountPrice;
    priceAItem.note = _price1.note;
    
    UnitPriceHistoryItem *priceBItem = [UnitPriceHistoryItem MR_createEntity];
	priceBItem.orderInComparison = @"B";
    priceBItem.price = _price2.price;
    priceBItem.unit = _price2.unit;
    priceBItem.size = _price2.size;
    priceBItem.quantity = _price2.quantity;
    priceBItem.discountPercent = _price2.discountPercent;
    priceBItem.discountPrice = _price2.discountPrice;
    priceBItem.note = _price2.note;
    
	history.unitPrices = [NSSet setWithArray:@[priceAItem, priceBItem]];

	[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
    
    self.historyBarItem.enabled = YES;
}

- (void)clearCalculation
{
    NSLog(@"clearCalculation");
    
    price1UnitPrice = 0;
    price2UnitPrice = 0;
    
    if (_price1) {
        [_price1 MR_deleteEntity];
    }
    if (_price2) {
        [_price2 MR_deleteEntity];
    }
    
    _price1 = nil;
    _price2 = nil;
    
    [self.tableView reloadData];
}

#pragma mark - Cell Configure

- (void)configureCompareCell:(A3UnitPriceCompareSliderCell *)cell
{
    [cell.upSliderView labelFontSetting];
    cell.upSliderView.displayColor = [UIColor colorWithRed:255.0/255.0 green:45.0/255.0 blue:85.0/255.0 alpha:1.0];
    cell.upSliderView.markLabel.text = @"A";
    cell.upSliderView.layoutType = Slider_UpperOfTwo;
    cell.upSliderView.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:248/255.0 alpha:1.0];
    cell.upSliderView.priceNumLabel.hidden = YES;
    
    [cell.downSliderView labelFontSetting];
    cell.downSliderView.displayColor = [UIColor colorWithRed:76.0/255.0 green:217.0/255.0 blue:100.0/255.0 alpha:1.0];
    cell.downSliderView.markLabel.text = @"B";
    cell.downSliderView.layoutType = Slider_LowerOfTwo;
    cell.downSliderView.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:248/255.0 alpha:1.0];
    cell.downSliderView.priceNumLabel.hidden = YES;
    
    cell.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:248/255.0 alpha:1.0];
 
    double unitPrice1 = 0;
    NSString *unitPriceTxt1 = @"";
    NSString *unitShortName1;
    NSString *priceTxt1;
    double maxPrice = MAX(self.price1.price.doubleValue, self.price2.price.doubleValue);
    
    priceTxt1 = [self.currencyFormatter stringFromNumber:@(self.price1.price.doubleValue)];
    unitShortName1 = self.price1.unit ? self.price1.unit.unitShortName : @"None";

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
            if (self.price1.unit) {
                unitPriceTxt1 = [NSString stringWithFormat:@"%@/%@", [self.currencyFormatter stringFromNumber:@(unitPrice1)], unitShortName1];
            }
            else {
                unitPriceTxt1 = [self.currencyFormatter stringFromNumber:@(unitPrice1)];
            }
            
            cell.upSliderView.progressBarHidden = NO;
            [cell.upSliderView setLayoutWithAnimated];
        }
        else if (unitPrice1 == 0) {
            if (self.price1.unit) {
                unitPriceTxt1 = [NSString stringWithFormat:@"%@/%@", [self.currencyFormatter stringFromNumber:@(unitPrice1)], unitShortName1];
            }
            else {
                unitPriceTxt1 = [self.currencyFormatter stringFromNumber:@(unitPrice1)];
                
            }
            
            cell.upSliderView.progressBarHidden = YES;
            [cell.upSliderView setLayoutWithNoAnimated];
        }
        else {
            if (self.price1.unit) {
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
    cell.upSliderView.maxValue = maxPrice;
    cell.upSliderView.unitPriceValue = unitPrice1;
    cell.upSliderView.priceValue = self.price1.price.floatValue;
    
    price1UnitPrice = unitPrice1;
    
    float unitPrice2 = 0;
    NSString *unitPriceTxt2 = @"";
    NSString *unitShortName2;
    NSString *priceTxt2;

    priceTxt2 = [self.currencyFormatter stringFromNumber:@(self.price2.price.doubleValue)];
    unitShortName2 = self.price2.unit ? self.price2.unit.unitShortName : @"None";

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
        
        if (_price1.unit && _price2.unit) {
            price1CnvRate = _price1.unit.conversionRate.floatValue;
            price2CnvRate = _price2.unit.conversionRate.floatValue;
        }
        else if (_price1.unit && !_price2.unit) {
            price1CnvRate = _price1.unit.conversionRate.floatValue;
            price2CnvRate = _price1.unit.conversionRate.floatValue;
        }
        else if (!_price1.unit && _price2.unit) {
            price1CnvRate = _price2.unit.conversionRate.floatValue;
            price2CnvRate = _price2.unit.conversionRate.floatValue;
        }
        else {
            price1CnvRate = 1;
            price2CnvRate = 1;
        }
        
        float rate = price2CnvRate / price1CnvRate;
        
        unitPrice2 = (priceValue2 - discountValue2) / (sizeValue2 * quantityValue2 * rate);
        
        if (unitPrice2 > 0) {
            if (self.price2.unit) {
                if (self.price1.unit != self.price2.unit) {
                    
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
            [cell.downSliderView setLayoutWithAnimated];
        }
        else if (unitPrice2 == 0) {
            if (self.price2.unit) {
                unitPriceTxt2 = [NSString stringWithFormat:@"%@/%@", [self.currencyFormatter stringFromNumber:@(unitPrice2)], unitShortName2];
            }
            else {
                unitPriceTxt2 = [self.currencyFormatter stringFromNumber:@(unitPrice2)];
                
            }
            
            cell.downSliderView.progressBarHidden = YES;
            [cell.downSliderView setLayoutWithNoAnimated];
            
        }
        else {
            if (self.price2.unit) {
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
    cell.downSliderView.maxValue = maxPrice;
    cell.downSliderView.unitPriceValue = unitPrice2;
    cell.downSliderView.priceValue = self.price2.price.floatValue;
    
    price2UnitPrice = unitPrice2;
    
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
    
    
    if (price1UnitPrice>0 && price2UnitPrice>0) {
        
        if (price1UnitPrice < price2UnitPrice) {
            self.resultLB.text = [NSString stringWithFormat:@"The best unit price is A at %@", unitPriceTxt1];
        }
        else if (price1UnitPrice > price2UnitPrice) {
            self.resultLB.text = [NSString stringWithFormat:@"The best unit price is B at %@", unitPriceTxt2];
        }
        else {
            self.resultLB.text = [NSString stringWithFormat:@"The unit price is same at %@", unitPriceTxt1];
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
    
    double unitPrice = 0;
    NSString *unitPriceTxt = @"";
    NSString *unitShortName = @"";
    NSString *unitName = @"";
    NSString *priceTxt = @"";
    NSString *sizeTxt = @"";

	NSNumberFormatter *decimalFormatter = [NSNumberFormatter new];
	[decimalFormatter setNumberStyle:NSNumberFormatterDecimalStyle];

	UnitPriceInfo *priceInfo = self.price1;
    
    priceTxt = [self.currencyFormatter stringFromNumber:@(priceInfo.price.doubleValue)];
    unitShortName = priceInfo.unit ? priceInfo.unit.unitShortName : @"None";
    unitName = priceInfo.unit ? priceInfo.unit.unitName : @"None";
    sizeTxt = priceInfo.size.doubleValue != 0.0 ? [decimalFormatter stringFromNumber:priceInfo.size] : @"-";
    
    double priceValue = priceInfo.price.doubleValue;
    NSInteger sizeValue = (priceInfo.size.integerValue <= 0) ? 1:priceInfo.size.integerValue;
    NSInteger quantityValue = priceInfo.quantity.integerValue;
    
    // 할인값
    NSString *discountText = [self.currencyFormatter stringFromNumber:@(0)];
    double discountValue = 0;
    if (priceInfo.discountPrice.doubleValue > 0) {
        discountText = [self.currencyFormatter stringFromNumber:@(priceInfo.discountPrice.doubleValue)];
        discountValue = priceInfo.discountPrice.doubleValue;
        discountValue = MIN(discountValue, priceValue);
    }
    else if (priceInfo.discountPercent.doubleValue > 0) {
        discountText = [self.percentFormatter stringFromNumber:@(priceInfo.discountPercent.doubleValue)];
        discountValue = priceValue * priceInfo.discountPercent.doubleValue;
    }
    
    if ((priceValue>0) && (sizeValue>0) && (quantityValue>0)) {
        unitPrice = (priceValue - discountValue) / (sizeValue * quantityValue);
        
        if (unitPrice > 0) {
            if (priceInfo.unit) {
                unitPriceTxt = [NSString stringWithFormat:@"%@/%@", [self.currencyFormatter stringFromNumber:@(unitPrice)], unitShortName];
            }
            else {
                unitPriceTxt = [self.currencyFormatter stringFromNumber:@(unitPrice)];
            }
        }
        else if (unitPrice == 0) {
            if (priceInfo.unit) {
                unitPriceTxt = [NSString stringWithFormat:@"%@/%@", [self.currencyFormatter stringFromNumber:@(unitPrice)], unitShortName];
            }
            else {
                unitPriceTxt = [self.currencyFormatter stringFromNumber:@(unitPrice)];
            }
            
        }
        else {
            if (priceInfo.unit) {
                unitPriceTxt = [NSString stringWithFormat:@"-%@/%@", [self.currencyFormatter stringFromNumber:@(unitPrice*-1)], unitShortName];
            }
            else {
                unitPriceTxt = [NSString stringWithFormat:@"-%@", [self.currencyFormatter stringFromNumber:@(unitPrice*-1)]];
            }
        }
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
    
    double unitPrice = 0;
    NSString *unitPriceTxt = @"";
    NSString *price1UnitShortName = @"";
    NSString *unitShortName = @"";
    NSString *unitName = @"";
    NSString *priceTxt = @"";
    NSString *sizeTxt = @"";

	NSNumberFormatter *decimalFormatter = [NSNumberFormatter new];
	[decimalFormatter setNumberStyle:NSNumberFormatterDecimalStyle];

    UnitPriceInfo *priceInfo = self.price2;
    
    priceTxt = [self.currencyFormatter stringFromNumber:@(priceInfo.price.doubleValue)];
    price1UnitShortName = _price1.unit ? _price1.unit.unitShortName : @"None";
    unitShortName = priceInfo.unit ? priceInfo.unit.unitShortName : @"None";
    unitName = priceInfo.unit ? priceInfo.unit.unitName : @"None";
    sizeTxt = priceInfo.size.doubleValue != 0.0 ? [decimalFormatter stringFromNumber:priceInfo.size] : @"-";
    
    double priceValue = priceInfo.price.floatValue;
    NSInteger sizeValue = (priceInfo.size.integerValue <= 0) ? 1:priceInfo.size.integerValue;
    NSInteger quantityValue = priceInfo.quantity.integerValue;
    
    // 할인값
    NSString *discountText = [self.currencyFormatter stringFromNumber:@(0)];
    double discountValue = 0;
    if (priceInfo.discountPrice.floatValue > 0) {
        discountText = [self.currencyFormatter stringFromNumber:@(priceInfo.discountPrice.doubleValue)];
        discountValue = priceInfo.discountPrice.floatValue;
        discountValue = MIN(discountValue, priceValue);
    }
    else if (priceInfo.discountPercent.floatValue > 0) {
        discountText = [self.percentFormatter stringFromNumber:@(priceInfo.discountPercent.doubleValue)];
        discountValue = priceValue * priceInfo.discountPercent.floatValue;
    }
    
    if ((priceValue>0) && (sizeValue>0) && (quantityValue>0)) {
        
        double price1CnvRate, price2CnvRate;
        
        if (_price1.unit && _price2.unit) {
            price1CnvRate = _price1.unit.conversionRate.floatValue;
            price2CnvRate = _price2.unit.conversionRate.floatValue;
        }
        else if (_price1.unit && !_price2.unit) {
            price1CnvRate = _price1.unit.conversionRate.floatValue;
            price2CnvRate = _price1.unit.conversionRate.floatValue;
        }
        else if (!_price1.unit && _price2.unit) {
            price1CnvRate = _price2.unit.conversionRate.floatValue;
            price2CnvRate = _price2.unit.conversionRate.floatValue;
        }
        else {
            price1CnvRate = 1;
            price2CnvRate = 1;
        }
        
        double rate = price2CnvRate / price1CnvRate;
        
        unitPrice = (priceValue - discountValue) / (sizeValue * quantityValue * rate);
        
        if (unitPrice > 0) {
            if (priceInfo.unit) {
                
                if (self.price1.unit != self.price2.unit) {
                    
                    float normalPrice = (priceValue - discountValue) / (sizeValue * quantityValue);
                    
                    if (IS_IPAD) {
                        unitPriceTxt = [NSString stringWithFormat:@"%@/%@ (%@/%@)", [self.currencyFormatter stringFromNumber:@(unitPrice)], price1UnitShortName, [self.currencyFormatter stringFromNumber:@(normalPrice)], unitShortName];
                    }
                    else {
                        unitPriceTxt = [NSString stringWithFormat:@"%@/%@", [self.currencyFormatter stringFromNumber:@(unitPrice)], price1UnitShortName];
                    }
                    
                }
                else {
                    unitPriceTxt = [NSString stringWithFormat:@"%@/%@", [self.currencyFormatter stringFromNumber:@(unitPrice)], unitShortName];
                }
                
            }
            else {
                unitPriceTxt = [self.currencyFormatter stringFromNumber:@(unitPrice)];
            }
        }
        else if (unitPrice == 0) {
            if (priceInfo.unit) {
                unitPriceTxt = [NSString stringWithFormat:@"%@/%@", [self.currencyFormatter stringFromNumber:@(unitPrice)], unitShortName];
            }
            else {
                unitPriceTxt = [self.currencyFormatter stringFromNumber:@(unitPrice)];
            }
            
        }
        else {
            if (priceInfo.unit) {
                unitPriceTxt = [NSString stringWithFormat:@"-%@/%@", [self.currencyFormatter stringFromNumber:@(unitPrice*-1)], unitShortName];
            }
            else {
                unitPriceTxt = [NSString stringWithFormat:@"-%@", [self.currencyFormatter stringFromNumber:@(unitPrice*-1)]];
            }
        }
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
        return self.resultLB;
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

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

- (NSString *)defaultCurrencyCode {
	NSString *currencyCode = [[NSUserDefaults standardUserDefaults] objectForKey:A3UnitPriceCurrencyCode];
	if (!currencyCode) {
		currencyCode = [[NSLocale currentLocale] objectForKey:NSLocaleCurrencyCode];
	}
	return currencyCode;
}

@end
