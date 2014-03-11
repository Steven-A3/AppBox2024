//
//  A3WalletMainTabBarController.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 11..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3WalletMainTabBarController.h"
#import "A3WalletCateViewController.h"
#import "A3WalletAllViewController.h"
#import "A3WalletFavoritesViewController.h"
#import "A3WalletAddCateViewController.h"
#import "A3WalletAddCateWrapViewController.h"
#import "WalletCategory+initialize.h"
#import "WalletData.h"
#import "common.h"
#import "NSMutableArray+A3Sort.h"
#import "A3AppDelegate.h"
#import "UIViewController+A3AppCategory.h"
#import "NSUserDefaults+A3Defaults.h"
#import "A3UIDevice.h"
#import "UIViewController+MMDrawerController.h"
#import "A3RootViewController_iPad.h"
#import "NSString+conversion.h"
#import "UIViewController+A3Addition.h"
#import "NSManagedObject+Identify.h"
#import "SFKImage.h"

// NSUserDefaults key values:
NSString *kWallet_WhichTabPrefKey		= @"kWhichTab";     // which tab to select at launch
NSString *kWallet_TabBarOrderPrefKey	= @"kTabBarOrder";  // the ordering of the tabs

#define kDefaultTabSelection    1	// default tab value is 0 (tab #1), stored in NSUserDefaults

@interface A3WalletMainTabBarController ()

@property (nonatomic, strong) NSMutableArray *categories;
@property (nonatomic, strong) UINavigationController *addCateNav;
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
        [self addNotiListener];

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
        
        [self addNotiListener];
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

- (NSMutableArray *)categories {
    
	if (nil == _categories) {
        if ([[WalletCategory MR_numberOfEntities] isEqualToNumber:@0 ]) {
            [WalletCategory resetWalletCategory];
        }
		_categories = [NSMutableArray arrayWithArray:[WalletCategory MR_findAllSortedBy:@"order" ascending:YES]];

//        [_categories insertObject:self.allItem atIndex:0];
//        [_categories insertObject:self.favorItem atIndex:0];
	}
	return _categories;
}

/*
- (NSMutableDictionary *)allItem
{
    if (!_allItem) {
        _allItem = [NSMutableDictionary dictionaryWithDictionary:@{@"title":@"All", @"icon":@"", @"order":@""}];
    }
    
    return _allItem;
}

- (NSMutableDictionary *)favorItem
{
    if (!_favorItem) {
        _favorItem = [NSMutableDictionary dictionaryWithDictionary:@{@"title":@"Favorite", @"icon":@"", @"order":@""}];
    }
    
    return _favorItem;
}
 */

- (BOOL)hidesNavigationBar {
    return YES;
}

- (void)addNotiListener
{
    // 카테고리 이름/아이콘이 바뀌면 탭바의 표시되는 정보도 변경되어야 하므로 노티를 수신한다.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(categoryChangeNotiRecived:) name:@"CategoryEdited" object:nil];
    
    // 카테고리가 추가되면 탭바도 추가되어야 하므로 노티를 수신한다.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(categoryAddedNotiRecived:) name:@"CategoryAdded" object:nil];
    
    // 카테고리가 삭제되면 탭바도 삭제되어야 하므로 노티를 수신한다.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(categoryDeletedNotiRecived:) name:@"CategoryDeleted" object:nil];
}

- (void)categoryChangeNotiRecived:(NSNotification *)noti
{
    for (int i=0; i<self.categories.count; i++) {
        /*
        if (_categories[i] == self.allItem) {
            
        }
        else if (_categories[i] == self.favorItem) {
            
        }
        else {
            UIViewController *viewController = self.viewControllers[i];
            
            WalletCategory *category = _categories[i];
            viewController.tabBarItem.title = category.name;
            viewController.tabBarItem.image = [UIImage imageNamed:category.icon];
        }
         */
        UIViewController *viewController = self.viewControllers[i];
        
        WalletCategory *category = _categories[i];
        viewController.tabBarItem.title = category.name;
        viewController.tabBarItem.image = [UIImage imageNamed:category.icon];
        NSString *selected = [category.icon stringByAppendingString:@"_on"];
        viewController.tabBarItem.selectedImage = [UIImage imageNamed:selected];
    }
}

- (void)categoryAddedNotiRecived:(NSNotification *)noti
{
    _categories = nil;
    
    [self setupTabBar];
}

- (void)categoryDeletedNotiRecived:(NSNotification *)noti
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
    
    if (self.moreNavigationController && (self.moreNavigationController.viewControllers.count>1)) {
        [self.moreNavigationController popToRootViewControllerAnimated:NO];
    }
}

- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
    if (changed) {
        
        NSMutableArray *tmp = [NSMutableArray new];

        for (int i=0; i<viewControllers.count; i++) {
            
            UINavigationController *navController = viewControllers[i];
            UIViewController *viewController = navController.viewControllers[0];
            if ([viewController isKindOfClass:[A3WalletCateViewController class]]) {
                A3WalletCateViewController *vc = (A3WalletCateViewController *) viewController;
                [tmp addObjectToSortedArray:vc.category];
            }
            else if ([viewController isKindOfClass:[A3WalletAllViewController class]]) {
                A3WalletAllViewController *vc = (A3WalletAllViewController *) viewController;
                [tmp addObjectToSortedArray:vc.category];
            }
            else if ([viewController isKindOfClass:[A3WalletFavoritesViewController class]]) {
                A3WalletFavoritesViewController *vc = (A3WalletFavoritesViewController *) viewController;
                [tmp addObjectToSortedArray:vc.category];
            }
            
            if (navController == self.addCateNav) {
                NSLog(@"1");
            }
        }

		[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
	}
}

#pragma mark - Added Function

- (void) setupTabBar
{
    NSMutableArray *totalArray = [[NSMutableArray alloc] init];
    NSMutableArray *configurableArray = [[NSMutableArray alloc] init];
    
    NSString *allKey = [[NSUserDefaults standardUserDefaults] stringForKey:kWalletAllCateKey];
    NSString *favKey = [[NSUserDefaults standardUserDefaults] stringForKey:kWalletFavCateKey];
    
    for (int i=0; i<self.categories.count; i++) {

        WalletCategory *category = _categories[i];
        NSString *cateKey = [category uriKey];
        UIViewController *viewController;
        UIImage *selectedIcon;
        
        if ([cateKey isEqualToString:allKey]) {
            A3WalletAllViewController *vc = [[A3WalletAllViewController alloc] initWithNibName:nil bundle:nil];
            vc.category = category;
            viewController = vc;
            NSString *selected = [category.icon stringByAppendingString:@"_on"];
            selectedIcon = [UIImage imageNamed:selected];
        }
        else if ([cateKey isEqualToString:favKey]) {
            A3WalletFavoritesViewController *vc = [[A3WalletFavoritesViewController alloc] initWithStyle:UITableViewStylePlain];
            vc.category = category;
            viewController = vc;
            NSString *selected = [category.icon stringByAppendingString:@"_on"];
            selectedIcon = [UIImage imageNamed:selected];
        }
        else {
            WalletCategory *category = _categories[i];
            
            A3WalletCateViewController *vc = [[A3WalletCateViewController alloc] initWithNibName:nil bundle:nil];
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
        
        [configurableArray addObject:nav];
        
        /*
        if (_categories[i] == self.allItem) {
            A3WalletAllViewController *vc = [[A3WalletAllViewController alloc] initWithNibName:nil bundle:nil];
            
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
            
            nav.tabBarItem.image = [UIImage imageNamed:_allItem[@"icon"]];
            nav.tabBarItem.title = _allItem[@"title"];
            
            [configurableArray addObject:nav];
        }
        else if (_categories[i] == self.favorItem) {
            A3WalletFavoritesViewController *vc = [[A3WalletFavoritesViewController alloc] initWithStyle:UITableViewStylePlain];
            
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
            
            nav.tabBarItem.image = [UIImage imageNamed:_favorItem[@"icon"]];
            nav.tabBarItem.title = _favorItem[@"title"];
            
            [configurableArray addObject:nav];
        }
        else {
            WalletCategory *category = _categories[i];
            
            A3WalletCateViewController *vc = [[A3WalletCateViewController alloc] initWithNibName:nil bundle:nil];
            vc.category = category;
            
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
            
            nav.tabBarItem.image = [UIImage imageNamed:category.icon];
            nav.tabBarItem.title = category.name;
            
            [configurableArray addObject:nav];
        }
         */
    }
    
    [totalArray addObjectsFromArray:configurableArray];
    
    // 카테고리 추가하기 화면
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"WalletPhoneStoryBoard" bundle:nil];
    A3WalletAddCateViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"A3WalletAddCateViewController"];
    vc.hidesBottomBarWhenPushed = YES;
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.tabBarItem.title = @"Add Category";
    nav.tabBarItem.image = [UIImage imageNamed:@"add01"];
    [totalArray addObject:nav];
    self.addCateNav = nav;
    
    self.viewControllers = totalArray;
    self.customizableViewControllers = configurableArray;
    
    self.selectedIndex = [[NSUserDefaults standardUserDefaults] integerForKey:kWallet_WhichTabPrefKey];

}

@end
