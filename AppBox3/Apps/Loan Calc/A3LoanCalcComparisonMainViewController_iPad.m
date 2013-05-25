//
//  A3LoanCalcComparisonMainViewController_iPad.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 05/23/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3LoanCalcComparisonMainViewController_iPad.h"
#import "A3LoanCalcComparisonTopLeftViewController.h"
#import "A3LoanCalcPrincipalBarChartController.h"
#import "A3LoanCalcSingleBarChartController.h"

@interface A3LoanCalcComparisonMainViewController_iPad ()

@property (nonatomic, strong) A3LoanCalcComparisonTopLeftViewController *firstColumnInScrollView;
@property (nonatomic, strong) A3LoanCalcPrincipalBarChartController *secondColumnInScrollView;
@property (nonatomic, strong) A3LoanCalcPrincipalBarChartController *thirdColumnInScrollView;
@property (nonatomic, strong) A3LoanCalcSingleBarChartController *fourthColumnInScrollView;

@end

@implementation A3LoanCalcComparisonMainViewController_iPad

- (void)configureTopScrollView {
	UIScrollView *_topScrollView = self.topScrollView;
	CGRect bounds = _topScrollView.bounds;
	[_topScrollView setContentSize:CGSizeMake(bounds.size.width * 2.0, bounds.size.height)];

	// add top left view
	[_topScrollView addSubview:self.firstColumnInScrollView.view];
	_firstColumnInScrollView.leftObject = self.leftObject;
	_firstColumnInScrollView.rightObject = self.rightObject;
	[_firstColumnInScrollView updateLabels];

	CGRect boundsParent = self.topScrollView.bounds;
	CGFloat columnWidth = boundsParent.size.width / 2.0;

	self.secondColumnInScrollView.graphHostingView.frame = CGRectMake(columnWidth, 0.0, columnWidth, boundsParent.size.height);
	[_topScrollView addSubview:self.secondColumnInScrollView.graphHostingView];

	_secondColumnInScrollView.objectA = self.leftObject;
	_secondColumnInScrollView.objectB = self.rightObject;
	[_secondColumnInScrollView reloadData];

	self.thirdColumnInScrollView.graphHostingView.frame = CGRectMake(columnWidth * 2.0, 0.0, columnWidth, boundsParent.size.height);
	[_topScrollView addSubview:_thirdColumnInScrollView.graphHostingView];
	_thirdColumnInScrollView.objectA = self.leftObject;
	_thirdColumnInScrollView.objectB = self.rightObject;
	[_thirdColumnInScrollView reloadData];

	self.fourthColumnInScrollView.graphHostingView.frame = CGRectMake(columnWidth * 3.0, 0.0, columnWidth, boundsParent.size.height);
	[_topScrollView addSubview:_fourthColumnInScrollView.graphHostingView];
	_fourthColumnInScrollView.objectA = self.leftObject;
	_fourthColumnInScrollView.objectB = self.rightObject;
	[_fourthColumnInScrollView reloadData];

	UIColor *lineColor = [UIColor colorWithRed:213.0/255.0 green:207.0/255.0 blue:192.0/255.0 alpha:1.0];
	// add vertical line in the first page.
	UIView *verticalLine1 = [[UIView alloc] initWithFrame:CGRectMake(bounds.size.width / 2.0, 0.0, 1.0, 211.0)];
	verticalLine1.backgroundColor = lineColor;
	[_topScrollView addSubview:verticalLine1];

	// add vertical line in the second page.
	UIView *verticalLine2 = [[UIView alloc] initWithFrame:CGRectMake(bounds.size.width / 2.0 * 3.0, 0.0, 1.0, 211.0)];
	verticalLine2.backgroundColor = lineColor;
	[_topScrollView addSubview:verticalLine2];
}

- (void)pageControlValueChanged:(DDPageControl *)control {
	[self.topScrollView setContentOffset:CGPointMake(self.topScrollView.contentSize.width / 2.0 * control.currentPage, 0.0) animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	self.pageControl.currentPage = (NSInteger) (self.topScrollView.contentOffset.x / (self.topScrollView.contentSize.width / 2.0));
}

- (A3LoanCalcComparisonTopLeftViewController *)firstColumnInScrollView {
	if (nil == _firstColumnInScrollView) {
		_firstColumnInScrollView = [[A3LoanCalcComparisonTopLeftViewController alloc] initWithNibName:@"A3LoanCalcComparisonTopLeftViewController_iPad" bundle:nil];
	}
	return _firstColumnInScrollView;
}

- (A3LoanCalcPrincipalBarChartController *)secondColumnInScrollView {
	if (nil == _secondColumnInScrollView) {
		_secondColumnInScrollView = [[A3LoanCalcPrincipalBarChartController alloc] init];
	}
	return _secondColumnInScrollView;
}

- (A3LoanCalcPrincipalBarChartController *)thirdColumnInScrollView {
	if (nil == _thirdColumnInScrollView) {
		_thirdColumnInScrollView = [[A3LoanCalcPrincipalBarChartController alloc] init];
	}
	return _thirdColumnInScrollView;
}

- (A3LoanCalcSingleBarChartController *)fourthColumnInScrollView {
	if (nil == _fourthColumnInScrollView) {
		_fourthColumnInScrollView = [[A3LoanCalcSingleBarChartController alloc] init];
	}
	return _fourthColumnInScrollView;
}

- (void)loanCalcComparisonTableViewValueChanged {
	[_firstColumnInScrollView updateLabels];
	[_secondColumnInScrollView reloadData];
	[_thirdColumnInScrollView reloadData];
	[_fourthColumnInScrollView reloadData];
}

- (UIFont *)fontForEntryCellTextField {
	return [UIFont boldSystemFontOfSize:23.0];
}

@end
