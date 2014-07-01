//
//  ExpenseListBudgetLocation.h
//  AppBox3
//
//  Created by A3 on 6/30/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ExpenseListBudget;

@interface ExpenseListBudgetLocation : NSManagedObject

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * budgetId;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * contact;
@property (nonatomic, retain) NSString * country;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) ExpenseListBudget *budget;

@end
