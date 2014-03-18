//
//  A3LadyCalendarModelManager.m
//  A3TeamWork
//
//  Created by coanyaa on 2013. 11. 18..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <EventKit/EventKit.h>
#import "A3LadyCalendarModelManager.h"
#import "A3LadyCalendarDefine.h"
#import "MagicalRecord.h"
#import "LadyCalendarAccount.h"
#import "LadyCalendarPeriod.h"
#import "A3DateHelper.h"
#import "A3UserDefaults.h"

static A3LadyCalendarModelManager *ladyCalendarModelManager = nil;

@interface A3LadyCalendarModelManager ()
//@property (strong, nonatomic) EKEventStore *eventStore;

- (void)addDefaultAccount;
//- (void)initEventStore;
- (EKAlarm*)createAlarmWithPeriod:(LadyCalendarPeriod*)period setting:(NSDictionary*)setting;
- (EKReminder*)registerToReminder:(LadyCalendarPeriod*)period;
@end

@implementation A3LadyCalendarModelManager

+ (A3LadyCalendarModelManager*)sharedManager
{
    @synchronized (self) {
        if (ladyCalendarModelManager == nil) {
            ladyCalendarModelManager = [[self alloc] init];
        }
    }
    return ladyCalendarModelManager;
}

+ (void)alertMessage:(NSString*)message title:(NSString*)title
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

+ (UIImage*)createTripleCircleImageSize:(CGSize)size lineColor:(UIColor*)lineColor centerColor:(UIColor*)centerColor outCircleColor:(UIColor*)outCircleColor
{
    CGRect outCircleRect = CGRectMake(0, 0, size.width,size.height);
    CGRect outlineRect = CGRectMake(size.width*0.25, size.height*0.25, size.width*0.5, size.height*0.5);
    CGRect inCircleRect = CGRectMake(size.width*0.35, size.height*0.35, size.width * 0.3, size.height * 0.3);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [outCircleColor setFill];
    CGContextFillEllipseInRect(context, outCircleRect);
    [[UIColor whiteColor] setFill];
    CGContextFillEllipseInRect(context, outlineRect);
    
    CGContextSetLineWidth(context, 1.0/[[UIScreen mainScreen] scale]);
    CGContextSetStrokeColorWithColor(context, [lineColor CGColor]);
    CGContextStrokeEllipseInRect(context, outlineRect);
    
    [centerColor setFill];
    CGContextFillEllipseInRect(context, inCircleRect);
    
    UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return retImage;
}

//- (void)initEventStore
//{
//    if(_eventStore)
//        return;
//    
//    self.eventStore = [[EKEventStore alloc] init];
//    [_eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
//        if( !granted){
//            self.eventStore = nil;
//        }
//    }];
//}


- (EKAlarm*)createAlarmWithPeriod:(LadyCalendarPeriod*)period setting:(NSDictionary*)setting
{
    NSInteger alertType = [[setting objectForKey:SettingItem_AlertType] integerValue];

    NSDate *alertDate = nil;
    switch (alertType) {
        case AlertType_OnDay:
            alertDate = [A3DateHelper dateMakeDate:period.startDate Hour:9 minute:0];
            break;
        case AlertType_OneDayBefore:
            alertDate = [A3DateHelper dateMakeDate:[A3DateHelper dateByAddingDays:-1 fromDate:period.startDate] Hour:9 minute:0];
            break;
        case AlertType_TwoDaysBefore:
            alertDate = [A3DateHelper dateMakeDate:[A3DateHelper dateByAddingDays:-2 fromDate:period.startDate] Hour:9 minute:0];
            break;
        case AlertType_OneWeekBefore:
            alertDate = [A3DateHelper dateMakeDate:[A3DateHelper dateByAddingWeeks:-1 fromDate:period.startDate] Hour:9 minute:0];
            break;
        case AlertType_Custom:{
            NSInteger days = [[setting objectForKey:SettingItem_CustomAlertDays] integerValue];
            alertDate = [A3DateHelper dateMakeDate:[A3DateHelper dateByAddingDays:-days fromDate:period.startDate] Hour:9 minute:0];
        }
            break;
    }
    
    EKAlarm *alarm = [EKAlarm alarmWithAbsoluteDate:alertDate];
    return alarm;
}

