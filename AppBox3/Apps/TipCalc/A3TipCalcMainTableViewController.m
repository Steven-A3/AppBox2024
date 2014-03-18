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
#import "UIViewController+A3AppCategory.h"
#import "A3RoundedSideButton.h"
#import "TipCalcRecently.h"
#import "A3TipCalcDataManager.h"
#import "A3TipCalcSettingViewController.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+MMDrawerController.h"
#import "A3AppDelegate.h"
#import "A3TipCalcHeaderView.h"
#import "A3NumberKeyboardViewController.h"
#import "A3TipCalcRoundingViewController.h"
#import "A3TipCalcHistoryViewController.h"
#import "NSUserDefaults+A3Defaults.h"
#import "A3CurrencySelectViewController.h"
#import "A3JHTableViewRootElement.h"
#import "A3TableViewCheckMarkElement.h"
#import "A3TableViewInputElement.h"
#import "A3JHTableViewSelectElement.h"
#import "A3JHSelectTableViewController.h"
#import "A3JHTableViewEntryCell.h"
#import "A3PopoverTableViewController.h"
#import "A3DefaultColorDefines.h"
#import "A3ItemSelectListViewController.h"

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


@interface A3TipCalcMainTableViewController () <UITextFieldDelegate, A3TipCalcDataManagerDelegate, A3TipCalcSettingsDelegate, A3TipCalcRoundingViewDelegate, UIPopoverControllerDelegate, A3TipCalcHistorySelectDelegate, A3JHSelectTableViewControllerProtocol>

@property (nonatomic, strong) A3JHTableViewRootElement *tableDataSource;
@property (nonatomic, strong) NSArray * tableSectionTitles;
@property (nonatomic, strong) CellTextInputBlock cellTextInputBeginBlock;
@property (nonatomic, strong) CellTextInputBlock cellTextInputChangedBlock;
@property (nonatomic, strong) CellTextInputBlock cellTextInputFinishedBlock;
@property (nonatomic, strong) BasicBlock cellInputDoneButtonPressed;
@property (nonatomic, strong) id firstResponder;
@property (nonatomic, strong) UIPopoverController * localPopoverController;
@property (nonatomic, strong) A3TipCalcHeaderView * headerView;

@end

@implementation A3TipCalcMainTableViewController
{
    NSArray* _arrMenuButtons;
    UIView* _moreMenuView;
    BOOL _isShowMoreMenu;

    CGFloat _fTableDefaultOffset;
    A3TableViewInputElement *_taxElement;
}

- (id)init {
	self = [super initWithStyle:UITableViewStyleGrouped];
	if (self) {
		
	}
	
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self initialize];
    [self outputAllResultWithAnimation:NO];
    [self.headerView showDetailInfoButton];
    if (![[A3TipCalcDataManager sharedInstance] hasCalcData] && [[A3TipCalcDataManager sharedInstance] isTaxOptionOn]) {
        [[A3TipCalcDataManager sharedInstance] getUSTaxRateByLocation];     // to calledFromAreaTax
    }
    [self refreshMoreButtonState];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)contentSizeDidChange:(NSNotification *)notification {
    [_headerView setNeedsLayout];
}

- (void)initialize {
    [self makeBackButtonEmptyArrow];
    [self leftBarButtonAppsButton];
    [self rightBarButtons];
    self.title = @"Tip Calculator";
    
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.separatorInset = UIEdgeInsetsMake(0.0, IS_IPHONE ? 15.0 : 28.0, 0.0, 0.0);
    self.tableView.separatorColor = COLOR_TABLE_SEPARATOR;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    self.tableView.tableHeaderView = [self headerView];
    
    [A3TipCalcDataManager terminate];
    A3TipCalcDataManager *dataManager = [A3TipCalcDataManager sharedInstance];
    dataManager.delegate = self;

    [self reloadTableDataSource];
    [self registerContentSizeCategoryDidChangeNotification];
}

- (void)disposeInitializedCondition
{
    [_firstResponder resignFirstResponder];
    
    if (IS_IPHONE) {
        [self dismissMoreMenu];
    }
    
    if (self.localPopoverController) {
        [self.localPopoverController dismissPopoverAnimated:YES];
        self.localPopoverController = nil;
    }
}

- (void)setBarButtonsEnable:(BOOL)enable {
    [self.navigationItem.rightBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem *barButton, NSUInteger idx, BOOL *stop) {
        barButton.enabled = enable;
    }];
    self.headerView.detailInfoButton.enabled = enable;
    self.headerView.beforeSplitButton.enabled = enable;
    self.headerView.perPersonButton.enabled = enable;
    self.navigationItem.leftBarButtonItem.enabled = enable;
    
    if (enable) {
        [self refreshMoreButtonState];
    }
}

