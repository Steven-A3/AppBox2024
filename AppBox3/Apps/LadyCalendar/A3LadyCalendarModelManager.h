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
@interface A3LadyCalendarModelManager : NSObject{
    NSManagedObjectContext *managedContext;
}

+ (A3LadyCalendarModelManager*)sharedManager;
+ (void)alertMessage:(NSString*)message title:(NSString*)title;
+ (UIImage*)createTripleCircleImageSize:(CGSize)size lineColor:(UIColor*)lineColor centerColor:(UIColor*)centerColor outCircleColor:(UIColor*)outCircleColor;

- (NSManagedObjectContext*)managedObjectContext;

- (void)prepare;
- (void)savePredictItemBeforeNow;

- (NSInteger)numberOfAccount;
- (LadyCalendarAccount*)accountForID:(NSString*)accountID;
- (NSMutableDictionary*)emptyAccount;
- (BOOL)addAccount:(NSDictionary*)item;
- (BOOL)removeAccount:(NSString*)accountID;
- (BOOL)modifyAccount:(NSDictionary*)item;
- (NSArray*)accountListSortedByNameIsAscending:(BOOL)ascending;
- (NSArray*)accountListSortedByOrderIsAscending:(BOOL)ascending;
- (NSMutableDictionary*)dictionaryFromAccount:(LadyCalendarAccount*)account;
- (LadyCalendarAccount*)currentAccount;

- (NSInteger)numberOfPeriodsWithAccountID:(NSString*)accountID;
- (LadyCalendarPeriod*)periodForID:(NSString*)periodID;
- (NSMutableDictionary*)emptyPeriod;
- (BOOL)addPeriod:(NSDictionary*)item;
- (void)autosavePredictPeriodToReal:(LadyCalendarPeriod*)item;
- (BOOL)removePeriod:(NSString*)periodID;
- (BOOL)modifyPeriod:(NSDictionary*)item;
- (NSMutableDictionary*)dictionaryFromPeriod:(LadyCalendarPeriod*)period;
- (NSArray*)periodListSortedByStartDateIsAscending:(BOOL)ascending accountID:(NSString*)accountID;
- (NSArray*)predictPeriodListSortedByStartDateIsAscending:(BOOL)ascending accountID:(NSString*)accountID;
- (NSArray*)fullPeriodListSortedByStartDateIsAscending:(BOOL)ascending accountID:(NSString*)accountID;

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
@end
