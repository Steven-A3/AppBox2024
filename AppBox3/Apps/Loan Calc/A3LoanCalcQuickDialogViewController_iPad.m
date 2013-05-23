//
//  A3LoanCalcQuickDialogViewController_iPad
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 5/21/13 9:48 PM.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3LoanCalcQuickDialogViewController_iPad.h"
#import "CommonUIDefinitions.h"
#import "A3LoanCalcAmortizationViewController.h"
#import "A3LoanCalcString.h"

@interface A3LoanCalcQuickDialogViewController_iPad () <A3LoanCalcPieChartViewDelegate>
@property (nonatomic, strong)	A3LoanCalcAmortizationViewController *amortizationVC;
@end

@implementation A3LoanCalcQuickDialogViewController_iPad {

}

- (QElement *)calculationForElement {
	A3LabelElement *element = [[A3LabelElement alloc] initWithTitle:@"calculation for" Value:self.valueForCalculationForField];
	element.key = A3LC_KEY_CALCULATION_FOR;
	element.cellStyleDelegate = self;
	element.centerValue = [A3LoanCalcString stringFromCalculationFor:self.preferences.calculationFor];
	element.onSelected = ^{
		[self onSelectCalculationFor];
	};
	return element;
}

-(void)sectionHeaderWillAppearForSection:(QSection *)section atIndex:(NSInteger)index {
	if (index == 2) {
		UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, APP_VIEW_WIDTH_iPAD, 44.0f)];
		UILabel *sectionText = [[UILabel alloc] initWithFrame:CGRectMake(64.0f, 0.0f, APP_VIEW_WIDTH_iPAD - 64.0f * 2.0f, 44.0f)];
		sectionText.backgroundColor = [UIColor clearColor];
		sectionText.font = [UIFont boldSystemFontOfSize:24.0f];
		sectionText.textColor = [UIColor blackColor];
		sectionText.text = section.title;
		[headerView addSubview:sectionText];

		section.headerView = headerView;
	}
}

- (UIView *)tableHeaderView {
	return self.tableHeaderViewController.view;
}

- (UIViewController *)tableHeaderViewController {
	if (nil == super.tableHeaderViewController) {
		A3LoanCalcPieChartViewController *viewController =	[[A3LoanCalcPieChartViewController alloc] initWithNibName:@"A3LoanCalcPieChartViewController" bundle:nil];
		viewController.delegate = self;
		viewController.chartController = self.chartController;
		super.tableHeaderViewController = viewController;
	}
	return super.tableHeaderViewController;
}

- (void)reloadGraphView {
	[super reloadGraphView];

	A3LoanCalcPieChartViewController *viewController = (A3LoanCalcPieChartViewController *) self.tableHeaderViewController;
	[viewController reloadData];
}

- (void)loanCalcPieChartViewButtonPressed {
	self.quickDialogTableView.scrollEnabled = NO;
	_amortizationVC = [[A3LoanCalcAmortizationViewController alloc] initWithNibName:nil bundle:nil];
	_amortizationVC.object = self.editingObject;
	CGRect frame = self.quickDialogTableView.bounds;
	frame.origin.y = 274.0;
	frame.size.height -= 274.0;
	_amortizationVC.view.frame = frame;

	[self.view addSubview:_amortizationVC.view];
	[self addChildViewController:_amortizationVC];
}

@end