//
//  A3SalesCalcQuickDialogViewController_iPhone.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 4/10/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3SalesCalcQuickDialogViewController_iPhone.h"
#import "A3NumberKeyboardViewController_iPhone.h"
#import "A3HorizontalBarContainerView.h"

@interface A3SalesCalcQuickDialogViewController_iPhone ()

@end

@implementation A3SalesCalcQuickDialogViewController_iPhone

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		self.tableHeaderView.chartLabelFont = [UIFont boldSystemFontOfSize:13.0f];
		super.tableHeaderView.chartValueFont = [UIFont boldSystemFontOfSize:20.0];
		super.tableHeaderView.bottomValueFont = [UIFont boldSystemFontOfSize:24.0];
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

- (A3NumberKeyboardViewController *)keyboardViewController {
	if (nil == super.keyboardViewController) {
		super.keyboardViewController = [[A3NumberKeyboardViewController_iPhone alloc] initWithNibName:@"A3NumberKeyboardViewController_iPhone" bundle:nil];
		super.keyboardViewController.delegate = self;
	}
	return super.keyboardViewController;
}

@end
