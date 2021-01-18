//
//  A3HomeStyleHelpViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 3/20/16.
//  Copyright © 2016 ALLABOUTAPPS. All rights reserved.
//

#import "A3HomeStyleHelpViewController.h"

@interface A3HomeStyleHelpViewController ()

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *topSpaceConstraint;

@end

@implementation A3HomeStyleHelpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIEdgeInsets safeAreaInsets = [[UIApplication sharedApplication] keyWindow].safeAreaInsets;
    if (safeAreaInsets.top > 20) {
        _topSpaceConstraint.constant = safeAreaInsets.top - 20;
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
