//
//  A3LadyCalendarModelManager.m
//  A3TeamWork
//
//  Created by coanyaa on 2013. 11. 18..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3LadyCalendarModelManager.h"
#import "A3LadyCalendarDefine.h"
#import "LadyCalendarAccount.h"
#import "LadyCalendarPeriod.h"
#import "A3DateHelper.h"
#import "A3UserDefaults.h"
#import "A3AppDelegate.h"
#import "NSDate+calculation.h"
#import "NSDateFormatter+A3Addition.h"
#import "NSDate-Utilities.h"

// UserInfo have "changedMonth".
NSString *const A3NotificationLadyCalendarPeriodDataChanged = @"A3NotificationLadyCalendarPeriodDataChanged";
NSString *const A3LadyCalendarChangedDateKey = @"A3LadyCalendarChangedDateKey";

@interface A3LadyCalendarModelManager ()

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation A3LadyCalendarModelManager

+ (void)alertMessage:(NSString*)message title:(NSString*)title
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
														message:message
													   delegate:nil
											  cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
											  otherButtonTitles:nil];
    [alertView show];
}

- (NSString *)defaultAccountName {
	return [NSString stringWithFormat:@"%@01", NSLocalizedString(@"User", nil)];
}

- (void)addDefaultAccountInContext:(NSManagedObjectContext *)context {
    [self addAccount:@{AccountItem_ID : DefaultAccountID, AccountItem_Name : [self defaultAccountName]} inContext:context ];
}

- (NSDateFormatter *)dateFormatter {
	if (!_dateFormatter) {
		_dateFormatter = [NSDateFormatter new];
	}
	return _dateFormatter;
}

- (void)prepare
{
	[self prepareAccountInContext:[[MagicalRecordStack defaultStack] context] ];

    // 기본 설정값을 저장한다.
    if( [[NSUserDefaults standardUserDefaults] objectForKey:A3LadyCalendarSetting] == nil ){
        NSMutableDictionary *item = [self createDefaultSetting];
        [[NSUserDefaults standardUserDefaults] setObject:item forKey:A3LadyCalendarSetting];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    // 배란예정일 간격을 저장한다.
    if( [[NSUserDefaults standardUserDefaults] objectForKey:A3LadyCalendarOvulationDays]  == nil ){
        [[NSUserDefaults standardUserDefaults] setInteger:14 forKey:A3LadyCalendarOvulationDays];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    [self savePredictItemBeforeNow];
    
    [self recalculateDates];
}

- (void)prepareAccountInContext:(NSManagedObjectContext *)context {
	// 기본 계정을 한개 추가한다.
	if( [self numberOfAccountInContext:context ] < 1 ){
		[self addDefaultAccountInContext:context ];

		if( [[NSUserDefaults standardUserDefaults] objectForKey:A3LadyCalendarCurrentAccountID] == nil ){
			[[NSUserDefaults standardUserDefaults] setObject:DefaultAccountID forKey:A3LadyCalendarCurrentAccountID];
			[[NSUserDefaults standardUserDefaults] synchronize];
		}
	}
}

- (void)savePredictItemBeforeNow
{
    NSDictionary *setting = [self currentSetting];
	if( ![[setting objectForKey:SettingItem_AutoRecord] boolValue] ) return;

	LadyCalendarAccount *account = [self currentAccount];
	if( !account ) return;

	// Make predict item until today
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"account.uniqueID == %@ && isPredict == %@", account.uniqueID, @NO];
	if (![LadyCalendarPeriod MR_countOfEntitiesWithPredicate:predicate]) return;

	LadyCalendarPeriod *period = [LadyCalendarPeriod MR_findFirstWithPredicate:predicate sortedBy:@"startDate" ascending:NO];
	NSDate *today = [NSDate date];
	if ([today isEarlierThanDate:period.periodEnds]) return;

	NSInteger averageCycleLength = [self cycleLengthConsideringUserOption];
	NSCalendar *calendar = [[A3AppDelegate instance] calendar];
	NSDateComponents *difference = [calendar components:NSDayCalendarUnit fromDate:period.periodEnds toDate:today options:0];
	NSInteger numberOfPredictToMake = difference.day / averageCycleLength + 1;

	if (numberOfPredictToMake) {
		[self updatePredictPeriodsWithCount:numberOfPredictToMake];
	}

	NSArray *predictList = [self predictPeriodListSortedByStartDateIsAscending:YES ];
	for(LadyCalendarPeriod *period in predictList ) {
		if( [period.endDate isEarlierThanDate:today] ){
			period.isPredict = @(NO);
			period.isAutoSave = @(YES);
		}
	}
	[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
}

#pragma mark - account
- (NSInteger)numberOfAccountInContext:(NSManagedObjectContext *)context {
    return [LadyCalendarAccount MR_countOfEntitiesWithContext:context];
}

- (LadyCalendarAccount *)accountForID:(NSString *)accountID inContext:(NSManagedObjectContext *)context {
    return [LadyCalendarAccount MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"uniqueID == %@",accountID] inContext:context];
}

- (BOOL)addAccount:(NSDictionary *)item inContext:(NSManagedObjectContext *)context {
    LadyCalendarAccount *account = [self accountForID:[item objectForKey:AccountItem_ID] inContext:context ];
    if( account )
        return NO;
    
    account = [LadyCalendarAccount MR_createInContext:context];
    account.uniqueID = [item objectForKey:AccountItem_ID];
    account.name = [item objectForKey:AccountItem_Name];
    account.notes = [item objectForKey:AccountItem_Notes];
    account.birthDay = [item objectForKey:AccountItem_Birthday];
    account.order = [NSNumber numberWithInteger:[self numberOfAccountInContext:context ] +1];
    account.updateDate = [NSDate date];
    
    [context MR_saveToPersistentStoreAndWait];
    
    return YES;
}

- (NSArray*)accountListSortedByOrderIsAscending:(BOOL)ascending
{
    return [LadyCalendarAccount MR_findAllSortedBy:@"order" ascending:ascending];
}

- (LadyCalendarAccount*)currentAccount {
	if (!_currentAccount) {
		NSString *accountID = [[NSUserDefaults standardUserDefaults] objectForKey:A3LadyCalendarCurrentAccountID];
		NSAssert(accountID != nil, @"Default account ID must be set in initialization.");
		_currentAccount = [LadyCalendarAccount MR_findFirstByAttribute:@"uniqueID" withValue:accountID];
	}

	return _currentAccount;
}

#pragma mark - period

- (NSInteger)numberOfPeriodsWithAccountID:(NSString*)accountID
{
    return [LadyCalendarPeriod MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"account.uniqueID == %@",accountID]];
}

