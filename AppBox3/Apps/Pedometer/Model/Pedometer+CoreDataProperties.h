//
//  Pedometer+CoreDataProperties.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 5/12/16.
//  Copyright © 2016 ALLABOUTAPPS. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Pedometer.h"

NS_ASSUME_NONNULL_BEGIN

@interface Pedometer (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *uniqueID;
@property (nullable, nonatomic, retain) NSString *date;
@property (nullable, nonatomic, retain) NSNumber *numberOfSteps;
@property (nullable, nonatomic, retain) NSNumber *distance;
@property (nullable, nonatomic, retain) NSNumber *floorsAscended;
@property (nullable, nonatomic, retain) NSNumber *floorsDescended;

@end

NS_ASSUME_NONNULL_END
