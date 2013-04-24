//
//  A3DateKeyboardViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 2/28/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "A3DateKeyboardViewController.h"
#import "A3KeyboardButton.h"
#import "A3KeyboardMoveMarkView.h"
#import "common.h"
#import "A3UIDevice.h"
#import "QEntryTableViewCell+Extension.h"
#import "A3Formatter.h"

@interface A3DateKeyboardViewController ()

@property (nonatomic, strong)	IBOutlet A3KeyboardButton *blankButton;
@property (nonatomic, strong)	IBOutlet A3KeyboardButton *yearButton;
@property (nonatomic, strong)	IBOutlet A3KeyboardButton *monthButton;
@property (nonatomic, strong)	IBOutlet A3KeyboardButton *dayButton;
@property (nonatomic, strong)	IBOutlet A3KeyboardButton *num7_Jan_Button;
@property (nonatomic, strong)	IBOutlet A3KeyboardButton *num8_Feb_Button;
@property (nonatomic, strong)	IBOutlet A3KeyboardButton *num9_Mar_Button;
@property (nonatomic, strong)	IBOutlet A3KeyboardButton *num4_Apr_Button;
@property (nonatomic, strong)	IBOutlet A3KeyboardButton *num5_May_Button;
@property (nonatomic, strong)	IBOutlet A3KeyboardButton *num6_Jun_Button;
@property (nonatomic, strong)	IBOutlet A3KeyboardButton *num1_Jul_Button;
@property (nonatomic, strong)	IBOutlet A3KeyboardButton *num2_Aug_Button;
@property (nonatomic, strong)	IBOutlet A3KeyboardButton *num3_Sep_Button;
@property (nonatomic, strong)	IBOutlet A3KeyboardButton *clear_Oct_Button;
@property (nonatomic, strong)	IBOutlet A3KeyboardButton *num0_Nov_Button;
@property (nonatomic, strong)	IBOutlet A3KeyboardButton *today_Dec_Button;
@property (nonatomic, strong)	IBOutlet A3KeyboardButton *blank2Button;
@property (nonatomic, strong)	IBOutlet A3KeyboardButton *prevButton;
@property (nonatomic, strong)	IBOutlet A3KeyboardButton *nextButton;
@property (nonatomic, strong)	IBOutlet A3KeyboardButton *doneButton;
@property (nonatomic, strong)	IBOutlet A3KeyboardMoveMarkView *markView;

@end

@implementation A3DateKeyboardViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		_workingMode = A3DateKeyboardWorkingModeYearMonthDay;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	_yearButton.blueColorOnHighlighted = YES;
	_monthButton.blueColorOnHighlighted = YES;
	_dayButton.blueColorOnHighlighted = YES;

	[self layoutForWorkingMode];
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
		[_prevButton setTitle:available?@"Prev" : @"" forState:UIControlStateNormal];
		[_prevButton setEnabled:available];
	} else {
		[_prevButton setTitle:@"Prev" forState:UIControlStateNormal];
		[_prevButton setEnabled:YES];
	}
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	[self reloadPrevNextButtons];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initExtraLabels {
	[_num7_Jan_Button removeExtraLabels];
	[_num8_Feb_Button removeExtraLabels];
	[_num9_Mar_Button removeExtraLabels];
	[_num4_Apr_Button removeExtraLabels];
	[_num5_May_Button removeExtraLabels];
	[_num6_Jun_Button removeExtraLabels];
	[_num1_Jul_Button removeExtraLabels];
	[_num2_Aug_Button removeExtraLabels];
	[_num3_Sep_Button removeExtraLabels];
	[_clear_Oct_Button removeExtraLabels];
	[_num0_Nov_Button removeExtraLabels];
	[_today_Dec_Button removeExtraLabels];
}

- (void)resetNumberButtons {
	NSArray *order = @[_num0_Nov_Button,
			_num1_Jul_Button, _num2_Aug_Button, _num3_Sep_Button,
			_num4_Apr_Button, _num5_May_Button, _num6_Jun_Button,
			_num7_Jan_Button, _num8_Feb_Button, _num9_Mar_Button
	];
	NSInteger index = 0;
	for (A3KeyboardButton *button in order) {
		[button setTitle:[NSString stringWithFormat:@"%d", index] forState:UIControlStateNormal];
		index++;
	}
	[_clear_Oct_Button setTitle:@"Clear" forState:UIControlStateNormal];
	[_today_Dec_Button setTitle:@"Today" forState:UIControlStateNormal];
}

- (IBAction)switchToYear {
	[self initExtraLabels];
	[self resetNumberButtons];

	_yearButton.selected = YES;
	_monthButton.selected = NO;
	_dayButton.selected = NO;
}

