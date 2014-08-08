//
//  A3WalletFieldTypeSelectViewController.h
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 21..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WalletFieldTypeSelectDelegate <NSObject>

@required
- (void)walletFieldSelectedFieldType:(NSString *)fieldType;
@end

@interface A3WalletFieldTypeSelectViewController : UITableViewController

@property (nonatomic, assign) NSString *selectedType;
@property (nonatomic, weak) id<WalletFieldTypeSelectDelegate> delegate;

@end
