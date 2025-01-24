//
//  A3UnitPriceDetailTableController.m
//  A3TeamWork
//
//  Created by kihyunkim on 2014. 1. 23..
//  Copyright (c) 2014년 ALLABOUTAPPS. All rights reserved.
//

#import "A3UnitPriceDetailTableController.h"
#import "A3UnitPriceSliderView.h"
#import "A3UnitPriceUnitTabBarController.h"
#import "UnitPriceInfo.h"
#import "A3UnitPriceSliderCell.h"
#import "A3UnitPriceInputCell.h"
#import "A3AppDelegate.h"
#import "A3NumberKeyboardViewController.h"
#import "UILabel+BaseAlignment.h"
#import "UIViewController+NumberKeyboard.h"
#import "A3UnitPriceMainTableController.h"
#import "UITableView+utility.h"
#import "A3WalletNoteCell.h"
#import "NSString+conversion.h"
#import "UIViewController+tableViewStandardDimension.h"
#import "A3CurrencySelectViewController.h"
#import "A3CalculatorViewController.h"
#import "UIViewController+A3Addition.h"
#import "UnitPriceInfo+extension.h"
#import "A3UserDefaultsKeys.h"
#import "A3SyncManager.h"
#import "A3UnitDataManager.h"
#import "A3SyncManager+NSUbiquitousKeyValueStore.h"
#import "A3StandardTableViewCell.h"
#import "A3AppDelegate.h"
#import "NSManagedObject+extension.h"
#import "NSManagedObjectContext+extension.h"
#import "A3SyncManager.h"
#import "A3UIDevice.h"
#import "A3UserDefaults+A3Addition.h"

typedef NS_ENUM(NSInteger, PriceDiscountType) {
	Price_Percent = 0,
    Price_Amount,
};

@interface A3UnitPriceDetailTableController () <UITextFieldDelegate, UITextViewDelegate, A3KeyboardDelegate,
		UINavigationControllerDelegate, A3UnitSelectViewControllerDelegate, A3SearchViewControllerDelegate,
		A3CalculatorViewControllerDelegate, A3ViewControllerProtocol>

@property (nonatomic, strong) NSIndexPath *currentIndexPath;

@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) NSMutableDictionary *priceItem;
@property (nonatomic, strong) NSMutableDictionary *unitItem;
@property (nonatomic, strong) NSMutableDictionary *sizeItem;
@property (nonatomic, strong) NSMutableDictionary *quantityItem;
@property (nonatomic, strong) NSMutableDictionary *discountItem;
@property (nonatomic, strong) NSMutableDictionary *noteItem;
@property (nonatomic, strong) UITextField *calculatorTargetTextField;
@property (nonatomic, strong) NSNumberFormatter *decimalFormatter;
@property (nonatomic, copy) NSString *textBeforeEditingTextField;
@property (nonatomic, copy) NSString *placeholderBeforeEditingTextField;
@property (nonatomic, strong) A3UnitDataManager *unitDataManager;
@property (nonatomic, weak) UITextField *editingTextField;
@property (nonatomic, copy) UIColor *textColorBeforeEditing;

@end

NSString *const A3UnitPriceSliderCellID = @"A3UnitPriceSliderCell";
NSString *const A3UnitPriceInputCellID = @"A3UnitPriceInputCell";
NSString *const A3UnitPriceActionCellID = @"A3UnitPriceActionCell";
NSString *const A3UnitPriceNoteCellID = @"A3UnitPriceNoteCell";

@implementation A3UnitPriceDetailTableController {
	PriceDiscountType _discountType;
	BOOL			_isNumberKeyboardVisible;
	BOOL			_didPressClearKey;
	BOOL			_didPressNumberKey;
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

	if (IS_IPHONE) {
		[self makeBackButtonEmptyArrow];
	}

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorInset = A3UITableViewSeparatorInset;
    self.tableView.contentInset = UIEdgeInsetsMake(-1, 0, 36, 0);
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorColor = [self tableViewSeparatorColor];
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
	if ([self.tableView respondsToSelector:@selector(cellLayoutMarginsFollowReadableWidth)]) {
		self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
	}
	if ([self.tableView respondsToSelector:@selector(layoutMargins)]) {
		self.tableView.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0);
	}

    self.title = _isPriceA ? NSLocalizedString(@"Price A", @"Price A") : NSLocalizedString(@"Price B", @"Price B");
    self.currencyFormatter.maximumFractionDigits = 2;
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 1, self.view.bounds.size.width, IS_RETINA ? 0.5:1.0)];
    lineView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    lineView.backgroundColor = [UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0];
    [self.tableView addSubview:lineView];
    
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cloudStoreDidImport) name:A3NotificationCloudKeyValueStoreDidImport object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cloudStoreDidImport) name:A3NotificationCloudCoreDataStoreDidImport object:nil];

	[self registerContentSizeCategoryDidChangeNotification];
}

