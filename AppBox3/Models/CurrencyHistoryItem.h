//
//  CurrencyHistoryItem.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 7/16/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CurrencyHistory;

@interface CurrencyHistoryItem : NSManagedObject

@property (nonatomic, retain) NSString * currencyCode;
@property (nonatomic, retain) NSNumber * rateToSource;
@property (nonatomic, retain) NSDate * dateForRate;
@property (nonatomic, retain) CurrencyHistory *history;

@end
