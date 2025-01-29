//
//  A3WalletMainTabBarController.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 11..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <AppBoxKit/AppBoxKit.h>
#import "A3WalletMainTabBarController.h"
#import "A3WalletCategoryViewController.h"
#import "A3WalletAllViewController.h"
#import "A3WalletFavoritesViewController.h"
#import "UIViewController+NumberKeyboard.h"
#import "A3WalletMoreTableViewController.h"
#import "A3WalletCategoryInfoViewController.h"
#import "A3WalletItemViewController.h"
#import "WalletData.h"
#import "A3AppDelegate.h"
#import "A3CenterViewDelegate.h"
#import "UITabBarController+extension.h"
#import "A3WalletRecentsViewController.h"
#import "UIViewController+extension.h"

#define kDefaultTabSelection    1	// default tab value is 0 (tab #1), stored in A3UserDefaults

NSString *const A3WalletNotificationCategoryChanged = @"CategoryChanged";
NSString *const A3WalletNotificationCategoryDeleted = @"CategoryDeleted";
NSString *const A3WalletNotificationCategoryAdded = @"CategoryAdded";
NSString *const A3WalletNotificationItemCategoryMoved = @"WalletItemCategoryMoved";

@interface A3WalletMainTabBarController () <GADBannerViewDelegate>

@property (nonatomic, strong) NSMutableArray *categories;
@property (nonatomic, strong) UINavigationController *myMoreNavigationController;

@end

@implementation A3WalletMainTabBarController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationController.navigationBar.prefersLargeTitles = NO;
	self.delegate = self;
    
	// test for "kWhichTabPrefKey" key value
    if (![[A3UserDefaults standardUserDefaults] objectForKey:A3WalletUserDefaultsSelectedTab]) {
        [[A3UserDefaults standardUserDefaults] setInteger:kDefaultTabSelection forKey:A3WalletUserDefaultsSelectedTab];
        [[A3UserDefaults standardUserDefaults] synchronize];
    }

	[WalletData createDirectories];

	[self categories];

	[self setupTabBar];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cloudStoreDidImport:) name:NSManagedObjectContextObjectsDidChangeNotification object:nil];

	// 카테고리 이름/아이콘이 바뀌면 탭바의 표시되는 정보도 변경되어야 하므로 노티를 수신한다.
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveCategoryChangedNotification:) name:A3WalletNotificationCategoryChanged object:nil];

	// 카테고리가 추가되면 탭바도 추가되어야 하므로 노티를 수신한다.
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveCategoryAddedNotification:) name:A3WalletNotificationCategoryAdded object:nil];

	// 카테고리가 삭제되면 탭바도 삭제되어야 하므로 노티를 수신한다.
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveCategoryDeletedNotification:) name:A3WalletNotificationCategoryDeleted object:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveItemCategoryMovedNotification:) name:A3WalletNotificationItemCategoryMoved object:nil];
}

- (void)cloudStoreDidImport:(NSNotification *)notification {
    NSManagedObjectContext *context = notification.object;
    if (![context isKindOfClass:[NSManagedObjectContext class]]) {
        return; // Ensure the notification's object is a managed object context.
    }

    NSDictionary *userInfo = notification.userInfo;

    // Combine all changes into a single set
    NSMutableSet *allChangedObjects = [NSMutableSet set];
    [allChangedObjects unionSet:userInfo[NSInsertedObjectsKey] ?: [NSSet set]];
    [allChangedObjects unionSet:userInfo[NSUpdatedObjectsKey] ?: [NSSet set]];
    [allChangedObjects unionSet:userInfo[NSDeletedObjectsKey] ?: [NSSet set]];

    // Check if any of the changes are related to the "WalletItem_" entity
    for (NSManagedObject *object in allChangedObjects) {
        if ([object.entity.name isEqualToString:@"WalletCategory_"]) {
            FNLOG(@"Change detected for WalletCategory_: %@", object);
            dispatch_async(dispatch_get_main_queue(), ^{
                self->_categories = nil;
                [self setupTabBar];
            });
            break; // No need to continue once we know there's a change
        }
    }
}

