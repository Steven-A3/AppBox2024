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
#import "UIViewController+A3AppCategory.h"
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


enum A3TableElementCellType {
    A3TableElementCellType_Price = 100,
    A3TableElementCellType_Discount,
    A3TableElementCellType_Additional,
    A3TableElementCellType_Tax,
    A3TableElementCellType_Note
};

NSString *const A3SalesCalcCurrencyCode = @"A3SalesCalcCurrencyCode";

@interface A3SalesCalcMainViewController () <A3JHSelectTableViewControllerProtocol, A3SalesCalcHistorySelectDelegate, CLLocationManagerDelegate, UIPopoverControllerDelegate, A3SearchViewControllerDelegate, A3TableViewInputElementDelegate>

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

@property (nonatomic, strong) CLLocationManager * lm;
@property (nonatomic, strong) A3TableViewInputElement *taxElement;
@property (nonatomic, strong) A3TableViewInputElement *price;
@property (nonatomic, strong) A3TextViewElement *notes;
@property (nonatomic, strong) UITextView *textViewResponder;

@end

@implementation A3SalesCalcMainViewController
{
    NSNumber * _locationTax;
    NSString * _locationCode;
}

- (id)init {
	self = [super initWithStyle:UITableViewStyleGrouped];
	if (self) {
        // Custom initialization
        self.title = @"Sales Calculator";
        [self configureTableData];
        
        _lm = [[CLLocationManager alloc] init];
        _lm.delegate = self;
        _locationTax = @0.0;
        [self getReverseGeocode];
	}
	
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self makeBackButtonEmptyArrow];
	[self leftBarButtonAppsButton];
    [self rightButtonHistoryButton];
    [self registerContentSizeCategoryDidChangeNotification];
    [self setBarButtonsEnable:YES];
    
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
    
    UIBarButtonItem *compoItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(saveToHistory:)];
    
    self.navigationItem.rightBarButtonItems = @[historyItem, compoItem];
}

- (void)appsButtonAction:(UIBarButtonItem *)barButtonItem {
	[self.textViewResponder resignFirstResponder];

	[super appsButtonAction:barButtonItem];
}

-(void)setBarButtonsEnable:(BOOL)enable
{
    if (enable) {
        SalesCalcHistory *aData = [SalesCalcHistory MR_findFirst];
        UIBarButtonItem *historyButton = [self.navigationItem.rightBarButtonItems objectAtIndex:0];
        historyButton.enabled = aData ? YES : NO;
        
        UIBarButtonItem *compo = [self.navigationItem.rightBarButtonItems objectAtIndex:1];
        compo.enabled = (![self.preferences.calcData.price isEqualToNumber:@0] && ![self.preferences.calcData.discount isEqualToNumber:@0]) ? YES : NO;
        
    } else {
        [self.navigationItem.rightBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem *barButton, NSUInteger idx, BOOL *stop) {
            barButton.enabled = NO;
        }];
    }
}

-(void)saveInputTextData:(A3SalesCalcData *)inputTextData {
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:inputTextData] forKey:@"savedInputData_SalesCalc"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)saveToHistory:(id)sender {
    BOOL result;
    A3TextViewElement *notes = (A3TextViewElement *)[self.root elementForIndexPath:[NSIndexPath indexPathForRow:2 inSection:2]];
    self.preferences.calcData.notes = notes.value;
    result = [self.preferences.calcData saveData];
    
    if (result) {
        A3SalesCalcData *newData = [[A3SalesCalcData alloc] init];
        [self saveInputTextData:newData];
        [self reloadSalesCalcData:newData];
    }
    
    [self scrollToTopOfTableView];
    [self setBarButtonsEnable:YES];
}

#pragma mark - History

