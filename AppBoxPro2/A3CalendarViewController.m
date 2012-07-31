//
//  A3CalendarViewController.m
//  AppBoxPro2
//
//  Created by Byeong Kwon Kwak on 7/31/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3CalendarViewController.h"
#import "A3CalendarMonthView.h"
#import "CoolButton.h"

@interface A3CalendarViewController ()

@property (weak, nonatomic) IBOutlet A3CalendarMonthView *monthView;
@property (weak, nonatomic) IBOutlet CoolButton *todayButton;

@end

@implementation A3CalendarViewController
@synthesize monthView = _monthView;
@synthesize todayButton = _todayButton;


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
    // Do any additional setup after loading the view from its nib.
	[self.todayButton setButtonColor:[UIColor colorWithRed:102.0f/255.0f green:102.0f/255.0f blue:222.0f/255.0f alpha:1.0f]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)viewDidLayoutSubviews {
	[super viewDidLayoutSubviews];

	[self.monthView setNeedsDisplay];
}

@end
