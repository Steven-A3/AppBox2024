//
//  A3LoanCalcLoanDetailViewController.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 12. 11..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3LoanCalcLoanDetailViewController.h"
#import "A3LoanCalcSelectFrequencyViewController.h"
#import "A3LoanCalcExtraPaymentViewController.h"
#import "A3LoanCalcMonthlyDataViewController.h"
#import "A3LoanCalcTextInputCell.h"
#import "LoanCalcData+Calculation.h"
#import "LoanCalcString.h"
#import "LoanCalcPreference.h"
#import "A3AppDelegate.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+LoanCalcAddtion.h"
#import "A3KeyboardProtocol.h"
#import "UIViewController+A3AppCategory.h"
#import "A3LoanCalcLoanGraphCell.h"
#import "A3NumberKeyboardViewController.h"

@interface A3LoanCalcLoanDetailViewController () <LoanCalcSelectFrequencyDelegate, LoanCalcExtraPaymentDelegate, A3KeyboardDelegate, UITextFieldDelegate>
{
    BOOL _isTotalMode;
    NSIndexPath *currentIndexPath;
    BOOL _isLoanCalcEdited;
}

@property (nonatomic, strong) NSMutableArray *calcItems;
@property (nonatomic, strong) NSMutableArray *extraPaymentItems;

@end

@implementation A3LoanCalcLoanDetailViewController

NSString *const A3LoanCalcSelectCellID2 = @"A3LoanCalcSelectCell";
NSString *const A3LoanCalcTextInputCellID2 = @"A3LoanCalcTextInputCell";
NSString *const A3LoanCalcLoanGraphCellID2 = @"A3LoanCalcLoanGraphCell";

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
    
    [self makeBackButtonEmptyArrow];

    // init loan
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.contentInset = UIEdgeInsetsMake(-1, 0, 36, 0);
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 2)];
    line.backgroundColor = [UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0];
    line.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.tableView addSubview:line];
    
    // init
    _isTotalMode = NO;
    [self.percentFormatter setMaximumFractionDigits:3];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardHide:) name:UIKeyboardWillHideNotification object:nil];
 
    [self registerContentSizeCategoryDidChangeNotification];
}

- (void)contentSizeDidChange:(NSNotification *) notification
{
    [self.tableView reloadData];
}

/*
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if (![self.navigationController.viewControllers containsObject:self]) {
        //pop this controller
        if (_isLoanCalcEdited) {
            
            if (_delegate && [_delegate respondsToSelector:@selector(didEditedLoanData:)]) {
                [_delegate didEditedLoanData:_loanData];
            }
        }
    }
}
 */

