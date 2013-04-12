//
//  ExpenseDetail.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 4/12/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Expense;

@interface ExpenseDetail : NSManagedObject

@property (nonatomic, retain) NSString * item;
@property (nonatomic, retain) NSString * order;
@property (nonatomic, retain) NSString * price;
@property (nonatomic, retain) NSString * quantity;
@property (nonatomic, retain) Expense *expense;

@end
