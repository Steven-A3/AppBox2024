//
//  A3MainMenuTableViewController.m
//  AppBox3
//
//  Created by A3 on 11/20/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3MainMenuTableViewController.h"
#import "A3TableViewRootElement.h"
#import "A3TableViewSection.h"
#import "A3TableViewExpandableElement.h"
#import "A3UIDevice.h"
#import "A3RootViewController_iPad.h"
#import "A3AppDelegate.h"
#import "UIViewController+MMDrawerController.h"
#import "UIViewController+A3Addition.h"

@interface A3MainMenuTableViewController () <UISearchDisplayDelegate, UISearchBarDelegate>

@property (nonatomic, strong) UISearchDisplayController *mySearchDisplayController;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;

@end

@implementation A3MainMenuTableViewController

- (id)init {
	self = [super initWithStyle:UITableViewStyleGrouped];
	if (self) {
		[self setupData];
	}

	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;


	UISearchBar *searchBar = [UISearchBar new];
	searchBar.placeholder = @"Search by App or Contents";
	searchBar.frame = self.navigationController.navigationBar.bounds;

	self.navigationItem.titleView = searchBar;

	self.mySearchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
	_mySearchDisplayController.delegate = self;
	_mySearchDisplayController.searchBar.delegate = self;
	_mySearchDisplayController.searchResultsTableView.delegate = self;
	_mySearchDisplayController.searchResultsTableView.dataSource = self;
	_mySearchDisplayController.searchResultsTableView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];
	_mySearchDisplayController.searchResultsTableView.showsVerticalScrollIndicator = NO;

	_mySearchDisplayController.searchBar.barTintColor = [UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:248.0/255.0 alpha:1.0];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addTapGestureRecognizer {
	_tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
	[self.view addGestureRecognizer:_tapGestureRecognizer];
}

- (void)handleTapGesture:(UITapGestureRecognizer *)gestureRecognizer {
	[_mySearchDisplayController.searchBar resignFirstResponder];
}

NSString *const kA3AppsMenuName = @"kA3AppsMenuName";
NSString *const kA3AppsMenuImageName = @"kA3AppsMenuImageName";
NSString *const kA3AppsExpandableChildren = @"kA3AppsExpandableChildren";
NSString *const kA3AppsClassName = @"kA3AppsClassName";
NSString *const kA3AppsNibName = @"kA3AppsNibName";
NSString *const kA3AppsStoryboardName = @"kA3AppsStoryboardName";
NSString *const kA3AppsMenuExpandable = @"kA3AppsMenuExpandable";

- (void)setupData {
	self.rootElement = [A3TableViewRootElement new];
	self.rootElement.tableView = self.tableView;

	NSArray *section0 = @[
			@{
					kA3AppsMenuExpandable : @YES,
					kA3AppsMenuName : @"Favorites",
					kA3AppsExpandableChildren :	@[
							@{kA3AppsMenuName : @"Date Calculator", kA3AppsClassName : @"", kA3AppsMenuImageName : @"DateCalculator"},
							@{kA3AppsMenuName : @"Loan Calculator", kA3AppsClassName : @"A3LoanCalc2ViewController", kA3AppsMenuImageName : @"LoanCalculator"},
							@{kA3AppsMenuName : @"Sales Calculator", kA3AppsClassName : @"", kA3AppsMenuImageName : @"SalesCalculator"},
							@{kA3AppsMenuName : @"Tip Calculator", kA3AppsClassName : @"", kA3AppsMenuImageName : @"TipCalculator"},
							@{kA3AppsMenuName : @"Unit Price", kA3AppsClassName : @"", kA3AppsMenuImageName : @"UnitPrice"},
							@{kA3AppsMenuName : @"Calculator", kA3AppsClassName : @"", kA3AppsMenuImageName : @"Calculator"},
							@{kA3AppsMenuName : @"Percent Calculator", kA3AppsClassName : @"", kA3AppsMenuImageName : @"PercentCalculator"}
			]
			},
			@{
					kA3AppsMenuExpandable : @YES,
					kA3AppsMenuName : @"Recent",
					kA3AppsExpandableChildren : @[
							@{kA3AppsMenuName : @"Currency", kA3AppsClassName : @"A3CurrencyViewController", kA3AppsMenuImageName : @"Currency"},
							@{kA3AppsMenuName : @"Lunar Converter", kA3AppsClassName : @"", kA3AppsMenuImageName : @"LunarConverter"},
							@{kA3AppsMenuName : @"Translator", kA3AppsClassName : @"", kA3AppsMenuImageName : @"Translator"},
							@{kA3AppsMenuName : @"Unit Converter", kA3AppsClassName : @"", kA3AppsMenuImageName : @"UnitConverter"},
			]}
			];

	self.rootElement.sectionsArray = @[[self sectionWithData:section0], self.appSection, self.bottomSection];
}

