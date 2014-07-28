//
//  UnitPriceInfo.h
//  AppBox3
//
//  Created by A3 on 7/28/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface UnitPriceInfo : NSManagedObject

@property (nonatomic, retain) NSNumber * discountPercent;
@property (nonatomic, retain) NSNumber * discountPrice;
@property (nonatomic, retain) NSString * note;
@property (nonatomic, retain) NSNumber * price;
@property (nonatomic, retain) NSString * priceName;
@property (nonatomic, retain) NSNumber * quantity;
@property (nonatomic, retain) NSNumber * size;
@property (nonatomic, retain) NSString * uniqueID;
@property (nonatomic, retain) NSNumber * unitID;
@property (nonatomic, retain) NSDate * updateDate;
@property (nonatomic, retain) NSNumber * unitCategoryID;
@property (nonatomic, retain) NSString * historyID;

@end
