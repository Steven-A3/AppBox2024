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
	NSInteger numberOfActions;
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
	NSString *imageFilePath = [[NSBundle mainBundle] pathForResource:@"edit" ofType:@"png"];
	[editButton setImage:[UIImage imageWithContentsOfFile:imageFilePath] forState:UIControlStateNormal];
	[editButton addTarget:self action:@selector(editButtonAction) forControlEvents:UIControlEventTouchUpInside];
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

	_chartContainerView.bottomValueLabel.text = [self currencyFormattedString:self.detailsViewController.expenseObject.budget];
	_chartContainerView.bottomValueLabel.font = _chartContainerView.bottomValueFont;

	_chartContainerView.chartLeftValueLabel.textColor = [UIColor whiteColor];
	_chartContainerView.chartLeftValueLabel.font = _chartContainerView.chartValueFont;

	_chartContainerView.chartRightValueLabel.textColor = [UIColor whiteColor];
	_chartContainerView.chartRightValueLabel.font = _chartContainerView.chartValueFont;

	[_chartContainerView setBottomLabelText:_chartContainerView.bottomValueLabel.text];

	[_detailsViewController calculate];

	A3VerticalLinesView *tableViewBackground = [[A3VerticalLinesView alloc] initWithFrame:_myTableView.bounds];
	if (DEVICE_IPAD) {
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
	if (DEVICE_IPAD){
		A3PaperFoldMenuViewController *paperFoldMenuViewController = [[A3AppDelegate instance] paperFoldMenuViewController];
		[paperFoldMenuViewController presentRightWingWithViewController:viewController onClose:nil];
	} else {
		UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
		[self applySilverNavigationBarStyleToNavigationVC:navController];
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
	button.enabled = NO;

	if (DEVICE_IPAD) {
		[self presentEmptyActionMenu];
		numberOfActions = 0;
		[self addActionIcon:@"t_newList" title:@"New List" selector:@selector(newListAction)];
		[self addActionIcon:@"t_history" title:@"History" selector:@selector(showHistoryAction)];
		[self addActionIcon:@"t_mail" title:@"Mail" selector:@selector(shareAction)];
	} else {
		[self presentActionMenuWithDelegate:self];
	}

	button.enabled = YES;
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
	if (DEVICE_IPAD){
		A3PaperFoldMenuViewController *paperFoldMenuViewController = [[A3AppDelegate instance] paperFoldMenuViewController];
		[paperFoldMenuViewController presentRightWingWithViewController:viewController onClose:nil];
	} else {
		UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
		[self applySilverNavigationBarStyleToNavigationVC:navController];
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

	[self presentModalViewController:picker animated:YES];
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
	[self dismissModalViewControllerAnimated:YES];
}

- (void)addActionIcon:(NSString *)iconName title:(NSString *)title selector:(SEL)selector {
	static NSArray *coordinateX;
	coordinateX = @[@156.0, @340.0, @523.0];

	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	NSString *path = [[NSBundle mainBundle] pathForResource:iconName ofType:@"png"];
	[button setImage:[UIImage imageWithContentsOfFile:path] forState:UIControlStateNormal];
	[button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
	button.frame = CGRectMake([coordinateX[numberOfActions] floatValue], 18.0, 32.0, 32.0);
	[self.actionMenuViewController.view addSubview:button];

	CGRect frame = CGRectMake([coordinateX[numberOfActions] floatValue] + 37.0, 19.0, 130.0, 32.0);
	UILabel *label = [[UILabel alloc] initWithFrame:frame];
	label.backgroundColor = [UIColor clearColor];
	label.text = title;
	label.font = [UIFont systemFontOfSize:14.5];
	label.textColor = [UIColor whiteColor];
	label.userInteractionEnabled = YES;
	[self.actionMenuViewController.view addSubview:label];

	UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:selector];
	[label addGestureRecognizer:tapGestureRecognizer];

	numberOfActions++;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
