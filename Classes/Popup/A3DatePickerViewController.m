//
//  A3DatePickerViewController.m
//  AppBoxPro2
//
//  Created by Byeong Kwon Kwak on 8/3/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3DatePickerViewController.h"

@interface A3DatePickerViewController ()
@property (nonatomic, strong) UIDatePicker *datePicker;
@end

@implementation A3DatePickerViewController
@synthesize datePicker = _datePicker;


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
	UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 216.0f)];
	contentView.backgroundColor = [UIColor blackColor];
	self.view = contentView;

	[self.datePicker setDate:[NSDate date]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (UIDatePicker *)datePicker {
	if (nil == _datePicker) {
		_datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 216.0f)];
		[_datePicker setDatePickerMode:UIDatePickerModeDate];
		[self.view addSubview:_datePicker];
	}
	return _datePicker;
}


@end
