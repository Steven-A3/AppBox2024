//
//  UnitFavorite+initialize.h
//  A3TeamWork
//
//  Created by kihyunkim on 13. 10. 17..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "UnitFavorite.h"

@class UnitItem;

@interface UnitFavorite (extension)

+ (void)reset;

- (UnitItem *)item;
@end
