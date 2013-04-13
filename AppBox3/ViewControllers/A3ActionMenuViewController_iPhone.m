//
//  A3ActionMenuViewController_iPad.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 2/8/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3ActionMenuViewController_iPhone.h"
#import "A3ActionMenuViewControllerDelegate.h"

@interface A3ActionMenuViewController_iPhone ()

@end

@implementation A3ActionMenuViewController_iPhone

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

- (IBAction)newListAction {
	if ([_delegate respondsToSelector:@selector(newListAction)]) {
		[_delegate settingsAction];
	}
}

- (IBAction)showHistoryAction {
	if ([_delegate respondsToSelector:@selector(showHistoryAction)]) {
		[_delegate emailAction];
	}
}

- (IBAction)shareAction {
	if ([_delegate respondsToSelector:@selector(shareAction)]) {
		[_delegate messageAction];
	}
}

@end
