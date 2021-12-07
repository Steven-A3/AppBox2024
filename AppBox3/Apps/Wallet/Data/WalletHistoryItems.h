//
//  WalletFavorite.h
//  AppBox3
//
//  Created by A3 on 7/18/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kWalletHistoryItemID;
extern NSString *const kWalletHistoryAccessTime;

@interface WalletHistoryItems : NSObject

- (void)addHistory:(NSString *)itemId;
- (NSArray *)historyItems;

@end
