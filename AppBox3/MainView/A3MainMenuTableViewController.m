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
#import "CurrencyFavorite.h"
#import "JNJProgressButton.h"
#import "A3TableViewMenuElement.h"
#import "A3KeychainUtils.h"

@protocol JNJProgressButtonExtension <NSObject>
- (void)startProgress;
@end

NSString *const A3MainMenuFavorites = @"A3MainMenuFavorites";
NSString *const A3MainMenuRecentlyUsed = @"A3MainMenuRecents";

@interface A3MainMenuTableViewController () <UISearchDisplayDelegate, UISearchBarDelegate, A3PasscodeViewControllerDelegate>

@property (nonatomic, strong) UISearchDisplayController *mySearchDisplayController;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, strong) id usmStoreDidImportChangesObserver;
@property (nonatomic, weak) A3TableViewElement *selectedElement;
@property (nonatomic, strong) UIViewController<A3PasscodeViewControllerProtocol> *passcodeViewController;

@end

@implementation A3MainMenuTableViewController

- (id)init {
	self = [super initWithStyle:UITableViewStyleGrouped];
	if (self) {
		[self setupData];

		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
	}

	return self;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	[self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

	__typeof(self) __weak weakSelf = self;
	self.usmStoreDidImportChangesObserver =
	[[NSNotificationCenter defaultCenter] addObserverForName:USMStoreDidImportChangesNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
		[weakSelf.tableView reloadData];
	}];
	
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


- (void)dealloc {
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center removeObserver:_usmStoreDidImportChangesObserver];
	[center removeObserver:self];
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

#pragma mark - Data Handler

- (NSArray *)favoriteMenuItems {
	NSArray *storedFavorites = [[NSUserDefaults standardUserDefaults] objectForKey:A3MainMenuFavorites];
	if (!storedFavorites) {
		storedFavorites = @[
				@{kA3AppsMenuName : @"Date Calculator", kA3AppsClassName : @"", kA3AppsMenuImageName : @"DateCalculator"},
				@{kA3AppsMenuName : @"Loan Calculator", kA3AppsClassName : @"A3LoanCalc2ViewController", kA3AppsMenuImageName : @"LoanCalculator"},
				@{kA3AppsMenuName : @"Sales Calculator", kA3AppsClassName : @"", kA3AppsMenuImageName : @"SalesCalculator"},
				@{kA3AppsMenuName : @"Tip Calculator", kA3AppsClassName : @"", kA3AppsMenuImageName : @"TipCalculator"},
				@{kA3AppsMenuName : @"Unit Price", kA3AppsClassName : @"", kA3AppsMenuImageName : @"UnitPrice"},
				@{kA3AppsMenuName : @"Calculator", kA3AppsClassName : @"", kA3AppsMenuImageName : @"Calculator"},
				@{kA3AppsMenuName : @"Percent Calculator", kA3AppsClassName : @"", kA3AppsMenuImageName : @"PercentCalculator"}
		];
		[[NSUserDefaults standardUserDefaults] setObject:storedFavorites forKey:A3MainMenuFavorites];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	return storedFavorites;
}

- (NSArray *)recentlyUsedMenuItems {
	return [[NSUserDefaults standardUserDefaults] objectForKey:A3MainMenuRecentlyUsed];
}

- (void)setupData {
	self.rootElement = [A3TableViewRootElement new];
	self.rootElement.tableView = self.tableView;

	NSMutableArray *section0 = [@[
			@{
					kA3AppsMenuExpandable : @YES,
					kA3AppsMenuName : @"Favorites",
					kA3AppsExpandableChildren :	[self favoriteMenuItems]
			}] mutableCopy];

	NSArray *recentlyUsedMenuItems = [self recentlyUsedMenuItems];
	if ([recentlyUsedMenuItems count]) {
		NSDictionary *element = @{
				kA3AppsMenuExpandable : @YES,
				kA3AppsMenuName : @"Recent",
				kA3AppsExpandableChildren : recentlyUsedMenuItems
		};
		[section0 addObject:element];
	}

	self.rootElement.sectionsArray = @[[self sectionWithData:section0], self.appSection, self.bottomSection];
}

- (id)appSection {
	return [self sectionWithData:[[A3AppDelegate instance] allMenu]];
}

- (id)bottomSection {
	NSArray *bottomSection = @[
			@{kA3AppsMenuName : @"Settings", kA3AppsClassName : @"", kA3AppsStoryboardName : @"A3Settings", kA3AppsMenuNeedSecurityCheck : @YES},
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
			A3TableViewMenuElement *element = [A3TableViewMenuElement new];
			element.title = elementDescription[kA3AppsMenuName];
			element.imageName = elementDescription[kA3AppsMenuImageName];
			element.className = elementDescription[kA3AppsClassName];
			element.storyboardName = elementDescription[kA3AppsStoryboardName];
			element.nibName = elementDescription[kA3AppsNibName];
			element.needSecurityCheck = [elementDescription[kA3AppsMenuNeedSecurityCheck] boolValue];

			if ([element.className length] || [element.storyboardName length]) {

				__typeof(self) __weak weakSelf = self;

				element.onSelected = ^(A3TableViewElement *elementObject) {
					@autoreleasepool {
						A3TableViewMenuElement *menuElement = (A3TableViewMenuElement *) elementObject;
						UIViewController *targetViewController= [self getViewControllerForElement:menuElement];

						BOOL proceedPasscodeCheck = NO;
						// Check active view controller
						if (![weakSelf isActiveViewController:[targetViewController class]]) {
							if ([A3KeychainUtils getPassword] && [menuElement respondsToSelector:@selector(needSecurityCheck)] && [menuElement needSecurityCheck]) {
								proceedPasscodeCheck = YES;

								if ([menuElement.storyboardName isEqualToString:@"A3Settings"]) {
									proceedPasscodeCheck &= [[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultsKeyForAskPasscodeForSettings];
								}
							}
							if (proceedPasscodeCheck) {
								weakSelf.selectedElement = menuElement;
								weakSelf.passcodeViewController = [UIViewController passcodeViewControllerWithDelegate:self];
								UIViewController *passcodeTargetViewController;
								if (IS_IPHONE) {
									passcodeTargetViewController = [self mm_drawerController];
								} else {
									passcodeTargetViewController = [[A3AppDelegate instance] rootViewController];
								}
								[_passcodeViewController showLockscreenInViewController:passcodeTargetViewController];
							} else {
								[weakSelf popToRootAndPushViewController:targetViewController];

								if (IS_IPHONE) {
									[self.mm_drawerController closeDrawerAnimated:YES completion:nil];
								}
							}
						} else {
							if (IS_IPHONE) {
								[self.mm_drawerController closeDrawerAnimated:YES completion:nil];
							} else if (IS_PORTRAIT) {
								[[[A3AppDelegate instance] rootViewController] toggleLeftMenuViewOnOff];
							}
						}
					}

				};
			}
			[elementsArray addObject:element];
		}
	}
	return elementsArray;
}

- (UIViewController *)getViewControllerForElement:(A3TableViewMenuElement *)menuElement {
	UIViewController *targetViewController;
	if ([menuElement.className length]) {
							Class class;
							class = NSClassFromString(menuElement.className);

							targetViewController = [[class alloc] initWithNibName:menuElement.nibName bundle:nil];
						} else if ([menuElement.storyboardName length]) {
							UIStoryboard *storyboard = [UIStoryboard storyboardWithName:menuElement.storyboardName bundle:nil];
							targetViewController = [storyboard instantiateInitialViewController];
						}
	return targetViewController;
}

- (BOOL)isActiveViewController:(Class)aClass {
	UINavigationController *navigationController;

	if (IS_IPHONE) {
		navigationController = (UINavigationController *) self.mm_drawerController.centerViewController;
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

- (BOOL)isAppAvailableForElement:(A3TableViewMenuElement *)element {
	if ([element.className isEqualToString:@"A3CurrencyViewController"]) {
		NSUInteger count = [CurrencyFavorite MR_countOfEntities];
		FNLOG(@"%lu", (unsigned long)count);
		return count > 0;
	}
	return YES;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	A3TableViewMenuElement *element = (A3TableViewMenuElement *) [self elementAtIndexPath:indexPath];

	if ([self isAppAvailableForElement:element]) {
		cell.textLabel.textColor = [UIColor blackColor];
		cell.accessoryView = nil;
		cell.selectionStyle = UITableViewCellSelectionStyleDefault;
		if ([element.imageName length]) {
			cell.imageView.image= [UIImage imageNamed:element.imageName];
			cell.imageView.tintColor = nil;
		}
	} else {
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.textLabel.textColor = [UIColor colorWithRed:194.0/255.0 green:194.0/255.0 blue:194.0/255.0 alpha:1.0];

		UIImage *image = [[UIImage imageNamed:element.imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
		cell.imageView.image = image;
		cell.imageView.tintColor = [UIColor colorWithRed:194.0/255.0 green:194.0/255.0 blue:194.0/255.0 alpha:1.0];

		JNJProgressButton *progressButton = [[JNJProgressButton alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
		progressButton.needsProgress = YES;
		progressButton.userInteractionEnabled = NO;
		cell.accessoryView = progressButton;
		[(id<JNJProgressButtonExtension>)progressButton startProgress];
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	A3TableViewMenuElement *element = (A3TableViewMenuElement *) [self elementAtIndexPath:indexPath];
	if ([self isAppAvailableForElement:element]) {
		[element didSelectCellInViewController:(id) self tableView:self.tableView atIndexPath:indexPath];
	}
}

- (void)passcodeViewDidDisappearWithSuccess:(BOOL)success {
	if (success && _selectedElement) {
		UIViewController *viewController = [self getViewControllerForElement:(A3TableViewMenuElement *) _selectedElement];
		[self popToRootAndPushViewController:viewController];
		
		if (IS_IPHONE) {
			[self.mm_drawerController closeDrawerAnimated:YES completion:nil];
		}
	}
	_selectedElement = nil;
	_passcodeViewController = nil;
}

- (void)applicationWillResignActive {
	_selectedElement = nil;
	if (_passcodeViewController) {
		[_passcodeViewController cancelAndDismissMe];
	}
	_passcodeViewController = nil;
}

@end
