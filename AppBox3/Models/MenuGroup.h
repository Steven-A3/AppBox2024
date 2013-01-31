//
//  MenuGroup.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 1/29/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MenuItem;

@interface MenuGroup : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * order;
@property (nonatomic, retain) NSString * menuGroupID;
@property (nonatomic, retain) NSSet *menuItems;
@end

@interface MenuGroup (CoreDataGeneratedAccessors)

- (void)addMenuItemsObject:(MenuItem *)value;
- (void)removeMenuItemsObject:(MenuItem *)value;
- (void)addMenuItems:(NSSet *)values;
- (void)removeMenuItems:(NSSet *)values;

@end