- (IBAction)switchToMonth {
	_yearButton.selected = NO;
	_monthButton.selected = YES;
	_dayButton.selected = NO;

	NSArray *order = [self monthOrder];

	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	NSArray *monthSymbols = dateFormatter.shortMonthSymbols;
	NSUInteger index = 0;
	for (A3KeyboardButton *button in order) {
		[button setTitle:@"" forState:UIControlStateNormal];
		button.mainTitle.text = [monthSymbols objectAtIndex:index];
		index++;
		button.subTitle.text = [NSString stringWithFormat:@"%d", index];
	}
}

- (IBAction)switchToDay {
	_yearButton.selected = NO;
	_monthButton.selected = NO;
	_dayButton.selected = YES;

	[self initExtraLabels];
	[self resetNumberButtons];
}

- (NSArray *)monthOrder {
	return @[
			_num7_Jan_Button, _num8_Feb_Button, _num9_Mar_Button,
			_num4_Apr_Button, _num5_May_Button, _num6_Jun_Button,
			_num1_Jul_Button, _num2_Aug_Button, _num3_Sep_Button,
			_clear_Oct_Button, _num0_Nov_Button, _today_Dec_Button];
}

- (NSArray *)numberOrder {
	return @[_num0_Nov_Button, _num1_Jul_Button, _num2_Aug_Button,
			_num3_Sep_Button, _num4_Apr_Button, _num5_May_Button,
			_num6_Jun_Button, _num7_Jan_Button, _num8_Feb_Button,
			_num9_Mar_Button
	];
}

- (NSUInteger)numberOfButton:(UIButton *)button {
	NSArray *numberOrder = [self numberOrder];
	return [numberOrder indexOfObject:button];
}

- (NSUInteger)monthNumberOfButton:(UIButton *)button {
	NSArray *monthOrder = [self monthOrder];
	NSUInteger index = [monthOrder indexOfObject:button];
	return index != NSNotFound ? (index + 1) : NSNotFound;
}

- (IBAction)numberButtonAction:(UIButton *)button {
	if (!_monthButton.selected && (button == _clear_Oct_Button || button == _today_Dec_Button)) {
		return;
	}
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *dateComponents = [gregorian components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:self.date];
	if (_monthButton.selected) {
		dateComponents.month = [self monthNumberOfButton:button];
	} else if (_yearButton.selected) {
		NSInteger year = dateComponents.year;
		year -= year / 1000 * 1000;
		year *= 10;
		year += [self numberOfButton:button];
		dateComponents.year = year;
	} else {
		NSInteger day = dateComponents.day, entered = [self numberOfButton:button];
		day *= 10;
		day += entered;

		NSRange range = [gregorian rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:_date];
		if (day > range.length) {
			NSInteger temp = day - day / 100 * 100;
			if (temp <= range.length) {
				day = temp;
			} else {
				day = entered == 0 ? dateComponents.day : entered;
			}
		}
		dateComponents.day = MAX(MIN(day, range.length), 1);
	}
	_date = [gregorian dateFromComponents:dateComponents];
	_displayLabel.text = [A3Formatter mediumStyleDateStringFromDate:_date];

	if ([_delegate respondsToSelector:@selector(dateKeyboardValueChangedDate:element:)]) {
		[_delegate dateKeyboardValueChangedDate:_date element:_element];
	}
}

- (IBAction)prevButtonAction {
	if ([_delegate respondsToSelector:@selector(prevButtonPressedWithElement:)]) {
		[_delegate prevButtonPressedWithElement:_element];
	} else {
		[_entryTableViewCell handlePrevNextWithForNext:NO];
	}
}

- (IBAction)nextButtonAction {
	if ([_delegate respondsToSelector:@selector(nextButtonPressedWithElement:)]) {
		[_delegate nextButtonPressedWithElement:_element];
	} else {
		[_entryTableViewCell handlePrevNextWithForNext:YES];
	}
}

- (IBAction)doneButtonAction {
	if ([_delegate respondsToSelector:@selector(A3KeyboardViewControllerDoneButtonPressed)]) {
		[_delegate A3KeyboardViewControllerDoneButtonPressed];
	} else {
		[_entryTableViewCell handleActionBarDone:nil];
	}
}

- (IBAction)clearButtonAction {
	if (_monthButton.selected) {
		return;
	}
	_date = nil;
	_displayLabel.text = @"";

	if ([_delegate respondsToSelector:@selector(dateKeyboardValueChangedDate:element:)]) {
		[_delegate dateKeyboardValueChangedDate:_date element:_element];
	}
}

- (IBAction)todayButtonAction {
	if (_monthButton.selected) {
		return;
	}
	_date = [NSDate date];
	_displayLabel.text = [A3Formatter mediumStyleDateStringFromDate:_date];

	if ([_delegate respondsToSelector:@selector(dateKeyboardValueChangedDate:element:)]) {
		[_delegate dateKeyboardValueChangedDate:_date element:_element];
	}
}

