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
#import "UnitItem.h"
#import "A3UnitPriceSliderCell.h"
#import "A3UnitPriceInputCell.h"
#import "A3UnitPriceActionCell.h"
#import "A3UnitPriceNote2Cell.h"

#import "A3AppDelegate.h"
#import "A3NumberKeyboardViewController.h"
#import "UIViewController+A3Addition.h"
#import "UILabel+BaseAlignment.h"
#import "UIViewController+A3AppCategory.h"
#import "A3UnitPriceMainTableController.h"
#import "A3CalculatorDelegate.h"
#import "A3SearchViewController.h"
#import "UITableView+utility.h"

typedef NS_ENUM(NSInteger, PriceDiscountType) {
    Price_Amount = 0,
    Price_Percent,
};

@interface A3UnitPriceDetailTableController () <UITextFieldDelegate, UITextViewDelegate, A3KeyboardDelegate, UINavigationControllerDelegate, A3UnitSelectViewControllerDelegate, A3CalculatorDelegate, A3SearchViewControllerDelegate>
{
    PriceDiscountType _discountType;
    
    float textViewHeight;
}

@property (nonatomic, strong) NSIndexPath *currentIndexPath;

@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) NSMutableDictionary *priceItem;
@property (nonatomic, strong) NSMutableDictionary *unitItem;
@property (nonatomic, strong) NSMutableDictionary *sizeItem;
@property (nonatomic, strong) NSMutableDictionary *quantityItem;
@property (nonatomic, strong) NSMutableDictionary *discountItem;
@property (nonatomic, strong) NSMutableDictionary *noteItem;
@property (nonatomic, weak) UITextField *calculatorTargetTextField;
@property (nonatomic, strong) NSNumberFormatter *decimalFormatter;
@property (nonatomic, copy) NSString *textBeforeEditingTextField;

@end

NSString *const A3UnitPriceSliderCellID = @"A3UnitPriceSliderCell";
NSString *const A3UnitPriceInputCellID = @"A3UnitPriceInputCell";
NSString *const A3UnitPriceActionCellID = @"A3UnitPriceActionCell";
NSString *const A3UnitPriceNoteCellID = @"A3UnitPriceNoteCell";
NSString *const A3UnitPriceNote2CellID = @"A3UnitPriceNote2Cell";


@implementation A3UnitPriceDetailTableController

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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, (IS_IPAD)?28:15, 0, 0);
    self.tableView.contentInset = UIEdgeInsetsMake(-1, 0, 36, 0);
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorColor = [self tableViewSeparatorColor];
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;     // KJH
    
    self.title = _isPriceA ? @"Price A":@"Price B";
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 1, self.view.bounds.size.width, IS_RETINA ? 0.5:1.0)];
    lineView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    lineView.backgroundColor = [UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0];
    [self.tableView addSubview:lineView];
    
    [self registerContentSizeCategoryDidChangeNotification];
}