- (EKReminder*)registerToReminder:(LadyCalendarPeriod*)period
{
//    NSDictionary *setting = [self currentSetting];
//    EKAlarm *alarm = [self createAlarmWithPeriod:period setting:setting];
//    EKReminder *reminder = [EKReminder reminderWithEventStore:_eventStore];
//    reminder.calendar = [_eventStore defaultCalendarForNewReminders];
//    reminder.title = [NSString stringWithFormat:@"Menstrual period"];
//    [reminder addAlarm:alarm];
//    
//    NSError *error = nil;
//    if([_eventStore saveReminder:reminder commit:YES error:&error])
//        return reminder;
    
    return nil;
}

- (void)addDefaultAccount
{
    [self addAccount:@{AccountItem_ID : DefaultAccountID, AccountItem_Name : DefaultAccountName}];
}

- (NSManagedObjectContext*)managedObjectContext
{
    if( managedContext == nil ){
        managedContext = [[MagicalRecordStack defaultStack] context];
	}
    
    return managedContext;
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
            NSArray *predictList = [self predictPeriodListSortedByStartDateIsAscending:YES accountID:account.accountID];
            
            NSDate *today = [NSDate date];
            
            BOOL isProcess = NO;
            for(LadyCalendarPeriod *period in predictList ){
                if( [today timeIntervalSince1970] > [period.endDate timeIntervalSince1970] ){
                    isProcess = YES;
                    [self autosavePredictPeriodToReal:period];
                }
            }
            if( isProcess )
                [[self managedObjectContext] MR_saveToPersistentStoreAndWait];
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
    return [LadyCalendarAccount MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"accountID == %@",accountID] inContext:[self managedObjectContext]];
}

- (NSMutableDictionary*)emptyAccount
{
    NSMutableDictionary *item = [NSMutableDictionary dictionary];
    [item setObject:[[NSUUID UUID] UUIDString] forKey:AccountItem_ID];
    [item setObject:@"" forKey:AccountItem_Name];
    [item setObject:@"" forKey:AccountItem_Notes];
    
    return item;
}

- (BOOL)addAccount:(NSDictionary*)item
{
    LadyCalendarAccount *account = [self accountForID:[item objectForKey:AccountItem_ID]];
    if( account )
        return NO;
    
    account = [LadyCalendarAccount MR_createInContext:[self managedObjectContext]];
    account.accountID = [item objectForKey:AccountItem_ID];
    account.accountName = [item objectForKey:AccountItem_Name];
    account.accountNotes = [item objectForKey:AccountItem_Notes];
    account.birthDay = [item objectForKey:AccountItem_Birthday];
    account.order = [NSNumber numberWithInteger:[self numberOfAccount]+1];
    account.regDate = [NSDate date];
    
    [[self managedObjectContext] MR_saveToPersistentStoreAndWait];
    
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

- (BOOL)modifyAccount:(NSDictionary*)item
{
    LadyCalendarAccount *account = [self accountForID:[item objectForKey:AccountItem_ID]];
    if( account == nil)
        return NO;
    
    account.accountName = [item objectForKey:AccountItem_Name];
    account.accountNotes = [item objectForKey:AccountItem_Notes];
    account.birthDay = [item objectForKey:AccountItem_Birthday];
    [account.managedObjectContext MR_saveToPersistentStoreAndWait];
    
    return YES;
}

- (NSArray*)accountListSortedByNameIsAscending:(BOOL)ascending
{
    return [LadyCalendarAccount MR_findAllSortedBy:@"accountName" ascending:ascending inContext:[self managedObjectContext]];
}

- (NSArray*)accountListSortedByOrderIsAscending:(BOOL)ascending
{
    return [LadyCalendarAccount MR_findAllSortedBy:@"order" ascending:ascending inContext:[self managedObjectContext]];
}

- (NSMutableDictionary*)dictionaryFromAccount:(LadyCalendarAccount*)account
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:account.accountID forKey:AccountItem_ID];
    [dict setObject:account.accountName forKey:AccountItem_Name];
    if( account.birthDay )
        [dict setObject:account.birthDay forKey:AccountItem_Birthday];
    [dict setObject:(account.accountNotes ? account.accountNotes : @"") forKey:AccountItem_Notes];
    [dict setObject:account.order forKey:AccountItem_Order];
    [dict setObject:account.regDate forKey:AccountItem_RegDate];
    
    return dict;
}

- (LadyCalendarAccount*)currentAccount
{
    NSString *accountID = [[NSUserDefaults standardUserDefaults] objectForKey:A3LadyCalendarCurrentAccountID];
    if( [accountID length] < 1 )
        return nil;
    
    return [self accountForID:accountID];
}

