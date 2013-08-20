//
//  A3TranslatorFavoriteDataSource.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/20/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TranslatorHistory;

@protocol A3TranslatorFavoriteDelegate <NSObject>
- (void)translatorFavoriteItemSelected:(TranslatorHistory *)item;
@end

@interface A3TranslatorFavoriteDataSource : NSObject<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) id<A3TranslatorFavoriteDelegate> delegate;

- (void)resetData;
@end
