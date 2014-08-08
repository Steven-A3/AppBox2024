//
//  A3WalletFieldStyleSelectViewController.h
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 22..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WalletFieldStyleSelectDelegate <NSObject>

@required
- (void)walletFieldStyleSelected:(NSString *)fieldStyle;

@end
@interface A3WalletFieldStyleSelectViewController : UITableViewController

@property (nonatomic, strong) NSString *typeName;
@property (nonatomic, strong) NSString *selectedStyle;
@property (nonatomic, weak) id<WalletFieldStyleSelectDelegate> delegate;

@end
