//
//  A3WalletIconSelectViewController.h
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 21..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WalletIconSelectDelegate <NSObject>

@required
- (void)walletIconSelected:(NSString *)iconName;

@optional
- (void)dismissedWalletIconController:(UIViewController *)viewController;

@end

@interface A3WalletIconSelectViewController : UIViewController

@property (nonatomic, weak) id<WalletIconSelectDelegate> delegate;
@property (nonatomic, strong) NSString *selecteIconName;

@end