- (A3TipCalcHeaderView *)headerView
{
    CGRect frame = CGRectZero;
    if (!_headerView) {
        if ([[A3TipCalcDataManager sharedInstance] isSplitOptionOn]) {
            if (IS_IPAD) {
                frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), IS_RETINA ? 192.5 : 193);
            }
            else {
                frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 134);
            }
        }
        else {
            if (IS_IPAD) {
                frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), IS_RETINA ? 157.5 : 158);
            }
            else {
                frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 104);
            }
        }

        _headerView = [[A3TipCalcHeaderView alloc] initWithFrame:frame];
        [_headerView.beforeSplitButton addTarget:self action:@selector(beforeSplitButtonTouchedUp:) forControlEvents:UIControlEventTouchUpInside];
        [_headerView.perPersonButton addTarget:self action:@selector(perPersonButtonTouchedUp:) forControlEvents:UIControlEventTouchUpInside];
        [_headerView.detailInfoButton addTarget:self action:@selector(detailButtonTouchedUp:) forControlEvents:UIControlEventTouchUpInside];
    }
    else {
        frame = _headerView.frame;
        
        if ([[A3TipCalcDataManager sharedInstance] isSplitOptionOn]) {
            if (IS_IPAD) {
                frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), IS_RETINA ? 192.5 : 193);
            }
            else {
                frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 134);
            }
        }
        else {
            if (IS_IPAD) {
                frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), IS_RETINA ? 157.5 : 158);
            }
            else {
                frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 104);
            }
        }
        
        _headerView.frame = frame;
    }
    
    return _headerView;
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
    if ([[A3TipCalcDataManager sharedInstance] isTaxOptionOn]) {
        [sections addObject:@"KNOWN VALUE"];
    }
    // Section 1
    [sections addObject:@""];
    // Section 2
    if ([[A3TipCalcDataManager sharedInstance] isRoundingOptionOn]) {
        [sections addObject:@"ROUNDING METHOD"];
    }
    
    self.tableSectionTitles = sections;
    
    
    // Rows
    NSMutableArray * sectionsRows = [NSMutableArray new];
    if ([[A3TipCalcDataManager sharedInstance] isTaxOptionOn]) {
        [sectionsRows addObject:[self tableSectionDataAtSection:0]];
    }
    
    [sectionsRows addObject:[self tableSectionDataAtSection:1]];
    
    if ([[A3TipCalcDataManager sharedInstance] isRoundingOptionOn]) {
        [sectionsRows addObject:[self tableSectionDataAtSection:2]];
    }
    
    self.tableDataSource.sectionsArray = sectionsRows;
}

