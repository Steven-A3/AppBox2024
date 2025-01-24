//
//  A3UnitPriceUnitTabBarController.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 3..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3UnitPriceUnitTabBarController.h"
#import "UIViewController+A3Addition.h"
#import "UnitPriceInfo.h"
#import "A3UnitDataManager.h"
#import "UIViewController+extension.h"
#import "A3AppDelegate.h"
#import "A3UIDevice.h"

@interface A3UnitPriceUnitTabBarController () <UITabBarControllerDelegate, GADBannerViewDelegate>
{
    BOOL isFavoriteMode;
    
    id<A3UnitSelectViewControllerDelegate> tossedDelegate;
}

@property (nonatomic, strong) NSMutableArray *unitCategories;
@property (nonatomic, strong) UISegmentedControl *selectSegment;
@property (nonatomic, strong) A3UnitDataManager *dataManager;

@end

NSString *const A3UnitPriceSegmentIndex = @"A3UnitPriceSegmentIndex";

@implementation A3UnitPriceUnitTabBarController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.delegate = self;
        
        [self setupTabBar];
    }
    return self;
}

- (id)initWithDelegate:(id<A3UnitSelectViewControllerDelegate>)delegate withPrice:(UnitPriceInfo *)price
{
    self = [super init];
    
    if (self) {
        self.delegate = self;
        tossedDelegate = delegate;
        self.price = price;
        [self setupTabBar];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.navigationItem.titleView = self.selectSegment;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if ([self isMovingToParentViewController] || [self isBeingPresented]) {
        [self setupBannerViewForAdUnitID:AdMobAdUnitIDUnitPrice keywords:@[@"shopping", @"price", @"sale"] delegate:self];
    }
	if ([self.navigationController.navigationBar isHidden]) {
		[self showNavigationBarOn:self.navigationController];
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (A3UnitDataManager *)dataManager {
	if (!_dataManager) {
		_dataManager = [A3UnitDataManager new];
	}
	return _dataManager;
}


- (void)doneButtonAction:(id)button {
	if (self.selectedViewController.presentedViewController) {
		[self.selectedViewController.presentedViewController dismissViewControllerAnimated:YES completion:NULL];
	}
	else {
		[[[A3AppDelegate instance] rootViewController_iPad] dismissRightSideViewController];
	}
}

- (void)setupTabBar
{
    NSDictionary *textAttributes = @{
                                     NSFontAttributeName : [UIFont systemFontOfSize:12]
                                     };
    [[UITabBarItem appearance] setTitleTextAttributes:textAttributes forState:UIControlStateNormal];
    
    NSMutableArray *viewControllers = [[NSMutableArray alloc] init];
    
    for (NSInteger i = 0; i < self.unitCategories.count; i++) {
        NSDictionary *unitCategory = _unitCategories[i];
		NSUInteger categoryID = [unitCategory[ID_KEY] unsignedIntegerValue];

		A3UnitPriceSelectViewController *viewController = [self unitSelectViewControllerWithUnitType:categoryID];

        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:viewController];
        nav.tabBarItem.image = [UIImage imageNamed:[_dataManager iconNameForID:categoryID ] ];
        nav.tabBarItem.selectedImage = [UIImage imageNamed:[_dataManager selectedIconNameForID:categoryID ] ];
        nav.tabBarItem.title = unitCategory[NAME_KEY];
        
        [nav.navigationBar setShadowImage:[UIImage new]];
        [nav.navigationBar setBackgroundImage:[UIImage new]
                               forBarPosition:UIBarPositionAny
                                   barMetrics:UIBarMetricsDefault];
        
        [viewControllers addObject:nav];
    }
    
    self.viewControllers = viewControllers;
    
    // PriceInfo에 설정된 unitType에 해당한 탭바가 선택되도록 한다.
    if (self.price.unitCategoryID) {
		NSUInteger idx = [_unitCategories indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
			return [obj[ID_KEY] isEqualToNumber:self.price.unitCategoryID];
		}];

		self.selectedIndex = idx;
    }
}

- (UISegmentedControl *)selectSegment
{
    UISegmentedControl *segment = [[UISegmentedControl alloc] initWithItems:@[NSLocalizedString(@"All Units", @"All Units"), NSLocalizedString(@"Favorites", @"Favorites")]];
    [segment setWidth:IS_IPAD? 150 : 85 forSegmentAtIndex:0];
    [segment setWidth:IS_IPAD? 150 : 85 forSegmentAtIndex:1];
    [segment setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:13.0]
                                                                forKey:NSFontAttributeName]
                           forState:UIControlStateNormal];
    NSNumber *selectedSegmentIndex = [[NSUserDefaults standardUserDefaults] objectForKey:A3UnitPriceSegmentIndex];
    segment.selectedSegmentIndex = !selectedSegmentIndex ? 1 : [selectedSegmentIndex integerValue];
    [segment addTarget:self action:@selector(selectSegmentChanged:) forControlEvents:UIControlEventValueChanged];
    
    return segment;
}

- (void)selectSegmentChanged:(UISegmentedControl*) segment
{
    switch (segment.selectedSegmentIndex) {
        case 0:
        {
            UINavigationController *nav = (UINavigationController *)self.selectedViewController;
            A3UnitPriceSelectViewController *viewController = (A3UnitPriceSelectViewController *)nav.topViewController;
            viewController.isFavoriteMode = NO;
            isFavoriteMode = NO;
            [viewController setEditing:NO];
            
            break;
        }
        case 1:
        {
            UINavigationController *nav = (UINavigationController *)self.selectedViewController;
            A3UnitPriceSelectViewController *viewController = (A3UnitPriceSelectViewController *)nav.topViewController;
            viewController.isFavoriteMode = YES;
            isFavoriteMode = YES;
            [viewController setEditing:NO];
            
            break;
        }
        default:
            break;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:@(segment.selectedSegmentIndex) forKey:A3UnitPriceSegmentIndex];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSMutableArray *)unitCategories
{
    if (!_unitCategories) {
		NSArray *allUnitCategories = [self.dataManager allCategories];
		_unitCategories = [NSMutableArray new];

		NSArray *unitPriceUnits = @[@"Area", @"Length", @"Volume", @"Weight"];
		[allUnitCategories enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			if ([unitPriceUnits containsObject:[_dataManager categoryNameForID:[obj[ID_KEY] unsignedIntegerValue] ] ]) {
				[_unitCategories addObject:obj];
			}
		}];
    }
    return _unitCategories;
}

- (A3UnitPriceSelectViewController *)unitSelectViewControllerWithUnitType:(NSUInteger)categoryID {
	A3UnitPriceSelectViewController *viewController = [[A3UnitPriceSelectViewController alloc] initWithNibName:nil bundle:nil];
	viewController.delegate = tossedDelegate;
	viewController.shouldPopViewController = YES;
    viewController.categoryID = categoryID;
    viewController.selectedCategoryID = [_price.unitCategoryID unsignedIntegerValue];
	viewController.selectedUnitID = validUnit(_price.unitID) ? [_price.unitID unsignedIntegerValue] : NSNotFound;
	viewController.dataManager = self.dataManager;

	return viewController;
}

@end
