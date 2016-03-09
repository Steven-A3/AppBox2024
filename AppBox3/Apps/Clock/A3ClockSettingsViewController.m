//
//  A3ClockSettingsViewController.m
//  A3TeamWork
//
//  Created by Sanghyun Yu on 2013. 11. 21..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "A3ClockSettingsViewController.h"
#import "A3UserDefaults+A3Defaults.h"
#import "UIViewController+A3Addition.h"
#import "A3ClockDataManager.h"
#import "UIViewController+NumberKeyboard.h"
#import "A3ClockAutoDimViewController.h"

typedef NS_ENUM(NSUInteger, A3ClockSettingsTypes) {
	kTagSwitchWithSecond = 1000,
	kTagSwitchFlash = 1001,
	kTagSwitch24Hour = 1002,
	kTagSwitchAMPM = 1003,
	kTagSwitchWeek = 1010,
	kTagSwitchDate = 1011,
	kTagSwitchWeather = 1020,
    kTagSwitchUseAutoLock = 1030
};

NSString *const A3NotificationClockSettingsChanged = @"A3NotificationClockSettingsChanged";

@interface A3ClockSettingsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *sections;
@property (nonatomic, strong) NSArray *timeSection;
@property (nonatomic, strong) NSArray *dateSection;
@property (nonatomic, strong) NSArray *weatherSection;
@property (nonatomic, strong) NSArray *displaySection;
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
    
    self.title = NSLocalizedString(A3AppName_Settings, nil);
    
    _sections = @[
			NSLocalizedString(@"TIME", @"TIME"),
			NSLocalizedString(@"DATE", @"DATE"),
			NSLocalizedString(@"WEATHER", @"WEATHER"),
			NSLocalizedString(@"Display", @"Display")
	];
    
    _timeSection = @[
			NSLocalizedString(@"The time with seconds", @"The time with seconds"),
			NSLocalizedString(@"Flash the time separators", @"Flash the time separators"),
			NSLocalizedString(@"Use a 24-hour clock", @"Use a 24-hour clock"),
			NSLocalizedString(@"Show AM/PM", @"Show AM/PM")
	];
    _dateSection = @[
			NSLocalizedString(@"Show the day of the week", @"Show the day of the week"),
			NSLocalizedString(@"Show date", @"Show date")
	];
    _weatherSection = @[
			NSLocalizedString(@"Show Weather", @"Show Weather"),
			@""
	];
    _displaySection = @[
			NSLocalizedString(@"Use Auto-Lock", nil),
            NSLocalizedString(@"Auto Dim", @"Auto Dim")
	];

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

    [self.myTableView reloadData];
}

- (void)doneButtonAction:(id)button {
	[[UIApplication sharedApplication] setStatusBarHidden:YES];

	if (IS_IPAD) {
		[[[A3AppDelegate instance] rootViewController_iPad] dismissRightSideViewController];
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
		[_segmentedControl setSelectedSegmentIndex:[[A3UserDefaults standardUserDefaults] clockUsesFahrenheit] ? 0 : 1];
		[_segmentedControl setEnabled:[[A3UserDefaults standardUserDefaults] clockShowWeather]];
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
        case 3:
            nRst = _displaySection.count;
            break;
        default:
            break;
    }
    
    return nRst;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = nil;

    if (indexPath.section == 3 && indexPath.row == 1) {
        static NSString *normalCell = @"normalCell";
        cell = [tableView dequeueReusableCellWithIdentifier:normalCell];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:normalCell];
        }
        cell.textLabel.text = _displaySection[1];
        cell.detailTextLabel.text = [_clockDataManager autoDimString];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    } else if (indexPath.section == 2 && indexPath.row == 1) {
		static NSString *CellWithSegmentedControl = @"A3ClockSettingsWithSegmentedControl";

		cell = [tableView dequeueReusableCellWithIdentifier:CellWithSegmentedControl];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellWithSegmentedControl];
		}

		[cell addSubview:self.segmentedControl];
		[self setSegmentedControlEnabled:[[A3UserDefaults standardUserDefaults] clockShowWeather]];

		[_segmentedControl removeConstraints:_segmentedControl.constraints];
		[_segmentedControl makeConstraints:^(MASConstraintMaker *make) {
			make.centerX.equalTo(cell.centerX);
			make.centerY.equalTo(cell.centerY);
			make.width.equalTo(@290);
			make.height.equalTo(@29);
		}];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
            case 3:
                titlesArray = _displaySection;
                break;
			default:
				break;
		}

		cell.textLabel.text = titlesArray[indexPath.row];

		switch((A3ClockSettingsTypes)switchControl.tag) {
			case kTagSwitchWithSecond:
				switchControl.on = [[A3UserDefaults standardUserDefaults] clockTheTimeWithSeconds];
				break;
			case kTagSwitchFlash:
				switchControl.on = [[A3UserDefaults standardUserDefaults] clockFlashTheTimeSeparators];
				break;
			case kTagSwitch24Hour:
				switchControl.on = [[A3UserDefaults standardUserDefaults] clockUse24hourClock];
				break;
			case kTagSwitchAMPM:
				[switchControl setEnabled:![[A3UserDefaults standardUserDefaults] clockUse24hourClock]];
				switchControl.on = [[A3UserDefaults standardUserDefaults] clockShowAMPM];
				break;
			case kTagSwitchWeek:
				switchControl.on = [[A3UserDefaults standardUserDefaults] clockShowTheDayOfTheWeek];
				break;
			case kTagSwitchDate:
				switchControl.on = [[A3UserDefaults standardUserDefaults] clockShowDate];
				break;
			case kTagSwitchWeather:
				switchControl.on = [[A3UserDefaults standardUserDefaults] clockShowWeather];
				break;
            case kTagSwitchUseAutoLock:
                switchControl.on = [[A3UserDefaults standardUserDefaults] clockUseAutoLock];
                break;
		}
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	return cell;
}