- (void)cloudStoreDidImport {
	if (self.editingObject) {
		return;
	}

	self.currencyFormatter = nil;
	self.currencyFormatter.maximumFractionDigits = 2;

	_price = [UnitPriceInfo findFirstByAttribute:ID_KEY withValue:_isPriceA ? A3UnitPricePrice1DefaultID : A3UnitPricePrice2DefaultID];
	[self.tableView reloadData];
}

- (void)removeObserver {
	[self removeContentSizeCategoryDidChangeNotification];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationCloudKeyValueStoreDidImport object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationCloudCoreDataStoreDidImport object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
}

- (void)prepareClose {
	self.delegate = nil;
	self.tableView.delegate = nil;
	self.tableView.dataSource = nil;
	[self removeObserver];
}

- (BOOL)resignFirstResponder {
	[self dismissNumberKeyboardAnimated:NO];
	[self.editingObject resignFirstResponder];
	return [super resignFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	if ([self.navigationController.navigationBar isHidden]) {
		[self.navigationController setNavigationBarHidden:NO animated:NO];
	}
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                          atScrollPosition:UITableViewScrollPositionTop
                                  animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	[self dismissNumberKeyboardAnimated:NO];
	[self.editingObject resignFirstResponder];
	[self setEditingObject:nil];

	if ([self isMovingFromParentViewController] || [self isBeingDismissed]) {
		FNLOG();
		[self removeObserver];
	}
}

- (void)dealloc {
	[self removeObserver];
}

- (void)keyboardDidHide:(NSNotification *)notification {
	[self.tableView setContentOffset:CGPointMake(0, - self.tableView.contentInset.top) animated:YES];
}

- (void)contentSizeDidChange:(NSNotification *) notification
{
    [self.tableView reloadData];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if (![self.navigationController.viewControllers containsObject:self]) {
		if (_delegate && [_delegate respondsToSelector:@selector(unitPriceInfoChanged:)]) {
			[_delegate unitPriceInfoChanged:self.price];
		}
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (A3UnitDataManager *)unitDataManager {
	if (!_unitDataManager) {
		_unitDataManager = [A3UnitDataManager new];
	}
	return _unitDataManager;
}

- (NSNumberFormatter *)decimalFormatter {
	if (!_decimalFormatter) {
		_decimalFormatter = [NSNumberFormatter new];
		[_decimalFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
		[_decimalFormatter setMaximumFractionDigits:3];
	}
	return _decimalFormatter;
}

-(NSMutableArray *)items {
    if (!_items) {
        _items = [[NSMutableArray alloc] init];
        [_items addObject:self.priceItem];
        [_items addObject:self.unitItem];
        [_items addObject:self.sizeItem];
        [_items addObject:self.quantityItem];
        [_items addObject:self.discountItem];
        [_items addObject:self.noteItem];
    }
    
    return _items;
}

- (NSMutableDictionary *)priceItem
{
    if (!_priceItem) {
        _priceItem = [[NSMutableDictionary alloc] initWithDictionary:@{@"Name": NSLocalizedString(@"Price", @"Price")}];
    }
    return _priceItem;
}

- (NSMutableDictionary *)unitItem
{
    if (!_unitItem) {
        _unitItem = [[NSMutableDictionary alloc] initWithDictionary:@{@"Name": NSLocalizedString(@"Unit", @"Unit")}];
    }
    return _unitItem;
}

- (NSMutableDictionary *)sizeItem
{
    if (!_sizeItem) {
        _sizeItem = [[NSMutableDictionary alloc] initWithDictionary:@{@"Name": NSLocalizedString(@"Size", @"Size")}];
    }
    return _sizeItem;
}

- (NSMutableDictionary *)quantityItem
{
    if (!_quantityItem) {
        _quantityItem = [[NSMutableDictionary alloc] initWithDictionary:@{@"Name": NSLocalizedString(@"Quantity", @"Quantity")}];
    }
    return _quantityItem;
}

- (NSMutableDictionary *)discountItem
{
    if (!_discountItem) {
        _discountItem = [[NSMutableDictionary alloc] initWithDictionary:@{@"Name": NSLocalizedString(@"Discount", @"Discount")}];
    }
    return _discountItem;
}

- (NSMutableDictionary *)noteItem
{
    if (!_noteItem) {
        _noteItem = [NSMutableDictionary new];
    }
    return _noteItem;
}

- (void)configureSliderCell:(A3UnitPriceSliderCell *)sliderCell
{
    sliderCell.sliderView.displayColor = [UIColor colorWithRed:255.0/255.0 green:45.0/255.0 blue:85.0/255.0 alpha:1.0];
    sliderCell.sliderView.markLabel.text = _isPriceA ? @"A":@"B";
    sliderCell.sliderView.layoutType = Slider_StandAlone;
    [sliderCell.sliderView labelFontSetting];
    sliderCell.sliderView.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:248/255.0 alpha:1.0];
    sliderCell.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:248/255.0 alpha:1.0];
    
    double unitPrice = 0;
    NSString *unitPriceTxt = @"";
    NSString *unitName = IS_IPHONE ? [self unitShortName] : [self unitName];
    NSString *priceTxt;
    
    UnitPriceInfo *priceInfo = self.price;
    
    priceTxt = [self.currencyFormatter stringFromNumber:@(priceInfo.price.doubleValue)];

    double priceValue = priceInfo.price.doubleValue;
    double sizeValue = priceInfo.size.doubleValue;
	if (sizeValue == 0.0) sizeValue = 1.0;
    NSInteger quantityValue = priceInfo.quantity.integerValue;
    
    // 할인값
    NSString *discountText = [self.currencyFormatter stringFromNumber:@(0)];
    double discountValue = 0;
    if (!priceInfo.discountPercent && !priceInfo.discountPrice) {
        discountText = @"";
        discountValue = 0;
    }
    else {
        if (priceInfo.discountPrice.doubleValue > 0) {
            discountText = [self.currencyFormatter stringFromNumber:@(priceInfo.discountPrice.doubleValue)];
            discountValue = priceInfo.discountPrice.doubleValue;
            discountValue = MIN(discountValue, priceValue);
        }
        else if (priceInfo.discountPercent.floatValue > 0) {
            discountText = [self.percentFormatter stringFromNumber:@(priceInfo.discountPercent.doubleValue)];
            discountValue = priceValue * priceInfo.discountPercent.floatValue;
        }
    }

    if ((priceValue>0) && (sizeValue>0) && (quantityValue>0)) {
        unitPrice = (priceValue - discountValue) / (sizeValue * quantityValue);
		FNLOG(@"%@, %@", @(unitPrice), @([self.currencyFormatter minimumFractionDigits]));

        if (unitPrice > 0) {
            if (validUnit(priceInfo.unitID)) {
                unitPriceTxt = [NSString stringWithFormat:@"%@/%@",
								[self.currencyFormatter stringFromNumber:@(unitPrice)],
								unitName];
            }
            else {
                unitPriceTxt = [self.currencyFormatter stringFromNumber:@(unitPrice)];
            }
            
            sliderCell.sliderView.progressBarHidden = NO;
        }
        else if (unitPrice == 0) {
            if (validUnit(priceInfo.unitID)) {
                unitPriceTxt = [NSString stringWithFormat:@"%@/%@",
								[self.currencyFormatter stringFromNumber:@(unitPrice)],
								unitName];
            }
            else {
                unitPriceTxt = [self.currencyFormatter stringFromNumber:@(unitPrice)];
            }
            
            sliderCell.sliderView.progressBarHidden = YES;
        }
        else {
            if (validUnit(priceInfo.unitID)) {
                unitPriceTxt = [NSString stringWithFormat:@"-%@/%@",
								[self.currencyFormatter stringFromNumber:@(unitPrice*-1)],
								unitName];
            }
            else {
                unitPriceTxt = [NSString stringWithFormat:@"-%@", [self.currencyFormatter stringFromNumber:@(unitPrice*-1)]];
            }
            
            sliderCell.sliderView.progressBarHidden = YES;
        }
        
    }
    else {
        sliderCell.sliderView.progressBarHidden = YES;
    }
    
    // slider
    sliderCell.sliderView.unitPriceNumLabel.text = unitPriceTxt;
    sliderCell.sliderView.priceNumLabel.text = priceTxt;
    sliderCell.sliderView.maxValue = priceInfo.price.floatValue;
    sliderCell.sliderView.unitPriceValue = unitPrice;
    sliderCell.sliderView.priceValue = priceInfo.price.floatValue;
    
    [sliderCell.sliderView setLayoutWithAnimated];
    
    if (IS_IPAD) {
        [sliderCell.sliderView.unitPriceLabel adjustBaselineForContainView:sliderCell.contentView fromBottomDistance:104];
        [sliderCell.sliderView.unitPriceNumLabel adjustBaselineForContainView:sliderCell.contentView fromBottomDistance:104];
        [sliderCell.sliderView.priceNumLabel adjustBaselineForContainView:sliderCell.contentView fromBottomDistance:47];
        [sliderCell.sliderView.priceLabel adjustBaselineForContainView:sliderCell.contentView fromBottomDistance:47];
    }
    else {
        [sliderCell.sliderView.unitPriceLabel adjustBaselineForContainView:sliderCell.contentView fromBottomDistance:73];
        [sliderCell.sliderView.unitPriceNumLabel adjustBaselineForContainView:sliderCell.contentView fromBottomDistance:73];
        [sliderCell.sliderView.priceNumLabel adjustBaselineForContainView:sliderCell.contentView fromBottomDistance:28];
        [sliderCell.sliderView.priceLabel adjustBaselineForContainView:sliderCell.contentView fromBottomDistance:28];
    }
}

- (void)configureInputCell:(A3UnitPriceInputCell *)inputCell withIndexPath:(NSIndexPath *)indexPath
{
    NSString *priceTxt;
    
    UnitPriceInfo *priceInfo = self.price;
    
    priceTxt = [self.currencyFormatter stringFromNumber:priceInfo.price ? priceInfo.price : @0];

    // 할인값
    NSString *discountText = [self.currencyFormatter stringFromNumber:@0];
    if (priceInfo.discountPercent.doubleValue == 0.0 && priceInfo.discountPrice.doubleValue == 0.0) {
        discountText = @"";
    }
    else {
        if (priceInfo.discountPrice.doubleValue > 0) {
            discountText = [self.currencyFormatter stringFromNumber:priceInfo.discountPrice];
        }
        else if (priceInfo.discountPercent.doubleValue > 0) {
            discountText = [self.percentFormatter stringFromNumber:priceInfo.discountPercent];
        }
    }

    if ([self.items objectAtIndex:indexPath.row] == self.priceItem) {
        inputCell.titleLB.text = NSLocalizedString(@"Price", @"Price");
        inputCell.textField.text = priceTxt;
    }
    else if ([self.items objectAtIndex:indexPath.row] == self.sizeItem) {
        inputCell.titleLB.text = NSLocalizedString(@"Size", @"Size");
        inputCell.textField.placeholder = NSLocalizedString(@"Optional", @"Optional");
        inputCell.textField.text = priceInfo.size.doubleValue != 0.0 ? [self.decimalFormatter stringFromNumber:priceInfo.size] : @"";
    }
    else if ([self.items objectAtIndex:indexPath.row] == self.quantityItem) {
        inputCell.titleLB.text = NSLocalizedString(@"Quantity", @"Quantity");
        inputCell.textField.text = priceInfo.quantity ? [self.decimalFormatter stringFromNumber:priceInfo.quantity] : [self.decimalFormatter stringFromNumber:@1];
    }
    else if ([self.items objectAtIndex:indexPath.row] == self.discountItem) {
        inputCell.titleLB.text = NSLocalizedString(@"Discount", @"Discount");
        inputCell.textField.placeholder = NSLocalizedString(@"Optional", @"Optional");
        inputCell.textField.text = discountText;
    }
}

- (A3UnitPriceUnitTabBarController *)unitsTabBarController
{
    A3UnitPriceUnitTabBarController *tabBarController = [[A3UnitPriceUnitTabBarController alloc] initWithDelegate:self withPrice:self.price];
    return tabBarController;
}

- (void)updateValueTextField:(UITextField *)textField
{
    if ([self.items objectAtIndex:_currentIndexPath.row] == self.noteItem) {
        self.price.note = textField.text;
    }
    else if ([self.items objectAtIndex:_currentIndexPath.row] == self.priceItem) {
        self.price.price = @([textField.text floatValueEx]);
        textField.text = [self.currencyFormatter stringFromNumber:self.price.price ? self.price.price : @0];
    }
    else if ([self.items objectAtIndex:_currentIndexPath.row] == self.discountItem) {
        if (textField.text.length > 0) {
			_discountType = [self.numberKeyboardViewController.bigButton1 isSelected] ? Price_Percent : Price_Amount;
			switch (_discountType) {
                case Price_Amount:
                {
                    double value = [textField.text floatValueEx];
                    value = MAX(0, value);
                    self.price.discountPrice = @(value);
                    self.price.discountPercent = @0;
                    
                    // textField 의 text가 업데이트가 안되는 현상 발생 (mainQueue를 보장하게 하여 수정함)
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        textField.text = [self.currencyFormatter stringFromNumber:@(value)];
                    }];
                    
                    break;
                }
                case Price_Percent:
                {
                    double value = [textField.text floatValueEx];
                    value = MAX(0, value);
                    value /= 100.0;
                    self.price.discountPercent = @(value);
                    self.price.discountPrice = @0;
                    
                    // textField 의 text가 업데이트가 안되는 현상 발생 (mainQueue를 보장하게 하여 수정함)
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        textField.text = [self.percentFormatter stringFromNumber:@(value)];
                    }];
                    
                    break;
                }
                default:
                    break;
            }
        }
        else {
            _discountType = Price_Amount;
            self.price.discountPrice = nil;
            self.price.discountPercent = nil;
        }
    }
    else if ([self.items objectAtIndex:_currentIndexPath.row] == self.quantityItem) {
        self.price.quantity = [self.decimalFormatter numberFromString:textField.text];
		textField.text = self.price.quantity ? [self.decimalFormatter stringFromNumber:self.price.quantity]:[self.decimalFormatter stringFromNumber:@0];
    }
    else if ([self.items objectAtIndex:_currentIndexPath.row] == self.sizeItem) {
        if (textField.text.length > 0) {
            self.price.size = [self.decimalFormatter numberFromString:textField.text];
            if ([self.price.size isEqualToNumber:@0]) {
                self.price.size = nil;
            }
        }
        else {
            self.price.size = nil;
        }
		textField.text = self.price.size ? [self.decimalFormatter stringFromNumber:self.price.size]: @"";
    }
    NSManagedObjectContext *context = A3SyncManager.sharedSyncManager.persistentContainer.viewContext;
    [context saveContext];
}