- (NSArray *)tableSectionDataAtSection:(NSInteger)section {
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    formatter.minimumFractionDigits = 2;
    NSArray * result;
    
    switch (section) {
        case 0:     // KNOWN VALUE
        {
            A3TableViewCheckMarkElement *subtotal = [A3TableViewCheckMarkElement new];
            subtotal.title = @"Costs After Tax";
            subtotal.identifier = RowElementID_SubTotal;
            subtotal.checked = [[A3TipCalcDataManager sharedInstance] knownValue] == TCKnownValue_Subtotal ? YES : NO;
            
            A3TableViewCheckMarkElement *costsBeforeTax = [A3TableViewCheckMarkElement new];
            costsBeforeTax.title = @"Costs Before Tax";
            costsBeforeTax.identifier = RowElementID_CostsBeforeTax;
            costsBeforeTax.checked = [[A3TipCalcDataManager sharedInstance] knownValue] == TCKnownValue_CostsBeforeTax ? YES : NO;
            
            result = @[subtotal, costsBeforeTax];
        }
            break;
            
        case 1:     // input Section
        {
            NSMutableArray *elements = [NSMutableArray new];
            A3TableViewInputElement *costs = [A3TableViewInputElement new];
            if ([[A3TipCalcDataManager sharedInstance].tipCalcData.showTax boolValue]) {
                costs.title = [[A3TipCalcDataManager sharedInstance] knownValue] == TCKnownValue_Subtotal ? @"Costs After Tax" : @"Costs Before Tax";
            }
            else {
                costs.title = @"Cost";
            }
            
            costs.value = [formatter stringFromNumber:[[A3TipCalcDataManager sharedInstance].tipCalcData costs]];
            costs.inputType = A3TableViewEntryTypeCurrency;
            costs.bigButton1Type = A3TableViewBigButtonTypeCurrency;
            costs.bigButton2Type = A3TableViewBigButtonTypeCalculator;
            costs.prevEnabled = NO;
            costs.nextEnabled = YES;
            costs.valueType = A3TableViewValueTypeCurrency;
            costs.onEditingBegin = [self cellTextInputBeginBlock];
            costs.onEditingValueChanged = [self cellTextInputChangedBlock];
            costs.onEditingFinished = [self cellTextInputFinishedBlock];
            costs.doneButtonPressed = [self cellInputDoneButtonPressed];
            costs.identifier = RowElementID_Costs;
            [elements addObject:costs];

            if ([[A3TipCalcDataManager sharedInstance] isTaxOptionOn]) {
                A3TableViewInputElement *tax = [A3TableViewInputElement new];
                tax.title = @"Tax";
                tax.value = [formatter stringFromNumber:[[A3TipCalcDataManager sharedInstance].tipCalcData tax]];
                tax.inputType = A3TableViewEntryTypeCurrency;
                tax.bigButton1Type = A3TableViewBigButtonTypePercent;
                tax.bigButton2Type = A3TableViewBigButtonTypeCurrency;
                tax.prevEnabled = YES;
                tax.nextEnabled = YES;
                tax.valueType = [[A3TipCalcDataManager sharedInstance].tipCalcData.isPercentTax boolValue] ? A3TableViewValueTypePercent : A3TableViewValueTypeCurrency;
                tax.onEditingBegin = [self cellTextInputBeginBlock];
                tax.onEditingValueChanged = [self cellTextInputChangedBlock];
                tax.onEditingFinished = [self cellTextInputFinishedBlock];
                tax.doneButtonPressed = [self cellInputDoneButtonPressed];
                tax.identifier = RowElementID_Tax;
                _taxElement = tax;
                [elements addObject:tax];
            }

            A3TableViewInputElement *tip = [A3TableViewInputElement new];
            tip.title = @"Tip";
            tip.value = [formatter stringFromNumber:[[A3TipCalcDataManager sharedInstance].tipCalcData tip]];
            tip.inputType = A3TableViewEntryTypeCurrency;
            tip.bigButton1Type = A3TableViewBigButtonTypePercent;
            tip.bigButton2Type = A3TableViewBigButtonTypeCurrency;
            tip.prevEnabled = YES;
            tip.nextEnabled = YES;
            tip.valueType = [[A3TipCalcDataManager sharedInstance].tipCalcData.isPercentTip boolValue] ? A3TableViewValueTypePercent : A3TableViewValueTypeCurrency;
            tip.onEditingBegin = [self cellTextInputBeginBlock];
            tip.onEditingValueChanged = [self cellTextInputChangedBlock];
            tip.onEditingFinished = [self cellTextInputFinishedBlock];
            tip.doneButtonPressed = [self cellInputDoneButtonPressed];
            tip.identifier = RowElementID_Tip;
            [elements addObject:tip];

            if ([[A3TipCalcDataManager sharedInstance] isSplitOptionOn]) {
                A3TableViewInputElement *split = [A3TableViewInputElement new];
                split.title = @"Split";
                split.value = [formatter stringFromNumber:[[A3TipCalcDataManager sharedInstance].tipCalcData split]];
                split.inputType = A3TableViewEntryTypeSimpleNumber;
                split.valueType = A3TableViewValueTypeNumber;
                split.bigButton1Type = A3TableViewBigButtonTypePercent;
                split.bigButton2Type = A3TableViewBigButtonTypeCurrency;
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
            value.title = @"Value";
            value.items = @[@"Tip", @"Total", @"Total Per Person", @"Tip Per Person"];
            value.selectedIndex = [[A3TipCalcDataManager sharedInstance] roundingMethodValue];
            value.identifier = RowElementID_Value;
            
            A3JHTableViewSelectElement * option = [A3JHTableViewSelectElement new];
            option.title = @"Option";
            option.items = @[@"Exact", @"Up", @"Down", @"Off"];
            option.selectedIndex = [[A3TipCalcDataManager sharedInstance] roundingMethodOption];
            option.identifier = RowElementID_Option;
            result = @[value, option];
        }
            break;
            
        default:
            break;
    }
    
    return result;
}


-(void)scrollToTopOfTableView {
    if (IS_LANDSCAPE) {
        [UIView beginAnimations:@"KeyboardWillShow" context:nil];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationCurve:7];
        [UIView setAnimationDuration:0.35];
        self.tableView.contentOffset = CGPointMake(0.0, CGPointMake(0.0, -(self.navigationController.navigationBar.bounds.size.height + [[UIApplication sharedApplication] statusBarFrame].size.width)).y);
        [UIView commitAnimations];
    }
    else {
        [UIView beginAnimations:@"KeyboardWillShow" context:nil];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationCurve:7];
        [UIView setAnimationDuration:0.35];
        self.tableView.contentOffset = CGPointMake(0.0, CGPointMake(0.0, -(self.navigationController.navigationBar.bounds.size.height + [[UIApplication sharedApplication] statusBarFrame].size.height)).y);
        [UIView commitAnimations];
    }
}

#pragma mark - Table InputElement Manipulate Blocks
-(CellTextInputBlock)cellTextInputBeginBlock
{
    if (!_cellTextInputBeginBlock) {
        __weak A3TipCalcMainTableViewController * weakSelf = self;
        _cellTextInputBeginBlock = ^(A3TableViewInputElement *element, UITextField *textField) {
            weakSelf.firstResponder = textField;
            [weakSelf dismissMoreMenu];
        };
    }
    
    return _cellTextInputBeginBlock;
}

