//
//  A3LoanCalcComparisonTopLeftViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 3/19/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3LoanCalcComparisonTopLeftViewController.h"

@interface A3LoanCalcComparisonTopLeftViewController ()

@property (nonatomic, strong) IBOutlet UILabel *totalAmount_A, *totalAmount_B, *totalAmount_label;
@property (nonatomic, strong) IBOutlet UIView *totalAmount_underlineView;
@property (nonatomic, strong) IBOutlet UILabel *principal_A, *principal_B, *principal_label;
@property (nonatomic, strong) IBOutlet UIView *principal_underlineView;
@property (nonatomic, strong) IBOutlet UILabel *totalInterest_A, *totalInterest_B, *totalInterest_label;
@property (nonatomic, strong) IBOutlet UIView *totalInterest_underlineView;
@property (nonatomic, strong) IBOutlet UILabel *monthlyPayment_A, *monthlyPayment_B, *monthlyPayment_label;
@property (nonatomic, strong) IBOutlet UIView *monthlyPayment_underlineView;
@property (nonatomic, strong) IBOutlet UIView *lowestPayment_underlineView;
@property (nonatomic, strong) IBOutlet UILabel *lowestPaymentLabel;
@property (nonatomic, strong) IBOutlet UILabel *lowestPaymentHead;
@property (nonatomic, strong) IBOutlet UILabel *lowestPaymentMiddle;
@property (nonatomic, strong) IBOutlet UILabel *lowestPaymentDiff;
@property (nonatomic, strong) NSNumberFormatter *numberFormatter;

@end

@implementation A3LoanCalcComparisonTopLeftViewController

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
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setTotalAmountValue_A:(float)totalAmountValue_A {
	_totalAmount_A.text = [self.numberFormatter stringFromNumber:[NSNumber numberWithFloat:totalAmountValue_A]];
}

- (void)setTotalAmountValue_B:(float)totalAmountValue_B {
	_totalAmount_B.text = [self.numberFormatter stringFromNumber:[NSNumber numberWithFloat:totalAmountValue_B]];
}

- (void)setPrincipalValue_A:(float)principalValue_A {
	_principal_A.text = [self.numberFormatter stringFromNumber:[NSNumber numberWithFloat:principalValue_A]];
}

- (void)setPrincipalValue_B:(float)principalValue_B {
	_principal_B.text = [self.numberFormatter stringFromNumber:[NSNumber numberWithFloat:principalValue_B]];
}

- (void)setTotalInterestValue_A:(float)totalInterestValue_A {
	_totalInterest_A.text = [self.numberFormatter stringFromNumber:[NSNumber numberWithFloat:totalInterestValue_A]];
}

- (void)setTotalInterestValue_B:(float)totalInterestValue_B {
	_totalInterest_B.text = [self.numberFormatter stringFromNumber:[NSNumber numberWithFloat:totalInterestValue_B]];
}

- (void)setMonthlyPaymentValue_A:(float)monthlyPaymentValue_A {
	_monthlyPayment_A.text = [self.numberFormatter stringFromNumber:[NSNumber numberWithFloat:monthlyPaymentValue_A]];
	[self updateLowestPaymentValueLabel];
}

- (void)setMonthlyPaymentValue_B:(float)monthlyPaymentValue_B {
	_monthlyPayment_B.text = [self.numberFormatter stringFromNumber:[NSNumber numberWithFloat:monthlyPaymentValue_B]];
	[self updateLowestPaymentValueLabel];
}

- (void)updateLowestPaymentValueLabel {
	NSString *lowestSet = _monthlyPaymentValue_A > _monthlyPaymentValue_B ? @"Loan B" : @"Loan A";
	_lowestPaymentHead.text = lowestSet;

	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	double difference = fabs(_monthlyPaymentValue_A - _monthlyPaymentValue_B);
	_lowestPaymentDiff.text = [NSString stringWithFormat:@"%@/mo", [numberFormatter stringFromNumber:[NSNumber numberWithDouble:difference]]];
}

- (NSNumberFormatter *)numberFormatter {
	if (_numberFormatter == nil) {
		_numberFormatter = [[NSNumberFormatter alloc] init];
		[_numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	}
	return _numberFormatter;
}

@end
