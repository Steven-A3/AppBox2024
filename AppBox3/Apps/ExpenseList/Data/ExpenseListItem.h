//
//  ExpenseListItem.h
//  AppBox3
//
//  Created by A3 on 7/18/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ExpenseListItem : NSManagedObject

@property (nonatomic, retain) NSString * budgetID;
@property (nonatomic, retain) NSNumber * hasData;
@property (nonatomic, retain) NSDate * itemDate;
@property (nonatomic, retain) NSString * itemName;
@property (nonatomic, retain) NSString * order;
@property (nonatomic, retain) NSNumber * price;
@property (nonatomic, retain) NSNumber * qty;
@property (nonatomic, retain) NSNumber * subTotal;
@property (nonatomic, retain) NSString * uniqueID;
@property (nonatomic, retain) NSDate * updateDate;

@end
