//
//  A3LoanCalcComparisonMainViewController_iPhone.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 05/23/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import "A3LoanCalcComparisonMainViewController_iPhone.h"
#import "A3LoanCalcComparisonTopLeftViewController.h"
#import "A3LoanCalcPrincipalBarChartController.h"
#import "A3LoanCalcSingleBarChartController.h"

@interface A3LoanCalcComparisonMainViewController_iPhone ()

@property (nonatomic, strong) A3LoanCalcComparisonTopLeftViewController *pageOne;
@property (nonatomic, strong) A3LoanCalcPrincipalBarChartController *pageTwo;
@property (nonatomic, strong) A3LoanCalcSingleBarChartController *pageThree;

@end

@implementation A3LoanCalcComparisonMainViewController_iPhone

- (void)configureTopScrollView {
	CGRect bounds = self.topScrollView.bounds;
	UIScrollView *scrollView = self.topScrollView;
	CGFloat width = bounds.size.width;
	CGFloat height = bounds.size.height;
	[scrollView setContentSize:CGSizeMake(width * 3.0, bounds.size.height)];

	[scrollView addSubview:self.pageOne.view];
	_pageOne.leftObject = self.leftObject;
	_pageOne.rightObject = self.rightObject;
	[_pageOne updateLabels];

	CGRect frame = CGRectMake(width, 0.0, width, height);
	self.pageTwo.graphHostingView.frame = frame;
	[scrollView addSubview:self.pageTwo.graphHostingView];
	_pageTwo.objectA = self.leftObject;
	_pageTwo.objectB = self.rightObject;
	[_pageTwo reloadData];

	frame = CGRectMake(width * 2.0, 0.0, width, height);
	self.pageThree.graphHostingView.frame = frame;
	[scrollView addSubview:self.pageThree.graphHostingView];
	_pageThree.objectA = self.leftObject;
	_pageThree.objectB = self.rightObject;
	[_pageThree reloadData];
}

- (void)pageControlValueChanged:(DDPageControl *)control {
	[self.topScrollView setContentOffset:CGPointMake(self.topScrollView.bounds.size.width * control.currentPage, 0.0) animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	self.pageControl.currentPage = (NSInteger) (self.topScrollView.contentOffset.x / self.topScrollView.bounds.size.width);
}

- (A3LoanCalcComparisonTopLeftViewController *)pageOne {
	if (nil == _pageOne) {
		_pageOne = [[A3LoanCalcComparisonTopLeftViewController alloc] initWithNibName:@"A3LoanCalcComparisonTopLeftViewController_iPhone" bundle:nil];
	}
	return _pageOne;
}

- (A3LoanCalcPrincipalBarChartController *)pageTwo {
	if (nil == _pageTwo) {
		_pageTwo = [[A3LoanCalcPrincipalBarChartController alloc] init];
	}
	return _pageTwo;
}

- (A3LoanCalcSingleBarChartController *)pageThree {
	if (nil == _pageThree) {
		_pageThree = [[A3LoanCalcSingleBarChartController alloc] init];
	}
	return _pageThree;
}

- (void)loanCalcComparisonTableViewValueChanged {
	[super loanCalcComparisonTableViewValueChanged];

	[_pageOne updateLabels];
	[_pageTwo reloadData];
	[_pageThree reloadData];
}

- (UIFont *)fontForEntryCellTextField {
	return [UIFont boldSystemFontOfSize:16.0];
}

@end
