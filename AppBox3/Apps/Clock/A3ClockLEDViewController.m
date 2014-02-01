//
//  A3ClockLEDViewController.m
//  A3TeamWork
//
//  Created by Sanghyun Yu on 2013. 11. 20..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3ClockInfo.h"
#import "A3ClockDataManager.h"
#import "A3ClockLEDViewController.h"
#import "NSUserDefaults+A3Defaults.h"
#import "A3ClockLEDBGLayer.h"

@interface A3ClockLEDViewController ()

@property (nonatomic, strong) UILabel *lbAMPM;
@property (nonatomic, strong) UILabel *lbTemperatureWeather;
@property (nonatomic, strong) UILabel *lbWeekDayMonth;
@property (nonatomic, strong) UILabel* lb0;
@property (nonatomic, strong) UIView* viewPanel;
@property (nonatomic, strong) UILabel* lbHour1;
@property (nonatomic, strong) UILabel* lbHour2;
@property (nonatomic, strong) UILabel* lbMinute1;
@property (nonatomic, strong) UILabel* lbMinute2;
@property (nonatomic, strong) UILabel* lbSecond1;
@property (nonatomic, strong) UILabel* lbSecond2;
@property (nonatomic, strong) UILabel* lbColon1;
@property (nonatomic, strong) UILabel* lbColon2;

@end

@implementation A3ClockLEDViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	self.lb0 = [[UILabel alloc] initWithFrame:self.view.bounds];
	[self.lb0 setTextAlignment:NSTextAlignmentCenter];
	[self.lb0 setFont:[UIFont fontWithName:kClockFontNameDigit size:[self fontSizeTime]]];
	[self.lb0 setTextColor:[UIColor whiteColor]];
	[self.lb0 setAlpha:0.05f];
	[self.lb0 setText:@"00 00 00"];
	[self.view addSubview:self.lb0];

	self.viewPanel = [[UIView alloc] initWithFrame:CGRectMake(0, 0,
			[self.lb0.text sizeWithAttributes:@{NSFontAttributeName:[self.lb0 font]}].width,
			self.view.bounds.size.height)];


//        self.viewPanel = [[UIView alloc] init];
	[self.view addSubview:self.viewPanel];
