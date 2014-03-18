//
//  A3LaunchViewController.m
//  AppBox3
//
//  Created by A3 on 3/17/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "A3LaunchViewController.h"
#import "A3LaunchSceneTransitionManager.h"
#import "A3ClockMainViewController.h"
#import "A3LaunchSceneViewController.h"

@interface A3LaunchViewController () <UIViewControllerTransitioningDelegate>

@property (nonatomic, strong) A3LaunchSceneTransitionManager *transitionManager;
@property (nonatomic, strong) UIStoryboard *launchStoryboard;
@property (nonatomic, strong) A3LaunchSceneViewController *currentSceneViewController;
@property (nonatomic, strong) A3LaunchSceneViewController *nextSceneViewController;

@end

@implementation A3LaunchViewController {
	NSUInteger sceneNumber;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

	sceneNumber = 0;

	_launchStoryboard = [UIStoryboard storyboardWithName:@"Launch" bundle:nil];
	_currentSceneViewController = [_launchStoryboard instantiateViewControllerWithIdentifier:@"LaunchScene0"];
	_currentSceneViewController.delegate = self;

	[self.view addSubview:_currentSceneViewController.view];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	[self.navigationController setNavigationBarHidden:YES animated:NO];
	[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];

	UIImage *image = [UIImage new];
	[self.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
	[self.navigationController.navigationBar setShadowImage:image];
}

- (A3LaunchSceneTransitionManager *)transitionManager {
	if (!_transitionManager) {
		_transitionManager = [A3LaunchSceneTransitionManager new];
	}
	return _transitionManager;
}

- (IBAction)continueButtonAction:(UIButton *)sender {
}

#pragma mark - UIVieControllerTransitioningDelegate -

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                   presentingController:(UIViewController *)presenting
                                                                       sourceController:(UIViewController *)source{
    return self.transitionManager;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return self.transitionManager;
}

- (void)useICloudButtonPressedInViewController:(UIViewController *)viewController {

}

- (void)continueButtonPressedInViewController:(UIViewController *)viewController {
	sceneNumber++;
	A3LaunchSceneViewController *nextSceneViewController = [_launchStoryboard instantiateViewControllerWithIdentifier:[NSString stringWithFormat:@"LaunchScene%ld", (long)sceneNumber]];
	nextSceneViewController.delegate = self;
	nextSceneViewController.transitioningDelegate = self;
	nextSceneViewController.modalPresentationStyle = UIModalPresentationCustom;
	_currentSceneViewController = nextSceneViewController;
	[viewController presentViewController:nextSceneViewController animated:YES completion:nil];
}

- (void)useAppBoxButtonPressedInViewController:(UIViewController *)viewController {
	[viewController.view removeFromSuperview];
	_currentSceneViewController = nil;
	_launchStoryboard = nil;

	A3ClockMainViewController *clockVC = [A3ClockMainViewController new];
	[self.navigationController pushViewController:clockVC animated:NO];
}

- (BOOL)hidesNavigationBar {
	return YES;
}

@end
