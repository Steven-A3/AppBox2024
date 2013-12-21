//
//  CurrencyHistoryItem.h
//  AppBox3
//
//  Created by A3 on 12/19/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
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
