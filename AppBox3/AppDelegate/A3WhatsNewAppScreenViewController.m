//
//  A3WhatsNewAppScreenViewController.m
//  AppBox3
//
//  Created by BYEONG KWON KWAK on 14/03/2017.
//  Copyright © 2017 ALLABOUTAPPS. All rights reserved.
//

#import <AppBoxKit/AppBoxKit.h>
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
@property (nonatomic, strong) UIViewController *currentImageViewController;
@property (nonatomic, weak) IBOutlet UIImageView *closeImageView;
@property (nonatomic, weak) IBOutlet UILabel *textLabel1;
@property (nonatomic, weak) IBOutlet UILabel *textLabel2;

@end

@implementation A3WhatsNewAppScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor clearColor];
    
    _screenImageFrameView.layer.cornerRadius = 10;

    [self setupConstraintWithSize:[UIScreen mainScreen].bounds.size];

    _closeImageView.image = [[UIImage imageNamed:@"delete03"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _closeImageView.tintColor = [UIColor whiteColor];
    
    UITapGestureRecognizer *closeImageTapGestureRecognizer =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(didTapCloseImage)];
    [_closeImageView addGestureRecognizer:closeImageTapGestureRecognizer];
    
    NSString *fontName;
    BOOL isLanguageLikeCJK = [A3UIDevice isLanguageLikeCJK];
    if (isLanguageLikeCJK) {
        UIFont *systemFont = [UIFont systemFontOfSize:10];
        fontName = systemFont.fontName;
    } else {
        fontName = @"Chalkduster";
    }
    if (IS_IPAD) {
        _textLabel1.font = [UIFont fontWithName:fontName size:26];
        _textLabel2.font = [UIFont fontWithName:fontName size:26];
    } else if (isLanguageLikeCJK) {
        _textLabel1.font = [UIFont fontWithName:fontName size:_textLabel1.font.pointSize];
        _textLabel2.font = [UIFont fontWithName:fontName size:_textLabel2.font.pointSize];
    }
    if (IS_IPHONE_3_5_INCH || IS_IPHONE_4_INCH) {
        _textLabel1.font = [UIFont fontWithName:fontName size:17];
        _textLabel2.font = [UIFont fontWithName:fontName size:17];
    }
}

- (void)didTapCloseImage {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillLayoutSubviews {
    
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    [self setupConstraintWithSize:size];
    [self.view layoutIfNeeded];
    
    if (_currentImageViewController) {
        _currentImageViewController.view.bounds = CGRectMake(0, 0, size.width, size.height);
        [_currentImageViewController viewWillLayoutSubviews];
        [_currentImageViewController.view layoutIfNeeded];
        _screenShotImageView.image = [_currentImageViewController.view imageByRenderingView];
    }
}

- (void)setupConstraintWithSize:(CGSize)size {

    CGFloat topOffset;
    if (IS_IPHONE) {
        topOffset = size.width < 375 ? 44 : 64;
    } else {
        topOffset = 54;
    }

    [_screenImageFrameView removeConstraint:_screenImageFrameViewAspectRatioConstraint];
    _screenImageFrameViewAspectRatioConstraint =
    [NSLayoutConstraint constraintWithItem:_screenImageFrameView
                                 attribute:NSLayoutAttributeWidth
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:_screenImageFrameView
                                 attribute:NSLayoutAttributeHeight
                                multiplier:size.width / (size.height - topOffset)
                                  constant:0];
    [_screenImageFrameView addConstraint:_screenImageFrameViewAspectRatioConstraint];
    
    [_screenImageView removeConstraint:_screenImageViewAspectRatioConstraint];
    _screenImageViewAspectRatioConstraint =
    [NSLayoutConstraint constraintWithItem:_screenImageView
                                 attribute:NSLayoutAttributeWidth
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:_screenImageView
                                 attribute:NSLayoutAttributeHeight
                                multiplier:size.width / size.height
                                  constant:0];
    [_screenImageView addConstraint:_screenImageViewAspectRatioConstraint];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showAbbreviationSnapshotView {
    A3AbbreviationViewController *viewController = [A3AbbreviationViewController storyboardInstance];
    viewController.doNotShowHelpView = YES;
    viewController.view.bounds = self.view.bounds;
    [viewController viewWillLayoutSubviews];
    [viewController.view layoutIfNeeded];
    _screenShotImageView.image = [viewController.view imageByRenderingView];
    _currentImageViewController = viewController;
    FNLOG(@"%f, %f", _screenShotImageView.image.size.width, _screenShotImageView.image.size.height);
}

- (void)showKaomojiSnapshotView {
    A3KaomojiViewController *viewController = [A3KaomojiViewController storyboardInstance];
    viewController.view.bounds = self.view.bounds;
    [viewController viewWillLayoutSubviews];
    [viewController.view layoutIfNeeded];
    _screenShotImageView.image = [viewController.view imageByRenderingView];
    _currentImageViewController = viewController;
    FNLOG(@"%f, %f", _screenShotImageView.image.size.width, _screenShotImageView.image.size.height);
}

- (IBAction)didPressNextButton:(id)sender {
    _nextButtonAction();
}

- (IBAction)didPressDoneButton:(id)sender {
    _doneButtonAction();
}

@end
