//
//  A3ExpenseListViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 2/5/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3ExpenseListViewController.h"
#import "A3UIDevice.h"
#import "A3HorizontalBarContainerView.h"
#import "A3SmallButton.h"
#import "A3NumberKeyboardViewController_iPad.h"
#import "ATSDragToReorderTableViewController.h"
#import "A3ExpenseListDetailsTableViewController.h"
#import "A3VerticalLinesView.h"
#import "UIViewController+A3AppCategory.h"
#import "A3ExpenseListAddBudgetViewController.h"
#import "A3PaperFoldMenuViewController.h"
#import "A3AppDelegate.h"
#import "Expense.h"
#import "common.h"
#import <MessageUI/MessageUI.h>

@interface A3ExpenseListViewController () <UITextFieldDelegate, A3KeyboardDelegate, A3ActionMenuViewControllerDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic, weak) IBOutlet A3HorizontalBarContainerView *chartContainerView;
@property (nonatomic, weak) IBOutlet UITableView *myTableView;
@property (nonatomic, strong) A3ExpenseListDetailsTableViewController *detailsViewController;

@end

@implementation A3ExpenseListViewController {
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		self.title = @"Expense List";
	}
    return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];

	A3SmallButton *editButton = [[A3SmallButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 32.0, 30.0)];
	[editButton setImage:[UIImage imageNamed:@"edit"] forState:UIControlStateNormal];
	[editButton addTarget:self action:@selector(editButtonAction) forControlEvents:UIControlEventTouchUpInside];
	_chartContainerView.accessoryView = editButton;

	// Do any additional setup after loading the view.
	_chartContainerView.chartLabelColor = [UIColor colorWithRed:73.0/255.0 green:74.0/255.0 blue:73.0/255.0 alpha:1.0];
	if (IS_IPAD) {
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

	_chartContainerView.bottomValueLabel.text = [self currencyFormattedString:self.detailsViewController.expenseObject.budget];
	_chartContainerView.bottomValueLabel.font = _chartContainerView.bottomValueFont;

	_chartContainerView.chartLeftValueLabel.textColor = [UIColor whiteColor];
	_chartContainerView.chartLeftValueLabel.font = _chartContainerView.chartValueFont;

	_chartContainerView.chartRightValueLabel.textColor = [UIColor whiteColor];
	_chartContainerView.chartRightValueLabel.font = _chartContainerView.chartValueFont;

	[_chartContainerView setBottomLabelText:_chartContainerView.bottomValueLabel.text];

	[_detailsViewController calculate];

	A3VerticalLinesView *tableViewBackground = [[A3VerticalLinesView alloc] initWithFrame:_myTableView.bounds];
	if (IS_IPAD) {
		tableViewBackground.positions = @[@51.0, @53.0, @302.0, @412.0, @473.0];
	} else {
		tableViewBackground.positions = @[@40.0, @42.0, @142.0, @211.0, @240.0];
	}

	tableViewBackground.backgroundColor = [self tableViewBackgroundColor];
	[_myTableView addSubview:tableViewBackground];
	[_myTableView setScrollEnabled:NO];

	[_myTableView addSubview:self.detailsViewController.view];

	[self addTopGradientLayerToView:self.view position:1.0];
	[self addToolsButtonWithAction:@selector(onActionButton:)];

	[self.detailsViewController calculate];
}

- (void)editButtonAction {
	A3ExpenseListAddBudgetViewController *viewController = [[A3ExpenseListAddBudgetViewController alloc] initWithObject:self.detailsViewController.expenseObject];
	if (IS_IPAD) {
		MMDrawerController *mm_drawerController = [[A3AppDelegate instance] mm_drawerController];
		[mm_drawerController setRightDrawerViewController:viewController];
		[mm_drawerController openDrawerSide:MMDrawerSideRight animated:YES completion:nil];
	} else {
		UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
		[self presentViewController:navController animated:YES completion:nil];
	}
}

- (A3ExpenseListDetailsTableViewController *)detailsViewController {
	if (nil == _detailsViewController) {
		_detailsViewController = [[A3ExpenseListDetailsTableViewController alloc] initWithStyle:UITableViewStylePlain];
		_detailsViewController.view.frame = _myTableView.bounds;
		_detailsViewController.view.backgroundColor = _myTableView.backgroundColor;
		_detailsViewController.tableView.rowHeight = _myTableView.rowHeight;
		_detailsViewController.chartContainerView = self.chartContainerView;
	}
	return _detailsViewController;
}

- (IBAction)addNewItemButtonAction {
	[self.detailsViewController addNewItemButtonAction];
}

- (void)onActionButton:(UIButton *)button {
	if (IS_IPAD) {
		[self presentEmptyActionMenu];
		[self addActionIcon:@"t_newList" title:@"New List" selector:@selector(newListAction) atIndex:0];
		[self addActionIcon:@"t_history" title:@"History" selector:@selector(showHistoryAction) atIndex:1];
		[self addActionIcon:@"t_mail" title:@"Mail" selector:@selector(shareAction) atIndex:2];
	} else {
		[self presentActionMenuWithDelegate:self];
	}
}

- (void)newListAction {
	FNLOG();
	[self closeActionMenuViewWithAnimation:YES];
	[self.detailsViewController makeNewList];
}

- (void)showHistoryAction {
	[self closeActionMenuViewWithAnimation:YES];

	A3ExpenseListHistoryViewController *viewController = [[A3ExpenseListHistoryViewController alloc] initWithNibName:nil bundle:nil];
	viewController.delegate = self.detailsViewController;
	if (IS_IPAD){
		MMDrawerController *mm_drawerController = [[A3AppDelegate instance] mm_drawerController];
		[mm_drawerController setRightDrawerViewController:viewController];
		[mm_drawerController openDrawerSide:MMDrawerSideRight animated:YES completion:nil];
	} else {
		UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
		[self presentViewController:navController animated:YES completion:nil];
	}
}

- (void)shareAction {
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;

	[picker setSubject:@"Expense List"];

	// Attach an image to the email
//	NSString *path = [[NSBundle mainBundle] pathForResource:@"rainy" ofType:@"jpg"];
//	NSData *myData = [NSData dataWithContentsOfFile:path];
//	[picker addAttachmentData:myData mimeType:@"image/jpeg" fileName:@"rainy"];

	// Fill out the email body text
	NSString *emailBody = @"This is a Expense List data.";
	[picker setMessageBody:emailBody isHTML:NO];

	[self presentViewController:picker animated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller
		  didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
//	// Notifies users about errors associated with the interface
//	switch (result)
//	{
//		case MFMailComposeResultCancelled:
//			feedbackMsg.text = @"Result: Mail sending canceled";
//			break;
//		case MFMailComposeResultSaved:
//			feedbackMsg.text = @"Result: Mail saved";
//			break;
//		case MFMailComposeResultSent:
//			feedbackMsg.text = @"Result: Mail sent";
//			break;
//		case MFMailComposeResultFailed:
//			feedbackMsg.text = @"Result: Mail sending failed";
//			break;
//		default:
//			feedbackMsg.text = @"Result: Mail not sent";
//			break;
//	}
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
