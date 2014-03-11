//
//  UnitHistoryItem.h
//  AppBox3
//
//  Created by A3 on 3/11/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class UnitHistory, UnitItem;

@interface UnitHistoryItem : NSManagedObject

@property (nonatomic, retain) NSString * order;
@property (nonatomic, retain) UnitHistory *history;
@property (nonatomic, retain) UnitItem *unit;

@end