-(CellTextInputBlock)cellTextInputChangedBlock
{
    if (!_cellTextInputChangedBlock) {
//        __weak A3TipCalcViewController * weakSelf = self;
        _cellTextInputChangedBlock = ^(A3TableViewInputElement *element, UITextField *textField) {
            
        };
    }
    
    return _cellTextInputChangedBlock;
}

-(CellTextInputBlock)cellTextInputFinishedBlock
{
    if (!_cellTextInputFinishedBlock) {
        __weak A3TipCalcMainTableViewController * weakSelf = self;
        
        _cellTextInputFinishedBlock = ^(A3TableViewInputElement *element, UITextField *textField) {
            if (weakSelf.firstResponder == textField) {
                weakSelf.firstResponder = nil;
            }

//            if ([textField.text length] > 0) {
//                switch (element.identifier) {
//                    case RowElementID_Costs:
//                    {
//                        element.value = textField.text;
//                        [[A3TipCalcDataManager sharedInstance] setTipCalcDataCost:@([textField.text doubleValue])];
//                    }
//                        break;
//                    case RowElementID_Tax:
//                    {
//                        element.value = [textField text];
//                        [[A3TipCalcDataManager sharedInstance] setTipCalcDataTax:@([textField.text doubleValue])
//                                                                   isPercentType:[element valueType] == A3TableViewValueTypePercent ? YES : NO ];
//                    }
//                        break;
//                    case RowElementID_Tip:
//                    {
//                        element.value = [textField text];
//                        [[A3TipCalcDataManager sharedInstance] setTipCalcDataTip:@([textField.text doubleValue])
//                                                                   isPercentType:[element valueType] == A3TableViewValueTypePercent ? YES : NO];
//                    }
//                        break;
//                    case RowElementID_Split:
//                    {
//                        //element.value = @([textField.text doubleValue]);
//                        element.value = [textField text];
//                        [[A3TipCalcDataManager sharedInstance] setTipCalcDataSplit:@([textField.text doubleValue])];
//                    }
//                        break;
//                        
//                    default:
//                        break;
//                }
//            }
            NSNumber *value;
            if ([textField.text length] == 0) {
                value = @([[element value] doubleValue]);
            } else {
                value = @([textField.text doubleValue]);
                element.value = [NSString stringWithString:textField.text];
            }
            
            switch (element.identifier) {
                case RowElementID_Costs:
                {
                    [[A3TipCalcDataManager sharedInstance] setTipCalcDataCost:value];
                }
                    break;
                case RowElementID_Tax:
                {
                    [[A3TipCalcDataManager sharedInstance] setTipCalcDataTax:value
                                                               isPercentType:[element valueType] == A3TableViewValueTypePercent ? YES : NO ];
                }
                    break;
                case RowElementID_Tip:
                {
                    [[A3TipCalcDataManager sharedInstance] setTipCalcDataTip:value
                                                               isPercentType:[element valueType] == A3TableViewValueTypePercent ? YES : NO];
                }
                    break;
                case RowElementID_Split:
                {
                    [[A3TipCalcDataManager sharedInstance] setTipCalcDataSplit:value];
                }
                    break;
                    
                default:
                    break;
            }
            
            [weakSelf.headerView showDetailInfoButton];
            [weakSelf.headerView setResult:[A3TipCalcDataManager sharedInstance].tipCalcData withAnimation:YES];
            [weakSelf refreshMoreButtonState];
			[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
        };
    }
    
    return _cellTextInputFinishedBlock;
}

-(BasicBlock)cellInputDoneButtonPressed {
    if (!_cellInputDoneButtonPressed) {
        __weak A3TipCalcMainTableViewController * weakSelf = self;
        _cellInputDoneButtonPressed = ^(id sender){
            if ([[A3TipCalcDataManager sharedInstance].tipCalcData.costs doubleValue] > 0 && [[A3TipCalcDataManager sharedInstance].tipCalcData.tip doubleValue] > 0) {
                [weakSelf scrollToTopOfTableView];
            }
        };
    }
    
    return _cellInputDoneButtonPressed;
}


#pragma mark - Delegate
#pragma mark Settings
- (void)tipCalcSettingsChanged {
    //    [_headerView layoutIfNeeded];
    [_headerView setResult:[A3TipCalcDataManager sharedInstance].tipCalcData withAnimation:YES];
    //    [UIView animateWithDuration:0.3 animations:^{
    self.tableView.tableHeaderView = [self headerView];
    [self reloadTableDataSource];
    [self.tableView reloadData];
    [_headerView showDetailInfoButton];
    //    }];
}

- (void)dismissTipCalcSettingsViewController {
    [self setBarButtonsEnable:YES];
}

#pragma mark A3TipCalcHistorySelectDelegate
- (void)didSelectHistoryData:(TipCalcHistory *)aHistory {
    [[A3TipCalcDataManager sharedInstance] historyToRecently:aHistory];

    self.tableView.tableHeaderView = [self headerView];
    [_headerView setResult:[A3TipCalcDataManager sharedInstance].tipCalcData withAnimation:YES];
    [self reloadTableDataSource];
    [self.tableView reloadData];
}

- (void)clearSelectHistoryData {

}

- (void)dismissHistoryViewController {
    [self setBarButtonsEnable:YES];
}

- (void)tipCalcRoundingChanged {
    [_headerView setResult:[A3TipCalcDataManager sharedInstance].tipCalcData withAnimation:YES];
    [self reloadTableDataSource];
    [self.tableView reloadData];
}

#pragma mark A3SelectTableViewController Delegate
-(void)selectTableViewController:(A3JHSelectTableViewController *)viewController selectedItemIndex:(NSInteger)index indexPathOrigin:(NSIndexPath *)indexPathOrigin {
    [self setBarButtonsEnable:YES];
    viewController.root.selectedIndex = index;
    
    if ([viewController.root.title isEqualToString:@"Option"]) {
        [A3TipCalcDataManager sharedInstance].roundingMethodOption = index;
        
        NSNumber * result = [[A3TipCalcDataManager sharedInstance] numberByRoundingMethodForValue:@0.4];
        NSLog(@"result: %@", result);
        
        result = [[A3TipCalcDataManager sharedInstance] numberByRoundingMethodForValue:@0.5];
        NSLog(@"result: %@", result);
        
        result = [[A3TipCalcDataManager sharedInstance] numberByRoundingMethodForValue:@0.6];
        NSLog(@"result: %@", result);
    }
    else {
        [A3TipCalcDataManager sharedInstance].roundingMethodValue = index;
    }
    
    [self.headerView showDetailInfoButton];
    [self.headerView setResult:[A3TipCalcDataManager sharedInstance].tipCalcData withAnimation:YES];
    [self refreshMoreButtonState];
    [self.tableView reloadData];
}

#pragma mark Location Manager Delegate
- (void)dataManager:(id)manager taxValueUpdated:(NSNumber *)taxRate {
    NSNumberFormatter *formatter = [NSNumberFormatter new];
	[[A3TipCalcDataManager sharedInstance] setTipCalcDataTax:taxRate isPercentType:YES];
    _taxElement.value = [formatter stringFromNumber:taxRate];
    _taxElement.valueType = A3TableViewValueTypePercent;

	[self.tableView reloadData];
}

#pragma mark - private
- (void)outputAllResultWithAnimation:(BOOL)animate
{
    [_headerView setResult:[A3TipCalcDataManager sharedInstance].tipCalcData withAnimation:animate];
    [self reloadTableDataSource];
    [self.tableView reloadData];
    
    if ([[A3TipCalcDataManager sharedInstance] tipSplitOption] == TCTipSplitOption_BeforeSplit) {
        _headerView.beforeSplitButton.selected = YES;
        _headerView.perPersonButton.selected = NO;
    }
    else {
        _headerView.beforeSplitButton.selected = NO;
        _headerView.perPersonButton.selected = YES;
    }
}

- (NSString*)percentFormattedStringTipCalc:(NSString*)aNum
{
    NSString* strRst = [aNum stringByReplacingOccurrencesOfString:@"%" withString:@""];
    strRst = [NSString stringWithFormat:@"%@%%", strRst];
    
    return strRst;
}

#pragma mark - button event
- (void)detailButtonTouchedUp:(UIButton* )aSender
{
    if (self.localPopoverController) {
        [self disposeInitializedCondition];
        return;
    }
    
    if (self.firstResponder) {
        [self.firstResponder resignFirstResponder];
        return;
    }
    
    A3PopoverTableViewController * popoverTableView = [[A3PopoverTableViewController alloc] initWithStyle:UITableViewStylePlain];
    NSMutableArray *titles = [NSMutableArray new];
    NSMutableArray *details = [NSMutableArray new];
    NSMutableArray *values;
    
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    formatter.numberStyle = NSNumberFormatterCurrencyStyle;
    //formatter.roundingMode = NSNumberFormatterRoundCeiling;
//    [formatter setMaximumFractionDigits:3];
//    [formatter setRoundingMode:NSNumberFormatterRoundHalfUp];
//    [formatter setRoundingIncrement:@3];
//    test = [formatter stringFromNumber:[[A3TipCalcDataManager sharedInstance] costBeforeTax]];
//    NSLog(@"test : %@", test);
//
//    [formatter setRoundingMode:NSNumberFormatterRoundHalfDown];
//    test = [formatter stringFromNumber:[[A3TipCalcDataManager sharedInstance] costBeforeTax]];
//    NSLog(@"test : %@", test);
//    
//    [formatter setRoundingMode:NSNumberFormatterRoundHalfEven];
//    test = [formatter stringFromNumber:[[A3TipCalcDataManager sharedInstance] costBeforeTax]];
//    NSLog(@"test : %@", test);
    
    if ([[A3TipCalcDataManager sharedInstance] tipSplitOption] == TCTipSplitOption_BeforeSplit) {
        values = [NSMutableArray new];
//        [values addObject:[[[A3TipCalcDataManager sharedInstance] costBeforeTax] stringValue]];
//        [values addObject:[[[A3TipCalcDataManager sharedInstance] taxValue] stringValue]];
        [values addObject:[formatter stringFromNumber:[[A3TipCalcDataManager sharedInstance] costBeforeTax]]];
        [values addObject:[formatter stringFromNumber:[[A3TipCalcDataManager sharedInstance] taxValue]]];
        [titles addObject:@[@"Costs", @"Tax"]];
        [details addObject:values];
        
        values = [NSMutableArray new];
//        [values addObject:[[[A3TipCalcDataManager sharedInstance] subtotal] stringValue]];
//        [values addObject:[[[A3TipCalcDataManager sharedInstance] tipValue] stringValue]];
        [values addObject:[formatter stringFromNumber:[[A3TipCalcDataManager sharedInstance] subtotal]]];
        [values addObject:[formatter stringFromNumber:[[A3TipCalcDataManager sharedInstance] tipValue]]];
        [titles addObject:@[@"Subtotal", @"Tip"]];
        [details addObject:values];
        
//        values = [NSMutableArray new];
//        [values addObject:[[[A3TipCalcDataManager sharedInstance] totalBeforeSplit] stringValue]];
//        [titles addObject:@[@"Total Before Split"]];
//        [details addObject:values];
    }
    else if ([[A3TipCalcDataManager sharedInstance] tipSplitOption] == TCTipSplitOption_PerPerson) {
        values = [NSMutableArray new];
//        [values addObject:[[[A3TipCalcDataManager sharedInstance] costBeforeTaxWithSplit] stringValue]];
//        [values addObject:[[[A3TipCalcDataManager sharedInstance] taxValueWithSplit] stringValue]];
        [values addObject:[formatter stringFromNumber:[[A3TipCalcDataManager sharedInstance] costBeforeTaxWithSplit]]];
        [values addObject:[formatter stringFromNumber:[[A3TipCalcDataManager sharedInstance] taxValueWithSplit]]];
        [titles addObject:@[@"Costs", @"Tax"]];
        [details addObject:values];
        
        values = [NSMutableArray new];
//        [values addObject:[[[A3TipCalcDataManager sharedInstance] subtotalWithSplit] stringValue]];
//        [values addObject:[[[A3TipCalcDataManager sharedInstance] tipValueWithSplit] stringValue]];
        [values addObject:[formatter stringFromNumber:[[A3TipCalcDataManager sharedInstance] subtotalWithSplit]]];
        [values addObject:[formatter stringFromNumber:[[A3TipCalcDataManager sharedInstance] tipValueWithSplit]]];
        [titles addObject:@[@"Subtotal", @"Tip"]];
        [details addObject:values];
        
//        values = [NSMutableArray new];
//        [values addObject:[[[A3TipCalcDataManager sharedInstance] totalPerPerson] stringValue]];
//        [titles addObject:@[@"Total Per Person"]];
//        [details addObject:values];
    }
    [popoverTableView setSectionArrayForTitles:titles withDetails:details];

    self.localPopoverController = [[UIPopoverController alloc] initWithContentViewController:popoverTableView];
    self.localPopoverController.backgroundColor = [UIColor whiteColor];
    self.localPopoverController.delegate = self;
    [self.localPopoverController setPopoverContentSize:CGSizeMake(224, 266) animated:NO];
    [self.localPopoverController presentPopoverFromRect:aSender.frame
                                                 inView:aSender.superview
                               permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    [self.localPopoverController setPopoverContentSize:CGSizeMake(224, popoverTableView.tableView.contentSize.height)
                                              animated:NO];
    [self setBarButtonsEnable:NO];
}

- (void)beforeSplitButtonTouchedUp:(id)aSender
{
    _headerView.beforeSplitButton.selected = YES;
    _headerView.perPersonButton.selected = NO;
    [A3TipCalcDataManager sharedInstance].tipSplitOption = TCTipSplitOption_BeforeSplit;
    
    [self outputAllResultWithAnimation:YES];
}

- (void)perPersonButtonTouchedUp:(id)aSender {
    _headerView.beforeSplitButton.selected = NO;
    _headerView.perPersonButton.selected = YES;
    [A3TipCalcDataManager sharedInstance].tipSplitOption = TCTipSplitOption_PerPerson;
    
    [self outputAllResultWithAnimation:YES];
}

#pragma mark - keyboard Stuff
- (void)changePlaceHolder
{
    NSString* strPlaceHoler = @"0%";
    if(![[A3TipCalcDataManager sharedInstance].tipCalcData.isPercentTax boolValue])
        strPlaceHoler = [NSString stringWithFormat:@"%@0", [A3TipCalcDataManager sharedInstance].tipCalcData.currenySymbol];
    
    
    ((UITextField *)_firstResponder).attributedPlaceholder = [[NSAttributedString alloc] initWithString:strPlaceHoler attributes:@{NSForegroundColorAttributeName: kColorPlaceHolder}];
}

#pragma mark - currencyselected view stuff

- (void)searchViewController:(UIViewController *)viewController itemSelectedWithItem:(NSString *)selectedItem {
    
    [A3TipCalcDataManager sharedInstance].tipCalcData.currenyCode = selectedItem;
    [A3TipCalcDataManager sharedInstance].tipCalcData.currenySymbol = [[A3TipCalcDataManager sharedInstance] currencySymbolFromCode:selectedItem];
    
    [self outputAllResultWithAnimation:YES];
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
        ((A3JHTableViewEntryCell *)cell).textField.textColor = COLOR_TABLE_DETAIL_TEXTLABEL;
        ((A3JHTableViewEntryCell *)cell).textField.font = [UIFont systemFontOfSize:17];
    }
    
    switch (element.identifier) {
        case RowElementID_Value:
            break;
        case RowElementID_Option:
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
                [A3TipCalcDataManager sharedInstance].knownValue = TCKnownValue_Subtotal;
            }
            else {
                subtotal.checked = NO;
                beforeTax.checked = YES;
                subtotalCell.accessoryType = UITableViewCellAccessoryNone;
                beforeTaxCell.accessoryType = UITableViewCellAccessoryCheckmark;
                [A3TipCalcDataManager sharedInstance].knownValue = RowElementID_CostsBeforeTax;
            }
            
            if ([[A3TipCalcDataManager sharedInstance].tipCalcData.beforeSplit intValue] == 0) {
                _headerView.beforeSplitButton.selected = YES;
                _headerView.perPersonButton.selected = NO;
            }
            else {
                _headerView.beforeSplitButton.selected = NO;
                _headerView.perPersonButton.selected = YES;
            }
            
            [_headerView setResult:[A3TipCalcDataManager sharedInstance].tipCalcData withAnimation:YES];
            

            UITableViewCell *costs = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
            costs.textLabel.text = [[A3TipCalcDataManager sharedInstance] knownValue] == TCKnownValue_Subtotal ? @"Costs After Tax" : @"Costs Before Tax";
        }
            break;

        case RowElementID_Costs:
        case RowElementID_Tax:
        case RowElementID_Tip:
        case RowElementID_Split:
        {
            A3JHTableViewEntryCell * cell = (A3JHTableViewEntryCell *)[tableView cellForRowAtIndexPath:indexPath];
            [cell.textField becomeFirstResponder];
        }
            break;
            
        case RowElementID_Value:
        case RowElementID_Option:
        {
            A3JHTableViewSelectElement *selectItem = (A3JHTableViewSelectElement *)[self.tableDataSource elementForIndexPath:indexPath];
            A3ItemSelectListViewController *selectTableViewController = [[A3ItemSelectListViewController alloc] initWithStyle:UITableViewStyleGrouped];
            selectTableViewController.root = selectItem;
            selectTableViewController.delegate = self;
            selectTableViewController.indexPathOfOrigin = indexPath;
            if (IS_IPHONE) {
                [self.navigationController pushViewController:selectTableViewController animated:YES];
            }
            else {
                [self presentSubViewController:selectTableViewController];
            }
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - apps & more button stuff
- (void)appsButtonAction {
	@autoreleasepool {
        [self disposeInitializedCondition];

		if (IS_IPHONE) {
			[self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
            
			if ([_moreMenuView superview]) {
                [self rightBarButtons];
			}
		}
        else {
			[[[A3AppDelegate instance] rootViewController] toggleLeftMenuViewOnOff];
		}
	}
}

- (void)moreButtonAction:(UIButton *)button {
    @autoreleasepool {
        [self disposeInitializedCondition];
        
        UIBarButtonItem *save = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(saveToHistoryAndInitialize:)];
        UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonAction:)];
        self.navigationItem.rightBarButtonItems = @[done, save];
        
        _arrMenuButtons = @[self.shareButton, [self historyButton:NULL], self.settingsButton];
        _moreMenuView = [self presentMoreMenuWithButtons:_arrMenuButtons tableView:self.tableView];
        _isShowMoreMenu = YES;
        
        [self refreshMoreButtonState];
    };
}

