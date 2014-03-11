//
//  WalletFieldItem+initialize.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 12. 4..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "WalletFieldItem+initialize.h"
#import "WalletField.h"
#import "WalletData.h"

@implementation WalletFieldItem (initialize)

- (void)deleteAndClearRelated
{
    if ([self.field.type isEqualToString:WalletFieldTypeImage]) {
        if (self.filePath.length > 0) {
            NSString *thumbPath = [WalletData thumbImgPathOfImgPath:self.filePath];
            [WalletData deleteFileAtPath:self.filePath];
            [WalletData deleteFileAtPath:thumbPath];
        }
    }
    else if ([self.field.type isEqualToString:WalletFieldTypeVideo]) {
        if (self.filePath.length > 0) {
            NSString *thumbPath = [WalletData thumbImgPathOfVideoPath:self.filePath];
            [WalletData deleteFileAtPath:self.filePath];
            [WalletData deleteFileAtPath:thumbPath];
        }
    }
    
    [self MR_deleteEntity];

	[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
}

@end
