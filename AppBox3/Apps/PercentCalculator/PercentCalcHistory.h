//
//  PercentCalcHistory.h
//  AppBox3
//
//  Created by A3 on 7/1/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface PercentCalcHistory : NSManagedObject

@property (nonatomic, retain) NSData * historyItem;
@property (nonatomic, retain) NSDate * updateDate;
@property (nonatomic, retain) NSString * uniqueID;

@end
