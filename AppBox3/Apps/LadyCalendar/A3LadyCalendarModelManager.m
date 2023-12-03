//
//  A3LadyCalendarModelManager.m
//  A3TeamWork
//
//  Created by coanyaa on 2013. 11. 18..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3LadyCalendarModelManager.h"
#import "A3LadyCalendarDefine.h"
#import "LadyCalendarPeriod.h"
#import "A3DateHelper.h"
#import "A3UserDefaultsKeys.h"
#import "A3AppDelegate.h"
#import "NSDate+calculation.h"
#import "NSDate-Utilities.h"
#import "LadyCalendarPeriod+extension.h"
#import "A3SyncManager.h"
#import "A3SyncManager+NSUbiquitousKeyValueStore.h"
#import "LadyCalendarAccount.h"
#import "NSManagedObject+extension.h"
#import "NSManagedObjectContext+extension.h"
#import "NSString+conversion.h"

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

- (void)addDefaultAccount {
    NSManagedObjectContext *context = A3SyncManager.sharedSyncManager.persistentContainer.viewContext;
    LadyCalendarAccount *account = [[LadyCalendarAccount alloc] initWithContext:context];
	account.uniqueID = DefaultAccountID;
	account.name = [self defaultAccountName];
	account.order = [NSString orderStringWithOrder:1000000];
    [context saveContext];
}

- (NSDateFormatter *)dateFormatter {
	if (!_dateFormatter) {
		_dateFormatter = [NSDateFormatter new];
	}
	return _dateFormatter;
}

- (void)prepare
{
	[self prepareAccount];

    // 기본 설정값을 저장한다.
    if ([[A3SyncManager sharedSyncManager] objectForKey:A3LadyCalendarUserDefaultsSettings] == nil ){
        NSMutableDictionary *item = [self createDefaultSetting];
		[[A3SyncManager sharedSyncManager] setObject:item forKey:A3LadyCalendarUserDefaultsSettings state:A3DataObjectStateInitialized];
    }

	[self makePredictPeriodsBeforeCurrentPeriod];
    [self recalculateDates];
}

- (void)prepareAccount {
	// 기본 계정을 한개 추가한다.
	if ([self numberOfAccount] < 1 ){
		[self addDefaultAccount];

		if ( [[A3SyncManager sharedSyncManager] objectForKey:A3LadyCalendarCurrentAccountID] == nil ) {
			[[A3SyncManager sharedSyncManager] setObject:DefaultAccountID forKey:A3LadyCalendarCurrentAccountID state:A3DataObjectStateInitialized];
		}
	}
}

- (void)deleteAccount:(LadyCalendarAccount *)account {
    NSManagedObjectContext *context = A3SyncManager.sharedSyncManager.persistentContainer.viewContext;
    [context deleteObject:account];
    [context saveContext];
}

- (void)makePredictPeriodsBeforeCurrentPeriod
{
    NSDictionary *setting = [self currentSetting];
	if ( ![[setting objectForKey:SettingItem_AutoRecord] boolValue] )
        return;

	LadyCalendarAccount *account = [self currentAccount];
	if ( !account )
        return;

	// Make predict item until today
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"accountID == %@ && isPredict == %@", account.uniqueID, @NO];
	if (![LadyCalendarPeriod countOfEntitiesWithPredicate:predicate])
        return;

	LadyCalendarPeriod *period = [LadyCalendarPeriod findFirstWithPredicate:predicate sortedBy:@"startDate" ascending:NO];
	NSDate *today = [NSDate date];
	if ([today isEarlierThanDate:period.periodEnds])
        return;

	NSInteger averageCycleLength = [self cycleLengthConsideringUserOption];
	if (averageCycleLength == 0) {
		averageCycleLength = 28;
	}
	NSCalendar *calendar = [[A3AppDelegate instance] calendar];
	NSDateComponents *difference = [calendar components:NSCalendarUnitDay fromDate:period.periodEnds toDate:today options:0];
	NSInteger numberOfPredictToMake = difference.day / averageCycleLength + 1;

	if (numberOfPredictToMake) {
		[self updatePredictPeriodsWithCount:numberOfPredictToMake];
	}

	NSArray *predictList = [self predictPeriodListSortedByStartDateIsAscending:YES ];
	for(LadyCalendarPeriod *period in predictList ) {
		if ( [period.startDate isEarlierThanDate:today] ){
			period.isPredict = @(NO);
			period.isAutoSave = @(YES);
		}
	}
    NSManagedObjectContext *context = A3SyncManager.sharedSyncManager.persistentContainer.viewContext;
    [context saveContext];
}

