//
//  TranslatorFavorite.h
//  AppBox3
//
//  Created by A3 on 7/18/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface TranslatorFavorite : NSManagedObject

@property (nonatomic, retain) NSString * groupID;
@property (nonatomic, retain) NSString * historyID;
@property (nonatomic, retain) NSString * order;
@property (nonatomic, retain) NSString * uniqueID;
@property (nonatomic, retain) NSDate * updateDate;

@end
