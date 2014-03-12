//
//  ExpenseListHistory.h
//  AppBox3
//
//  Created by A3 on 3/13/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ExpenseListBudget;

@interface ExpenseListHistory : NSManagedObject

@property (nonatomic, retain) NSDate * updateDate;
@property (nonatomic, retain) ExpenseListBudget *budgetData;

@end
