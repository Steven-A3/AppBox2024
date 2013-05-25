//
//  A3LoanCalcPieChartController
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 5/22/13 4:52 PM.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CPTGraph;

typedef NS_ENUM(NSUInteger, A3LoanCalcGraphType) {
	A3LoanCalcGraphWithPrincipal = 1,
	A3LoanCalcGraphWithMonthlyPayment,
};

@interface A3LoanCalcPieChartController : NSObject

@property (nonatomic, strong)	NSNumber *principal, *totalInterest, *monthlyPayment, *monthlyAverageInterest, *totalAmount;
@property (nonatomic, strong)	UIColor *backgroundColor;

- (CPTGraph *)graphWithFrame:(CGRect)frame for:(A3LoanCalcGraphType)type;
@end