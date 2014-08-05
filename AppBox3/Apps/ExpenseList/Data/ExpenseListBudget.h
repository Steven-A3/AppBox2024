//
//  ExpenseListBudget.h
//  AppBox3
//
//  Created by dotnetguy83 on 8/5/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ExpenseListBudget : NSManagedObject

@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSString * currencyCode;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSData * location;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSString * paymentType;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * totalAmount;
@property (nonatomic, retain) NSString * uniqueID;
@property (nonatomic, retain) NSDate * updateDate;
@property (nonatomic, retain) NSNumber * usedAmount;
@property (nonatomic, retain) NSNumber * isModified;

@end
