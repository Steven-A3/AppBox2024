//
//  A3LoanCalcComparisonMainViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 3/21/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3LoanCalcComparisonMainViewController.h"
#import "A3CircleView.h"
#import "common.h"
#import "A3LoanCalcComparisonTableViewDataSource.h"
#import "A3AppDelegate.h"
#import "A3LoanCalcPreferences.h"
#import "EKKeyboardAvoidingScrollViewManager.h"
#import "NSManagedObject+Clone.h"

@interface A3LoanCalcComparisonMainViewController () <A3LoanCalcComparisonTableViewDataSourceDelegate>

@end

@implementation A3LoanCalcComparisonMainViewController {

}
@synthesize leftObject = _leftObject, rightObject = _rightObject;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do any additional setup after loading the view from its nib.

	[self configureTopScrollView];
	[self configurePageControl];

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

- (void)configurePageControl {
	[_pageControl setNumberOfPages:(NSInteger) (self.topScrollView.contentSize.width / self.topScrollView.bounds.size.width)];
	[_pageControl setCurrentPage:0];
	[_pageControl setType:DDPageControlTypeOnFullOffEmpty];
	[_pageControl setOnColor: [UIColor colorWithRed:91.0/255.0 green:91.0/255.0 blue:91.0/255.0 alpha:1.0] ];
	[_pageControl setOffColor: [UIColor blackColor] ];
	[_pageControl setIndicatorDiameter: 6.0 ];
	[_pageControl setIndicatorSpace: 8.0 ];
	[_pageControl addTarget:self action:@selector(pageControlValueChanged:) forControlEvents:UIControlEventValueChanged];
	CGPoint center = _pageControl.center;
	center.x = 160.0;
	_pageControl.center = center;
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
	NSManagedObjectContext *managedObjectContext = [NSManagedObjectContext MR_mainQueueContext];
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
		object.compareWith = rightObject;

		[rightObject initializeValues];
		rightObject.location = @"B";
		rightObject.created = object.created;
		rightObject.compareWith = object;

		NSError *error;
		[managedObjectContext save:&error];
	}
	return object;
}

- (LoanCalcHistory *)leftObject {
	if (nil == _leftObject) {
		_leftObject = [self getEditingObjectForLeft:YES];
		_rightObject = _leftObject.compareWith;
	}
	return _leftObject;
}

- (LoanCalcHistory *)rightObject {
	if (nil == _rightObject) {
		_leftObject = [self getEditingObjectForLeft:YES];
		_rightObject = _leftObject.compareWith;
	}
	return _rightObject;
}

- (void)loanCalcComparisonTableViewValueChanged {
	[self addDataToHistory];
}

- (void)reloadData {
	// This is a prototype implementation and sub clias _iPhone & _iPad have to
	// complete it.
}

- (void)addDataToHistory {
	if (![self.leftObject hasChanges] && ![self.rightObject hasChanges]) {
		FNLOG(@"Nothing to add.");
		return;
	}

	NSManagedObjectContext *managedObjectContext = _leftObject.managedObjectContext;
	LoanCalcHistory *newHistoryLeft = (LoanCalcHistory *) [_leftObject cloneInContext:managedObjectContext];
	LoanCalcHistory *newHistoryRight = (LoanCalcHistory *) [_rightObject cloneInContext:managedObjectContext];
	newHistoryLeft.editing = @NO;
	newHistoryRight.editing = @NO;
	newHistoryLeft.created = [NSDate date];
	newHistoryRight.created = newHistoryLeft.created;
	newHistoryLeft.compareWith = newHistoryRight;

	NSError *error;
	if ([managedObjectContext save:&error]) {
		FNLOG(@"History saved successfully!");
	}
}

- (void)historySelected:(LoanCalcHistory *)object {
	[self setLeftObject:object];

	[self.leftTableView reloadData];
	[self.rightTableView reloadData];
	[self reloadData];
}

- (void)setLeftObject:(LoanCalcHistory *)leftObject {
	_leftObject = leftObject;
	_rightObject = leftObject.compareWith;
	_leftTableViewDataSource.object = _leftObject;
	_rightTableViewDataSource.object = _rightObject;
}

@end
