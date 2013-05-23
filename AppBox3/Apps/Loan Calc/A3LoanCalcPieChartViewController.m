//
//  A3LoanCalcPieChartViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 2/8/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3LoanCalcPieChartViewController.h"
#import "A3LoanCalcPieChartController.h"
#import "CorePlot-CocoaTouch.h"

@interface A3LoanCalcPieChartViewController ()

@property (nonatomic, strong) IBOutlet CPTGraphHostingView *leftGraphView;
@property (nonatomic, strong) IBOutlet CPTGraphHostingView *rightGraphView;
@property (nonatomic, strong) IBOutlet UILabel *totalLabel;
@property (nonatomic, strong) IBOutlet UILabel *leftCenterLabel, *rightCenterLabel;
@property (nonatomic, strong) IBOutlet UILabel *leftTopLabel, *leftBottomLabel;
@property (nonatomic, strong) IBOutlet UILabel *rightTopLabel, *rightBottomLabel;

@end

@implementation A3LoanCalcPieChartViewController

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
	[self addPieChart];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Setup Pie Chart

- (void)addPieChart {
	// Setup LEFT pie chart
	self.leftGraphView.hostedGraph = [_chartController graphWithFrame:self.leftGraphView.bounds for:A3LoanCalcGraphWithPrincipal];
	self.rightGraphView.hostedGraph = [_chartController graphWithFrame:self.rightGraphView.bounds for:A3LoanCalcGraphWithMonthlyPayment];
}

#pragma mark - Public Interfaces

- (void)reloadData {
	static NSNumberFormatter *numberFormatter = nil;
	if (nil == numberFormatter) {
		numberFormatter = [[NSNumberFormatter alloc] init];
		[numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	}

	_leftTopLabel.text = [numberFormatter stringFromNumber:self.chartController.totalInterest];
	_leftBottomLabel.text = [numberFormatter stringFromNumber:self.chartController.principal];
	_rightTopLabel.text = [numberFormatter stringFromNumber:self.chartController.monthlyAverageInterest];
	_rightBottomLabel.text = [numberFormatter stringFromNumber:self.chartController.monthlyPayment];
	_totalLabel.text = [numberFormatter stringFromNumber:self.chartController.totalAmount];

	[self.leftGraphView.hostedGraph reloadData];
	[self.rightGraphView.hostedGraph reloadData];
}

- (IBAction)buttonPressed:(id)sender {
	if ([_delegate respondsToSelector:@selector(loanCalcPieChartViewButtonPressed)]) {
		[_delegate loanCalcPieChartViewButtonPressed];
	}
}

@end