- (void)doneButtonAction:(id)button {
	@autoreleasepool {
		[self dismissMoreMenu];
	}
}

- (void)dismissMoreMenu {
	@autoreleasepool {
		if ( !_isShowMoreMenu || IS_IPAD ) return;
        
		[self moreMenuDismissAction:[[self.view gestureRecognizers] lastObject] ];
	}
}

- (void)moreMenuDismissAction:(UITapGestureRecognizer *)gestureRecognizer {
	@autoreleasepool {
		if (!_isShowMoreMenu) return;
        
		_isShowMoreMenu = NO;
        
		[self rightButtonMoreButton];
		[self dismissMoreMenuView:_moreMenuView scrollView:self.tableView];
		[self.view removeGestureRecognizer:gestureRecognizer];
	}
}

- (void)rightBarButtons {
    if (IS_IPHONE) {
        UIImage *image = [UIImage imageNamed:@"more"];
        UIBarButtonItem *moreButtonItem = [[UIBarButtonItem alloc] initWithImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStylePlain target:self action:@selector(moreButtonAction:)];
        UIBarButtonItem *saveItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(saveToHistoryAndInitialize:)];
        self.navigationItem.rightBarButtonItems = @[moreButtonItem, saveItem];
    }
    else {
        self.navigationItem.hidesBackButton = YES;
        
        UIBarButtonItem *share = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"share"] style:UIBarButtonItemStylePlain target:self action:@selector(shareButtonAction:)];
        UIBarButtonItem *saveItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(saveToHistoryAndInitialize:)];
        UIBarButtonItem *history = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"history"] style:UIBarButtonItemStylePlain target:self action:@selector(historyButtonAction:)];
        UIBarButtonItem *settings = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"general"] style:UIBarButtonItemStylePlain target:self action:@selector(settingsButtonAction:)];
        UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        space.width = 24.0;
        
        self.navigationItem.rightBarButtonItems = @[settings, space, history, saveItem, space, share];
    }
}

