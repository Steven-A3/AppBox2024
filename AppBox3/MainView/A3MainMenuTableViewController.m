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

NSString *const A3NotificationAppsMainMenuContentsChanged = @"A3NotificationAppsMainMenuContentsChanged";
NSString *const A3MainMenuBecameFirstResponder = @"A3MainMenuBecameFirstResponder";
NSString *const A3NotificationMainMenuDidShow = @"A3NotificationMainMenuDidShow";
NSString *const A3NotificationMainMenuDidHide = @"A3NotificationMainMenuDidHide";

@interface A3MainMenuTableViewController () <UISearchDisplayDelegate, UISearchBarDelegate, A3PasscodeViewControllerDelegate, A3TableViewExpandableElementDelegate>

@property (nonatomic, strong) UISearchDisplayController *mySearchDisplayController;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, weak) A3TableViewElement *selectedElement;
@property (nonatomic, strong) UIViewController<A3PasscodeViewControllerProtocol> *passcodeViewController;
@property (nonatomic, strong) A3TableViewElement *mostRecentMenuElement;
@property (nonatomic, strong) NSTimer *titleResetTimer;

@end

@implementation A3MainMenuTableViewController

- (instancetype)init {
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

	self.title = @"AppBox Pro";

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
	self.title = @"AppBox Pro";
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

NSString *const kA3AppsDoNotKeepAsRecent = @"DoNotKeepAsRecent";

- (id)bottomSection {
	NSArray *bottomSection = @[
			@{kA3AppsMenuName : A3AppName_Settings, kA3AppsStoryboard_iPhone : @"A3Settings", kA3AppsStoryboard_iPad:@"A3Settings", kA3AppsMenuNeedSecurityCheck : @YES, kA3AppsDoNotKeepAsRecent : @YES},
			@{kA3AppsMenuName : @"About", kA3AppsStoryboard_iPhone : @"about", kA3AppsStoryboard_iPad:@"about", kA3AppsDoNotKeepAsRecent:@YES},
//			@{kA3AppsMenuName : @"Help", kA3AppsClassName_iPhone : @"A3HelpViewController", kA3AppsDoNotKeepAsRecent:@YES},
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

			element.onSelected = ^(A3TableViewElement *elementObject, BOOL verifyPasscode) {
				FNLOG(@"self.activeAppName = %@", self.activeAppName);
				A3TableViewMenuElement *menuElement = (A3TableViewMenuElement *) elementObject;

				BOOL proceedPasscodeCheck = NO;

				// Check active view controller
				if (![self.activeAppName isEqualToString:elementObject.title]) {
					if (   verifyPasscode
                        && [A3KeychainUtils getPassword]
						&& [menuElement securitySettingsIsOn]
						&& [[A3AppDelegate instance] didPasscodeTimerEnd]
						)
					{
						proceedPasscodeCheck = YES;

						if ([menuElement.storyboardName_iPhone isEqualToString:@"A3Settings"]) {
							proceedPasscodeCheck &= [[A3UserDefaults standardUserDefaults] boolForKey:kUserDefaultsKeyForAskPasscodeForSettings];
						}
					}
					if (proceedPasscodeCheck) {
						weakSelf.selectedElement = menuElement;
						if (IS_IOS7 || ![[A3AppDelegate instance] useTouchID]) {
							[weakSelf presentLockScreen];
						} else {
							LAContext *context = [LAContext new];
							NSError *error;
							if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
								[[UIApplication sharedApplication] setStatusBarHidden:YES];
								[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
								[context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
										localizedReason:[NSString stringWithFormat:NSLocalizedString(@"Unlock %@", @"Unlock %@"), NSLocalizedString(self.selectedElement.title, nil)]
												  reply:^(BOOL success, NSError *error) {
													  dispatch_async(dispatch_get_main_queue(), ^{
														  [[UIApplication sharedApplication] setStatusBarHidden:NO];
														  [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];

														  [[A3AppDelegate instance] removeSecurityCoverView];
														  if (success) {
															  [self passcodeViewControllerDidDismissWithSuccess:YES];
														  } else {
															  [self presentLockScreen];
														  }
													  });

												  }];
							} else {
								[self presentLockScreen];
							}
						}
					} else {
						[self callPrepareCloseOnActiveMainAppViewController];

						UIViewController *targetViewController= [self getViewControllerForElement:menuElement];
						[weakSelf popToRootAndPushViewController:targetViewController];
						[weakSelf updateRecentlyUsedAppsWithElement:menuElement];

						if (IS_IPHONE) {
							[self.mm_drawerController closeDrawerAnimated:YES completion:^(BOOL finished) {
								[[NSNotificationCenter defaultCenter] postNotificationName:A3DrawerStateChanged object:nil];
							}];
						}
						self.activeAppName = elementObject.title;
					}
				}
                else
				{
					if (IS_IPHONE) {
						[self.mm_drawerController closeDrawerAnimated:YES completion:^(BOOL finished) {
							[[NSNotificationCenter defaultCenter] postNotificationName:A3DrawerStateChanged object:nil];
						}];
					} else if (IS_IPAD) {
						A3RootViewController_iPad *rootViewController = [[A3AppDelegate instance] rootViewController];
						if (rootViewController.showLeftView) {
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

- (void)presentLockScreen {
	[self dismissModalViewControllerOnMainViewController];

	self.passcodeViewController = [UIViewController passcodeViewControllerWithDelegate:self];
	UIViewController *passcodeTargetViewController;
	if (IS_IPHONE) {
		passcodeTargetViewController = [self mm_drawerController];
	} else {
		passcodeTargetViewController = [[A3AppDelegate instance] rootViewController];
	}
	[_passcodeViewController showLockScreenInViewController:passcodeTargetViewController];
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

	if ([menuElement.imageName isEqualToString:@"DaysCounter"]) {
        A3DaysCounterModelManager *sharedManager = [[A3DaysCounterModelManager alloc] init];
		[sharedManager prepareInContext:[A3AppDelegate instance].managedObjectContext];

        NSInteger lastOpenedMainIndex = [[A3UserDefaults standardUserDefaults] integerForKey:A3DaysCounterLastOpenedMainIndex];
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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	A3TableViewMenuElement *element = (A3TableViewMenuElement *) [self elementAtIndexPath:indexPath];

	cell.textLabel.text = NSLocalizedString(cell.textLabel.text, nil);

	if ([element isKindOfClass:[A3TableViewMenuElement class]]) {
		cell.textLabel.textColor = [UIColor blackColor];
		cell.accessoryView = nil;
		if (![element isKindOfClass:[A3TableViewExpandableElement class]]) {
			cell.selectionStyle = UITableViewCellSelectionStyleDefault;
		}
		if ([element.imageName length]) {
			cell.imageView.image= [UIImage imageNamed:element.imageName];
			cell.imageView.tintColor = nil;
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

		UIViewController *viewController = [self getViewControllerForElement:(A3TableViewMenuElement *) _selectedElement];
		[self popToRootAndPushViewController:viewController];
		[self updateRecentlyUsedAppsWithElement:(A3TableViewMenuElement *) _selectedElement];
	}
	_selectedElement = nil;
}

- (void)openClockApp {
	A3ClockMainViewController *clockVC = [A3ClockMainViewController new];
	[self popToRootAndPushViewController:clockVC];
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
		NSMutableArray *allMenus = [[[A3AppDelegate instance] allMenuArrayFromStoredDataFile]	mutableCopy];
		NSUInteger idx = [allMenus indexOfObjectPassingTest:^BOOL(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
			return [obj[kA3AppsMenuName]  isEqualToString:element.title];
		}];
		if (idx != NSNotFound) {
			NSMutableDictionary *expandableMenuDictionary = [allMenus[idx] mutableCopy];
			expandableMenuDictionary[kA3AppsMenuCollapsed] = @(element.isCollapsed);
			[allMenus replaceObjectAtIndex:idx withObject:expandableMenuDictionary];
			[[A3SyncManager sharedSyncManager] setObject:allMenus forKey:A3MainMenuDataEntityAllMenu state:A3DataObjectStateModified];
		}
	}
}

- (void)updateRecentlyUsedAppsWithElement:(A3TableViewMenuElement *)element {
	if (![element isKindOfClass:[A3TableViewMenuElement class]] || element.doNotKeepAsRecent) {
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
				[self popToRootAndPushViewController:viewController];
				self.activeAppName = startingAppName;
				return YES;
			}
		}
	}
	else if (_mostRecentMenuElement) {
		_mostRecentMenuElement.onSelected(_mostRecentMenuElement, verifyPasscode);
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
