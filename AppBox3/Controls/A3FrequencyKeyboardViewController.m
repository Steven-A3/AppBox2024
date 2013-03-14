//
//  A3FrequencyKeyboardViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 2/22/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3FrequencyKeyboardViewController.h"
#import "A3KeyboardButton.h"
#import "A3LoanCalcString.h"
#import "QEntryTableViewCell+Extension.h"
#import "A3UIDevice.h"
#import "common.h"

@interface A3FrequencyKeyboardViewController ()

@property (nonatomic, strong) IBOutlet A3KeyboardButton *weeklyButton;
@property (nonatomic, strong) IBOutlet A3KeyboardButton *fortnightlyButton;
@property (nonatomic, strong) IBOutlet A3KeyboardButton *monthlyButton;
@property (nonatomic, strong) IBOutlet A3KeyboardButton *bimonthlyButton;
@property (nonatomic, strong) IBOutlet A3KeyboardButton *quarterlyButton;
@property (nonatomic, strong) IBOutlet A3KeyboardButton *semiAnnuallyButton;
@property (nonatomic, strong) IBOutlet A3KeyboardButton *annuallyButton;
@property (nonatomic, strong) IBOutlet A3KeyboardButton *blankButton;
@property (nonatomic, strong) IBOutlet A3KeyboardButton *prevButton;
@property (nonatomic, strong) IBOutlet A3KeyboardButton *nextButton;
@property (nonatomic, strong) IBOutlet A3KeyboardButton *doneButton;

@end

@implementation A3FrequencyKeyboardViewController

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

	[self rotateToInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];

	// Do any additional setup after loading the view.
	self.weeklyButton.tag = A3LoanCalcFrequencyWeekly;
	self.fortnightlyButton.tag = A3LoanCalcFrequencyFortnightly;
	self.monthlyButton.tag = A3LoanCalcFrequencyMonthly;
	self.bimonthlyButton.tag = A3LoanCalcFrequencyBiMonthly;
	self.quarterlyButton.tag = A3LoanCalcFrequencyQuarterly;
	self.semiAnnuallyButton.tag = A3LoanCalcFrequencySemiAnnually;
	self.annuallyButton.tag = A3LoanCalcFrequencyAnnually;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	[self reloadPrevNextButtons];
}

- (void)reloadPrevNextButtons {
	if ([_delegate respondsToSelector:@selector(nextAvailableForElement:)]) {
		BOOL available = [_delegate nextAvailableForElement:_element];
		[_nextButton setTitle:available ? @"Next" : @"" forState:UIControlStateNormal];
		[_nextButton setEnabled:available];
	} else {
		[_nextButton setTitle:@"Next" forState:UIControlStateNormal];
		[_nextButton setEnabled:YES];
	}
	if ([_delegate respondsToSelector:@selector(prevAvailableForElement:)]) {
		BOOL available = [_delegate prevAvailableForElement:_element];
		[_prevButton setTitle:available ? @"Prev" : @"" forState:UIControlStateNormal];
		[_prevButton setEnabled:available];
	} else {
		[_prevButton setTitle:@"Prev" forState:UIControlStateNormal];
		[_prevButton setEnabled:YES];
	}
}

- (void)viewDidUnload {
	[super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setSelectedFrequency:(NSNumber *)selectedFrequency {
	_selectedFrequency = selectedFrequency;
	[self.weeklyButton setSelected:NO];
	[self.fortnightlyButton setSelected:NO];
	[self.monthlyButton setSelected:NO];
	[self.bimonthlyButton setSelected:NO];
	[self.quarterlyButton setSelected:NO];
	[self.semiAnnuallyButton setSelected:NO];
	[self.annuallyButton setSelected:NO];

	UIButton *button = (UIButton *)[self.view viewWithTag:[_selectedFrequency unsignedIntegerValue] ];
	[button setSelected:YES];
}

- (IBAction)frequencyButtonTouchUpInside:(UIButton *)button {
	self.selectedFrequency = [NSNumber numberWithUnsignedInteger:(NSUInteger) button.tag];
	id <A3FrequencyKeyboardDelegate> o = self.delegate;
	if ([o respondsToSelector:@selector(frequencySelected:cell:)]) {
		[o frequencySelected:_selectedFrequency cell:_entryTableViewCell];
	}
}

- (IBAction)prevButtonTouchUpInside:(UIButton *)button {
	if ([_delegate respondsToSelector:@selector(prevButtonPressedWithElement:)]) {
		[_delegate prevButtonPressedWithElement:_element];
	} else {
		[_entryTableViewCell handlePrevNextWithForNext:NO];
	}
}

- (IBAction)nextButtonTouchUpInside:(UIButton *)button {
	if ([_delegate respondsToSelector:@selector(nextButtonPressedWithElement:)]) {
		[_delegate nextButtonPressedWithElement:_element];
	} else {
		[_entryTableViewCell handlePrevNextWithForNext:YES];
	}
}

- (IBAction)doneButtonTouchUpInside:(UIButton *)button {
	[_entryTableViewCell handleActionBarDone:nil];
}

- (void)rotateToInterfaceOrientation:(UIInterfaceOrientation)toOrientation {
	CGFloat col_1, col_2, col_3;
	CGFloat row_1, row_2, row_3, row_4;
	CGFloat width, height;

	if (UIDeviceOrientationIsPortrait(toOrientation)) {
		col_1 = 225.0; col_2 = 389.0; col_3 = 570.0;
		row_1 = 6.0; row_2 = 72.0; row_3 = 137.0; row_4 = 201.0;
		width = 154.0; height = 57.0;
	} else {
		col_1 = 335.0; col_2 = 519.0; col_3 = 735.0;
		row_1 = 8.0; row_2 = 95.0; row_3 = 179.0; row_4 = 266.0;
		width = 170.0; height = 77.0;
	}
	[_weeklyButton setFrame:CGRectMake(col_1, row_1, width, height)];
	[_fortnightlyButton setFrame:CGRectMake(col_2, row_1, width, height)];
	[_monthlyButton setFrame:CGRectMake(col_1, row_2, width, height)];
	[_bimonthlyButton setFrame:CGRectMake(col_2, row_2, width, height)];
	[_quarterlyButton setFrame:CGRectMake(col_1, row_3, width, height)];
	[_semiAnnuallyButton setFrame:CGRectMake(col_2, row_3, width, height)];
	[_annuallyButton setFrame:CGRectMake(col_1, row_4, width, height)];
	[_blankButton setFrame:CGRectMake(col_3, row_1, width, height)];
	[_prevButton setFrame:CGRectMake(col_3, row_2, width, height)];
	[_nextButton setFrame:CGRectMake(col_3, row_3, width, height)];
	[_doneButton setFrame:CGRectMake(col_3, row_4, width, height)];
}

@end
