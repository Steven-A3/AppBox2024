//
//  A3LoanCalcComparisonMainViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 3/21/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import "A3LoanCalcComparisonMainViewController.h"
#import "A3LoanCalcComparisonTopLeftViewController.h"
#import "A3LoanCalcBarPlotItem.h"
#import "DDPageControl.h"
#import "A3CircleView.h"
#import "common.h"
#import "A3LoanCalcComparisonTableViewDataSource.h"
#import "A3AppDelegate.h"
#import "A3LoanCalcPreferences.h"
#import "CommonUIDefinitions.h"
#import "EKKeyboardAvoidingScrollViewManager.h"

@interface A3LoanCalcComparisonMainViewController ()

@property (nonatomic, weak) IBOutlet UIScrollView *mainScrollView;
@property (nonatomic, weak) IBOutlet UIScrollView *topScrollView;
@property (nonatomic, weak) IBOutlet UITableView *leftTableView;
@property (nonatomic, weak) IBOutlet UITableView *rightTableView;
@property (nonatomic, weak) IBOutlet UIImageView *principalImageView;
@property (nonatomic, weak) IBOutlet UIImageView *downPaymentImageView;
@property (nonatomic, weak) IBOutlet UIImageView *termImageView;
@property (nonatomic, weak) IBOutlet UIImageView *interestRateImageView;
@property (nonatomic, weak) IBOutlet UIImageView *frequencyImageView;
@property (nonatomic, weak) IBOutlet UIImageView *startDateImageView;
@property (nonatomic, weak) IBOutlet UIImageView *notesImageView;
@property (nonatomic, weak) IBOutlet UIImageView *extraPaymentMonthlyImageView;
@property (nonatomic, weak) IBOutlet UIImageView *extraPaymentYearlyImageView;
@property (nonatomic, weak) IBOutlet UIImageView *extraPaymentOneTimeImageView;
@property (nonatomic, weak) IBOutlet A3CircleView *loanACircleView, *loanBCircleView;
@property (nonatomic, weak) IBOutlet DDPageControl *pageControl;

@property (nonatomic, strong) A3LoanCalcComparisonTopLeftViewController *firstColumnInScrollView;

@property (nonatomic, strong) A3LoanCalcBarPlotItem *secondColumnInScrollView;
@property (nonatomic, strong) A3LoanCalcBarPlotItem *thirdColumnInScrollView;
@property (nonatomic, strong) A3LoanCalcBarPlotItem *fourthColumnInScrollView;

@property (nonatomic, strong) A3LoanCalcComparisonTableViewDataSource *leftTableViewDataSource, *rightTableViewDataSource;
@property (nonatomic, strong) LoanCalcHistory *leftObject, *rightObject;

@end

@implementation A3LoanCalcComparisonMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc {
	FNLOG(@"dealloc?");
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do any additional setup after loading the view from its nib.

	[self configureTopScrollView];
	[self reloadScrollViewContentSize];

	_loanACircleView.textLabel.text = @"A";
	_loanACircleView.textLabel.textColor = [UIColor colorWithRed:115.0/255.0 green:115.0/255.0 blue:115.0/255.0 alpha:1.0];
	_loanBCircleView.textLabel.text = @"B";
	_loanBCircleView.textLabel.textColor = [UIColor whiteColor];
	_loanBCircleView.backgroundColor = [UIColor colorWithRed:165.0/255.0 green:166.0/255.0 blue:169.0/255.0 alpha:1.0];

	self.leftTableViewDataSource.object = self.leftObject;
	self.rightTableViewDataSource.object = self.rightObject;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	[[EKKeyboardAvoidingScrollViewManager sharedInstance] registerScrollViewForKeyboardAvoiding:self.mainScrollView];
	[self.leftTableViewDataSource registerKeyboardNotification];
	[self.rightTableViewDataSource registerKeyboardNotification];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];

	[self.leftTableViewDataSource removeObservers];
	[self.rightTableViewDataSource removeObservers];
	[[EKKeyboardAvoidingScrollViewManager sharedInstance] unregisterScrollViewFromKeyboardAvoiding:self.mainScrollView];
}