- (NSArray *)periodListSortedByStartDateIsAscending:(BOOL)ascending {
    return [LadyCalendarPeriod MR_findAllSortedBy:@"startDate" ascending:ascending withPredicate:[NSPredicate predicateWithFormat:@"account.uniqueID == %@ AND isPredict == %@", _currentAccount.uniqueID, @(NO)]];
}

- (NSArray *)predictPeriodListSortedByStartDateIsAscending:(BOOL)ascending {
    return [LadyCalendarPeriod MR_findAllSortedBy:@"startDate" ascending:ascending withPredicate:[NSPredicate predicateWithFormat:@"account.uniqueID == %@ AND isPredict == %@", _currentAccount.uniqueID, @(YES)]];
}

- (NSInteger)calculateAverageCycleFromArray:(NSArray*)array fromIndex:(NSInteger)index
{
    if( [array count] < 1 )
        return 0;
    else if( [array count] == 1 ){
        LadyCalendarPeriod *item = [array objectAtIndex:0];
        return [item.cycleLength integerValue];
    }
    
    if( index < 0 )
        index = 0;
    
    NSInteger count = 0;
    NSInteger daysTotal = 0;
    for(NSInteger i=index; i < [array count]; i++ ){
        LadyCalendarPeriod *item = [array objectAtIndex:i];
        daysTotal += [item.cycleLength integerValue];
        count++;
    }
    
    return (daysTotal / count);
}

- (NSArray *)periodListStartsInMonth:(NSDate *)month {
	NSDate *nextMonth = [month dateByAddingCalendarMonth:1];

	return [LadyCalendarPeriod MR_findAllSortedBy:@"startDate" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"(account.uniqueID == %@) AND ((startDate >= %@) AND (startDate < %@))", _currentAccount.uniqueID, month, nextMonth]];
}

