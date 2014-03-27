//
//  A3TableViewSelectElement.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 10/22/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3TableViewElement.h"

@interface A3TableViewSelectElement : A3TableViewElement

@property (nonatomic) NSInteger selectedIndex;
@property (nonatomic, strong) NSArray *items;

@end
