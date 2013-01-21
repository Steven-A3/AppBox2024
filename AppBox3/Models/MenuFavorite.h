//
//  MenuFavorite.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 1/16/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MenuItem;

@interface MenuFavorite : NSManagedObject

@property (nonatomic, retain) NSString * order;
@property (nonatomic, retain) MenuItem *menuItem;

@end