- (NSDate *)date {
	if (nil == _date) {
		_date = [NSDate date];
	}
	return _date;
}

- (void)resetToDefaultState {
	[self switchToMonth];
}

- (void)rotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	CGFloat col_1, col_2, col_3, col_4, col_5;
	CGFloat row_1, row_2, row_3, row_4;
	CGFloat width_small, height_small, width_big, height_big;
	if (UIDeviceOrientationIsPortrait(toInterfaceOrientation)) {
		width_big = 124.0; height_big = 118.0;
		width_small = 89.0; height_small = 57.0;
		col_1 = 74.0; col_2 = 237.0; col_3 = 338.0; col_4 = 440.0, col_5 = 570.0;
		row_1 = 6.0; row_2 = 72.0; row_3 = 137.0; row_4 = 201.0;

		[_markView setFrame:CGRectMake(755.0, 219.0, 8.0, 24.0)];
	} else {
		width_big = 172.0; height_big = 164.0;
		width_small = 108.0; height_small = 77.0;
		col_1 = 114.0; col_2 = 332.0; col_3 = 455.0; col_4 = 578.0, col_5 = 735.0;
		row_1 = 8.0; row_2 = 94.0; row_3 = 179.0; row_4 = 265.0;

		[_markView setFrame:CGRectMake(999.0, 282.0, 10.0, 24.0)];
	}
	switch (_workingMode) {
		case A3DateKeyboardWorkingModeYearMonthDay:
			[_blankButton setFrame:CGRectMake(col_1, row_1, width_big, height_small)];
			[_yearButton setFrame:CGRectMake(col_1, row_2, width_big, height_small)];
			[_monthButton setFrame:CGRectMake(col_1, row_3, width_big, height_small)];
			[_dayButton setFrame:CGRectMake(col_1, row_4, width_big, height_small)];
			break;
		case A3DateKeyboardWorkingModeYearMonth:
			[_yearButton setFrame:CGRectMake(col_1, row_1, width_big, height_big)];
			[_monthButton setFrame:CGRectMake(col_1, row_3, width_big, height_big)];
			break;
		case A3DateKeyboardWorkingModeMonth:
			break;
	}

	[_num7_Jan_Button setFrame:CGRectMake(col_2, row_1, width_small, height_small)];
	[_num4_Apr_Button setFrame:CGRectMake(col_2, row_2, width_small, height_small)];
	[_num1_Jul_Button setFrame:CGRectMake(col_2, row_3, width_small, height_small)];
	[_clear_Oct_Button setFrame:CGRectMake(col_2, row_4, width_small, height_small)];

	[_num8_Feb_Button setFrame:CGRectMake(col_3, row_1, width_small, height_small)];
	[_num5_May_Button setFrame:CGRectMake(col_3, row_2, width_small, height_small)];
	[_num2_Aug_Button setFrame:CGRectMake(col_3, row_3, width_small, height_small)];
	[_num0_Nov_Button setFrame:CGRectMake(col_3, row_4, width_small, height_small)];

	[_num9_Mar_Button setFrame:CGRectMake(col_4, row_1, width_small, height_small)];
	[_num6_Jun_Button setFrame:CGRectMake(col_4, row_2, width_small, height_small)];
	[_num3_Sep_Button setFrame:CGRectMake(col_4, row_3, width_small, height_small)];
	[_today_Dec_Button setFrame:CGRectMake(col_4, row_4, width_small, height_small)];

	[_blank2Button setFrame:CGRectMake(col_5, row_1, width_big, height_small)];
	[_prevButton setFrame:CGRectMake(col_5, row_2, width_big, height_small)];
	[_nextButton setFrame:CGRectMake(col_5, row_3, width_big, height_small)];
	[_doneButton setFrame:CGRectMake(col_5, row_4, width_big, height_small)];
}

- (void)setWorkingMode:(A3DateKeyboardWorkingMode)workingMode {
	_workingMode = workingMode;
	[self layoutForWorkingMode];
}


- (void)layoutForWorkingMode {
	[self rotateToInterfaceOrientation:[A3UIDevice deviceOrientation]];

	switch (_workingMode) {
		case A3DateKeyboardWorkingModeYearMonthDay:
			[_blankButton setHidden:NO];
			[_yearButton setHidden:NO];
			[_monthButton setHidden:NO];
			[_dayButton setHidden:NO];
			break;
		case A3DateKeyboardWorkingModeYearMonth:
			[_blankButton setHidden:YES];
			[_yearButton setHidden:NO];
			[_monthButton setHidden:NO];
			[_dayButton setHidden:YES];
			[self switchToYear];
			break;
		case A3DateKeyboardWorkingModeMonth:
			[_blankButton setHidden:YES];
			[_yearButton setHidden:YES];
			[_monthButton setHidden:YES];
			[_dayButton setHidden:YES];
			[self switchToMonth];
			break;
	}
}

@end
