//
//  A3LoanCalcQuickDialogViewController_iPhone.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 05/21/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3LoanCalcQuickDialogViewController_iPhone.h"
#import "A3LoanCalcString.h"
#import "CommonUIDefinitions.h"
#import "DDPageControl.h"
#import "A3OnOffLeftRightButton.h"
#import "A3LoanCalcPieChartController.h"
#import "A3LoanCalcAmortizationViewController_iPhone.h"

@interface A3LoanCalcQuickDialogViewController_iPhone () <A3LoanCalcChartViewControllerDelegate, UIScrollViewDelegate>

@property (nonatomic, strong)	UIScrollView *tableHeaderScrollView_iPhone;
@property (nonatomic, strong)	A3LoanCalcChartViewController_iPhone *firstPage_iPhone;
@property (nonatomic, strong)	A3LoanCalcChartViewController_iPhone *secondPage_iPhone;
@property (nonatomic, strong)	DDPageControl *pageControl;

@end


@implementation A3LoanCalcQuickDialogViewController_iPhone

- (QElement *)calculationForElement {
	QLabelElement *section1element = [[QLabelElement alloc] initWithTitle:[A3LoanCalcString stringFromCalculationFor:self.preferences.calculationFor] Value:self.valueForCalculationForField];
	section1element.key = A3LC_KEY_CALCULATION_FOR;
	QAppearance *appearance = [QLabelElement appearance];
	appearance.labelFont = [UIFont boldSystemFontOfSize:18.0];
	appearance.labelColorEnabled = [UIColor blackColor];
	appearance.labelColorDisabled = [UIColor blackColor];
	appearance.valueFont = [UIFont systemFontOfSize:18.0];
	appearance.valueColorEnabled = [UIColor colorWithRed:55.0 / 255.0 green:84.0 / 255.0 blue:135.0 / 255.0 alpha:1.0];
	appearance.valueColorDisabled = [UIColor colorWithRed:55.0 / 255.0 green:84.0 / 255.0 blue:135.0 / 255.0 alpha:1.0];
	section1element.appearance = appearance;
	section1element.onSelected = ^{
		[self onSelectCalculationFor];
	};
	return section1element;
}

- (void)cell:(UITableViewCell *)cell willAppearForElement:(QElement *)element atIndexPath:(NSIndexPath *)indexPath {
	[super cell:cell willAppearForElement:element atIndexPath:indexPath];

	if ([element.key isEqualToString:A3LC_KEY_CALCULATION_FOR]) {
		cell.textLabel.textColor = [UIColor blackColor];
		cell.textLabel.font = [UIFont boldSystemFontOfSize:18.0];
	}
}


-(void)sectionHeaderWillAppearForSection:(QSection *)section atIndex:(NSInteger)index {
	if (index == 2) {
		CGFloat viewHeight = 36.0;
		UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, APP_VIEW_WIDTH_iPHONE, viewHeight)];
		UILabel *sectionText = [[UILabel alloc] initWithFrame:CGRectMake(18.0, 0.0, APP_VIEW_WIDTH_iPHONE - 18.0 * 2.0, viewHeight)];
		sectionText.backgroundColor = [UIColor clearColor];
		sectionText.font = [UIFont boldSystemFontOfSize:18.0f];
		sectionText.textColor = [UIColor blackColor];
		sectionText.text = section.title;
		[headerView addSubview:sectionText];

		section.headerView = headerView;
	}
}

