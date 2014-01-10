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
#import "A3AppDelegate+iCloud.h"
#import "NSMutableArray+MoveObject.h"

@protocol JNJProgressButtonExtension <NSObject>
- (void)startProgress;
@end

NSString *const kA3MainMenuFavorites = @"kA3MainMenuFavorites";				// Store NSDictionary
NSString *const kA3MainMenuRecentlyUsed = @"kA3MainMenuRecentlyUsed";		// Store NSDictionary
NSString *const kA3MainMenuAllMenu = @"kA3MainMenuAllMenu";					// Store NSArray
NSString *const kA3MainMenuMaxRecentlyUsed = @"kA3MainMenuMaxRecentlyUsed";	// Store NSNumber

@interface A3MainMenuTableViewController () <UISearchDisplayDelegate, UISearchBarDelegate, A3PasscodeViewControllerDelegate, A3TableViewExpandableElementDelegate>

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

	__typeof(self) __weak weakSelf = self;
	self.usmStoreDidImportChangesObserver =
			[[NSNotificationCenter defaultCenter] addObserverForName:USMStoreDidImportChangesNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
				[weakSelf.tableView reloadData];
			}];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(coreDataAvailable) name:A3CoreDataReadyNotification object:nil];
}

- (void)coreDataAvailable {
	[self.tableView reloadData];
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

- (NSDictionary *)favoriteMenuItems {
	NSDictionary *storedFavorites = [[NSUserDefaults standardUserDefaults] objectForKey:kA3MainMenuFavorites];
	if (!storedFavorites) {
		storedFavorites = @{
				kA3AppsMenuName : @"Farovirtes",
				kA3AppsMenuCollapsed : @YES,
				kA3AppsMenuExpandable : @YES,
				kA3AppsExpandableChildren :
				@[
						@{kA3AppsMenuName : @"Date Calculator", kA3AppsClassName : @"", kA3AppsMenuImageName : @"DateCalculator"},
						@{kA3AppsMenuName : @"Loan Calculator", kA3AppsClassName : @"A3LoanCalc2ViewController", kA3AppsMenuImageName : @"LoanCalculator"},
						@{kA3AppsMenuName : @"Sales Calculator", kA3AppsClassName : @"", kA3AppsMenuImageName : @"SalesCalculator"},
						@{kA3AppsMenuName : @"Tip Calculator", kA3AppsClassName : @"", kA3AppsMenuImageName : @"TipCalculator"},
						@{kA3AppsMenuName : @"Calculator", kA3AppsClassName : @"", kA3AppsMenuImageName : @"Calculator"},
						@{kA3AppsMenuName : @"Percent Calculator", kA3AppsClassName : @"", kA3AppsMenuImageName : @"PercentCalculator"}
				]
		};
		[[NSUserDefaults standardUserDefaults] setObject:storedFavorites forKey:kA3MainMenuFavorites];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	return storedFavorites;
}

- (NSDictionary *)recentlyUsedMenuItems {
	return [[NSUserDefaults standardUserDefaults] objectForKey:kA3MainMenuRecentlyUsed];
}

- (void)setupData {
	self.rootElement = [A3TableViewRootElement new];
	self.rootElement.tableView = self.tableView;

	NSDictionary *favoritesDict = [self favoriteMenuItems];
	NSMutableArray *section0 = [NSMutableArray new];
	[section0 addObject:favoritesDict];

	NSDictionary *recentlyUsedMenuItems = [self recentlyUsedMenuItems];
	if (recentlyUsedMenuItems) {
		[section0 addObject:recentlyUsedMenuItems];
	}

	self.rootElement.sectionsArray = @[[self sectionWithData:section0], self.appSection, self.bottomSection];
}

- (id)appSection {
	NSArray *allMenus = [[NSUserDefaults standardUserDefaults] objectForKey:kA3MainMenuAllMenu];
	if (!allMenus) {
		allMenus = [[A3AppDelegate instance] allMenu];
		NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		[userDefaults setObject:allMenus forKey:kA3MainMenuAllMenu];
		[userDefaults synchronize];
	}
	return [self sectionWithData:allMenus];
}

NSString *const kA3AppsDoNotKeepAsRecent = @"DoNotKeepAsRecent";

- (id)bottomSection {
	NSArray *bottomSection = @[
			@{kA3AppsMenuName : @"Settings", kA3AppsClassName : @"", kA3AppsStoryboardName : @"A3Settings", kA3AppsMenuNeedSecurityCheck : @YES, kA3AppsDoNotKeepAsRecent : @YES},
			@{kA3AppsMenuName : @"About", kA3AppsClassName : @"", kA3AppsDoNotKeepAsRecent:@YES},
			@{kA3AppsMenuName : @"Help", kA3AppsClassName : @"", kA3AppsDoNotKeepAsRecent:@YES},
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
			expandableElement.collapsed = [elementDescription[kA3AppsMenuCollapsed] boolValue];
			expandableElement.elements = [self elementsWithData:elementDescription[kA3AppsExpandableChildren]];
			expandableElement.delegate = self;
			[elementsArray addObject:expandableElement];
		} else {
			A3TableViewMenuElement *element = [A3TableViewMenuElement new];
			element.title = elementDescription[kA3AppsMenuName];
			element.imageName = elementDescription[kA3AppsMenuImageName];
			element.className = elementDescription[kA3AppsClassName];
			element.storyboardName = elementDescription[kA3AppsStoryboardName];
			element.nibName = elementDescription[kA3AppsNibName];
			element.needSecurityCheck = [elementDescription[kA3AppsMenuNeedSecurityCheck] boolValue];
			element.doNotKeepAsRecent = [elementDescription[kA3AppsDoNotKeepAsRecent] boolValue];

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
								[weakSelf updateRecentlyUsedAppsWithElement:menuElement];

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

- (NSArray *)dataFromElements:(NSArray *)elements {
	NSMutableArray *descriptionsArray = [[NSMutableArray alloc] initWithCapacity:elements.count];
	for (id object in elements) {
		if ([object isKindOfClass:[A3TableViewExpandableElement class]]) {
			A3TableViewExpandableElement *expandableElement = object;
			NSMutableDictionary *newDescription = [NSMutableDictionary new];
			if (expandableElement.title) newDescription[kA3AppsMenuName] = expandableElement.title;
			newDescription[kA3AppsMenuCollapsed] = @(expandableElement.isCollapsed);
			if (expandableElement.elements) newDescription[kA3AppsExpandableChildren] = [self dataFromElements:expandableElement.elements];
			[descriptionsArray addObject:newDescription];
		} else {
			A3TableViewMenuElement *menuElement = object;
			NSMutableDictionary *newDescription = [NSMutableDictionary new];
			if (menuElement.title) newDescription[kA3AppsMenuName] = menuElement.title;
			if (menuElement.imageName) newDescription[kA3AppsMenuImageName] = menuElement.imageName;
			if (menuElement.className) newDescription[kA3AppsClassName] = menuElement.className;
			if (menuElement.storyboardName) newDescription[kA3AppsStoryboardName] = menuElement.storyboardName;
			if (menuElement.nibName) newDescription[kA3AppsNibName] = menuElement.nibName;
			if (menuElement.needSecurityCheck) newDescription[kA3AppsMenuNeedSecurityCheck] = @YES;
			if (menuElement.doNotKeepAsRecent) newDescription[kA3AppsDoNotKeepAsRecent] = @YES;
			[descriptionsArray addObject:newDescription];
		}
	}
	return descriptionsArray;
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
		if ([[A3AppDelegate instance] coreDataReadyToUse]) {
			NSUInteger count = [CurrencyFavorite MR_countOfEntities];
			FNLOG(@"%lu", (unsigned long) count);
			return count > 0;
		} else {
			return NO;
		}
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
		[self updateRecentlyUsedAppsWithElement:(A3TableViewMenuElement *) _selectedElement];
		
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

#pragma mark - A3ExpandableElement delegate

- (void)element:(A3TableViewExpandableElement *)element cellStateChangedAtIndexPath:(NSIndexPath *)indexPath {
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	if (indexPath.section == 0) {
		if (indexPath.row == 0) {
			NSMutableDictionary *favoriteDictionary = [[userDefaults objectForKey:kA3MainMenuFavorites] mutableCopy];
			favoriteDictionary[kA3AppsMenuCollapsed] = @(element.collapsed);
			[userDefaults setObject:favoriteDictionary forKey:kA3MainMenuFavorites];
		} else {
			NSMutableDictionary *recentDictionary = [[userDefaults objectForKey:kA3MainMenuRecentlyUsed] mutableCopy];
			recentDictionary[kA3AppsMenuCollapsed] = @(element.collapsed);
			[userDefaults setObject:recentDictionary forKey:kA3MainMenuRecentlyUsed];
		}
	} else if (indexPath.section == 1) {
		NSMutableArray *allMenus = [[userDefaults objectForKey:kA3MainMenuAllMenu] mutableCopy];
		NSMutableDictionary *sectionDictionary = [allMenus[(NSUInteger) indexPath.section] mutableCopy];
		sectionDictionary[kA3AppsMenuCollapsed] = @(element.collapsed);
		[allMenus replaceObjectAtIndex:indexPath.section withObject:sectionDictionary];
		[userDefaults setObject:allMenus forKey:kA3MainMenuAllMenu];
	}
	[userDefaults synchronize];
}

- (void)updateRecentlyUsedAppsWithElement:(A3TableViewMenuElement *)element {
	if (![element isKindOfClass:[A3TableViewMenuElement class]] || element.doNotKeepAsRecent) {
		return;
	}
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSMutableDictionary *recentlyUsed = [[userDefaults objectForKey:kA3MainMenuRecentlyUsed] mutableCopy];
	if (!recentlyUsed) {
		recentlyUsed = [NSMutableDictionary new];
		recentlyUsed[kA3AppsMenuName] = @"Recent";
		recentlyUsed[kA3AppsMenuCollapsed] = @YES;
		recentlyUsed[kA3AppsMenuExpandable] = @YES;
	}
	NSMutableArray *appsList = [recentlyUsed[kA3AppsExpandableChildren] mutableCopy];
	if (!appsList) {
		appsList = [NSMutableArray new];
	}

	NSUInteger idx = [appsList indexOfObjectPassingTest:^BOOL(NSDictionary *menuDictionary, NSUInteger idx, BOOL *stop) {
		if ([element.title isEqualToString:menuDictionary[kA3AppsMenuName]]) {
			*stop = YES;
			return YES;
		}
		return NO;
	}];
	if (idx != NSNotFound) {
		if (idx > 0) {
			[appsList moveObjectFromIndex:idx toIndex:0];
			recentlyUsed[kA3AppsExpandableChildren] = appsList;
		}
	} else {
		NSInteger maxRecent = [userDefaults integerForKey:kA3MainMenuMaxRecentlyUsed];
		if (!maxRecent) maxRecent = 3;    // Default value == 3

		if (maxRecent == 1) {
			recentlyUsed[kA3AppsExpandableChildren] = [self dataFromElements:@[element]];
		} else {
			NSArray *newDataArray = [self dataFromElements:@[element]];
			[appsList insertObject:newDataArray[0] atIndex:0];


			if ([appsList count] > maxRecent) {
				[appsList removeLastObject];
			}
			recentlyUsed[kA3AppsExpandableChildren] = appsList;
		}
	}

	[userDefaults setObject:recentlyUsed forKey:kA3MainMenuRecentlyUsed];
	[userDefaults synchronize];

	[self setupData];
	[self.tableView reloadData];
}

@end
