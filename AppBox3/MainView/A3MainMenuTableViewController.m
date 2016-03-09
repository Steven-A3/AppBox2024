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
@property (nonatomic, strong) MBProgressHUD *hudView;

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

	if ([[A3AppDelegate instance] isIAPRemoveAdsAvailable]) {
		bottomSection = @[
				@{kA3AppsMenuName : A3AppName_RemoveAds},
				@{kA3AppsMenuName : A3AppName_RestorePurchase},
				@{kA3AppsMenuName : A3AppName_Settings},
				@{kA3AppsMenuName : A3AppName_About},
		];
	} else if ([[A3AppDelegate instance] shouldPresentAd]) {
		bottomSection = @[
				@{kA3AppsMenuName : A3AppName_RestorePurchase},
				@{kA3AppsMenuName : A3AppName_Settings},
				@{kA3AppsMenuName : A3AppName_About},
		];
	} else {
		bottomSection = @[
				@{kA3AppsMenuName : A3AppName_Settings},
				@{kA3AppsMenuName : A3AppName_About},
		];
	}

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

				if ([elementObject.title isEqualToString:A3AppName_RemoveAds]) {
					[self didSelectRemoveAdsRow];
					return;
				} else if ([elementObject.title isEqualToString:A3AppName_RestorePurchase]) {
					[self didSelectRestorePurchase];
					return;
				}

				// Check active view controller
				if (![self.activeAppName isEqualToString:elementObject.title]) {
					if ([[A3AppDelegate instance] launchAppNamed:elementObject.title verifyPasscode:verifyPasscode animated:NO]) {
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
	NSDictionary *appInfo = [[A3AppDelegate instance] appInfoDictionary][element.title];
	if (![element isKindOfClass:[A3TableViewMenuElement class]] || [appInfo[kA3AppsDoNotKeepAsRecent] boolValue]) {
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

#pragma mark In App Purchase

- (void)didSelectRemoveAdsRow {
	A3AppDelegate *appDelegate = [A3AppDelegate instance];
	appDelegate.inAppPurchaseInProgress = YES;

	[self showProcessingHUD];

	if ([appDelegate.receiptVerificator verifyAppReceipt]) {
		// 영수증을 다시 확인을 한다.
		// 영수증이 정상인데, 이 멤버가 호출이 되었다는 것은,
		// 사용자가 3.6 이후 버전을 구매했다는 의미 이므로 인앱 구매를 진행한다.
		// App Store에서 구매한 실 사용자라면 이 흐름으로 진행이 된다.

		[self executePurchaseRemoveAds];
	} else {
		// App Review 상황이거나, 앱을 App Store를 통해서 설치하지 않은 경우,
		// iTunes를 통해서 설치한 경우, 영수증이 없는 경우가 있다.
		
		// 앱 심사 과정의 Reject된 상황을 고려할 때 refreshReceipt가 App Review과정에서 실패하는 것으로
		// 추정이 된다.
		[[RMStore defaultStore] refreshReceiptOnSuccess:^{
			RMAppReceipt *appReceipt = [RMAppReceipt bundleReceipt];
			if ([appDelegate isPaidAppVersionCustomer:appReceipt]) {
				[self hideProcessingHUD];
				[self processRemoveAds];
				appDelegate.inAppPurchaseInProgress = NO;
				[self alertPaidAppCustomer];
			} else if ([appDelegate isIAPPurchasedCustomer:appReceipt]) {
				[self hideProcessingHUD];
				[self processRemoveAds];
				appDelegate.inAppPurchaseInProgress = NO;
				[self alertAlreadyPurchased];
			} else {
				[self executePurchaseRemoveAds];
			}
			[appDelegate makeReceiptBackup];
		} failure:^(NSError *error) {
			// 탈옥폰이라면 다음에 진행될 인앱 구매 진행이 실패할 것이다.
			// 앱 리뷰시 영수증 리프레시에 실패하여 이 코드가 실행이 된다.
			[self executePurchaseRemoveAds];
		}];
		return;
	}
}

- (void)executePurchaseRemoveAds {
	A3AppDelegate *appDelegate = [A3AppDelegate instance];
	
	[[RMStore defaultStore] addPayment:A3InAppPurchaseRemoveAdsProductIdentifier success:^(SKPaymentTransaction *transaction) {
		[self hideProcessingHUD];

		[self processRemoveAds];
		appDelegate.inAppPurchaseInProgress = NO;
		[[A3AppDelegate instance] makeReceiptBackup];
	} failure:^(SKPaymentTransaction *transaction, NSError *error) {
		[self hideProcessingHUD];
		
		[self alertTransactionFailed];
		appDelegate.inAppPurchaseInProgress = NO;
	}];
}

- (void)didSelectRestorePurchase {
	// App Receipt가 정상적으로 Validate가 되었는지 확인한다.
	A3AppDelegate *appDelegate = [A3AppDelegate instance];
	appDelegate.inAppPurchaseInProgress = YES;

	[self showProcessingHUD];

	if (![appDelegate.receiptVerificator verifyAppReceipt]) {
		[[RMStore defaultStore] refreshReceiptOnSuccess:^{
			[self hideProcessingHUD];

			RMAppReceipt *appReceipt = [RMAppReceipt bundleReceipt];
			if ([appDelegate isPaidAppVersionCustomer:appReceipt]) {
				[self processRemoveAds];
				[self alertPaidAppCustomer];
				appDelegate.inAppPurchaseInProgress = NO;
			} else if ([appDelegate isIAPPurchasedCustomer:appReceipt]) {
				[self processRemoveAds];
				[self alertAlreadyPurchased];
				appDelegate.inAppPurchaseInProgress = NO;
			} else {
				[self executeRestoreTransaction];
			}
			[appDelegate makeReceiptBackup];
		} failure:^(NSError *error) {
			[self executeRestoreTransaction];
		}];
		return;
	} else {
		[self executeRestoreTransaction];
	}
}

- (void)executeRestoreTransaction {
	A3AppDelegate *appDelegate = [A3AppDelegate instance];
	[[RMStore defaultStore] restoreTransactionsOnSuccess:^(NSArray *transactions) {
		[self hideProcessingHUD];
		
		BOOL isTransactionRestored = NO;
		for (SKPaymentTransaction *transaction in transactions) {
			SKPayment *payment = transaction.payment;
			if ([payment.productIdentifier isEqualToString:A3InAppPurchaseRemoveAdsProductIdentifier]) {
				isTransactionRestored = YES;
				break;
			}
		}
		
		if (isTransactionRestored) {
			[self processRemoveAds];
			[self alertRestoreSuccess];
		} else {
			[self alertRestoreFailed];
		}
		appDelegate.inAppPurchaseInProgress = NO;
	} failure:^(NSError *error) {
		[self hideProcessingHUD];
		
		appDelegate.inAppPurchaseInProgress = NO;
	}];
}

- (void)processRemoveAds {
	A3AppDelegate *appDelegate = [A3AppDelegate instance];
	appDelegate.shouldPresentAd = NO;
	appDelegate.isIAPRemoveAdsAvailable = NO;
	
	[self menuContentsChanged];
}

- (void)alertPaidAppCustomer {
	UIAlertView *alertAlreadyPurchased = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Thank You", nil)
																	message:NSLocalizedString(@"Your paid app receipt has been validated. Thank you very much.", nil)
																   delegate:nil
														  cancelButtonTitle:NSLocalizedString(@"OK", nil)
														  otherButtonTitles:nil];
	[alertAlreadyPurchased show];
}

- (void)alertAlreadyPurchased {
	UIAlertView *alertAlreadyPurchased = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Thank You", nil)
																	message:NSLocalizedString(@"You've already purchased this. Your purchases has been restored.", nil)
																   delegate:nil
														  cancelButtonTitle:NSLocalizedString(@"OK", nil)
														  otherButtonTitles:nil];
	[alertAlreadyPurchased show];
}

- (void)alertRestoreSuccess {
	UIAlertView *thanksAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Thanks", @"Thanks")
															  message:NSLocalizedString(@"Thank you very much for purchasing the AppBox Pro.", @"Thank you very much for purchasing the AppBox Pro.")
															 delegate:nil
													cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
													otherButtonTitles:nil];
	[thanksAlertView show];
}

