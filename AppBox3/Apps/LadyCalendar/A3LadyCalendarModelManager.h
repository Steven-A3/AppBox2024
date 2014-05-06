//
//  A3LadyCalendarModelManager.h
//  A3TeamWork
//
//  Created by coanyaa on 2013. 11. 18..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LadyCalendarAccount;
@class LadyCalendarPeriod;

@interface A3LadyCalendarModelManager : NSObject

@property (nonatomic, strong) LadyCalendarAccount *currentAccount;

+ (void)alertMessage:(NSString*)message title:(NSString*)title;

- (void)prepare;
- (void)savePredictItemBeforeNow;

- (NSInteger)numberOfAccount;
- (LadyCalendarAccount*)accountForID:(NSString*)accountID;

- (BOOL)addAccount:(NSDictionary*)item;
- (BOOL)removeAccount:(NSString*)accountID;

- (NSArray*)accountListSortedByOrderIsAscending:(BOOL)ascending;
- (NSMutableDictionary*)dictionaryFromAccount:(LadyCalendarAccount*)account;
- (LadyCalendarAccount*)currentAccount;

- (NSInteger)numberOfPeriodsWithAccountID:(NSString*)accountID;
- (LadyCalendarPeriod*)periodForID:(NSString*)periodID;
- (void)autoSavePredictPeriodToReal:(LadyCalendarPeriod*)item;

- (NSArray*)periodListSortedByStartDateIsAscending:(BOOL)ascending accountID:(NSString*)accountID;
- (NSArray*)predictPeriodListSortedByStartDateIsAscending:(BOOL)ascending accountID:(NSString*)accountID;

- (NSArray*)periodListWithMonth:(NSDate*)month accountID:(NSString*)accountID containPredict:(BOOL)containPredict;
- (NSArray*)periodListWithMonth:(NSDate*)month period:(NSInteger)period accountID:(NSString*)accountID;
- (LadyCalendarPeriod*)previousPeriodFromDate:(NSDate*)date accountID:(NSString*)accountID;
- (LadyCalendarPeriod*)nextPeriodFromDate:(NSDate*)date accountID:(NSString*)accountID;
- (NSArray *)periodListInRangeWithMonth:(NSDate*)month accountID:(NSString*)accountID;
- (BOOL)isOverlapStartDate:(NSDate*)startDate endDate:(NSDate*)endDate accountID:(NSString*)accountID periodID:(NSString*)periodID;

- (NSMutableDictionary*)createDefaultSetting;
- (NSDictionary*)currentSetting;
- (NSString*)stringForAlertType:(NSInteger)alertType;

- (void)recalculateDates;
- (NSString*)dateStringForDate:(NSDate*)date;
- (NSString*)dateStringExceptYearForDate:(NSDate*)date;

- (NSDate *)startDateForCurrentAccount;
- (NSDate *)endDateForCurrentAccount;

@end