#pragma mark - period
- (NSInteger)numberOfPeriodsWithAccountID:(NSString*)accountID
{
    return [LadyCalendarPeriod MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"accountID == %@",accountID] inContext:[self managedObjectContext]];
}

- (LadyCalendarPeriod*)periodForID:(NSString*)periodID
{
    return [LadyCalendarPeriod MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"periodID == %@",periodID] inContext:[self managedObjectContext]];
}

- (NSMutableDictionary*)emptyPeriod
{
    NSMutableDictionary *item = [NSMutableDictionary dictionary];
    
    NSDate *startDate = [A3DateHelper dateMake12PM:[NSDate date]];
    NSDate *endDate = [A3DateHelper dateMake12PM:[A3DateHelper dateByAddingDays:4 fromDate:startDate]];
    LadyCalendarAccount *account = [self currentAccount];
    [item setObject:[[NSUUID UUID] UUIDString] forKey:PeriodItem_ID];
    [item setObject:startDate forKey:PeriodItem_StartDate];
    [item setObject:endDate forKey:PeriodItem_EndDate];
    [item setObject:[NSNumber numberWithInteger:28] forKey:PeriodItem_CycleLength];
    [item setObject:@"" forKey:PeriodItem_Notes];
    [item setObject:@(NO) forKey:PeriodItem_IsPerdict];
    [item setObject:@"" forKey:PeriodItem_CalendarID];
    [item setObject:@(NO) forKey:PeriodItem_IsAutoSave];
    [item setObject:account.accountID forKey:PeriodItem_AccountID];
    [item setObject:account forKey:PeriodItem_Account];
    
    return item;
}

- (BOOL)addPeriod:(NSDictionary*)item
{
    LadyCalendarPeriod *period = [self periodForID:[item objectForKey:PeriodItem_ID]];
    if( period )
        return NO;
    
    period = [LadyCalendarPeriod MR_createInContext:[self managedObjectContext]];
    period.periodID = [item objectForKey:PeriodItem_ID];
    period.startDate = [item objectForKey:PeriodItem_StartDate];
    period.endDate = [item objectForKey:PeriodItem_EndDate];
    period.cycleLength = [item objectForKey:PeriodItem_CycleLength];
//    period.ovulation = [item objectForKey:PeriodItem_Ovulation];
    period.periodNotes = [item objectForKey:PeriodItem_Notes];
    period.isPredict = [item objectForKey:PeriodItem_IsPerdict];
    period.isAutoSave = [item objectForKey:PeriodItem_IsAutoSave];
    period.accountID = [item objectForKey:PeriodItem_AccountID];
    period.account = [item objectForKey:PeriodItem_Account];
    period.regDate = [NSDate date];
    
    // 해당 아이템이 예측 수치이면 설정된 값에 의거하여 reminder에 등록하고 해당 아이디를 저장시킨다.
    NSDictionary *setting = [self currentSetting];
    if( [period.isPredict boolValue] && ([[setting objectForKey:SettingItem_AlertType] integerValue] != AlertType_None) ){
        EKReminder *reminder = [self registerToReminder:period];
        if( reminder )
            period.calendarID = reminder.calendarItemIdentifier;
    }
    
    [[self managedObjectContext] MR_saveToPersistentStoreAndWait];
    
    return YES;
}

- (void)autosavePredictPeriodToReal:(LadyCalendarPeriod*)item
{
    item.isPredict = @(NO);
    item.isAutoSave = @(YES);
    
    // 리마인더 항목이 있다면 제거한다.
//    if( [item.calendarID length] > 0 ){
//        EKReminder *reminder = (EKReminder*)[_eventStore calendarItemWithIdentifier:item.calendarID];
//        if( reminder )
//            [_eventStore removeReminder:reminder commit:YES error:nil];
//        item.calendarID = nil;
//    }
}

- (BOOL)removePeriod:(NSString*)periodID
{
    LadyCalendarPeriod *period = [self periodForID:periodID];
    if( period == nil )
        return NO;
    
    // 예측치 이고 reminder에 등록 되어있으면 reminder를 삭제한다.
    if( [period.isPredict boolValue] && [period.calendarID length] > 0){
//        EKReminder *reminder = (EKReminder*)[_eventStore calendarItemWithIdentifier:period.calendarID];
//        if( reminder )
//            [_eventStore removeReminder:reminder commit:YES error:nil];
    }
    
    [period MR_deleteEntity];
    [period.managedObjectContext MR_saveToPersistentStoreAndWait];
    
    return YES;
}

