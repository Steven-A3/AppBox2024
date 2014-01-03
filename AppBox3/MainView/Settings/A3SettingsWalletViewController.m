//
//  A3SettingsWalletViewController.m
//  AppBox3
//
//  Created by A3 on 12/22/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3SettingsWalletViewController.h"

@interface A3SettingsWalletViewController ()

@end

@implementation A3SettingsWalletViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	self.title = NSLocalizedString(@"Wallet", @"Title for Wallet section in Settings");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
