//
//  A3WalletAddCateWrapViewController.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 25..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3WalletAddCateWrapViewController.h"
#import "A3WalletAddCateViewController.h"

@interface A3WalletAddCateWrapViewController ()

@end

@implementation A3WalletAddCateWrapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    NSString *nibName = (IS_IPHONE) ? @"WalletPhoneStoryBoard" : @"WalletPadStoryBoard";
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:nibName bundle:nil];
    A3WalletAddCateViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"A3WalletAddCateViewController"];
    
    [self presentViewController:vc animated:NO completion:NULL];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
