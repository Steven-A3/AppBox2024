//
//  A3MainMenuTableViewController.m
//  AppBox3
//
//  Created by A3 on 11/20/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <LocalAuthentication/LocalAuthentication.h>
#import "A3MainMenuTableViewController.h"
#import "A3TableViewRootElement.h"
#import "A3TableViewSection.h"
#import "A3TableViewExpandableElement.h"
#import "A3RootViewController_iPad.h"
#import "A3AppDelegate.h"
#import "UIViewController+MMDrawerController.h"
#import "UIViewController+A3Addition.h"
#import "A3PasscodeViewControllerProtocol.h"
#import "A3TableViewMenuElement.h"
#import "A3KeychainUtils.h"
#import "NSMutableArray+MoveObject.h"
#import "A3TableViewExpandableCell.h"
#import "A3DaysCounterModelManager.h"
#import "A3DaysCounterSlideShowMainViewController.h"
#import "A3DaysCounterCalendarListMainViewController.h"
#import "A3DaysCounterReminderListViewController.h"
#import "A3DaysCounterFavoriteListViewController.h"
#import "A3ClockMainViewController.h"
#import "A3SyncManager.h"
#import "A3SyncManager+NSUbiquitousKeyValueStore.h"
#import "A3UserDefaults.h"
#import "A3LunarConverterViewController.h"
#import "RMStore.h"
#import "RMAppReceipt.h"
#import "A3TableViewElement.h"

NSString *const A3NotificationAppsMainMenuContentsChanged = @"A3NotificationAppsMainMenuContentsChanged";
NSString *const A3MainMenuBecameFirstResponder = @"A3MainMenuBecameFirstResponder";
NSString *const A3NotificationMainMenuDidShow = @"A3NotificationMainMenuDidShow";
NSString *const A3NotificationMainMenuDidHide = @"A3NotificationMainMenuDidHide";

@interface A3MainMenuTableViewController () <UISearchDisplayDelegate, UISearchBarDelegate, A3PasscodeViewControllerDelegate, A3TableViewExpandableElementDelegate>

@property (nonatomic, strong) UISearchDisplayController *mySearchDisplayController;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, strong) A3TableViewElement *selectedElement;
@property (nonatomic, strong) A3TableViewElement *mostRecentMenuElement;
@property (nonatomic, strong) NSTimer *titleResetTimer;

@end

@implementation A3MainMenuTableViewController

- (instancetype)init {
	self = [super initWithStyle:UITableViewStyleGrouped];
	if (self) {
	}

	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	[self setupData];
	self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
	self.title = @"AppBox Pro®";
	self.tableView.accessibilityIdentifier = @"MainMenuTable";

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuContentsChanged) name:A3NotificationAppsMainMenuContentsChanged object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuContentsChanged) name:A3NotificationCloudKeyValueStoreDidImport object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncDidMakeProgress:) name:CDEPersistentStoreEnsembleDidMakeProgressWithActivityNotification object:nil];
}

- (void)syncDidMakeProgress:(NSNotification *)notification {
	@autoreleasepool {
		NSNumber *progress = [notification.userInfo objectForKey:CDEProgressFractionKey];
		if ([progress doubleValue] == 1.0) {
			FNLOG(@"%@", [notification.userInfo objectForKey:CDEEnsembleActivityKey]);
		}
		NSNumberFormatter *formatter = [NSNumberFormatter new];
		[formatter setNumberStyle:NSNumberFormatterPercentStyle];
		self.title = [NSString stringWithFormat:NSLocalizedString(@"Syncing...(%@)", @"Syncing...(%@)"), [formatter stringFromNumber:progress]];
		[_titleResetTimer invalidate];
		_titleResetTimer = [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(resetTitle) userInfo:nil repeats:NO];
	}
}

- (void)resetTitle {
	self.title = @"AppBox Pro®";
	[_titleResetTimer invalidate];
	_titleResetTimer = nil;
}

- (void)removeObserver {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:CDEPersistentStoreEnsembleDidMakeProgressWithActivityNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationCloudKeyValueStoreDidImport object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationAppsMainMenuContentsChanged object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	if ([self isMovingFromParentViewController] || [self isBeingDismissed]) {
		FNLOG();
		[self removeObserver];
	}
}

