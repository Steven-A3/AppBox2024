//
//  A3ExpenseListViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 2/5/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3ExpenseListViewController.h"
#import "A3UIKit.h"
#import "A3UIDevice.h"
#import "A3HorizontalBarContainerView.h"
#import "A3SmallButton.h"
#import "A3HorizontalBarChartView.h"
#import "A3NumberKeyboardViewController_iPad.h"
#import "ATSDragToReorderTableViewController.h"
#import "A3ExpenseListDetailsViewController.h"

@interface A3ExpenseListViewController () <UITextFieldDelegate, A3NumberKeyboardDelegate, A3ActionMenuViewControllerDelegate>

@property (nonatomic, weak) IBOutlet A3HorizontalBarContainerView *chartContainerView;
@property (nonatomic, weak) IBOutlet UITableView *myTableView;
@property (nonatomic, strong) A3ExpenseListDetailsViewController *detailsViewController;

@end

@implementation A3ExpenseListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		self.title = @"Expense List";
        [A3UIKit addTopGradientLayerToView:self.view];
	}
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	[self addToolsButtonWithAction:@selector(onActionButton)];

	A3SmallButton *editButton = [[A3SmallButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 32.0, 30.0)];
	NSString *imageFilePath = [[NSBundle mainBundle] pathForResource:@"edit" ofType:@"png"];
	[editButton setImage:[UIImage imageWithContentsOfFile:imageFilePath] forState:UIControlStateNormal];
	_chartContainerView.accessoryView = editButton;

	// Do any additional setup after loading the view.
	_chartContainerView.chartLabelColor = [UIColor colorWithRed:73.0/255.0 green:74.0/255.0 blue:73.0/255.0 alpha:1.0];
	if (DEVICE_IPAD) {
		_chartContainerView.chartLabelFont = [UIFont boldSystemFontOfSize:18.0];
		_chartContainerView.chartValueFont = [UIFont boldSystemFontOfSize:22.0];
		_chartContainerView.bottomValueFont = [UIFont boldSystemFontOfSize:20.0];
	} else {
		_chartContainerView.chartLabelFont = [UIFont boldSystemFontOfSize:13.0];
		_chartContainerView.chartValueFont = [UIFont boldSystemFontOfSize:20.0];
		_chartContainerView.chartLabelColor = [UIColor blackColor];
		_chartContainerView.bottomValueFont = [UIFont boldSystemFontOfSize:24.0];
	}
	_chartContainerView.labelLeftTop.text = @"Total";
	_chartContainerView.labelLeftTop.font = _chartContainerView.chartLabelFont;
	_chartContainerView.labelRightTop.textColor = _chartContainerView.chartLabelColor;

	_chartContainerView.labelRightTop.text = @"Left";
	_chartContainerView.labelRightTop.font = _chartContainerView.chartLabelFont;
	_chartContainerView.labelRightTop.textColor = [UIColor colorWithRed:42.0/255.0 green:125.0/255.0 blue:0.0 alpha:1.0];

	_chartContainerView.bottomLabel.text = @"Budget";
	_chartContainerView.bottomLabel.font = _chartContainerView.chartLabelFont;
	_chartContainerView.bottomLabel.textColor = _chartContainerView.chartLabelColor;

	_chartContainerView.bottomValueLabel.text = @"$250.00";
	_chartContainerView.bottomValueLabel.font = _chartContainerView.bottomValueFont;

	_chartContainerView.chartLeftValueLabel.textColor = [UIColor whiteColor];
	_chartContainerView.chartLeftValueLabel.font = _chartContainerView.chartValueFont;

	_chartContainerView.chartRightValueLabel.textColor = [UIColor whiteColor];
	_chartContainerView.chartRightValueLabel.font = _chartContainerView.chartValueFont;
	_chartContainerView.chartRightValueLabel.text = @"$0.00";

	_chartContainerView.percentBarChart.leftValue = 183.49;
	_chartContainerView.percentBarChart.rightValue = 66.51;

	[_chartContainerView setBottomLabelText:_chartContainerView.bottomValueLabel.text];

	[_myTableView addSubview:self.detailsViewController.view];
}

- (A3ExpenseListDetailsViewController *)detailsViewController {
	if (nil == _detailsViewController) {
		_detailsViewController = [[A3ExpenseListDetailsViewController alloc] initWithStyle:UITableViewStylePlain];
		_detailsViewController.view.frame = _myTableView.bounds;
		_detailsViewController.chartContainerView = self.chartContainerView;
	}
	return _detailsViewController;
}

- (IBAction)addNewItemButtonAction {
	[self.detailsViewController addNewItemButtonAction];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	[self.detailsViewController calculate];
}

- (void)onActionButton {
	[self presentActionMenuWithDelegate:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
