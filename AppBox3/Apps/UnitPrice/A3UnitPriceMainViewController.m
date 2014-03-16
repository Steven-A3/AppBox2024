//
//  A3UnitPriceMainViewController.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 2..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3UnitPriceMainViewController.h"
#import "A3UnitPriceInputView.h"
#import "A3UnitPriceSliderView.h"
#import "A3UnitPriceHistoryViewController.h"
#import "A3UnitPriceDetailTableController.h"
#import "UnitItem.h"
#import "UnitPriceInfo.h"
#import "UnitPriceHistory.h"
#import "UnitPriceHistoryItem.h"

#import "common.h"
#import "A3AppDelegate.h"
#import "UIViewController+A3AppCategory.h"
#import "NSMutableArray+A3Sort.h"
#import "NSManagedObject+MagicalFinders.h"
#import "NSManagedObjectContext+MagicalSaves.h"
#import "NSManagedObject+MagicalRecord.h"
#import "NSUserDefaults+A3Defaults.h"
#import "A3UIDevice.h"
#import "UIViewController+MMDrawerController.h"
#import "A3RootViewController_iPad.h"
#import "NSString+conversion.h"
#import "UIViewController+A3Addition.h"

@interface A3UnitPriceMainViewController () <UnitPriceInputDelegate, A3UnitPriceModifyDelegate, UnitPriceHistoryViewControllerDelegate>
{
    float price1UnitPrice;
    float price2UnitPrice;
}

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) A3UnitPriceSliderView *price1sliderView;
@property (nonatomic, strong) A3UnitPriceSliderView *price2sliderView;
@property (nonatomic, strong) A3UnitPriceInputView *price1InputView;
@property (nonatomic, strong) A3UnitPriceInputView *price2InputView;
@property (nonatomic, strong) UnitPriceInfo *price1;
@property (nonatomic, strong) UnitPriceInfo *price2;
@property (nonatomic, strong) UIBarButtonItem *historyBarItem;
@property (weak, nonatomic) IBOutlet UILabel *resultLB;
@property (weak, nonatomic) IBOutlet UIView *graphBgView;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *lineViews;

@end

@implementation A3UnitPriceMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.navigationItem.title = @"Unit Price";
    
    [self makeBackButtonEmptyArrow];
    [self leftBarButtonAppsButton];
    
    self.navigationItem.hidesBackButton = YES;
    
    self.navigationItem.rightBarButtonItems = @[self.historyBarItem];

    for (UIView *linewView in _lineViews) {
        if (IS_RETINA) {
            CGRect rect = linewView.frame;
            rect.size.height = 0.5;
            rect.origin.y += 0.5;
            linewView.frame = rect;
        }
        
        linewView.backgroundColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0];
    }
    
    [self initializeView];
    [self updateUnitPrices:NO];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSArray *historys = [UnitPriceHistory MR_findAll];
    if (historys.count>0) {
        self.historyBarItem.enabled = YES;
    }
    else {
        self.historyBarItem.enabled = NO;
    }
    
    [self.scrollView setContentOffset:CGPointZero animated:NO];
}

- (void)viewWillLayoutSubviews {
	[super viewWillLayoutSubviews];
    
	if (IS_IPAD) {
        // 아이패드도 바운스가 되도록 하기 위해서, 화면 높이보다 크게 컨텐츠 영역 높이를 준다.
        CGSize contentSize = self.scrollView.contentSize;
        float scrollContentHeight = contentSize.height;
        float viewHeight = (IS_LANDSCAPE) ? 768-64:1024-64;
        if (scrollContentHeight <= viewHeight) {
            scrollContentHeight = (viewHeight+1);
        }
        contentSize.height = scrollContentHeight;
        self.scrollView.contentSize = contentSize;
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIBarButtonItem *)historyBarItem
{
    if (!_historyBarItem) {
        _historyBarItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"history"] style:UIBarButtonItemStylePlain target:self action:@selector(historyButtonAction:)];
    }
    
    return _historyBarItem;
}