- (UIView *)tableHeaderView {
	UIView *tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 165.0)];
	_tableHeaderScrollView_iPhone = [[UIScrollView alloc] initWithFrame:tableHeaderView.bounds];
	_tableHeaderScrollView_iPhone.showsHorizontalScrollIndicator = NO;
	_tableHeaderScrollView_iPhone.contentSize = CGSizeMake(320.0 * 2.0, 165.0);
	_tableHeaderScrollView_iPhone.pagingEnabled = YES;
	_tableHeaderScrollView_iPhone.delegate = self;

	_firstPage_iPhone = [[A3LoanCalcChartViewController_iPhone alloc] initWithNibName:@"A3LoanCalcChartViewController_iPhone" bundle:nil];
	_firstPage_iPhone.delegate = self;
	[_tableHeaderScrollView_iPhone addSubview:_firstPage_iPhone.view];

	_secondPage_iPhone = [[A3LoanCalcChartViewController_iPhone alloc] initWithNibName:@"A3LoanCalcChartViewController_iPhone" bundle:nil];
	CGRect frame = _secondPage_iPhone.view.frame;

	frame.origin.x = frame.size.width;
	_secondPage_iPhone.view.frame = frame;
	_secondPage_iPhone.delegate = self;

	_secondPage_iPhone.row_one_title_label.text = @"Monthly Payment";
	_secondPage_iPhone.row_one_value_label.textColor = [UIColor colorWithRed:0.0 green:182.0 / 255.0 blue:180.0 / 255.0 alpha:12.0];
	_secondPage_iPhone.row_two_title_label.text = @"Monthly Avg. Interest";
	_secondPage_iPhone.row_two_value_label.textColor = [UIColor colorWithRed:235.0 / 255.0 green:100.0 / 255.0 blue:170.0 / 255.0 alpha:1.0];
	_secondPage_iPhone.row_three_title_label.hidden = YES;
	_secondPage_iPhone.row_three_value_label.hidden = YES;
	[_tableHeaderScrollView_iPhone addSubview:_secondPage_iPhone.view];

	[tableHeaderView addSubview:_tableHeaderScrollView_iPhone];

	_pageControl = [[DDPageControl alloc] init];
	_pageControl.center = CGPointMake(160.0, 150.0);
	[_pageControl addTarget:self action:@selector(pageControlPageChanged:) forControlEvents:UIControlEventValueChanged];
	[_pageControl setNumberOfPages:2];
	[_pageControl setCurrentPage:0];
	[_pageControl setType:DDPageControlTypeOnFullOffEmpty] ;
	[_pageControl setOnColor:[UIColor colorWithRed:91.0f / 255.0f green:91.0f / 255.0f blue:91.0f / 255.0f alpha:1.0f]];
	[_pageControl setOffColor:[UIColor blackColor]];
	[_pageControl setIndicatorDiameter:6.0f];
	[_pageControl setIndicatorSpace:8.0f];

	[tableHeaderView addSubview:_pageControl];

	_firstPage_iPhone.leftButton.selected = YES;
	_secondPage_iPhone.rightButton.selected = YES;

	_firstPage_iPhone.graphHostingView.hostedGraph = [self.chartController graphWithFrame:_firstPage_iPhone.graphHostingView.bounds for:A3LoanCalcGraphWithPrincipal];
	_secondPage_iPhone.graphHostingView.hostedGraph = [self.chartController graphWithFrame:_secondPage_iPhone.graphHostingView.bounds for:A3LoanCalcGraphWithMonthlyPayment];

	UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnHeaderView)];
	[tableHeaderView addGestureRecognizer:gestureRecognizer];
	return tableHeaderView;
}

- (void)tapOnHeaderView {
	A3LoanCalcAmortizationViewController_iPhone *viewController = [[A3LoanCalcAmortizationViewController_iPhone alloc] initWithNibName:@"A3LoanCalcAmortizationViewController_iPhone" bundle:nil];
	[viewController setObject:self.editingObject];
	[self.navigationController pushViewController:viewController animated:YES];
}

- (void)scrollToPage:(NSInteger)page {
	[_tableHeaderScrollView_iPhone setContentOffset:CGPointMake(320.0 * page, 0.0) animated:YES];
}

- (void)pageControlPageChanged:(DDPageControl *)pageControl {
	[self scrollToPage:pageControl.currentPage];
}

- (void)loanCalcChartViewButtonPressed:(BOOL)left {
	[self scrollToPage:left ? 0 : 1];
}

- (void)reloadGraphView {
	[super reloadGraphView];

	NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
	[nf setNumberStyle:NSNumberFormatterCurrencyStyle];
	_firstPage_iPhone.row_one_value_label.text = [nf stringFromNumber:self.chartController.totalAmount];
	_firstPage_iPhone.row_two_value_label.text = [nf stringFromNumber:self.chartController.principal];
	_firstPage_iPhone.row_three_value_label.text = [nf stringFromNumber:self.chartController.totalInterest];

	_secondPage_iPhone.row_one_value_label.text = [nf stringFromNumber:self.chartController.monthlyPayment];
	_secondPage_iPhone.row_two_value_label.text = [nf stringFromNumber:self.chartController.monthlyAverageInterest];

	[_firstPage_iPhone.graphHostingView.hostedGraph reloadData];
	[_secondPage_iPhone.graphHostingView.hostedGraph reloadData];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	[_pageControl setCurrentPage:(NSInteger) (scrollView.contentOffset.x / 320.0)];
}

@end
