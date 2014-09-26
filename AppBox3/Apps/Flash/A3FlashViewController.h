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

@property (weak, nonatomic) IBOutlet UIToolbar *topToolBar;
@property (weak, nonatomic) IBOutlet UIToolbar *sliderToolBar;
@property (weak, nonatomic) IBOutlet UIToolbar *bottomToolBar;
@property (weak, nonatomic) IBOutlet UIView *pickerPanelView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topToolBarTopConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *middleToolBarBottomConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomToolBarBottomConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pickerViewBottomConst;

@property (weak, nonatomic) IBOutlet UISlider *sliderControl;
@property (weak, nonatomic) IBOutlet UIImageView *contentImageView;
@property (weak, nonatomic) IBOutlet UIButton *lightOffButton;


- (IBAction)sliderControlValueChanged:(UISlider *)sender;

- (IBAction)appsButtonTouchUp:(id)sender;
- (IBAction)detailInfoButtonTouchUp:(id)sender;

- (IBAction)LEDonOffButtonTouchUp:(id)sender;
- (IBAction)colorMenuButtonTouchUp:(id)sender;
- (IBAction)effectsMenuButtonTouchUp:(id)sender;

//#if	!TARGET_IPHONE_SIMULATOR
@property (strong, nonatomic) AVCaptureSession *LEDSession;
//#endif
@end