- (void)removeObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextObjectsDidChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3WalletNotificationCategoryChanged object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3WalletNotificationCategoryAdded object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3WalletNotificationCategoryDeleted object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3WalletNotificationItemCategoryMoved object:nil];
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

- (void)cleanUp {
	[self removeObserver];
}

- (void)prepareClose {
	if (self.presentedViewController) {
		[self.presentedViewController dismissViewControllerAnimated:NO completion:nil];
	}
	for (UIViewController *childViewController in self.viewControllers) {
		if ([childViewController isKindOfClass:[UINavigationController class]]) {
			UINavigationController *navigationController = (UINavigationController *)childViewController;
			UIViewController<A3CenterViewDelegate> *contentViewController = navigationController.viewControllers[0];
			if ([contentViewController respondsToSelector:@selector(prepareClose)]) {
				[contentViewController prepareClose];
			}
		}
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    UIImage *image = [UIImage new];
    [self.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:image];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

    [self setValuePrefersStatusBarHidden:NO];
    [self setValueStatusBarStyle:UIStatusBarStyleDefault];
    [self setNeedsStatusBarAppearanceUpdate];

	if ([self isMovingToParentViewController] || [self isBeingPresented]) {
		[self setupBannerViewForAdUnitID:AdMobAdUnitIDWallet keywords:@[@"wallet", @"security", @"privacy", @"notes"] delegate:self];
	}
}

- (NSMutableArray *)categories {
	if (nil == _categories) {
		_categories = [[WalletData walletCategoriesFilterDoNotShow:YES] mutableCopy];
	}
	return _categories;
}

- (void)popToRootViewControllerForCategoryID:(NSString *)categoryID {
	NSUInteger indexOfCategory = [self.categories indexOfObjectPassingTest:^BOOL(WalletCategory_ *category, NSUInteger idx, BOOL *stop) {
		return [category.uniqueID isEqualToString:categoryID];
	}];
	if (indexOfCategory < [self numberOfCategoriesInTabBar]) {
		UINavigationController *oldCategoryNavigationController = self.viewControllers[indexOfCategory];
		[oldCategoryNavigationController popToRootViewControllerAnimated:NO];
	}
}

- (void)didReceiveItemCategoryMovedNotification:(NSNotification *)notification {
	if (notification.userInfo) {
		NSString *oldCategoryID = [notification.userInfo valueForKey:@"oldCategoryID"];
		NSString *categoryID = [notification.userInfo valueForKey:@"categoryID"];
		NSString *itemID = [notification.userInfo valueForKey:@"itemID"];

		[self popToRootViewControllerForCategoryID:oldCategoryID];
		[self popToRootViewControllerForCategoryID:A3WalletUUIDAllCategory];
		[self popToRootViewControllerForCategoryID:A3WalletUUIDFavoriteCategory];

		NSUInteger indexOfSelectedCategory = [self.categories indexOfObjectPassingTest:^BOOL(WalletCategory_ *category, NSUInteger idx, BOOL *stop) {
			return [category.uniqueID isEqualToString:categoryID];
		}];
		NSUInteger numberOfCategoriesInTabBar = [self numberOfCategoriesInTabBar];
		UINavigationController *categoryNavigationController;
		if (indexOfSelectedCategory < numberOfCategoriesInTabBar) {
			[self setSelectedIndex:indexOfSelectedCategory];

			UINavigationController *navigationController = self.viewControllers[indexOfSelectedCategory];
			[navigationController popToRootViewControllerAnimated:NO];
			[navigationController.viewControllers[0] view];

			categoryNavigationController = navigationController;
		} else {
			[self setSelectedIndex:numberOfCategoriesInTabBar];

			[_myMoreNavigationController popToRootViewControllerAnimated:NO];
			[_myMoreNavigationController.viewControllers[0] view];

			A3WalletCategoryViewController *categoryViewController = [[A3WalletCategoryViewController alloc] initWithNibName:nil bundle:nil];
			categoryViewController.category = self.categories[indexOfSelectedCategory];
			categoryViewController.isFromMoreTableViewController = YES;
			[categoryViewController view];
			[_myMoreNavigationController pushViewController:categoryViewController animated:NO];

			categoryNavigationController = _myMoreNavigationController;
		}

		UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"WalletPhoneStoryBoard" bundle:nil];
		A3WalletItemViewController *itemViewController = [storyBoard instantiateViewControllerWithIdentifier:@"A3WalletItemViewController"];
		itemViewController.hidesBottomBarWhenPushed = YES;
		WalletItem_ *item = [WalletItem_ findByAttribute:@"uniqueID" withValue:itemID][0];
		itemViewController.item = item;
		itemViewController.showCategory = YES;
		itemViewController.alwaysReturnToOriginalCategory = YES;
		[categoryNavigationController pushViewController:itemViewController animated:NO];
	}
}