- (void)contentSizeDidChange:(NSNotification *) notification
{
    [self.tableView reloadData];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if (![self.navigationController.viewControllers containsObject:self]) {
        //pop this controller
        if ([[[MagicalRecordStack defaultStack] context] hasChanges]) {
            [[[MagicalRecordStack defaultStack] context] MR_saveOnlySelfAndWait];
            
            if (_delegate && [_delegate respondsToSelector:@selector(unitPriceInfoChanged:)]) {
                [_delegate unitPriceInfoChanged:self.price];
            }
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

	[self.firstResponder resignFirstResponder];
	[self setFirstResponder:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        _priceItem = [[NSMutableDictionary alloc] initWithDictionary:@{@"Name": @"Price"}];
    }
    return _priceItem;
}

- (NSMutableDictionary *)unitItem
{
    if (!_unitItem) {
        _unitItem = [[NSMutableDictionary alloc] initWithDictionary:@{@"Name": @"Unit"}];
    }
    return _unitItem;
}

- (NSMutableDictionary *)sizeItem
{
    if (!_sizeItem) {
        _sizeItem = [[NSMutableDictionary alloc] initWithDictionary:@{@"Name": @"Size"}];
    }
    return _sizeItem;
}

- (NSMutableDictionary *)quantityItem
{
    if (!_quantityItem) {
        _quantityItem = [[NSMutableDictionary alloc] initWithDictionary:@{@"Name": @"Quantity"}];
    }
    return _quantityItem;
}

- (NSMutableDictionary *)discountItem
{
    if (!_discountItem) {
        _discountItem = [[NSMutableDictionary alloc] initWithDictionary:@{@"Name": @"Discountpo"}];
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
    sliderCell.sliderView.displayColor = _isPriceA ? [UIColor colorWithRed:255.0/255.0 green:45.0/255.0 blue:85.0/255.0 alpha:1.0]:[UIColor colorWithRed:76.0/255.0 green:217.0/255.0 blue:100.0/255.0 alpha:1.0];
    sliderCell.sliderView.markLabel.text = _isPriceA ? @"A":@"B";
    sliderCell.sliderView.layoutType = Slider_StandAlone;
    [sliderCell.sliderView labelFontSetting];
    sliderCell.sliderView.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:248/255.0 alpha:1.0];
    sliderCell.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:248/255.0 alpha:1.0];
    
    double unitPrice = 0;
    NSString *unitPriceTxt = @"";
    NSString *unitShortName = @"";
    NSString *unitName = @"";
    NSString *priceTxt = @"";
    
    UnitPriceInfo *priceInfo = self.price;
    
    priceTxt = [self.currencyFormatter stringFromNumber:@(priceInfo.price.doubleValue)];
    unitShortName = priceInfo.unit ? priceInfo.unit.unitShortName : @"None";
    unitName = priceInfo.unit ? priceInfo.unit.unitName : @"None";
    
    double priceValue = priceInfo.price.doubleValue;
    NSInteger sizeValue = (priceInfo.size.integerValue <= 0) ? 1:priceInfo.size.integerValue;
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
        
        if (unitPrice > 0) {
            if (priceInfo.unit) {
                unitPriceTxt = [NSString stringWithFormat:@"%@/%@", [self.currencyFormatter stringFromNumber:@(unitPrice)], unitName];
            }
            else {
                unitPriceTxt = [self.currencyFormatter stringFromNumber:@(unitPrice)];
            }
            
            sliderCell.sliderView.progressBarHidden = NO;
        }
        else if (unitPrice == 0) {
            if (priceInfo.unit) {
                unitPriceTxt = [NSString stringWithFormat:@"%@/%@", [self.currencyFormatter stringFromNumber:@(unitPrice)], unitName];
            }
            else {
                unitPriceTxt = [self.currencyFormatter stringFromNumber:@(unitPrice)];
            }
            
            sliderCell.sliderView.progressBarHidden = YES;
        }
        else {
            if (priceInfo.unit) {
                unitPriceTxt = [NSString stringWithFormat:@"-%@/%@", [self.currencyFormatter stringFromNumber:@(unitPrice*-1)], unitName];
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
    NSString *priceTxt = @"";
    
    UnitPriceInfo *priceInfo = self.price;
    
    priceTxt = [self.currencyFormatter stringFromNumber:priceInfo.price];

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

	NSNumberFormatter *decimalFormatter = [NSNumberFormatter new];
	[decimalFormatter setNumberStyle:NSNumberFormatterDecimalStyle];

    if ([self.items objectAtIndex:indexPath.row] == self.priceItem) {
        inputCell.titleLB.text = @"Price";
        inputCell.textField.text = priceTxt;
    }
    else if ([self.items objectAtIndex:indexPath.row] == self.sizeItem) {
        inputCell.titleLB.text = @"Size";
        inputCell.textField.placeholder = @"Optional";
        inputCell.textField.text = priceInfo.size.doubleValue != 0.0 ? [decimalFormatter stringFromNumber:priceInfo.size] : @"";
    }
    else if ([self.items objectAtIndex:indexPath.row] == self.quantityItem) {
        inputCell.titleLB.text = @"Quantity";
        inputCell.textField.text = priceInfo.quantity ? [decimalFormatter stringFromNumber:priceInfo.quantity]:[decimalFormatter stringFromNumber:@0];
    }
    else if ([self.items objectAtIndex:indexPath.row] == self.discountItem) {
        inputCell.titleLB.text = @"Discount";
        inputCell.textField.placeholder = @"Optional";
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
        self.price.price = [self.decimalFormatter numberFromString:textField.text];
        textField.text = [self.currencyFormatter stringFromNumber:self.price.price];
    }
    else if ([self.items objectAtIndex:_currentIndexPath.row] == self.discountItem) {
        if (textField.text.length > 0) {
			_discountType = [self.numberKeyboardViewController.bigButton1 isSelected] ? Price_Percent : Price_Amount;
			switch (_discountType) {
                case Price_Amount:
                {
                    double value = [[self.decimalFormatter numberFromString:textField.text] doubleValue];
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
                    double value = [[self.decimalFormatter numberFromString:textField.text] doubleValue];
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
    }
    else if ([self.items objectAtIndex:_currentIndexPath.row] == self.sizeItem) {
        if (textField.text.length > 0) {
            self.price.size = [self.decimalFormatter numberFromString:textField.text];
        }
        else {
            self.price.size = nil;
        }
    }
}

#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    self.price.note = textView.text;
    
    [self.tableView beginUpdates];
    
    CGRect frame = textView.frame;
    frame.size.height = textView.contentSize.height+25;
    textView.frame = frame;
    
    textViewHeight = frame.size.height;
    
    [self.tableView endUpdates];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    self.price.note = textView.text;
}

#pragma mark - A3TbvCellTextInputDelegate

- (void)setupCurrencyKeyboardForTextField:(UITextField *)textField usePercent:(BOOL)usePercent {
	A3NumberKeyboardViewController *keyboardVC = [self normalNumberKeyboard];
	[keyboardVC setTextInputTarget:textField];
	[keyboardVC setDelegate:self];
	[textField setInputView:[keyboardVC view]];
	[keyboardVC setCurrencyCode:[self defaultCurrencyCode]];
	[keyboardVC setKeyboardType:usePercent ? A3NumberKeyboardTypePercent : A3NumberKeyboardTypeCurrency];
	[keyboardVC reloadPrevNextButtons];
	[self setNumberKeyboardViewController:keyboardVC];
}

- (void)setupDecimalKeyboardForTextField:(UITextField *)textField useFraction:(BOOL)useFraction {
	A3NumberKeyboardViewController *keyboardVC = [self simplePrevNextClearNumberKeyboard];
	[keyboardVC setTextInputTarget:textField];
	[keyboardVC setDelegate:self];
	[textField setInputView:[keyboardVC view]];
	[keyboardVC setKeyboardType:useFraction ? A3NumberKeyboardTypeReal : A3NumberKeyboardTypeInteger];
	[keyboardVC reloadPrevNextButtons];
	[self setNumberKeyboardViewController:keyboardVC];
}

#pragma mark - UITextField delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	// 백버튼을 눌렀을때, 네비게이션이 팝이 되었는데도,
	// 다시 textField가 firstResponder가 되면서 생기는 업데이트 문제를 수정하기 위해 조건문 추가
	if (self.navigationController.visibleViewController != self) {
		return NO;
	}
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	_textBeforeEditingTextField = textField.text;
	textField.text = @"";

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:nil];

	[self setFirstResponder:textField];

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
	}
}

- (void)textFieldDidChange:(NSNotification *)notification {
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[self.firstResponder resignFirstResponder];
	[self setFirstResponder:nil];

	return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];

	[self setFirstResponder:nil];

	if ([textField.text length] > 0) {
		[self updateValueTextField:textField];
		[self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
	} else {
		textField.text = _textBeforeEditingTextField;
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
    if (self.firstResponder && _currentIndexPath) {
        if ([self.items objectAtIndex:_currentIndexPath.row] == self.sizeItem) {
            NSUInteger index = [self.items indexOfObject:self.priceItem];
            A3UnitPriceInputCell *inputCell = (A3UnitPriceInputCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:1]];
            [inputCell.textField becomeFirstResponder];
        }
        else if ([self.items objectAtIndex:_currentIndexPath.row] == self.quantityItem) {
            NSUInteger index = [self.items indexOfObject:self.sizeItem];
            A3UnitPriceInputCell *inputCell = (A3UnitPriceInputCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:1]];
            [inputCell.textField becomeFirstResponder];
        }
        else if ([self.items objectAtIndex:_currentIndexPath.row] == self.discountItem) {
            NSUInteger index = [self.items indexOfObject:self.quantityItem];
            A3UnitPriceInputCell *inputCell = (A3UnitPriceInputCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:1]];
            [inputCell.textField becomeFirstResponder];
        }
    }
}

