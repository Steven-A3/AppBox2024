//
//  UIViewController+UnitConverter.m
//  A3TeamWork
//
//  Created by kihyunkim on 13. 10. 22..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "UIViewController+UnitConverter.h"
#import "UnitFavorite.h"

@implementation UIViewController (UnitConverter)

- (BOOL)isFavoriteItemForUnitItem:(id)object
{
    NSArray *result = [UnitFavorite MR_findByAttribute:@"item" withValue:object];
	return [result count] > 0;
}

@end
