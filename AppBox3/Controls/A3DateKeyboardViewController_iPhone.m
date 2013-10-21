//
//  A3DateKeyboardViewController_iPhone.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 5/22/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3DateKeyboardViewController_iPhone.h"
#import "A3KeyboardButton_iPhone.h"
#import "SFKImage.h"

@interface A3DateKeyboardViewController_iPhone ()

@end

@implementation A3DateKeyboardViewController_iPhone

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

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)removeExtraLabelsForButton:(UIButton *)button {
	A3KeyboardButton_iPhone *aButton = (A3KeyboardButton_iPhone *) button;
	if ([aButton respondsToSelector:@selector(removeExtraLabels)]) {
		[aButton removeExtraLabels];
	}
}

- (void)initExtraLabels {
	[self removeExtraLabelsForButton:self.num7_Jan_Button];
	[self removeExtraLabelsForButton:self.num8_Feb_Button];
	[self removeExtraLabelsForButton:self.num9_Mar_Button];
	[self removeExtraLabelsForButton:self.num4_Apr_Button];
	[self removeExtraLabelsForButton:self.num5_May_Button];
	[self removeExtraLabelsForButton:self.num6_Jun_Button];
	[self removeExtraLabelsForButton:self.num1_Jul_Button];
	[self removeExtraLabelsForButton:self.num2_Aug_Button];
	[self removeExtraLabelsForButton:self.num3_Sep_Button];
	[self removeExtraLabelsForButton:self.clear_Dec_Button];
	[self removeExtraLabelsForButton:self.num0_Nov_Button];
	[self removeExtraLabelsForButton:self.today_Oct_Button];
}

- (IBAction)switchToMonth {
	self.yearButton.selected = NO;
	self.monthButton.selected = self.workingMode != A3DateKeyboardWorkingModeMonth;
	self.dayButton.selected = NO;

	NSArray *order = [self monthOrder];

	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	NSArray *monthSymbols = dateFormatter.shortMonthSymbols;
	NSUInteger index = 0;
	for (A3KeyboardButton_iPhone *button in order) {
		[button setTitle:nil forState:UIControlStateNormal];
		button.mainTitle.text = [monthSymbols objectAtIndex:index];
		index++;
		button.subTitle.text = [NSString stringWithFormat:@"%d", index];
	}
}

- (void)layoutForWorkingMode {
	CGRect frame1 = CGRectMake(-1, 0, 66, 55);
	CGRect frame2 = CGRectMake(-1, 54, 66, 55);
	CGRect frame3 = CGRectMake(-1, 108, 66, 55);
	CGRect frame4 = CGRectMake(-1, 162, 66, 55);

	self.blankButton.frame = frame1;
	self.yearButton.frame = frame2;
	self.monthButton.frame = frame3;
	self.dayButton.frame = frame4;

	switch (self.workingMode) {
		case A3DateKeyboardWorkingModeYearMonthDay:
			[self.blankButton setHidden:NO];
			[self.yearButton setHidden:NO];
			[self.monthButton setHidden:NO];
			[self.dayButton setHidden:NO];
			[self.monthButton setTitle:@"Month" forState:UIControlStateNormal];
			break;
		case A3DateKeyboardWorkingModeYearMonth:
			[self.blankButton setHidden:YES];
			[self.yearButton setHidden:NO];
			self.yearButton.frame = CGRectMake(-1, 0, 66, 108);
			[self.monthButton setHidden:NO];
			self.monthButton.frame = CGRectMake(-1, 108, 66, 108);
			[self.dayButton setHidden:YES];
			[self.monthButton setTitle:@"Month" forState:UIControlStateNormal];
			[self switchToYear];
			break;
		case A3DateKeyboardWorkingModeMonth:
			[self.blankButton setHidden:NO];
			self.blankButton.frame = CGRectMake(-1, 0, 66, 108);
			[self.yearButton setHidden:YES];
			[self.monthButton setHidden:NO];
			self.monthButton.frame = CGRectMake(-1, 108, 66, 108);
			[self.monthButton setTitle:nil forState:UIControlStateNormal];
			[self.dayButton setHidden:YES];
			[self switchToMonth];
			break;
	}
}

@end