- (void)dealloc {
	[self removeObserver];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	if (![self isMovingToParentViewController]) {
		[self.tableView reloadData];
	}
}

- (UIStatusBarStyle)preferredStatusBarStyle {
	return UIStatusBarStyleDefault;
}

- (BOOL)prefersStatusBarHidden {
	return NO;
}

- (void)menuContentsChanged {
	[self setupData];
	[self.tableView reloadData];
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
	NSDictionary *result = [[A3SyncManager sharedSyncManager] objectForKey:A3MainMenuDataEntityRecentlyUsed];
	if ([result isEqual:[NSNull null]]) return nil;
	return result;
}

- (void)setupData {
	self.rootElement = [A3TableViewRootElement new];
	self.rootElement.tableView = self.tableView;

	NSDictionary *favoritesDict = [[A3AppDelegate instance] favoriteMenuDictionary];
	NSMutableArray *section0 = [NSMutableArray new];
	[section0 addObject:favoritesDict];

	NSInteger maxRecent = [[A3AppDelegate instance] maximumRecentlyUsedMenus];
	NSArray *recentMenuItems = nil;
	NSDictionary *recentlyUsedMenuDictionary = [self recentlyUsedMenuItems];
	recentMenuItems = recentlyUsedMenuDictionary[kA3AppsExpandableChildren];

	if (maxRecent) {
		if ([recentMenuItems count]) {
			if ([recentMenuItems count] > maxRecent) {
				recentMenuItems = [recentMenuItems subarrayWithRange:NSMakeRange(0, maxRecent)];
				NSMutableDictionary *mutableDictionary = [recentlyUsedMenuDictionary mutableCopy];
				mutableDictionary[kA3AppsExpandableChildren] = recentMenuItems;
				[section0 addObject:mutableDictionary];
			} else {
				[section0 addObject:recentlyUsedMenuDictionary];
			}
		}
	}
	if ([recentMenuItems count]) {
		NSArray *recentMenuElements = [self elementsWithData:recentMenuItems];
		_mostRecentMenuElement = recentMenuElements[0];
	} else {
		_mostRecentMenuElement = nil;
	}

	self.rootElement.sectionsArray = @[[self sectionWithData:section0], self.appSection, self.bottomSection];
}

- (id)appSection {
	return [self sectionWithData:[[A3AppDelegate instance] allMenuArrayFromStoredDataFile]];
}

