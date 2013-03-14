//
//  A3ActionMenuViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 2/8/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3ActionMenuViewController.h"

@interface A3ActionMenuViewController ()

@end

@implementation A3ActionMenuViewController

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
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)settingsAction {
	if ([_delegate respondsToSelector:@selector(settingsAction)]) {
		[_delegate settingsAction];
	}
}

- (IBAction)emailAction {
	if ([_delegate respondsToSelector:@selector(emailAction)]) {
		[_delegate emailAction];
	}
}

- (IBAction)messageAction {
	if ([_delegate respondsToSelector:@selector(messageAction)]) {
		[_delegate messageAction];
	}
}

- (IBAction)twitterAction {
	if ([_delegate respondsToSelector:@selector(twitterAction)]) {
		[_delegate twitterAction];
	}
}

- (IBAction)facebookAction {
	if ([_delegate respondsToSelector:@selector(facebookAction)]) {
		[_delegate facebookAction];
	}
}

@end
