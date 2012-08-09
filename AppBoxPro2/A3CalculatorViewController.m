//
//  A3CalculatorViewController.m
//  AppBoxPro2
//
//  Created by Byeong Kwon Kwak on 6/30/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "A3CalculatorViewController.h"
#import "common.h"
#import "CommonUIDefinitions.h"
#import "DDPageControl.h"
#import "A3CalculatorButtonsViewController.h"
#import "A3GrayAppHeaderView.h"
#import "CoolButton.h"
#import "A3CalcExpressionView.h"
#import "A3CalcHistoryViewCell.h"

@interface A3CalculatorViewController ()
- (void)buildGradientLayers;

@property (nonatomic, strong) IBOutlet UIScrollView *buttonsScrollView;
@property (nonatomic, strong) UIView *topLineAboveHistoryHeaderView;
@property (nonatomic, strong) DDPageControl *pageControl;
@property (nonatomic, strong) A3GrayAppHeaderView *grayAppHeaderView;
@property (nonatomic, strong) CoolButton *editHistoryButton;
@property (nonatomic, strong) UITableView *historyTableView;
@property (nonatomic, strong) IBOutlet A3CalcExpressionView *expressionView;

- (void)layoutSubViews;

@end

@implementation A3CalculatorViewController
@synthesize buttonsScrollView = _buttonsScrollView;
@synthesize pageControl = _pageControl;
@synthesize topLineAboveHistoryHeaderView = _topLineAboveHistoryHeaderView;
@synthesize grayAppHeaderView = _grayAppHeaderView;
@synthesize historyTableView = _historyTableView;
@synthesize editHistoryButton = _editHistoryButton;
@synthesize expressionView = _expressionView;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillLayoutSubviews {
	[super viewWillLayoutSubviews];
	FNLOG(@"pass");
}

- (void)viewDidLayoutSubviews {
	[super viewDidLayoutSubviews];
	FNLOG(@"Passed");

	[self layoutSubViews];
}

