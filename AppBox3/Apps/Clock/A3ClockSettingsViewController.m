//
//  A3ClockSettingsViewController.m
//  A3TeamWork
//
//  Created by Sanghyun Yu on 2013. 11. 21..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "A3ClockSettingsViewController.h"
#import "NSUserDefaults+A3Defaults.h"
#import "UIViewController+A3Addition.h"
#import "A3ClockDataManager.h"
#import "UIViewController+NumberKeyboard.h"
#import "UIViewController+navigation.h"

typedef NS_ENUM(NSUInteger, A3ClockSettingsTypes) {
	kTagSwitchWithSecond = 1000,
	kTagSwitchFlash = 1001,
	kTagSwitch24Hour = 1002,
	kTagSwitchAMPM = 1003,
	kTagSwitchWeek = 1010,
	kTagSwitchDate = 1011,
	kTagSwitchWeather = 1020
};

NSString *const A3NotificationClockSettingsChanged = @"A3NotificationClockSettingsChanged";

@interface A3ClockSettingsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *sections;
@property (nonatomic, strong) NSArray *timeSection;
@property (nonatomic, strong) NSArray *dateSection;
@property (nonatomic, strong) NSArray *weatherSection;
@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, strong) UITableView *myTableView;

@end

@implementation A3ClockSettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self makeBackButtonEmptyArrow];

	if (IS_IPHONE) {
		[self rightBarButtonDoneButton];
	}
    
    self.title = @"Setting";
    
    _sections = @[@"TIME", @"DATE", @"WEATHER"];
    
    _timeSection = @[@"The time with seconds", @"Flash the time separators", @"Use a 24-hour clock", @"Show AM/PM"];
    _dateSection = @[@"Show the day of the week", @"Show date"];
    _weatherSection = @[@"Show Weather", @""];

	[self.view setBackgroundColor:[UIColor whiteColor]];

	_myTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _myTableView.dataSource = self;
    _myTableView.delegate = self;
	_myTableView.showsVerticalScrollIndicator = NO;
	_myTableView.showsHorizontalScrollIndicator = NO;
	_myTableView.separatorColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0];
	[self.view addSubview:_myTableView];

	[_myTableView makeConstraints:^(MASConstraintMaker *make) {
		make.edges.equalTo(self.view);
	}];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	[[UIApplication sharedApplication] setStatusBarHidden:NO];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)doneButtonAction:(id)button {
	[[UIApplication sharedApplication] setStatusBarHidden:YES];

	if (IS_IPAD) {
		[self.A3RootViewController dismissRightSideViewController];
	} else {
		[self dismissViewControllerAnimated:YES completion:nil];
	}
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _sections.count;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return _sections[section];
}

- (UISegmentedControl *)segmentedControl {
	if (!_segmentedControl) {
		_segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"°F", @"°C"]];
		[_segmentedControl addTarget:self action:@selector(segmentedControlValueChanged:) forControlEvents:UIControlEventValueChanged];
		[_segmentedControl setSelectedSegmentIndex:[[NSUserDefaults standardUserDefaults] clockUsesFahrenheit] ? 0 : 1];
		[_segmentedControl setEnabled:[[NSUserDefaults standardUserDefaults] clockShowWeather]];
	}
	return _segmentedControl;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger nRst = 0;
    
    switch (section) {
        case 0:
            nRst = _timeSection.count;
            break;
        case 1:
            nRst = _dateSection.count;
            break;
        case 2:
            nRst = _weatherSection.count;
            break;
        default:
            break;
    }
    
    return nRst;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = nil;

	if (indexPath.section == 2 && indexPath.row == 1) {
		static NSString *CellWithSegmentedControl = @"A3	ClockSettingsWithSegmentedControl";

		cell = [tableView dequeueReusableCellWithIdentifier:CellWithSegmentedControl];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellWithSegmentedControl];
		}

		[cell addSubview:self.segmentedControl];
		[self setSegmentedControlEnabled:[[NSUserDefaults standardUserDefaults] clockShowWeather]];

		[_segmentedControl removeConstraints:_segmentedControl.constraints];
		[_segmentedControl makeConstraints:^(MASConstraintMaker *make) {
			make.centerX.equalTo(cell.centerX);
			make.centerY.equalTo(cell.centerY);
			make.width.equalTo(@290);
			make.height.equalTo(@29);
		}];
	} else {
		static NSString *CellWithSwitch = @"A3ClockSettingsCellWithSwitch";

		cell = [tableView dequeueReusableCellWithIdentifier:CellWithSwitch];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellWithSwitch];

			UISwitch *switchControl = [[UISwitch alloc] initWithFrame:CGRectZero];
			cell.accessoryView = switchControl;
			[switchControl addTarget:self action:@selector(onSwitchChange:) forControlEvents:UIControlEventValueChanged];
		}

		UISwitch *switchControl = (UISwitch *) cell.accessoryView;

		switchControl.tag = [[NSString stringWithFormat:@"%lu%lu", (unsigned long) indexPath.section, (unsigned long) indexPath.row] integerValue] + 1000;

		NSArray *titlesArray = nil;
		switch (indexPath.section) {
			case 0:
				titlesArray = _timeSection;
				break;
			case 1:
				titlesArray = _dateSection;
				break;
			case 2:
				titlesArray = _weatherSection;
				break;
			default:
				break;
		}

		cell.textLabel.text = titlesArray[indexPath.row];

		switch((A3ClockSettingsTypes)switchControl.tag) {
			case kTagSwitchWithSecond:
				switchControl.on = [[NSUserDefaults standardUserDefaults] clockTheTimeWithSeconds];
				break;
			case kTagSwitchFlash:
				switchControl.on = [[NSUserDefaults standardUserDefaults] clockFlashTheTimeSeparators];
				break;
			case kTagSwitch24Hour:
				switchControl.on = [[NSUserDefaults standardUserDefaults] clockUse24hourClock];
				break;
			case kTagSwitchAMPM:
				[switchControl setEnabled:![[NSUserDefaults standardUserDefaults] clockUse24hourClock]];
				switchControl.on = [[NSUserDefaults standardUserDefaults] clockShowAMPM];
				break;
			case kTagSwitchWeek:
				switchControl.on = [[NSUserDefaults standardUserDefaults] clockShowTheDayOfTheWeek];
				break;
			case kTagSwitchDate:
				switchControl.on = [[NSUserDefaults standardUserDefaults] clockShowDate];
				break;
			case kTagSwitchWeather:
				switchControl.on = [[NSUserDefaults standardUserDefaults] clockShowWeather];
				break;
		}
	}
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	return cell;
}