- (void)didReceiveCategoryChangedNotification:(NSNotification *)notification {
	_categories = nil;
	[self setupTabBar];
	if (notification.userInfo) {
		NSString *categoryID = [notification.userInfo valueForKey:@"uniqueID"];
		NSUInteger indexOfSelectedCategory = [self.categories indexOfObjectPassingTest:^BOOL(WalletCategory_ *category, NSUInteger idx, BOOL *stop) {
			BOOL match = [category.uniqueID isEqualToString:categoryID];
			if (match) *stop = YES;
			return match;
		}];
		NSUInteger numberOfCategoriesInTabBar = [self numberOfCategoriesInTabBar];
		if (indexOfSelectedCategory < numberOfCategoriesInTabBar) {
			[self setSelectedIndex:indexOfSelectedCategory];

			UINavigationController *navigationController = self.viewControllers[indexOfSelectedCategory];
			[navigationController.viewControllers[0] view];
			A3WalletCategoryInfoViewController *infoViewController = [[A3WalletCategoryInfoViewController alloc] initWithStyle:UITableViewStylePlain];
			infoViewController.category = self.categories[indexOfSelectedCategory];
			[infoViewController view];
			[navigationController pushViewController:infoViewController animated:NO];
		} else {
			[self setSelectedIndex:numberOfCategoriesInTabBar];

			[_myMoreNavigationController.viewControllers[0] view];

			A3WalletCategoryViewController *viewController = [[A3WalletCategoryViewController alloc] initWithNibName:nil bundle:nil];
			viewController.category = self.categories[indexOfSelectedCategory];
			viewController.isFromMoreTableViewController = YES;
			[viewController view];
			[_myMoreNavigationController pushViewController:viewController animated:NO];

			A3WalletCategoryInfoViewController *infoViewController = [[A3WalletCategoryInfoViewController alloc] initWithStyle:UITableViewStylePlain];
			infoViewController.category = self.categories[indexOfSelectedCategory];
			[viewController view];
			[_myMoreNavigationController pushViewController:infoViewController animated:NO];
		}
	}
}

- (void)didReceiveCategoryAddedNotification:(NSNotification *)notification
{
	_categories = nil;
	[self setupTabBar];
}

- (void)didReceiveCategoryDeletedNotification:(NSNotification *)notification
{
	_categories = nil;
	[self setupTabBar];
}

#pragma mark - UITabBarControllerDelegate

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    self.title = tabBarController.selectedViewController.tabBarItem.title;

	[[A3UserDefaults standardUserDefaults] setInteger:self.selectedIndex forKey:A3WalletUserDefaultsSelectedTab];
    [[A3UserDefaults standardUserDefaults] synchronize];
}

- (NSUInteger)numberOfCategoriesInTabBar {
	return IS_IPHONE ? 4 : 7;
}

#pragma mark - Added Function