- (void)viewDidLoad
{
	FNLOG(@"viewDidLoad");

    [super viewDidLoad];
	// Do any additional setup after loading the view.
	[self buildGradientLayers];

	self.pageControl = [[DDPageControl alloc] init];
	[self.pageControl setCenter: CGPointMake(APP_VIEW_WIDTH / 2.0f, IPAD_SCREEN_HEIGHT_LANDSCAPE - (44.0f / 2.0f)) ];
	[self.pageControl setNumberOfPages: 2 ];
	[self.pageControl setCurrentPage: 0 ];
	[self.pageControl addTarget: self action: @selector(pageControlClicked:) forControlEvents: UIControlEventValueChanged] ;
	[self.pageControl setType: DDPageControlTypeOnFullOffEmpty] ;
	[self.pageControl setOnColor: [UIColor colorWithRed:91.0f/255.0f green:91.0f/255.0f blue:91.0f/255.0f alpha:1.0f] ];
	[self.pageControl setOffColor: [UIColor blackColor] ];
	[self.pageControl setIndicatorDiameter: 11.0f ];
	[self.pageControl setIndicatorSpace: 10.0f ];
	[self.view addSubview:self.pageControl];

	[self.buttonsScrollView setContentSize:CGSizeMake(APP_VIEW_WIDTH * 2.0, CGRectGetHeight(self.buttonsScrollView.bounds))];

	UIViewController *viewController = [[A3CalculatorButtonsViewController alloc] initWithNibName:@"CalculatorButtonsInFirstPage" bundle:nil];
	[viewController.view setFrame:CGRectMake(0.0f, 0.0f, APP_VIEW_WIDTH, CGRectGetHeight(viewController.view.bounds))];
	[self.buttonsScrollView addSubview: [viewController view] ];

	UIViewController *viewController2 = [[A3CalculatorButtonsViewController alloc] initWithNibName:@"CalculatorButtonsInSecondPage" bundle:nil];
	[viewController2.view setFrame:CGRectMake(APP_VIEW_WIDTH, 0.0f, APP_VIEW_WIDTH, CGRectGetHeight(viewController2.view.bounds))];
	[self.buttonsScrollView addSubview: [viewController2 view] ];
	
	self.topLineAboveHistoryHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
	self.topLineAboveHistoryHeaderView.backgroundColor = [UIColor blackColor];
	[self.view addSubview:self.topLineAboveHistoryHeaderView];

	self.grayAppHeaderView = [[A3GrayAppHeaderView alloc] initWithFrame:CGRectZero];
    [self.grayAppHeaderView setTitle:@"History"];

    [self.view addSubview:self.grayAppHeaderView];

	self.historyTableView = [[UITableView alloc] initWithFrame:CGRectZero];
	self.historyTableView.backgroundColor = [UIColor colorWithRed:245.0f/255.0f green:245.0f/255.0f blue:245.0f/255.0f alpha:1.0f];
	self.historyTableView.delegate = self;
	self.historyTableView.dataSource = self;
	self.historyTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	[self.view addSubview:self.historyTableView];

	[self.expressionView setExpression:[NSArray arrayWithObjects:@"24.97", @"x", @"8.75", @"x", nil]];
	[self.expressionView setStyle:CEV_FILL_BACKGROUND];
//	[self.expressionView setStyle:CEV_TRANSPARENT_BACKGROUND];
	[self.expressionView setNeedsDisplay];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#define	A3_CALCULATOR_VIEW_BORDER_GRADIENT_SIZE						6.0f
#define A3_CALCULATOR_VIEW_HEIGHT_OF_TOPLINE_ABOVE_TABLE_HEADER		10.0f
#define A3_CALCULATOR_HISTORY_HEADER_HEIGHT							40.0f
#define A3_CALCULATOR_HISTORY_EDIT_BUTTON_WIDTH                     46.0f
#define A3_CALCULATOR_HISTORY_EDIT_BUTTON_HEIGHT                    30.0f


- (void)layoutSubViews {
	if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
		CGFloat historyViewWidth = IPAD_SCREEN_WIDTH_LANDSCAPE - HOT_MENU_VIEW_WIDTH - APP_VIEW_WIDTH;
		[self.topLineAboveHistoryHeaderView setFrame:CGRectMake(APP_VIEW_WIDTH, 0.0f, historyViewWidth, A3_CALCULATOR_VIEW_HEIGHT_OF_TOPLINE_ABOVE_TABLE_HEADER)];
		[self.grayAppHeaderView setFrame:CGRectMake(APP_VIEW_WIDTH, 10.0f, historyViewWidth, A3_CALCULATOR_HISTORY_HEADER_HEIGHT)];
        [self.editHistoryButton setFrame:CGRectMake(historyViewWidth - A3_CALCULATOR_HISTORY_EDIT_BUTTON_WIDTH - 10.0f, A3_CALCULATOR_HISTORY_HEADER_HEIGHT / 2.0f - 15.0f, A3_CALCULATOR_HISTORY_EDIT_BUTTON_WIDTH, A3_CALCULATOR_HISTORY_EDIT_BUTTON_HEIGHT)];
		[self.historyTableView setFrame:CGRectMake(APP_VIEW_WIDTH, 10.0f + A3_CALCULATOR_HISTORY_HEADER_HEIGHT, historyViewWidth, IPAD_SCREEN_HEIGHT_LANDSCAPE - 10.0f - A3_CALCULATOR_HISTORY_HEADER_HEIGHT)];
	} else {
		CGFloat historyViewWidth = APP_VIEW_WIDTH;
		[self.topLineAboveHistoryHeaderView setFrame:CGRectMake(0.0f, IPAD_SCREEN_HEIGHT_LANDSCAPE, historyViewWidth, 10.0f)];
		[self.grayAppHeaderView setFrame:CGRectMake(0.0f, IPAD_SCREEN_HEIGHT_LANDSCAPE + 10.0f, historyViewWidth, A3_CALCULATOR_HISTORY_HEADER_HEIGHT)];
        [self.editHistoryButton setFrame:CGRectMake(historyViewWidth - 10.0f - A3_CALCULATOR_HISTORY_EDIT_BUTTON_WIDTH, A3_CALCULATOR_HISTORY_HEADER_HEIGHT/2.0f - 15.0f, A3_CALCULATOR_HISTORY_EDIT_BUTTON_WIDTH, A3_CALCULATOR_HISTORY_EDIT_BUTTON_HEIGHT)];
		[self.historyTableView setFrame:CGRectMake(0.0f, IPAD_SCREEN_HEIGHT_LANDSCAPE + 10.0f + A3_CALCULATOR_HISTORY_HEADER_HEIGHT, historyViewWidth, IPAD_SCREEN_HEIGHT_PORTRAIT - IPAD_SCREEN_HEIGHT_LANDSCAPE - 10.0f - A3_CALCULATOR_HISTORY_HEADER_HEIGHT)];
	}
}