#pragma mark - account

- (NSInteger)numberOfAccount {
    return [LadyCalendarAccount countOfEntities];
}

- (LadyCalendarAccount *)currentAccount {
	if (!_currentAccount) {
		[self prepareAccount];

		NSString *accountID = [[A3SyncManager sharedSyncManager] objectForKey:A3LadyCalendarCurrentAccountID];
		_currentAccount = [LadyCalendarAccount findFirstByAttribute:ID_KEY withValue:accountID];
		if (!_currentAccount) {
			_currentAccount = [LadyCalendarAccount findFirst];
			[[A3SyncManager sharedSyncManager] setObject:_currentAccount.uniqueID forKey:A3LadyCalendarCurrentAccountID state:A3DataObjectStateModified];
		}
	}
	return _currentAccount;
}

- (void)setWatchingDateForCurrentAccount:(NSDate *)date {
	self.currentAccount.watchingDate = date;
    NSManagedObjectContext *context = A3SyncManager.sharedSyncManager.persistentContainer.viewContext;
    [context saveContext];
}

#pragma mark - period

- (NSInteger)numberOfPeriodsWithAccountID:(NSString*)accountID
{
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"accountID == %@",accountID];
    return [LadyCalendarPeriod countOfEntitiesWithPredicate:predicate];
}

- (NSArray *)periodListSortedByStartDateIsAscending:(BOOL)ascending {
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"accountID == %@ AND isPredict == %@", [self currentAccount].uniqueID, @(NO)];
    return [LadyCalendarPeriod findAllSortedBy:@"startDate"
                                     ascending:ascending
                                 withPredicate:predicate];
}

- (NSArray *)predictPeriodListSortedByStartDateIsAscending:(BOOL)ascending {
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"accountID == %@ AND isPredict == %@", [self currentAccount].uniqueID, @(YES)];
    return [LadyCalendarPeriod findAllSortedBy:@"startDate"
                                     ascending:ascending
                                 withPredicate:predicate];
}

- (NSInteger)calculateAverageCycleFromArray:(NSArray*)array fromIndex:(NSInteger)index
{
    if ( [array count] < 1 )
        return 0;
    else if ( [array count] == 1 ){
        LadyCalendarPeriod *item = [array objectAtIndex:0];
        return [item.cycleLength integerValue];
    }
    
    if ( index < 0 )
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

	return [LadyCalendarPeriod findAllSortedBy:@"startDate" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"(accountID == %@) AND ((startDate >= %@) AND (startDate < %@))", [self currentAccount].uniqueID, month, nextMonth]];
}

- (NSArray *)periodListInRangeWithMonth:(NSDate*)month accountID:(NSString*)accountID
{
    NSDate *prevMonth = [month dateByAddingCalendarMonth:-1];
	NSDate *nextMonth = [month dateByAddingCalendarMonth:1];

    return [LadyCalendarPeriod findAllSortedBy:@"startDate" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"(accountID == %@) AND ((startDate >= %@) AND (startDate < %@))", accountID, prevMonth, nextMonth]];
}

- (NSArray*)periodListWithMonth:(NSDate*)month accountID:(NSString*)accountID containPredict:(BOOL)containPredict
{
    NSDate *nextMonth = [month dateByAddingCalendarMonth:1];
    
    if ( containPredict )
        return [LadyCalendarPeriod findAllSortedBy:@"startDate" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"(accountID == %@) AND ((startDate >= %@) AND (startDate < %@))",accountID,month,nextMonth]];
    
    return [LadyCalendarPeriod findAllSortedBy:@"startDate" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"isPredict == %@ AND (accountID == %@) AND ((startDate >= %@) AND (startDate < %@))",@(NO),accountID,month,nextMonth]];
}

