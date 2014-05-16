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
#import "A3AppDelegate+mainMenu.h"
#import "A3TableViewExpandableCell.h"
#import "A3DaysCounterModelManager.h"
#import "A3DaysCounterSlideShowMainViewController.h"
#import "A3DaysCounterCalendarListMainViewController.h"
#import "A3DaysCounterReminderListViewController.h"
#import "A3DaysCounterFavoriteListViewController.h"

@protocol JNJProgressButtonExtension <NSObject>
- (void)startProgress;
@end

NSString *const kA3MainMenuFavorites = @"kA3MainMenuFavorites";				// Store NSDictionary
NSString *const kA3MainMenuRecentlyUsed = @"kA3MainMenuRecentlyUsed";		// Store NSDictionary
NSString *const kA3MainMenuAllMenu = @"kA3MainMenuAllMenu";					// Store NSArray
NSString *const kA3MainMenuMaxRecentlyUsed = @"kA3MainMenuMaxRecentlyUsed";	// Store NSNumber

NSString *const A3AppsMainMenuContentsChangedNotification = @"A3AppsMainMenuContentsChangedNotification";
NSString *const A3MainMenuBecameFirstResponder = @"A3MainMenuBecameFirstResponder";
NSString *const A3NotificationMainMenuDidShow = @"A3NotificationMainMenuDidShow";
NSString *const A3NotificationMainMenuDidHide = @"A3NotificationMainMenuDidHide";

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
		self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	}

	return self;
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
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(coreDataAvailable) name:A3NotificationCoreDataReady object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuContentsChanged) name:A3AppsMainMenuContentsChangedNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	if (![self isMovingToParentViewController]) {
		[self.tableView reloadData];
	}
}

- (void)menuContentsChanged {
	[self setupData];
	[self.tableView reloadData];
}

- (void)coreDataAvailable {
	dispatch_async(dispatch_get_main_queue(), ^{
		[self setupData];
		[self.tableView reloadData];
	});
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

- (NSDictionary *)recentlyUsedMenuItems {
	return [[NSUserDefaults standardUserDefaults] objectForKey:kA3MainMenuRecentlyUsed];
}

- (void)setupData {
	self.rootElement = [A3TableViewRootElement new];
	self.rootElement.tableView = self.tableView;

	NSDictionary *favoritesDict = [[A3AppDelegate instance] favoriteMenuDictionary];
	NSMutableArray *section0 = [NSMutableArray new];
	[section0 addObject:favoritesDict];

	NSDictionary *recentlyUsedMenuDictionary = [self recentlyUsedMenuItems];
	NSArray *recentMenuItems = recentlyUsedMenuDictionary[kA3AppsExpandableChildren];
	if ([recentMenuItems count]) {
		NSInteger maxRecent = [[A3AppDelegate instance] maximumRecentlyUsedMenus];
		  if ([recentMenuItems count] > maxRecent) {
			recentMenuItems = [recentMenuItems subarrayWithRange:NSMakeRange(0, maxRecent)];
			NSMutableDictionary *mutableDictionary = [recentlyUsedMenuDictionary mutableCopy];
			mutableDictionary[kA3AppsExpandableChildren] = recentMenuItems;
			[section0 addObject:mutableDictionary];
		} else {
			[section0 addObject:recentlyUsedMenuDictionary];
		}
	}

	self.rootElement.sectionsArray = @[[self sectionWithData:section0], self.appSection, self.bottomSection];
}

- (id)appSection {
	return [self sectionWithData:[[A3AppDelegate instance] allMenuArrayFromUserDefaults]];
}

NSString *const kA3AppsDoNotKeepAsRecent = @"DoNotKeepAsRecent";

- (id)bottomSection {
	NSArray *bottomSection = @[
			@{kA3AppsMenuName : @"Settings", kA3AppsStoryboard_iPhone : @"A3Settings", kA3AppsStoryboard_iPad:@"A3Settings", kA3AppsMenuNeedSecurityCheck : @YES, kA3AppsDoNotKeepAsRecent : @YES},
			@{kA3AppsMenuName : @"About", kA3AppsStoryboard_iPhone : @"about", kA3AppsStoryboard_iPad:@"about", kA3AppsDoNotKeepAsRecent:@YES},
			@{kA3AppsMenuName : @"Help", kA3AppsClassName_iPhone : @"A3HelpViewController", kA3AppsDoNotKeepAsRecent:@YES},
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
			element.className_iPhone = elementDescription[kA3AppsClassName_iPhone];
			element.className_iPad = elementDescription[kA3AppsClassName_iPad];
			element.storyboardName_iPhone = elementDescription[kA3AppsStoryboard_iPhone];
			element.storyboardName_iPad = elementDescription[kA3AppsStoryboard_iPad];
			element.nibName_iPhone = elementDescription[kA3AppsNibName_iPhone];
			element.nibName_iPad = elementDescription[kA3AppsNibName_iPad];
			element.needSecurityCheck = [elementDescription[kA3AppsMenuNeedSecurityCheck] boolValue];
			element.doNotKeepAsRecent = [elementDescription[kA3AppsDoNotKeepAsRecent] boolValue];


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

							if ([menuElement.storyboardName_iPhone isEqualToString:@"A3Settings"]) {
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
								[self.mm_drawerController closeDrawerAnimated:YES completion:^(BOOL finished) {
									[[NSNotificationCenter defaultCenter] postNotificationName:A3DrawerStateChanged object:nil];
								}];
							}
						}
					} else {
						if (IS_IPHONE) {
							[self.mm_drawerController closeDrawerAnimated:YES completion:^(BOOL finished) {
								[[NSNotificationCenter defaultCenter] postNotificationName:A3DrawerStateChanged object:nil];
							}];
						} else if (IS_PORTRAIT) {
							[[[A3AppDelegate instance] rootViewController] toggleLeftMenuViewOnOff];
						}
					}
				}

			};
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
			if (menuElement.className_iPhone) newDescription[kA3AppsClassName_iPhone] = menuElement.className_iPhone;
			if (menuElement.className_iPad) newDescription[kA3AppsClassName_iPad] = menuElement.className_iPad;
			if (menuElement.storyboardName_iPhone) newDescription[kA3AppsStoryboard_iPhone] = menuElement.storyboardName_iPhone;
			if (menuElement.storyboardName_iPad) newDescription[kA3AppsStoryboard_iPad] = menuElement.storyboardName_iPad;
			if (menuElement.nibName_iPhone) newDescription[kA3AppsNibName_iPhone] = menuElement.nibName_iPhone;
			if (menuElement.nibName_iPad) newDescription[kA3AppsNibName_iPad] = menuElement.nibName_iPad;
			if (menuElement.needSecurityCheck) newDescription[kA3AppsMenuNeedSecurityCheck] = @YES;
			if (menuElement.doNotKeepAsRecent) newDescription[kA3AppsDoNotKeepAsRecent] = @YES;
			[descriptionsArray addObject:newDescription];
		}
	}
	return descriptionsArray;
}