-(void)willMoveToParentViewController:(UIViewController *)parent {
    NSLog(@"This VC has has been pushed popped OR covered");
    
    if (parent) {
        NSLog(@"LoanCalc Detail -> pushed");
    }
    else {
        NSLog(@"LoanCalc Detail -> pushed");
        
        if (_isLoanCalcEdited) {
            
            if (_delegate && [_delegate respondsToSelector:@selector(didEditedLoanData:)]) {
                [_delegate didEditedLoanData:_loanData];
            }
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)onKeyboardHide:(NSNotification *)notification
{
    //keyboard will hide
    NSLog(@"noti received:%@", notification.name);
    
    self.tableView.contentOffset = CGPointMake(0, -64);
}

- (NSMutableArray *)calcItems
{
    if (!_calcItems) {
        _calcItems = [[NSMutableArray alloc] initWithArray:[LoanCalcMode compareCalculateItemsForDownPaymentEnabled:_loanData.showDownPayment]];
    }
    
    return _calcItems;
}

- (NSMutableArray *)extraPaymentItems
{
    if (!_extraPaymentItems) {
        _extraPaymentItems = [[NSMutableArray alloc] initWithArray:[LoanCalcMode extraPaymentTypes]];
    }
    
    return _extraPaymentItems;
}

- (void)monthlyButtonAction:(UIButton *)button
{
    if (_isTotalMode) {
        _isTotalMode = NO;
        
        [self displayLoanGraph];
    }
}

- (void)infoButtonAction:(UIButton *)button
{
    UIStoryboard *stroyBoard = (IS_IPHONE) ? [UIStoryboard storyboardWithName:@"LoanCalculatorPhoneStoryBoard" bundle:nil] : [UIStoryboard storyboardWithName:@"LoanCalculatorPadStoryBoard" bundle:nil];
    A3LoanCalcMonthlyDataViewController *viewController = [stroyBoard instantiateViewControllerWithIdentifier:@"A3LoanCalcMonthlyDataViewController"];
    viewController.loanData = _loanData;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)totalButtonAction:(UIButton *)button
{
    if (!_isTotalMode) {
        _isTotalMode = YES;
        
        [self displayLoanGraph];
    }
}

- (void)clearEverything {
	@autoreleasepool {
		[self.firstResponder resignFirstResponder];
		[self setFirstResponder:nil];
	}
}

- (void)presentSubViewController:(UIViewController *)viewController {
	if (IS_IPHONE) {
        [self.navigationController pushViewController:viewController animated:YES];
        /*
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
		[self presentViewController:navigationController animated:YES completion:nil];
         */
	} else {
		A3RootViewController_iPad *rootViewController = [[A3AppDelegate instance] rootViewController];
		[rootViewController presentRightSideViewController:viewController];
	}
}

- (void)configureInputCell:(A3LoanCalcTextInputCell *)inputCell withCalculationItem:(A3LoanCalcCalculationItem) calcItem
{
    inputCell.titleLabel.text = [LoanCalcString titleOfItem:calcItem];
    NSString *placeHolderText = @"";
    NSString *textFieldText = @"";
    switch (calcItem) {
        case A3LC_CalculationItemDownPayment:
        {
//            placeHolderText = [self.loanFormatter stringFromNumber:@(0)];
            textFieldText = [self.loanFormatter stringFromNumber:_loanData.downPayment];
            break;
        }
        case A3LC_CalculationItemInterestRate:
        {
            placeHolderText = [NSString stringWithFormat:@"Annual %@", [self.percentFormatter stringFromNumber:@(0)]];
            textFieldText = [self.percentFormatter stringFromNumber:_loanData.annualInterestRate];
            break;
        }
        case A3LC_CalculationItemPrincipal:
        {
//            placeHolderText = [self.loanFormatter stringFromNumber:@(0)];
            textFieldText = [self.loanFormatter stringFromNumber:_loanData.principal];
            break;
        }
        case A3LC_CalculationItemRepayment:
        {
            placeHolderText = [self.loanFormatter stringFromNumber:@(0)];
            textFieldText = [self.loanFormatter stringFromNumber:_loanData.repayment];
            break;
        }
        case A3LC_CalculationItemTerm:
        {
            placeHolderText = @"0 years";
            int yearInt =  (int)round(_loanData.monthOfTerms.doubleValue/12.0);
            textFieldText = [NSString stringWithFormat:@"%d years", yearInt];
            break;
        }
        default:
            break;
    }
    inputCell.textField.text = textFieldText;
    inputCell.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeHolderText
                                                                                attributes:@{NSForegroundColorAttributeName:inputCell.textField.textColor}];
}

- (void)configureExtraPaymentYearlyCell:(UITableViewCell *)cell
{
    cell.textLabel.text = [LoanCalcString titleOfExtraPayment:A3LC_ExtraPaymentYearly];
    NSString *currencyText = @"";
    if (_loanData.extraPaymentYearly) {
        currencyText = [self.loanFormatter stringFromNumber:_loanData.extraPaymentYearly];
    }
    else {
        currencyText = [self.loanFormatter stringFromNumber:@(0)];
    }
    NSString *dateText = @"";
    
    if (_loanData.extraPaymentYearlyDate) {
        NSDate *pickDate = _loanData.extraPaymentYearlyDate;
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setDateFormat:@"MMM"];
        dateText = [formatter stringFromDate:pickDate];
    }
    else {
        dateText = @"None";
    }
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", currencyText, dateText];
}

- (void)configureExtraPaymentOneTimeCell:(UITableViewCell *)cell
{
    cell.textLabel.text = [LoanCalcString titleOfExtraPayment:A3LC_ExtraPaymentOnetime];
    NSString *currencyText = @"";
    if (_loanData.extraPaymentOneTime) {
        currencyText = [self.loanFormatter stringFromNumber:_loanData.extraPaymentOneTime];
    }
    else {
        currencyText = [self.loanFormatter stringFromNumber:@(0)];
    }
    NSString *dateText = @"";
    if (_loanData.extraPaymentOneTimeDate) {
        NSDate *pickDate = _loanData.extraPaymentOneTimeDate;
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setDateFormat:@"MMM, yyyy"];
        dateText = [formatter stringFromDate:pickDate];
    }
    else {
        dateText = @"None";
    }
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", currencyText, dateText];
}

- (NSUInteger)indexOfCalcItem:(A3LoanCalcCalculationItem) calcItem
{
    for (NSNumber *itemNum in _calcItems) {
        A3LoanCalcCalculationItem item = itemNum.integerValue;
        
        if (calcItem == item) {
            NSUInteger idx = [_calcItems indexOfObject:itemNum];
            return idx;
        }
    }
    
    return -1;
}

