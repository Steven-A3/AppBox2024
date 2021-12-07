//
//  WalletFavorite.m
//  AppBox3
//
//  Created by A3 on 7/18/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "WalletHistoryItems.h"
#import "A3UserDefaults.h"

NSString *const kWalletHistoryItemID = @"itemID";
NSString *const kWalletHistoryAccessTime = @"accessTime";
NSString *const kWalletHistoryItems = @"kA3WalletHistoryItems";

@implementation WalletHistoryItems

- (void)addHistory:(NSString *)itemID {
    NSArray *historyItems = [[A3UserDefaults standardUserDefaults] objectForKey:kWalletHistoryItems];
    NSMutableArray *mutableHistory;
    if (historyItems == nil) {
        mutableHistory = [[NSMutableArray alloc] init];
    } else {
        mutableHistory = [historyItems mutableCopy];
    }
    NSInteger idx = [mutableHistory indexOfObjectPassingTest:^BOOL(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return [obj[kWalletHistoryItemID] isEqualToString:itemID];
    }];
    if (idx != NSNotFound) {
        [mutableHistory removeObjectAtIndex:idx];
    }
    [mutableHistory addObject:@{
        kWalletHistoryItemID: itemID,
        kWalletHistoryAccessTime : [NSDate date]
    }];
    if ([mutableHistory count] > 100) {
        [mutableHistory removeObjectAtIndex:0];
    }
    [[A3UserDefaults standardUserDefaults] setObject:mutableHistory forKey:kWalletHistoryItems];
    [[A3UserDefaults standardUserDefaults] synchronize];
}

- (NSArray *)historyItems {
    return [[A3UserDefaults standardUserDefaults] objectForKey:kWalletHistoryItems];
}

@end