- (NSArray *)periodListInRangeWithMonth:(NSDate*)month accountID:(NSString*)accountID
{
    NSDate *prevMonth = [month dateByAddingCalendarMonth:-1];
	NSDate *nextMonth = [month dateByAddingCalendarMonth:1];

    return [LadyCalendarPeriod MR_findAllSortedBy:@"startDate" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"(account.uniqueID == %@) AND ((startDate >= %@) AND (startDate < %@))", accountID, prevMonth, nextMonth]];
}

- (NSArray*)periodListWithMonth:(NSDate*)month accountID:(NSString*)accountID containPredict:(BOOL)containPredict
{
    NSDate *nextMonth = [month dateByAddingCalendarMonth:1];
    
    if( containPredict )
        return [LadyCalendarPeriod MR_findAllSortedBy:@"startDate" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"(account.uniqueID == %@) AND ((startDate >= %@) AND (startDate < %@))",accountID,month,nextMonth]];
    
    return [LadyCalendarPeriod MR_findAllSortedBy:@"startDate" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"isPredict == %@ AND (account.uniqueID == %@) AND ((startDate >= %@) AND (startDate < %@))",@(NO),accountID,month,nextMonth]];
}

- (NSArray*)periodListWithMonth:(NSDate*)month period:(NSInteger)period accountID:(NSString*)accountID
{
    NSDate *startMonth = [month dateByAddingCalendarMonth:-period];

    return [LadyCalendarPeriod MR_findAllSortedBy:@"startDate" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"isPredict == %@ AND (account.uniqueID == %@) AND ((startDate >= %@) AND (startDate < %@))",@(NO),accountID,startMonth,month]];
}

- (LadyCalendarPeriod *)previousPeriodFromDate:(NSDate *)date {
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(startDate < %@) AND (account.uniqueID == %@) AND (isPredict == %@)", date, _currentAccount.uniqueID, @(NO)];
	return [LadyCalendarPeriod MR_findFirstWithPredicate:predicate sortedBy:@"startDate" ascending:NO];
}

- (LadyCalendarPeriod *)nextPeriodFromDate:(NSDate *)date {
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(startDate > %@) AND (account.uniqueID == %@)", date, _currentAccount.uniqueID];
    return [LadyCalendarPeriod MR_findFirstWithPredicate:predicate sortedBy:@"startDate" ascending:YES];
}

- (BOOL)isOverlapStartDate:(NSDate*)startDate endDate:(NSDate*)endDate accountID:(NSString*)accountID periodID:(NSString*)periodID
{
    NSArray *array = nil;
    if( [periodID length] < 1 )
        return [[LadyCalendarPeriod MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"(account.uniqueID == %@) AND (isPredict == %@) AND ((startDate <= %@ AND endDate >= %@) OR (startDate <= %@ AND endDate >= %@))", accountID, @(NO), startDate, startDate, endDate, endDate]] count] > 0;
    else
        array = [LadyCalendarPeriod MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"(account.uniqueID == %@) AND (isPredict == %@) AND ((startDate <= %@ AND endDate >= %@) OR (startDate <= %@ AND endDate >= %@)) AND uniqueID != %@", accountID, @(NO), startDate, startDate, endDate, endDate, periodID]];
    
    return ([array count] > 0 );
}

#pragma mark - setting

- (NSMutableDictionary*)createDefaultSetting
{
    NSMutableDictionary *item = [NSMutableDictionary dictionary];
    [item setObject:@(3) forKey:SettingItem_ForeCastingPeriods];
    [item setObject:@(CycleLength_SameBeforeCycle) forKey:SettingItem_CalculateCycle];
    [item setObject:@(YES) forKey:SettingItem_AutoRecord];
    [item setObject:@(AlertType_None) forKey:SettingItem_AlertType];
    
    return item;
}

- (NSDictionary*)currentSetting
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:A3LadyCalendarSetting];
}

- (NSString*)stringForAlertType:(NSInteger)alertType
{
    NSInteger index = ABS(alertType);
    NSArray *strings = @[
			NSLocalizedString(@"None", @"None"),
			NSLocalizedString(@"On day(9 AM)", @"On day(9 AM)"),
			NSLocalizedString(@"1 day before(9 AM)", @"1 day before(9 AM)"),
			NSLocalizedString(@"2 days before(9 AM)", @"2 days before(9 AM)"),
			NSLocalizedString(@"1 week before", @"1 week before"),
			NSLocalizedString(@"Custom", @"Custom")];
    if( index < 0 || index >= [strings count] )
        return @"";
    
    return [strings objectAtIndex:index];
}

