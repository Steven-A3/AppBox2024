//
//  A3WalletMainTabBarController.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 11..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3WalletMainTabBarController.h"
#import "A3WalletCategoryViewController.h"
#import "A3WalletAllViewController.h"
#import "A3WalletFavoritesViewController.h"
#import "WalletCategory+initialize.h"
#import "UIViewController+A3AppCategory.h"
#import "A3WalletMoreTableViewController.h"
#import "A3WalletCategoryInfoViewController.h"
#import "A3WalletItemViewController.h"
#import "WalletItem.h"

// NSUserDefaults key values:
NSString *kWallet_WhichTabPrefKey		= @"kWhichTab";     // which tab to select at launch
NSString *kWallet_TabBarOrderPrefKey	= @"kTabBarOrder";  // the ordering of the tabs

#define kDefaultTabSelection    1	// default tab value is 0 (tab #1), stored in NSUserDefaults

NSString *const A3WalletNotificationCategoryChanged = @"CategoryChanged";
NSString *const A3WalletNotificationCategoryDeleted = @"CategoryDeleted";
NSString *const A3WalletNotificationCategoryAdded = @"CategoryAdded";
NSString *const A3WalletNotificationItemCategoryMoved = @"WalletItemCategoryMoved";

@interface A3WalletMainTabBarController ()

@property (nonatomic, strong) NSMutableArray *categories;
@property (nonatomic, strong) UINavigationController *myMoreNavigationController;

@end

@implementation A3WalletMainTabBarController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.delegate = self;
        
        // test for "kWhichTabPrefKey" key value
        NSUInteger preTabIndex = [[NSUserDefaults standardUserDefaults] integerForKey:kWallet_WhichTabPrefKey];
        if (preTabIndex == 0)
        {
            // no default source value has been set, create it here
            //
            // since no default values have been set (i.e. no preferences file created), create it here
            NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [NSNumber numberWithInt:kDefaultTabSelection], kWallet_WhichTabPrefKey,
                                         nil];
            
            [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
        }
        
        [self categories];
        
        [self setupTabBar];

    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        //init
        
        self.delegate = self;
        
        // test for "kWhichTabPrefKey" key value
        NSUInteger preTabIndex = [[NSUserDefaults standardUserDefaults] integerForKey:kWallet_WhichTabPrefKey];
        if (preTabIndex == 0)
        {
            // no default source value has been set, create it here
            //
            // since no default values have been set (i.e. no preferences file created), create it here
            NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [NSNumber numberWithInt:kDefaultTabSelection], kWallet_WhichTabPrefKey,
                                         nil];
            
            [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
        }
        
        [self setupTabBar];
    }
    
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];

	// 카테고리 이름/아이콘이 바뀌면 탭바의 표시되는 정보도 변경되어야 하므로 노티를 수신한다.
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveCategoryChangedNotification:) name:A3WalletNotificationCategoryChanged object:nil];

	// 카테고리가 추가되면 탭바도 추가되어야 하므로 노티를 수신한다.
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveCategoryAddedNotification:) name:A3WalletNotificationCategoryAdded object:nil];

	// 카테고리가 삭제되면 탭바도 삭제되어야 하므로 노티를 수신한다.
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveCategoryDeletedNotification:) name:A3WalletNotificationCategoryDeleted object:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveItemCategoryMovedNotification:) name:A3WalletNotificationItemCategoryMoved object:nil];
}

- (void)removeObserver {
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	FNLOG();
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (NSMutableArray *)categories {
	if (nil == _categories) {
        if ([[WalletCategory MR_numberOfEntities] isEqualToNumber:@0 ]) {
            [WalletCategory resetWalletCategory];
        }
		_categories = [NSMutableArray arrayWithArray:[WalletCategory MR_findAllSortedBy:@"order" ascending:YES]];
	}
	return _categories;
}

- (BOOL)hidesNavigationBar {
    return YES;
}

- (void)didReceiveItemCategoryMovedNotification:(NSNotification *)notification {
	if (notification.userInfo) {
		NSString *categoryID = [notification.userInfo valueForKey:@"categoryID"];
		NSString *itemID = [notification.userInfo valueForKey:@"itemID"];

		NSUInteger indexOfSelectedCategory = [self.categories indexOfObjectPassingTest:^BOOL(WalletCategory *category, NSUInteger idx, BOOL *stop) {
			BOOL match = [category.uniqueID isEqualToString:categoryID];
			if (match) *stop = YES;
			return match;
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
		WalletItem *item = [WalletItem MR_findByAttribute:@"uniqueID" withValue:itemID][0];
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
		NSUInteger indexOfSelectedCategory = [self.categories indexOfObjectPassingTest:^BOOL(WalletCategory *category, NSUInteger idx, BOOL *stop) {
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
    
    [[NSUserDefaults standardUserDefaults] setInteger:self.selectedIndex forKey:kWallet_WhichTabPrefKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (_myMoreNavigationController && (_myMoreNavigationController.viewControllers.count>1)) {
        [_myMoreNavigationController popToRootViewControllerAnimated:NO];
    }
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
	for (NSUInteger idx = 0; idx < numberOfItemsOnTapBar; idx++) {

        WalletCategory *category = self.categories[idx];
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
        nav.tabBarItem.title = category.name;
        
        UIFont *titleFont;
        NSArray *words = [category.name componentsSeparatedByString:@" "];
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

	A3WalletMoreTableViewController *moreViewController = [[A3WalletMoreTableViewController alloc] initWithStyle:UITableViewStylePlain];
	moreViewController.mainTabBarController = self;
	_myMoreNavigationController = [[UINavigationController alloc] initWithRootViewController:moreViewController];
	_myMoreNavigationController.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemMore tag:0];
	[viewControllers addObject:_myMoreNavigationController];

    self.viewControllers = viewControllers;

    self.selectedIndex = [[NSUserDefaults standardUserDefaults] integerForKey:kWallet_WhichTabPrefKey];

}

@end
