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

@interface A3PaperFoldMenuViewController ()

@end

@implementation A3PaperFoldMenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		_paperFoldView = [[PaperFoldView alloc] initWithFrame:[[UIScreen mainScreen] bounds] ];
		[_paperFoldView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
		[_paperFoldView setDelegate:self];
		[_paperFoldView setUseOptimizedScreenshot:NO];
		[self.view addSubview:_paperFoldView];

		_contentView = [[UIView alloc] initWithFrame:_paperFoldView.frame];
		[_contentView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
		[_paperFoldView setCenterContentView:_contentView];

		A3HomeViewController_iPhone *homeViewController_iPhone = [[A3HomeViewController_iPhone alloc] initWithNibName:@"HomeView_iPhone" bundle:nil];
		homeViewController_iPhone.paperFoldView = _paperFoldView;
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:homeViewController_iPhone];
		[navigationController.view setFrame:_contentView.frame];
		[self addChildViewController:navigationController];
		[_contentView addSubview:[navigationController view]];

		UIView *sideMenuView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, A3_MENU_TABLE_VIEW_WIDTH, CGRectGetHeight(_paperFoldView.frame))];
		_sideMenuTableViewController = [[A3iPhoneMenuTableViewController alloc] initWithStyle:UITableViewStylePlain];
		[_sideMenuTableViewController.view setFrame:sideMenuView.frame];
		[sideMenuView addSubview:_sideMenuTableViewController.view];
		[_paperFoldView setLeftFoldContentView:sideMenuView foldCount:3 pullFactor:0.9];
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