- (NSString *)unitName {
	return validUnit(self.price.unitID) ?
		NSLocalizedStringFromTable(
			[self.unitDataManager unitNameForUnitID:[self.price.unitID unsignedIntegerValue] categoryID:[self.price.unitCategoryID unsignedIntegerValue]], @"unit", nil)
			: NSLocalizedString(@"None", @"None");
}

- (NSString *)unitShortName {
	return validUnit(self.price.unitID) ?
			NSLocalizedStringFromTable(
			[self.unitDataManager unitNameForUnitID:[self.price.unitID unsignedIntegerValue] categoryID:[self.price.unitCategoryID unsignedIntegerValue]], @"unitShort", nil)
			: NSLocalizedString(@"None", @"None");
}

#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
	self.editingObject = textView;
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    self.price.note = textView.text;
    
    [self.tableView beginUpdates];
    
    CGRect frame = textView.frame;
    frame.size.height = textView.contentSize.height+25;
    textView.frame = frame;
    
    [self.tableView endUpdates];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
	self.price.note = textView.text;
	self.editingObject = nil;

    NSManagedObjectContext *context = A3SyncManager.sharedSyncManager.persistentContainer.viewContext;
    [context saveContext];
}

#pragma mark - A3TbvCellTextInputDelegate

- (void)setupCurrencyKeyboardForTextField:(UITextField *)textField usePercent:(BOOL)usePercent {
	A3NumberKeyboardViewController *keyboardVC = [self normalNumberKeyboard];
	[keyboardVC view];
	keyboardVC.delegate = self;
	keyboardVC.currencyCode = [self defaultCurrencyCode];
	keyboardVC.keyboardType = usePercent ? A3NumberKeyboardTypePercent : A3NumberKeyboardTypeCurrency;
	[keyboardVC reloadPrevNextButtons];
	self.numberKeyboardViewController = keyboardVC;
}