- (id)appSection {
	NSArray *appSection = @[
			@{
					kA3AppsMenuExpandable : @YES,
					kA3AppsMenuName : @"Calculator",
					kA3AppsExpandableChildren :	@[
							@{kA3AppsMenuName : @"Date Calculator", kA3AppsClassName : @"", kA3AppsMenuImageName : @"DateCalculator"},
							@{kA3AppsMenuName : @"Loan Calculator", kA3AppsClassName : @"A3LoanCalc2ViewController", kA3AppsMenuImageName : @"LoanCalculator"},
							@{kA3AppsMenuName : @"Sales Calculator", kA3AppsClassName : @"", kA3AppsMenuImageName : @"SalesCalculator"},
							@{kA3AppsMenuName : @"Tip Calculator", kA3AppsClassName : @"", kA3AppsMenuImageName : @"TipCalculator"},
							@{kA3AppsMenuName : @"Unit Price", kA3AppsClassName : @"", kA3AppsMenuImageName : @"UnitPrice"},
							@{kA3AppsMenuName : @"Calculator", kA3AppsClassName : @"", kA3AppsMenuImageName : @"Calculator"},
							@{kA3AppsMenuName : @"Percent Calculator", kA3AppsClassName : @"", kA3AppsMenuImageName : @"PercentCalculator"}
					]
			},
			@{
					kA3AppsMenuExpandable : @YES,
					kA3AppsMenuName : @"Converter",
					kA3AppsExpandableChildren : @[
							@{kA3AppsMenuName : @"Currency", kA3AppsClassName : @"A3CurrencyViewController", kA3AppsMenuImageName : @"Currency"},
							@{kA3AppsMenuName : @"Lunar Converter", kA3AppsClassName : @"", kA3AppsMenuImageName : @"LunarConverter"},
							@{kA3AppsMenuName : @"Translator", kA3AppsClassName : @"A3TranslatorViewController", kA3AppsMenuImageName : @"Translator"},
							@{kA3AppsMenuName : @"Unit Converter", kA3AppsClassName : @"", kA3AppsMenuImageName : @"UnitConverter"},
			]
			},
			@{
					kA3AppsMenuExpandable : @YES,
					kA3AppsMenuName : @"Productivity",
					kA3AppsExpandableChildren : @[
							@{kA3AppsMenuName : @"Days Counter", kA3AppsClassName : @"", kA3AppsMenuImageName : @"DaysCounter"},
							@{kA3AppsMenuName : @"Lady Calendar", kA3AppsClassName : @"", kA3AppsMenuImageName : @"LadyCalendar"},
							@{kA3AppsMenuName : @"Wallet", kA3AppsClassName : @"", kA3AppsMenuImageName : @"Wallet"},
							@{kA3AppsMenuName : @"Expense List", kA3AppsClassName : @"", kA3AppsMenuImageName : @"ExpenseList"},
			]
			},
			@{
					kA3AppsMenuExpandable : @YES,
					kA3AppsMenuName : @"Reference",
					kA3AppsExpandableChildren : @[
							@{kA3AppsMenuName : @"Holidays", kA3AppsClassName : @"A3HolidaysPageViewController", kA3AppsMenuImageName : @"Holidays"},
			]
			},
			@{
					kA3AppsMenuExpandable : @YES,
					kA3AppsMenuName : @"Utility",
					kA3AppsExpandableChildren : @[
							@{kA3AppsMenuName : @"Clock", kA3AppsClassName : @"", kA3AppsMenuImageName : @"Clock"},
							@{kA3AppsMenuName : @"Battery Status", kA3AppsClassName : @"", kA3AppsMenuImageName : @"BatteryStatus"},
							@{kA3AppsMenuName : @"Mirror", kA3AppsClassName : @"", kA3AppsMenuImageName : @"Mirror"},
							@{kA3AppsMenuName : @"Magnifier", kA3AppsClassName : @"", kA3AppsMenuImageName : @"Magnifier"},
			]
			},
	];

	return [self sectionWithData:appSection];
}

