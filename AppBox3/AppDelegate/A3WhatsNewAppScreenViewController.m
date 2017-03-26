//
//  A3WhatsNewAppScreenViewController.m
//  AppBox3
//
//  Created by BYEONG KWON KWAK on 14/03/2017.
//  Copyright © 2017 ALLABOUTAPPS. All rights reserved.
//

#import "A3WhatsNewAppScreenViewController.h"
#import "A3AbbreviationViewController.h"
#import "A3KaomojiViewController.h"
#import "NYXImagesKit.h"
#import "A3AppDelegate.h"
#import "UIView+SBExtras.h"

@interface A3WhatsNewAppScreenViewController ()

@property (nonatomic, weak) IBOutlet UIView *screenImageFrameView;
@property (nonatomic, weak) IBOutlet UIImageView *screenImageView;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *screenImageViewAspectRatioConstraint;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *screenImageFrameViewAspectRatioConstraint;

@end

@implementation A3WhatsNewAppScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor clearColor];
    
    _screenImageFrameView.layer.cornerRadius = 10;
    
    CGFloat topOffset = SCREEN_WIDTH < 375 ? 44 : 64;

    [_screenImageFrameView removeConstraint:_screenImageFrameViewAspectRatioConstraint];
    _screenImageFrameViewAspectRatioConstraint =
    [NSLayoutConstraint constraintWithItem:_screenImageFrameView
                                 attribute:NSLayoutAttributeWidth
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:_screenImageFrameView
                                 attribute:NSLayoutAttributeHeight
                                multiplier:SCREEN_WIDTH / (SCREEN_HEIGHT - topOffset)
                                  constant:0];
    [_screenImageFrameView addConstraint:_screenImageFrameViewAspectRatioConstraint];
    
    [_screenImageView removeConstraint:_screenImageViewAspectRatioConstraint];
    _screenImageViewAspectRatioConstraint =
    [NSLayoutConstraint constraintWithItem:_screenImageView
                                 attribute:NSLayoutAttributeWidth
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:_screenImageView
                                 attribute:NSLayoutAttributeHeight
                                multiplier:SCREEN_WIDTH / SCREEN_HEIGHT
                                  constant:0];
    [_screenImageView addConstraint:_screenImageViewAspectRatioConstraint];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showAbbreviationSnapshotView {
    A3AbbreviationViewController *viewController = [A3AbbreviationViewController storyboardInstance];
    viewController.view.bounds = self.view.bounds;
    [viewController viewWillLayoutSubviews];
    [viewController.view layoutIfNeeded];
    _screenShotImageView.image = [viewController.view imageByRenderingView];
    FNLOG(@"%f, %f", _screenShotImageView.image.size.width, _screenShotImageView.image.size.height);
}

- (void)showKaomojiSnapshotView {
    A3KaomojiViewController *viewController = [A3KaomojiViewController storyboardInstance];
    viewController.view.bounds = self.view.bounds;
    [viewController viewWillLayoutSubviews];
    [viewController.view layoutIfNeeded];
    _screenShotImageView.image = [viewController.view imageByRenderingView];
    FNLOG(@"%f, %f", _screenShotImageView.image.size.width, _screenShotImageView.image.size.height);
}

- (IBAction)didPressNextButton:(id)sender {
    _nextButtonAction();
}

- (IBAction)didPressDoneButton:(id)sender {
    _doneButtonAction();
}

@end