- (void)setupDecimalKeyboardForTextField:(UITextField *)textField useFraction:(BOOL)useFraction {
	A3NumberKeyboardViewController *keyboardVC = [self simplePrevNextClearNumberKeyboard];
	[keyboardVC view];
	keyboardVC.delegate = self;
	keyboardVC.keyboardType = useFraction ? A3NumberKeyboardTypeReal : A3NumberKeyboardTypeInteger;
	[keyboardVC reloadPrevNextButtons];
	self.numberKeyboardViewController = keyboardVC;
}

#pragma mark - UITextField delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	// 백버튼을 눌렀을때, 네비게이션이 팝이 되었는데도,
	// 다시 textField가 firstResponder가 되면서 생기는 업데이트 문제를 수정하기 위해 조건문 추가
	if (self.navigationController.visibleViewController != self) {
		return NO;
	}
	if (_isNumberKeyboardVisible) {
		[self dismissNumberKeyboardAnimated:NO];
		[self presentNumberKeyboardForTextField:textField animated:NO];
	} else {
		[self presentNumberKeyboardForTextField:textField animated:YES];
	}
	return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	self.editingObject = textField;
	self.editingTextField = textField;
	_didPressClearKey = NO;
	_didPressNumberKey = NO;

	self.textBeforeEditingTextField = textField.text;
	self.placeholderBeforeEditingTextField = textField.placeholder;
	self.textColorBeforeEditing = textField.textColor;

	textField.text = [self.decimalFormatter stringFromNumber:@0];
	textField.placeholder = @"";
    textField.textColor = [[A3UserDefaults standardUserDefaults] themeColor];

	_currentIndexPath = [self.tableView indexPathForCellSubview:textField];

	if ([self.items objectAtIndex:_currentIndexPath.row] == self.priceItem) {
		[self setupCurrencyKeyboardForTextField:textField usePercent:NO ];
	}
	else if ([self.items objectAtIndex:_currentIndexPath.row] == self.sizeItem) {
		[self setupDecimalKeyboardForTextField:textField useFraction:YES];
	}
	else if ([self.items objectAtIndex:_currentIndexPath.row] == self.quantityItem) {
		[self setupDecimalKeyboardForTextField:textField useFraction:NO];
	}
	else if ([self.items objectAtIndex:_currentIndexPath.row] == self.discountItem) {
		[self setupCurrencyKeyboardForTextField:textField usePercent:YES ];
		[self.numberKeyboardViewController.bigButton1 setSelected:_discountType == Price_Percent];
		[self.numberKeyboardViewController.bigButton2 setSelected:_discountType == Price_Amount];
	}
	self.numberKeyboardViewController.textInputTarget = textField;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[self.editingObject resignFirstResponder];

	return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	textField.placeholder = _placeholderBeforeEditingTextField;

	if (_textColorBeforeEditing) {
		textField.textColor = _textColorBeforeEditing;
		_textColorBeforeEditing = nil;
	}
	if (!_didPressClearKey && !_didPressNumberKey && _textBeforeEditingTextField) {
		textField.text = _textBeforeEditingTextField;
	}
	_textBeforeEditingTextField = nil;

	[self updateValueTextField:textField];
	[self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
	self.editingObject = nil;
}

