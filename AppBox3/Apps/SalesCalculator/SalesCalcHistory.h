//
//  SalesCalcHistory.h
//  AppBox3
//
//  Created by A3 on 7/1/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SalesCalcHistory : NSManagedObject

@property (nonatomic, retain) NSNumber * additionalOff;
@property (nonatomic, retain) NSNumber * additionalOffType;
@property (nonatomic, retain) NSNumber * discount;
@property (nonatomic, retain) NSNumber * discountType;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSNumber * price;
@property (nonatomic, retain) NSNumber * priceType;
@property (nonatomic, retain) NSNumber * shownPriceType;
@property (nonatomic, retain) NSNumber * tax;
@property (nonatomic, retain) NSNumber * taxType;
@property (nonatomic, retain) NSDate * updateDate;
@property (nonatomic, retain) NSString * uniqueID;

@end
