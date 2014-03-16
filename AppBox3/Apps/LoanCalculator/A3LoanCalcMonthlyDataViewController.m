//
//  A3LoanCalcMonthlyDataViewController.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 12. 13..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3LoanCalcMonthlyDataViewController.h"
#import "A3LoanCalcLoanInfo3Cell.h"
#import "A3LoanCalcPaymentInfoCell.h"
#import "LoanCalcData.h"
#import "LoanCalcData+Calculation.h"
#import "LoanCalcString.h"
#import "A3NumberKeyboardViewController.h"
#import "A3AppDelegate.h"
#import "UIViewController+A3AppCategory.h"
#import "A3LoanCalcMonthlyTableTitleView.h"

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
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 2)];
    line.backgroundColor = [UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0];
    line.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.tableView addSubview:line];
    
    NSString *title = [[LoanCalcString titleOfFrequency:_loanData.frequencyIndex] stringByAppendingString:@" Data"];
    self.navigationItem.title = title;
    
    [self registerContentSizeCategoryDidChangeNotification];
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

/*
- (void)updateInfoCell:(A3LoanCalcLoanInfo2Cell *)infoCell withLoanInfo:(LoanCalcData *)loan
{
    if (IS_IPAD) {
        infoCell.amountLabel.text = [self.currencyFormatter stringFromNumber:loan.totalAmount];
    }
    infoCell.paymentLabel.text = [NSString stringWithFormat:@"%@/%@", [self.currencyFormatter stringFromNumber:loan.repayment], [LoanCalcString shortTitleOfFrequency:loan.frequencyIndex]];
    infoCell.frequencyLabel.text = [LoanCalcString titleOfFrequency:loan.frequencyIndex];
    infoCell.interestLabel.text = [self.percentFormatter stringFromNumber:loan.annualInterestRate];
    int yearInt =  (int)round(loan.monthOfTerms.doubleValue/12.0);
    infoCell.termLabel.text = [NSString stringWithFormat:@"%d years", yearInt];
    infoCell.principalLabel.text = [self.currencyFormatter stringFromNumber:loan.principal];
}

- (void)makeClearInfoCell:(A3LoanCalcLoanInfo2Cell *)infoCell
{
    if (IS_IPAD) {
        infoCell.amountLabel.text = [self.currencyFormatter stringFromNumber:@(0)];
    }
    infoCell.paymentLabel.text = [NSString stringWithFormat:@"%@/%@", [self.currencyFormatter stringFromNumber:@(0)], [LoanCalcString shortTitleOfFrequency:A3LC_FrequencyMonthly]];
    infoCell.frequencyLabel.text = [LoanCalcString titleOfFrequency:A3LC_FrequencyMonthly];
    infoCell.interestLabel.text = [self.percentFormatter stringFromNumber:@(0)];
    infoCell.termLabel.text = @"0 years";
    infoCell.principalLabel.text = [self.currencyFormatter stringFromNumber:@(0)];
}
 */

- (NSString *)valueTextForCalcItem:(A3LoanCalcCalculationItem)calcItem fromData:(LoanCalcData *)loan
{
    switch (calcItem) {
        case A3LC_CalculationItemDownPayment:
        {
            return [self.currencyFormatter stringFromNumber:loan.downPayment];
        }
        case A3LC_CalculationItemFrequency:
        {
            return [LoanCalcString titleOfFrequency:loan.frequencyIndex];
        }
        case A3LC_CalculationItemInterestRate:
        {
            return [self.percentFormatter stringFromNumber:loan.annualInterestRate];
        }
        case A3LC_CalculationItemPrincipal:
        {
            return [self.currencyFormatter stringFromNumber:loan.principal];
        }
        case A3LC_CalculationItemRepayment:
        {
            return [NSString stringWithFormat:@"%@/%@", [self.currencyFormatter stringFromNumber:loan.repayment], [LoanCalcString shortTitleOfFrequency:loan.frequencyIndex]];
        }
        case A3LC_CalculationItemTerm:
        {
            int yearInt =  (int)round(loan.monthOfTerms.doubleValue/12.0);
            return [NSString stringWithFormat:@"%d years", yearInt];
        }
        default:
            return @"";
    }
}