//        self.viewPanel.backgroundColor = [UIColor greenColor];
//        [self.viewPanel makeConstraints:^(MASConstraintMaker *make) {
//            make.centerY.equalTo(self.centerY).with.offset(0);
//            make.centerX.equalTo(self.centerX).with.offset(0);
//            make.width.equalTo(self.width).with.offset(0);
//        }];


	_lbAMPM = [[UILabel alloc] init];
	_lbAMPM.textAlignment = NSTextAlignmentLeft;
	[_lbAMPM setFont:[UIFont fontWithName:kClockFontNameDigit size:12]];
	[_lbAMPM setTextColor:[UIColor whiteColor]];
	[self.viewPanel addSubview:_lbAMPM];

	_lbTemperatureWeather = [[UILabel alloc] init];
	_lbTemperatureWeather.textAlignment = NSTextAlignmentLeft;
	[_lbTemperatureWeather setFont:[UIFont fontWithName:kClockFontNameDigit size:12]];
	[_lbTemperatureWeather setTextColor:[UIColor whiteColor]];
	[self.viewPanel addSubview:_lbTemperatureWeather];

	_lbWeekDayMonth = [[UILabel alloc] init];
	_lbWeekDayMonth.textAlignment = NSTextAlignmentLeft;
	[_lbWeekDayMonth setFont:[UIFont fontWithName:kClockFontNameDigit size:12]];
	[_lbWeekDayMonth setTextColor:[UIColor whiteColor]];
	[self.viewPanel addSubview:_lbWeekDayMonth];


	float fWidthCharacter = [@"0" sizeWithAttributes:@{NSFontAttributeName:[self.lb0 font]}].width;
	float fWidthSpace = [@" " sizeWithAttributes:@{NSFontAttributeName:[self.lb0 font]}].width;


	self.lbHour1 = [[UILabel alloc] initWithFrame:self.view.bounds];
	[self.lbHour1 setFrame:CGRectMake(self.lbHour1.frame.origin.x, self.lbHour1.frame.origin.y, fWidthCharacter, self.lbHour1.frame.size.height)];
	[self.lbHour1 setTextAlignment:NSTextAlignmentRight];
	[self.lbHour1 setFont:[UIFont fontWithName:kClockFontNameDigit size:[self fontSizeTime]]];
	[self.lbHour1 setTextColor:[UIColor whiteColor]];
	[self.lbHour1 setText:@"0"];
	[self.viewPanel addSubview:self.lbHour1];

	self.lbHour2 = [[UILabel alloc] initWithFrame:self.view.bounds];
	[self.lbHour2 setFrame:CGRectMake(self.lbHour1.frame.origin.x + fWidthCharacter, self.lbHour2.frame.origin.y, fWidthCharacter, self.lbHour2.frame.size.height)];
	[self.lbHour2 setTextAlignment:NSTextAlignmentRight];
	[self.lbHour2 setFont:[UIFont fontWithName:kClockFontNameDigit size:[self fontSizeTime]]];
	[self.lbHour2 setTextColor:[UIColor whiteColor]];
	[self.lbHour2 setText:@"1"];
	[self.viewPanel addSubview:self.lbHour2];

	self.lbColon1 = [[UILabel alloc] initWithFrame:self.view.bounds];
	[self.lbColon1 setCenter:CGPointMake(self.lbHour2.frame.origin.x + fWidthCharacter + (fWidthSpace*0.5f), self.lbColon1.center.y - 6)];
	[self.lbColon1 setTextAlignment:NSTextAlignmentCenter];
	[self.lbColon1 setFont:[UIFont fontWithName:kClockFontNameRegular size:[self fontSizeColon]]];
	[self.lbColon1 setTextColor:[UIColor whiteColor]];
	[self.lbColon1 setAlpha:0.5f];
	[self.lbColon1 setText:@":"];
	[self.viewPanel addSubview:self.lbColon1];

	self.lbMinute1 = [[UILabel alloc] initWithFrame:self.view.bounds];
	[self.lbMinute1 setFrame:CGRectMake(self.lbHour2.frame.origin.x + fWidthCharacter + fWidthSpace, self.lbMinute1.frame.origin.y, fWidthCharacter, self.lbMinute1.frame.size.height)];
	[self.lbMinute1 setTextAlignment:NSTextAlignmentRight];
	[self.lbMinute1 setFont:[UIFont fontWithName:kClockFontNameDigit size:[self fontSizeTime]]];
	[self.lbMinute1 setTextColor:[UIColor whiteColor]];
	[self.lbMinute1 setText:@"0"];
	[self.viewPanel addSubview:self.lbMinute1];

	self.lbMinute2 = [[UILabel alloc] initWithFrame:self.view.bounds];
	[self.lbMinute2 setFrame:CGRectMake(self.lbMinute1.frame.origin.x + fWidthCharacter, self.lbMinute2.frame.origin.y, fWidthCharacter, self.lbMinute2.frame.size.height)];
	[self.lbMinute2 setTextAlignment:NSTextAlignmentRight];
	[self.lbMinute2 setFont:[UIFont fontWithName:kClockFontNameDigit size:[self fontSizeTime]]];
	[self.lbMinute2 setTextColor:[UIColor whiteColor]];
	[self.lbMinute2 setText:@"1"];
	[self.viewPanel addSubview:self.lbMinute2];

	self.lbColon2 = [[UILabel alloc] initWithFrame:self.view.bounds];
	[self.lbColon2 setCenter:CGPointMake(self.lbMinute2.frame.origin.x + fWidthCharacter + (fWidthSpace*0.5f), self.lbColon2.center.y - 6)];
	[self.lbColon2 setTextAlignment:NSTextAlignmentCenter];
	[self.lbColon2 setFont:[UIFont fontWithName:kClockFontNameRegular size:[self fontSizeColon]]];
	[self.lbColon2 setTextColor:[UIColor whiteColor]];
	[self.lbColon2 setAlpha:0.5f];
	[self.lbColon2 setText:@":"];
	[self.viewPanel addSubview:self.lbColon2];

	self.lbSecond1 = [[UILabel alloc] initWithFrame:self.view.bounds];
	[self.lbSecond1 setFrame:CGRectMake(self.lbMinute2.frame.origin.x + fWidthCharacter + fWidthSpace, self.lbSecond1.frame.origin.y, fWidthCharacter, self.lbSecond1.frame.size.height)];
	[self.lbSecond1 setTextAlignment:NSTextAlignmentRight];
	[self.lbSecond1 setFont:[UIFont fontWithName:kClockFontNameDigit size:[self fontSizeTime]]];
	[self.lbSecond1 setTextColor:[UIColor whiteColor]];
	[self.lbSecond1 setText:@"0"];
	[self.viewPanel addSubview:self.lbSecond1];

	self.lbSecond2 = [[UILabel alloc] initWithFrame:self.view.bounds];
	[self.lbSecond2 setFrame:CGRectMake(self.lbSecond1.frame.origin.x + fWidthCharacter, self.lbSecond2.frame.origin.y, fWidthCharacter, self.lbSecond2.frame.size.height)];
	[self.lbSecond2 setTextAlignment:NSTextAlignmentRight];
	[self.lbSecond2 setFont:[UIFont fontWithName:kClockFontNameDigit size:[self fontSizeTime]]];
	[self.lbSecond2 setTextColor:[UIColor whiteColor]];
	[self.lbSecond2 setText:@"1"];
	[self.viewPanel addSubview:self.lbSecond2];



