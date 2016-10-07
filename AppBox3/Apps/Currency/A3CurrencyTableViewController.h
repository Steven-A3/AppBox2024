//
//  A3CurrencyTableViewController.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 7/5/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3FMMoveTableViewController.h"

@class A3CurrencyDataManager;
@class A3CurrencyViewController;

extern NSString *const A3CurrencyDataCellID;
extern NSString *const A3CurrencySettingsChangedNotification;

@interface A3CurrencyTableViewController : A3FMMoveTableViewController

@property (nonatomic, weak) A3CurrencyDataManager *currencyDataManager;
@property (nonatomic, weak) A3CurrencyViewController *mainViewController;

- (void)enableControls:(BOOL)enable;
- (void)resetIntermediateState;
- (void)showInstructionView;

- (void)dismissNumberKeyboardAnimated:(BOOL)animated;
@end
