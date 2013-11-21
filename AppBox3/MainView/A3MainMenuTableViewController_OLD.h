//
//  A3MainMenuTableViewController_OLD.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 10/23/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

#define A3_MENU_TABLE_VIEW_SECTION_HEIGHT	44.0f

typedef enum NSUInteger {
	A3_MENU_TABLE_VIEW_SECTION_SHORTCUT = 0,
	A3_MENU_TABLE_VIEW_SECTION_FAVORITES,
	A3_MENU_TABLE_VIEW_SECTION_APPS,
	A3_MENU_TABLE_VIEW_SECTION_SETTINGS,
	A3_MENU_TABLE_VIEW_SECTION_INFORMATION
}  A3_MENU_TABLE_VIEW_SECTION_TYPE;

@interface A3MainMenuTableViewController_OLD : UITableViewController

@end
