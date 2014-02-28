//
//  PercentCalcHistory.h
//  A3TeamWork
//
//  Created by jeonghwan kim on 13. 11. 20..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface PercentCalcHistory : NSManagedObject

@property (nonatomic, retain) NSDate * historyDate;
@property (nonatomic, retain) NSData * historyItem;

@end
