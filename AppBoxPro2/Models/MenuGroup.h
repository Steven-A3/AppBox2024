//
//  MenuGroup.h
//  AppBoxPro2
//
//  Created by Byeong Kwon Kwak on 6/4/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MenuItem;

@interface MenuGroup : NSManagedObject

@property (nonatomic, retain) NSString * group_id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * order;
@property (nonatomic, retain) NSSet *menus;
@end

@interface MenuGroup (CoreDataGeneratedAccessors)

- (void)addMenusObject:(MenuItem *)value;
- (void)removeMenusObject:(MenuItem *)value;
- (void)addMenus:(NSSet *)values;
- (void)removeMenus:(NSSet *)values;

@end
