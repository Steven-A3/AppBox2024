//
//  A3CurrencySettingsViewController.h
//  AppBox3
//
//  Created by A3 on 11/20/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol A3CurrencySettingsDelegate <NSObject>

- (void)currencyConfigurationChanged;

@end

@interface A3CurrencySettingsViewController : UITableViewController

@property (nonatomic, weak) id<A3CurrencySettingsDelegate> delegate;

@end
