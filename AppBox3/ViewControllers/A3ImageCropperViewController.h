//
//  A3ImageCropperViewController.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 9/14/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol A3ImageCropperDelegate;

@interface A3ImageCropperViewController : UIViewController

@property (nonatomic, weak) id<A3ImageCropperDelegate> delegate;

- (instancetype)initWithImage:(UIImage *)image withHudView:(UIView *)hudView;
@end

@protocol A3ImageCropperDelegate <NSObject>
- (void)imageCropper:(A3ImageCropperViewController *)cropper didFinishCroppingWithImage:(UIImage *)image;
- (void)imageCropperDidCancel:(A3ImageCropperViewController *)cropper;
@end