- (void)removeAllPredictItemsAccountID:(NSString*)accountID
{
    NSArray *predictArray = [self predictPeriodListSortedByStartDateIsAscending:YES ];
    for(LadyCalendarPeriod *item in predictArray){
		[item MR_deleteEntity];
    }
	[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
}

- (NSInteger)cycleLengthConsideringUserOption {
	NSArray *periodArray = [self periodListSortedByStartDateIsAscending:YES ];

	NSDictionary *setting = [[NSUserDefaults standardUserDefaults] objectForKey:A3LadyCalendarSetting];

	NSInteger cycleOption = [[setting objectForKey:SettingItem_CalculateCycle] integerValue];

	NSInteger cycleLength = 0;
	// 주기값을 구한다.
	if( cycleOption == CycleLength_SameBeforeCycle ){
		cycleLength = [self calculateAverageCycleFromArray:periodArray fromIndex:[periodArray count]-1];
	}
	else if( cycleOption == CycleLength_AverageBeforeTwoCycle ){
		cycleLength = [self calculateAverageCycleFromArray:periodArray fromIndex:[periodArray count]-2];
	}
	else if( cycleOption == CycleLength_AverageAllCycle ){
		cycleLength = [self calculateAverageCycleFromArray:periodArray fromIndex:0];
	}

	return cycleLength;
}

- (void)updatePredictPeriodsWithCount:(NSInteger)numberOfPredicts {
	LadyCalendarAccount *account = [self currentAccount];
	if( account == nil )
		return;

	// 예상치 제외한 값을 가져온다.
	NSArray *periodArray = [self periodListSortedByStartDateIsAscending:YES ];

	if( [periodArray count] < 1 ){
		// 예상치 저장된 것들이 있다면 다 삭제한다.
		[self removeAllPredictItemsAccountID:account.uniqueID];
		return;
	}

	NSDictionary *setting = [[NSUserDefaults standardUserDefaults] objectForKey:A3LadyCalendarSetting];

	NSInteger cycleOption = [[setting objectForKey:SettingItem_CalculateCycle] integerValue];

	NSInteger cycleLength = 0;
	// 주기값을 구한다.
	if( cycleOption == CycleLength_SameBeforeCycle ){
		cycleLength = [self calculateAverageCycleFromArray:periodArray fromIndex:[periodArray count]-1];
	}
	else if( cycleOption == CycleLength_AverageBeforeTwoCycle ){
		cycleLength = [self calculateAverageCycleFromArray:periodArray fromIndex:[periodArray count]-2];
	}
	else if( cycleOption == CycleLength_AverageAllCycle ){
		cycleLength = [self calculateAverageCycleFromArray:periodArray fromIndex:0];
	}

	// 현재 예상목록을 모두 지우고 다시 생성한다.
	[self removeAllPredictItemsAccountID:account.uniqueID];

	LadyCalendarPeriod *lastItem = [periodArray lastObject];
	NSDate *prevStartDate = lastItem.startDate;

	for (NSInteger idx = 0; idx < numberOfPredicts; idx++){
		LadyCalendarPeriod *newPeriod = [LadyCalendarPeriod MR_createEntity];
		newPeriod.uniqueID = [[NSUUID UUID] UUIDString];
		newPeriod.isPredict = @(YES);
		newPeriod.startDate = [A3DateHelper dateMake12PM:[A3DateHelper dateByAddingDays:cycleLength fromDate:prevStartDate]];
		newPeriod.endDate = [A3DateHelper dateByAddingDays:4 fromDate:newPeriod.startDate];
		newPeriod.cycleLength = @(cycleLength);
		newPeriod.updateDate = [NSDate date];
		newPeriod.account = account;
		NSDateComponents *cycleLengthComponents = [NSDateComponents new];
		cycleLengthComponents.day = [newPeriod.cycleLength integerValue] - 1;
		newPeriod.periodEnds = [[A3AppDelegate instance].calendar dateByAddingComponents:cycleLengthComponents toDate:newPeriod.startDate options:0];

		prevStartDate = newPeriod.startDate;
	}
	[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
}

- (void)recalculateDates
{
	NSDictionary *setting = [[NSUserDefaults standardUserDefaults] objectForKey:A3LadyCalendarSetting];

	NSInteger periodLength = [[setting objectForKey:SettingItem_ForeCastingPeriods] integerValue];
	[self updatePredictPeriodsWithCount:periodLength];

	[A3LadyCalendarModelManager setupLocalNotification];
}

- (NSString*)stringFromDate:(NSDate*)date
{
	[self.dateFormatter setDateStyle:NSDateFormatterLongStyle];
	[self.dateFormatter setTimeStyle:NSDateFormatterNoStyle];
	return [self.dateFormatter stringFromDate:date];
}

- (NSString*)stringFromDateOmittingYear:(NSDate*)date {
	[self.dateFormatter setDateStyle:NSDateFormatterLongStyle];
	[_dateFormatter setTimeStyle:NSDateFormatterNoStyle];

	NSString *format = [_dateFormatter formatStringByRemovingYearComponent:_dateFormatter.dateFormat];
	[_dateFormatter setDateFormat:format];

	return [_dateFormatter stringFromDate:date];
}

- (NSDate *)startDateForCurrentAccount {
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"account.uniqueID == %@", self.currentAccount.uniqueID];
	LadyCalendarPeriod *firstPeriod = [LadyCalendarPeriod MR_findFirstWithPredicate:predicate sortedBy:@"startDate" ascending:YES];
	return firstPeriod ? firstPeriod.startDate : [NSDate date];
}

- (NSDate *)endDateForCurrentAccount {
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"account.uniqueID == %@", self.currentAccount.uniqueID];
	LadyCalendarPeriod *furthestPeriodEnds = [LadyCalendarPeriod MR_findFirstWithPredicate:predicate sortedBy:@"periodEnds" ascending:NO];
	return furthestPeriodEnds ? furthestPeriodEnds.periodEnds : [NSDate date];
}

