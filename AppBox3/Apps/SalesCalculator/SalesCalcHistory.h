//
//  SalesCalcHistory.h
//  A3TeamWork
//
//  Created by jeonghwan kim on 1/24/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SalesCalcHistory : NSManagedObject

@property (nonatomic, retain) NSNumber * additionalOff;
@property (nonatomic, retain) NSNumber * additionalOffType;
@property (nonatomic, retain) NSNumber * discount;
@property (nonatomic, retain) NSNumber * discountType;
@property (nonatomic, retain) NSDate * historyDate;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSNumber * price;
@property (nonatomic, retain) NSNumber * priceType;
@property (nonatomic, retain) NSNumber * tax;
@property (nonatomic, retain) NSNumber * taxType;
@property (nonatomic, retain) NSNumber * shownPriceType;

@end
