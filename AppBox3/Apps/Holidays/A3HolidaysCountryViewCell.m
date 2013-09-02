//
//  A3HolidaysCountryViewCell.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/30/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3HolidaysCountryViewCell.h"
#import "A3FlickrImageView.h"
#import "A3UIDevice.h"
#import "HolidayData.h"
#import "HolidayData+Country.h"
#import "NSDate+daysleft.h"

@interface A3HolidaysCountryViewCell ()

@property (nonatomic, strong) UILabel *countryName;
@property (nonatomic, strong) UILabel *upcomingHoliday;
@property (nonatomic, strong) UILabel *daysLeft;
@property (nonatomic, strong) UILabel *numberOfHolidays;

@end

@implementation A3HolidaysCountryViewCell {
	NSInteger _thisYear;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
		NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
		NSDateComponents *components = [gregorian components:NSYearCalendarUnit fromDate:[NSDate date]];
		_thisYear = [components year];

		// Initialization code
		_backgroundImageView = [A3FlickrImageView new];
		_backgroundImageView.useForCountryList = YES;
		[self.contentView addSubview:_backgroundImageView];

		[_backgroundImageView makeConstraints:^(MASConstraintMaker *make) {
			make.edges.equalTo(self.contentView);
		}];

		UIView *filter = [UIView new];
		filter.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
		[_backgroundImageView addSubview:filter];
		[filter makeConstraints:^(MASConstraintMaker *make) {
			make.edges.equalTo(_backgroundImageView);
		}];

		_numberOfHolidays = [UILabel new];
		_numberOfHolidays.textColor = [UIColor whiteColor];
		_numberOfHolidays.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:65];
		[self.contentView addSubview:_numberOfHolidays];

		[_numberOfHolidays makeConstraints:^(MASConstraintMaker *make) {
			make.centerY.equalTo(self.contentView.centerY);
			make.right.equalTo(self.contentView.right).with.offset(IS_IPHONE ? -15 : -28);
		}];
		[_numberOfHolidays setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];

		_countryName = [UILabel new];
		_countryName.textColor = [UIColor whiteColor];
		_countryName.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:30];
		[self.contentView addSubview:_countryName];

		[_countryName makeConstraints:^(MASConstraintMaker *make) {
			make.left.equalTo(self.contentView.left).with.offset(IS_IPHONE ? 15 : 28);
			make.right.lessThanOrEqualTo(_numberOfHolidays.left);
			make.centerY.equalTo(self.contentView.centerY).with.offset(-12);
		}];
		[_countryName setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];

		_upcomingHoliday = [UILabel new];
		_upcomingHoliday.textColor = [UIColor whiteColor];
		[self.contentView addSubview:_upcomingHoliday];

		[_upcomingHoliday makeConstraints:^(MASConstraintMaker *make) {
			make.top.equalTo(_countryName.bottom);
			make.left.equalTo(_countryName.left);
		}];

		_daysLeft = [UILabel new];
		_daysLeft.textColor = [UIColor colorWithWhite:1.0 alpha:0.7];
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

	[self setFontsForLabels];
}

- (void)setFontsForLabels {
	_upcomingHoliday.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
	_daysLeft.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
}

- (void)setCountryCode:(NSString *)countryCode {
	_countryCode = [countryCode mutableCopy];
	_countryName.text = [[NSLocale currentLocale] displayNameForKey:NSLocaleCountryCode value:_countryCode];

	HolidayData *holidayData = [HolidayData new];
	NSMutableArray *holidaysThisYear = [holidayData holidaysForCountry:_countryCode year:_thisYear fullSet:NO ];
	NSUInteger upcomingHolidayIndex = [holidaysThisYear indexOfObjectPassingTest:^BOOL(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
		return [[NSDate date] compare:obj[kHolidayDate]] == NSOrderedAscending;
	}];

	NSDictionary *upcomingHoliday = holidaysThisYear[upcomingHolidayIndex];

	_upcomingHoliday.text = upcomingHoliday[kHolidayName];
	_daysLeft.text = [NSString stringWithFormat:@", %@", [upcomingHoliday[kHolidayDate] daysLeft] ];
	_numberOfHolidays.text = [NSString stringWithFormat:@"%d", [holidaysThisYear count]];

	[_backgroundImageView displayImageWithCountryCode:_countryCode];
}

- (void)prepareForMove {
	_backgroundImageView.image = nil;
	_countryName.text = @"";
	_upcomingHoliday.text = @"";
	_daysLeft.text = @"";
	_numberOfHolidays.text = @"";
}


@end
