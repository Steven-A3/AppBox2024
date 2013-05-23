//
//  A3LoanCalcChartViewController_iPhone.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 5/21/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3LoanCalcChartViewController_iPhone.h"
#import "A3OnOffLeftRightButton.h"

@interface A3LoanCalcChartViewController_iPhone ()

@end

@implementation A3LoanCalcChartViewController_iPhone

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)leftButtonPressed {
	if ([_delegate respondsToSelector:@selector(loanCalcChartViewButtonPressed:)]) {
		[_delegate loanCalcChartViewButtonPressed:YES];
	}
}

- (IBAction)rightButtonPressed {
	if ([_delegate respondsToSelector:@selector(loanCalcChartViewButtonPressed:)]) {
		[_delegate loanCalcChartViewButtonPressed:NO];
	}
}

@end