- (void)updateUnitPrices:(BOOL) historyUpdate
{
    _resultLB.text = @"";
    price1UnitPrice = 0.0;
    price2UnitPrice = 0.0;

    [self updateUnitPrice1];
    [self updateUnitPrice2];
    
    if (price1UnitPrice>0 && price2UnitPrice>0) {
        if (price1UnitPrice < price2UnitPrice) {
            _resultLB.text = [NSString stringWithFormat:@"The best unit price is A at %@", _price1sliderView.unitPriceNumLabel.text];
        }
        else if (price1UnitPrice > price2UnitPrice) {
            _resultLB.text = [NSString stringWithFormat:@"The best unit price is B at %@", _price2sliderView.unitPriceNumLabel.text];
        }
        else {
            _resultLB.text = [NSString stringWithFormat:@"The unit price is same at %@", _price1sliderView.unitPriceNumLabel.text];
        }
        
        // put History
        if (historyUpdate) {
            [self putHistory];
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

- (void)updateUnitPrice1
{
    float unitPrice = 0;
    NSString *unitPriceTxt = @"";
    NSString *unitShortName = @"";
    NSString *unitName = @"";
    NSString *priceTxt = @"";
    NSString *sizeTxt = @"";
    float maxPrice = MAX(self.price1.price.doubleValue, self.price2.price.doubleValue);

    UnitPriceInfo *priceInfo = self.price1;
    
    priceTxt = [self.currencyFormatter stringFromNumber:@(priceInfo.price.doubleValue)];
    unitShortName = priceInfo.unit ? priceInfo.unit.unitShortName : @"None";
    unitName = priceInfo.unit ? priceInfo.unit.unitName : @"None";
    sizeTxt = priceInfo.size ? priceInfo.size : @"-";
    
    float priceValue = priceInfo.price.doubleValue;
    NSUInteger sizeValue = (priceInfo.size.integerValue <= 0) ? 1:priceInfo.size.integerValue;
    NSUInteger quantityValue = priceInfo.quantity.integerValue;
    
    // 할인값
    NSString *discountText = [self.currencyFormatter stringFromNumber:@(0)];
    float discountValue = 0;
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
                /*
                if (self.price2.unit) {
                    unitPriceTxt = [NSString stringWithFormat:@"%@/%@", [self.currencyFormatter stringFromNumber:@(unitPrice)], self.price2.unit.unitShortName];
                }
                else {
                    unitPriceTxt = [self.currencyFormatter stringFromNumber:@(unitPrice)];
                }
                 */
            }
            
            _price1sliderView.progressBarHidden = NO;
        }
        else if (unitPrice == 0) {
            if (priceInfo.unit) {
                unitPriceTxt = [NSString stringWithFormat:@"%@/%@", [self.currencyFormatter stringFromNumber:@(unitPrice)], unitShortName];
            }
            else {
                unitPriceTxt = [self.currencyFormatter stringFromNumber:@(unitPrice)];

                /*
                if (self.price2.unit) {
                    unitPriceTxt = [NSString stringWithFormat:@"%@/%@", [self.currencyFormatter stringFromNumber:@(unitPrice)], self.price2.unit.unitShortName];
                }
                else {
                    unitPriceTxt = [self.currencyFormatter stringFromNumber:@(unitPrice)];
                }
                 */
            }
            
            _price1sliderView.progressBarHidden = YES;
            
        }
        else {
            if (priceInfo.unit) {
                unitPriceTxt = [NSString stringWithFormat:@"-%@/%@", [self.currencyFormatter stringFromNumber:@(unitPrice*-1)], unitShortName];
            }
            else {
                unitPriceTxt = [NSString stringWithFormat:@"-%@", [self.currencyFormatter stringFromNumber:@(unitPrice*-1)]];

                /*
                if (self.price2.unit) {
                    unitPriceTxt = [NSString stringWithFormat:@"-%@/%@", [self.currencyFormatter stringFromNumber:@(unitPrice*-1)], self.price2.unit.unitShortName];
                }
                else {
                    unitPriceTxt = [NSString stringWithFormat:@"-%@", [self.currencyFormatter stringFromNumber:@(unitPrice*-1)]];
                }
                 */
            }
            
            _price1sliderView.progressBarHidden = YES;
        }
    }
    else {
        _price1sliderView.progressBarHidden = YES;
    }
    
    // input1
    _price1InputView.priceLabel.text = priceTxt;
    _price1InputView.unitLabel.text = IS_IPHONE ? unitShortName : unitName;
    _price1InputView.sizeLabel.text = sizeTxt;
    _price1InputView.quantityLabel.text = priceInfo.quantity ? priceInfo.quantity:@"0";
    _price1InputView.discountLabel.text = discountText;
    [_price1InputView.unitPriceBtn setTitle:unitPriceTxt forState:UIControlStateNormal];
    
    
    // slider1
    _price1sliderView.unitPriceNumLabel.text = unitPriceTxt;
    _price1sliderView.priceNumLabel.text = priceTxt;
    _price1sliderView.maxValue = maxPrice;
    _price1sliderView.unitPriceValue = unitPrice;
    _price1sliderView.priceValue = priceInfo.price.floatValue;
    
    price1UnitPrice = unitPrice;
}

