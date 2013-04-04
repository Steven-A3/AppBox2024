//
//  A3LoanCalcSingleBarChartController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 4/4/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3LoanCalcSingleBarChartController.h"
#import "LoanCalcHistory.h"
#import "NSString+conversion.h"
#import "common.h"

@implementation A3LoanCalcSingleBarChartController

- (CPTGraphHostingView *)graphHostingView {
	if (nil == _graphHostingView) {
		_graphHostingView = [[CPTGraphHostingView alloc] initWithFrame:CGRectZero];
		_graphHostingView.clipsToBounds = NO;
	}
	return _graphHostingView;
}

- (void)configureBarChart {
	CPTXYGraph *graph = [[CPTXYGraph alloc] initWithFrame:_graphHostingView.bounds];
	_graphHostingView.hostedGraph = graph;

	[graph applyTheme:[CPTTheme themeNamed:kCPTPlainWhiteTheme]];

	graph.paddingBottom = 0.0;
	graph.plotAreaFrame.borderLineStyle = nil;

	float yRange = MAX(_objectA.monthlyPayment.floatValueEx, _objectB.monthlyPayment.floatValueEx);
	float fullRange = yRange / 0.45;
	float base = fullRange * 0.40;
	float visibleRange = fullRange - base;
	FNLOG(@"%f, %f", fullRange, base);

	CPTXYPlotSpace *barPlotSpace = [[CPTXYPlotSpace alloc] init];
	barPlotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-0.4) length:CPTDecimalFromFloat(2.9)];
	barPlotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-base) length:CPTDecimalFromFloat(fullRange)];

	[graph addPlotSpace:barPlotSpace];

	// Create grid line styles
	CPTMutableLineStyle *majorGridLineStyle = [CPTMutableLineStyle lineStyle];
	majorGridLineStyle.lineWidth = 1.0f;
	majorGridLineStyle.lineColor = [CPTColor colorWithComponentRed:213.0/255.0 green:207.0/255.0 blue:192.0/255.0 alpha:1.0];

	CPTMutableLineStyle *minorGridLineStyle = [CPTMutableLineStyle lineStyle];
	minorGridLineStyle.lineWidth = 1.0f;
	minorGridLineStyle.lineColor = [[CPTColor blackColor] colorWithAlphaComponent:0.25];

	NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc] init];
	[currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];

	// Create axes
	CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
	CPTXYAxis *x          = axisSet.xAxis;
	{
		x.labelingPolicy 			  = CPTAxisLabelingPolicyNone;
		x.majorIntervalLength         = CPTDecimalFromInteger(1);
		x.minorTicksPerInterval       = 0;
		x.orthogonalCoordinateDecimal = CPTDecimalFromInteger(0);

		x.majorGridLineStyle = nil;
		x.minorGridLineStyle = nil;
		x.axisLineStyle      = majorGridLineStyle;
		x.majorTickLineStyle = majorGridLineStyle;
		x.minorTickLineStyle = nil;
		x.labelOffset        = 5.0;

		x.visibleRange   = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.5) length:CPTDecimalFromFloat(2.0)];

		NSMutableSet *axisLabels = [NSMutableSet set];
		CPTMutableTextStyle *labelTextStyle = [CPTMutableTextStyle textStyle];
		labelTextStyle.fontSize = 16.0;
		labelTextStyle.color = [CPTColor colorWithComponentRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0];

		CPTAxisLabel *labelForLoanA = [[CPTAxisLabel alloc] initWithText:@"Loan A" textStyle:labelTextStyle];
		labelForLoanA.tickLocation = CPTDecimalFromFloat(1.0);
		labelForLoanA.offset = 3.0;
		[axisLabels addObject:labelForLoanA];

		CPTAxisLabel *labelForLoanB = [[CPTAxisLabel alloc] initWithText:@"Loan B" textStyle:labelTextStyle];
		labelForLoanB.tickLocation = CPTDecimalFromFloat(2.0);
		labelForLoanB.offset = 3.0;
		[axisLabels addObject:labelForLoanB];

		x.axisLabels = axisLabels;

		x.plotSpace = barPlotSpace;
	}

	CPTXYAxis *y = axisSet.yAxis;
	{
		CPTMutableTextStyle *labelTextStyle = [CPTMutableTextStyle textStyle];
		labelTextStyle.fontSize = 16.0;
		labelTextStyle.color = [CPTColor colorWithComponentRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0];

		y.labelingPolicy 			  = CPTAxisLabelingPolicyAutomatic;
		y.majorIntervalLength         = CPTDecimalFromInteger(200);
		y.minorTicksPerInterval       = 0;
		y.orthogonalCoordinateDecimal = CPTDecimalFromDouble(0.0);

		y.preferredNumberOfMajorTicks = 5;
		y.majorGridLineStyle          = majorGridLineStyle;
		y.minorGridLineStyle          = nil;
		y.axisLineStyle               = nil;
		y.majorTickLineStyle          = nil;
		y.minorTickLineStyle          = nil;
		y.labelOffset                 = -40.0;
		y.labelFormatter 			  = currencyFormatter;
		y.labelTextStyle			  = labelTextStyle;

		y.visibleRange   = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0) length:CPTDecimalFromFloat(visibleRange)];
		y.gridLinesRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.5) length:CPTDecimalFromFloat(2.0)];

		y.plotSpace = barPlotSpace;
	}

	// Set axes