//        CGSize textSize = [@"0" sizeWithAttributes:@{NSFontAttributeName:[self.lbHour1 font]}];
//        CGFloat fWidth1 = textSize.width;
//        textSize = [@"00" sizeWithAttributes:@{NSFontAttributeName:[self.lbHour1 font]}];
//        CGFloat fWidth2 = textSize.width;
//        textSize = [@" " sizeWithAttributes:@{NSFontAttributeName:[self.lbHour1 font]}];
//        CGFloat fWidth3 = textSize.width;
//        textSize = [@"1" sizeWithAttributes:@{NSFontAttributeName:[self.lbHour1 font]}];
//        CGFloat fWidth4 = textSize.width;
//
//
//        NSLog(@"%f,%f,%f,%f", fWidth1, fWidth2, fWidth3, fWidth4);
//        self.lbColon1 = [[UILabel alloc] initWithFrame:self.bounds];
//        [self.lbColon1 setTextAlignment:NSTextAlignmentCenter];
//        [self.lbColon1 setFont:[UIFont fontWithName:kClockFontNameRegular size:70]];
//        [self.lbColon1 setTextColor:[UIColor whiteColor]];
//        [self.lbColon1 setAlpha:0.5f];
//        [self.lbColon1 setText:@":"];
//        [self addSubview:self.lbColon1];// 왼쪽51
//
//        self.lbColon2 = [[UILabel alloc] initWithFrame:self.bounds];
//        [self.lbColon2 setTextAlignment:NSTextAlignmentCenter];
//        [self.lbColon2 setFont:[UIFont fontWithName:kClockFontNameRegular size:70]];
//        [self.lbColon2 setTextColor:[UIColor whiteColor]];
//        [self.lbColon2 setAlpha:0.5f];
//        [self.lbColon2 setText:@":"];
//        [self addSubview:self.lbColon2];// 오른쪽53


//        [UIButton buttonWithType:UIButtonTypeSystem]



	if(IS_IPHONE)
		[self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"LED_bg.png"]]];
	else
		[self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"LED_bg_p.png"]]];

//        [self setupSubviews];

	CAGradientLayer *bgLayer = [A3ClockLEDBGLayer whiteGradient];
	bgLayer.frame = self.view.bounds;
	[self.view.layer insertSublayer:bgLayer atIndex:1];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	[self layoutSubviews];
}

