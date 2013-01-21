//
//  MenuItem.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 1/16/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MenuGroup;

@interface MenuItem : NSManagedObject

@property (nonatomic, retain) NSString * iconName;
@property (nonatomic, retain) NSString * unique_id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) MenuGroup *group;
@property (nonatomic, retain) NSManagedObject *favorite;

@end
