//
//  A3OpenSourceLicensesViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 3/24/15.
//  Copyright (c) 2015 ALLABOUTAPPS. All rights reserved.
//

#import "A3OpenSourceLicensesViewController.h"

@interface A3OpenSourceLicensesViewController ()

@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation A3OpenSourceLicensesViewController

- (void)viewDidLoad {
    [super viewDidLoad];

//	self.title = NSLocalizedString(@"Open Source Licenses", @"Open Source Licenses");
	NSString *path = [[NSBundle mainBundle] pathForResource:@"openSourceLicenses" ofType:@"txt"];
	NSString *contents = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
	self.textView.text = contents;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	if ([self.navigationController.navigationBar isHidden]) {
		[self.navigationController setNavigationBarHidden:NO animated:NO];
	}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
