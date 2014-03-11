//
//  UnitPriceFavorite.h
//  AppBox3
//
//  Created by A3 on 3/11/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class UnitItem;

@interface UnitPriceFavorite : NSManagedObject

@property (nonatomic, retain) NSString * order;
@property (nonatomic, retain) UnitItem *item;

@end
