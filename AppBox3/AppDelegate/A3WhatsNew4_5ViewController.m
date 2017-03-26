//
//  A3WhatsNew4_5ViewController.m
//  AppBox3
//
//  Created by BYEONG KWON KWAK on 13/03/2017.
//  Copyright © 2017 ALLABOUTAPPS. All rights reserved.
//

#import "A3WhatsNew4_5ViewController.h"
#import "A3WhatsNew4_5PageViewController.h"
#import "FXBlurView.h"
#import "BEMCheckBox.h"

@interface A3WhatsNew4_5ViewController ()

@property (nonatomic, weak) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, weak) IBOutlet BEMCheckBox *checkBox;
@property (nonatomic, strong) A3WhatsNew4_5PageViewController *pageViewController;

@end

@implementation A3WhatsNew4_5ViewController

+ (A3WhatsNew4_5ViewController *)storyboardInstanceWithImage:(UIImage *)bgImage {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"WhatsNew4_5" bundle:nil];
    A3WhatsNew4_5ViewController *viewController = [storyboard instantiateInitialViewController];
    [viewController view];      // Load the view
    viewController.backgroundImageView.image = bgImage;
    return viewController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    _checkBox.animationDuration = 0.2;
    _checkBox.boxType = BEMBoxTypeSquare;
    _checkBox.onAnimationType = BEMAnimationTypeBounce;
    _checkBox.offAnimationType = BEMAnimationTypeBounce;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[UIPageViewController class]]) {
        _pageViewController = segue.destinationViewController;
        __typeof(self) __weak weakSelf = self;
        _pageViewController.dismissBlock = ^{
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
        };
    }
    [super prepareForSegue:segue sender:sender];
}

@end