- (void)setupTabBar
{
	self.tabBarController.tabBar.translucent = NO;
    
	_categories = nil;

    NSMutableArray *viewControllers = [[NSMutableArray alloc] init];

	NSUInteger numberOfItemsOnTapBar = [self numberOfCategoriesInTabBar];
	for (NSUInteger idx = 0; idx < MIN(numberOfItemsOnTapBar, [self.categories count]); idx++) {

        WalletCategory_ *category = self.categories[idx];
        UIViewController *viewController;
        UIImage *selectedIcon;
        
        if ([category.uniqueID isEqualToString:A3WalletUUIDAllCategory]) {
            A3WalletAllViewController *vc = [[A3WalletAllViewController alloc] initWithNibName:nil bundle:nil];
            vc.category = category;
            viewController = vc;
            NSString *selected = [category.icon stringByAppendingString:@"_on"];
            selectedIcon = [UIImage imageNamed:selected];
        }
        else if ([category.uniqueID isEqualToString:A3WalletUUIDFavoriteCategory]) {
            A3WalletFavoritesViewController *vc = [[A3WalletFavoritesViewController alloc] init];
            vc.category = category;
            viewController = vc;
            NSString *selected = [category.icon stringByAppendingString:@"_on"];
            selectedIcon = [UIImage imageNamed:selected];
        }
        else if ([category.uniqueID isEqualToString:A3WalletUUIDRecentsCategory]) {
            A3WalletRecentsViewController *vc = [[A3WalletRecentsViewController alloc] init];
            vc.category = category;
            viewController = vc;
            NSString *selected = category.icon;
            selectedIcon = [UIImage imageNamed:selected];
        }
        else {
            A3WalletCategoryViewController *vc = [[A3WalletCategoryViewController alloc] initWithNibName:nil bundle:nil];
            vc.category = category;
            viewController = vc;
            NSString *selected = [category.icon stringByAppendingString:@"_on"];
            selectedIcon = [UIImage imageNamed:selected];
        }
        
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:viewController];
        nav.tabBarItem.image = [UIImage imageNamed:category.icon];
        nav.tabBarItem.selectedImage = selectedIcon;
		NSString *title = category.name;
        nav.tabBarItem.title = title;
        
        UIFont *titleFont;
        NSArray *words = [title componentsSeparatedByString:@" "];
        if (words.count>1) {
            if (IS_IPAD) {
                titleFont = [UIFont systemFontOfSize:11];
            }
            else {
                titleFont = [UIFont systemFontOfSize:9];
            }
        }
        else {
            if (IS_IPAD) {
                titleFont = [UIFont systemFontOfSize:12];
            }
            else {
                titleFont = [UIFont systemFontOfSize:10];
            }
        }
        
        NSDictionary *textAttributes = @{NSFontAttributeName : titleFont};
        [nav.tabBarItem setTitleTextAttributes:textAttributes forState:UIControlStateNormal];
        
        [viewControllers addObject:nav];
    }

//	if ([_categories count] >= [self numberOfCategoriesInTabBar]) {
		A3WalletMoreTableViewController *moreViewController = [[A3WalletMoreTableViewController alloc] initWithStyle:UITableViewStylePlain];
		moreViewController.mainTabBarController = self;
		_myMoreNavigationController = [[UINavigationController alloc] initWithRootViewController:moreViewController];
		_myMoreNavigationController.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemMore tag:0];
		[viewControllers addObject:_myMoreNavigationController];
//	}

    self.viewControllers = viewControllers;

	FNLOG(@"%ld, %ld, %ld", (long)[[A3UserDefaults standardUserDefaults] integerForKey:A3WalletUserDefaultsSelectedTab], (long)[self numberOfCategoriesInTabBar], (long)[_categories count]);
    self.selectedIndex = MIN(MIN([[A3UserDefaults standardUserDefaults] integerForKey:A3WalletUserDefaultsSelectedTab], [self numberOfCategoriesInTabBar]), [_categories count]);

    [self makeAppearanceCompatible];
}

@end
