//
//  A3WalletEditFieldViewController.h
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 21..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WalletField;

@protocol WalletEditFieldDelegate <NSObject>

@required
- (void)walletFieldEdited:(WalletField *)field;

@optional
- (void)walletFieldAdded:(WalletField *)field;
- (void)dismissedViewController:(UIViewController *)viewController;

@end

@interface A3WalletEditFieldViewController : UITableViewController

@property (nonatomic, assign) id<WalletEditFieldDelegate> delegate;
@property (nonatomic, strong) WalletField *field;
@property (readwrite) BOOL isAddMode;

@end
