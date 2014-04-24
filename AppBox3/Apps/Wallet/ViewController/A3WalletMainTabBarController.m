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
#import "A3WalletAddCategoryViewController.h"
#import "WalletCategory+initialize.h"
#import "NSMutableArray+A3Sort.h"
#import "A3AppDelegate.h"
#import "UIViewController+A3AppCategory.h"
#import "A3WalletMoreTableViewController.h"

// NSUserDefaults key values:
NSString *kWallet_WhichTabPrefKey		= @"kWhichTab";     // which tab to select at launch
NSString *kWallet_TabBarOrderPrefKey	= @"kTabBarOrder";  // the ordering of the tabs

#define kDefaultTabSelection    1	// default tab value is 0 (tab #1), stored in NSUserDefaults

NSString *const A3WalletNotificationCategoryChanged = @"CategoryChanged";
NSString *const A3WalletNotificationCategoryDeleted = @"CategoryDeleted";
NSString *const A3WalletNotificationCategoryAdded = @"CategoryAdded";

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
		[self startReceiveNotification];

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

		[self startReceiveNotification];
    }
    
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //self.selectedIndex = [[NSUserDefaults standardUserDefaults] unitConverterCurrentUnitTap];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	if ([self isMovingToParentViewController]) {
		[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
		[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
	}
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

- (void)startReceiveNotification
{
    // 카테고리 이름/아이콘이 바뀌면 탭바의 표시되는 정보도 변경되어야 하므로 노티를 수신한다.
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveCategoryChangedNotification:) name:A3WalletNotificationCategoryChanged object:nil];
    
    // 카테고리가 추가되면 탭바도 추가되어야 하므로 노티를 수신한다.
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveCategoryAddedNotification:) name:A3WalletNotificationCategoryAdded object:nil];

    // 카테고리가 삭제되면 탭바도 삭제되어야 하므로 노티를 수신한다.
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveCategoryDeletedNotification:) name:A3WalletNotificationCategoryDeleted object:nil];
}

- (void)didReceiveCategoryChangedNotification:(NSNotification *)notification
{
	_categories = nil;

	[self setupTabBar];
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
    
    // All화면으로 띄우고 초기화한다. (더이상 삭제된 카테고리 화면이 없음)
    self.selectedIndex = 0;
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

#pragma mark - Added Function

- (void)setupTabBar
{
	_categories = nil;

    NSMutableArray *viewControllers = [[NSMutableArray alloc] init];

	NSUInteger numberOfItemsOnTapBar = IS_IPHONE ? 4 : 7;
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