#pragma mark - private

- (float)fontSizeTime
{
    float fRst = 0.f;
    
    if(IS_IPHONE)
    {
        if([[NSUserDefaults standardUserDefaults] clockTheTimeWithSeconds])
            fRst = 74.f;
        else
            fRst = 116.f;
    }
    
    return fRst;
}

- (float)fontSizeColon
{
    float fRst = 0.f;
    
    if(IS_IPHONE)
    {
        if([[NSUserDefaults standardUserDefaults] clockTheTimeWithSeconds])
            fRst = 70.f;
        else
            fRst = 90.f;
    }
    
    return fRst;
}

#pragma mark - public
- (void)layoutSubviews {
    if([[NSUserDefaults standardUserDefaults] clockShowAMPM])
        _lbAMPM.hidden = YES;
    else
        _lbAMPM.hidden = NO;
    
    if([[NSUserDefaults standardUserDefaults] clockShowWeather])
        _lbTemperatureWeather.hidden = YES;
    else
        _lbTemperatureWeather.hidden = NO;

    if(IS_IPHONE)
    {
        if([[NSUserDefaults standardUserDefaults] clockTheTimeWithSeconds])
        {
            self.lbColon2.hidden = NO;
            self.lbSecond2.hidden = NO;
            
            [self.lb0 setText:@"00 00 00"];
            
            [_lbAMPM makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.viewPanel.left).with.offset(0);
                //            make.bottom.equalTo(self.lbHour1.top).with.offset(-16);
                make.top.equalTo(self.view.top).with.offset(230);
            }];
            
            [_lbTemperatureWeather makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self.viewPanel.right).with.offset(0);
                make.top.equalTo(self.view.top).with.offset(230);
            }];
            
            [_lbWeekDayMonth makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self.viewPanel.right).with.offset(0);
                make.top.equalTo(self.view.top).with.offset(322);
            }];
        }
        else
        {
            self.lbColon2.hidden = YES;
            self.lbSecond2.hidden = YES;
            
            [self.lb0 setText:@"00 00"];
            
            [_lbAMPM makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.viewPanel.left).with.offset(8);
                //            make.bottom.equalTo(self.lbHour1.top).with.offset(-16);
                make.top.equalTo(self.view.top).with.offset(230);
            }];
            
            [_lbTemperatureWeather makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self.viewPanel.right).with.offset(-8);
                make.top.equalTo(self.view.top).with.offset(230);
            }];
            
            [_lbWeekDayMonth makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self.viewPanel.right).with.offset(-8);
                make.top.equalTo(self.view.top).with.offset(322);
            }];
        }
        
        [self.lb0 setFont:[UIFont fontWithName:kClockFontNameDigit size:[self fontSizeTime]]];
        [self.lb0 setFrame:self.view.bounds];
            
        [self.viewPanel setFrame:CGRectMake(0, 0,
                                            [self.lb0.text sizeWithAttributes:@{NSFontAttributeName:[self.lb0 font]}].width,
                                            self.view.bounds.size.height)];
        [self.viewPanel setCenter:CGPointMake(self.view.frame.size.width*0.5f, self.view.frame.size.height*0.5f)];
        
        
        float fWidthCharacter = [@"0" sizeWithAttributes:@{NSFontAttributeName:[self.lb0 font]}].width;
        float fWidthSpace = [@" " sizeWithAttributes:@{NSFontAttributeName:[self.lb0 font]}].width;
        
        
        [self.lbHour1 setFrame:CGRectMake(self.lbHour1.frame.origin.x, self.lbHour1.frame.origin.y, fWidthCharacter, self.lbHour1.frame.size.height)];
        [self.lbHour1 setFont:[UIFont fontWithName:kClockFontNameDigit size:[self fontSizeTime]]];

        [self.lbHour2 setFrame:CGRectMake(self.lbHour1.frame.origin.x + fWidthCharacter, self.lbHour2.frame.origin.y, fWidthCharacter, self.lbHour2.frame.size.height)];
        [self.lbHour2 setFont:[UIFont fontWithName:kClockFontNameDigit size:[self fontSizeTime]]];
        
        [self.lbColon1 setCenter:CGPointMake(self.lbHour2.frame.origin.x + fWidthCharacter + (fWidthSpace*0.5f), self.lbHour2.center.y - 6)];
        [self.lbColon1 setFont:[UIFont fontWithName:kClockFontNameRegular size:[self fontSizeColon]]];
        
        [self.lbMinute1 setFrame:CGRectMake(self.lbHour2.frame.origin.x + fWidthCharacter + fWidthSpace, self.lbMinute1.frame.origin.y, fWidthCharacter, self.lbMinute1.frame.size.height)];
        [self.lbMinute1 setFont:[UIFont fontWithName:kClockFontNameDigit size:[self fontSizeTime]]];
        
        [self.lbMinute2 setFrame:CGRectMake(self.lbMinute1.frame.origin.x + fWidthCharacter, self.lbMinute2.frame.origin.y, fWidthCharacter, self.lbMinute2.frame.size.height)];
        [self.lbMinute2 setFont:[UIFont fontWithName:kClockFontNameDigit size:[self fontSizeTime]]];
        
        [self.lbColon2 setCenter:CGPointMake(self.lbMinute2.frame.origin.x + fWidthCharacter + (fWidthSpace*0.5f), self.lbMinute1.center.y - 6)];
        [self.lbColon2 setFont:[UIFont fontWithName:kClockFontNameRegular size:[self fontSizeColon]]];
        
        [self.lbSecond1 setFrame:CGRectMake(self.lbMinute2.frame.origin.x + fWidthCharacter + fWidthSpace, self.lbSecond1.frame.origin.y, fWidthCharacter, self.lbSecond1.frame.size.height)];
        [self.lbSecond1 setFont:[UIFont fontWithName:kClockFontNameDigit size:[self fontSizeTime]]];
        
        [self.lbSecond2 setFrame:CGRectMake(self.lbSecond1.frame.origin.x + fWidthCharacter, self.lbSecond2.frame.origin.y, fWidthCharacter, self.lbSecond2.frame.size.height)];
        [self.lbSecond2 setFont:[UIFont fontWithName:kClockFontNameDigit size:[self fontSizeTime]]];
    }
}

