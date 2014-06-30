//
//  ExpenseListItem.h
//  AppBox3
//
//  Created by A3 on 6/30/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ExpenseListBudget;

@interface ExpenseListItem : NSManagedObject

@property (nonatomic, retain) NSNumber * hasData;
@property (nonatomic, retain) NSDate * itemDate;
@property (nonatomic, retain) NSString * itemName;
@property (nonatomic, retain) NSString * order;
@property (nonatomic, retain) NSNumber * price;
@property (nonatomic, retain) NSNumber * qty;
@property (nonatomic, retain) NSNumber * subTotal;
@property (nonatomic, retain) ExpenseListBudget *budget;

@end
