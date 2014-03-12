//
//  A3UnitConverterTabBarController.m
//  A3TeamWork
//
//  Created by kihyunkim on 13. 10. 12..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3UnitConverterTabBarController.h"
#import "A3UnitConverterConvertTableViewController.h"
#import "UnitType.h"
#import "UnitType+initialize.h"
#import "UnitItem.h"
#import "UnitItem+initialize.h"
#import "common.h"
#import "A3AppDelegate.h"
#import "UIViewController+A3AppCategory.h"
#import "NSUserDefaults+A3Defaults.h"
#import "A3UIDevice.h"
#import "UIViewController+MMDrawerController.h"
#import "A3RootViewController_iPad.h"
#import "NSString+conversion.h"
#import "UIViewController+A3Addition.h"

// NSUserDefaults key values:
NSString *kWhichTabPrefKey		= @"kWhichTab";     // which tab to select at launch
NSString *kTabBarOrderPrefKey	= @"kTabBarOrder";  // the ordering of the tabs

#define kDefaultTabSelection    0	// default tab value is 0 (tab #1), stored in NSUserDefaults

@interface A3UnitConverterTabBarController ()

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
	// Do any additional setup after loading the view.

//    self.selectedIndex = [[NSUserDefaults standardUserDefaults] unitConverterCurrentUnitTap];
    
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
        if ([[UnitType MR_numberOfEntities] isEqualToNumber:@0 ]) {
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
    
    if (self.moreNavigationController && (self.moreNavigationController.viewControllers.count>1)) {
        [self.moreNavigationController popToRootViewControllerAnimated:NO];
    }
}

- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
    if (changed) {
        for (int i=0; i<viewControllers.count; i++) {
            UINavigationController *navController = viewControllers[i];
            UIViewController *viewController = navController.viewControllers[0];
            if ([viewController isKindOfClass:[A3UnitConverterConvertTableViewController class]]) {
                ((A3UnitConverterConvertTableViewController *)viewController).unitType.order = [NSNumber numberWithInt:i];
            }
        }
		[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
    }
}

- (void)tabBarController:(UITabBarController *)tabBarController willBeginCustomizingViewControllers:(NSArray *)viewControllers
{
}

#pragma mark - Added Function

- (void) setupTabBar
{
    NSMutableArray *marray = [[NSMutableArray alloc] init];
    
    for (int i=0; i<self.unitTypes.count; i++) {
        UnitType *utype = _unitTypes[i];
        
        A3UnitConverterConvertTableViewController *vc = [[A3UnitConverterConvertTableViewController alloc] initWithStyle:UITableViewStylePlain];
        vc.unitType = utype;
        vc.title = utype.unitTypeName;
        
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];

        nav.tabBarItem.image = [UIImage imageNamed:utype.flagImagName];
        nav.tabBarItem.selectedImage = [UIImage imageNamed:utype.selectedFlagImagName];
        
        NSDictionary *textAttributes = @{
                                         NSFontAttributeName : IS_IPAD ? [UIFont systemFontOfSize:12]:[UIFont systemFontOfSize:10]
                                         };
        [[UITabBarItem appearance] setTitleTextAttributes:textAttributes forState:UIControlStateNormal];
        
        NSArray *unitNameArray = [utype.unitTypeName componentsSeparatedByString:@" "];
        if (unitNameArray.count>1) {
            // khkim_131217 : Fuel Consumption, Electric Current에서 앞쪽 글자만 표시되도록
//            nav.tabBarItem.title = unitNameArray[0];
            
            if (IS_IPHONE) {
                nav.tabBarItem.title = unitNameArray[0];
                vc.title = unitNameArray[0];
            }
        }
        else {
            nav.tabBarItem.title = utype.unitTypeName;
        }
        
        [marray addObject:nav];
    }
    
    self.viewControllers = marray;
    
    [marray exchangeObjectAtIndex:0 withObjectAtIndex:1];
    
    self.customizableViewControllers = marray;
}

@end
