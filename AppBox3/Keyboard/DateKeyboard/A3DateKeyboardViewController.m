//
//  A3DateKeyboardViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 2/28/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3DateKeyboardViewController.h"
#import "A3KeyboardButton_iOS7.h"
#import "NSDateFormatter+LunarDate.h"
#import "NSDate+LunarConverter.h"
#import "NSUserDefaults+A3Addition.h"

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

	[self changeInputToYear];

	[self.yearButton setTitle:NSLocalizedString(@"Year", nil) forState:UIControlStateNormal];
	[self.monthButton setTitle:NSLocalizedString(@"Month", nil) forState:UIControlStateNormal];
	[self.dayButton setTitle:NSLocalizedString(@"Day", nil) forState:UIControlStateNormal];
	[self.doneButton setTitle:NSLocalizedString(@"DoneButton", nil) forState:UIControlStateNormal];
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

- (void)resetToNumbersButtons {
	NSArray *order = @[_num0_Nov_Button,
			_num1_Jul_Button, _num2_Aug_Button, _num3_Sep_Button,
			_num4_Apr_Button, _num5_May_Button, _num6_Jun_Button,
			_num7_Jan_Button, _num8_Feb_Button, _num9_Mar_Button
	];

	[order enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL *stop) {
		[button setTitle:[NSString stringWithFormat:@"%ld", (long) idx] forState:UIControlStateNormal];
		button.titleLabel.font = [UIFont systemFontOfSize:IS_IPHONE ? 26 : IS_LANDSCAPE ? 27 : 22];
	}];

	[_today_Oct_Button setTitle:NSLocalizedString(@"Today", @"Today") forState:UIControlStateNormal];
	_today_Oct_Button.titleLabel.font = [UIFont systemFontOfSize:IS_IPHONE ? 18 : IS_LANDSCAPE ? 25 : 18];
	[_delete_Dec_Button setImage:[UIImage imageNamed:IS_IPHONE ? @"backspace" : @"backspace_p"] forState:UIControlStateNormal];
	[_delete_Dec_Button setTitle:nil forState:UIControlStateNormal];
}

- (IBAction)switchToYear {
	[[UIDevice currentDevice] playInputClick];

	[self changeInputToYear];
}

- (IBAction)switchToMonth {
	[[UIDevice currentDevice] playInputClick];
	
	_yearButton.selected = NO;
	_monthButton.selected = YES;
	_dayButton.selected = NO;

	[_delete_Dec_Button setImage:nil forState:UIControlStateNormal];

	NSArray *order = [self monthOrder];

	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	NSArray *monthSymbols = dateFormatter.shortMonthSymbols;

	NSString *january = monthSymbols[0];

	BOOL showNumber = [january rangeOfString:@"1"].location == NSNotFound;
	[order enumerateObjectsUsingBlock:^(A3KeyboardButton_iOS7 *button, NSUInteger idx, BOOL *stop) {
		if (showNumber) {
			[button setTitle:@"" forState:UIControlStateNormal];
			button.mainTitle.text = [monthSymbols objectAtIndex:idx];
			button.subTitle.text = [NSString stringWithFormat:@"%ld", (long)idx + 1];
			
			button.mainTitle.font = [UIFont systemFontOfSize:IS_IPHONE ? 18 : 20];
			button.subTitle.font = [UIFont systemFontOfSize:IS_IPHONE ? 16 : IS_LANDSCAPE ? 17 : 15];
			button.subTitle.textColor = [UIColor colorWithRed:123.0/255.0 green:123.0/255.0 blue:123.0/255.0 alpha:1.0];
		} else {
			[button setTitle:monthSymbols[idx] forState:UIControlStateNormal];
			button.titleLabel.font = [UIFont systemFontOfSize:IS_IPHONE ? 18 : 20];
		}
	}];
}

- (IBAction)switchToDay {
	[[UIDevice currentDevice] playInputClick];
	
	_yearButton.selected = NO;
	_monthButton.selected = NO;
	_dayButton.selected = YES;

	[self initExtraLabels];
	[self resetToNumbersButtons];
}

- (void)changeInputToYear {
	[self initExtraLabels];
	[self resetToNumbersButtons];

	_yearButton.selected = YES;
	_monthButton.selected = NO;
	_dayButton.selected = NO;
}

- (NSArray *)monthOrder {
	return @[
			_num7_Jan_Button, _num8_Feb_Button, _num9_Mar_Button,
			_num4_Apr_Button, _num5_May_Button, _num6_Jun_Button,
			_num1_Jul_Button, _num2_Aug_Button, _num3_Sep_Button,
			_today_Oct_Button, _num0_Nov_Button, _delete_Dec_Button];
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

- (NSCalendar *)gregorian {
	if (!_gregorian) {
		_gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	}
	return _gregorian;
}

- (IBAction)numberButtonAction:(UIButton *)button {
	[[UIDevice currentDevice] playInputClick];
	
	if (_monthButton.selected) {
		self.dateComponents.month = [self monthNumberOfButton:button];
	} else if (_yearButton.selected) {
		if (button == _delete_Dec_Button) return;
		if (button == _today_Oct_Button) return;
		NSInteger year = self.dateComponents.year;
		year *= 10;
		if (year >= 10000) year = 0;
		year += [self numberOfButton:button];
		self.dateComponents.year = year;
	} else {
		if (button == _delete_Dec_Button) return;
		if (button == _today_Oct_Button) return;

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
	[[UIDevice currentDevice] playInputClick];

	if ([_delegate respondsToSelector:@selector(dateKeyboardDoneButtonPressed:)]) {
		[_delegate dateKeyboardDoneButtonPressed:self ];
	}
}

- (IBAction)todayButtonAction {
	[[UIDevice currentDevice] playInputClick];

	if (_monthButton.selected) {
		return;
	}
	_dateComponents = nil;

	[self updateResult];
}

- (IBAction)deleteButtonAction {
	if (_yearButton.selected) {
		NSInteger year = self.dateComponents.year;
		year /= 10;
		self.dateComponents.year = year;
	} else {
		NSInteger day = self.dateComponents.day;
		day /= 10;
		self.dateComponents.day = MAX(day, 1);
	}
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
