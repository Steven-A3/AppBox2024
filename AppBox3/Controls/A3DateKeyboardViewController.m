//
//  A3DateKeyboardViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 2/28/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3DateKeyboardViewController.h"
#import "A3UIDevice.h"
#import "QEntryTableViewCell+Extension.h"
#import "A3Formatter.h"
#import "SFKImage.h"
#import "A3KeyboardButton_iOS7.h"

@interface A3DateKeyboardViewController ()


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

	[self layoutForWorkingMode];
}

- (void)initSymbolFont {
	[SFKImage setDefaultFont:[UIFont fontWithName:@"LigatureSymbols" size:30.0]];
	[SFKImage setDefaultColor:[UIColor blackColor]];
}

- (void)reloadPrevNextButtons {
	[self initSymbolFont];

	BOOL available = NO;
	if ([self.delegate respondsToSelector:@selector(nextAvailableForElement:)]) {
		available = [self.delegate nextAvailableForElement:self.element];
	}
	if (IS_IPAD) {
		[_nextButton setTitle:available ? @"Next" : nil forState:UIControlStateNormal];
	} else {
		UIImage *image = available ? [SFKImage imageNamed:@"arrowdown"] : nil;
		[_nextButton setImage:image forState:UIControlStateNormal];
	}
	[_nextButton setEnabled:available];

	available = NO;
	if ([self.delegate respondsToSelector:@selector(prevAvailableForElement:)]) {
		available = [self.delegate prevAvailableForElement:self.element];
	}
	if (IS_IPAD) {
		[_prevButton setTitle:available ? @"Prev" : nil forState:UIControlStateNormal];
	} else {
		UIImage *image = available ? [SFKImage imageNamed:@"arrowup"] : nil;
		[_prevButton setImage:image forState:UIControlStateNormal];
	}
	[_prevButton setEnabled:available];
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
}

- (void)resetNumberButtons {
	NSArray *order = @[_num0_Nov_Button,
			_num1_Jul_Button, _num2_Aug_Button, _num3_Sep_Button,
			_num4_Apr_Button, _num5_May_Button, _num6_Jun_Button,
			_num7_Jan_Button, _num8_Feb_Button, _num9_Mar_Button
	];
	NSInteger index = 0;
	for (UIButton *button in order) {
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
	for (A3KeyboardButton_iOS7 *button in order) {
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
	if ([_delegate respondsToSelector:@selector(A3KeyboardDoneButtonPressed)]) {
		[_delegate A3KeyboardDoneButtonPressed];
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
