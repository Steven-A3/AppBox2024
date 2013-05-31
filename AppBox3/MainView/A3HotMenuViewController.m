//
//  A3HotMenuViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 11/21/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "A3HotMenuViewController.h"
#import "A3Utilities.h"
#import "A3CalculatorViewController.h"
#import "A3CalendarViewController.h"
#import "A3UIDevice.h"
#import "PaperFoldView.h"

@interface A3HotMenuViewController ()

@property (nonatomic, strong) IBOutlet UIView *leftGradientView;
@property (nonatomic, strong) IBOutlet UIView *rightGradientView;

@end

@implementation A3HotMenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)addGradientLayer {
	// GradientLayer for Hot Menu left and right side
	CAGradientLayer *leftGradientHotMenuLayer = [CAGradientLayer layer];
	[leftGradientHotMenuLayer setColors:
			[NSArray arrayWithObjects:
					(__bridge id)[[UIColor colorWithRed:8.0f/255.0f green:8.0f/255.0f blue:9.0f/255.0f alpha:0.8f] CGColor],
					(__bridge id)[[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.0f] CGColor],
					nil ] ];
	[leftGradientHotMenuLayer setAnchorPoint:CGPointMake(0.0f, 0.0f)];
	[leftGradientHotMenuLayer setBounds:[self.leftGradientView bounds]];
	[leftGradientHotMenuLayer setStartPoint:CGPointMake(0.0f, 0.5f)];
	[leftGradientHotMenuLayer setEndPoint:CGPointMake(1.0f, 0.5f)];
	[[self.leftGradientView layer] insertSublayer:leftGradientHotMenuLayer atIndex:1];

	CAGradientLayer *rightGradientHotMenuLayer = [CAGradientLayer layer];
	[rightGradientHotMenuLayer setColors:
			[NSArray arrayWithObjects:
					(__bridge id)[[UIColor colorWithRed:8.0f/255.0f green:8.0f/255.0f blue:9.0f/255.0f alpha:0.8f] CGColor],
					(__bridge id)[[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.0f] CGColor],
					nil ] ];
	[rightGradientHotMenuLayer setAnchorPoint:CGPointMake(0.0f, 0.0f)];
	[rightGradientHotMenuLayer setBounds:[self.rightGradientView bounds]];
	[rightGradientHotMenuLayer setStartPoint:CGPointMake(1.0f, 0.5f)];
	[rightGradientHotMenuLayer setEndPoint:CGPointMake(0.0f, 0.5f)];
	[[self.rightGradientView layer] insertSublayer:rightGradientHotMenuLayer atIndex:1];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

	[self addGradientLayer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)calculatorButtonTouchUpInside:(UIButton *)sender {
	[_myNavigationController popToRootViewControllerAnimated:NO];
	BOOL deviceIsPortrait = [A3UIDevice deviceOrientationIsPortrait];
	CGRect newFrame = deviceIsPortrait ? CGRectMake(0.0, 0.0, 714.0, 1004.0) : CGRectMake(0.0, 0.0, 714.0, 748.0);
	[_myNavigationController.view setFrame:newFrame];
	[_paperFoldView setPaperFoldState:deviceIsPortrait ? PaperFoldStateDefault : PaperFoldStateLeftUnfolded];
	A3CalculatorViewController *viewController = [[A3CalculatorViewController alloc] initWithNibName:@"A3CalculatorViewController_iPad" bundle:nil];
	[_myNavigationController pushViewController:viewController animated:YES];
}

- (IBAction)calendarButtonTouchUpInside:(id)sender {
	[_myNavigationController popToRootViewControllerAnimated:NO];
	A3CalendarViewController *viewController = [[A3CalendarViewController alloc] initWithNibName:@"A3CalendarViewController" bundle:nil];
	[_myNavigationController pushViewController:viewController animated:YES];
}

@end