- (void)updateInfoCell:(A3LoanCalcLoanInfo3Cell *)infoCell withLoanInfo:(LoanCalcData *)loan
{
    if (IS_IPAD) {
        infoCell.amountValueLB.text = [self.currencyFormatter stringFromNumber:loan.totalAmount];
    }
    
    // 결과 아이템
    infoCell.upSecondTitleLB.text = [[LoanCalcString titleOfCalFor:_loanData.calculationFor] uppercaseString];
    A3LoanCalcCalculationItem resultItem = [LoanCalcMode resltItemForCalcFor:_loanData.calculationFor];
    if (_loanData.calculationFor == A3LC_CalculationForTermOfMonths) {
        int monthInt =  (int)round(loan.monthOfTerms.doubleValue);
        infoCell.upSecondValueLB.text = [NSString stringWithFormat:@"%d months", monthInt];
    }
    else if (_loanData.calculationFor == A3LC_CalculationForTermOfYears) {
        int yearInt =  (int)round(loan.monthOfTerms.doubleValue/12.0);
        infoCell.upSecondValueLB.text = [NSString stringWithFormat:@"%d years", yearInt];
    }
    else {
        infoCell.upSecondValueLB.text = [self valueTextForCalcItem:resultItem fromData:_loanData];
    }
    
    BOOL downPaymentEnable = (loan.showDownPayment && (loan.downPayment.doubleValue >0)) ? YES:NO;
    NSArray *calItems = [LoanCalcMode calculateItemForMode:_loanData.calculationFor withDownPaymentEnabled:downPaymentEnable];
    
    for (NSUInteger idx = 0; idx < calItems.count; idx++) {
        NSNumber *num = calItems[idx];
        A3LoanCalcCalculationItem calItem = (A3LoanCalcCalculationItem) num.integerValue;
        UILabel *titleLB = infoCell.downTitleLBs[idx];
        titleLB.text = [LoanCalcString titleOfItem:calItem];
        titleLB.text = [titleLB.text uppercaseString];

    }
    
    for (int i=0; i<calItems.count; i++) {
        NSNumber *num = calItems[i];
        A3LoanCalcCalculationItem calItem = num.integerValue;
        UILabel *valueLB = infoCell.downValueLBs[i];
        valueLB.text = [self valueTextForCalcItem:calItem fromData:loan];
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
        
        int calItemsCount = _loanData.showDownPayment ? 5:4;
        
        for (int i = 0; i<extraItems.count; i++) {
            UILabel *titleLB = infoCell.downTitleLBs[calItemsCount + i];
            UILabel *valueLB = infoCell.downValueLBs[calItemsCount + i];
            
            NSNumber *num = extraItems[i];
            A3LoanCalcExtraPaymentType extraType = num.integerValue;
            
            switch (extraType) {
                case A3LC_ExtraPaymentMonthly:
                {
                    titleLB.text = IS_IPAD ? @"ExtraPayments(Monthly)":@"Extra(Monthly)";
                    titleLB.text = [titleLB.text uppercaseString];
                    valueLB.text = [self.currencyFormatter stringFromNumber:_loanData.extraPaymentMonthly];
                    break;
                }
                case A3LC_ExtraPaymentYearly:
                {
                    titleLB.text = IS_IPAD ? @"ExtraPayments(Yearly)":@"Extra(Yearly)";
                    titleLB.text = [titleLB.text uppercaseString];

                    NSString *currencyText = @"";
                    if (_loanData.extraPaymentYearly) {
                        currencyText = [self.currencyFormatter stringFromNumber:_loanData.extraPaymentYearly];
                    }
                    else {
                        currencyText = [self.currencyFormatter stringFromNumber:@(0)];
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
                    
                    valueLB.text = [NSString stringWithFormat:@"%@ %@", currencyText, dateText];
                    break;
                }
                case A3LC_ExtraPaymentOnetime:
                {
                    titleLB.text = IS_IPAD ? @"ExtraPayments(Onetime)":@"Extra(Onetime)";
                    titleLB.text = [titleLB.text uppercaseString];

                    NSString *currencyText = @"";
                    if (_loanData.extraPaymentOneTime) {
                        currencyText = [self.currencyFormatter stringFromNumber:_loanData.extraPaymentOneTime];
                    }
                    else {
                        currencyText = [self.currencyFormatter stringFromNumber:@(0)];
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
    /*
    if (IS_IPAD) {
        infoCell.amountLabel.text = [self.currencyFormatter stringFromNumber:@(0)];
    }
    infoCell.paymentLabel.text = [NSString stringWithFormat:@"%@/%@", [self.currencyFormatter stringFromNumber:@(0)], [LoanCalcString shortTitleOfFrequency:A3LC_FrequencyMonthly]];
    infoCell.frequencyLabel.text = [LoanCalcString titleOfFrequency:A3LC_FrequencyMonthly];
    infoCell.interestLabel.text = [self.percentFormatter stringFromNumber:@(0)];
    infoCell.termLabel.text = @"0 years";
    infoCell.principalLabel.text = [self.currencyFormatter stringFromNumber:@(0)];
     */
}

- (void)configurePayInfoCell:(A3LoanCalcPaymentInfoCell *)payInfoCell withPayment:(NSDictionary *)paymentInfo
{
    NSDate *date = paymentInfo[@"Date"];
    NSNumber *principal = paymentInfo[@"Principal"];
    NSNumber *payment = paymentInfo[@"Payment"];
    NSNumber *interest = paymentInfo[@"Interest"];
    NSNumber *balance = paymentInfo[@"Balance"];
    NSDateFormatter *df = [NSDateFormatter new];
    df.dateStyle = NSDateFormatterShortStyle;
    if ((_loanData.frequencyIndex == A3LC_FrequencyBiweekly) || (_loanData.frequencyIndex == A3LC_FrequencyWeekly)) {
        payInfoCell.dateLb.text = [df stringFromDate:date];
    }
    else {
        [df setDateFormat:@"MMM yyyy"];
        payInfoCell.dateLb.text = [df stringFromDate:date];
    }
    
    payInfoCell.interestLb.text = [self.currencyFormatter stringFromNumber:interest];
    payInfoCell.paymentLb.text = [self.currencyFormatter stringFromNumber:payment];
    payInfoCell.principalLb.text = [self.currencyFormatter stringFromNumber:principal];
    payInfoCell.balanceLb.text = [self.currencyFormatter stringFromNumber:balance];
}

- (NSUInteger)countForLoanItem:(LoanCalcData *)loan
{
    NSUInteger itemCount = 4;
    
    if (_loanData.calculationFor == A3LC_CalculationForDownPayment) {
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
    UITableViewCell *cell=nil;
	@autoreleasepool {
		cell = nil;
        
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

@end
