//
//  MenuItem.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 1/29/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MenuFavorite, MenuGroup;

@interface MenuItem : NSManagedObject

@property (nonatomic, retain) NSString * iconName;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * appID;
@property (nonatomic, retain) MenuFavorite *favorite;
@property (nonatomic, retain) MenuGroup *group;

@end
