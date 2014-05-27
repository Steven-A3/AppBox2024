//
//  A3DataMigrationManager.m
//  AppBox3
//
//  Created by A3 on 5/26/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "A3DataMigrationManager.h"
#import "NSString+conversion.h"
#import "DaysCounterEvent.h"
#import "DaysCounterDate.h"
#import "A3DaysCounterDefine.h"

NSString *const kKeyForDDayTitle 					= @"kKeyForDDayTitle";
NSString *const kKeyForDDayDate						= @"kKeyForDDayDate";
NSString *const kKeyForDDayEnds						= @"kKeyForDDayEnds";
NSString *const kKeyForDDayType						= @"kKeyForDDayType";
NSString *const kKeyForDDayRepeat					= @"kKeyForDDayRepeat";
NSString *const kKeyForDDayBadgeType				= @"kKeyForDDayBadgeType";						// For Badge
NSString *const kKeyForDDayBadgeTerm				= @"kKeyForDDayBadgeTerm";
NSString *const kKeyForDDayNotificationMinutes      = @"kKeyForDDayNotificationMinutesBefore";
// Integer,
// -2 : Custom
// -1 : Don't make a notification (or missing)
//  0 : Use "kKeyForDDayNotificationTime" to make notification
// >0 : Use "kKeyForDDayNotificationTime" to make notification and this value contains minutes from eventStart when eventDateType == 1
NSString *const kKeyForDDayNotificationTime			= @"kKeyForDDayNotificationTime";
NSString *const kKeyForDDayImageFilename			= @"kKeyForDDayImageFilename";
NSString *const kKeyForDDayMemo						= @"kKeyForDDayMemo";
NSString *const kKeyForDDayShowCountdown			= @"kKeyForDDayShowCountdown";

@implementation A3DataMigrationManager

#pragma mark - Days Until

- (NSString *)daysUntilV1DataFilePath {
	return [@"DDayData.db" pathInLibraryDirectory];
}

- (void)migrateDaysCounter {
	NSString *v1DataFilePath = [self daysUntilV1DataFilePath];
	NSArray *V1DataArray = [[NSArray alloc] initWithContentsOfFile:v1DataFilePath];
	if (![V1DataArray count]) {
		FNLOG(@"DaysUntil does not have V1 data.");
		return;
	}

	for (NSDictionary *v1Item in V1DataArray) {
		DaysCounterEvent *newEvent = [DaysCounterEvent MR_createEntity];
		newEvent.eventName = v1Item[kKeyForDDayTitle];
		newEvent.startDate = [DaysCounterDate MR_createEntity];
		newEvent.startDate.solarDate = v1Item[kKeyForDDayDate];
		NSDate *endDate = v1Item[kKeyForDDayEnds];
		if (endDate) {
			newEvent.endDate = [DaysCounterDate MR_createEntity];
			newEvent.endDate.solarDate = endDate;
		}
		newEvent.isAllDay = @([v1Item[kKeyForDDayType] integerValue] == 1);
		newEvent.repeatType = @([self repeatTypeForV1RepeatType:v1Item[kKeyForDDayRepeat]]);
		NSString *filename = v1Item[kKeyForDDayImageFilename];
		if ([filename length]) {
			newEvent.photo = [UIImage imageWithContentsOfFile:[filename pathInLibraryDirectory]];
		}
		newEvent.notes = v1Item[kKeyForDDayMemo];
	}
}

- (A3DaysCounterRepeatType)repeatTypeForV1RepeatType:(NSNumber *)v1RepeatType {
	switch([v1RepeatType integerValue]) {
		case 1:
			return RepeatType_EveryDay;
		case 2:
			return RepeatType_EveryWeek;
		case 3:
			return RepeatType_Every2Week;
		case 4:
			return RepeatType_EveryMonth;
		case 5:
			return RepeatType_EveryYear;
		default:
			return RepeatType_Never;
	}
}

@end
