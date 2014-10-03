//
//  A3CameraViewController.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 10/3/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface A3CameraViewController : UIViewController

@property (nonatomic, strong) UIButton *lastimageButton;

- (UIImage *)cropImageWithSquare:(UIImage *)source;
- (void)loadFirstPhoto;

- (void)setImageOnCameraRollButton:(UIImage *)image;
- (IBAction)loadCameraRoll:(id)sender;
- (void)notifyCameraShotSaveRule;

@end
