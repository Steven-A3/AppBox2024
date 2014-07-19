//
//  A3UnitConverterTabBarController.m
//  A3TeamWork
//
//  Created by kihyunkim on 13. 10. 12..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3UnitConverterTabBarController.h"
#import "A3UnitConverterConvertTableViewController.h"
#import "UnitType+extension.h"
#import "UIViewController+NumberKeyboard.h"
#import "NSUserDefaults+A3Defaults.h"
#import "A3UnitConverterMoreTableViewController.h"
#import "UnitConvertItem.h"
#import "UnitConvertItem+extension.h"
#import "UnitFavorite.h"
#import "UnitFavorite+extension.h"
#import "A3AppDelegate.h"

@interface A3UnitConverterTabBarController ()

@property (nonatomic, strong) UINavigationController *myMoreNavigationController;
@property (nonatomic, strong) NSArray *moreMenuButtons;
@property (nonatomic, strong) UIView *moreMenuView;

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
        //init

		if ([UnitConvertItem MR_countOfEntities] == 0) {
			[UnitConvertItem reset];
		}
		if ([UnitFavorite MR_countOfEntities] == 0) {
			[UnitFavorite reset];
		}
		if (![UnitType MR_countOfEntities]) {
			[UnitType resetUnitTypeLists];
		}

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
}

- (void)resetSelectedTab {
	NSInteger vcIdx = [[NSUserDefaults standardUserDefaults] unitConverterCurrentUnitTap];

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
	NSInteger vcIdx = [[NSUserDefaults standardUserDefaults] unitConverterCurrentUnitTap];
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

	if ([self isMovingToParentViewController]) {
		[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
		[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	if ([self isMovingFromParentViewController]) {
		[self.navigationController setNavigationBarHidden:NO animated:NO];
		[self removeObserver];
	}
}

- (NSMutableArray *)unitTypes {
	if (nil == _unitTypes) {
		_unitTypes = [NSMutableArray arrayWithArray:[UnitType MR_findAllSortedBy:@"order" ascending:YES]];
	}
	return _unitTypes;
}

- (BOOL)hidesNavigationBar {
    return YES;
}

#pragma mark - UITabBarControllerDelegate

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    self.title = tabBarController.selectedViewController.tabBarItem.title;
	if (viewController != _myMoreNavigationController) {
		if ([_myMoreNavigationController.viewControllers count] > 1) {
			[_myMoreNavigationController popToRootViewControllerAnimated:NO];
		}
	}
}

#pragma mark - Added Function

- (void)setupTabBar
{
	NSDictionary *textAttributes = @{
			NSFontAttributeName : IS_IPAD ? [UIFont systemFontOfSize:12]:[UIFont systemFontOfSize:10]
	};
	[[UITabBarItem appearance] setTitleTextAttributes:textAttributes forState:UIControlStateNormal];

    NSMutableArray *viewControllers = [[NSMutableArray alloc] init];

	_unitTypes = nil;
	NSUInteger numberOfItemsOnTapBar = IS_IPHONE ? 4 : 7;
    for (NSInteger idx = 0; idx < numberOfItemsOnTapBar; idx++) {
        UnitType *unitType = self.unitTypes[idx];
		NSString *unitName = NSLocalizedStringFromTable(unitType.unitTypeName, @"unit", nil);
        
        A3UnitConverterConvertTableViewController *converterViewController = [[A3UnitConverterConvertTableViewController alloc] init];
        converterViewController.unitType = unitType;
        converterViewController.title = unitName;
        
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:converterViewController];
        navigationController.tabBarItem.image = [UIImage imageNamed:unitType.flagImageName];
        navigationController.tabBarItem.selectedImage = [UIImage imageNamed:unitType.selectedFlagImageName];
        
        NSArray *unitNameArray = [unitName componentsSeparatedByString:@" "];
        if (unitNameArray.count > 1) {
            if (IS_IPHONE) {
                navigationController.tabBarItem.title = unitNameArray[0];
            }
        }
        else {
            navigationController.tabBarItem.title = unitName;
        }

		[viewControllers addObject:navigationController];
    }

	A3UnitConverterMoreTableViewController *moreViewController = [[A3UnitConverterMoreTableViewController alloc] initWithStyle:UITableViewStylePlain];
	moreViewController.mainTabBarController = self;
	_myMoreNavigationController = [[UINavigationController alloc] initWithRootViewController:moreViewController];
	_myMoreNavigationController.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemMore tag:0];
	[viewControllers addObject:_myMoreNavigationController];

    self.viewControllers = viewControllers;
}

@end