- (void)presentNumberKeyboardForTextField:(UITextField *)textField animated:(BOOL)animated {
	if (_isNumberKeyboardVisible) {
		return;
	}

	[self textFieldDidBeginEditing:textField];

	A3NumberKeyboardViewController *keyboardViewController = self.numberKeyboardViewController;

	CGRect bounds = [A3UIDevice screenBoundsAdjustedWithOrientation];
	CGFloat keyboardHeight = keyboardViewController.keyboardHeight;
	UIView *keyboardView = keyboardViewController.view;
	[self.view.superview addSubview:keyboardView];

	_isNumberKeyboardVisible = YES;
	_editingTextField = textField;

	[self addNumberKeyboardNotificationObservers];

	if (animated) {
		keyboardView.frame = CGRectMake(0, self.view.bounds.size.height, bounds.size.width, keyboardHeight);
		[UIView animateWithDuration:0.3 animations:^{
			CGRect frame = keyboardView.frame;
			frame.origin.y -= keyboardHeight;
			keyboardView.frame = frame;
			
			UIEdgeInsets contentInset = self.tableView.contentInset;
			contentInset.bottom = keyboardHeight;
			self.tableView.contentInset = contentInset;
			
			NSIndexPath *indexPath = [self.tableView indexPathForCellSubview:textField];
			[self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
		} completion:^(BOOL finished) {
		}];
	} else {
		keyboardView.frame = CGRectMake(0, self.view.bounds.size.height - keyboardHeight, bounds.size.width, keyboardHeight);
		
		UIEdgeInsets contentInset = self.tableView.contentInset;
		contentInset.bottom = keyboardHeight;
		self.tableView.contentInset = contentInset;
		
		NSIndexPath *indexPath = [self.tableView indexPathForCellSubview:textField];
		[self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
	}
}

- (void)dismissNumberKeyboardAnimated:(BOOL)animated {
	if (!_isNumberKeyboardVisible) {
		return;
	}

	[self textFieldDidEndEditing:_editingTextField];

	[self removeNumberKeyboardNotificationObservers];
	_isNumberKeyboardVisible = NO;
	
	A3NumberKeyboardViewController *keyboardViewController = self.numberKeyboardViewController;
	UIView *keyboardView = keyboardViewController.view;

    void(^completion)(void) = ^{
		[keyboardView removeFromSuperview];
		self.numberKeyboardViewController = nil;
	};

	if (animated) {
		[UIView animateWithDuration:0.3 animations:^{
			CGRect frame = keyboardView.frame;
			frame.origin.y += keyboardViewController.keyboardHeight;
			keyboardView.frame = frame;
			
			UIEdgeInsets contentInset = self.tableView.contentInset;
			contentInset.bottom = 0;
			self.tableView.contentInset = contentInset;
			
		} completion:^(BOOL finished) {
			completion();
		}];
	} else {
		UIEdgeInsets contentInset = self.tableView.contentInset;
		contentInset.bottom = 0;
		self.tableView.contentInset = contentInset;
		
		completion();
	}
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
	
	if (_isNumberKeyboardVisible && self.numberKeyboardViewController.view.superview) {
		UIView *keyboardView = self.numberKeyboardViewController.view;
		CGFloat keyboardHeight = self.numberKeyboardViewController.keyboardHeight;
		
		FNLOGRECT(self.view.bounds);
		FNLOG(@"%f", keyboardHeight);
		keyboardView.frame = CGRectMake(0, self.view.bounds.size.height - keyboardHeight, self.view.bounds.size.width, keyboardHeight);
		[self.numberKeyboardViewController rotateToInterfaceOrientation:toInterfaceOrientation];

		UIEdgeInsets contentInset = self.tableView.contentInset;
		contentInset.bottom = keyboardHeight;
		self.tableView.contentInset = contentInset;
		
		NSIndexPath *indexPath = [self.tableView indexPathForCellSubview:_editingTextField];
		[self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
	}
}

#pragma mark - A3KeyboardDelegate

- (BOOL)isPreviousEntryExists{
    if (_currentIndexPath) {
        if ([self.items objectAtIndex:_currentIndexPath.row] == self.priceItem) {
            return NO;
        }
        else {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isNextEntryExists{
    if (_currentIndexPath) {
        if ([self.items objectAtIndex:_currentIndexPath.row] == self.noteItem) {
            return NO;
        }
        else {
            return YES;
        }
    }
    return NO;
}

- (void)prevButtonPressed{
    if (_editingTextField && _currentIndexPath) {
        if ([self.items objectAtIndex:_currentIndexPath.row] == self.sizeItem) {
            NSUInteger index = [self.items indexOfObject:self.priceItem];
            A3UnitPriceInputCell *inputCell = (A3UnitPriceInputCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:1]];
			[self dismissNumberKeyboardAnimated:NO];
			[self presentNumberKeyboardForTextField:inputCell.textField animated:NO];
        }
        else if ([self.items objectAtIndex:_currentIndexPath.row] == self.quantityItem) {
            NSUInteger index = [self.items indexOfObject:self.sizeItem];
            A3UnitPriceInputCell *inputCell = (A3UnitPriceInputCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:1]];
			[self dismissNumberKeyboardAnimated:NO];
			[self presentNumberKeyboardForTextField:inputCell.textField animated:NO];
        }
        else if ([self.items objectAtIndex:_currentIndexPath.row] == self.discountItem) {
            NSUInteger index = [self.items indexOfObject:self.quantityItem];
            A3UnitPriceInputCell *inputCell = (A3UnitPriceInputCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:1]];
			[self dismissNumberKeyboardAnimated:NO];
			[self presentNumberKeyboardForTextField:inputCell.textField animated:NO];
        }
    }
}

- (void)nextButtonPressed{
    if (_editingTextField && _currentIndexPath) {
        if ([self.items objectAtIndex:_currentIndexPath.row] == self.priceItem) {
            NSUInteger index = [self.items indexOfObject:self.sizeItem];
            A3UnitPriceInputCell *inputCell = (A3UnitPriceInputCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:1]];
			[self dismissNumberKeyboardAnimated:NO];
			[self presentNumberKeyboardForTextField:inputCell.textField animated:NO];
        }
        else if ([self.items objectAtIndex:_currentIndexPath.row] == self.sizeItem) {
            NSUInteger index = [self.items indexOfObject:self.quantityItem];
            A3UnitPriceInputCell *inputCell = (A3UnitPriceInputCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:1]];
			[self dismissNumberKeyboardAnimated:NO];
			[self presentNumberKeyboardForTextField:inputCell.textField animated:NO];
        }
        else if ([self.items objectAtIndex:_currentIndexPath.row] == self.quantityItem) {
            NSUInteger index = [self.items indexOfObject:self.discountItem];
            A3UnitPriceInputCell *inputCell = (A3UnitPriceInputCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:1]];
			[self dismissNumberKeyboardAnimated:NO];
			[self presentNumberKeyboardForTextField:inputCell.textField animated:NO];
        }
        else if ([self.items objectAtIndex:_currentIndexPath.row] == self.discountItem) {
            NSUInteger index = [self.items indexOfObject:self.noteItem];
            A3WalletNoteCell *noteCell = (A3WalletNoteCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:1]];
			[self dismissNumberKeyboardAnimated:NO];
            [noteCell.textView becomeFirstResponder];
        }
    }
}