-(void)historyButtonAction:(id)sender
{
    [self.firstResponder resignFirstResponder];
	[self setFirstResponder:nil];

    [self.textViewResponder resignFirstResponder];
    A3SalesCalcHistoryViewController *viewController = [[A3SalesCalcHistoryViewController alloc] initWithStyle:UITableViewStylePlain];
    viewController.delegate = self;
    
//    if (_preferences.calcData && [_preferences didSaveBefore]==NO) {
//        [_preferences.calcData saveDataForcingly];
//        [_preferences setOldCalcData:_preferences.calcData];
//    }
    
    [self presentSubViewController:viewController];
    
    if (IS_IPAD) {
        [self.navigationItem.rightBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem *buttonItem, NSUInteger idx, BOOL *stop) {
            [buttonItem setEnabled:NO];
        }];
        _headerView.detailInfoButton.enabled = NO;
    }
}

-(void)didSelectHistoryData:(A3SalesCalcData *)aData
{
//    [self reloadSalesCalcData:aData];
//    [self.firstResponder resignFirstResponder];
//    [self.textViewResponder resignFirstResponder];
//    self.firstResponder = nil;
//    _textViewResponder = nil;
    
    self.preferences.calcData = aData;
    [self saveInputTextData:aData];
    
    NSMutableArray *sectionsArray = [NSMutableArray new];
    [sectionsArray addObject:[self knownValueTypeElements]];
    [sectionsArray addObject:[self valueAndPriceElementsFor:aData]];
    [sectionsArray addObject:[self advancedSectionWithData:aData]];
    
    [_headerView setResultData:aData withAnimation:YES];
    
    [self.root setSectionsArray:sectionsArray];
    [self.tableView reloadData];
}

-(void)clearSelectHistoryData {
    [self setBarButtonsEnable:YES];
}

-(void)dismissHistoryViewController {
    [self setBarButtonsEnable:YES];
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
        NSData * saveData = [[NSUserDefaults standardUserDefaults] objectForKey:@"savedInputData_SalesCalc"];
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
    [self setBarButtonsEnable:NO];
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    _headerView.detailInfoButton.enabled = YES;

    [self setBarButtonsEnable:YES];
}

- (void)configureTableData {
	@autoreleasepool {
        _preferences = [self preferences];
        
		NSMutableArray *sectionsArray = [NSMutableArray new];
		[sectionsArray addObject:[self knownValueTypeElements] ];
		[sectionsArray addObject:[self valueAndPriceElementsFor:nil]];
        //[sectionsArray addObject:[self expandable:nil]];
        [sectionsArray addObject:[self advancedSectionWithData:nil]];

		[self.root setSectionsArray:sectionsArray];
//        [self adjustElementValue];
	}
}

-(id)knownValueTypeElements
{
    NSMutableArray *elements = [NSMutableArray new];
    
    A3TableViewCheckMarkElement *originPrice = [A3TableViewCheckMarkElement new];
    originPrice.title = @"Original Price";
    originPrice.identifier = 0;
    originPrice.checked = _preferences.calcData.shownPriceType == ShowPriceType_Origin;
    [elements addObject:originPrice];
    
    A3TableViewCheckMarkElement *salePrice = [A3TableViewCheckMarkElement new];
    //salePrice.title = @"Sale Price";
    salePrice.title = IS_IPAD? @"Sale Price with Tax" : @"Sale Price w/Tax";
    salePrice.identifier = 0;
    salePrice.checked = _preferences.calcData.shownPriceType == ShowPriceType_Sale;
    [elements addObject:salePrice];
    
    return elements;
}