- (void)refreshSecond:(A3ClockInfo *)clockInfo {

}

- (void)refreshWholeClock:(A3ClockInfo *)clockInfo {
	if([clockInfo.hour intValue] < 10)
		self.lbHour1.text = @"";
	else
		self.lbHour1.text = [clockInfo.hour substringToIndex:1];

	self.lbHour2.text = [clockInfo.hour substringFromIndex:1];

	self.lbMinute1.text = [clockInfo.minute substringToIndex:1];
	self.lbMinute2.text = [clockInfo.minute substringFromIndex:1];

	self.lbSecond1.text = [clockInfo.second substringToIndex:1];
	self.lbSecond2.text = [clockInfo.second substringFromIndex:1];

	if([[NSUserDefaults standardUserDefaults] clockShowTheDayOfTheWeek] && [[NSUserDefaults standardUserDefaults] clockShowDate])
	{
		_lbWeekDayMonth.text = [NSString stringWithFormat:@"%@ %@ %@", [clockInfo.shortWeekday uppercaseString], clockInfo.day, [clockInfo.shortMonth uppercaseString]];
	}
	else if([[NSUserDefaults standardUserDefaults] clockShowTheDayOfTheWeek])
	{
		_lbWeekDayMonth.text = [NSString stringWithFormat:@"%@", clockInfo.weekday];
	}
	else if([[NSUserDefaults standardUserDefaults] clockShowDate])
	{
		_lbWeekDayMonth.text = [NSString stringWithFormat:@"%@ %@", clockInfo.month, clockInfo.day];
	}
	else
		_lbWeekDayMonth.text = @"";

	_lbAMPM.text = clockInfo.AMPM;


	[self layoutSubviews];
}


@end
