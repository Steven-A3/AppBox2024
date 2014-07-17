//
//  UnitItem+initialize.h
//  A3TeamWork
//
//  Created by kihyunkim on 13. 10. 16..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "UnitItem.h"

@class UnitType;

@interface UnitItem (extension)

+ (void)resetUnitItemLists;

- (UnitType *)type;
@end
