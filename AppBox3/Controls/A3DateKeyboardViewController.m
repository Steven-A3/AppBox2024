//
//  A3DateKeyboardViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 2/28/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3DateKeyboardViewController.h"
#import "A3Formatter.h"
#import "A3KeyboardButton_iOS7.h"
#import "NSDateFormatter+LunarDate.h"
#import "NSDate+LunarConverter.h"
#import "NSUserDefaults+A3Addition.h"
#import "MBProgressHUD.h"

@interface A3DateKeyboardViewController ()
@property (nonatomic, strong) NSCalendar *gregorian;
@end

@implementation A3DateKeyboardViewController

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

	[self switchToYear];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initExtraLabels {
}

- (void)resetNumberButtons {
	NSArray *order = @[_num0_Oct_Button,
			_num1_Jul_Button, _num2_Aug_Button, _num3_Sep_Button,
			_num4_Apr_Button, _num5_May_Button, _num6_Jun_Button,
			_num7_Jan_Button, _num8_Feb_Button, _num9_Mar_Button
	];
	NSInteger index = 0;
	for (UIButton *button in order) {
		[button setTitle:[NSString stringWithFormat:@"%ld", (long)index] forState:UIControlStateNormal];
		index++;
	}

	[CATransaction begin];
	[CATransaction setValue:[NSNumber numberWithBool:YES] forKey:kCATransactionDisableActions];

	[_Nov_Button setHidden:YES];
	[_today_Dec_Button setTitle:@"Today" forState:UIControlStateNormal];

	CGRect frame = _num0_Oct_Button.frame;
	frame.size.width = CGRectGetMaxX(_num2_Aug_Button.frame) - CGRectGetMinX(_num1_Jul_Button.frame);
	_num0_Oct_Button.frame = frame;

	[CATransaction commit];
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
	NSUInteger idx = 0;

	NSString *january = monthSymbols[0];

	BOOL showNumber = [january rangeOfString:@"1"].location == NSNotFound;
	for (A3KeyboardButton_iOS7 *button in order) {
		if (showNumber) {
			[button setTitle:@"" forState:UIControlStateNormal];
			button.mainTitle.text = [monthSymbols objectAtIndex:idx];
			button.subTitle.text = [NSString stringWithFormat:@"%ld", (long)idx + 1];
		} else {
			[button setTitle:monthSymbols[idx] forState:UIControlStateNormal];
		}

		idx++;
	}

	[CATransaction begin];
	[CATransaction setValue:[NSNumber numberWithBool:YES] forKey:kCATransactionDisableActions];

	CGRect frame = _num0_Oct_Button.frame;
	frame.size.width = CGRectGetWidth(_num1_Jul_Button.frame);
	_num0_Oct_Button.frame = frame;

	[_Nov_Button setHidden:NO];

	[CATransaction commit];
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
			_num0_Oct_Button, _Nov_Button, _today_Dec_Button];
}

- (NSArray *)numberOrder {
	return @[_num0_Oct_Button, _num1_Jul_Button, _num2_Aug_Button,
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

- (NSCalendar *)gregorian {
	if (!_gregorian) {
		_gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	}
	return _gregorian;
}

- (IBAction)numberButtonAction:(UIButton *)button {
	if (!_monthButton.selected && button == _today_Dec_Button) {
		return;
	}
	if (_monthButton.selected) {
		self.dateComponents.month = [self monthNumberOfButton:button];
	} else if (_yearButton.selected) {
		NSInteger year = self.dateComponents.year;
		year *= 10;
		if (year >= 10000) year = 0;
		year += [self numberOfButton:button];
		self.dateComponents.year = year;
	} else {
		NSInteger day = self.dateComponents.day, entered = [self numberOfButton:button];
		day *= 10;
		day += entered;

		NSRange range;
		if (_isLunarDate) {
			BOOL useKorean = [[NSUserDefaults standardUserDefaults] boolForKey:A3SettingsUseKoreanCalendarForLunarConversion];
			NSInteger maxDayForMonth = [NSDate lastMonthDayForLunarYear:self.dateComponents.year month:self.dateComponents.month isKorean:useKorean];
			range = NSMakeRange(0, maxDayForMonth);
		} else {
			NSDateComponents *verifyingComponents = [self.dateComponents copy];
			verifyingComponents.day = 1;
			NSDate *verifyingDate = [self.gregorian dateFromComponents:verifyingComponents];
			range = [self.gregorian rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:verifyingDate];
		}
		if ((entered == 0 || entered > 2) && day > range.length) {
			day %= 100;
		}
		if (day > range.length) {
			day = entered;
		}
		self.dateComponents.day = MAX(MIN(day, range.length), 1);
	}

	[self updateResult];
}

- (void)updateResult {
	self.dateComponents.weekday = NSUndefinedDateComponent;
	NSDate *displayDate = [self.gregorian dateFromComponents:self.dateComponents];
	NSDateComponents *temporary = [self.gregorian components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekdayCalendarUnit fromDate:displayDate];
	self.dateComponents.weekday = temporary.weekday;
	if (!_isLunarDate) {
		_displayLabel.text = [self.dateFormatter stringFromDateComponents:self.dateComponents];
	}

	if ([_delegate respondsToSelector:@selector(dateKeyboardValueChangedDate:)]) {
		[_delegate dateKeyboardValueChangedDate:displayDate];
	}
	if ([_delegate respondsToSelector:@selector(dateKeyboardValueChangedDateComponents:)]) {
		[_delegate dateKeyboardValueChangedDateComponents:self.dateComponents];
	}
}

- (IBAction)doneButtonAction {
	if ([_delegate respondsToSelector:@selector(A3KeyboardDoneButtonPressed)]) {
		[_delegate A3KeyboardDoneButtonPressed];
	}
}

- (IBAction)todayButtonAction {
	if (_monthButton.selected) {
		return;
	}
	_dateComponents = nil;

	[self updateResult];
}

/*! Virtual method implementation to override.
 *  Subclasses will implement this for iPhone or iPad
 */
- (void)rotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
}

- (void)setDate:(NSDate *)date {
	_date = date;
	if (date) {
		_dateComponents = [self.gregorian components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekdayCalendarUnit fromDate:date];
	} else {
		_dateComponents = nil;
	}
}


- (NSDateComponents *)dateComponents {
	if (!_dateComponents) {
		_dateComponents = [self.gregorian components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekdayCalendarUnit fromDate:[NSDate date]];
	}
	return _dateComponents;
}

- (NSDateFormatter *)dateFormatter {
	if (!_dateFormatter) {
		_dateFormatter = [NSDateFormatter new];
		[_dateFormatter setDateStyle:NSDateFormatterMediumStyle];
	}
	return _dateFormatter;
}


@end