- (void)shareButtonAction:(id)sender {
	@autoreleasepool {
        if (self.localPopoverController) {
            [self disposeInitializedCondition];
            return;
        }
        
        [self disposeInitializedCondition];

        
        NSString *activityItem = [[A3TipCalcDataManager sharedInstance] sharedData];

        self.localPopoverController = [self presentActivityViewControllerWithActivityItems:@[activityItem] fromBarButtonItem:sender];
        self.localPopoverController.delegate = self;
        if (IS_IPAD) {
            [self setBarButtonsEnable:NO];
        }
    }
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    [self setBarButtonsEnable:YES];
    
    self.localPopoverController = nil;
}

- (void)historyButtonAction:(UIButton *)button {
	@autoreleasepool {
        [self disposeInitializedCondition];
        [self setBarButtonsEnable:NO];
        
        A3TipCalcHistoryViewController* viewController = [[A3TipCalcHistoryViewController alloc] init];
        viewController.delegate = self;
        [self presentSubViewController:viewController];
	}
}

- (void)settingsButtonAction:(UIButton *)button {
	@autoreleasepool {
        [self disposeInitializedCondition];\
        [self setBarButtonsEnable:NO];
        
//		A3TipCalcSettingsViewController *viewController = [[A3TipCalcSettingsViewController alloc] initWithRoot:nil];
//        viewController.delegate = self;
//		[self presentSubViewController:viewController];
		A3TipCalcSettingViewController *viewController = [[A3TipCalcSettingViewController alloc] initWithStyle:UITableViewStyleGrouped];
        viewController.delegate = self;
		[self presentSubViewController:viewController];
	}
}