- (BOOL)modifyPeriod:(NSDictionary*)item
{
    LadyCalendarPeriod *period = [self periodForID:[item objectForKey:PeriodItem_ID]];
    if( period == nil )
        return NO;
    
    period.startDate = [item objectForKey:PeriodItem_StartDate];
    period.endDate = [item objectForKey:PeriodItem_EndDate];
    period.cycleLength = [item objectForKey:PeriodItem_CycleLength];
//    period.ovulation = [item objectForKey:PeriodItem_Ovulation];
    period.periodNotes = [item objectForKey:PeriodItem_Notes];
    period.isPredict = [item objectForKey:PeriodItem_IsPerdict];
    period.isAutoSave = @(NO);
    period.accountID = [item objectForKey:PeriodItem_AccountID];
    period.account = [item objectForKey:PeriodItem_Account];
    
    // 예측 치 이고 reminder가 등록되어있다면 reminder의 내용을 삭제하고 새로 등록.
    if( [period.isPredict boolValue] && [period.calendarID length] > 0 ){
//        EKReminder *reminder = (EKReminder*)[_eventStore calendarItemWithIdentifier:period.calendarID];
//        if( reminder )
//            [_eventStore removeReminder:reminder commit:YES error:nil];
        
        NSDictionary *setting = [self currentSetting];
        if( [[setting objectForKey:SettingItem_AlertType] integerValue] == AlertType_None ){
            period.calendarID = nil;
        }
        else{
//            reminder = [self registerToReminder:period];
//            if( reminder )
//                period.calendarID = reminder.calendarItemIdentifier;
        }
    }
    
    [[self managedObjectContext] MR_saveToPersistentStoreAndWait];
    
    return YES;
}

- (NSMutableDictionary*)dictionaryFromPeriod:(LadyCalendarPeriod*)period
{
    NSMutableDictionary *item = [NSMutableDictionary dictionary];
    
    [item setObject:period.periodID forKey:PeriodItem_ID];
    [item setObject:period.startDate forKey:PeriodItem_StartDate];
    if( period.endDate )
        [item setObject:period.endDate forKey:PeriodItem_EndDate];
    [item setObject:period.cycleLength forKey:PeriodItem_CycleLength];
//    if( period.ovulation )
//        [item setObject:period.ovulation forKey:PeriodItem_Ovulation];
    [item setObject:(period.periodNotes ? period.periodNotes : @"") forKey:PeriodItem_Notes];
    [item setObject:period.isPredict forKey:PeriodItem_IsPerdict];
    if( [period.calendarID length] > 0 )
        [item setObject:period.calendarID forKey:PeriodItem_CalendarID];
    [item setObject:(period.accountID ? period.accountID : @"") forKey:PeriodItem_AccountID];
    if( period.account )
        [item setObject:period.account forKey:PeriodItem_Account];
    [item setObject:period.regDate forKey:PeriodItem_RegDate];
    
    return item;
}

- (NSArray*)periodListSortedByStartDateIsAscending:(BOOL)ascending accountID:(NSString*)accountID
{
    if( [accountID length] < 1 )
        return nil;
    return [LadyCalendarPeriod MR_findAllSortedBy:@"startDate" ascending:ascending withPredicate:[NSPredicate predicateWithFormat:@"accountID == %@ AND isPredict == %@",accountID,@(NO)] inContext:[self managedObjectContext]];
}


- (NSArray*)predictPeriodListSortedByStartDateIsAscending:(BOOL)ascending accountID:(NSString*)accountID
{
    if( [accountID length] < 1 )
        return nil;
    return [LadyCalendarPeriod MR_findAllSortedBy:@"startDate" ascending:ascending withPredicate:[NSPredicate predicateWithFormat:@"accountID == %@ AND isPredict == %@",accountID,@(YES)] inContext:[self managedObjectContext]];
}

