//
//  A3TranslatorFavoriteDataSource.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/20/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMMoveTableView.h"

@class TranslatorFavorite;

@protocol A3TranslatorFavoriteDelegate <NSObject>
- (void)translatorFavoriteItemSelected:(TranslatorFavorite *)item;
@end

@interface A3TranslatorFavoriteDataSource : NSObject<FMMoveTableViewDelegate, FMMoveTableViewDataSource>

@property (nonatomic, weak) id<A3TranslatorFavoriteDelegate> delegate;

- (void)resetData;
@end
