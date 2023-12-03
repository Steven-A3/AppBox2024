//
//  JVFloatLabeledTextField+A3PasswordTextField.h
//  AppBox3
//
//  Created by BYEONG KWON KWAK on 2023/03/03.
//  Copyright © 2023 ALLABOUTAPPS. All rights reserved.
//

#import "A3FloatLabeledPasswordTextField.h"
#import "A3AppDelegate.h"
#import "A3UserDefaults+A3Addition.h"

@implementation A3FloatLabeledPasswordTextField

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    self.secureTextEntry = YES;
    self.rightViewMode = UITextFieldViewModeAlways;
    
    UIButton *eyeOnOffButton = [UIButton buttonWithType:UIButtonTypeSystem];
    eyeOnOffButton.frame = CGRectMake(0, 0, 34, 34);
    [eyeOnOffButton setImage:[self imageForEyeButton] forState:UIControlStateNormal];
    [eyeOnOffButton.widthAnchor constraintEqualToConstant:34].active = YES;
    [eyeOnOffButton.heightAnchor constraintEqualToConstant:34].active = YES;
    eyeOnOffButton.tintColor = [[A3UserDefaults standardUserDefaults] themeColor];
    [eyeOnOffButton sizeToFit];
    [eyeOnOffButton addTarget:self action:@selector(eyeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    self.rightView = eyeOnOffButton;
}

- (UIImage *)imageForEyeButton {
    if (self.secureTextEntry) {
        return [UIImage imageNamed:@"eye-off-outline"];
    }
    return [UIImage imageNamed:@"eye-outline"];
}

- (void)eyeButtonPressed:(UIButton *)eyeButton {
    self.secureTextEntry = !self.secureTextEntry;
    
    [eyeButton setImage:[self imageForEyeButton] forState:UIControlStateNormal];
}

@end
