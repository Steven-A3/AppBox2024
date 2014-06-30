//
//  ExpenseListCategories.h
//  AppBox3
//
//  Created by A3 on 6/30/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ExpenseListCategories : NSManagedObject

@property (nonatomic, retain) NSString * uniqueID;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * updateDate;

@end