- (void)updateUnitPrice2
{
    float unitPrice = 0;
    NSString *unitPriceTxt = @"";
    NSString *price1UnitShortName = @"";
    NSString *unitShortName = @"";
    NSString *unitName = @"";
    NSString *priceTxt = @"";
    NSString *sizeTxt = @"";
    float maxPrice = MAX(self.price1.price.floatValue, self.price2.price.floatValue);
    
    UnitPriceInfo *priceInfo = self.price2;
    
    priceTxt = [self.currencyFormatter stringFromNumber:@(priceInfo.price.doubleValue)];
    price1UnitShortName = _price1.unit ? _price1.unit.unitShortName : @"None";
    unitShortName = priceInfo.unit ? priceInfo.unit.unitShortName : @"None";
    unitName = priceInfo.unit ? priceInfo.unit.unitName : @"None";
    sizeTxt = priceInfo.size ? priceInfo.size : @"-";
    
    float priceValue = priceInfo.price.floatValue;
    NSUInteger sizeValue = (priceInfo.size.integerValue <= 0) ? 1:priceInfo.size.integerValue;
    NSUInteger quantityValue = priceInfo.quantity.integerValue;

    // 할인값
    NSString *discountText = [self.currencyFormatter stringFromNumber:@(0)];
    float discountValue = 0;
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
        
        unitPrice = (priceValue - discountValue) / (sizeValue * quantityValue * rate);
        
        if (unitPrice > 0) {
            if (priceInfo.unit) {
                unitPriceTxt = [NSString stringWithFormat:@"%@/%@", [self.currencyFormatter stringFromNumber:@(unitPrice)], unitShortName];
            }
            else {
                unitPriceTxt = [self.currencyFormatter stringFromNumber:@(unitPrice)];

                /*
                if (self.price1.unit) {
                    unitPriceTxt = [NSString stringWithFormat:@"%@/%@", [self.currencyFormatter stringFromNumber:@(unitPrice)], self.price1.unit.unitShortName];
                }
                else {
                    unitPriceTxt = [self.currencyFormatter stringFromNumber:@(unitPrice)];
                }
                 */
            }
            
            _price2sliderView.progressBarHidden = NO;
        }
        else if (unitPrice == 0) {
            if (priceInfo.unit) {
                unitPriceTxt = [NSString stringWithFormat:@"%@/%@", [self.currencyFormatter stringFromNumber:@(unitPrice)], unitShortName];
            }
            else {
                unitPriceTxt = [self.currencyFormatter stringFromNumber:@(unitPrice)];

                /*
                if (self.price1.unit) {
                    unitPriceTxt = [NSString stringWithFormat:@"%@/%@", [self.currencyFormatter stringFromNumber:@(unitPrice)], self.price1.unit.unitShortName];
                }
                else {
                    unitPriceTxt = [self.currencyFormatter stringFromNumber:@(unitPrice)];
                }
                 */
            }
            
            _price2sliderView.progressBarHidden = YES;
            
        }
        else {
            if (priceInfo.unit) {
                unitPriceTxt = [NSString stringWithFormat:@"-%@/%@", [self.currencyFormatter stringFromNumber:@(unitPrice*-1)], unitShortName];
            }
            else {
                unitPriceTxt = [NSString stringWithFormat:@"-%@", [self.currencyFormatter stringFromNumber:@(unitPrice*-1)]];

                /*
                if (self.price1.unit) {
                    unitPriceTxt = [NSString stringWithFormat:@"-%@/%@", [self.currencyFormatter stringFromNumber:@(unitPrice*-1)], self.price1.unit.unitShortName];
                }
                else {
                    unitPriceTxt = [NSString stringWithFormat:@"-%@", [self.currencyFormatter stringFromNumber:@(unitPrice*-1)]];
                }
                 */
            }
            
            _price2sliderView.progressBarHidden = YES;
        }
    }
    else {
        _price2sliderView.progressBarHidden = YES;
    }
    
    // input2
    _price2InputView.priceLabel.text = priceTxt;
    _price2InputView.unitLabel.text = IS_IPHONE ? unitShortName : unitName;
    _price2InputView.sizeLabel.text = sizeTxt;
    _price2InputView.quantityLabel.text = priceInfo.quantity ? priceInfo.quantity:@"0";
    _price2InputView.discountLabel.text = discountText;
    [_price2InputView.unitPriceBtn setTitle:unitPriceTxt forState:UIControlStateNormal];
    
    
    // slider2
    _price2sliderView.unitPriceNumLabel.text = unitPriceTxt;
    _price2sliderView.priceNumLabel.text = priceTxt;
    _price2sliderView.maxValue = maxPrice;
    _price2sliderView.unitPriceValue = unitPrice;
    _price2sliderView.priceValue = priceInfo.price.floatValue;
    
    price2UnitPrice = unitPrice;
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

