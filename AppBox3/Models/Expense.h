//
//  Expense.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 5/19/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ExpenseDetail;

@interface Expense : NSManagedObject

@property (nonatomic, retain) NSString * budget;
@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSNumber * location_latitude;
@property (nonatomic, retain) NSNumber * location_longitude;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSString * paymentType;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * location_address1;
@property (nonatomic, retain) NSString * location_address2;
@property (nonatomic, retain) NSString * location_address3;
@property (nonatomic, retain) NSString * locatoin_contact;
@property (nonatomic, retain) NSNumber * total;
@property (nonatomic, retain) NSNumber * left;
@property (nonatomic, retain) NSSet *details;
@end

@interface Expense (CoreDataGeneratedAccessors)

- (void)addDetailsObject:(ExpenseDetail *)value;
- (void)removeDetailsObject:(ExpenseDetail *)value;
- (void)addDetails:(NSSet *)values;
- (void)removeDetails:(NSSet *)values;

@end