- (void)segmentedControlValueChanged:(UISegmentedControl *)segmentedControl {
	[[A3UserDefaults standardUserDefaults] setClockUsesFahrenheit:segmentedControl.selectedSegmentIndex == 0];

	[[NSNotificationCenter defaultCenter] postNotificationName:A3NotificationClockSettingsChanged object:nil];
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 3 && indexPath.row == 1) {
        A3ClockAutoDimViewController *viewController = [[A3ClockAutoDimViewController alloc] init];
        viewController.dataManager = _clockDataManager;

        [self.navigationController pushViewController:viewController animated:YES];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Switch event

- (void)onSwitchChange:(UISwitch *)switchControl
{
	switch ((A3ClockSettingsTypes)switchControl.tag) {
		case kTagSwitchWithSecond:
			[[A3UserDefaults standardUserDefaults] setClockTheTimeWithSeconds:switchControl.on];
			break;
		case kTagSwitchFlash:
			[[A3UserDefaults standardUserDefaults] setClockFlashTheTimeSeparators:switchControl.on];
			break;
		case kTagSwitch24Hour:{
			[[A3UserDefaults standardUserDefaults] setClockUse24hourClock:switchControl.on];

			UISwitch *AMPMSwitchControl = (UISwitch *) [_myTableView viewWithTag:kTagSwitchAMPM];
			[AMPMSwitchControl setEnabled:!switchControl.on];
			if (switchControl.on) {
				[AMPMSwitchControl setOn:NO];
			} else {
				[AMPMSwitchControl setOn:[[A3UserDefaults standardUserDefaults] clockShowAMPM]];
			}
			break;
		}
		case kTagSwitchAMPM:
			[[A3UserDefaults standardUserDefaults] setClockShowAMPM:switchControl.on];
			break;
		case kTagSwitchWeek:
			[[A3UserDefaults standardUserDefaults] setClockShowTheDayOfTheWeek:switchControl.on];
			[self.clockDataManager enableWeekdayCircle:switchControl.on];
			break;
		case kTagSwitchDate:
			[[A3UserDefaults standardUserDefaults] setClockShowDate:switchControl.on];
			[self.clockDataManager enableDateCircle:switchControl.on];
			break;
		case kTagSwitchWeather:
			FNLOG(@"locationServicesEnabled : %@", @([CLLocationManager locationServicesEnabled]));
			FNLOG(@"authorizationStatus %@", @([CLLocationManager authorizationStatus]));
			if ([switchControl isOn] && (![CLLocationManager locationServicesEnabled] || [CLLocationManager authorizationStatus] <= kCLAuthorizationStatusDenied)) {
				[self alertLocationDisabled];
				[switchControl setOn:NO];
			} else {
				[self setWeatherStatus:[switchControl isOn]];
			}
			break;
        case kTagSwitchUseAutoLock:
            [[A3UserDefaults standardUserDefaults] setBool:switchControl.isOn forKey:A3ClockUseAutoLock];
            [[A3UserDefaults standardUserDefaults] synchronize];
            break;
	}
	double delayInSeconds = 0.1;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		[[NSNotificationCenter defaultCenter] postNotificationName:A3NotificationClockSettingsChanged object:nil];
	});
}

- (void)setWeatherStatus:(BOOL)on {
	[[A3UserDefaults standardUserDefaults] setClockShowWeather:on];
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