- (UITextField *)previousTextField:(UITextField *) current
{
    NSUInteger section, row;
    section = currentIndexPath.section;
    row = currentIndexPath.row;
    NSIndexPath *selectedIP = nil;
    UITableViewCell *prevCell = nil;
    BOOL exit = false;
    do {
        if (row == 0) {
            if (section == 0) {
                return nil;
            }
            section--;
            row = [self.tableView numberOfRowsInSection:section]-1;
        }
        else {
            row--;
        }
        
        NSIndexPath *tmpIp = [NSIndexPath indexPathForRow:row inSection:section];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:tmpIp];
        
        if ([cell isKindOfClass:[A3LoanCalcTextInputCell class]]) {
            exit = true;
            prevCell = cell;
            selectedIP = tmpIp;
        }
        
    } while (!exit);
    
    if (prevCell && selectedIP && [prevCell isKindOfClass:[A3LoanCalcTextInputCell class]]) {
        return ((A3LoanCalcTextInputCell *)prevCell).textField;
    }
    else {
        return nil;
    }
}

- (UITextField *)nextTextField:(UITextField *) current
{
    NSUInteger section, row;
    section = currentIndexPath.section;
    row = currentIndexPath.row;
    NSIndexPath *selectedIP = nil;
    UITableViewCell *nextCell = nil;
    BOOL exit = false;
    do {
        row++;
        NSUInteger numRowOfSection = [self.tableView numberOfRowsInSection:section];
        if ((row+1) > numRowOfSection) {
            section++;
            row=0;
        }
        
        NSUInteger maxSection = [self.tableView numberOfSections];
        
        if (section > (maxSection-1)) {
            return nil;
        }
        
        NSIndexPath *tmpIp = [NSIndexPath indexPathForRow:row inSection:section];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:tmpIp];
        
        if ([cell isKindOfClass:[A3LoanCalcTextInputCell class]]) {
            exit = true;
            nextCell = cell;
            selectedIP = tmpIp;
        }
        
    } while (!exit);
    
    if (nextCell && selectedIP && [nextCell isKindOfClass:[A3LoanCalcTextInputCell class]]) {
        return ((A3LoanCalcTextInputCell *)nextCell).textField;
    }
    else {
        return nil;
    }
}

