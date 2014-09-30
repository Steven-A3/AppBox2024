//
//  A3FlashViewController.h
//  AppBox3
//
//  Created by kimjeonghwan on 9/24/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "NPColorPickerView.h"

extern NSString *const A3UserDefaultFlashViewMode;

@interface A3FlashViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIToolbar *topToolBar;
@property (weak, nonatomic) IBOutlet UIToolbar *sliderToolBar;
@property (weak, nonatomic) IBOutlet UIToolbar *bottomToolBar;
@property (weak, nonatomic) IBOutlet UIToolbar *LEDBrightnessToolBar;
@property (weak, nonatomic) IBOutlet UIView *pickerPanelView;
@property (weak, nonatomic) IBOutlet NPColorPickerView *colorPickerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topToolBarTopConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sliderToolBarBottomConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomToolBarBottomConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pickerViewBottomConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *colorPickerHeightConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *flashBrightnessSliderBottomConst;

@property (weak, nonatomic) IBOutlet UISlider *sliderControl;
@property (weak, nonatomic) IBOutlet UISlider *flashBrightnessSlider;
@property (weak, nonatomic) IBOutlet UIImageView *contentImageView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *colorPickerTopConst;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *ledBarButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *colorBarButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *effectBarButton;
@property (weak, nonatomic) IBOutlet UIPickerView *effectPickerView;

- (IBAction)sliderControlValueChanged:(UISlider *)sender;

- (IBAction)appsButtonTouchUp:(id)sender;
- (IBAction)detailInfoButtonTouchUp:(id)sender;

- (IBAction)LEDMenuButtonTouchUp:(id)sender;
- (IBAction)colorMenuButtonTouchUp:(id)sender;
- (IBAction)effectsMenuButtonTouchUp:(id)sender;

//#if	!TARGET_IPHONE_SIMULATOR
@property (strong, nonatomic) AVCaptureSession *LEDSession;
//#endif
@end