- (void)saveToHistoryAndInitialize:(id)sender {
    [self disposeInitializedCondition];
    
    [[A3TipCalcDataManager sharedInstance] saveToHistory];
    
    if ([[A3TipCalcDataManager sharedInstance] isTaxOptionOn]) {
        [[A3TipCalcDataManager sharedInstance] getUSTaxRateByLocation];     // to calledFromAreaTax
    }
    
    // Initailize
    [self.headerView showDetailInfoButton];
    //[self.headerView setResult:[[A3TipCalcDataManager sharedInstance] tipCalcData] withAnimation:YES];
    self.tableView.tableHeaderView = self.headerView;
    [self.headerView setResult:nil withAnimation:YES];
    [self reloadTableDataSource];
    [self.tableView reloadData];
    [self refreshMoreButtonState];
}

- (void)refreshMoreButtonState {
    if (IS_IPHONE) {
        UIBarButtonItem *save = [self.navigationItem.rightBarButtonItems objectAtIndex:1];
        save.enabled = [[A3TipCalcDataManager sharedInstance].tipCalcData.costs isEqualToNumber:@0] ? NO : YES;
        if (_isShowMoreMenu) {
            UIBarButtonItem *share = [_arrMenuButtons objectAtIndex:0];
            share.enabled = [[A3TipCalcDataManager sharedInstance].tipCalcData.costs isEqualToNumber:@0] ? NO : YES;
        }
    }
    else {
        UIBarButtonItem *save = [self.navigationItem.rightBarButtonItems objectAtIndex:3];
        save.enabled = [[A3TipCalcDataManager sharedInstance].tipCalcData.costs isEqualToNumber:@0] ? NO : YES;
        UIBarButtonItem *share = [self.navigationItem.rightBarButtonItems objectAtIndex:5];
        share.enabled = [[A3TipCalcDataManager sharedInstance].tipCalcData.costs isEqualToNumber:@0] ? NO : YES;
    }
    
}

@end
