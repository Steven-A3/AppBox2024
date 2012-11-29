//
//  A3PaperFoldMenuViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 11/9/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3PaperFoldMenuViewController.h"
#import "A3iPhoneMenuTableViewController.h"
#import "A3HomeViewController_iPhone.h"
#import "CommonUIDefinitions.h"
#import "A3HotMenuViewController.h"
#import "A3HomeViewController_iPad.h"
#import "A3UIDevice.h"
#import "common.h"

@interface A3PaperFoldMenuViewController ()
@property (nonatomic, strong)	UINavigationController *navigationController;
@property (nonatomic, strong)	A3HotMenuViewController *hotMenuViewController;

@end

@implementation A3PaperFoldMenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		CGRect paperFoldViewFrame = [[UIScreen mainScreen] bounds];
		// Custom initialization
		if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
			self.hotMenuViewController = [[A3HotMenuViewController alloc] initWithNibName:@"MenuView_iPad" bundle:nil];
			[self.view addSubview:[_hotMenuViewController view]];
			[self addChildViewController:_hotMenuViewController];

			paperFoldViewFrame.origin.x += _hotMenuViewController.view.frame.size.width;
			paperFoldViewFrame.size.width = 714.0f;
		}

		_paperFoldView = [[PaperFoldView alloc] initWithFrame:paperFoldViewFrame];
		[_paperFoldView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
		[_paperFoldView setDelegate:self];
		[_paperFoldView setUseOptimizedScreenshot:NO];
		[self.view addSubview:_paperFoldView];

		FNLOG(@"width: %f, height: %f", _paperFoldView.bounds.size.width, _paperFoldView.bounds.size.height);

		_contentView = [[UIView alloc] initWithFrame:_paperFoldView.bounds];
		[_contentView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin];
		[_paperFoldView setCenterContentView:_contentView];

		if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
			A3HomeViewController_iPad *homeViewController_iPad = [[A3HomeViewController_iPad alloc] initWithNibName:@"HomeView_iPad" bundle:nil];
			homeViewController_iPad.paperFoldView = _paperFoldView;
			self.navigationController = [[UINavigationController alloc] initWithRootViewController:homeViewController_iPad];
			[_navigationController.view setFrame:_contentView.bounds];
			[self addChildViewController:_navigationController];
			[_contentView addSubview:[_navigationController view]];

			self.hotMenuViewController.navigationController = _navigationController;
		} else {
			A3HomeViewController_iPhone *homeViewController_iPhone = [[A3HomeViewController_iPhone alloc] initWithNibName:@"HomeView_iPhone" bundle:nil];
			homeViewController_iPhone.paperFoldView = _paperFoldView;
			self.navigationController = [[UINavigationController alloc] initWithRootViewController:homeViewController_iPhone];
			[_navigationController.view setFrame:_contentView.bounds];
			[self addChildViewController:_navigationController];
			[_contentView addSubview:[_navigationController view]];
		}

		UIView *sideMenuView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, A3_MENU_TABLE_VIEW_WIDTH, CGRectGetHeight(_paperFoldView.frame))];
		_sideMenuTableViewController = [[A3iPhoneMenuTableViewController alloc] initWithStyle:UITableViewStylePlain];
		[_sideMenuTableViewController.view setFrame:sideMenuView.frame];
		[sideMenuView addSubview:_sideMenuTableViewController.view];
		[_paperFoldView setLeftFoldContentView:sideMenuView foldCount:3 pullFactor:0.9];

		if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
			if (![A3UIDevice deviceOrientationIsPortrait]) {
				[_paperFoldView setPaperFoldState:PaperFoldStateLeftUnfolded];
			}
		}
	}
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
