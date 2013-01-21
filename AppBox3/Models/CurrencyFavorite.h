//
//  CurrencyFavorite.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 1/17/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CurrencyItem;

@interface CurrencyFavorite : NSManagedObject

@property (nonatomic, retain) NSString * order;
@property (nonatomic, retain) CurrencyItem *currencyItem;

@end