- (UIViewController *)getViewControllerForElement:(A3TableViewMenuElement *)menuElement {
	UIViewController *targetViewController;

	if ([menuElement.title isEqualToString:@"Days Counter"]) {
        A3DaysCounterModelManager *sharedManager = [[A3DaysCounterModelManager alloc] init];
        [sharedManager prepare];
        NSInteger lastOpenedMainIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"DaysCounterLastOpenedMainIndex"];
        switch (lastOpenedMainIndex) {
            case 1:
                targetViewController = [[A3DaysCounterSlideShowMainViewController alloc] initWithNibName:@"A3DaysCounterSlideShowMainViewController" bundle:nil];
                ((A3DaysCounterSlideShowMainViewController *)targetViewController).sharedManager = sharedManager;
                break;
            case 3:
                targetViewController = [[A3DaysCounterReminderListViewController alloc] initWithNibName:@"A3DaysCounterReminderListViewController" bundle:nil];
                ((A3DaysCounterReminderListViewController *)targetViewController).sharedManager = sharedManager;
                break;
            case 4:
                targetViewController = [[A3DaysCounterFavoriteListViewController alloc] initWithNibName:@"A3DaysCounterFavoriteListViewController" bundle:nil];
                ((A3DaysCounterFavoriteListViewController *)targetViewController).sharedManager = sharedManager;
                break;
                
            default:
                targetViewController = [[A3DaysCounterCalendarListMainViewController alloc] initWithNibName:@"A3DaysCounterCalendarListMainViewController" bundle:nil];
                ((A3DaysCounterCalendarListMainViewController *)targetViewController).sharedManager = sharedManager;
                break;
        }

		return targetViewController;
	}

	if ([menuElement.className_iPhone length]) {
		Class class;
		NSString *nibName;
		if (IS_IPAD) {
			class = NSClassFromString(menuElement.className_iPad ? menuElement.className_iPad : menuElement.className_iPhone);
			nibName = menuElement.nibName_iPad ? menuElement.nibName_iPad : menuElement.nibName_iPhone;
		} else {
			class = NSClassFromString(menuElement.className_iPhone);
			nibName = menuElement.nibName_iPhone;
		}

		if (nibName) {
			targetViewController = [[class alloc] initWithNibName:nibName bundle:nil];
		} else {
			targetViewController = [[class alloc] init];
		}
	} else if ([menuElement.storyboardName_iPhone length]) {
		NSString *storyboardName;
		if (IS_IPAD) {
			storyboardName = menuElement.storyboardName_iPad ? menuElement.storyboardName_iPad : menuElement.storyboardName_iPhone;
		} else {
			storyboardName = menuElement.storyboardName_iPhone;
		}
		UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
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
	if (![element isKindOfClass:[A3TableViewMenuElement class]]) return NO;
	if ([element.className_iPhone isEqualToString:@"A3CurrencyViewController"]) {
		if ([[A3AppDelegate instance] coreDataReadyToUse]) {
			NSUInteger count = [CurrencyFavorite MR_countOfEntities];
			return count > 0;
		} else {
			return NO;
		}
	}
	return YES;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	A3TableViewMenuElement *element = (A3TableViewMenuElement *) [self elementAtIndexPath:indexPath];

	if ([element isKindOfClass:[A3TableViewMenuElement class]]) {
		if ([self isAppAvailableForElement:element]) {
			cell.textLabel.textColor = [UIColor blackColor];
			cell.accessoryView = nil;
			if (![element isKindOfClass:[A3TableViewExpandableElement class]]) {
				cell.selectionStyle = UITableViewCellSelectionStyleDefault;
			}
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
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self.mySearchDisplayController.searchBar resignFirstResponder];

	A3TableViewExpandableElement *expandableElement = (A3TableViewExpandableElement *) [self elementAtIndexPath:indexPath];
	if ([expandableElement isKindOfClass:[A3TableViewExpandableElement class]]) {
		A3TableViewExpandableCell *cell = (A3TableViewExpandableCell *) [tableView cellForRowAtIndexPath:indexPath];
		[expandableElement expandButtonPressed:cell.expandButton];
		return;
	}
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
			[self.mm_drawerController closeDrawerAnimated:YES completion:^(BOOL finished) {
				[[NSNotificationCenter defaultCenter] postNotificationName:A3DrawerStateChanged object:nil];
			}];
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
	[self.mySearchDisplayController.searchBar resignFirstResponder];

	if (indexPath.section == 0) {
		if (indexPath.row == 0) {
			NSMutableDictionary *favoriteDictionary = [[[A3AppDelegate instance] favoriteMenuDictionary] mutableCopy];
			favoriteDictionary[kA3AppsMenuCollapsed] = @(element.isCollapsed);
			[[A3AppDelegate instance] storeFavoriteMenuDictionary:favoriteDictionary withDate:[NSDate date]];
		} else {
			NSMutableDictionary *recentDictionary = [[[NSUserDefaults standardUserDefaults] objectForKey:kA3MainMenuRecentlyUsed] mutableCopy];
			recentDictionary[kA3AppsMenuCollapsed] = @(element.isCollapsed);
			[[A3AppDelegate instance] storeRecentlyUsedMenuDictionary:recentDictionary withDate:[NSDate date]];
		}
	} else if (indexPath.section == 1) {
		NSMutableArray *allMenus = [[[A3AppDelegate instance] allMenuArrayFromUserDefaults]	mutableCopy];
		NSUInteger idx = [allMenus indexOfObjectPassingTest:^BOOL(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
			return [obj[kA3AppsMenuName]  isEqualToString:element.title];
		}];
		if (idx != NSNotFound) {
			NSMutableDictionary *expandableMenuDictionary = [allMenus[idx] mutableCopy];
			expandableMenuDictionary[kA3AppsMenuCollapsed] = @(element.isCollapsed);
			[allMenus replaceObjectAtIndex:idx withObject:expandableMenuDictionary];
			[[A3AppDelegate instance] storeAllMenu:allMenus withDate:[NSDate date]];
		}
	}
}

- (void)updateRecentlyUsedAppsWithElement:(A3TableViewMenuElement *)element {
	@autoreleasepool {
		if (![element isKindOfClass:[A3TableViewMenuElement class]] || element.doNotKeepAsRecent) {
			return;
		}
		NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		NSMutableDictionary *recentlyUsed = [[userDefaults objectForKey:kA3MainMenuRecentlyUsed] mutableCopy];
		if (!recentlyUsed) {
			recentlyUsed = [NSMutableDictionary new];
			recentlyUsed[kA3AppsMenuName] = @"Recent";
			recentlyUsed[kA3AppsMenuCollapsed] = @NO;
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
			NSInteger maxRecent = [[A3AppDelegate instance] maximumRecentlyUsedMenus];

			if (maxRecent == 1) {
				recentlyUsed[kA3AppsExpandableChildren] = [self dataFromElements:@[element]];
			} else {
				NSArray *newDataArray = [self dataFromElements:@[element]];
				[appsList insertObject:newDataArray[0] atIndex:0];

				if ([appsList count] > maxRecent) {
					[appsList removeObjectsInRange:NSMakeRange(maxRecent, [appsList count] - maxRecent)];
				}
				recentlyUsed[kA3AppsExpandableChildren] = appsList;
			}
		}

		[[A3AppDelegate instance] storeRecentlyUsedMenuDictionary:recentlyUsed withDate:[NSDate date]];

		[self setupData];
		[self.tableView reloadData];
	}
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	if (IS_IPAD) {
		[[NSNotificationCenter defaultCenter] postNotificationName:A3MainMenuBecameFirstResponder object:self];
	}
}

@end
