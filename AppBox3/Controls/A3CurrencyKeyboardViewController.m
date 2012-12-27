//
//  A3CurrencyKeyboardViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 12/21/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3CurrencyKeyboardViewController.h"
#import "A3GradientView.h"

@interface A3CurrencyKeyboardViewController ()
@property (nonatomic, strong) IBOutlet A3GradientView *backgroundView;
@end

@implementation A3CurrencyKeyboardViewController

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

//	[self.backgroundView setGradientColors:@[(__bridge id)[UIColor colorWithRed:158.0f/255.0f green:157.0f/255.0f blue:167.0f/255.0f alpha:1.0f].CGColor,
//			(__bridge id)[UIColor colorWithRed:67.0f/255.0f green:68.0f/255.0f blue:75.0f/255.0f alpha:1.0f].CGColor] ];
//	[self.backgroundView setNeedsDisplay];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
