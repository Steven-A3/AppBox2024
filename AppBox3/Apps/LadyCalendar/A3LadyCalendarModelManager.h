//
//  A3LadyCalendarModelManager.h
//  A3TeamWork
//
//  Created by coanyaa on 2013. 11. 18..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

extern NSString *const A3NotificationLadyCalendarPeriodDataChanged;
extern NSString *const A3LadyCalendarChangedDateKey;

@interface A3LadyCalendarModelManager : NSObject

@property (nonatomic, strong) LadyCalendarAccount_ *currentAccount;

- (NSString *)defaultAccountName;
- (void)prepare;
- (void)prepareAccount;
- (void)deleteAccount:(LadyCalendarAccount_ *)account;
- (void)makePredictPeriodsBeforeCurrentPeriod;
- (NSInteger)numberOfAccount;
- (void)setWatchingDateForCurrentAccount:(NSDate *)date;
- (NSInteger)numberOfPeriodsWithAccountID:(NSString*)accountID;
- (NSArray *)periodListSortedByStartDateIsAscending:(BOOL)ascending;
- (NSArray *)predictPeriodListSortedByStartDateIsAscending:(BOOL)ascending;
- (NSArray*)periodListWithMonth:(NSDate*)month accountID:(NSString*)accountID containPredict:(BOOL)containPredict;
- (NSArray*)periodListWithMonth:(NSDate*)month period:(NSInteger)period accountID:(NSString*)accountID;
- (LadyCalendarPeriod_ *)currentPeriodFromDate:(NSDate *)date;
- (LadyCalendarPeriod_ *)previousPeriodFromDate:(NSDate *)date;
- (LadyCalendarPeriod_ *)nextPeriodFromDate:(NSDate *)date;
- (NSArray *)periodListStartsInMonth:(NSDate *)month;
- (NSArray *)periodListInRangeWithMonth:(NSDate*)month accountID:(NSString*)accountID;
- (LadyCalendarPeriod_ *)lastPeriod;
- (BOOL)isOverlapStartDate:(NSDate*)startDate endDate:(NSDate*)endDate accountID:(NSString*)accountID periodID:(NSString*)periodID;
- (NSMutableDictionary*)createDefaultSetting;
- (NSDictionary*)currentSetting;
- (NSString*)stringForAlertType:(NSInteger)alertType;
- (NSInteger)cycleLengthConsideringUserOption;
- (void)recalculateDates;
- (NSString*)stringFromDate:(NSDate*)date;
- (NSDate *)startDateForCurrentAccount;
- (NSDate *)endDateForCurrentAccount;
+ (void)setupLocalNotification;

@end