- (NSArray*)periodListWithMonth:(NSDate*)month period:(NSInteger)period accountID:(NSString*)accountID
{
    NSDate *startMonth = [month dateByAddingCalendarMonth:-period];

    return [LadyCalendarPeriod findAllSortedBy:@"startDate" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"isPredict == %@ AND (accountID == %@) AND ((startDate >= %@) AND (startDate < %@))",@(NO),accountID,startMonth,month]];
}

- (LadyCalendarPeriod *)currentPeriodFromDate:(NSDate *)date {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(startDate < %@ && periodEnds > %@) AND (accountID == %@)", date, date, [self currentAccount].uniqueID];
    return [LadyCalendarPeriod findFirstWithPredicate:predicate];
}

- (LadyCalendarPeriod *)previousPeriodFromDate:(NSDate *)date {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(startDate < %@) AND (accountID == %@) AND isPredict == NO", date, [self currentAccount].uniqueID];
	return [LadyCalendarPeriod findFirstWithPredicate:predicate sortedBy:@"startDate" ascending:NO];
}

- (LadyCalendarPeriod *)nextPeriodFromDate:(NSDate *)date {
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(startDate > %@) AND (accountID == %@)", date, [self currentAccount].uniqueID];
    return [LadyCalendarPeriod findFirstWithPredicate:predicate sortedBy:@"startDate" ascending:YES];
}

- (LadyCalendarPeriod *)lastPeriod {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(accountID == %@) AND isPredict == NO", [self currentAccount].uniqueID];
    return [LadyCalendarPeriod findFirstWithPredicate:predicate sortedBy:@"startDate" ascending:NO];
}

- (BOOL)isOverlapStartDate:(NSDate*)startDate endDate:(NSDate*)endDate accountID:(NSString*)accountID periodID:(NSString*)periodID
{
    NSArray *array = nil;
    if ( [periodID length] < 1 ) {
        array = [LadyCalendarPeriod findAllWithPredicate:[NSPredicate predicateWithFormat:@"(uniqueID != nil) AND (accountID == %@) AND (isPredict == %@) AND ((startDate <= %@ AND endDate >= %@) OR (startDate <= %@ AND endDate >= %@))", accountID, @(NO), startDate, startDate, endDate, endDate]];
    }
    else {
        array = [LadyCalendarPeriod findAllWithPredicate:[NSPredicate predicateWithFormat:@"(accountID == %@) AND (isPredict == %@) AND ((startDate <= %@ AND endDate >= %@) OR (startDate <= %@ AND endDate >= %@)) AND uniqueID != %@", accountID, @(NO), startDate, startDate, endDate, endDate, periodID]];
    }
    
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
    return [[A3SyncManager sharedSyncManager] objectForKey:A3LadyCalendarUserDefaultsSettings];
}

- (NSString*)stringForAlertType:(NSInteger)alertType
{
    NSInteger index = ABS(alertType);
    NSArray *strings = @[
			NSLocalizedString(@"Alert_None", @"None"),
			NSLocalizedString(@"On day(9 AM)", @"On day(9 AM)"),
			NSLocalizedString(@"1 day before(9 AM)", @"1 day before(9 AM)"),
			NSLocalizedString(@"2 days before(9 AM)", @"2 days before(9 AM)"),
			NSLocalizedString(@"1 week before", @"1 week before"),
			NSLocalizedString(@"Custom", @"Custom")];
    if ( index < 0 || index >= [strings count] )
        return @"";
    
    return [strings objectAtIndex:index];
}

- (void)removeAllPredictItemsAccountID:(NSString*)accountID
{
    NSManagedObjectContext *context = A3SyncManager.sharedSyncManager.persistentContainer.viewContext;
    NSArray *predictArray = [self predictPeriodListSortedByStartDateIsAscending:YES ];
    for(LadyCalendarPeriod *item in predictArray){
        [context deleteObject:item];
    }
    [context saveContext];
}

