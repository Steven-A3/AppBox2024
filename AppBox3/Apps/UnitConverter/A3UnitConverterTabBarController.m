//
//  A3UnitConverterTabBarController.m
//  A3TeamWork
//
//  Created by kihyunkim on 13. 10. 12..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3UnitConverterTabBarController.h"
#import "A3UnitConverterConvertTableViewController.h"
#import "UnitType+initialize.h"
#import "UIViewController+NumberKeyboard.h"
#import "NSUserDefaults+A3Defaults.h"
#import "A3UnitConverterMoreTableViewController.h"

// NSUserDefaults key values:
NSString *kWhichTabPrefKey		= @"kWhichTab";     // which tab to select at launch
NSString *kTabBarOrderPrefKey	= @"kTabBarOrder";  // the ordering of the tabs

#define kDefaultTabSelection    0	// default tab value is 0 (tab #1), stored in NSUserDefaults

@interface A3UnitConverterTabBarController ()

@property (nonatomic, strong) UINavigationController *myMoreNavigationController;

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
        
        self.delegate = self;
        
        // test for "kWhichTabPrefKey" key value
        NSUInteger testValue = [[NSUserDefaults standardUserDefaults] integerForKey:kWhichTabPrefKey];
        if (testValue == 0)
        {
            // no default source value has been set, create it here
            //
            // since no default values have been set (i.e. no preferences file created), create it here
            NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [NSNumber numberWithInt:kDefaultTabSelection], kWhichTabPrefKey,
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

    NSInteger vcIdx = [[NSUserDefaults standardUserDefaults] unitConverterCurrentUnitTap];
    
    if (vcIdx>=0 && vcIdx<self.viewControllers.count) {
        UIViewController *selectedVC = self.viewControllers[vcIdx];
        self.selectedViewController = selectedVC;
    }
    
    self.moreNavigationController.navigationBar.hidden = NO;
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
	}
}


- (NSMutableArray *)unitTypes {
	if (nil == _unitTypes) {
        if (![UnitType MR_countOfEntities]) {
            [UnitType resetUnitTypeLists];
        }
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
        
        A3UnitConverterConvertTableViewController *converterViewController = [[A3UnitConverterConvertTableViewController alloc] init];
        converterViewController.unitType = unitType;
        converterViewController.title = unitType.unitTypeName;
        
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:converterViewController];
        navigationController.tabBarItem.image = [UIImage imageNamed:unitType.flagImageName];
        navigationController.tabBarItem.selectedImage = [UIImage imageNamed:unitType.selectedFlagImagName];
        
        NSArray *unitNameArray = [unitType.unitTypeName componentsSeparatedByString:@" "];
        if (unitNameArray.count > 1) {
            if (IS_IPHONE) {
                navigationController.tabBarItem.title = unitNameArray[0];
            }
        }
        else {
            navigationController.tabBarItem.title = unitType.unitTypeName;
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