- (void)alertRestoreFailed {
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Info", nil)
														message:NSLocalizedString(@"No Transactions to Restore", @"No Transactions to Restore")
													   delegate:nil
											  cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
											  otherButtonTitles:nil];
	[alertView show];
}

- (void)alertTransactionFailed {
	UIAlertView *purchaseFailed = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Info", @"Info")
															 message:NSLocalizedString(@"Transaction failed. Try again later.", @"Transaction failed. Try again later.")
															delegate:nil
												   cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
												   otherButtonTitles:nil];
	[purchaseFailed show];
}

- (MBProgressHUD *)hudView {
	if (!_hudView) {
		_hudView = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
		_hudView.minShowTime = 2;
		_hudView.removeFromSuperViewOnHide = YES;
		_hudView.completionBlock = ^{
			_hudView = nil;
		};
	}
	return _hudView;
}

- (void)showProcessingHUD {
	if (IS_IPHONE) {
		self.hudView.labelText = NSLocalizedString(@"Processing", @"Processing");
		[self.hudView show:YES];
	} else {
		A3AppDelegate *appDelegate = [A3AppDelegate instance];
		appDelegate.hud.labelText = NSLocalizedString(@"Processing", @"Processing");
		[appDelegate.hud show:YES];
	}
}

- (void)hideProcessingHUD {
	if (IS_IPHONE) {
		[self.hudView hide:NO];
	} else {
		A3AppDelegate *appDelegate = [A3AppDelegate instance];
		[appDelegate.hud hide:NO];
	}
}

@end