- (void)segmentedControlValueChanged:(UISegmentedControl *)segmentedControl {
	[[NSUserDefaults standardUserDefaults] setClockUsesFahrenheit:segmentedControl.selectedSegmentIndex == 0];

	[[NSNotificationCenter defaultCenter] postNotificationName:A3NotificationClockSettingsChanged object:nil];
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Switch event

- (void)onSwitchChange:(UISwitch *)switchControl
{
	switch ((A3ClockSettingsTypes)switchControl.tag) {
		case kTagSwitchWithSecond:
			[[NSUserDefaults standardUserDefaults] setClockTheTimeWithSeconds:switchControl.on];
			break;
		case kTagSwitchFlash:
			[[NSUserDefaults standardUserDefaults] setClockFlashTheTimeSeparators:switchControl.on];
			break;
		case kTagSwitch24Hour:{
			[[NSUserDefaults standardUserDefaults] setClockUse24hourClock:switchControl.on];

			UISwitch *AMPMSwitchControl = (UISwitch *) [_myTableView viewWithTag:kTagSwitchAMPM];
			[AMPMSwitchControl setEnabled:!switchControl.on];
			if (switchControl.on) {
				[AMPMSwitchControl setOn:NO];
			} else {
				[AMPMSwitchControl setOn:[[NSUserDefaults standardUserDefaults] clockShowAMPM]];
			}
			break;
		}
		case kTagSwitchAMPM:
			[[NSUserDefaults standardUserDefaults] setClockShowAMPM:switchControl.on];
			break;
		case kTagSwitchWeek:
			[[NSUserDefaults standardUserDefaults] setClockShowTheDayOfTheWeek:switchControl.on];
			[self.clockDataManager enableWeekdayCircle:switchControl.on];
			break;
		case kTagSwitchDate:
			[[NSUserDefaults standardUserDefaults] setClockShowDate:switchControl.on];
			[self.clockDataManager enableDateCircle:switchControl.on];
			break;
		case kTagSwitchWeather:
			if ([switchControl isOn] && (![CLLocationManager locationServicesEnabled] || [CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorized)) {
				[self alertLocationDisabled];
				[switchControl setOn:NO];
			} else {
				[self setWeatherStatus:[switchControl isOn]];
			}
			break;
	}
	double delayInSeconds = 0.1;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		[[NSNotificationCenter defaultCenter] postNotificationName:A3NotificationClockSettingsChanged object:nil];
	});
}

- (void)alertLocationDisabled {
	NSString *message = ![CLLocationManager locationServicesEnabled] ? @"Location Services not enabled. Go to Settings > Privacy > Location Services. Location services must enabled and AppBox Pro authorized to show weather." :
			@"Location services enabled, but AppBox Pro is not authorized to access location services. Go to Settings > Privacy > Location Services and authorize it to show weather.";
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Info" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alertView show];
}

- (void)setWeatherStatus:(BOOL)on {
	[[NSUserDefaults standardUserDefaults] setClockShowWeather:on];
	[self.clockDataManager enableWeatherCircle:on];
	[self setSegmentedControlEnabled:on];
}

- (void)setSegmentedControlEnabled:(BOOL)enabled {
	[self.segmentedControl setTintColor:enabled ? nil : [UIColor colorWithRed:147.0/255.0 green:147.0/255.0 blue:147.0/255.0 alpha:1.0]];
	[self.segmentedControl setEnabled:enabled];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSUInteger)a3SupportedInterfaceOrientations {
	if (IS_IPHONE) return UIInterfaceOrientationMaskPortrait;
	return UIInterfaceOrientationMaskAll;
}


@end
