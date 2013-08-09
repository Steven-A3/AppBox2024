//
//  A3RootViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/9/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3RootViewController.h"
#import "MMDrawerController.h"
#import "A3MainMenuTableViewController.h"
#import "A3UIDevice.h"
#import "A3HomeViewController_iPad.h"
#import "A3HomeViewController_iPhone.h"

@interface A3RootViewController ()

@property (nonatomic, strong)	A3MainMenuTableViewController *leftMenuViewController;

@end

@implementation A3RootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.view.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	_leftMenuViewController = [[A3MainMenuTableViewController alloc] initWithStyle:UITableViewStylePlain];

	UIViewController *rootViewController;
	if (IS_IPAD) {
		A3HomeViewController_iPad *viewController = [[A3HomeViewController_iPad alloc] initWithNibName:@"HomeView_iPad" bundle:nil];
		rootViewController = viewController;
	} else {
		A3HomeViewController_iPhone *viewController = [[A3HomeViewController_iPhone alloc] initWithNibName:@"HomeView_iPhone" bundle:nil];
		rootViewController = viewController;
	}

	_navigationController = [[UINavigationController alloc] initWithRootViewController:rootViewController];

	_drawerController = [[MMDrawerController alloc]
			initWithCenterViewController:_navigationController leftDrawerViewController:_leftMenuViewController];
	[_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeBezelPanningCenterView];
	[_drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
	[_drawerController setDrawerVisualStateBlock:[self slideAndScaleVisualStateBlock]];
	[_drawerController setCenterHiddenInteractionMode:MMDrawerOpenCenterInteractionModeFull];

    CGRect frame;
	if ( IS_IPAD ) {
		[_drawerController setMaximumLeftDrawerWidth:256.0];
        if ( IS_LANDSCAPE ) {
            frame = CGRectMake(0.0, 0.0, 768.0, 768.0);
        } else {
            frame = CGRectMake(0.0, 0.0, 768.0, 1024.0);
        }
    } else {
        frame = self.view.bounds;
    }
    _drawerController.view.frame = frame;
	[self addChildViewController:_drawerController];
	[self.view addSubview:[_drawerController view] ];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (MMDrawerControllerDrawerVisualStateBlock)slideAndScaleVisualStateBlock{
	MMDrawerControllerDrawerVisualStateBlock visualStateBlock =
			^(MMDrawerController * drawerController, MMDrawerSide drawerSide, CGFloat percentVisible){
				CGFloat minScale = .95;
				CGFloat scale = minScale + (percentVisible*(1.0-minScale));
				CATransform3D scaleTransform =  CATransform3DMakeScale(scale, scale, scale);

				CGFloat maxDistance = 10;
				CGFloat distance = maxDistance * percentVisible;
				CATransform3D translateTransform;
				UIViewController * sideDrawerViewController;
				if(drawerSide == MMDrawerSideLeft) {
					sideDrawerViewController = drawerController.leftDrawerViewController;
					translateTransform = CATransform3DMakeTranslation((maxDistance-distance), 0.0, 0.0);
				}
				else if(drawerSide == MMDrawerSideRight){
					sideDrawerViewController = drawerController.rightDrawerViewController;
					translateTransform = CATransform3DMakeTranslation(-(maxDistance-distance), 0.0, 0.0);
				}

				[sideDrawerViewController.view.layer setTransform:CATransform3DConcat(scaleTransform, translateTransform)];
				[sideDrawerViewController.view setAlpha:percentVisible];
			};
	return visualStateBlock;
}

- (void)viewWillLayoutSubviews {
	if (IS_IPHONE) {
		return;
	}

	if ( IS_LANDSCAPE )  {
        _drawerController.view.frame = CGRectMake(0.0, 0.0, 768.0, 768.0);
        [_drawerController openDrawerSide:MMDrawerSideLeft animated:NO completion:nil];
        [_drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeNone];
	} else {
        _drawerController.view.frame = self.view.bounds;
        [_drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
        [_drawerController closeDrawerAnimated:NO completion:nil];
	}
}

@end