- (void)buildGradientLayers {
	CGRect bounds = self.view.layer.bounds;

	CAGradientLayer *leftBorderGradient = [CAGradientLayer layer];
	leftBorderGradient.anchorPoint = CGPointMake(0.0f, 0.0f);
	leftBorderGradient.bounds = CGRectMake(CGRectGetMinX(bounds), CGRectGetMinY(bounds), A3_CALCULATOR_VIEW_BORDER_GRADIENT_SIZE, CGRectGetHeight(bounds) - A3_APP_HEADER_BAR_HEIGHT);
	leftBorderGradient.position = CGPointMake(0.0f, A3_APP_HEADER_BAR_HEIGHT);
	leftBorderGradient.colors = [NSArray arrayWithObjects:
			(__bridge id)[UIColor colorWithRed:203.0f/255.0f green:205.0f/255.0f blue:206.0f/255.0f alpha:1.0f].CGColor,
			(__bridge id)[UIColor colorWithRed:240.0f/255.0f green:242.0f/255.0f blue:243.0f/255.0f alpha:1.0f].CGColor,
			nil];
	leftBorderGradient.startPoint = CGPointMake(0.0f, 0.5f);
	leftBorderGradient.endPoint = CGPointMake(1.0f, 0.5f);
	[self.view.layer addSublayer:leftBorderGradient];

	CAGradientLayer *rightBorderGradient = [CAGradientLayer layer];
	rightBorderGradient.anchorPoint = CGPointMake(0.0f, 0.0f);
	rightBorderGradient.bounds = CGRectMake(CGRectGetMinX(bounds), CGRectGetMinY(bounds), A3_CALCULATOR_VIEW_BORDER_GRADIENT_SIZE, CGRectGetHeight(bounds) - A3_APP_HEADER_BAR_HEIGHT);
	rightBorderGradient.position = CGPointMake(CGRectGetWidth(bounds) - A3_CALCULATOR_VIEW_BORDER_GRADIENT_SIZE, A3_APP_HEADER_BAR_HEIGHT);
	rightBorderGradient.colors = [NSArray arrayWithObjects:
			(__bridge id)[UIColor colorWithRed:240.0f/255.0f green:242.0f/255.0f blue:243.0f/255.0f alpha:1.0f].CGColor,
			(__bridge id)[UIColor colorWithRed:208.0f/255.0f green:210.0f/255.0f blue:211.0f/255.0f alpha:1.0f].CGColor,
			nil];
	rightBorderGradient.startPoint = CGPointMake(0.0f, 0.5f);
	rightBorderGradient.endPoint = CGPointMake(1.0f, 0.5f);
	[self.view.layer addSublayer:rightBorderGradient];

	CAGradientLayer *bottomBorderGradient = [CAGradientLayer layer];
	bottomBorderGradient.anchorPoint = CGPointMake(0.0f, 0.0f);
	bottomBorderGradient.bounds = CGRectMake(CGRectGetMinX(bounds), CGRectGetMinY(bounds), APP_VIEW_WIDTH, A3_CALCULATOR_VIEW_BORDER_GRADIENT_SIZE);
	bottomBorderGradient.position = CGPointMake(0.0f, CGRectGetHeight(bounds) - A3_CALCULATOR_VIEW_BORDER_GRADIENT_SIZE);
	FNLOG(@"%f, %f", bottomBorderGradient.position.x, bottomBorderGradient.position.y);
	bottomBorderGradient.colors = [NSArray arrayWithObjects:
			(__bridge id)[UIColor colorWithRed:240.0f/255.0f green:242.0f/255.0f blue:243.0f/255.0f alpha:1.0f].CGColor,
			(__bridge id)[UIColor colorWithRed:186.0f/255.0f green:188.0f/255.0f blue:189.0f/255.0f alpha:1.0f].CGColor,
			nil];
	bottomBorderGradient.startPoint = CGPointMake(0.5f, 0.0f);
	bottomBorderGradient.endPoint = CGPointMake(0.5f, 1.0f);
	[self.view.layer addSublayer:bottomBorderGradient];

	CGFloat separatorOrigin_Y = IPAD_SCREEN_HEIGHT_LANDSCAPE - 44.0;

	CALayer *separatorLayerUp = [CALayer layer];
	separatorLayerUp.bounds = CGRectMake(CGRectGetMinX(bounds), CGRectGetMinY(bounds), CGRectGetWidth(bounds), 1.0f);
	separatorLayerUp.position = CGPointMake(CGRectGetMinX(bounds), separatorOrigin_Y);
	separatorLayerUp.backgroundColor = [UIColor colorWithRed:216.0f/255.0f green:217.0f/255.0f blue:218.0f/255.0f alpha:1.0f].CGColor;
	separatorLayerUp.anchorPoint = CGPointMake(0.0f, 0.0f);
	[self.view.layer addSublayer:separatorLayerUp];

	CALayer *separatorLayerDown = [CALayer layer];
	separatorLayerDown.bounds = CGRectMake(CGRectGetMinX(bounds), CGRectGetMinY(bounds), CGRectGetWidth(bounds), 1.0f);
	separatorLayerDown.position = CGPointMake(CGRectGetMinX(bounds), separatorOrigin_Y + 1.0f);
	separatorLayerDown.backgroundColor = [UIColor colorWithRed:254.0f/255.0f green:254.0f/255.0f blue:254.0f/255.0f alpha:1.0f].CGColor;
	separatorLayerDown.anchorPoint = CGPointMake(0.0f, 0.0f);
	[self.view.layer addSublayer:separatorLayerDown];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	NSInteger currentPage = scrollView.contentOffset.x / APP_VIEW_WIDTH;
	[self.pageControl setCurrentPage:currentPage];
}

