//
//  A3PasswordViewController.h
//  AppBox3
//
//  Created by A3 on 12/28/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "A3PasscodeViewControllerProtocol.h"

@interface A3PasswordViewController : UITableViewController <A3PasscodeViewControllerProtocol>

@property (nonatomic, weak) id<A3PasscodeViewControllerDelegate> delegate;

- (id)initWithDelegate:(id <A3PasscodeViewControllerDelegate>)delegate;
@end
