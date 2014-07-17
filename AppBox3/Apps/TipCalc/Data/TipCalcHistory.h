//
//  TipCalcHistory.h
//  AppBox3
//
//  Created by A3 on 7/18/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface TipCalcHistory : NSManagedObject

@property (nonatomic, retain) NSString * labelTip;
@property (nonatomic, retain) NSString * labelTotal;
@property (nonatomic, retain) NSString * uniqueID;
@property (nonatomic, retain) NSDate * updateDate;

@end
