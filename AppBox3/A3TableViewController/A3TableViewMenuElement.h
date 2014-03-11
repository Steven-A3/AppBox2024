//
//  A3TableViewMenuElement.h
//  AppBox3
//
//  Created by A3 on 1/5/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "A3TableViewElement.h"

@interface A3TableViewMenuElement : A3TableViewElement

@property (nonatomic, copy) NSString *className;
@property (nonatomic, copy) NSString *storyboardName_iPhone;
@property (nonatomic, copy) NSString *storyboardName_iPad;
@property (nonatomic, copy) NSString *nibName;
@property (nonatomic, assign) BOOL needSecurityCheck;
@property (nonatomic, assign) BOOL doNotKeepAsRecent;

@end
