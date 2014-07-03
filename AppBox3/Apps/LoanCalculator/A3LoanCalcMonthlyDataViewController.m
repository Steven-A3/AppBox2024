//
//  A3LoanCalcMonthlyDataViewController.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 12. 13..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3LoanCalcMonthlyDataViewController.h"
#import "UIViewController+NumberKeyboard.h"
#import "UIViewController+LoanCalcAddtion.h"
#import "A3LoanCalcLoanInfo3Cell.h"
#import "A3LoanCalcPaymentInfoCell.h"
#import "LoanCalcData.h"
#import "LoanCalcData+Calculation.h"
#import "LoanCalcString.h"
#import "A3NumberKeyboardViewController.h"
#import "A3AppDelegate.h"
#import "A3LoanCalcMonthlyTableTitleView.h"
#import "NSDate+formatting.h"
#import "NSDateFormatter+A3Addition.h"


@interface A3LoanCalcMonthlyDataViewController ()

@property (nonatomic, strong) NSMutableArray *paymentList;
@property (nonatomic, strong) UIView *valueTitleView;

@end

@implementation A3LoanCalcMonthlyDataViewController

NSString *const A3LoanCalcLoanInfoCell3ID = @"A3LoanCalcLoanInfo3Cell";
NSString *const A3LoanCalcPaymentInfoCellID = @"A3LoanCalcPaymentInfoCell";

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
    
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.contentInset = UIEdgeInsetsMake(-1, 0, 36, 0);
    self.tableView.separatorColor = [self tableViewSeparatorColor];
    self.tableView.separatorInset = UIEdgeInsetsMake(0, (IS_IPAD)?28:15, 0, 0);
    
    self.paymentList = [NSMutableArray new];
    [self.percentFormatter setMaximumFractionDigits:3];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 2)];
    line.backgroundColor = [UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0];
    line.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.tableView addSubview:line];
    
    NSString *title = [[LoanCalcString titleOfFrequency:_loanData.frequencyIndex] stringByAppendingString:NSLocalizedString(@"Data", nil)];
    self.navigationItem.title = title;
    
    [self registerContentSizeCategoryDidChangeNotification];
    [self reloadCurrencyCode];
}

- (void)reloadCurrencyCode {
	NSString *customCurrencyCode = [[NSUserDefaults standardUserDefaults] objectForKey:A3LoanCalcCustomCurrencyCode];
	if ([customCurrencyCode length]) {
		[self.currencyFormatter setCurrencyCode:customCurrencyCode];
	}
}

