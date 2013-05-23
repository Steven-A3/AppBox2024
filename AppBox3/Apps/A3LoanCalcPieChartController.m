//
//  A3LoanCalcPieChartController
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 5/22/13 4:52 PM.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3LoanCalcPieChartController.h"
#import "CorePlot-CocoaTouch.h"
#import "common.h"

@interface A3LoanCalcPieChartController () <CPTPlotDataSource>
@end

@implementation A3LoanCalcPieChartController {

}

static NSString *graphIdentifierForWithPrincial = @"principalAndTotalInterest";
static NSString *graphIdentifierForWithMonthlyPayment = @"monthlyPayment";

- (CPTGraph *)graphWithFrame:(CGRect)frame for:(A3LoanCalcGraphType)type {
	NSString *identifier;
	switch (type) {
		case A3LoanCalcGraphWithPrincipal:
			identifier = graphIdentifierForWithPrincial;
			break;
		case A3LoanCalcGraphWithMonthlyPayment:
			identifier = graphIdentifierForWithMonthlyPayment;
			break;
	}

	CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:frame];
	[graph applyTheme:[CPTTheme themeNamed:kCPTPlainWhiteTheme]];
	graph.paddingLeft = 0.0f;
	graph.paddingRight = 0.0f;
	graph.paddingTop = 0.0f;
	graph.paddingBottom = 0.0f;
	graph.axisSet = nil;
	graph.plotAreaFrame.borderLineStyle = nil;
	graph.backgroundColor = self.backgroundColor.CGColor;

	CPTMutableLineStyle *clearLineStyle = [CPTMutableLineStyle lineStyle];
	clearLineStyle.lineColor = [CPTColor clearColor];

	CPTMutableShadow *whiteShadow = [CPTMutableShadow shadow];
	whiteShadow.shadowOffset = CGSizeMake(0.0, -8.0);
	whiteShadow.shadowBlurRadius = 3.0;
	whiteShadow.shadowColor = [[CPTColor darkGrayColor] colorWithAlphaComponent:0.25];

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
	pieChart.backgroundColor = self.backgroundColor.CGColor;

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
	if ([pieChart.identifier isEqual:graphIdentifierForWithPrincial]) {
		switch (index) {
			case 0:
				return self.principal;
			case 1:
				return self.totalInterest;
		}
	} else if ([pieChart.identifier isEqual:graphIdentifierForWithMonthlyPayment]) {
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

	if ([pieChart.identifier isEqual:graphIdentifierForWithPrincial])
		return [[CPTFill alloc] initWithColor:[plotFillColorsLeft objectAtIndex:idx]];
	return [[CPTFill alloc] initWithColor:[plotFillColorsRight objectAtIndex:idx]];
}

@end