- (void)A3KeyboardController:(id)controller clearButtonPressedTo:(UIResponder *)keyInputDelegate {
	_didPressClearKey = YES;
	_didPressNumberKey = NO;
	UITextField *textField = (UITextField *) self.numberKeyboardViewController.textInputTarget;
	if ([textField isKindOfClass:[UITextField class]]) {
		textField.text = [self.decimalFormatter stringFromNumber:@0];
		_textBeforeEditingTextField = textField.text;
	}
}

- (void)A3KeyboardController:(id)controller doneButtonPressedTo:(UIResponder *)keyInputDelegate {
	[self dismissNumberKeyboardAnimated:YES];
	[self scrollToTopOfTableViewIfNeeded];
}

- (void)keyboardViewControllerDidValueChange:(A3NumberKeyboardViewController *)vc {
	_didPressNumberKey = YES;
	_didPressClearKey = NO;
}

#pragma mark - A3UnitSelectViewControllerDelegate

- (void)selectViewController:(UIViewController *)viewController didSelectCategoryID:(NSUInteger)categoryID unitID:(NSUInteger)unitID {
	self.price.unitCategoryID = @(categoryID);
	self.price.unitID = @(unitID);

    NSManagedObjectContext *context = A3SyncManager.sharedSyncManager.persistentContainer.viewContext;
    [context saveContext];

	NSIndexPath *sliderIP = [NSIndexPath indexPathForRow:0 inSection:0];
	NSIndexPath *unitIP = [NSIndexPath indexPathForRow:[self.items indexOfObject:self.unitItem] inSection:1];
	[self.tableView reloadRowsAtIndexPaths:@[sliderIP, unitIP] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

	if (indexPath.section == 0) {

	}
	else {
		if ([self.items objectAtIndex:indexPath.row] == self.noteItem) {
			A3WalletNoteCell *noteCell = (A3WalletNoteCell *)[tableView cellForRowAtIndexPath:indexPath];
			[noteCell.textView becomeFirstResponder];
		}
		else if ([self.items objectAtIndex:indexPath.row] == self.unitItem) {
			if (IS_IPHONE) {
				//[self makeBackButtonEmptyArrow];
				[self.navigationController pushViewController:[self unitsTabBarController] animated:YES];
			}
			else {
				self.navigationController.navigationItem.backBarButtonItem.enabled = NO;

				[self.editingObject resignFirstResponder];
				[self setEditingObject:nil];

                UINavigationController *unitTabBarNavigationController = [[UINavigationController alloc] initWithRootViewController:[self unitsTabBarController]];
                [self presentViewController:unitTabBarNavigationController animated:YES completion:NULL];
			}
		}
		else {
			A3UnitPriceInputCell *inputCell = (A3UnitPriceInputCell *)[tableView cellForRowAtIndexPath:indexPath];
			[inputCell.textField becomeFirstResponder];
		}
	}
}

#pragma mark TableView Manipulate
// KJH
- (void)scrollToTopOfTableViewIfNeeded {
    if (IS_IPAD) {
        return;
    }
    
    if ([self.price.price doubleValue] > 0 && [self.price.quantity doubleValue] > 0) {
        [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0) {
        return 1;
    }
    else {
        return self.items.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell;

	if (indexPath.section == 0) {
		A3UnitPriceSliderCell *sliderCell = [tableView dequeueReusableCellWithIdentifier:A3UnitPriceSliderCellID forIndexPath:indexPath];
		[self configureSliderCell:sliderCell];
		cell = sliderCell;
	}
	else {
		if ([self.items objectAtIndex:indexPath.row] == self.unitItem) {
			A3StandardTableViewCell *actionCell = [tableView dequeueReusableCellWithIdentifier:A3UnitPriceActionCellID forIndexPath:indexPath];
			actionCell.textLabel.textColor = [UIColor blackColor];
			actionCell.detailTextLabel.textColor = [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
			actionCell.textLabel.font = [UIFont systemFontOfSize:17];
			actionCell.detailTextLabel.font = [UIFont systemFontOfSize:17];
			actionCell.textLabel.text = NSLocalizedString(@"Unit", @"Unit");
			NSString *unitName = [self unitName];
			actionCell.detailTextLabel.text = unitName;

			cell = actionCell;
		}
		else if ([self.items objectAtIndex:indexPath.row] == self.noteItem) {
			A3WalletNoteCell *noteCell = [tableView dequeueReusableCellWithIdentifier:A3UnitPriceNoteCellID forIndexPath:indexPath];
			[noteCell setupTextView];
			noteCell.textView.delegate = self;
			noteCell.textView.text = [self.price.note length] ? self.price.note : nil;

			cell = noteCell;
		}
		else {
			A3UnitPriceInputCell *inputCell = [tableView dequeueReusableCellWithIdentifier:A3UnitPriceInputCellID forIndexPath:indexPath];
			inputCell.textField.textColor = [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
			inputCell.titleLB.textColor = [UIColor blackColor];
			inputCell.textField.delegate = self;

			[self configureInputCell:inputCell withIndexPath:indexPath];

			cell = inputCell;
		}
	}

	cell.selectionStyle = UITableViewCellSelectionStyleNone;

	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return IS_IPAD ? 158 : 104;
    }
    else if ([self.items objectAtIndex:indexPath.row] == self.noteItem) {
		return [UIViewController noteCellHeight];
	}
    return 44.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    else {
        return IS_RETINA ? 34.0:34.0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}

- (NSString *)defaultCurrencyCode {
	NSString *currencyCode = [[A3SyncManager sharedSyncManager] objectForKey:A3UnitPriceUserDefaultsCurrencyCode];
	if (!currencyCode) {
		currencyCode = [A3UIDevice systemCurrencyCode];
	}
	return currencyCode;
}

#pragma mark - Number Keyboard Currency Select Button Notification

- (void)currencySelectButtonAction:(NSNotification *)notification {
	A3CurrencySelectViewController *viewController = [self presentCurrencySelectViewControllerWithCurrencyCode:notification.object];
	viewController.delegate = self;
}

- (void)searchViewController:(UIViewController *)viewController itemSelectedWithItem:(NSString *)currencyCode {
	[UnitPriceInfo changeDefaultCurrencyCode:currencyCode];

    self.currencyFormatter = nil;

    [self.currencyFormatter setCurrencyCode:currencyCode];
    self.currencyFormatter.maximumFractionDigits = 2;
    [self.tableView reloadData];
}

#pragma mark - Number Keyboard Calculator Button Notification

- (void)calculatorButtonAction {
	_calculatorTargetTextField = (UITextField *) self.editingObject;
	[self.editingObject resignFirstResponder];
	A3CalculatorViewController *viewController = [self presentCalculatorViewController];
	viewController.delegate = self;
}

- (void)calculatorDidDismissWithValue:(NSString *)value {
	_calculatorTargetTextField.text = value;
	[self textFieldDidEndEditing:_calculatorTargetTextField];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    FNLOG(@"%f", scrollView.contentOffset.y);
}

@end
