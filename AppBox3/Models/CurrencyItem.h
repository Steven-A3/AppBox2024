//
//  CurrencyItem.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/3/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CurrencyFavorite;

@interface CurrencyItem : NSManagedObject

@property (nonatomic, retain) NSString * currencyCode;
@property (nonatomic, retain) NSString * flagImageName;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * rateToUSD;
@property (nonatomic, retain) NSDate * updated;
@property (nonatomic, retain) NSString * currencySymbol;
@property (nonatomic, retain) CurrencyFavorite *favorite;

@end