- (A3UnitPriceInputView *)price1InputView
{
    if (!_price1InputView) {
        NSString *nibName = (IS_IPHONE) ? @"A3UnitPriceInputView" : @"A3UnitPriceInputView_iPad";
        _price1InputView = [[[NSBundle mainBundle] loadNibNamed:nibName
                                                          owner:nil
                                                        options:nil] lastObject];
        _price1InputView.markLabel.text = @"A";
        _price1InputView.layer.anchorPoint = CGPointMake(0, 1);
        _price1InputView.delegate = self;
    }
    
    return _price1InputView;
}

- (A3UnitPriceInputView *)price2InputView
{
    if (!_price2InputView) {
        NSString *nibName = (IS_IPHONE) ? @"A3UnitPriceInputView" : @"A3UnitPriceInputView_iPad";
        _price2InputView = [[[NSBundle mainBundle] loadNibNamed:nibName
                                                          owner:nil
                                                        options:nil] lastObject];
        _price2InputView.markLabel.text = @"B";
        _price2InputView.layer.anchorPoint = CGPointMake(0, 1);
        _price2InputView.delegate = self;
    }
    
    return _price2InputView;
}

- (A3UnitPriceSliderView *)price1sliderView
{
    if (!_price1sliderView) {
        _price1sliderView = [[[NSBundle mainBundle] loadNibNamed:@"A3UnitPriceSliderView"
                                                           owner:nil
                                                         options:nil] lastObject];
        
        _price1sliderView.layer.anchorPoint = CGPointMake(0, 1);
        CGRect rect = _price1sliderView.frame;
        rect.size.width = self.view.bounds.size.width;
        _price1sliderView.frame = rect;
        _price1sliderView.displayColor = [UIColor colorWithRed:255.0/255.0 green:45.0/255.0 blue:85.0/255.0 alpha:1.0];
        _price1sliderView.markLabel.text = @"A";
        _price1sliderView.layoutType = Slider_UpperOfTwo;
    }
    
    return _price1sliderView;
}

- (A3UnitPriceSliderView *)price2sliderView
{
    if (!_price2sliderView) {
        _price2sliderView = [[[NSBundle mainBundle] loadNibNamed:@"A3UnitPriceSliderView"
                                                           owner:nil
                                                         options:nil] lastObject];
        _price2sliderView.layer.anchorPoint = CGPointMake(0, 1);
        CGRect rect = _price2sliderView.frame;
        rect.size.width = self.view.bounds.size.width;
        _price2sliderView.frame = rect;
        _price2sliderView.displayColor = [UIColor colorWithRed:76.0/255.0 green:217.0/255.0 blue:100.0/255.0 alpha:1.0];
        _price2sliderView.markLabel.text = @"B";
        _price2sliderView.layoutType = Slider_LowerOfTwo;
    }
    
    return _price2sliderView;
}

