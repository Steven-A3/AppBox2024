//
//  UnitPriceInfo.h
//  AppBox3
//
//  Created by A3 on 3/11/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class UnitItem;

@interface UnitPriceInfo : NSManagedObject

@property (nonatomic, retain) NSString * discountPercent;
@property (nonatomic, retain) NSString * discountPrice;
@property (nonatomic, retain) NSString * note;
@property (nonatomic, retain) NSString * price;
@property (nonatomic, retain) NSString * priceName;
@property (nonatomic, retain) NSString * quantity;
@property (nonatomic, retain) NSString * size;
@property (nonatomic, retain) UnitItem *unit;

@end
