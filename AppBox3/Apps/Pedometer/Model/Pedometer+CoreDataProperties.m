//
//  Pedometer+CoreDataProperties.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 5/12/16.
//  Copyright © 2016 ALLABOUTAPPS. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Pedometer+CoreDataProperties.h"

@implementation Pedometer (CoreDataProperties)

@dynamic uniqueID;
@dynamic date;
@dynamic numberOfSteps;
@dynamic distance;
@dynamic floorsAscended;
@dynamic floorsDescended;

@end