- (NSArray*)fullPeriodListSortedByStartDateIsAscending:(BOOL)ascending accountID:(NSString*)accountID
{
    if( [accountID length] < 1 )
        return nil;
    return [LadyCalendarPeriod MR_findAllSortedBy:@"startDate" ascending:ascending withPredicate:[NSPredicate predicateWithFormat:@"accountID == %@",accountID] inContext:[self managedObjectContext]];
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

/*
- (NSArray*)predictPeriodListWithSourceArray:(NSArray*)sourceArray
{
    NSMutableArray *array = [NSMutableArray array];
    
    if( [sourceArray count] < 1 )
        return array;
    
    NSDictionary *setting = [[NSUserDefaults standardUserDefaults] objectForKey:A3LadyCalendarSetting];
    
    NSInteger period = [[setting objectForKey:SettingItem_ForeCastingPeriods] integerValue];
    NSInteger cycleOption = [[setting objectForKey:SettingItem_CalculateCycle] integerValue];
    
    NSInteger cycleLength = 0;
    if( cycleOption == CycleLength_SameBeforeCycle ){
        cycleLength = [self calculateAverageCycleFromArray:sourceArray fromIndex:[sourceArray count]-2];
    }
    else if( cycleOption == CycleLength_AverageBeforeTwoCycle ){
        cycleLength = [self calculateAverageCycleFromArray:sourceArray fromIndex:[sourceArray count]-3];
    }
    else if( cycleOption == CycleLength_AverageAllCycle ){
        cycleLength = [self calculateAverageCycleFromArray:sourceArray fromIndex:0];
    }
    
    LadyCalendarPeriod *lastItem = [sourceArray lastObject];
    NSDate *startDate = lastItem.startDate;
    for(NSInteger i=0; i < period; i++){
        LadyCalendarPeriod *period = [[LadyCalendarPeriod alloc] initWithEntity:[NSEntityDescription entityForName:@"LadyCalendarPeriod" inManagedObjectContext:[self managedObjectContext]] insertIntoManagedObjectContext:nil];
        NSDate *predictDate = [A3DateHelper dateMake12PM:[A3DateHelper dateByAddingDays:cycleLength fromDate:startDate]];

        period.startDate = predictDate;
        period.endDate = [A3DateHelper dateByAddingDays:4 fromDate:predictDate];
        period.cycleLength = @(cycleLength);
        period.ovulation = [A3DateHelper dateByAddingDays:14 fromDate:predictDate];
        [period setValue:[NSNumber numberWithBool:YES] forKey:PeriodItem_IsPerdict];
        
        [array addObject:period];
        startDate = predictDate;
    }
    
    return array;
}
*/

- (NSArray *)periodListInRangeWithMonth:(NSDate*)month accountID:(NSString*)accountID
{
    NSDate *prevMonth = [A3DateHelper dateByAddingMonth:-1 fromDate:month];
    NSDate *nextMonth = [A3DateHelper dateByAddingMonth:1 fromDate:month];
    
    return [LadyCalendarPeriod MR_findAllSortedBy:@"startDate" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"(accountID == %@) AND ((startDate >= %@) AND (startDate <= %@))",accountID,prevMonth,nextMonth] inContext:[self managedObjectContext]];
}

- (NSArray*)periodListWithMonth:(NSDate*)month accountID:(NSString*)accountID containPredict:(BOOL)containPredict
{
    NSDate *nextMonth = [A3DateHelper dateByAddingMonth:1 fromDate:month];
    
    if( containPredict )
        return [LadyCalendarPeriod MR_findAllSortedBy:@"startDate" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"(accountID == %@) AND ((startDate >= %@) AND (startDate < %@))",accountID,month,nextMonth] inContext:[self managedObjectContext]];
    
    return [LadyCalendarPeriod MR_findAllSortedBy:@"startDate" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"isPredict == %@ AND (accountID == %@) AND ((startDate >= %@) AND (startDate < %@))",@(NO),accountID,month,nextMonth] inContext:[self managedObjectContext]];
}

- (NSArray*)periodListWithMonth:(NSDate*)month period:(NSInteger)period accountID:(NSString*)accountID
{
    NSDate *startMonth = [A3DateHelper dateByAddingMonth:-period fromDate:month];
    
    return [LadyCalendarPeriod MR_findAllSortedBy:@"startDate" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"isPredict == %@ AND (accountID == %@) AND ((startDate >= %@) AND (startDate < %@))",@(NO),accountID,startMonth,month] inContext:[self managedObjectContext]];
}

- (LadyCalendarPeriod*)previousPeriodFromDate:(NSDate*)date accountID:(NSString*)accountID
{
    NSArray *ret = [LadyCalendarPeriod MR_findAllSortedBy:@"startDate" ascending:NO withPredicate:[NSPredicate predicateWithFormat:@"(startDate < %@) AND (accountID == %@) AND (isPredict == %@)",date,accountID,@(NO)] inContext:[self managedObjectContext]];
    if( [ret count] < 1 )
        return nil;
    
    return [ret objectAtIndex:0];
}