- (void)initializeView
{
    /*
     아이폰
     164 / 49 / 178 / 36 / 178
     
     아이패드
     223 / 47 / 192 / 36 / 192
     */
    
    [_scrollView addSubview:self.price1sliderView];
    [_scrollView addSubview:self.price2sliderView];
    [_scrollView addSubview:self.price1InputView];
    [_scrollView addSubview:self.price2InputView];
    
    _price1InputView.markLabel.text = @"A";
    _price2InputView.markLabel.text = @"B";
    
    float lastBottomMargin = 38.0;
    
    if (IS_IPHONE) {
        // 67 , 178
        float sliderViewHeight = 67.0;
        float inputViewHeight = 178.0;
        
        float ySum = 15.0;
        
        ySum += sliderViewHeight;
        _price1sliderView.center = CGPointMake(0, ySum);
        ySum += sliderViewHeight;
        _price2sliderView.center = CGPointMake(0, ySum);
        ySum += (IS_RETINA  ? 71.5:72.0); // gap
        ySum += inputViewHeight;
        _price1InputView.center = CGPointMake(0, ySum);
        ySum += (IS_RETINA ? 34.5:35.0) + inputViewHeight;
        _price2InputView.center = CGPointMake(0, ySum);
        ySum += lastBottomMargin;
        _scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, ySum);
    }
    else {
        // 67 , 178
        float sliderViewHeight = 67.0;
        float inputViewHeight = 190.0;
        
        float ySum = 15.0 + 36.0;   // 시작값 늘리기
        
        ySum += sliderViewHeight;
        _price1sliderView.center = CGPointMake(0, ySum);
        ySum += sliderViewHeight;
        _price2sliderView.center = CGPointMake(0, ySum);
        ySum += (IS_RETINA ? 95.5:96.0); // gap
        ySum += inputViewHeight;
        _price1InputView.center = CGPointMake(0, ySum);
        ySum += (IS_RETINA ? 34.5:35.0) + inputViewHeight;
        _price2InputView.center = CGPointMake(0, ySum);
        ySum += lastBottomMargin;
        
        _scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, ySum);
    }
    
}

- (void)historyButtonAction:(UIButton *)button {
	@autoreleasepool {
        A3UnitPriceHistoryViewController *viewController = [[A3UnitPriceHistoryViewController alloc] initWithNibName:nil bundle:nil];
        viewController.delegate = self;
		[self presentSubViewController:viewController];
	}
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
        [self.price1sliderView setLayoutWithAnimated];
        [self.price2sliderView setLayoutWithAnimated];
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
    [self.price1sliderView setLayoutWithAnimated];
    [self.price2sliderView setLayoutWithAnimated];
}

#pragma mark - UnitPriceInputDelegate

- (void)inputViewTapped:(A3UnitPriceInputView *)inputView
{
    if (inputView == _price1InputView) {
        /*
        A3UnitPriceDetailViewController *viewController = [self detailViewController];
        viewController.isPriceA = YES;
        viewController.price = self.price1;
        [self.navigationController pushViewController:viewController animated:YES];
         */
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:IS_IPAD ? @"UnitPriceStoryboard_iPad" : @"UnitPriceStoryboard" bundle:nil];
        A3UnitPriceDetailTableController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"A3UnitPriceDetailTableController"];
        viewController.delegate = self;
        viewController.isPriceA = YES;
        viewController.price = self.price1;
        [self.navigationController pushViewController:viewController animated:YES];
    }
    else if (inputView == _price2InputView) {
        /*
        A3UnitPriceDetailViewController *viewController = [self detailViewController];
        viewController.isPriceA = NO;
        viewController.price = self.price2;
        [self.navigationController pushViewController:viewController animated:YES];
         */
        
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:IS_IPAD ? @"UnitPriceStoryboard_iPad" : @"UnitPriceStoryboard" bundle:nil];
        A3UnitPriceDetailTableController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"A3UnitPriceDetailTableController"];
        viewController.delegate = self;
        viewController.isPriceA = NO;
        viewController.price = self.price2;
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

@end
