//
//  A3SalesCalcQuickDialogViewController_iPad.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 4/10/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3SalesCalcQuickDialogViewController_iPad.h"
#import "A3HorizontalBarContainerView.h"

@interface A3SalesCalcQuickDialogViewController_iPad ()

@end

@implementation A3SalesCalcQuickDialogViewController_iPad

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		self.tableHeaderView.chartLabelFont = [UIFont boldSystemFontOfSize:18.0];
		self.tableHeaderView.chartValueFont = [UIFont boldSystemFontOfSize:22.0];
		self.tableHeaderView.bottomValueFont = [UIFont boldSystemFontOfSize:20.0];
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
	if (nil == self.keyboardViewController) {
			self.keyboardViewController = [[A3NumberKeyboardViewController_iPad alloc] initWithNibName:@"A3NumberKeyboardViewController_iPad" bundle:nil];
		self.keyboardViewController.delegate = self;
	}
	return self.keyboardViewController;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];

	A3NumberKeyboardViewController_iPad *kbvc = (A3NumberKeyboardViewController_iPad *) self.keyboardViewController;
	if ([kbvc respondsToSelector:@selector(rotateToInterfaceOrientation:)]) {
		[kbvc rotateToInterfaceOrientation:toInterfaceOrientation];
	}
}

@end
