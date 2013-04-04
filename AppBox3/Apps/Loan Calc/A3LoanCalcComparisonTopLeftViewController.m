//
//  A3LoanCalcComparisonTopLeftViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 3/19/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3LoanCalcComparisonTopLeftViewController.h"
#import "LoanCalcHistory.h"
#import "NSString+conversion.h"
#import "LoanCalcHistory+calculation.h"

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

- (void)updateLabels {
	_totalAmount_A.text = [self.numberFormatter stringFromNumber:_leftObject.totalAmount];
	_totalAmount_B.text = [self.numberFormatter stringFromNumber:_rightObject.totalAmount];
	NSNumber *principalA = [NSNumber numberWithFloat:_leftObject.principal.floatValueEx];
	NSNumber *principalB = [NSNumber numberWithFloat:_rightObject.principal.floatValueEx];
	_principal_A.text = [_numberFormatter stringFromNumber:principalA];
	_principal_B.text = [_numberFormatter stringFromNumber:principalB];
	_totalInterest_A.text = [self.numberFormatter stringFromNumber:_leftObject.totalInterest];
	_totalInterest_B.text = [self.numberFormatter stringFromNumber:_rightObject.totalInterest];
	NSNumber *monthlyPaymentA = [NSNumber numberWithFloat:_leftObject.monthlyPayment.floatValueEx];
	NSNumber *monthlyPaymentB = [NSNumber numberWithFloat:_rightObject.monthlyPayment.floatValueEx];
	_monthlyPayment_A.text = [_numberFormatter stringFromNumber:monthlyPaymentA];
	_monthlyPayment_B.text = [_numberFormatter stringFromNumber:monthlyPaymentB];

	NSString *lowestSet = monthlyPaymentA.floatValue > monthlyPaymentB.floatValue ? @"Loan B" : @"Loan A";
	_lowestPaymentHead.text = lowestSet;

	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	double difference = fabs(monthlyPaymentA.floatValue - monthlyPaymentB.floatValue);
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
