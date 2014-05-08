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

// UserInfo have "changedMonth".
NSString *const A3NotificationLadyCalendarPeriodDataChanged = @"A3NotificationLadyCalendarPeriodDataChanged";
NSString *const A3LadyCalendarChangedDateKey = @"changedDate";

@interface A3LadyCalendarModelManager ()

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation A3LadyCalendarModelManager

+ (void)alertMessage:(NSString*)message title:(NSString*)title
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

- (void)addDefaultAccount
{
    [self addAccount:@{AccountItem_ID : DefaultAccountID, AccountItem_Name : DefaultAccountName}];
}

- (NSDateFormatter *)dateFormatter {
	if (!_dateFormatter) {
		_dateFormatter = [NSDateFormatter new];
	}
	return _dateFormatter;
}

- (void)prepare
{
    // 기본 계정을 한개 추가한다.
    if( [self numberOfAccount] < 1 ){
        [self addDefaultAccount];
        
        if( [[NSUserDefaults standardUserDefaults] objectForKey:A3LadyCalendarCurrentAccountID] == nil ){
            [[NSUserDefaults standardUserDefaults] setObject:DefaultAccountID forKey:A3LadyCalendarCurrentAccountID];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    
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

- (void)savePredictItemBeforeNow
{
    NSDictionary *setting = [self currentSetting];
    if( [[setting objectForKey:SettingItem_AutoRecord] boolValue] ){
        LadyCalendarAccount *account = [self currentAccount];
        if( account ){
            NSArray *predictList = [self predictPeriodListSortedByStartDateIsAscending:YES ];
            
            NSDate *today = [NSDate date];
            
            BOOL isProcess = NO;
            for(LadyCalendarPeriod *period in predictList ){
                if( [today timeIntervalSince1970] > [period.endDate timeIntervalSince1970] ){
                    isProcess = YES;
					[self autoSavePredictPeriodToReal:period];
                }
            }
            if( isProcess )
                [[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
        }
    }
}

#pragma mark - account
- (NSInteger)numberOfAccount
{
    return [LadyCalendarAccount MR_countOfEntities];
}

- (LadyCalendarAccount*)accountForID:(NSString*)accountID
{
    return [LadyCalendarAccount MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"uniqueID == %@",accountID]];
}

- (BOOL)addAccount:(NSDictionary*)item
{
    LadyCalendarAccount *account = [self accountForID:[item objectForKey:AccountItem_ID]];
    if( account )
        return NO;
    
    account = [LadyCalendarAccount MR_createEntity];
    account.uniqueID = [item objectForKey:AccountItem_ID];
    account.name = [item objectForKey:AccountItem_Name];
    account.notes = [item objectForKey:AccountItem_Notes];
    account.birthDay = [item objectForKey:AccountItem_Birthday];
    account.order = [NSNumber numberWithInteger:[self numberOfAccount]+1];
    account.modificationDate = [NSDate date];
    
    [[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
    
    return YES;
}

- (BOOL)removeAccount:(NSString*)accountID
{
    LadyCalendarAccount *account = [self accountForID:accountID];
    if( account == nil )
        return NO;
    [account MR_deleteEntity];
    [account.managedObjectContext MR_saveToPersistentStoreAndWait];
    
    return YES;
}

- (NSArray*)accountListSortedByOrderIsAscending:(BOOL)ascending
{
    return [LadyCalendarAccount MR_findAllSortedBy:@"order" ascending:ascending];
}

- (NSMutableDictionary*)dictionaryFromAccount:(LadyCalendarAccount*)account
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	[dict setObject:account.uniqueID forKey:AccountItem_ID];
	[dict setObject:account.name forKey:AccountItem_Name];
    if( account.birthDay )
        [dict setObject:account.birthDay forKey:AccountItem_Birthday];
    [dict setObject:(account.notes ? account.notes : @"") forKey:AccountItem_Notes];
    [dict setObject:account.order forKey:AccountItem_Order];
	[dict setObject:account.modificationDate forKey:AccountItem_RegDate];
    
    return dict;
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

- (void)autoSavePredictPeriodToReal:(LadyCalendarPeriod*)item
{
    item.isPredict = @(NO);
    item.isAutoSave = @(YES);
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
        return [[LadyCalendarPeriod MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"(account.uniqueID == %@) AND (isPredict == %@) AND ((startDate <= %@ AND endDate >= %@) OR (startDate <= %@ AND endDate >= %@))",accountID,@(NO),startDate,startDate,endDate,endDate]] count] > 0;
    else
        array = [LadyCalendarPeriod MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"(account.uniqueID == %@) AND (isPredict == %@) AND ((startDate <= %@ AND endDate >= %@) OR (startDate <= %@ AND endDate >= %@)) AND uniqueID != %@",accountID,@(NO),startDate,startDate,endDate,endDate,periodID]];
    
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
    NSArray *strings = @[@"None",@"On day(9 AM)", @"1 day before(9 AM)", @"2 days before(9 AM)", @"1 week before", @"Custom"];
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

// 현재 설정값에 따라서 예정일 및 기간등을 업데이트 하는 함수
// 백그라운드로 동작 후에 notify로 알림한다.
- (void)recalculateDates
{
    LadyCalendarAccount *account = [self currentAccount];
    if( account == nil )
        return;
    
    NSDictionary *setting = [[NSUserDefaults standardUserDefaults] objectForKey:A3LadyCalendarSetting];
    
    NSInteger periodLength = [[setting objectForKey:SettingItem_ForeCastingPeriods] integerValue];
    NSInteger cycleOption = [[setting objectForKey:SettingItem_CalculateCycle] integerValue];
    
    // 예상치 제외한 값을 가져온다.
    NSArray *periodArray = [self periodListSortedByStartDateIsAscending:YES ];
    
    if( [periodArray count] < 1 ){
        // 예상치 저장된 것들이 있다면 다 삭제한다.
		[self removeAllPredictItemsAccountID:account.uniqueID];
        return;
    }
    
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

    for (NSInteger idx = 0; idx < periodLength; idx++){
		LadyCalendarPeriod *newPeriod = [LadyCalendarPeriod MR_createEntity];
		newPeriod.uniqueID = [[NSUUID UUID] UUIDString];
		newPeriod.isPredict = @(YES);
		newPeriod.startDate = [A3DateHelper dateMake12PM:[A3DateHelper dateByAddingDays:cycleLength fromDate:prevStartDate]];
		newPeriod.endDate = [A3DateHelper dateByAddingDays:4 fromDate:newPeriod.startDate];
		newPeriod.cycleLength = @(cycleLength);
		newPeriod.modificationDate = [NSDate date];
		newPeriod.account = account;
		NSDateComponents *cycleLengthComponents = [NSDateComponents new];
		cycleLengthComponents.day = [newPeriod.cycleLength integerValue];
		newPeriod.periodEnds = [[A3AppDelegate instance].calendar dateByAddingComponents:cycleLengthComponents toDate:newPeriod.startDate options:0];

        prevStartDate = newPeriod.startDate;
    }
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

@end