- (LadyCalendarPeriod*)nextPeriodFromDate:(NSDate*)date accountID:(NSString*)accountID
{
    NSArray *ret = [LadyCalendarPeriod MR_findAllSortedBy:@"startDate" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"(startDate > %@) AND (accountID == %@)",date,accountID] inContext:[self managedObjectContext]];
    if( [ret count] < 1 )
        return nil;
    
    return [ret objectAtIndex:0];
}

- (BOOL)isOverlapStartDate:(NSDate*)startDate endDate:(NSDate*)endDate accountID:(NSString*)accountID periodID:(NSString*)periodID
{
    NSArray *array = nil;
    if( [periodID length] < 1 )
        array = [LadyCalendarPeriod MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"(accountID == %@) AND (isPredict == %@) AND ((startDate <= %@ AND endDate >= %@) OR (startDate <= %@ AND endDate >= %@))",accountID,@(NO),startDate,startDate,endDate,endDate] inContext:[self managedObjectContext]];
    else
        array = [LadyCalendarPeriod MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"(accountID == %@) AND (isPredict == %@) AND ((startDate <= %@ AND endDate >= %@) OR (startDate <= %@ AND endDate >= %@)) AND periodID != %@",accountID,@(NO),startDate,startDate,endDate,endDate,periodID] inContext:[self managedObjectContext]];
    
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
    NSArray *predictArray = [self predictPeriodListSortedByStartDateIsAscending:YES accountID:accountID];
    for(LadyCalendarPeriod *item in predictArray){
        [self removePeriod:item.periodID];
    }
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
    NSArray *periodArray = [self periodListSortedByStartDateIsAscending:YES accountID:account.accountID];
    
    if( [periodArray count] < 1 ){
        // 예상치 저장된 것들이 있다면 다 삭제한다.
        [self removeAllPredictItemsAccountID:account.accountID];
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
    [self removeAllPredictItemsAccountID:account.accountID];
    
    LadyCalendarPeriod *lastItem = [periodArray lastObject];
    NSDate *prevStartDate = lastItem.startDate;
    for(NSInteger i=0; i < periodLength; i++){
        NSMutableDictionary *period = [self emptyPeriod];
        NSDate *startDate = [A3DateHelper dateMake12PM:[A3DateHelper dateByAddingDays:cycleLength fromDate:prevStartDate]];
        NSDate *endDate = [A3DateHelper dateByAddingDays:4 fromDate:startDate];
//        NSDate *nextStartDate = [A3DateHelper dateMake12PM:[A3DateHelper dateByAddingDays:cycleLength fromDate:startDate]];
//        NSDate *ovulation = [A3DateHelper dateByAddingDays:-14 fromDate:nextStartDate];
        [period setObject:startDate forKey:PeriodItem_StartDate];
        [period setObject:endDate forKey:PeriodItem_EndDate];
        [period setObject:@(cycleLength) forKey:PeriodItem_CycleLength];
        [period setObject:@(YES) forKey:PeriodItem_IsPerdict];
//        [period setObject:ovulation forKey:PeriodItem_Ovulation];
        [self addPeriod:period];
        
        prevStartDate = startDate;
    }
}

- (NSString*)dateStringForDate:(NSDate*)date
{
    BOOL isKorean = [A3DateHelper isCurrentLocaleIsKorea];
    NSString *retStr = @"";
    if( date == nil )
        return retStr;
    if( isKorean ){
        retStr = [A3DateHelper dateStringFromDate:date withFormat:(IS_IPHONE ? @"yyyy년 MMM d일 (EEE)" : @"yyyy년 MMM d일 EEEE")];
    }
    else{
        retStr = [A3DateHelper dateStringFromDate:date withFormat:(IS_IPHONE ? @"EEE, MMM d, yyyy" : @"EEEE, MMMM d, yyyy")];
    }
    
    return retStr;
}

- (NSString*)dateStringExceptYearForDate:(NSDate*)date
{
    BOOL isKorean = [A3DateHelper isCurrentLocaleIsKorea];
    NSString *retStr = @"";
    if( date == nil )
        return retStr;
    if( isKorean ){
        retStr = [A3DateHelper dateStringFromDate:date withFormat:(IS_IPHONE ? @"MMM d일 (EEE)" : @"MMM d일 EEEE")];
    }
    else{
        retStr = [A3DateHelper dateStringFromDate:date withFormat:(IS_IPHONE ? @"EEE, MMM d" : @"EEEE, MMMM d")];
    }
    
    return retStr;
}

@end