- (void)nextButtonPressed{
    if (self.firstResponder && _currentIndexPath) {
        if ([self.items objectAtIndex:_currentIndexPath.row] == self.priceItem) {
            NSUInteger index = [self.items indexOfObject:self.sizeItem];
            A3UnitPriceInputCell *inputCell = (A3UnitPriceInputCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:1]];
            [inputCell.textField becomeFirstResponder];
        }
        else if ([self.items objectAtIndex:_currentIndexPath.row] == self.sizeItem) {
            NSUInteger index = [self.items indexOfObject:self.quantityItem];
            A3UnitPriceInputCell *inputCell = (A3UnitPriceInputCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:1]];
            [inputCell.textField becomeFirstResponder];
        }
        else if ([self.items objectAtIndex:_currentIndexPath.row] == self.quantityItem) {
            NSUInteger index = [self.items indexOfObject:self.discountItem];
            A3UnitPriceInputCell *inputCell = (A3UnitPriceInputCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:1]];
            [inputCell.textField becomeFirstResponder];
        }
        else if ([self.items objectAtIndex:_currentIndexPath.row] == self.discountItem) {
            NSUInteger index = [self.items indexOfObject:self.noteItem];
            A3UnitPriceNote2Cell *noteCell = (A3UnitPriceNote2Cell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:1]];
            [noteCell.textView becomeFirstResponder];
        }
    }
}

