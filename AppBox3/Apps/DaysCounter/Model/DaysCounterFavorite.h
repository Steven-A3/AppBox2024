//
//  DaysCounterFavorite.h
//  AppBox3
//
//  Created by A3 on 5/26/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DaysCounterEvent;

@interface DaysCounterFavorite : NSManagedObject

@property (nonatomic, retain) NSString * order;
@property (nonatomic, retain) DaysCounterEvent *event;

@end
