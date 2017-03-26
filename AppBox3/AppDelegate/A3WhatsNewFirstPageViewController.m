//
//  A3WhatsNewFirstPageViewController.m
//  AppBox3
//
//  Created by BYEONG KWON KWAK on 3/20/17.
//  Copyright © 2017 ALLABOUTAPPS. All rights reserved.
//

#import "A3WhatsNewFirstPageViewController.h"
#import "BEMCheckBox.h"

@interface A3WhatsNewFirstPageViewController ()

@property (nonatomic, weak) IBOutlet BEMCheckBox *checkBox;

@end

@implementation A3WhatsNewFirstPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    _checkBox.animationDuration = 0.6;
    _checkBox.onAnimationType = BEMAnimationTypeFill;
    _checkBox.offAnimationType = BEMAnimationTypeBounce;
    _checkBox.boxType = BEMBoxTypeSquare;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didPressNextButton:(id)sender {
    _nextButtonAction();
}

@end