- (void)configureTopScrollView {
	CGRect bounds = _topScrollView.bounds;
	[_topScrollView setContentSize:CGSizeMake(bounds.size.width * 2.0, bounds.size.height)];
	_topScrollView.backgroundColor = [UIColor clearColor];
	_topScrollView.pagingEnabled = YES;
	_topScrollView.showsHorizontalScrollIndicator = NO;
	_topScrollView.showsVerticalScrollIndicator = NO;

	// add top left view
	[_topScrollView addSubview:self.firstColumnInScrollView.view];

	CGRect boundsParent = self.topScrollView.bounds;
	CGFloat columnWidth = boundsParent.size.width / 2.0;
	self.secondColumnInScrollView.graphHostingView.frame = CGRectMake(columnWidth, 0.0, columnWidth, boundsParent.size.height);
	[_topScrollView addSubview:self.secondColumnInScrollView.graphHostingView];

	_secondColumnInScrollView.totalInterest_A = [NSNumber numberWithFloat:100.0];
	_secondColumnInScrollView.totalInterest_B = [NSNumber numberWithFloat:100.0];
	_secondColumnInScrollView.principal_A = [NSNumber numberWithFloat:1000.0];
	_secondColumnInScrollView.principal_B = [NSNumber numberWithFloat:1000.0];

	[_secondColumnInScrollView addBarPlotForPrincipal];

	UIColor *lineColor = [UIColor colorWithRed:213.0/255.0 green:207.0/255.0 blue:192.0/255.0 alpha:1.0];
	// add vertical line in the first page.
	UIView *verticalLine1 = [[UIView alloc] initWithFrame:CGRectMake(bounds.size.width / 2.0, 0.0, 1.0, 211.0)];
	verticalLine1.backgroundColor = lineColor;
	[_topScrollView addSubview:verticalLine1];

	// add vertical line in the second page.
	UIView *verticalLine2 = [[UIView alloc] initWithFrame:CGRectMake(bounds.size.width / 2.0 * 3.0, 0.0, 1.0, 211.0)];
	verticalLine2.backgroundColor = lineColor;
	[_topScrollView addSubview:verticalLine2];

	[_pageControl setNumberOfPages:2];
	[_pageControl setCurrentPage:0];
	[_pageControl setType:DDPageControlTypeOnFullOffEmpty];
	[_pageControl setOnColor: [UIColor colorWithRed:91.0/255.0 green:91.0/255.0 blue:91.0/255.0 alpha:1.0] ];
	[_pageControl setOffColor: [UIColor blackColor] ];
	[_pageControl setIndicatorDiameter: 6.0 ];
	[_pageControl setIndicatorSpace: 8.0 ];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (A3LoanCalcComparisonTopLeftViewController *)firstColumnInScrollView {
	if (nil == _firstColumnInScrollView) {
		_firstColumnInScrollView = [[A3LoanCalcComparisonTopLeftViewController alloc] initWithNibName:@"A3LoanCalcComparisonTopLeftViewController" bundle:nil];
	}
	return _firstColumnInScrollView;
}

- (A3LoanCalcBarPlotItem *)secondColumnInScrollView {
	if (nil == _secondColumnInScrollView) {
		_secondColumnInScrollView = [[A3LoanCalcBarPlotItem alloc] init];
	}
	return _secondColumnInScrollView;
}

- (A3LoanCalcBarPlotItem *)thirdColumnInScrollView {
	if (nil == _thirdColumnInScrollView) {
		_thirdColumnInScrollView = [[A3LoanCalcBarPlotItem alloc] init];
	}
	return _thirdColumnInScrollView;
}

- (A3LoanCalcBarPlotItem *)fourthColumnInScrollView {
	if (nil == _fourthColumnInScrollView) {
		_fourthColumnInScrollView = [[A3LoanCalcBarPlotItem alloc] init];
	}
	return _fourthColumnInScrollView;
}

- (A3LoanCalcComparisonTableViewDataSource *)leftTableViewDataSource {
	if (nil == _leftTableViewDataSource) {
		_leftTableViewDataSource = [[A3LoanCalcComparisonTableViewDataSource alloc] init];
		_leftTableViewDataSource.mainScrollView = self.mainScrollView;
		_leftTableViewDataSource.leftAlignment = YES;
		_leftTableView.delegate = _leftTableViewDataSource;
		_leftTableView.dataSource = _leftTableViewDataSource;
	}
	return _leftTableViewDataSource;
}

- (A3LoanCalcComparisonTableViewDataSource *)rightTableViewDataSource {
	if (nil == _rightTableViewDataSource) {
		_rightTableViewDataSource = [[A3LoanCalcComparisonTableViewDataSource alloc] init];
		_rightTableViewDataSource.mainScrollView = self.mainScrollView;
		_rightTableViewDataSource.leftAlignment = NO;
		_rightTableView.delegate = _rightTableViewDataSource;
		_rightTableView.dataSource = _rightTableViewDataSource;
	}
	return _rightTableViewDataSource;
}

- (LoanCalcHistory *)getEditingObjectForLeft:(BOOL)left {
	NSManagedObjectContext *managedObjectContext = [[A3AppDelegate instance] managedObjectContext];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"LoanCalcHistory" inManagedObjectContext:managedObjectContext];
	[fetchRequest setEntity:entity];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(editing == YES) and (location == %@)", left ? @"A" : @"B"];
	[fetchRequest setPredicate:predicate];
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"created" ascending:NO];
	[fetchRequest setSortDescriptors:@[sortDescriptor]];
	[fetchRequest setFetchLimit:1];
	NSError *error;
	NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];

	LoanCalcHistory *object;
	if ([fetchedObjects count]) {
		object = [fetchedObjects objectAtIndex:0];
		A3LoanCalcPreferences *preferences = [[A3LoanCalcPreferences alloc] init];
		[preferences setCalculationFor:(A3LoanCalcCalculationFor)[object.calculationFor unsignedIntegerValue]];
		[preferences setShowDownPayment:[object.showDownPayment boolValue]];
		[preferences setShowExtraPayment:[object.showExtraPayment boolValue]];
		[preferences setShowAdvanced:[object.showAdvanced boolValue]];
		[preferences setUseSimpleInterest:[object.useSimpleInterest boolValue]];
	} else {
		object = [NSEntityDescription insertNewObjectForEntityForName:@"LoanCalcHistory" inManagedObjectContext:managedObjectContext];
		LoanCalcHistory *rightObject = [NSEntityDescription insertNewObjectForEntityForName:@"LoanCalcHistory" inManagedObjectContext:managedObjectContext];
		[object initializeValues];
		object.location = @"A";

		[rightObject initializeValues];
		rightObject.location = @"B";
		rightObject.created = object.created;

		NSError *error;
		[managedObjectContext save:&error];
	}
	return object;
}

