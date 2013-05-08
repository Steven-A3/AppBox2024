//
//  A3LoanCalcPieChartViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 2/8/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3LoanCalcPieChartViewController.h"
#import "common.h"

@interface A3LoanCalcPieChartViewController ()

@property (nonatomic, strong) IBOutlet CPTGraphHostingView *leftGraphView;
@property (nonatomic, strong) IBOutlet CPTGraphHostingView *rightGraphView;
@property (nonatomic, strong) IBOutlet UILabel *totalLabel;
@property (nonatomic, strong) IBOutlet UILabel *leftCenterLabel, *rightCenterLabel;
@property (nonatomic, strong) IBOutlet UILabel *leftTopLabel, *leftBottomLabel;
@property (nonatomic, strong) IBOutlet UILabel *rightTopLabel, *rightBottomLabel;
@property (nonatomic, strong) NSString *leftGraphIdentifier;
@property (nonatomic, strong) NSString *rightGraphIdentifier;

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

#define LOANCALC_SINGLE_PIE_CHART_LEFT	@"LOANCALC_SINGLE_PIE_CHART_LEFT"
#define LOANCALC_SINGLE_PIE_CHART_RIGHT	@"LOANCALC_SINGLE_PIE_CHART_RIGHT"

- (void)addPieChart {
	// Setup LEFT pie chart
	_leftGraphIdentifier = LOANCALC_SINGLE_PIE_CHART_LEFT;
	_rightGraphIdentifier = LOANCALC_SINGLE_PIE_CHART_RIGHT;

	self.leftGraphView.hostedGraph = [self graphWithFrame:self.leftGraphView.bounds withIdentifier:_leftGraphIdentifier];
	self.rightGraphView.hostedGraph = [self graphWithFrame:self.rightGraphView.bounds withIdentifier:_rightGraphIdentifier];
}

- (CPTGraph *)graphWithFrame:(CGRect)frame withIdentifier:(id)identifier {
	CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:frame];
	[graph applyTheme:[CPTTheme themeNamed:kCPTPlainWhiteTheme]];
	graph.paddingLeft = 0.0f;
	graph.paddingRight = 0.0f;
	graph.paddingTop = 0.0f;
	graph.paddingBottom = 0.0f;
	graph.axisSet = nil;
	graph.plotAreaFrame.borderLineStyle = nil;
	graph.backgroundColor = [self tableViewBackgroundColor].CGColor;

	CPTMutableLineStyle *clearLineStyle = [CPTMutableLineStyle lineStyle];
	clearLineStyle.lineColor = [CPTColor clearColor];

	CPTMutableShadow *whiteShadow = [CPTMutableShadow shadow];
	whiteShadow.shadowOffset     = CGSizeMake(0.0, -8.0);
	whiteShadow.shadowBlurRadius = 3.0;
	whiteShadow.shadowColor      = [[CPTColor darkGrayColor] colorWithAlphaComponent:0.25];

	CPTGradient *overlayGradient = [[CPTGradient alloc] init];
	overlayGradient.gradientType = CPTGradientTypeRadial;
	overlayGradient = [overlayGradient addColorStop:[[CPTColor whiteColor] colorWithAlphaComponent:1.0] atPosition:0.0];
	overlayGradient = [overlayGradient addColorStop:[[CPTColor whiteColor] colorWithAlphaComponent:0.0] atPosition:1.0];

	CPTPieChart *pieChart = [[CPTPieChart alloc] init];
	pieChart.dataSource = self;
	pieChart.delegate = self;
	pieChart.pieRadius = frame.size.width * 0.85f / 2.0f;
	pieChart.pieInnerRadius = pieChart.pieRadius / 2.0f - 5.0f;
	pieChart.identifier = identifier;
	pieChart.startAngle = (CGFloat) DegreesToRadians(0.0);
	pieChart.sliceDirection = CPTPieDirectionClockwise;
	pieChart.borderLineStyle = clearLineStyle;
	pieChart.shadow = whiteShadow;
	pieChart.overlayFill = [CPTFill fillWithGradient:overlayGradient];
	pieChart.labelOffset = -30.0f;
	pieChart.backgroundColor = [self tableViewBackgroundColor].CGColor;

	[graph addPlot:pieChart];

	return graph;
}

#pragma mark -
#pragma mark Plot Data Source Methods

- (NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
	return 2;
}

- (NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
	CPTPieChart *pieChart = (CPTPieChart *)plot;
	if ([pieChart.identifier isEqual:_leftGraphIdentifier]) {
		switch (index) {
			case 0:
				return self.principal;
			case 1:
				return self.totalInterest;
		}
	} else if ([pieChart.identifier isEqual:_rightGraphIdentifier]) {
		switch (index) {
			case 0:
				return self.monthlyPayment;
			case 1:
				return self.monthlyAverageInterest;
		}
	}
	return nil;
}

- (CPTFill *)sliceFillForPieChart:(CPTPieChart *)pieChart recordIndex:(NSUInteger)idx {
	static NSArray *plotFillColorsLeft = nil;
	if (nil == plotFillColorsLeft) {
		plotFillColorsLeft= @[
				[UIColor colorWithRed:139.0/255.0 green:214.0/255.0 blue:2.0/255.0 alpha:1.0],
				[UIColor colorWithRed:255.0/255.0 green:134.0/255.0 blue:43.0/255.0 alpha:1.0]];
	}
	static NSArray *plotFillColorsRight = nil;
	if (nil == plotFillColorsRight) {
		plotFillColorsRight= @[
				[UIColor colorWithRed:42.0/255.0 green:230.0/255.0 blue:228.0/255.0 alpha:1.0],
				[UIColor colorWithRed:255.0/255.0 green:153.0/255.0 blue:206.0/255.0 alpha:1.0]];
	}

	if ([pieChart.identifier isEqual:_leftGraphIdentifier])
		return [[CPTFill alloc] initWithColor:[plotFillColorsLeft objectAtIndex:idx]];
	return [[CPTFill alloc] initWithColor:[plotFillColorsRight objectAtIndex:idx]];
}

#pragma mark - Public Interfaces

- (void)reloadData {
	static NSNumberFormatter *numberFormatter = nil;
	if (nil == numberFormatter) {
		numberFormatter = [[NSNumberFormatter alloc] init];
		[numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	}

	_leftTopLabel.text = [numberFormatter stringFromNumber:_totalInterest];
	_leftBottomLabel.text = [numberFormatter stringFromNumber:_principal];
	_rightTopLabel.text = [numberFormatter stringFromNumber:_monthlyAverageInterest];
	_rightBottomLabel.text = [numberFormatter stringFromNumber:_monthlyPayment];
	_totalLabel.text = [numberFormatter stringFromNumber:_totalAmount];

	[self.leftGraphView.hostedGraph reloadData];
	[self.rightGraphView.hostedGraph reloadData];
}

- (IBAction)buttonPressed:(id)sender {
	if ([_delegate respondsToSelector:@selector(loanCalcPieChartViewButtonPressed)]) {
		[_delegate loanCalcPieChartViewButtonPressed];
	}
}

@end