-(id)valueAndPriceElementsFor:(A3SalesCalcData *)aData
{
    NSNumberFormatter * formatter = [NSNumberFormatter new];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    NSMutableArray *elements = [NSMutableArray new];

    if (!_price) {
        _price = [A3TableViewInputElement new];
    }
    _price.title = _preferences.calcData.shownPriceType == ShowPriceType_Origin ? @"Original Price" : (IS_IPAD ? @"Sale Price with Tax" : @"Sale Price w/Tax");
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
        _price.value = [formatter stringFromNumber:aData.price];
    }
    else {
        _price.value = [formatter stringFromNumber:self.preferences.calcData.price];
    }
    
    A3TableViewInputElement *discount = [A3TableViewInputElement new];
    discount.title = @"Discount";
    discount.inputType = A3TableViewEntryTypePercent;
	discount.valueType = self.preferences.calcData.discountType;
    discount.prevEnabled = YES;
    discount.nextEnabled = YES;
    discount.onEditingBegin = [self cellTextInputBeginBlock];
    discount.onEditingValueChanged = [self cellTextInputChangedBlock];
    //discount.onEditingFinished = [self cellTextInputFinishedBlock];
    discount.onEditingFinishAll = [self cellTextInputFinishAllBlock];
    discount.doneButtonPressed = [self cellInputDoneButtonPressed];
    discount.identifier = A3TableElementCellType_Discount;
	discount.currencyCode = self.defaultCurrencyCode;

    [elements addObject:discount];
    if (aData) {
        discount.value = [formatter stringFromNumber:aData.discount];
    } else {
        discount.value = [formatter stringFromNumber:self.preferences.calcData.discount];
    }
    
    return elements;
}

-(NSArray *)advancedSectionWithData:(A3SalesCalcData *)aData {
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    
    NSMutableArray *elements = [NSMutableArray new];
    
    A3TableViewInputElement *additional = [A3TableViewInputElement new];
    additional.title = @"Additional Off";
    additional.placeholder = @"Optional";
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
        additional.value = [formatter stringFromNumber:aData.additionalOff];
    } else {
        additional.value = [formatter stringFromNumber:self.preferences.calcData.additionalOff];
    }
    
    A3TableViewInputElement *tax = [A3TableViewInputElement new];
    tax.title = @"Tax";
    tax.placeholder = @"Optional";
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
        tax.value = [formatter stringFromNumber:aData.tax];
    }
    else {
        tax.value = [formatter stringFromNumber:self.preferences.calcData.tax];
    }
    