- (void)pageControlClicked:(DDPageControl *)control {
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.4];
	[self.buttonsScrollView setContentOffset:CGPointMake(APP_VIEW_WIDTH * control.currentPage, 0.0f)];
	[UIView commitAnimations];
}

#define ACALC_UI_HISTORY_CELL_HEIGHT			90.0f

#pragma mark -- UITableView data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *cellIdentifier = @"CalcHistoryCell";
	A3CalcHistoryViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (nil == cell) {
		cell = [[A3CalcHistoryViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
	}

	return cell;
}

#pragma mark -- UITableView delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return ACALC_UI_HISTORY_CELL_HEIGHT;
}


#pragma mark -- Button actions

- (CoolButton *)editHistoryButton {
    if (nil == _editHistoryButton) {
        _editHistoryButton = [[CoolButton alloc] initWithFrame:CGRectZero];
        _editHistoryButton.buttonColor = [UIColor colorWithRed:135.0f/255.0f green:135.0f/255.0f blue:135.0f/255.0f alpha:1.0f];
        _editHistoryButton.titleLabel.textColor = [UIColor whiteColor];
        _editHistoryButton.titleLabel.font = [UIFont boldSystemFontOfSize:13.0];
        [_editHistoryButton setTitle:@"Edit" forState:UIControlStateNormal];
        [self.grayAppHeaderView addSubview:_editHistoryButton];
    }
    return _editHistoryButton;
}

- (IBAction)settingsButtonAction:(id)button {
	
}

@end