- (void)removeObserver {
	[self removeContentSizeCategoryDidChangeNotification];
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

- (void)contentSizeDidChange:(NSNotification *) notification
{
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    _paymentList = nil;
    [self.tableView reloadData];
}

- (NSMutableArray *)paymentList
{
    if (!_paymentList) {
        _paymentList = [[NSMutableArray alloc] init];
        
        // date, payment, principal, interest, balance
        
        double downPayment = _loanData.downPayment ? _loanData.downPayment.doubleValue : 0;
        double balance = (_loanData.principal.doubleValue - downPayment);

        NSUInteger paymentIndex = 0;    // start from 0
        
        do {
            NSDate *payDate = [_loanData dateOfPaymentIndex:paymentIndex];
            NSNumber *interest = @(balance * [_loanData interestRateOfFrequency]);
            
            double paymentTmp = [_loanData paymentOfPaymentIndex:paymentIndex].doubleValue;
            
            if ((paymentTmp-interest.floatValue) > balance) {
                paymentTmp = balance + interest.floatValue;
            }
            NSNumber *payment = @(paymentTmp);
            NSNumber *principal = @(payment.doubleValue - interest.doubleValue);
            balance -= principal.doubleValue;
            
            if (isinf(balance) || isnan(balance)) {
                break;
            }
            
            // 간혹 마지막 차에서 소수점이 남는 문제를 보정하기 위해 0.5미만은 0으로 바꾼다.
            if (balance < 0.5) {
                balance = 0;
            }
            NSNumber *balanceNum = @(balance);
            
            [_paymentList addObject:@{
                                      @"Date": payDate,
                                      @"Payment": payment,
                                      @"Principal": principal,
                                      @"Interest": interest,
                                      @"Balance": balanceNum
                                      }];
            paymentIndex++;
            
        } while (balance > 0);
    }
    
    return _paymentList;
}

- (UIView *)valueTitleView
{
    if (!_valueTitleView) {
        
        _valueTitleView = [[A3LoanCalcMonthlyTableTitleView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 35)];
    }
    
    return _valueTitleView;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateInfoCell:(A3LoanCalcLoanInfo3Cell *)infoCell withLoanInfo:(LoanCalcData *)loan
{
    if (IS_IPAD) {
        infoCell.amountValueLB.text = [self.currencyFormatter stringFromNumber:loan.totalAmount];
    }
    
    // 결과 아이템
    infoCell.upSecondTitleLB.text = [[LoanCalcString titleOfCalFor:_loanData.calculationMode] uppercaseString];
    A3LoanCalcCalculationItem resultItem = [LoanCalcMode resltItemForCalcMode:_loanData.calculationMode];
    if (_loanData.calculationMode == A3LC_CalculationForTermOfMonths) {
        NSInteger monthInt =  (int)round(loan.monthOfTerms.doubleValue);
        infoCell.upSecondValueLB.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld months", @"StringsDict", nil), (long)monthInt];
    }
    else if (_loanData.calculationMode == A3LC_CalculationForTermOfYears) {
        NSInteger yearInt =  (int)round(loan.monthOfTerms.doubleValue/12.0);
        infoCell.upSecondValueLB.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld years", @"StringsDict", nil), (long)yearInt];
        
        NSString *unit = [LoanCalcString shortTitleOfFrequency:A3LC_FrequencyAnnually];
        if (round([loan.monthOfTerms doubleValue]) < 12.0) {
            NSInteger monthInt = roundl([loan.monthOfTerms doubleValue]);
            infoCell.upSecondValueLB.text = [NSString stringWithFormat:NSLocalizedString(@"0 %@ %ld mo", @"0 %@ %ld mo"), unit, (long) monthInt];
        }
        else {
            NSInteger yearInt = roundl([loan.monthOfTerms doubleValue]) / 12.0;
            NSInteger monthInt = roundl([loan.monthOfTerms doubleValue]) - (12 * yearInt);
            if (monthInt == 0) {
                infoCell.upSecondValueLB.text = [NSString stringWithFormat:@"%ld %@", (long)yearInt, unit];
            }
            else {
                infoCell.upSecondValueLB.text = [NSString stringWithFormat:NSLocalizedString(@"%ld %@ %ld mo", @"%ld %@ %ld mo"), (long) yearInt, unit, (long) monthInt];
            }
        }
    }
    else {
        infoCell.upSecondValueLB.text = [LoanCalcString valueTextForCalcItem:resultItem fromData:_loanData formatter:self.currencyFormatter];
    }
    
    BOOL downPaymentEnable = (loan.showDownPayment && (loan.downPayment.doubleValue >0)) ? YES:NO;
    NSArray *calItems = [LoanCalcMode calculateItemForMode:_loanData.calculationMode withDownPaymentEnabled:downPaymentEnable];
    
    for (NSUInteger idx = 0; idx < calItems.count; idx++) {
        NSNumber *num = calItems[idx];
        A3LoanCalcCalculationItem calItem = (A3LoanCalcCalculationItem) num.integerValue;
        UILabel *titleLB = infoCell.downTitleLBs[idx];
        titleLB.text = [LoanCalcString titleOfItem:calItem];
        titleLB.text = [titleLB.text uppercaseString];
        [titleLB sizeToFit];
    }
    
    for (NSUInteger idx2 = 0; idx2 <calItems.count; idx2++) {
        NSNumber *num = calItems[idx2];
        A3LoanCalcCalculationItem calItem = (A3LoanCalcCalculationItem) num.integerValue;
        UILabel *valueLB = infoCell.downValueLBs[idx2];
        valueLB.text = [LoanCalcString valueTextForCalcItem:calItem fromData:loan formatter:self.currencyFormatter];
    }
    
    if (_loanData.showExtraPayment) {
        NSMutableArray *extraItems = [NSMutableArray new];
        if (_loanData.extraPaymentMonthly.doubleValue > 0) {
            [extraItems addObject:@(A3LC_ExtraPaymentMonthly)];
        }
        if (_loanData.extraPaymentYearly.doubleValue > 0) {
            [extraItems addObject:@(A3LC_ExtraPaymentYearly)];
        }
        if (_loanData.extraPaymentOneTime.doubleValue > 0) {
            [extraItems addObject:@(A3LC_ExtraPaymentOnetime)];
        }
        
        
        int calItemsCount = (_loanData.showDownPayment && [_loanData.downPayment doubleValue] > 0) ? 5:4;
        
        for (int idx = 0; idx < [extraItems count]; idx++) {
            UILabel *titleLB = infoCell.downTitleLBs[calItemsCount + idx];
            UILabel *valueLB = infoCell.downValueLBs[calItemsCount + idx];
            
            NSNumber *num = extraItems[idx];
            A3LoanCalcExtraPaymentType extraType = num.integerValue;
            
            switch (extraType) {
                case A3LC_ExtraPaymentMonthly:
                {
                    titleLB.text = IS_IPAD ? NSLocalizedString(@"Extra Payments(Monthly)", @"Extra Payments(Monthly)") : NSLocalizedString(@"Extra(Monthly)", @"Extra(Monthly)");
                    titleLB.text = [titleLB.text uppercaseString];
                    [titleLB sizeToFit];
                    valueLB.text = [self.currencyFormatter stringFromNumber:_loanData.extraPaymentMonthly];
                    break;
                }
                case A3LC_ExtraPaymentYearly:
                {
                    titleLB.text = IS_IPAD ? NSLocalizedString(@"Extra Payments(Yearly)", @"Extra Payments(Yearly)") : NSLocalizedString(@"Extra(Yearly)", @"Extra(Yearly)");
                    titleLB.text = [titleLB.text uppercaseString];
                    [titleLB sizeToFit];

                    NSString *currencyText;
                    if (_loanData.extraPaymentYearly) {
                        currencyText = [self.currencyFormatter stringFromNumber:_loanData.extraPaymentYearly];
                    }
                    else {
                        currencyText = [self.currencyFormatter stringFromNumber:@(0)];
                    }

                    NSString *dateText;
                    if (_loanData.extraPaymentYearlyDate) {
                        NSDate *pickDate = _loanData.extraPaymentYearlyDate;
                        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                        [formatter setDateStyle:NSDateFormatterMediumStyle];
                        [formatter setDateFormat:IS_IPAD ? @"MMMM" : @"MMM"];
                        dateText = [formatter stringFromDate:pickDate];
                    }
                    else {
                        dateText = NSLocalizedString(@"None", @"None");
                    }

                    valueLB.text = [NSString stringWithFormat:@"%@ %@", currencyText, dateText];
                    break;
                }
                case A3LC_ExtraPaymentOnetime:
                {
                    titleLB.text = IS_IPAD ? NSLocalizedString(@"Extra Payments(One-time)", @"Extra Payments(One-time)") : NSLocalizedString(@"Extra(One-time)", @"Extra(One-time)");
                    titleLB.text = [titleLB.text uppercaseString];
                    [titleLB sizeToFit];

                    NSString *currencyText;
                    if (_loanData.extraPaymentOneTime) {
                        currencyText = [self.currencyFormatter stringFromNumber:_loanData.extraPaymentOneTime];
                    }
                    else {
                        currencyText = [self.currencyFormatter stringFromNumber:@(0)];
                    }
                    NSString *dateText;
                    if (_loanData.extraPaymentOneTimeDate) {
                        NSDate *pickDate = _loanData.extraPaymentOneTimeDate;
                        
                        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                        dateText = IS_IPAD ? [formatter localizedLongStyleYearMonthFromDate:pickDate] : [formatter localizedMediumStyleYearMonthFromDate:pickDate];
                    }
                    else {
                        dateText = NSLocalizedString(@"None", @"None");
                    }
                    
                    valueLB.text = [NSString stringWithFormat:@"%@ %@", currencyText, dateText];
                    break;
                }
                default:
                    break;
            }
        }
    }
}

- (void)makeClearInfoCell:(A3LoanCalcLoanInfo3Cell *)infoCell
{
}

- (void)configurePayInfoCell:(A3LoanCalcPaymentInfoCell *)payInfoCell withPayment:(NSDictionary *)paymentInfo
{
    NSDate *date = paymentInfo[@"Date"];
    NSNumber *principal = paymentInfo[@"Principal"];
    NSNumber *payment = paymentInfo[@"Payment"];
    NSNumber *interest = paymentInfo[@"Interest"];
    NSNumber *balance = paymentInfo[@"Balance"];
    NSDateFormatter *df = [NSDateFormatter new];
    //df.dateStyle = NSDateFormatterLongStyle;
    
//    df.dateStyle = NSDateFormatterMediumStyle;
//    df.dateFormat = [df formatStringByRemovingDayComponent:[df dateFormat]];
//    payInfoCell.dateLb.text = [df stringFromDate:date];

    payInfoCell.dateLb.text = [df localizedMediumStyleYearMonthFromDate:date];
    
//    df.dateFormat = [df formatStringByRemovingDayComponent:[df customFullStyleFormat]];
//    payInfoCell.dateLb.text = [df stringFromDate:date];
    
    if (IS_IPHONE) {
        self.currencyFormatter.currencySymbol = @"";
    }

    payInfoCell.interestLb.text = [self.currencyFormatter stringFromNumber:interest];
    payInfoCell.paymentLb.text = [self.currencyFormatter stringFromNumber:payment];
    payInfoCell.principalLb.text = [self.currencyFormatter stringFromNumber:principal];
    payInfoCell.balanceLb.text = [self.currencyFormatter stringFromNumber:balance];
}

- (NSUInteger)countForLoanItem:(LoanCalcData *)loan
{
    NSUInteger itemCount = 4;
    
    if (_loanData.calculationMode == A3LC_CalculationForDownPayment) {
        itemCount++;
    }
    else {
        if (_loanData.showDownPayment) {
            if (_loanData.downPayment.doubleValue > 0) {
                itemCount++;
            }
        }
    }
    
    if (_loanData.showExtraPayment) {
        if (_loanData.extraPaymentMonthly.doubleValue > 0) {
            itemCount++;
        }
        if (_loanData.extraPaymentYearly.doubleValue > 0) {
            itemCount++;
        }
        if (_loanData.extraPaymentOneTime.doubleValue > 0) {
            itemCount++;
        }
    }
    return itemCount;
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
    if (section == 1) {
        return self.paymentList.count;
    }
    else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = nil;

	if (indexPath.section == 0){
		A3LoanCalcLoanInfo3Cell *infoCell = [tableView dequeueReusableCellWithIdentifier:A3LoanCalcLoanInfoCell3ID forIndexPath:indexPath];
		infoCell.selectionStyle = UITableViewCellSelectionStyleNone;
		infoCell.valueCount = [self countForLoanItem:_loanData];

		if ([_loanData calculated]) {
			[self updateInfoCell:infoCell withLoanInfo:_loanData];
		}
		else {
			[self makeClearInfoCell:infoCell];
		}

		cell = infoCell;
	}
	else if (indexPath.section == 1){
		A3LoanCalcPaymentInfoCell *payInfoCell = [tableView dequeueReusableCellWithIdentifier:A3LoanCalcPaymentInfoCellID forIndexPath:indexPath];
		payInfoCell.selectionStyle = UITableViewCellSelectionStyleNone;

		NSDictionary *paymentInfo = _paymentList[indexPath.row];
		[self configurePayInfoCell:payInfoCell withPayment:paymentInfo];

		cell = payInfoCell;
	}

	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return [A3LoanCalcLoanInfo3Cell heightForValueCount:[self countForLoanItem:_loanData]];
    }
    else {
        return 44;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
    if (section == 0) {
        return 1;
    }
    else if (section == 1){
        return self.valueTitleView.bounds.size.height;
    }
    else {
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    float titleHeight = 55.0;

    NSUInteger numberSection = [tableView numberOfSections];
    
    float lastFooterHeight = 1;
    
    if (section == (numberSection-1)) {
        return lastFooterHeight;
    }
    else if  (section == 0) {
        return titleHeight-self.valueTitleView.bounds.size.height;
    }
    else {
        return 1;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return self.valueTitleView;
    }
    
    return nil;
}

@end
