//
//  A3UnitPriceUnitTabBarController.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 3..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3UnitPriceUnitTabBarController.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+NumberKeyboard.h"
#import "UnitType.h"
#import "UnitType+initialize.h"
#import "UnitItem.h"
#import "UnitPriceFavorite.h"
#import "UnitPriceFavorite+initialize.h"
#import "UnitPriceInfo.h"
#import "A3AppDelegate.h"
#import "A3NumberKeyboardViewController.h"

@interface A3UnitPriceUnitTabBarController () <UITabBarControllerDelegate>
{
    BOOL isFavoriteMode;
    
    id<A3UnitSelectViewControllerDelegate> tossedDelegate;
}

@property (nonatomic, strong) NSMutableArray *unitTypes;
@property (nonatomic, strong) UISegmentedControl *selectSegment;

@end

@implementation A3UnitPriceUnitTabBarController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        self.delegate = self;
        
        [self setupTapBar];
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
        [self setupTapBar];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.navigationItem.titleView = self.selectSegment;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)doneButtonAction:(id)button {
	if (self.selectedViewController.presentedViewController) {
		[self.selectedViewController.presentedViewController dismissViewControllerAnimated:YES completion:NULL];
	}
	else {
		[self.A3RootViewController dismissRightSideViewController];
	}
}

- (void)setupTapBar
{
    NSDictionary *textAttributes = @{
                                     NSFontAttributeName : [UIFont systemFontOfSize:12]
                                     };
    [[UITabBarItem appearance] setTitleTextAttributes:textAttributes forState:UIControlStateNormal];
    
    NSMutableArray *viewControllers = [[NSMutableArray alloc] init];
    
    for (NSInteger i = 0; i < self.unitTypes.count; i++) {
        UnitType *unitType = _unitTypes[i];
        
        A3UnitPriceSelectViewController *viewController = [self unitSelectViewControllerWithUnitType:unitType];
        
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:viewController];
        nav.tabBarItem.image = [UIImage imageNamed:unitType.flagImageName];
        nav.tabBarItem.selectedImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_on", unitType.flagImageName]];
        nav.tabBarItem.title = unitType.unitTypeName;
        
        [nav.navigationBar setShadowImage:[UIImage new]];
        [nav.navigationBar setBackgroundImage:[UIImage new]
                               forBarPosition:UIBarPositionAny
                                   barMetrics:UIBarMetricsDefault];
        
        [viewControllers addObject:nav];
    }
    
    self.viewControllers = viewControllers;
    
    // PriceInfo에 설정된 unitType에 해당한 탭바가 선택되도록 한다.
    if (self.price.unit) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"unitTypeName == %@", self.price.unit.type.unitTypeName];
        NSArray *types = [_unitTypes filteredArrayUsingPredicate:predicate];
        if (types.count > 0) {
            UnitType *type = types[0];
            NSUInteger idx = [_unitTypes indexOfObject:type];
            
            self.selectedIndex = idx;
        }
    }
}

- (UISegmentedControl *)selectSegment
{
    UISegmentedControl *segment = [[UISegmentedControl alloc] initWithItems:@[@"All Units", @"Favorites"]];
    [segment setWidth:85 forSegmentAtIndex:0];
    [segment setWidth:85 forSegmentAtIndex:1];
    [segment setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:13.0]
                                                                forKey:NSFontAttributeName]
                           forState:UIControlStateNormal];
    segment.selectedSegmentIndex = 0;
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
}

- (NSMutableArray *)unitTypes
{
    if (!_unitTypes) {
        _unitTypes = [[NSMutableArray alloc] init];
        
        if ([[UnitType MR_numberOfEntities] isEqualToNumber:@0 ]) {
            [UnitType resetUnitTypeLists];
        }
        
        NSArray *names = @[@"Area", @"Length", @"Volume", @"Weight"];
        for (int i=0; i<names.count; i++) {
            UnitType *unitType = [UnitType MR_findFirstByAttribute:@"unitTypeName" withValue:names[i]];
            if (unitType) {
                [_unitTypes addObject:unitType];
            }
        }
    }
    return _unitTypes;
}

- (A3UnitPriceSelectViewController *)unitSelectViewControllerWithUnitType:(UnitType *)uType {
    
	A3UnitPriceSelectViewController *viewController = [[A3UnitPriceSelectViewController alloc] initWithNibName:nil bundle:nil];
	viewController.delegate = tossedDelegate;
	viewController.shouldPopViewController = YES;
    
    if ([[UnitPriceFavorite MR_numberOfEntities] isEqualToNumber:@0 ]) {
        [UnitPriceFavorite reset];
    }
    
    viewController.unitType = uType;
    viewController.favorites = [NSMutableArray arrayWithArray:[UnitPriceFavorite MR_findByAttribute:@"item.type" withValue:uType andOrderBy:@"order" ascending:YES]];
    viewController.selectedUnit = _price.unit;
    NSArray *items = [UnitItem MR_findByAttribute:@"type" withValue:uType andOrderBy:@"unitName" ascending:YES];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.unitName!=%@", @"feet inches"];
    viewController.allData = [NSMutableArray arrayWithArray:[items filteredArrayUsingPredicate:predicate]];
    
	return viewController;
}

#pragma mark - UITabBarControllerDelegate

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    /*
    UINavigationController *nav = (UINavigationController *)viewController;
    A3UnitPriceSelectViewController *vc = (A3UnitPriceSelectViewController *)nav.topViewController;
    vc.isFavoriteMode = isFavoriteMode;
     */
}

@end
