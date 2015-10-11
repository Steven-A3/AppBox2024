//
//  A3UnitConverterTabBarController.m
//  A3TeamWork
//
//  Created by kihyunkim on 13. 10. 12..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3UnitConverterTabBarController.h"
#import "A3UnitConverterConvertTableViewController.h"
#import "UIViewController+NumberKeyboard.h"
#import "A3UnitConverterMoreTableViewController.h"
#import "A3AppDelegate.h"
#import "A3UnitDataManager.h"
#import "A3SyncManager.h"
#import "A3SyncManager+NSUbiquitousKeyValueStore.h"
#import "UIViewController+A3Addition.h"
#import "A3CenterViewDelegate.h"
#import "A3UserDefaults.h"

@interface A3UnitConverterTabBarController () <A3ViewControllerProtocol>

@property (nonatomic, strong) UINavigationController *myMoreNavigationController;
@property (nonatomic, strong) UIView *moreMenuView;
@property (nonatomic, strong) A3UnitDataManager *dataManager;

@end

@implementation A3UnitConverterTabBarController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.delegate = self;

        [self setupTabBar];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self resetSelectedTab];
    
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cloudStoreDidImport) name:A3NotificationCloudKeyValueStoreDidImport object:nil];

    [[A3AppDelegate instance] popStartingAppInfo];
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

- (A3UnitDataManager *)dataManager {
	if (!_dataManager) {
		_dataManager = [A3UnitDataManager new];
	}
	return _dataManager;
}

- (void)resetSelectedTab {
    id defaultID = [[A3SyncManager sharedSyncManager] objectForKey:A3UnitConverterDefaultSelectedCategoryID];
	NSInteger vcIdx = 0;
    if (defaultID) {
        NSInteger unitID = [defaultID integerValue];
        NSArray *allCategories = [self.dataManager allCategories];
		vcIdx = [allCategories indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
				return [obj[ID_KEY] unsignedIntegerValue] == unitID;
			}];
    }

	if (vcIdx > [self.viewControllers count] - 1) {
		self.selectedViewController = [self.viewControllers lastObject];
	}
	else {
		if (vcIdx >= 0 && vcIdx < self.viewControllers.count) {
			UIViewController *selectedVC = self.viewControllers[vcIdx];
			self.selectedViewController = selectedVC;
		}
	}
}

- (void)cloudStoreDidImport {
	NSInteger vcIdx = [[A3SyncManager sharedSyncManager] integerForKey:A3UnitConverterDefaultSelectedCategoryID];
	if (self.selectedIndex != vcIdx) {
		[self resetSelectedTab];
	}
}

- (void)removeObserver {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationCloudKeyValueStoreDidImport object:nil];
}

- (void)dealloc {
	[self removeObserver];
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

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	if ([self isMovingFromParentViewController]) {
		[self.navigationController setNavigationBarHidden:NO animated:NO];
		[self removeObserver];
	}
}

- (BOOL)resignFirstResponder {
	[self.tabBarController.selectedViewController resignFirstResponder];

	return [super resignFirstResponder];
}

#pragma mark - UITabBarControllerDelegate

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
	self.title = tabBarController.selectedViewController.tabBarItem.title;
}

#pragma mark - Added Function

- (void)setupTabBar
{
	NSDictionary *textAttributes = @{
			NSFontAttributeName : IS_IPAD ? [UIFont systemFontOfSize:12]:[UIFont systemFontOfSize:10]
	};
	[[UITabBarItem appearance] setTitleTextAttributes:textAttributes forState:UIControlStateNormal];

	NSArray *unitCategories = [self.dataManager allCategories];
    NSMutableArray *viewControllers = [[NSMutableArray alloc] init];

	NSUInteger numberOfItemsOnTapBar = IS_IPHONE ? 4 : 7;
    for (NSUInteger idx = 0; idx < numberOfItemsOnTapBar; idx++) {
		NSUInteger categoryID = [unitCategories[idx][ID_KEY] unsignedIntegerValue];
		NSString *categoryName = [self.dataManager localizedCategoryNameForID:categoryID];

        A3UnitConverterConvertTableViewController *converterViewController = [[A3UnitConverterConvertTableViewController alloc] init];
        converterViewController.categoryID = categoryID;
        converterViewController.title = categoryName;
		converterViewController.dataManager = _dataManager;

        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:converterViewController];
        navigationController.tabBarItem.image = [UIImage imageNamed:[_dataManager iconNameForID:categoryID]];
        navigationController.tabBarItem.selectedImage = [UIImage imageNamed:[_dataManager selectedIconNameForID:categoryID]];

        NSArray *unitNameArray = [categoryName componentsSeparatedByString:@" "];
        if (unitNameArray.count > 1) {
            if (IS_IPHONE) {
                navigationController.tabBarItem.title = unitNameArray[0];
            }
        }
        else {
            navigationController.tabBarItem.title = categoryName;
        }

		[viewControllers addObject:navigationController];
    }

	A3UnitConverterMoreTableViewController *moreViewController = [[A3UnitConverterMoreTableViewController alloc] initWithStyle:UITableViewStylePlain];
	moreViewController.mainTabBarController = self;
	moreViewController.dataManager = self.dataManager;
	_myMoreNavigationController = [[UINavigationController alloc] initWithRootViewController:moreViewController];
	_myMoreNavigationController.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemMore tag:0];
	[viewControllers addObject:_myMoreNavigationController];

    self.viewControllers = viewControllers;
}

#pragma mark - A3ViewControllerProtocol

- (BOOL)shouldAllowExtensionPointIdentifier:(NSString *)extensionPointIdentifier {
	return NO;
}

@end
