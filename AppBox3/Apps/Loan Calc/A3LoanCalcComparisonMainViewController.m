//
//  A3LoanCalcComparisonMainViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 3/21/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>
#import "A3LoanCalcComparisonMainViewController.h"
#import "A3LoanCalcComparisonTopLeftViewController.h"
#import "A3LoanCalcPrincipalBarChartController.h"
#import "DDPageControl.h"
#import "A3CircleView.h"
#import "common.h"
#import "A3LoanCalcComparisonTableViewDataSource.h"
#import "A3AppDelegate.h"
#import "A3LoanCalcPreferences.h"
#import "EKKeyboardAvoidingScrollViewManager.h"
#import "A3LoanCalcSingleBarChartController.h"

@interface A3LoanCalcComparisonMainViewController () <A3LoanCalcComparisonTableViewDataSourceDelegate>

@property (nonatomic, weak) IBOutlet UIScrollView *mainScrollView;
@property (nonatomic, weak) IBOutlet UIScrollView *topScrollView;
@property (nonatomic, weak) IBOutlet UITableView *leftTableView;
@property (nonatomic, weak) IBOutlet UITableView *rightTableView;
@property (nonatomic, weak) IBOutlet A3CircleView *loanACircleView, *loanBCircleView;
@property (nonatomic, weak) IBOutlet DDPageControl *pageControl;

@property (nonatomic, strong) A3LoanCalcComparisonTopLeftViewController *firstColumnInScrollView;
@property (nonatomic, strong) A3LoanCalcPrincipalBarChartController *secondColumnInScrollView;
@property (nonatomic, strong) A3LoanCalcPrincipalBarChartController *thirdColumnInScrollView;
@property (nonatomic, strong) A3LoanCalcSingleBarChartController *fourthColumnInScrollView;

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

	_loanACircleView.textLabel.text = @"A";
	_loanACircleView.textLabel.textColor = [UIColor colorWithRed:115.0/255.0 green:115.0/255.0 blue:115.0/255.0 alpha:1.0];
	_loanBCircleView.textLabel.text = @"B";
	_loanBCircleView.textLabel.textColor = [UIColor whiteColor];
	_loanBCircleView.backgroundColor = [UIColor colorWithRed:165.0/255.0 green:166.0/255.0 blue:169.0/255.0 alpha:1.0];

	self.leftTableViewDataSource.object = self.leftObject;
	self.rightTableViewDataSource.object = self.rightObject;
	_leftTableViewDataSource.tableView = _leftTableView;
	_rightTableViewDataSource.tableView = _rightTableView;
	_leftTableViewDataSource.brother = _rightTableViewDataSource;
	_rightTableViewDataSource.brother = _leftTableViewDataSource;
	_leftTableViewDataSource.delegate = self;
	_rightTableViewDataSource.delegate = self;

	[_leftTableViewDataSource reloadMainScrollViewContentSize];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];

	[self.leftTableViewDataSource willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
	[self.rightTableViewDataSource willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
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

	[_pageControl setNumberOfPages:2];
	[_pageControl setCurrentPage:0];
	[_pageControl setType:DDPageControlTypeOnFullOffEmpty];
	[_pageControl setOnColor: [UIColor colorWithRed:91.0/255.0 green:91.0/255.0 blue:91.0/255.0 alpha:1.0] ];
	[_pageControl setOffColor: [UIColor blackColor] ];
	[_pageControl setIndicatorDiameter: 6.0 ];
	[_pageControl setIndicatorSpace: 8.0 ];
	[_pageControl addTarget:self action:@selector(pageControlValueChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)pageControlValueChanged:(DDPageControl *)control {
	[_topScrollView setContentOffset:CGPointMake(_topScrollView.contentSize.width / 2.0 * control.currentPage, 0.0) animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	_pageControl.currentPage = (NSInteger) (_topScrollView.contentOffset.x / (_topScrollView.contentSize.width / 2.0));
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

- (void)loanCalcComparisonTableViewValueChanged {
	[_firstColumnInScrollView updateLabels];
	[_secondColumnInScrollView reloadData];
	[_thirdColumnInScrollView reloadData];
	[_fourthColumnInScrollView reloadData];
}

@end
