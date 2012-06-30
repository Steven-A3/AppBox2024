//
//  MenuItem.h
//  AppBoxProPrepareData
//
//  Created by Byeong Kwon Kwak on 6/22/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MenuGroup;

@interface MenuItem : NSManagedObject

@property (nonatomic, retain) NSString * iconName;
@property (nonatomic, retain) NSString * menuID;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * order;
@property (nonatomic, retain) NSNumber * isFavorite;
@property (nonatomic, retain) MenuGroup *menuGroup;

@end
