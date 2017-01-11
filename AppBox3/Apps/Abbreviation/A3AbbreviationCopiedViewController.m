//
//  A3AbbreviationCopiedViewController.m
//  AppBox3
//
//  Created by Byeong-Kwon Kwak on 1/7/17.
//  Copyright © 2017 ALLABOUTAPPS. All rights reserved.
//

#import "A3AbbreviationCopiedViewController.h"

@interface A3AbbreviationCopiedViewController ()

@end

@implementation A3AbbreviationCopiedViewController

+ (A3AbbreviationCopiedViewController *)storyboardInstance {
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Abbreviation" bundle:nil];
	return [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Pattern_Dots"]];
	
	UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureHandler:)];
	[self.view addGestureRecognizer:gestureRecognizer];
}

- (void)tapGestureHandler:(UITapGestureRecognizer *)gesture {
	[self.view removeFromSuperview];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
