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
#import "UIViewController+A3AppCategory.h"

#define kTagSwitchWithSecond   1000
#define kTagSwitchFlash         1001
#define kTagSwitch24Hour        1002
#define kTagSwitchAMPM          1003

#define kTagSwitchWeek          1010
#define kTagSwitchDate          1011

#define kTagSwitchWeather        1020

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
    static NSString *CellIdentifier = @"A3ClockSettingTableViewCell";
	UITableViewCell *cell=nil;
    
	@autoreleasepool {
        
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

        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if(cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
            
            if(indexPath.section == 0 || indexPath.section == 1 || (indexPath.section == 2 && indexPath.row == 0))
            {
                UISwitch *switchControl = [[UISwitch alloc] initWithFrame:CGRectZero];
                switchControl.tag = [[NSString stringWithFormat:@"%lu%lu", (unsigned long)indexPath.section, (unsigned long)indexPath.row] integerValue] + 1000;
                cell.accessoryView = switchControl;
                [switchControl addTarget:self action:@selector(onSwitchChange:) forControlEvents:UIControlEventTouchUpInside];
            }
        }
        
        cell.textLabel.text = strCellText;
        
        UISwitch*switchControl = (UISwitch*)cell.accessoryView;
        if(switchControl.tag == kTagSwitchWithSecond)
            switchControl.on = [[NSUserDefaults standardUserDefaults] clockTheTimeWithSeconds];
        
        if(switchControl.tag == kTagSwitchFlash)
            switchControl.on = [[NSUserDefaults standardUserDefaults] clockFlashTheTimeSeparators];
        
        if(switchControl.tag == kTagSwitch24Hour)
            switchControl.on = [[NSUserDefaults standardUserDefaults] clockUse24hourClock];
        
        if(switchControl.tag == kTagSwitchAMPM)
            switchControl.on = [[NSUserDefaults standardUserDefaults] clockShowAMPM];
        
        if(switchControl.tag == kTagSwitchWeek)
            switchControl.on = [[NSUserDefaults standardUserDefaults] clockShowTheDayOfTheWeek];
        
        if(switchControl.tag == kTagSwitchDate)
            switchControl.on = [[NSUserDefaults standardUserDefaults] clockShowDate];
        
        if(switchControl.tag == kTagSwitchWeather)
            switchControl.on = [[NSUserDefaults standardUserDefaults] clockShowWeather];
        
	}
    
    return cell;
}



#pragma mark - tableview delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - switch event
- (void)onSwitchChange:(id)aSender
{
    UISwitch*switchControl = (UISwitch*)aSender;
    
    if(switchControl.tag == kTagSwitchWithSecond)
        [[NSUserDefaults standardUserDefaults] setClockTheTimeWithSeconds:switchControl.on];
    else if(switchControl.tag == kTagSwitchFlash)
        [[NSUserDefaults standardUserDefaults] setClockFlashTheTimeSeparators:switchControl.on];
    else if(switchControl.tag == kTagSwitch24Hour)
        [[NSUserDefaults standardUserDefaults] setClockUse24hourClock:switchControl.on];
    else if(switchControl.tag == kTagSwitchAMPM)
        [[NSUserDefaults standardUserDefaults] setClockShowAMPM:switchControl.on];
    else if(switchControl.tag == kTagSwitchWeek)
        [[NSUserDefaults standardUserDefaults] setClockShowTheDayOfTheWeek:switchControl.on];
    else if(switchControl.tag == kTagSwitchDate)
        [[NSUserDefaults standardUserDefaults] setClockShowDate:switchControl.on];
    else if(switchControl.tag == kTagSwitchWeather)
        [[NSUserDefaults standardUserDefaults] setClockShowWeather:switchControl.on];
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