- (id)bottomSection {
	NSArray *bottomSection = @[
			@{kA3AppsMenuName : @"Settings", kA3AppsClassName : @"", kA3AppsStoryboardName : @"A3SettingsStoryboard"},
			@{kA3AppsMenuName : @"About", kA3AppsClassName : @""},
			@{kA3AppsMenuName : @"Help", kA3AppsClassName : @""},
	];

	return [self sectionWithData:bottomSection];
}

- (id)sectionWithData:(NSArray *)data {
	A3TableViewSection *section = [A3TableViewSection new];

	section.elements = [self elementsWithData:data];

	return section;
}

- (NSArray *)elementsWithData:(NSArray *)elementsDescriptions {
	NSMutableArray *elementsArray = [NSMutableArray new];
	for (NSDictionary *elementDescription in elementsDescriptions) {
		if ([elementDescription[kA3AppsMenuExpandable] boolValue] && elementDescription[kA3AppsExpandableChildren]) {
			A3TableViewExpandableElement *expandableElement = [A3TableViewExpandableElement new];
			expandableElement.title = elementDescription[kA3AppsMenuName];
			expandableElement.elements = [self elementsWithData:elementDescription[kA3AppsExpandableChildren]];
			[elementsArray addObject:expandableElement];
		} else {
			A3TableViewElement *element = [A3TableViewElement new];
			element.title = elementDescription[kA3AppsMenuName];
			element.imageName = elementDescription[kA3AppsMenuImageName];
			element.className = elementDescription[kA3AppsClassName];
			element.storyboardName = elementDescription[kA3AppsStoryboardName];
			element.nibName = elementDescription[kA3AppsNibName];

			if ([element.className length] || [element.storyboardName length]) {

				__typeof(self) __weak weakSelf = self;

				element.onSelected = ^(A3TableViewElement *elementObject) {
					if ([elementObject.className length]) {
						Class class;
						class = NSClassFromString(elementObject.className);

						if (![weakSelf isActiveViewController:class]) {
							UIViewController *viewController = [[class alloc] initWithNibName:elementObject.nibName bundle:nil];
							[weakSelf popToRootAndPushViewController:viewController];
						}
					} else if ([elementObject.storyboardName length]) {
						UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"A3Settings" bundle:nil];
						UIViewController *viewController = [storyboard instantiateInitialViewController];
						[weakSelf popToRootAndPushViewController:viewController];
					}
				};
			}
			[elementsArray addObject:element];
		}
	}
	return elementsArray;
}

- (BOOL)isActiveViewController:(Class)aClass {
	UINavigationController *navigationController;

	if (IS_IPHONE) {
		navigationController = (UINavigationController *) self.mm_drawerController.centerViewController;
		[self.mm_drawerController closeDrawerAnimated:YES completion:nil];
	} else {
		A3RootViewController_iPad *rootViewController = [[A3AppDelegate instance] rootViewController];
		navigationController = [rootViewController centerNavigationController];
	}
	for (UIViewController *viewController in navigationController.viewControllers) {
		if ([viewController isMemberOfClass:aClass]) {
			return YES;
		}
	}
	return NO;
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
	[_mySearchDisplayController setActive:YES];
	return YES;
}

@end
