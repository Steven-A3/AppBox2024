//
//  A3LoanCalcQuickDialogViewController_iPad
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 5/21/13 9:48 PM.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import "A3LoanCalcQuickDialogViewController_iPad.h"
#import "A3LoanCalcAmortizationViewController.h"
#import "A3LoanCalcString.h"
#import "common.h"

@interface A3LoanCalcQuickDialogViewController_iPad () <A3LoanCalcPieChartViewDelegate>
@property (nonatomic, strong) A3LoanCalcAmortizationViewController *amortizationVC;
@property (nonatomic, strong) UIView *amortizationViewBackground;
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

#pragma mark -- Amortization View

- (UIView *)amortizationViewBackground {
	if (nil == _amortizationViewBackground) {
		CGRect frame;
		frame = self.view.bounds;
		frame.origin.y = 274.0;
		frame.size.height -= 274.0;
		_amortizationViewBackground = [[UIView alloc] initWithFrame:frame];
		_amortizationViewBackground.autoresizingMask = UIViewAutoresizingNone;
		_amortizationViewBackground.backgroundColor = [UIColor colorWithRed:248.0 / 255.0 green:248.0 / 255.0 blue:248.0 / 255.0 alpha:1.0];
		_amortizationViewBackground.restorationIdentifier = @"AmortizationViewBackground";
		_amortizationViewBackground.translatesAutoresizingMaskIntoConstraints = NO;
	}
	return _amortizationViewBackground;
}

- (void)loanCalcPieChartViewButtonPressed {
	self.quickDialogTableView.scrollEnabled = NO;

	_amortizationVC = [[A3LoanCalcAmortizationViewController alloc] initWithNibName:nil bundle:nil];
	_amortizationVC.object = self.editingObject;
	CGRect frame = self.amortizationViewBackground.bounds;
	FNLOGRECT(frame);
	frame = CGRectInset(frame, 44.0, 20.0);
	frame.size.height -= 24.0;
	_amortizationVC.view.frame = frame;
	_amortizationVC.view.translatesAutoresizingMaskIntoConstraints = NO;
	_amortizationVC.view.restorationIdentifier = @"AmortizationViewController.view";
	[self.amortizationViewBackground addSubview:_amortizationVC.view];

	[self.view addSubview:self.amortizationViewBackground];
	[self addChildViewController:_amortizationVC];

	[self.view addConstraints:
			@[
					[NSLayoutConstraint constraintWithItem:_amortizationViewBackground
												 attribute:NSLayoutAttributeLeft
												 relatedBy:NSLayoutRelationEqual
													toItem:_amortizationViewBackground.superview
												 attribute:NSLayoutAttributeLeft
												multiplier:1.0
												  constant:0.0],
					[NSLayoutConstraint constraintWithItem:_amortizationViewBackground
												 attribute:NSLayoutAttributeTop
												 relatedBy:NSLayoutRelationEqual
													toItem:_amortizationViewBackground.superview
												 attribute:NSLayoutAttributeTop
												multiplier:1.0
												  constant:274.0],
					[NSLayoutConstraint constraintWithItem:_amortizationViewBackground
												 attribute:NSLayoutAttributeWidth
												 relatedBy:NSLayoutRelationEqual
													toItem:_amortizationViewBackground.superview
												 attribute:NSLayoutAttributeWidth
												multiplier:1.0
												  constant:0.0],
					[NSLayoutConstraint constraintWithItem:_amortizationViewBackground
												 attribute:NSLayoutAttributeBottom
												 relatedBy:NSLayoutRelationEqual
													toItem:_amortizationViewBackground.superview
												 attribute:NSLayoutAttributeBottom
												multiplier:1.0
												  constant:0.0]
			]
	];

	[_amortizationViewBackground addConstraints:@[
			[NSLayoutConstraint constraintWithItem:_amortizationVC.view
										 attribute:NSLayoutAttributeLeft
										 relatedBy:NSLayoutRelationEqual
											toItem:_amortizationViewBackground
										 attribute:NSLayoutAttributeLeft
										multiplier:1
										  constant:44],
			[NSLayoutConstraint constraintWithItem:_amortizationVC.view
										 attribute:NSLayoutAttributeWidth
										 relatedBy:NSLayoutRelationEqual
											toItem:_amortizationViewBackground
										 attribute:NSLayoutAttributeWidth
										multiplier:1
										  constant:-88],
			[NSLayoutConstraint constraintWithItem:_amortizationVC.view
										 attribute:NSLayoutAttributeTop
										 relatedBy:NSLayoutRelationEqual
											toItem:_amortizationViewBackground
										 attribute:NSLayoutAttributeTop
										multiplier:1
										  constant:20],
			[NSLayoutConstraint constraintWithItem:_amortizationVC.view
										 attribute:NSLayoutAttributeBottom
										 relatedBy:NSLayoutRelationEqual
											toItem:_amortizationViewBackground
										 attribute:NSLayoutAttributeBottom
										multiplier:1
										  constant:-44],
	]];

}

@end
