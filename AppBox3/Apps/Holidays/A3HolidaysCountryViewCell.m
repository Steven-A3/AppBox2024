//
//  A3HolidaysCountryViewCell.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/30/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3HolidaysCountryViewCell.h"
#import "A3UIDevice.h"
#import "HolidayData.h"
#import "HolidayData+Country.h"
#import "NSDate+daysleft.h"
#import "A3HolidaysFlickrDownloadManager.h"
#import "SFKImage.h"
#import "FXLabel.h"

@interface A3HolidaysCountryViewCell ()

@property (nonatomic, strong) UIView *coverOnImageView;
@property (nonatomic, strong) FXLabel *countryName;
@property (nonatomic, strong) FXLabel *upcomingHoliday;
@property (nonatomic, strong) FXLabel *daysLeft;
@property (nonatomic, strong) FXLabel *numberOfHolidays;

@end

@implementation A3HolidaysCountryViewCell {
	NSInteger _thisYear;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
		self.selectionStyle = UITableViewCellSelectionStyleNone;

		NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
		NSDateComponents *components = [gregorian components:NSYearCalendarUnit fromDate:[NSDate date]];
		_thisYear = [components year];

		// Initialization code
		_backgroundImageView = [UIImageView new];
		[self.contentView addSubview:_backgroundImageView];

		[_backgroundImageView makeConstraints:^(MASConstraintMaker *make) {
			make.edges.equalTo(self.contentView);
		}];

		_coverOnImageView = [UIView new];
		_coverOnImageView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
		[_backgroundImageView addSubview:_coverOnImageView];
		[_coverOnImageView makeConstraints:^(MASConstraintMaker *make) {
			make.edges.equalTo(_backgroundImageView);
		}];

		_numberOfHolidays = [FXLabel new];
		_numberOfHolidays.textColor = [UIColor whiteColor];
		_numberOfHolidays.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:65];
		[self setupShadow:_numberOfHolidays];
		[self.contentView addSubview:_numberOfHolidays];

		[_numberOfHolidays makeConstraints:^(MASConstraintMaker *make) {
			make.centerY.equalTo(self.contentView.centerY);
			make.right.equalTo(self.contentView.right).with.offset(IS_IPHONE ? -15 : -28);
		}];
		[_numberOfHolidays setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];

		_countryName = [FXLabel new];
		_countryName.textColor = [UIColor whiteColor];
		_countryName.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:30];
		_countryName.adjustsFontSizeToFitWidth = YES;
		_countryName.minimumScaleFactor = 0.5;
		[self setupShadow:_countryName];
		[self.contentView addSubview:_countryName];

		[_countryName makeConstraints:^(MASConstraintMaker *make) {
			make.left.equalTo(self.contentView.left).with.offset(IS_IPHONE ? 15 : 28);
			make.right.lessThanOrEqualTo(_numberOfHolidays.left);
			make.centerY.equalTo(self.contentView.centerY).with.offset(-12);
		}];
		[_countryName setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];

		_upcomingHoliday = [FXLabel new];
		_upcomingHoliday.textColor = [UIColor whiteColor];
		[self setupShadow:_upcomingHoliday];
		[self.contentView addSubview:_upcomingHoliday];

		[_upcomingHoliday makeConstraints:^(MASConstraintMaker *make) {
			make.top.equalTo(_countryName.bottom);
			make.left.equalTo(_countryName.left);
		}];

		_daysLeft = [FXLabel new];
		_daysLeft.textColor = [UIColor colorWithWhite:1.0 alpha:0.7];
		[self setupShadow:_daysLeft];
		[self.contentView addSubview:_daysLeft];

		[_daysLeft makeConstraints:^(MASConstraintMaker *make) {
			make.left.equalTo(_upcomingHoliday.right).with.offset(1);
			make.right.lessThanOrEqualTo(_numberOfHolidays.left);
			make.baseline.equalTo(_upcomingHoliday);
		}];
		[_daysLeft setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];

		[self setFontsForLabels];
		[self layoutIfNeeded];
	}
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse {
	[super prepareForReuse];

	_coverOnImageView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
	[self setFontsForLabels];
}

- (void)setFontsForLabels {
	_upcomingHoliday.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
	_daysLeft.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
}

- (void)setCountryCode:(NSString *)countryCode {
	_countryCode = [countryCode mutableCopy];
	_countryName.text = [[NSLocale currentLocale] displayNameForKey:NSLocaleCountryCode value:_countryCode];

	HolidayData *holidayData = [HolidayData new];

	NSArray *holidays = [holidayData holidaysForCountry:_countryCode year:_thisYear fullSet:NO];
	NSDictionary *upcomingHoliday = [holidayData firstUpcomingHolidaysForCountry:_countryCode];

	if (upcomingHoliday) {
		_upcomingHoliday.text = upcomingHoliday[kHolidayName];
		_daysLeft.text = [NSString stringWithFormat:@", %@", [upcomingHoliday[kHolidayDate] daysLeft] ];
		_numberOfHolidays.text = [NSString stringWithFormat:@"%lu", (unsigned long)[holidays count]];
	}

	_backgroundImageView.image = [[A3HolidaysFlickrDownloadManager sharedInstance] imageForCountryCode:_countryCode orientation:CURRENT_ORIENTATION forList:YES];
}

- (void)prepareForMove {
	_backgroundImageView.image = nil;
	_coverOnImageView.backgroundColor = [UIColor whiteColor];
	_countryName.text = @"";
	_upcomingHoliday.text = @"";
	_daysLeft.text = @"";
	_numberOfHolidays.text = @"";
	[_locationImageView removeFromSuperview];
	_locationImageView = nil;
}

- (void)setupShadow:(FXLabel *)label {
	label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.35];
	label.shadowOffset = CGSizeMake(0, 1);
	label.shadowBlur = 2;
}

- (UIImageView *)locationImageView {
	if (!_locationImageView) {
		_locationImageView = [UIImageView new];
		[SFKImage setDefaultFont:[UIFont fontWithName:@"appbox" size:12]];
		[SFKImage setDefaultColor:[UIColor whiteColor]];
		_locationImageView.image = [SFKImage imageNamed:@"k"];
		[self.contentView addSubview:_locationImageView];

		[_locationImageView makeConstraints:^(MASConstraintMaker *make) {
			make.baseline.equalTo(_countryName.baseline);
			make.left.equalTo(_countryName.right).with.offset(8);
		}];
	}
	return _locationImageView;
}

@end
