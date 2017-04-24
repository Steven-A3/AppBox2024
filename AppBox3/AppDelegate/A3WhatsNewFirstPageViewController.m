//
//  A3WhatsNewFirstPageViewController.m
//  AppBox3
//
//  Created by BYEONG KWON KWAK on 3/20/17.
//  Copyright © 2017 ALLABOUTAPPS. All rights reserved.
//

#import "A3WhatsNewFirstPageViewController.h"
#import "BEMCheckBox.h"

extern NSString *const A3UserDefaultsDidAlertWhatsNew4_5;

@interface A3WhatsNewFirstPageViewController () <BEMCheckBoxDelegate>

@property (nonatomic, weak) IBOutlet BEMCheckBox *checkBox;
@property (nonatomic, weak) IBOutlet UILabel *doNotShowLabel;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *abbreviationsAppNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *kaomojiAppNameLabel;
@property (nonatomic, weak) IBOutlet UIImageView *closeImageView;

@end

@implementation A3WhatsNewFirstPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    _checkBox.animationDuration = 0.6;
    _checkBox.onAnimationType = BEMAnimationTypeFill;
    _checkBox.offAnimationType = BEMAnimationTypeBounce;
    _checkBox.boxType = BEMBoxTypeSquare;
    _checkBox.delegate = self;
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:A3UserDefaultsDidAlertWhatsNew4_5]) {
        _checkBox.hidden = YES;
        _doNotShowLabel.hidden = YES;
    }
    
    NSString *fontName;
    BOOL isLanguageLikeCJK = [A3UIDevice isLanguageLikeCJK];
    if (isLanguageLikeCJK) {
        UIFont *systemFont = [UIFont systemFontOfSize:10];
        fontName = systemFont.fontName;
    } else {
        fontName = @"Chalkduster";
    }
    if (IS_IPAD) {
        _titleLabel.font = [UIFont fontWithName:fontName size:50];
        _abbreviationsAppNameLabel.font = [UIFont fontWithName:fontName size:30];
        _kaomojiAppNameLabel.font = [UIFont fontWithName:fontName size:30];
        _doNotShowLabel.font = [UIFont fontWithName:fontName size:20];
    } else if (isLanguageLikeCJK) {
        _titleLabel.font = [UIFont fontWithName:fontName size:_titleLabel.font.pointSize];
    }
    _closeImageView.image = [[UIImage imageNamed:@"delete03"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _closeImageView.tintColor = [UIColor whiteColor];
    
    UITapGestureRecognizer *closeImageTapGestureRecognizer =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(didTapCloseImage)];
    [_closeImageView addGestureRecognizer:closeImageTapGestureRecognizer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didTapCloseImage {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)didPressNextButton:(id)sender {
    _nextButtonAction();
}

- (IBAction)didTapDoNotShowNextTime:(id)sender {
    [_checkBox setOn:!_checkBox.on animated:YES];
    [self didTapCheckBox:_checkBox];
}

- (void)didTapCheckBox:(BEMCheckBox *)checkBox {
    if (checkBox.on) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:A3UserDefaultsDidAlertWhatsNew4_5];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:A3UserDefaultsDidAlertWhatsNew4_5];
    }
}

@end