//	graph.axisSet.axes = [NSArray arrayWithObjects:x, y, nil];

	// Create a bar line style
	CPTMutableLineStyle *barLineStyle = [[CPTMutableLineStyle alloc] init];
	barLineStyle.lineWidth = 1.0;
	barLineStyle.lineColor = [CPTColor whiteColor];

	// Create first bar plot
	CPTBarPlot *barPlot = [[CPTBarPlot alloc] init];
	barPlot.lineStyle       = nil;
	CPTGradient *plot1Gradient = [CPTGradient gradientWithBeginningColor:
			[CPTColor colorWithComponentRed:116.0/255.0 green:181.0/255.0 blue:0.0 alpha:1.0]
															 endingColor:
																	 [CPTColor colorWithComponentRed:137.0/255.0 green:213.0/255.0 blue:0.0 alpha:1.0]];
	barPlot.fill            = [CPTFill fillWithGradient:plot1Gradient];
	barPlot.barBasesVary    = YES;
	barPlot.barWidth        = CPTDecimalFromFloat(0.85); // bar is 80% of the available space
	barPlot.barCornerRadius = 0.0f;

	barPlot.barsAreHorizontal = NO;

	CPTMutableTextStyle *whiteTextStyle = [CPTMutableTextStyle textStyle];
	whiteTextStyle.color   = [CPTColor whiteColor];
	whiteTextStyle.fontName = @"Helvetica-Bold";
	whiteTextStyle.fontSize = 14.0;
	barPlot.labelTextStyle = whiteTextStyle;
	barPlot.labelOffset = -1.0;
	barPlot.labelFormatter = currencyFormatter;

	barPlot.delegate   = self;
	barPlot.dataSource = self;
	barPlot.identifier = @"Monthly Payment";

	[graph addPlot:barPlot toPlotSpace:barPlotSpace];

	CPTMutableTextStyle *legendTextStyle = [CPTMutableTextStyle textStyle];
	legendTextStyle.fontSize = 15.0;
	legendTextStyle.color = [CPTColor colorWithComponentRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0];

	// Add legend
	CPTLegend *theLegend = [CPTLegend legendWithGraph:graph];
	theLegend.numberOfColumns = 2;
	theLegend.fill            = nil;
	theLegend.borderLineStyle = nil;
	theLegend.cornerRadius    = 10.0;
	theLegend.swatchSize      = CGSizeMake(12.0, 12.0);
	theLegend.textStyle       = legendTextStyle;

	NSArray *plotPoint = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.2], [NSNumber numberWithFloat:visibleRange * 0.2 * -1.0], nil];

	CPTPlotSpaceAnnotation *legendAnnotation = [[CPTPlotSpaceAnnotation alloc] initWithPlotSpace:barPlotSpace anchorPlotPoint:plotPoint];
	legendAnnotation.contentLayer = theLegend;

	legendAnnotation.contentAnchorPoint = CGPointMake(0.0, 1.0);
	[graph.plotAreaFrame.plotArea addAnnotation:legendAnnotation];

}

- (void)reloadData {
	_graphHostingView.hostedGraph = nil;
	[self configureBarChart];
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
	return 2;
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
	NSNumber *num = nil;

	if ( fieldEnum == CPTBarPlotFieldBarLocation ) {
		// location
		num = [NSNumber numberWithInt:index + 1];
	}
	else if ( fieldEnum == CPTBarPlotFieldBarTip ) {
		// length
		if (index == 0) {
			num = [NSNumber numberWithFloat:_objectA.monthlyPayment.floatValueEx];
		} else {
			num = [NSNumber numberWithFloat:_objectB.monthlyPayment.floatValueEx];
		}
	}
	else {
		// base
		num = [NSNumber numberWithInt:0];
	}

	return num;
}

@end
