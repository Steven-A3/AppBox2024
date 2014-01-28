//
//  A3ClockSettingsViewController.m
//  A3TeamWork
//
//  Created by Sanghyun Yu on 2013. 11. 21..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3ClockSettingsViewController.h"
#import "NSUserDefaults+A3Defaults.h"
#import "UIViewController+A3Addition.h"
#import "A3ClockDataManager.h"
#import "UIViewController+A3AppCategory.h"
#import "A3ClockDataManager.h"
#import "A3UserDefaults.h"

typedef NS_ENUM(NSUInteger, A3ClockSettingsTypes) {
	kTagSwitchWithSecond = 1000,
	kTagSwitchFlash = 1001,
	kTagSwitch24Hour = 1002,
	kTagSwitchAMPM = 1003,
	kTagSwitchWeek = 1010,
	kTagSwitchDate = 1011,
	kTagSwitchWeather = 1020
};

@interface A3ClockSettingsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray* arrSection;
@property (nonatomic, strong) NSArray* arrTimeSection;
@property (nonatomic, strong) NSArray* arrDateSection;
@property (nonatomic, strong) NSArray* arrWeatherSection;

@end

@implementation A3ClockSettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self makeBackButtonEmptyArrow];
    [self rightBarButtonDoneButton];
    
    self.title = @"Setting";
    
    _arrSection = @[@"TIME", @"DATE", @"WEATHER"];
    
    _arrTimeSection = @[@"The time with seconds", @"Flash the time separators", @"Use a 24-hour clock", @"Show AM/PM"];
    _arrDateSection = @[@"Show the day of the week", @"Show date"];
    _arrWeatherSection = @[@"Show Weather", @""];

	[self.view setBackgroundColor:[UIColor whiteColor]];

	UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    tableView.dataSource = self;
    tableView.delegate = self;
	[self.view addSubview:tableView];

	[tableView makeConstraints:^(MASConstraintMaker *make) {
		make.edges.equalTo(self.view);
	}];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)doneButtonAction:(id)button {
	@autoreleasepool {
		if (IS_IPAD) {
			[self.A3RootViewController dismissRightSideViewController];
		} else {
			[self dismissViewControllerAnimated:YES completion:nil];
		}
	}
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _arrSection.count;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return _arrSection[section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger nRst = 0;
    
    switch (section) {
        case 0:
            nRst = _arrTimeSection.count;
            break;
        case 1:
            nRst = _arrDateSection.count;
            break;
        case 2:
            nRst = _arrWeatherSection.count;
            break;
        default:
            break;
    }
    
    return nRst;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	@autoreleasepool {
		static NSString *CellWithSwitch = @"A3ClockSettingsCellWithSwitch";
		static NSString *CellWithSegmentedControl = @"A3ClockSettingsWithSegmentedControl";
		UITableViewCell *cell = nil;

        NSArray* arrTitles = nil;
        switch (indexPath.section) {
            case 0:
                arrTitles = _arrTimeSection;
                break;
            case 1:
                arrTitles = _arrDateSection;
                break;
            case 2:
                arrTitles = _arrWeatherSection;
                break;
            default:
                break;
        }
        
        NSString* strCellText = arrTitles[indexPath.row];

		BOOL useSegmentedControl = indexPath.section == 2 && indexPath.row == 1;
		if (useSegmentedControl) {
			cell = [tableView dequeueReusableCellWithIdentifier:CellWithSegmentedControl];
		} else {
			cell = [tableView dequeueReusableCellWithIdentifier:CellWithSwitch];
		}

        if(cell == nil) {
			if (useSegmentedControl) {
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellWithSegmentedControl];

				UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"°F", @"°C"]];
				[segmentedControl addTarget:self action:@selector(segmentedControlValueChanged:) forControlEvents:UIControlEventValueChanged];
				[segmentedControl setSelectedSegmentIndex:[[NSUserDefaults standardUserDefaults] clockUsesFahrenheit] ? 0 : 1];
				[cell addSubview:segmentedControl];
				[segmentedControl makeConstraints:^(MASConstraintMaker *make) {
					make.centerX.equalTo(cell.centerX);
					make.centerY.equalTo(cell.centerY);
					make.width.equalTo(@290);
					make.height.equalTo(@29);
				}];
			} else {
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellWithSwitch];

				UISwitch *switchControl = [[UISwitch alloc] initWithFrame:CGRectZero];
				switchControl.tag = [[NSString stringWithFormat:@"%lu%lu", (unsigned long) indexPath.section, (unsigned long) indexPath.row] integerValue] + 1000;
				cell.accessoryView = switchControl;
				[switchControl addTarget:self action:@selector(onSwitchChange:) forControlEvents:UIControlEventValueChanged];
			}
		}

		UISwitch *switchControl = (UISwitch *) cell.accessoryView;

		NSInteger tag = [[NSString stringWithFormat:@"%lu%lu", (unsigned long)indexPath.section, (unsigned long)indexPath.row] integerValue] + 1000;
		FNLOG(@"Cell.tag = %i, tag = %i", switchControl.tag, tag);
        cell.textLabel.text = strCellText;

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
		return cell;
	}
}

- (void)segmentedControlValueChanged:(UISegmentedControl *)segmentedControl {
	[[NSUserDefaults standardUserDefaults] setClockUsesFahrenheit:segmentedControl.selectedSegmentIndex == 0];
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Switch event

- (void)onSwitchChange:(id)aSender
{
    UISwitch*switchControl = (UISwitch*)aSender;

	switch ((A3ClockSettingsTypes)switchControl.tag) {
		case kTagSwitchWithSecond:
			[[NSUserDefaults standardUserDefaults] setClockTheTimeWithSeconds:switchControl.on];
			break;
		case kTagSwitchFlash:
			[[NSUserDefaults standardUserDefaults] setClockFlashTheTimeSeparators:switchControl.on];
			break;
		case kTagSwitch24Hour:
			[[NSUserDefaults standardUserDefaults] setClockUse24hourClock:switchControl.on];
			break;
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
			[[NSUserDefaults standardUserDefaults] setClockShowWeather:switchControl.on];
			[self.clockDataManager enableWeatherCircle:switchControl.on];
			break;
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSUInteger)a3SupportedInterfaceOrientations {
	return UIInterfaceOrientationMaskAll;
}


@end
