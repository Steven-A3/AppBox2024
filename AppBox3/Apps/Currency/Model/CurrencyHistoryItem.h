//
//  CurrencyHistoryItem.h
//  AppBox3
//
//  Created by A3 on 6/30/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CurrencyHistory;

@interface CurrencyHistoryItem : NSManagedObject

@property (nonatomic, retain) NSString * currencyCode;
@property (nonatomic, retain) NSString * order;
@property (nonatomic, retain) NSNumber * rate;
@property (nonatomic, retain) CurrencyHistory *history;

@end