- (NSInteger)cycleLengthConsideringUserOption {
	NSArray *periodArray = [self periodListSortedByStartDateIsAscending:YES ];

	NSDictionary *setting = [[A3SyncManager sharedSyncManager] objectForKey:A3LadyCalendarUserDefaultsSettings];

	NSInteger cycleOption = [[setting objectForKey:SettingItem_CalculateCycle] integerValue];

	NSInteger cycleLength = 0;
	// 주기값을 구한다.
	if ( cycleOption == CycleLength_SameBeforeCycle ){
		cycleLength = [self calculateAverageCycleFromArray:periodArray fromIndex:[periodArray count]-1];
	}
	else if ( cycleOption == CycleLength_AverageBeforeTwoCycle ){
		cycleLength = [self calculateAverageCycleFromArray:periodArray fromIndex:[periodArray count]-2];
	}
	else if ( cycleOption == CycleLength_AverageAllCycle ){
		cycleLength = [self calculateAverageCycleFromArray:periodArray fromIndex:0];
	}

	return cycleLength;
}

- (void)updatePassedPeriodsCycleLength {
    
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"accountID == %@", [self currentAccount].uniqueID];
    NSArray *periodArray =  [LadyCalendarPeriod findAllSortedBy:@"startDate"
                                                      ascending:YES
                                                  withPredicate:predicate];
    LadyCalendarPeriod *latestPeriod = [[self periodListSortedByStartDateIsAscending:YES] lastObject];

    [periodArray enumerateObjectsUsingBlock:^(LadyCalendarPeriod *aPeriod, NSUInteger idx, BOOL *stop) {
        LadyCalendarPeriod *prevPeriod;
        BOOL isLatestPeriod = [aPeriod.startDate isEqualToDate:latestPeriod.startDate];
        
        if (idx > 0) {
            prevPeriod = [periodArray objectAtIndex:idx - 1];
        }

        if (prevPeriod && ![aPeriod.isPredict boolValue] && !isLatestPeriod) {
            aPeriod.cycleLength = @(labs([A3DateHelper diffDaysFromDate:[prevPeriod startDate] toDate:[aPeriod startDate] isAllDay:YES]));
        }
    }];
}

- (void)updatePredictPeriodsWithCount:(NSInteger)numberOfPredicts {
	LadyCalendarAccount *account = [self currentAccount];
	if ( account == nil )
		return;

	// 예상치 제외한 값을 가져온다.
	NSArray *periodArray = [self periodListSortedByStartDateIsAscending:YES ];

	if ( [periodArray count] < 1 ){
		// 예상치 저장된 것들이 있다면 다 삭제한다.
		[self removeAllPredictItemsAccountID:account.uniqueID];
		return;
	}

	NSDictionary *setting = [[A3SyncManager sharedSyncManager] objectForKey:A3LadyCalendarUserDefaultsSettings];

	NSInteger cycleOption = [[setting objectForKey:SettingItem_CalculateCycle] integerValue];

	NSInteger cycleLength = 0;
	// 주기값을 구한다.
	if ( cycleOption == CycleLength_SameBeforeCycle ){
		cycleLength = [self calculateAverageCycleFromArray:periodArray fromIndex:[periodArray count]-1];
	}
	else if ( cycleOption == CycleLength_AverageBeforeTwoCycle ){
		cycleLength = [self calculateAverageCycleFromArray:periodArray fromIndex:[periodArray count]-2];
	}
	else if ( cycleOption == CycleLength_AverageAllCycle ){
		cycleLength = [self calculateAverageCycleFromArray:periodArray fromIndex:0];
	}
    FNLOG(@"%@", @(cycleLength));

	// 현재 예상목록을 모두 지우고 다시 생성한다.
	[self removeAllPredictItemsAccountID:account.uniqueID];

	LadyCalendarPeriod *lastItem = [periodArray lastObject];
	NSDate *prevStartDate = lastItem.startDate;

    NSManagedObjectContext *context = A3SyncManager.sharedSyncManager.persistentContainer.viewContext;
	for (NSInteger idx = 0; idx < numberOfPredicts; idx++){
        LadyCalendarPeriod *newPeriod = [[LadyCalendarPeriod alloc] initWithContext:context];
		newPeriod.isPredict = @(YES);
		newPeriod.startDate = [A3DateHelper dateMake12PM:[A3DateHelper dateByAddingDays:cycleLength fromDate:prevStartDate]];
		[newPeriod reassignUniqueIDWithStartDate];
		newPeriod.endDate = [A3DateHelper dateByAddingDays:4 fromDate:newPeriod.startDate];
		newPeriod.cycleLength = @(cycleLength);
		newPeriod.updateDate = [NSDate date];
		newPeriod.accountID = account.uniqueID;
		NSDateComponents *cycleLengthComponents = [NSDateComponents new];
		cycleLengthComponents.day = [newPeriod.cycleLength integerValue] - 1;
		newPeriod.periodEnds = [[A3AppDelegate instance].calendar dateByAddingComponents:cycleLengthComponents toDate:newPeriod.startDate options:0];

		prevStartDate = newPeriod.startDate;
	}
    [context saveContext];
}

