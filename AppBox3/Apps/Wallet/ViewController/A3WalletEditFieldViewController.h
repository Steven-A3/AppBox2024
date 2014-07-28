//
//  A3WalletEditFieldViewController.h
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 21..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WalletEditFieldDelegate <NSObject>

@required
- (void)walletFieldEdited:(NSDictionary *)field;

@optional
- (void)walletFieldAdded:(NSDictionary *)field;
- (void)dismissedViewController:(UIViewController *)viewController;

@end

@interface A3WalletEditFieldViewController : UITableViewController

@property (nonatomic, weak) id<WalletEditFieldDelegate> delegate;
@property (nonatomic, weak) NSArray *fields;
@property (nonatomic, strong) NSMutableDictionary *field;
@property (readwrite) BOOL isAddMode;

@end