- (LoanCalcHistory *)leftObject {
	if (nil == _leftObject) {
		_leftObject = [self getEditingObjectForLeft:YES];
	}
	return _leftObject;
}

- (LoanCalcHistory *)rightObject {
	if (nil == _rightObject) {
		_rightObject = [self getEditingObjectForLeft:NO];
	}
	return _rightObject;
}

- (void)reloadScrollViewContentSize {
	CGFloat height = 289.0;
	CGFloat tableViewHeight = 0.0;
	A3LoanCalcPreferences *preferences = [[A3LoanCalcPreferences alloc] init];
	tableViewHeight += preferences.showAdvanced ? A3_LOAN_CALC_ROW_HEIGHT * 7.0 : A3_LOAN_CALC_ROW_HEIGHT * 4.0;
	tableViewHeight += preferences.showDownPayment ? A3_LOAN_CALC_ROW_HEIGHT : 0.0;
	tableViewHeight += preferences.showExtraPayment ? 53.0 + A3_LOAN_CALC_ROW_HEIGHT * 3.0 : 0.0;
	tableViewHeight += 34.0;

	CGRect frame = self.leftTableView.frame;
	frame.size.height = tableViewHeight;
	self.leftTableView.frame = frame;

	frame = self.rightTableView.frame;
	frame.size.height = tableViewHeight;
	self.rightTableView.frame = frame;

	self.mainScrollView.contentSize = CGSizeMake(714.0, height + tableViewHeight);
}

@end
