//
//  MenuItem.h
//  AppBoxPro2
//
//  Created by Byeong Kwon Kwak on 6/4/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MenuGroup;

@interface MenuItem : NSManagedObject

@property (nonatomic, retain) NSString * menu_id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * order;
@property (nonatomic, retain) MenuGroup *menuGroup;

@end
