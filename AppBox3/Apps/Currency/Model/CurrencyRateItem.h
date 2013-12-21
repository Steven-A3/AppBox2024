//
//  CurrencyRateItem.h
//  AppBox3
//
//  Created by A3 on 12/19/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CurrencyRateItem : NSManagedObject

@property (nonatomic, retain) NSString * currencyCode;
@property (nonatomic, retain) NSString * currencySymbol;
@property (nonatomic, retain) NSString * flagImageName;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * rateToUSD;
@property (nonatomic, retain) NSDate * updated;

@end
