//
//  WalletCategory.h
//  AppBox3
//
//  Created by A3 on 8/16/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface WalletCategory : NSManagedObject

@property (nonatomic, retain) NSString * uniqueID;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * doNotShow;
@property (nonatomic, retain) NSNumber * isSystem;
@property (nonatomic, retain) NSString * icon;
@property (nonatomic, retain) NSString * order;

@end