- (id)bottomSection {
	NSArray *bottomSection;

	bottomSection = @[
					  @{kA3AppsMenuName : A3AppName_Settings},
					  @{kA3AppsMenuName : A3AppName_About},
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

			__typeof(self) __weak weakSelf = self;

			element.onSelected = ^(A3TableViewElement *elementObject, BOOL verifyPasscode) {
				FNLOG(@"self.activeAppName = %@", self.activeAppName);
				A3TableViewMenuElement *menuElement = (A3TableViewMenuElement *) elementObject;

				// Check active view controller
				if (![self.activeAppName isEqualToString:elementObject.title]) {
					if (![[A3AppDelegate instance] launchAppNamed:elementObject.title verifyPasscode:verifyPasscode delegate:self animated:NO]) {
						self.selectedElement = menuElement;
					} else {
						[weakSelf updateRecentlyUsedAppsWithElement:menuElement];
						
						if (IS_IPHONE) {
							[self.mm_drawerController closeDrawerAnimated:YES completion:^(BOOL finished) {
								[[NSNotificationCenter defaultCenter] postNotificationName:A3NotificationMainMenuDidHide object:nil];
							}];
						}
						self.activeAppName = elementObject.title;
					}
				}
                else
				{
					if (IS_IPHONE) {
						[self.mm_drawerController closeDrawerAnimated:YES completion:^(BOOL finished) {
							[[NSNotificationCenter defaultCenter] postNotificationName:A3NotificationMainMenuDidHide object:nil];
						}];
					} else if (IS_IPAD) {
						A3RootViewController_iPad *rootViewController = [[A3AppDelegate instance] rootViewController_iPad];
						if (rootViewController.showLeftView) {
							[[[A3AppDelegate instance] rootViewController_iPad] toggleLeftMenuViewOnOff];
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
			[descriptionsArray addObject:newDescription];
		}
	}
	return descriptionsArray;
}

- (BOOL)isActiveViewController:(Class)aClass {
	UINavigationController *navigationController;

	if (IS_IPHONE) {
		navigationController = (UINavigationController *) self.mm_drawerController.centerViewController;
	} else {
		A3RootViewController_iPad *rootViewController = [[A3AppDelegate instance] rootViewController_iPad];
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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	A3TableViewMenuElement *element = (A3TableViewMenuElement *) [self elementAtIndexPath:indexPath];

	cell.textLabel.text = NSLocalizedString(cell.textLabel.text, nil);

	if ([element isKindOfClass:[A3TableViewMenuElement class]]) {
		cell.textLabel.textColor = [UIColor blackColor];
		cell.accessoryView = nil;
		if (![element isKindOfClass:[A3TableViewExpandableElement class]]) {
			cell.selectionStyle = UITableViewCellSelectionStyleDefault;
		}
		NSString *imageName = [[A3AppDelegate instance] imageNameForApp:element.title];
		if ([imageName length]) {
			cell.imageView.image= [UIImage imageNamed:imageName];
			cell.imageView.tintColor = nil;
		}
	} else if ([element isKindOfClass:[A3TableViewExpandableElement class]]) {
		A3TableViewExpandableCell *expandableCell = (id)cell;
		[expandableCell.expandButton setHidden:YES];
		A3TableViewExpandableElement *expandableElement = (id)element;
		cell.imageView.image = [[UIImage imageNamed:expandableElement.isCollapsed ? @"Category_open" : @"Category_close"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
		cell.imageView.tintColor = [[A3AppDelegate instance] themeColor];
		if (![element.title isEqualToString:@"Favorites"] && ![element.title isEqualToString:@"Recent"]) {
			A3TableViewMenuElement *childElement = [[expandableElement elements] lastObject];
			NSString *groupName = [A3AppDelegate instance].appInfoDictionary[childElement.title][kA3AppsGroupName];
			cell.textLabel.textColor = [A3AppDelegate instance].groupColors[groupName];
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
	[element didSelectCellInViewController:(id) self tableView:self.tableView atIndexPath:indexPath];
}

- (void)passcodeViewControllerDidDismissWithSuccess:(BOOL)success {
    if (IS_IPHONE) {
        [self.mm_drawerController closeDrawerAnimated:NO completion:^(BOOL finished) {
            [[NSNotificationCenter defaultCenter] postNotificationName:A3DrawerStateChanged object:nil];
        }];
    }
    if (!success && _pushClockViewControllerOnPasscodeFailure) {
		[self callPrepareCloseOnActiveMainAppViewController];

		_pushClockViewControllerOnPasscodeFailure = NO;
		[self openClockApp];
        return;
    }
	if (success && _selectedElement) {
		[self callPrepareCloseOnActiveMainAppViewController];

		self.activeAppName = _selectedElement.title;

		UIViewController *viewController = [[A3AppDelegate instance] getViewControllerForAppNamed:_selectedElement.title];
		[self popToRootAndPushViewController:viewController animated:NO];
		[self updateRecentlyUsedAppsWithElement:(A3TableViewMenuElement *) _selectedElement];
	}
	_selectedElement = nil;
}

- (void)openClockApp {
	A3ClockMainViewController *clockVC = [A3ClockMainViewController new];
	[self popToRootAndPushViewController:clockVC animated:NO];
	self.activeAppName = A3AppName_Clock;
}

- (void)passcodeViewDidDisappearWithSuccess:(BOOL)success {
    _passcodeViewController = nil;
}

- (void)applicationDidEnterBackground {
	if (_passcodeViewController) {
		_passcodeViewController.delegate = nil;
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
			[[A3SyncManager sharedSyncManager] setObject:favoriteDictionary
												  forKey:A3MainMenuDataEntityFavorites
												   state:A3DataObjectStateModified];
		} else {
			NSMutableDictionary *recentDictionary = [[[A3SyncManager sharedSyncManager] objectForKey:A3MainMenuDataEntityRecentlyUsed] mutableCopy];
			recentDictionary[kA3AppsMenuCollapsed] = @(element.isCollapsed);
			[[A3SyncManager sharedSyncManager] setObject:recentDictionary
												  forKey:A3MainMenuDataEntityRecentlyUsed
												   state:A3DataObjectStateModified];
		}
	} else if (indexPath.section == 1) {
		NSMutableArray *allMenus = [[[A3AppDelegate instance] allMenuArrayFromStoredDataFile] mutableCopy];
		NSUInteger idx = [allMenus indexOfObjectPassingTest:^BOOL(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
			return [obj[kA3AppsMenuName]  isEqualToString:element.title];
		}];
		if (idx != NSNotFound) {
			NSMutableDictionary *expandableMenuDictionary = [allMenus[idx] mutableCopy];
			expandableMenuDictionary[kA3AppsMenuCollapsed] = @(element.isCollapsed);
			[allMenus replaceObjectAtIndex:idx withObject:expandableMenuDictionary];
			[[A3SyncManager sharedSyncManager] setObject:allMenus forKey:A3MainMenuDataEntityAllMenu state:A3DataObjectStateModified];
		}
		
		if (![element.title isEqualToString:@"Favorites"] && ![element.title isEqualToString:@"Recent"]) {
			A3TableViewMenuElement *childElement = [[element elements] lastObject];
			NSString *groupName = [A3AppDelegate instance].appInfoDictionary[childElement.title][kA3AppsGroupName];
			element.cell.textLabel.textColor = [A3AppDelegate instance].groupColors[groupName];
		}
	}
	if (element.isCollapsed) {
		element.cell.imageView.image = [[UIImage imageNamed:@"Category_open"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
	} else {
		element.cell.imageView.image = [[UIImage imageNamed:@"Category_close"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
	}
}

- (void)updateRecentlyUsedAppsWithElement:(A3TableViewMenuElement *)element {
	NSDictionary *appInfo = [[A3AppDelegate instance] appInfoDictionary][element.title];
	if (![element isKindOfClass:[A3TableViewMenuElement class]] || [appInfo[kA3AppsDoNotKeepAsRecent] boolValue]) {
		_mostRecentMenuElement = nil;
		return;
	}
	NSMutableDictionary *recentlyUsed = [[[A3SyncManager sharedSyncManager] objectForKey:A3MainMenuDataEntityRecentlyUsed] mutableCopy];
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

		if (maxRecent <= 1) {
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

	[[A3SyncManager sharedSyncManager] setObject:recentlyUsed
										  forKey:A3MainMenuDataEntityRecentlyUsed
										   state:A3DataObjectStateModified];

	[self setupData];
	[self.tableView reloadData];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	if (IS_IPAD) {
		[[NSNotificationCenter defaultCenter] postNotificationName:A3MainMenuBecameFirstResponder object:self];
	}
}

- (BOOL)openRecentlyUsedMenu:(BOOL)verifyPasscode {
	NSString *startingAppName = [[A3UserDefaults standardUserDefaults] objectForKey:kA3AppsStartingAppName];
	if ([startingAppName length]) {
		if ([startingAppName isEqualToString:self.activeAppName]) return YES;

		A3TableViewMenuElement *menuElement = [self menuElementWithName:startingAppName];
		if (menuElement) {
			menuElement.onSelected(menuElement, verifyPasscode);
			return YES;
		} else {
			if ([startingAppName isEqualToString:A3AppName_LunarConverter]) {
				A3LunarConverterViewController *viewController = [[A3LunarConverterViewController alloc] init];
				[self popToRootAndPushViewController:viewController animated:NO];
				self.activeAppName = startingAppName;
				return YES;
			}
		}
	}
	else if (_mostRecentMenuElement) {
		_mostRecentMenuElement.onSelected(_mostRecentMenuElement, verifyPasscode);
		return YES;
	} else if ([_activeAppName isEqualToString:A3AppName_Settings] || [_activeAppName isEqualToString:A3AppName_About]) {
		return YES;
	}
	return NO;
}

- (A3TableViewMenuElement *)menuElementWithName:(NSString *)name {
	A3TableViewSection *appMenuSection = self.rootElement.sectionsArray[1];
	for (A3TableViewExpandableElement *menuGroup in appMenuSection.elements) {
		for (A3TableViewMenuElement *menuElement in menuGroup.elements) {
			if ([menuElement.title isEqualToString:name]) {
				return menuElement;
			}
		}
	}
	return nil;
}

@end