- (void)updateLoanCalculation
{
    [_loanData calculateRepayment];
    [self displayLoanGraph];
    
    _isLoanCalcEdited = YES;
    
    if ([_loanData calculated]) {
        // 계산이 되었으면, 상단 그래프가 보이도록 이동시킨다.
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

- (void)displayLoanGraph
{
    A3LoanCalcLoanGraphCell *graphCell = (A3LoanCalcLoanGraphCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    if ([_loanData calculated]) {
        [self displayGraphCell:graphCell];
    }
    else {
        [self makeGraphCellClear:graphCell];
    }
    
    [graphCell.monthlyButton setTitle:[LoanCalcString titleOfFrequency:_loanData.frequencyIndex] forState:UIControlStateNormal];
}

- (void)displayGraphCell:(A3LoanCalcLoanGraphCell *)graphCell
{
    graphCell.infoButton.hidden = NO;
    
    // red bar
    graphCell.redLineView.hidden = NO;
    
    // downLabel, info X위치 (아이폰/아이패드 모두 우측에서 50)
    dispatch_async(dispatch_get_main_queue(), ^{
        float fromRightDistance = 15.0 + graphCell.infoButton.bounds.size.width + 10.0;
        graphCell.lowLabel.layer.anchorPoint = CGPointMake(1.0, 0.5);
        CGPoint center = graphCell.lowLabel.center;
        center.x = graphCell.bounds.size.width - fromRightDistance;
        graphCell.lowLabel.center = center;
        graphCell.lowLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        
        float fromRightDistance2 = 15.0;
        graphCell.infoButton.layer.anchorPoint = CGPointMake(1.0, 0.5);
        CGPoint center2 = graphCell.infoButton.center;
        center2.x = graphCell.bounds.size.width - fromRightDistance2;
        center2.y = (int)round(center.y);
        graphCell.infoButton.center = center2;
        graphCell.infoButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        
    });
    
    // 애니메이션 Start
    graphCell.upLabel.alpha = 0.0;
    graphCell.lowLabel.alpha = 0.0;
    
    float aniDuration = 0.3;
    [UIView beginAnimations:@"GraphUpdate" context:NULL];
    [UIView setAnimationDuration:aniDuration];
    
    float percentOfRedBar = 0;
    
    if (_isTotalMode) {
        float valueUp = [_loanData totalInterest].floatValue;
        float valueDown = [_loanData totalAmount].floatValue;
        percentOfRedBar = valueUp/valueDown;
    }
    else {
        float valueUp = [_loanData monthlyAverageInterest].floatValue;
        float valueDown = [_loanData repayment].floatValue;
        percentOfRedBar = valueUp/valueDown;
    }
    
    CGRect redRect = graphCell.redLineView.frame;
    redRect.size.width = self.view.bounds.size.width * percentOfRedBar;
    graphCell.redLineView.frame = redRect;
    
    // 애니메이션 End
    graphCell.upLabel.alpha = 1.0;
    graphCell.lowLabel.alpha = 1.0;
    
    [UIView commitAnimations];
    
    // text info
    NSString *interestText = _isTotalMode ? @"Interest" : @"Avg.Interest";
    NSString *paymentText = _isTotalMode ? @"Total Amount" : @"Payment";
    NSString *interestValue = _isTotalMode ? [self.loanFormatter stringFromNumber:[_loanData totalInterest]] : [self.loanFormatter stringFromNumber:[_loanData monthlyAverageInterest]];
    NSString *paymentValue = _isTotalMode ? [self.loanFormatter stringFromNumber:[_loanData totalAmount]] : [self.loanFormatter stringFromNumber:_loanData.repayment];
    
    if (!_isTotalMode) {
        paymentValue = [NSString stringWithFormat:@"%@/%@", paymentValue, [LoanCalcString shortTitleOfFrequency:_loanData.frequencyIndex]];
    }
    
    NSDictionary *textAttributes1 = @{
                                      NSFontAttributeName : IS_IPAD ? [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline] : [UIFont systemFontOfSize:15.0],
                                      NSForegroundColorAttributeName:[UIColor blackColor]
                                      };
    
    NSDictionary *textAttributes2 = @{
                                      NSFontAttributeName : IS_IPAD ? [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote] : [UIFont systemFontOfSize:13.0],
                                      NSForegroundColorAttributeName:[UIColor colorWithRed:123.0/255.0 green:123.0/255.0 blue:123.0/255.0 alpha:1.0]
                                      };
    
    NSDictionary *textAttributes3 = @{
                                      NSFontAttributeName : IS_IPAD ? [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline] : [UIFont boldSystemFontOfSize:17.0],
                                      NSForegroundColorAttributeName:[UIColor blackColor]
                                      };
    
    NSDictionary *textAttributes4 = @{
                                      NSFontAttributeName : IS_IPAD ? [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline] : [UIFont systemFontOfSize:17.0],
                                      NSForegroundColorAttributeName:[UIColor blackColor]
                                      };
    NSDictionary *space1 = @{
                             NSFontAttributeName : [UIFont systemFontOfSize:25.0],
                             NSForegroundColorAttributeName:[UIColor blackColor]
                             };
    
    NSDictionary *space2 = @{
                             NSFontAttributeName : [UIFont systemFontOfSize:17.0],
                             NSForegroundColorAttributeName:[UIColor blackColor]
                             };
    
    NSMutableAttributedString *upAttrString = [[NSMutableAttributedString alloc] init];
    NSMutableAttributedString *upText1 = [[NSMutableAttributedString alloc] initWithString:interestValue attributes:textAttributes1];
    NSMutableAttributedString *upText2 = [[NSMutableAttributedString alloc] initWithString:interestText attributes:textAttributes2];
    NSMutableAttributedString *upGap = [[NSMutableAttributedString alloc] initWithString:@" " attributes:space1];
    [upAttrString appendAttributedString:upText1];
    [upAttrString appendAttributedString:upGap];
    [upAttrString appendAttributedString:upText2];
    graphCell.upLabel.attributedText = upAttrString;
    
    NSMutableAttributedString *downAttrString = [[NSMutableAttributedString alloc] init];
    NSMutableAttributedString *downText1 = [[NSMutableAttributedString alloc] initWithString:paymentValue attributes:textAttributes3];
    NSMutableAttributedString *downText2 = [[NSMutableAttributedString alloc] initWithString:paymentText attributes:textAttributes4];
    NSMutableAttributedString *lowGap = [[NSMutableAttributedString alloc] initWithString:@" " attributes:space2];
    [downAttrString appendAttributedString:downText1];
    [downAttrString appendAttributedString:lowGap];
    [downAttrString appendAttributedString:downText2];
    graphCell.lowLabel.attributedText = downAttrString;
}


- (void)makeGraphCellClear:(A3LoanCalcLoanGraphCell *)graphCell
{
    graphCell.redLineView.hidden = YES;
    graphCell.infoButton.hidden = YES;
    
    // downLabel X위치 (우측에서 15)
    dispatch_async(dispatch_get_main_queue(), ^{
        float fromRightDistance = 15.0;
        graphCell.lowLabel.layer.anchorPoint = CGPointMake(1.0, 0.5);
        CGPoint center = graphCell.lowLabel.center;
        center.x = graphCell.bounds.size.width - fromRightDistance;
        graphCell.lowLabel.center = center;
        graphCell.lowLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    });
    
    NSString *interestText = _isTotalMode ? @"Interest" : (IS_IPAD ? @"Average Interest":@"Avg.Interest");
    NSString *paymentText = _isTotalMode ? @"Total Amount" : @"Payment";
    
    NSDictionary *textAttributes1 = @{
                                      NSFontAttributeName : IS_IPAD ? [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline] : [UIFont systemFontOfSize:15.0],
                                      NSForegroundColorAttributeName:[UIColor blackColor]
                                      };
    
    NSDictionary *textAttributes2 = @{
                                      NSFontAttributeName : IS_IPAD ? [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote] : [UIFont systemFontOfSize:13.0],
                                      NSForegroundColorAttributeName:[UIColor colorWithRed:123.0/255.0 green:123.0/255.0 blue:123.0/255.0 alpha:1.0]
                                      };
    
    NSDictionary *textAttributes3 = @{
                                      NSFontAttributeName : IS_IPAD ? [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline] : [UIFont boldSystemFontOfSize:17.0],
                                      NSForegroundColorAttributeName:[UIColor blackColor]
                                      };
    
    NSDictionary *textAttributes4 = @{
                                      NSFontAttributeName : IS_IPAD ? [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline] : [UIFont systemFontOfSize:17.0],
                                      NSForegroundColorAttributeName:[UIColor blackColor]
                                      };
    NSDictionary *space1 = @{
                             NSFontAttributeName : [UIFont systemFontOfSize:25.0],
                             NSForegroundColorAttributeName:[UIColor blackColor]
                             };
    
    NSDictionary *space2 = @{
                             NSFontAttributeName : [UIFont systemFontOfSize:17.0],
                             NSForegroundColorAttributeName:[UIColor blackColor]
                             };
    
    NSMutableAttributedString *upAttrString = [[NSMutableAttributedString alloc] init];
    NSMutableAttributedString *upText1 = [[NSMutableAttributedString alloc] initWithString:[self.loanFormatter stringFromNumber:@(0)] attributes:textAttributes1];
    NSMutableAttributedString *upText2 = [[NSMutableAttributedString alloc] initWithString:interestText attributes:textAttributes2];
    NSMutableAttributedString *upGap = [[NSMutableAttributedString alloc] initWithString:@" " attributes:space1];
    [upAttrString appendAttributedString:upText1];
    [upAttrString appendAttributedString:upGap];
    [upAttrString appendAttributedString:upText2];
    graphCell.upLabel.attributedText = upAttrString;
    
    NSMutableAttributedString *downAttrString = [[NSMutableAttributedString alloc] init];
    NSMutableAttributedString *downText1 = [[NSMutableAttributedString alloc] initWithString:[self.loanFormatter stringFromNumber:@(0)] attributes:textAttributes3];
    NSMutableAttributedString *downText2 = [[NSMutableAttributedString alloc] initWithString:paymentText attributes:textAttributes4];
    NSMutableAttributedString *lowGap = [[NSMutableAttributedString alloc] initWithString:@" " attributes:space2];
    [downAttrString appendAttributedString:downText1];
    [downAttrString appendAttributedString:lowGap];
    [downAttrString appendAttributedString:downText2];
    graphCell.lowLabel.attributedText = downAttrString;
}

#pragma mark - LoanCalcSelectFrequencyDelegate

- (void)didSelectLoanCalcFrequency:(A3LoanCalcFrequencyType)frequencyType
{
    if (self.loanData.frequencyIndex != frequencyType) {
        _loanData.frequencyIndex = frequencyType;
        
        NSUInteger frequencyIndex = [self indexOfCalcItem:A3LC_CalculationItemFrequency];
        [self.tableView reloadRowsAtIndexPaths:@[
                                                 [NSIndexPath indexPathForRow:frequencyIndex inSection:1]
                                                 ]
                              withRowAnimation:UITableViewRowAnimationFade];
        
        [self updateLoanCalculation];
    }
}

#pragma mark - LoanCalcExtraPaymentDelegate

- (void)didChangedLoanCalcExtraPayment:(LoanCalcData *)loanCalc {
    [self.tableView reloadData];
}

#pragma mark - TextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.firstResponder = textField;
    
    textField.text = @"";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
    
    UITableViewCell *cell;
    UIView *testView = textField;
    while (testView.superview) {
        if ([testView.superview isKindOfClass:[UITableViewCell class]]) {
            cell = (UITableViewCell *)testView.superview;
            break;
        }
        else {
            testView = testView.superview;
        }
    }
    
    NSIndexPath *endIndexPath = [self.tableView indexPathForCell:cell];
    
    NSLog(@"End IP : %ld - %ld", (long)endIndexPath.section, (long)endIndexPath.row);

	[self setFirstResponder:nil];

    // update
    if (endIndexPath.section == 1) {
        // calculation item
        NSNumberFormatter *formatter = [NSNumberFormatter new];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        NSNumber *calcItemNum = _calcItems[endIndexPath.row];
        A3LoanCalcCalculationItem calcItem = calcItemNum.integerValue;
        double inputFloat = [textField.text doubleValue];
        NSNumber *inputNum = @(inputFloat);
        
        switch (calcItem) {
            case A3LC_CalculationItemDownPayment:
            {
                if ([textField.text length] > 0) {
                    _loanData.downPayment = inputNum;
                    textField.text = [self.loanFormatter stringFromNumber:inputNum];
                }
                else {
                    textField.text = [self.loanFormatter stringFromNumber:_loanData.downPayment];
                }
                
                break;
            }
            case A3LC_CalculationItemInterestRate:
            {
                if ([textField.text length] > 0) {
                    NSNumber *percentNum = @(inputFloat/100.0);
                    _loanData.annualInterestRate = percentNum;
                    textField.text = [self.percentFormatter stringFromNumber:percentNum];
                }
                else {
                    textField.text = [self.percentFormatter stringFromNumber:_loanData.annualInterestRate];
                }
                break;
            }
            case A3LC_CalculationItemPrincipal:
            {
                if ([textField.text length] > 0) {
                    _loanData.principal = inputNum;
                    textField.text = [self.loanFormatter stringFromNumber:inputNum];
                }
                else {
                    textField.text = [self.loanFormatter stringFromNumber:_loanData.principal];
                }

                break;
            }
            case A3LC_CalculationItemRepayment:
            {
                if ([textField.text length] > 0) {
                    _loanData.repayment = inputNum;
                    textField.text = [self.loanFormatter stringFromNumber:inputNum];
                }
                else {
                    textField.text = [self.loanFormatter stringFromNumber:_loanData.repayment];
                }
                
                break;
            }
            case A3LC_CalculationItemTerm:
            {
                if ([textField.text length] > 0) {
                    _loanData.monthOfTerms = @(inputNum.integerValue * 12);
                    int years = inputNum.intValue;
                    textField.text = [NSString stringWithFormat:@"%d years", years];
                }
                else {
                    textField.text = [NSString stringWithFormat:@"%d years", [_loanData.monthOfTerms intValue] / 12];
                }

                break;
            }
            default:
                break;
        }
    }
    else if (endIndexPath.section == 2) {
        // extra payment
        NSNumber *exPayItemNum = _extraPaymentItems[endIndexPath.row];
        A3LoanCalcExtraPaymentType exPayType = exPayItemNum.integerValue;
        float inputFloat = [textField.text doubleValue];
        NSNumber *inputNum = @(inputFloat);
        
        if (exPayType == A3LC_ExtraPaymentMonthly) {
            if ([textField.text length] > 0) {
                _loanData.extraPaymentMonthly = inputNum;
                textField.text = [self.loanFormatter stringFromNumber:inputNum];
            }
            else {
                textField.text = [self.loanFormatter stringFromNumber:_loanData.extraPaymentMonthly];
            }
        }
    }
    
    [self updateLoanCalculation];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    UITableViewCell *cell;
    UIView *testView = textField;
    while (testView.superview) {
        if ([testView.superview isKindOfClass:[UITableViewCell class]]) {
            cell = (UITableViewCell *)testView.superview;
            break;
        }
        else {
            testView = testView.superview;
        }
    }
    
    currentIndexPath = [self.tableView indexPathForCell:cell];
    
    A3NumberKeyboardViewController *keyboardVC = [self normalNumberKeyboard];
    textField.inputView = [keyboardVC view];
    self.numberKeyboardViewController = keyboardVC;
    
    if (currentIndexPath.section == 1) {
        // calculation items
        NSNumber *calcItemNum = _calcItems[currentIndexPath.row];
        A3LoanCalcCalculationItem calcItem = calcItemNum.integerValue;
        
        switch (calcItem) {
            case A3LC_CalculationItemDownPayment:
            case A3LC_CalculationItemPrincipal:
            case A3LC_CalculationItemRepayment:
            {
                self.numberKeyboardViewController.keyboardType = A3NumberKeyboardTypeCurrency;
                break;
            }
            case A3LC_CalculationItemInterestRate:
            {
                self.numberKeyboardViewController.keyboardType = A3NumberKeyboardTypeInterestRate;
                break;
            }
            case A3LC_CalculationItemTerm:
            {
                self.numberKeyboardViewController.keyboardType = A3NumberKeyboardTypeMonthYear;
                break;
            }
            default:
                break;
        }
    }
    else if (currentIndexPath.section == 2) {
        // extra payment
        NSNumber *exPaymentItemNum = _extraPaymentItems[currentIndexPath.row];
        A3LoanCalcExtraPaymentType exPaymentItem = exPaymentItemNum.integerValue;
        
        if (exPaymentItem == A3LC_ExtraPaymentMonthly) {
            self.numberKeyboardViewController.keyboardType = A3NumberKeyboardTypeCurrency;
        }
    }
    
    keyboardVC.textInputTarget = textField;
    keyboardVC.delegate = self;
    self.numberKeyboardViewController = keyboardVC;
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.firstResponder resignFirstResponder];
	[self setFirstResponder:nil];
    
    return YES;
}

- (void)textChanged:(NSNotification *)noti
{
	UITextField *textField = noti.object;
    NSString *testText = textField.text;
    
    if ([testText rangeOfString:@"."].location == NSNotFound) {
        return;
    }
    else {
        NSArray *textDivs = [testText componentsSeparatedByString:@"."];
        NSString *intString = textDivs[0];
        NSString *floatString = textDivs[1];
        
        if (floatString.length > 3) {
            floatString = [floatString substringWithRange:NSMakeRange(0, 3)];
        }
        
        NSString *reText = [NSString stringWithFormat:@"%@.%@", intString, floatString];
        textField.text = reText;
    }
}

/*
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *toBe = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if ([toBe rangeOfString:@"."].location == NSNotFound) {
        return YES;
    }
    else {
        NSArray *textDivs = [toBe componentsSeparatedByString:@"."];
        NSString *intString = textDivs[0];
        NSString *floatString = textDivs[1];
        
        if (floatString.length > 3) {
            return NO;
        }
        else {
            return YES;
        }
    }
}
 */

#pragma mark - ScrollView Delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self clearEverything];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self clearEverything];
    
    if (indexPath.section == 0) {
        // graph
    }
    else if (indexPath.section == 1) {
        // calculation items
        NSNumber *calcItemNum = _calcItems[indexPath.row];
        A3LoanCalcCalculationItem calcItem = calcItemNum.integerValue;
        
        if (calcItem == A3LC_CalculationItemFrequency) {
            A3LoanCalcSelectFrequencyViewController *viewController = [[A3LoanCalcSelectFrequencyViewController alloc] initWithStyle:UITableViewStyleGrouped];
            viewController.delegate = self;
            viewController.currentFrequency = self.loanData.frequencyIndex;
            
            [self presentSubViewController:viewController];
        }
        else {
            A3LoanCalcTextInputCell *inputCell = (A3LoanCalcTextInputCell *)[tableView cellForRowAtIndexPath:indexPath];
            [inputCell.textField becomeFirstResponder];
        }
    }
    if (indexPath.section == 2) {
        // extra payment
        NSNumber *exPaymentItemNum = _extraPaymentItems[indexPath.row];
        A3LoanCalcExtraPaymentType exPaymentItem = exPaymentItemNum.integerValue;
        
        if ((exPaymentItem == A3LC_ExtraPaymentYearly) || (exPaymentItem == A3LC_ExtraPaymentOnetime)) {
            UIStoryboard *stroyBoard = [UIStoryboard storyboardWithName:@"LoanCalculatorPhoneStoryBoard" bundle:nil];
            A3LoanCalcExtraPaymentViewController *viewController = [stroyBoard instantiateViewControllerWithIdentifier:@"A3LoanCalcExtraPaymentViewController"];
            viewController.exPaymentType = exPaymentItem;
            viewController.loanCalcData = _loanData;
            viewController.delegate = self;
            
            [self presentSubViewController:viewController];
        }
        else if (exPaymentItem == A3LC_ExtraPaymentMonthly) {
            A3LoanCalcTextInputCell *inputCell = (A3LoanCalcTextInputCell *)[tableView cellForRowAtIndexPath:indexPath];
            [inputCell.textField becomeFirstResponder];
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [LoanCalcPreference new].showExtraPayment ? 3:2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0) {
        return 1;   // loan graph
    }
    else if (section == 1) {
        return self.calcItems.count;
    }
    else if (section == 2) {
        return self.extraPaymentItems.count;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=nil;
	@autoreleasepool {
		cell = nil;
        
        if (indexPath.section == 0) {
            // graph
            A3LoanCalcLoanGraphCell *graphCell = [tableView dequeueReusableCellWithIdentifier:A3LoanCalcLoanGraphCellID2 forIndexPath:indexPath];
            
            [graphCell.monthlyButton addTarget:self action:@selector(monthlyButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            [graphCell.totalButton addTarget:self action:@selector(totalButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            [graphCell.infoButton addTarget:self action:@selector(infoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            
            if ([_loanData calculated]) {
                [self displayGraphCell:graphCell];
            }
            else {
                [self makeGraphCellClear:graphCell];
            }
            
            [graphCell.monthlyButton setTitle:[LoanCalcString titleOfFrequency:_loanData.frequencyIndex] forState:UIControlStateNormal];
            
            cell = graphCell;
        }
        else if (indexPath.section == 1) {
            // calculation items
            NSNumber *calcItemNum = _calcItems[indexPath.row];
            A3LoanCalcCalculationItem calcItem = calcItemNum.integerValue;
            
            if (calcItem == A3LC_CalculationItemFrequency) {
                cell = [tableView dequeueReusableCellWithIdentifier:A3LoanCalcSelectCellID2 forIndexPath:indexPath];
                cell.textLabel.text = [LoanCalcString titleOfItem:calcItem];
                cell.detailTextLabel.text = [LoanCalcString titleOfFrequency:self.loanData.frequencyIndex];
                cell.detailTextLabel.font = [UIFont systemFontOfSize:17];
                cell.detailTextLabel.textColor = [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
            }
            else {
                A3LoanCalcTextInputCell *inputCell = [tableView dequeueReusableCellWithIdentifier:A3LoanCalcTextInputCellID2 forIndexPath:indexPath];
                inputCell.selectionStyle = UITableViewCellSelectionStyleNone;
                inputCell.textField.delegate = self;
                inputCell.textField.font = [UIFont systemFontOfSize:17];
                inputCell.textField.textColor = [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
                
                [self configureInputCell:inputCell withCalculationItem:calcItem];
                
                cell = inputCell;
            }
        }
        else if (indexPath.section == 2) {
            // extra payment
            NSNumber *exPaymentItemNum = _extraPaymentItems[indexPath.row];
            A3LoanCalcExtraPaymentType exPaymentItem = exPaymentItemNum.integerValue;
            
            if (exPaymentItem == A3LC_ExtraPaymentMonthly) {
                A3LoanCalcTextInputCell *inputCell = [tableView dequeueReusableCellWithIdentifier:A3LoanCalcTextInputCellID2 forIndexPath:indexPath];
                inputCell.selectionStyle = UITableViewCellSelectionStyleNone;
                inputCell.textField.font = [UIFont systemFontOfSize:17];
                inputCell.textField.textColor = [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
                inputCell.textField.delegate = self;
                inputCell.titleLabel.text = [LoanCalcString titleOfExtraPayment:exPaymentItem];
                inputCell.textField.text = [self.loanFormatter stringFromNumber:_loanData.extraPaymentMonthly];
                inputCell.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@""
                                                                                            attributes:@{NSForegroundColorAttributeName:inputCell.textField.textColor}];
//                inputCell.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:[self.loanFormatter stringFromNumber:@(0)]
//                                                                                            attributes:@{NSForegroundColorAttributeName:inputCell.textField.textColor}];
                
                cell = inputCell;
            }
            else {
                cell = [tableView dequeueReusableCellWithIdentifier:A3LoanCalcSelectCellID2 forIndexPath:indexPath];
                cell.detailTextLabel.font = [UIFont systemFontOfSize:17];
                cell.detailTextLabel.textColor = [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
                
                if (exPaymentItem == A3LC_ExtraPaymentYearly) {
                    [self configureExtraPaymentYearlyCell:cell];
                }
                else if (exPaymentItem == A3LC_ExtraPaymentOnetime) {
                    [self configureExtraPaymentOneTimeCell:cell];
                }
            }
        }
	}
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return (IS_IPHONE) ? 134 : 193;
    }
    else {
        return 44;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    float nonTitleHieght = 35;
    float titleHeight = 55;
    
    if (section == 0) {
        return 1;
    }
    else {
        if (section == 2) {
            return titleHeight-1.0;
        }
        else {
            return nonTitleHieght-1.0;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 2) {
        return [LoanCalcPreference new].showExtraPayment ? @"EXTRA PAYMENTS" : nil;
    }
    
    return nil;
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

#pragma mark - A3KeyboardDelegate

- (BOOL)isPreviousEntryExists{
    if ([self previousTextField:(UITextField *) self.firstResponder]) {
        return YES;
    }
    else {
        return NO;
    }
}

- (BOOL)isNextEntryExists{
    if ([self nextTextField:(UITextField *) self.firstResponder]) {
        return YES;
    }
    else {
        return NO;
    }
}

- (void)prevButtonPressed{
    if (self.firstResponder) {
        UITextField *prevTxtField = [self previousTextField:(UITextField *) self.firstResponder];
        if (prevTxtField) {
            [prevTxtField becomeFirstResponder];
        }
    }
}

- (void)nextButtonPressed{
    if (self.firstResponder) {
        UITextField *nextTxtField = [self nextTextField:(UITextField *) self.firstResponder];
        if (nextTxtField) {
            [nextTxtField becomeFirstResponder];
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
}

@end