+ (void)resetLocalNotifications {
	UIApplication *application = [UIApplication sharedApplication];
	NSArray *notifications = [application scheduledLocalNotifications];
	for (UILocalNotification *notification in notifications) {
		if ([notification.userInfo[A3LocalNotificationOwner] isEqualToString:@"Lady Calendar"]) {
			[application cancelLocalNotification:notification];
		}
	}
}

+ (void)setupLocalNotification {
	[A3LadyCalendarModelManager resetLocalNotifications];

	NSDictionary *settings = [[NSUserDefaults standardUserDefaults] objectForKey:A3LadyCalendarSetting];
	A3LadyCalendarSettingAlertType alertType = (A3LadyCalendarSettingAlertType) [settings[SettingItem_AlertType] integerValue];

	if (alertType == AlertType_None) return;

	NSInteger beforeDay = 0;
	switch (alertType) {
		case AlertType_Custom:
			beforeDay = [settings[SettingItem_CustomAlertDays] integerValue];
			break;
		case AlertType_OneWeekBefore:
			beforeDay = 7;
			break;
		case AlertType_TwoDaysBefore:
			beforeDay = 2;
			break;
		case AlertType_OneDayBefore:
			beforeDay = 1;
			break;
		case AlertType_OnDay:
			beforeDay = 0;
			break;
		case AlertType_None:
			break;
	}
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isPredict == %@", @YES];
	NSArray *predictPeriods = [LadyCalendarPeriod MR_findAllWithPredicate:predicate];

	NSDateComponents *fireDateComponents = [NSDateComponents new];
	fireDateComponents.day = -beforeDay;

	NSDate *today = [NSDate date];

	UIApplication *application = [UIApplication sharedApplication];
	NSCalendar *calendar = [[A3AppDelegate instance] calendar];

	for (LadyCalendarPeriod *period in predictPeriods) {

		NSDate *fireDate = [calendar dateByAddingComponents:fireDateComponents toDate:period.startDate options:0];
		NSDateComponents *components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:fireDate];
		components.hour = 9;
		fireDate = [calendar dateFromComponents:components];

		if ([fireDate isEarlierThanDate:today]) continue;

		NSString *alertBody = NSLocalizedString(@"Your period is coming.", @"Your period is coming.");
		UILocalNotification *notification = [UILocalNotification new];
		notification.fireDate = fireDate;
		notification.alertBody = alertBody;
		notification.soundName = UILocalNotificationDefaultSoundName;
		notification.userInfo = @{A3LocalNotificationOwner:A3LocalNotificationFromLadyCalendar, A3LocalNotificationDataID:period.uniqueID};
		[application scheduleLocalNotification:notification];
	}
	FNLOG(@"%@", [application scheduledLocalNotifications]);
}

@end
