//
//  A3FlashViewController.h
//  AppBox3
//
//  Created by kimjeonghwan on 9/24/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

extern NSString *const A3UserDefaultFlashViewMode;

@interface A3FlashViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIToolbar *topMenuToolbar;
@property (weak, nonatomic) IBOutlet UIView *subMenuPanelView;
@property (weak, nonatomic) IBOutlet UISlider *sliderControl;
@property (weak, nonatomic) IBOutlet UIImageView *contentImageView;
@property (weak, nonatomic) IBOutlet UIButton *lightOffButton;
@property (weak, nonatomic) IBOutlet UICollectionView *effectListCollectionView;

- (IBAction)exitBarButtonAction:(id)sender;
- (IBAction)colorBarButtonAction:(id)sender;
- (IBAction)brightnessBarButtonAction:(id)sender;
- (IBAction)effectBarButtonAction:(id)sender;

- (IBAction)sliderControlValueChanged:(UISlider *)sender;
- (IBAction)LEDlightOnButtonTouchUp:(id)sender;

#if	!TARGET_IPHONE_SIMULATOR
@property (strong, nonatomic) AVCaptureSession *LEDSession;
#endif
@end