//    _taxElement = tax;
    [self reloadLocationTax];
    
    if (!_notes) {
        _notes = [A3TextViewElement new];
    }
    _notes.identifier = A3TableElementCellType_Note;
    _notes.value = @"";
    _notes.placeHolder = @"Notes";
    _notes.minHeight = 180.0;
    _notes.currentHeight = 0.0;
    __weak A3SalesCalcMainViewController *weakSelf = self;
    _notes.onEditingBegin = ^(A3TextViewElement *element, UITextView *textView) {
        weakSelf.textViewResponder = textView;
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

- (NSString *)defaultCurrencyCode {
	NSString *currencyCode = [[NSUserDefaults standardUserDefaults] objectForKey:A3SalesCalcCurrencyCode];
	if (!currencyCode) {
		currencyCode = [[NSLocale currentLocale] objectForKey:NSLocaleCurrencyCode];
	}
	return currencyCode;
}

#pragma mark - Input Related
-(CellTextInputBlock)cellTextInputBeginBlock
{
    if (!_cellTextInputBeginBlock) {
		__typeof(self) __weak  weakSelf = self;
        _cellTextInputBeginBlock = ^(A3TableViewInputElement *element, UITextField *textField) {
            weakSelf.firstResponder = textField;
        };
    }
    
    return _cellTextInputBeginBlock;
}

-(CellTextInputBlock)cellTextInputChangedBlock
{
    if (!_cellTextInputChangedBlock) {
        _cellTextInputChangedBlock = ^(A3TableViewInputElement *element, UITextField *textField) {
        };
    }


    return _cellTextInputChangedBlock;
}

// 계산 값 입력을 마친 경우에 호출됨.
-(CellTextInputBlock)cellTextInputFinishAllBlock {
    if (!_cellTextInputFinishAllBlock) {
        __typeof(self) __weak weakSelf = self;
        
        _cellTextInputFinishAllBlock = ^(A3TableViewInputElement *element, UITextField *textField) {
            if (weakSelf.firstResponder == textField) {
                weakSelf.firstResponder = nil;
            }
            
            NSString *inputString = textField.text;
			NSNumberFormatter *formatter = [NSNumberFormatter new];

            switch (element.identifier) {
                case A3TableElementCellType_Price:
                case A3TableElementCellType_Discount:
                case A3TableElementCellType_Additional:
                case A3TableElementCellType_Tax:
                {
                    if (textField.text && textField.text.length!=0) {
                        NSNumber *value = [formatter numberFromString:inputString];
                        element.value = (!value || [value isEqualToNumber:@0]) ? @"" : inputString;
                    }
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
                [weakSelf.preferences.calcData setPrice:[formatter numberFromString:element.value]];
                [weakSelf.preferences.calcData setPriceType:element.valueType];
            }
            else if (element.identifier == A3TableElementCellType_Discount) {
                [weakSelf.preferences.calcData setDiscount:[formatter numberFromString:element.value]];
                [weakSelf.preferences.calcData setDiscountType:element.valueType];
            }
            else if (element.identifier == A3TableElementCellType_Additional) {
                [weakSelf.preferences.calcData setAdditionalOff:[formatter numberFromString:element.value]];
                [weakSelf.preferences.calcData setAdditionalOffType:element.valueType];
            }
            else if (element.identifier == A3TableElementCellType_Tax) {
                [weakSelf.preferences.calcData setTax:[formatter numberFromString:element.value]];
                [weakSelf.preferences.calcData setTaxType:element.valueType];
            }
            else if (element.identifier == A3TableElementCellType_Note) {
                [weakSelf.preferences.calcData setNotes:element.value];
                if ([inputString length] == 0) {
                    textField.placeholder = @"Notes";
                }
                else {
                    textField.placeholder = inputString;
                }
            }

            if (element.valueType == A3TableViewValueTypePercent) {
                NSNumberFormatter *percentFormatter = [NSNumberFormatter new];

                if ((!element || ![element value]) && [inputString length] == 0) {
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
                    if (element.identifier == A3TableElementCellType_Discount || (element.identifier == A3TableElementCellType_Tax && [weakSelf.preferences.calcData shownPriceType] == ShowPriceType_Sale)) {
                        if ([element valueType] == A3TableViewValueTypePercent) {
                            textField.text = [weakSelf.percentFormatter stringFromNumber:@([[formatter numberFromString:element.value] doubleValue]/ 100.0)];
                        }
                        else {
                            textField.text = [weakSelf.currencyFormatter stringFromNumber:[formatter numberFromString:element.value]];
                        }
                    }
                    else {
                        if ([element.value doubleValue] > 0) {
                            if ([element valueType] == A3TableViewValueTypePercent) {
								textField.text = [weakSelf.percentFormatter stringFromNumber:@([[formatter numberFromString:element.value] doubleValue] / 100.0)];
                            }
                            else {
                                textField.text = [weakSelf.currencyFormatter stringFromNumber:[formatter numberFromString:element.value]];
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
                
                switch (element.identifier) {
                    case A3TableElementCellType_Price:
                        [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                        break;
                    case A3TableElementCellType_Discount:
                    case A3TableElementCellType_Additional:
                    case A3TableElementCellType_Tax:
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
                        
                        [weakSelf updateTableViewCell:cell atIndexPath:indexPath textFieldTextToCurrency:currency andPercent:percent];
                    }
                        break;
                }
            }
            
            [weakSelf reloadPercentValuesToTableDataSource];
            [weakSelf saveInputTextData:weakSelf.preferences.calcData];
            
            
            if (!weakSelf.preferences.calcData.price || !weakSelf.preferences.calcData.discount) {
                return;
            }
            
            // 계산 결과 반영.
            [weakSelf.headerView setResultData:weakSelf.preferences.calcData withAnimation:YES];
            [weakSelf setBarButtonsEnable:YES];
            
            // 계산 결과 저장.
            if (NO == [weakSelf.preferences didSaveBefore]) {
                [weakSelf.preferences setOldCalcData:weakSelf.preferences.calcData];
            }
			if (element.identifier == A3TableElementCellType_Note) {
				[weakSelf.tableView setContentOffset:CGPointMake(0, -weakSelf.tableView.contentInset.top) animated:YES];
			}
        };
    }
    
    return _cellTextInputFinishAllBlock;
}

-(BasicBlock)cellInputDoneButtonPressed {
    
    if (!_cellInputDoneButtonPressed) {
        __weak A3SalesCalcMainViewController * weakSelf = self;
        _cellInputDoneButtonPressed = ^(id sender){
            
            if (weakSelf.preferences.calcData == nil) {
                return;
            }

            weakSelf.firstResponder = nil;
            
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
                [self updateTableViewCell:cell atIndexPath:indexPath textFieldTextToCurrency:@([[discount value] doubleValue]) andPercent:[A3SalesCalcCalculator discountPercentForCalcData:self.preferences.calcData]];
            }
        }
            break;

        case A3TableElementCellType_Additional:
        {
            if (!element.value || (element && ([element.value length] == 0 || [element.value isEqualToString:@"0"]))) {
                ((A3JHTableViewEntryCell *)cell).textField.text = @"";
                ((A3JHTableViewEntryCell *)cell).textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Optional"
                                                                                                                   attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:17]} ];
            }
            else {
                A3TableViewInputElement *additional = (A3TableViewInputElement *)element;
                if (additional.valueType == A3TableViewValueTypeCurrency) {
                    [self updateTableViewCell:cell atIndexPath:indexPath textFieldTextToCurrency:@([[additional value] doubleValue]) andPercent:[A3SalesCalcCalculator additionalOffPercentForCalcData:self.preferences.calcData]];
                }
            }
        }
            break;
            
        case A3TableElementCellType_Tax:
        {
            if ([_preferences.calcData shownPriceType] == ShowPriceType_Origin) {
                if (!element.value || (element && ([element.value length] == 0 || [element.value isEqualToString:@"0"]))) {
                    ((A3JHTableViewEntryCell *)cell).textField.text = @"";
                    ((A3JHTableViewEntryCell *)cell).textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Optional"
                                                                                                                       attributes:@{ //NSForegroundColorAttributeName : [UIColor redColor],
                                                                                                                                    NSFontAttributeName : [UIFont systemFontOfSize:17] } ];
                }
                else {
                    A3TableViewInputElement *tax = (A3TableViewInputElement *)element;
                    if (tax.valueType == A3TableViewValueTypeCurrency) {
                        [self updateTableViewCell:cell atIndexPath:indexPath textFieldTextToCurrency:@([[tax value] doubleValue]) andPercent:[A3SalesCalcCalculator taxPercentForCalcData:self.preferences.calcData]];
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
        if ([_preferences.calcData shownPriceType] == ShowPriceType_Sale && (![self.preferences.calcData tax] || [[self.preferences.calcData tax] isEqualToNumber:@0])) {
            [self reloadLocationTax];
        }

        [_headerView setResultData:self.preferences.calcData withAnimation:YES];
        [_headerView setNeedsLayout];
        
        _price.title = _preferences.calcData.shownPriceType == ShowPriceType_Origin ? @"Original Price" : (IS_IPAD ? @"Sale Price with Tax" :    @"Sale Price w/Tax");
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
        return @"KNOWN VALUE";
    }
    
    return nil;
}

-(void)scrollToTopOfTableView {
    if (IS_LANDSCAPE) {
        [UIView beginAnimations:@"KeyboardWillShow" context:nil];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationCurve:7];
        [UIView setAnimationDuration:0.35];
        self.tableView.contentOffset = CGPointMake(0.0, -(self.navigationController.navigationBar.bounds.size.height + [[UIApplication sharedApplication] statusBarFrame].size.width));
        [UIView commitAnimations];
    } else {
        [UIView beginAnimations:@"KeyboardWillShow" context:nil];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationCurve:7];
        [UIView setAnimationDuration:0.35];
        self.tableView.contentOffset = CGPointMake(0.0, -(self.navigationController.navigationBar.bounds.size.height + [[UIApplication sharedApplication] statusBarFrame].size.height));
        [UIView commitAnimations];
    }
}

#pragma mark - etc_countries Rate List
- (NSDictionary *)knownUSTaxes {
	return @{
             @"AL" : @"4",
             @"AK" : @"0",
             @"AZ" : @"6.60",
             @"AR" : @"6",
             @"CA" : @"7.50",
             @"CO" : @"2.90",
             @"CT" : @"6.35",
             @"DE" : @"0",
             @"DC" : @"10",
             @"FL" : @"9",
             @"GA" : @"4",
             @"GU" : @"4",
             @"HI" : @"4",
             @"ID" : @"6",
             @"IL" : @"8.25",
             @"IN" : @"9",
             @"IA" : @"6",
             @"KS" : @"6.30",
             @"KY" : @"6",
             @"LA" : @"4",
             @"ME" : @"7",
             @"MD" : @"6",
             @"MA" : @"7",
             @"MI" : @"6",
             @"MN" : @"10.78",
             @"MS" : @"7",
             @"MO" : @"4.23",
             @"MT" : @"0",
             @"NE" : @"9.50",
             @"NV" : @"6.85",
             @"NH" : @"9",
             @"WY" : @"7",
             @"NJ" : @"5.13",
             @"NM" : @"8.50",
             @"NY" : @"8.50",
             @"NC" : @"5",
             @"ND" : @"5.75",
             @"OH" : @"4.50",
             @"OK" : @"0",
             @"OR" : @"6",
             @"PA" : @"5.50",
             @"PR" : @"8",
             @"RI" : @"10.50",
             @"SC" : @"4",
             @"SD" : @"7",
             @"TN" : @"6.25",
             @"TX" : @"4.70",
             @"UT" : @"9",
             @"VT" : @"5.30",
             @"VA" : @"10",
             @"WA" : @"6",
             @"WV" : @"5",
             @"WI" : @"4",
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
            [self updateTableViewCell:cell atIndexPath:indexPath textFieldTextToCurrency:currency andPercent:percent];
        }
    }
    
    indexPath = [NSIndexPath indexPathForRow:0 inSection:2];
    element = (A3TableViewInputElement *)[self.root elementForIndexPath:indexPath];
    if (element.valueType == A3TableViewValueTypeCurrency) {
        currency = self.preferences.calcData.additionalOff;
        percent = [A3SalesCalcCalculator additionalOffPercentForCalcData:self.preferences.calcData];
        A3JHTableViewEntryCell *cell = (A3JHTableViewEntryCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        if (cell && cell.textField != self.firstResponder) {
            [self updateTableViewCell:cell atIndexPath:indexPath textFieldTextToCurrency:currency andPercent:percent];
        }
    }
    
    indexPath = [NSIndexPath indexPathForRow:1 inSection:2];
    element = (A3TableViewInputElement *)[self.root elementForIndexPath:indexPath];
    if (element.valueType == A3TableViewValueTypeCurrency) {
        currency = self.preferences.calcData.tax;
        percent = [A3SalesCalcCalculator taxPercentForCalcData:self.preferences.calcData];
        A3JHTableViewEntryCell *cell = (A3JHTableViewEntryCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        if (cell && cell.textField != self.firstResponder) {
            [self updateTableViewCell:cell atIndexPath:indexPath textFieldTextToCurrency:currency andPercent:percent];
        }
    }
    else {
        A3JHTableViewEntryCell *cell = (A3JHTableViewEntryCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        if ([self.preferences.calcData shownPriceType] == ShowPriceType_Sale) {
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

- (void)updateTableViewCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath textFieldTextToCurrency:(NSNumber *)amount andPercent:(NSNumber *)percent {
    if ([indexPath section] == 2 && [indexPath row] == 1) {
        if ((!amount || [amount isEqualToNumber:@0]) && [self.preferences.calcData shownPriceType] != ShowPriceType_Sale) {
            ((A3JHTableViewEntryCell *)cell).textField.text = @"";
            return;
        }
    } else {
        if (!amount || [amount isEqualToNumber:@0]) {
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
    [text appendFormat:@" (%@)", [formatter stringFromNumber:@([percent doubleValue] / 100.0)] ];
    
    ((A3JHTableViewEntryCell *)cell).textField.text = text;
}

#pragma mark CLLocationManager stuff

//bool kIsFirstTipCalcGeocodeTemp = YES; // temp
- (void)getReverseGeocode
{
    if(_lm == nil)
        return;
    
	//if (!self.delegate) return;
    
	_lm.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    [_lm startUpdatingLocation];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    if (!_lm) return;

    @autoreleasepool {
        [manager stopUpdatingLocation];
        
        CLGeocoder* geocoder = [[CLGeocoder alloc] init];
        
        [geocoder reverseGeocodeLocation: _lm.location completionHandler:^(NSArray *placemarks, NSError *error) {
            
            NSLog(@"ori------");
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            NSLog(@"%@", placemark.ISOcountryCode);// 1
            NSLog(@"%@", placemark.country);
            NSLog(@"%@", placemark.postalCode);
            NSLog(@"%@", placemark.administrativeArea);//4
            NSLog(@"%@", placemark.subAdministrativeArea);
            NSLog(@"%@", placemark.locality);
            NSLog(@"%@", placemark.subLocality);
            NSLog(@"%@", placemark.thoroughfare);
            NSLog(@"%@", placemark.subThoroughfare);
            NSLog(@"--------");
            
            NSNumber *knownTax = nil;
            if ([placemark.ISOcountryCode isEqualToString:@"US"] &&
                [placemark.administrativeArea length]) {
                NSString *knownTaxString = self.knownUSTaxes[placemark.administrativeArea];
                if ([knownTaxString length]) {
                    knownTax = @([knownTaxString doubleValue]);
                    _locationTax = knownTax;
                    _locationCode = @"US";
                    [self reloadLocationTax];
                    [self.tableView reloadData];
                }
            }
            
            _lm.delegate = nil;
            _lm = nil;
        }];
    }
}

- (void)reloadLocationTax {
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    if (_taxElement && [_locationCode isEqualToString:@"US"]) {
        _taxElement.value = [formatter stringFromNumber:_locationTax];
        self.preferences.calcData.tax = _locationTax;
    }
}

- (A3JHTableViewRootElement *)tableElementRootDataSource {
	return self.root;
}

- (UIViewController *)containerViewController {
	return self;
}

#pragma mark - Currency Select Delegate

- (id <A3SearchViewControllerDelegate>)delegateForCurrencySelector {
	return self;
}

- (void)searchViewController:(UIViewController *)viewController itemSelectedWithItem:(NSString *)selectedItem {

	[[NSUserDefaults standardUserDefaults] setObject:selectedItem forKey:A3SalesCalcCurrencyCode];
	[[NSUserDefaults standardUserDefaults] synchronize];

	[self setCurrencyFormatter:nil];
	self.headerView.currencyFormatter = self.currencyFormatter;

	[self configureTableData];
	[self.tableView reloadData];
	[self.headerView setResultData:self.preferences.calcData withAnimation:NO];
	[self.tableView setContentOffset:CGPointMake(0, -self.tableView.contentInset.top)];
}

- (NSNumberFormatter *)currencyFormatterForTableViewInputElement {
	return self.currencyFormatter;
}

@end