- (void)recalculateDates
{
	NSDictionary *setting = [[A3SyncManager sharedSyncManager] objectForKey:A3LadyCalendarUserDefaultsSettings];

	NSInteger periodLength = [[setting objectForKey:SettingItem_ForeCastingPeriods] integerValue];
    [self updatePassedPeriodsCycleLength];
	[self updatePredictPeriodsWithCount:periodLength];

	[A3LadyCalendarModelManager setupLocalNotification];
}

- (NSString*)stringFromDate:(NSDate*)date
{
	[self.dateFormatter setDateStyle:NSDateFormatterLongStyle];
	[self.dateFormatter setTimeStyle:NSDateFormatterNoStyle];
	return [self.dateFormatter stringFromDate:date];
}

- (NSDate *)startDateForCurrentAccount {
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"accountID == %@", self.currentAccount.uniqueID];
	LadyCalendarPeriod *firstPeriod = [LadyCalendarPeriod findFirstWithPredicate:predicate sortedBy:@"startDate" ascending:YES];
	return firstPeriod ? firstPeriod.startDate : [NSDate date];
}

- (NSDate *)endDateForCurrentAccount {
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"accountID == %@", self.currentAccount.uniqueID];
	LadyCalendarPeriod *furthestPeriodEnds = [LadyCalendarPeriod findFirstWithPredicate:predicate sortedBy:@"startDate" ascending:NO];
    FNLOG(@"%@", furthestPeriodEnds.periodEnds);
    if (!furthestPeriodEnds) {
        return [NSDate date];
    }
    return furthestPeriodEnds.periodEnds;
}

+ (void)resetLocalNotifications {
	UIApplication *application = [UIApplication sharedApplication];
	NSArray *notifications = [application scheduledLocalNotifications];
	for (UILocalNotification *notification in notifications) {
		if ([notification.userInfo[A3LocalNotificationOwner] isEqualToString:A3LocalNotificationFromLadyCalendar]) {
			[application cancelLocalNotification:notification];
		}
	}
}

+ (void)setupLocalNotification {
	[A3LadyCalendarModelManager resetLocalNotifications];

	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isPredict == %@", @YES];
	NSArray *predictPeriods = [LadyCalendarPeriod findAllWithPredicate:predicate];

	if (![predictPeriods count]) return;

	NSDictionary *settings = [[A3SyncManager sharedSyncManager] objectForKey:A3LadyCalendarUserDefaultsSettings];
	A3LadyCalendarSettingAlertType alertType = (A3LadyCalendarSettingAlertType) [settings[SettingItem_AlertType] integerValue];

	if (alertType == AlertType_None) return;

    UIUserNotificationSettings *currentNotificationSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];
    if (currentNotificationSettings.types == UIUserNotificationTypeNone) {
        
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeSound | UIUserNotificationTypeAlert categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }

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

	NSDateComponents *fireDateComponents = [NSDateComponents new];
	fireDateComponents.day = -beforeDay;

	NSDate *today = [NSDate date];

	UIApplication *application = [UIApplication sharedApplication];
	NSCalendar *calendar = [[A3AppDelegate instance] calendar];

	for (LadyCalendarPeriod *period in predictPeriods) {
		@autoreleasepool {
			NSDate *fireDate = [calendar dateByAddingComponents:fireDateComponents toDate:period.startDate options:0];
			NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:fireDate];
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
	}
	FNLOG(@"%@", [application scheduledLocalNotifications]);
}

@end