- (void)A3KeyboardController:(id)controller clearButtonPressedTo:(UIResponder *)keyInputDelegate {
	UITextField *textField = (UITextField *) self.numberKeyboardViewController.textInputTarget;
	if ([textField isKindOfClass:[UITextField class]]) {
		textField.text = @"";
	}
}

- (void)A3KeyboardController:(id)controller doneButtonPressedTo:(UIResponder *)keyInputDelegate {
    [self.numberKeyboardViewController.textInputTarget resignFirstResponder];
    [self scrollToTopOfTableViewIfNeeded];
}

#pragma mark - A3UnitSelectViewControllerDelegate

- (void)selectViewController:(UIViewController *)viewController unitSelectedWithItem:(UnitItem *)selectedItem
{
    @autoreleasepool {
        
        self.price.unit = selectedItem;
        
        NSIndexPath *sliderIP = [NSIndexPath indexPathForRow:0 inSection:0];
        NSIndexPath *unitIP = [NSIndexPath indexPathForRow:[self.items indexOfObject:self.unitItem] inSection:1];
        [self.tableView reloadRowsAtIndexPaths:@[sliderIP, unitIP] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)didCancledSelectUnit
{
    
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    @autoreleasepool {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];

        if (indexPath.section == 0) {
            
        }
        else {
            if ([self.items objectAtIndex:indexPath.row] == self.noteItem) {
                A3UnitPriceNote2Cell *noteCell = (A3UnitPriceNote2Cell *)[tableView cellForRowAtIndexPath:indexPath];
                [noteCell.textView becomeFirstResponder];
            }
            else if ([self.items objectAtIndex:indexPath.row] == self.unitItem) {
                if (IS_IPHONE) {
                    //[self makeBackButtonEmptyArrow];
                    [self.navigationController pushViewController:[self unitsTabBarController] animated:YES];
                }
                else {
                    self.navigationController.navigationItem.backBarButtonItem.enabled = NO;

					[self.firstResponder resignFirstResponder];
					[self setFirstResponder:nil];

                    [self presentSubViewController:[self unitsTabBarController]];
                }
            }
            else {
                A3UnitPriceInputCell *inputCell = (A3UnitPriceInputCell *)[tableView cellForRowAtIndexPath:indexPath];
                [inputCell.textField becomeFirstResponder];
            }
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
    UITableViewCell *cell=nil;
	@autoreleasepool {
		cell = nil;
        
        if (indexPath.section == 0) {
            A3UnitPriceSliderCell *sliderCell = [tableView dequeueReusableCellWithIdentifier:A3UnitPriceSliderCellID forIndexPath:indexPath];
            [self configureSliderCell:sliderCell];
            
            cell = sliderCell;
        }
        else {
            if ([self.items objectAtIndex:indexPath.row] == self.unitItem) {
                A3UnitPriceActionCell *actionCell = [tableView dequeueReusableCellWithIdentifier:A3UnitPriceActionCellID forIndexPath:indexPath];
                actionCell.textLabel.textColor = [UIColor blackColor];
                actionCell.detailTextLabel.textColor = [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
                actionCell.textLabel.font = [UIFont systemFontOfSize:17];
                actionCell.detailTextLabel.font = [UIFont systemFontOfSize:17];
                actionCell.textLabel.text = @"Unit";
                NSString *unitName = self.price.unit ? self.price.unit.unitName : @"None";
                actionCell.detailTextLabel.text = unitName;
                
                cell = actionCell;
            }
            else if ([self.items objectAtIndex:indexPath.row] == self.noteItem) {
                /*
                A3UnitPriceNoteCell *noteCell = [tableView dequeueReusableCellWithIdentifier:A3UnitPriceNoteCellID forIndexPath:indexPath];
                noteCell.delegate = self;
                noteCell.textFd.delegate = self;
                noteCell.textFd.textColor = [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
                noteCell.textFd.font = [UIFont systemFontOfSize:17];
                noteCell.textFd.placeholder = @"Notes";
                noteCell.textFd.text = self.price.note;
                
                cell = noteCell;
                 */
                // note
                A3UnitPriceNote2Cell *noteCell = [tableView dequeueReusableCellWithIdentifier:A3UnitPriceNote2CellID forIndexPath:indexPath];
                
                noteCell.selectionStyle = UITableViewCellSelectionStyleNone;
                noteCell.textView.delegate = self;
                noteCell.textView.bounces = NO;
                noteCell.textView.placeholder = @"Notes";
                noteCell.textView.textColor = [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
                noteCell.textView.text = self.price.note ? self.price.note : @"";
                
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
        NSDictionary *textAttributes = @{
                                         NSFontAttributeName : [UIFont systemFontOfSize:17]
                                         };
        
        NSString *textString = self.price.note  ? self.price.note:@"";
        NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:textString attributes:textAttributes];
        UITextView *txtView = [[UITextView alloc] init];
        [txtView setAttributedText:attributedString];
        float margin = IS_IPAD ? 49:31;
        CGSize txtViewSize = [txtView sizeThatFits:CGSizeMake(self.view.frame.size.width-margin, 1000)];
        float cellHeight = txtViewSize.height + 20;
        
        if (cellHeight < 180) {
            return 180;
        }
        else {
            return cellHeight;
        }
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
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here, for example:
    // Create the next view controller.
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];

    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}
 
 */

- (NSString *)defaultCurrencyCode {
	NSString *currencyCode = [[NSUserDefaults standardUserDefaults] objectForKey:A3UnitPriceCurrencyCode];
	if (!currencyCode) {
		currencyCode = [[NSLocale currentLocale] objectForKey:NSLocaleCurrencyCode];
	}
	return currencyCode;
}

#pragma mark --- Response to Calculator Button and result

- (UIViewController *)modalPresentingParentViewControllerForCalculator {
	_calculatorTargetTextField = (UITextField *) self.firstResponder;
	return self;
}

- (id <A3CalculatorDelegate>)delegateForCalculator {
	return self;
}

- (void)calculatorViewController:(UIViewController *)viewController didDismissWithValue:(NSString *)value {
	_calculatorTargetTextField.text = value;
	[self textFieldDidEndEditing:_calculatorTargetTextField];
}

#pragma mark --- Response to Currency Select Button and result

- (UIViewController *)modalPresentingParentViewControllerForCurrencySelector {
	return self;
}

- (id <A3SearchViewControllerDelegate>)delegateForCurrencySelector {
	return self;
}

- (void)searchViewController:(UIViewController *)viewController itemSelectedWithItem:(NSString *)selectedItem {
	if ([selectedItem length]) {
		[[NSUserDefaults standardUserDefaults] setObject:selectedItem forKey:A3UnitPriceCurrencyCode];
		[[NSUserDefaults standardUserDefaults] synchronize];

		[self.currencyFormatter setCurrencyCode:selectedItem];
		[self.tableView reloadData];

		dispatch_async(dispatch_get_main_queue(), ^{
			[[NSNotificationCenter defaultCenter] postNotificationName:A3NotificationUnitPriceCurrencyCodeChanged object:nil];
		});
	}
}

@end
