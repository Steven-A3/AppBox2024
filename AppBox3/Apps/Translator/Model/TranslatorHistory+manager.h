//
//  TranslatorHistory(manager)
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 2/28/14 6:08 PM.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TranslatorHistory.h"

@class TranslatorFavorite;

@interface TranslatorHistory (manager)
- (TranslatorFavorite *)favorite;

- (void)setAsFavoriteMember:(BOOL)isFavorite;
@end
