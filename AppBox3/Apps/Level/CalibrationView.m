//
//  InclinometerSurfaceView.h
//  CalcSuite#3
//
//  Created by Byeong-Kwon Kwak on 12/22/08.
//  Copyright 2008 ALLABOUTAPPS. All rights reserved.
//

#import <AppBoxKit/AppBoxKit.h>
#import "CalibrationView.h"
#import "InclinometerViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface CalibrationView ()

@end

@implementation CalibrationView {
	UIButton *calibration1Button;
	UIButton *calibration2Button;
	int viewMode;					// 0:Surface 1:Bubble
}

- (id)initWithMode:(int)mode viewController:(InclinometerViewController *)aController {
    CGRect frame = [A3UIDevice screenBoundsAdjustedWithOrientation];
    CGFloat topOffset = 0;
    if (frame.size.height == 812 || frame.size.height == 896) {
        topOffset = 40;
        frame.origin.y += topOffset;
        frame.size.height -= 80;
    }
    self = [super initWithFrame:frame];
    if (self != nil) {
		viewMode = mode;
        _viewController = aController;
		[self setupSubviews];
    }
    return self;
}

- (UIButton *)buttonWithTitle:(NSString *)title target:(id)target selector:(SEL)inSelector frame:(CGRect)frame image:(UIImage*)image {
	UIButton *button = [[UIButton alloc] initWithFrame:frame];
	
	UIButtonConfiguration *config = [UIButtonConfiguration plainButtonConfiguration];
	config.contentInsets = NSDirectionalEdgeInsetsMake(0, 10, 0, 10);
	config.background.image = [image stretchableImageWithLeftCapWidth:10 topCapHeight:10];
	
	// 타이틀 설정
	config.title = title;
	config.baseForegroundColor = [UIColor whiteColor];
	config.titleTextAttributesTransformer = ^NSDictionary<NSAttributedStringKey, id> *(NSDictionary<NSAttributedStringKey, id> *textAttributes) {
		NSMutableDictionary *attributes = [textAttributes mutableCopy];
		attributes[NSFontAttributeName] = SMALL_FONT;
		attributes[NSShadowAttributeName] = ({
			NSShadow *shadow = [[NSShadow alloc] init];
			shadow.shadowOffset = CGSizeMake(2.0, 0.0);
			shadow.shadowColor = [UIColor blackColor];
			shadow;
		});
		return attributes;
	};
	
	button.configuration = config;
	
	// 상태에 따른 설정
	button.configurationUpdateHandler = ^(UIButton *btn) {
		UIButtonConfiguration *updatedConfig = btn.configuration;
		if (btn.state == UIControlStateDisabled) {
			updatedConfig.baseForegroundColor = [UIColor grayColor];
			updatedConfig.background.backgroundColorTransformer = ^UIColor *(UIColor *color) {
				return [color colorWithAlphaComponent:0.5];
			};
		} else {
			updatedConfig.baseForegroundColor = [UIColor whiteColor];
			updatedConfig.background.backgroundColorTransformer = nil;
		}
		btn.configuration = updatedConfig;
	};
	
	[button addTarget:target action:inSelector forControlEvents:UIControlEventTouchUpInside];
	
	return button;
}

- (void)setupSubviews {
	UIImage *backgroundImage;
    UIEdgeInsets safeAreaInsets = [[[UIApplication sharedApplication] myKeyWindow] safeAreaInsets];
	if (viewMode == surfaceMode) {
        if (safeAreaInsets.top > 20) {
            backgroundImage = [UIImage imageNamed:@"bg_Inclinometer_surface_cal_iPhoneX"];
        } else {
            backgroundImage = [UIImage imageNamed:IS_IPHONE35 ? @"bg_Inclinometer_surface_cal_480" : @"bg_Inclinometer_surface_cal"];
        }
	} else {
        if (safeAreaInsets.top > 20) {
            backgroundImage = [UIImage imageNamed:@"bg_Inclinometer_bubble_cal_iPhoneX"];
        } else {
            backgroundImage = [UIImage imageNamed:IS_IPHONE35 ? @"bg_Inclinometer_bubble_cal_480" : @"bg_Inclinometer_bubble_cal"];
        }
	}
	
	CGFloat scale = [A3UIDevice scaleToOriginalDesignDimension];
	
    UIImageView *levelBackView = [[UIImageView alloc] initWithImage:backgroundImage];
	levelBackView.frame = self.bounds;
    [self addSubview:levelBackView];

	CATransform3D landscapeTransform = CATransform3DIdentity;
	landscapeTransform = CATransform3DRotate(landscapeTransform, DegreesToRadians(-90), 0, 0, 1);
	
	UIButton *exitButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[exitButton setImage:[UIImage imageNamed:@"bt_clinometer_exit"] forState:UIControlStateNormal];
	exitButton.backgroundColor = [UIColor clearColor];
	exitButton.frame = CGRectMake(10.0 * scale, 10.0 * scale, 40.0 * scale, 41.0 * scale);
	
	[exitButton addTarget:_viewController action:@selector(calibrateDoneAction:) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:exitButton];

	UIImage *imageNormal = [UIImage imageNamed:@"bt_input"];
    
    // set up Calibrate1 button
	CGFloat x = 200.5 * scale;
	CGFloat yOffset = IS_IPHONE35 ? 0 : 45.0 * scale;

    if (safeAreaInsets.top > 20) {
        yOffset = 85;
    }
	CGRect buttonFrame = CGRectMake(x, 340.0 * scale + yOffset, imageNormal.size.width * scale, imageNormal.size.height * scale);
    calibration1Button = [self buttonWithTitle:NSLocalizedString(@"Calibrate 1", nil)
										target:self 
									  selector:@selector(calibrate1Action:) 
										 frame:buttonFrame 
										 image:imageNormal];
    calibration1Button.enabled = YES;
	calibration1Button.layer.transform = landscapeTransform;
	calibration1Button.titleLabel.shadowColor = [UIColor colorWithRed:64.0f/255.0f green:35.0f/255.0f blue:0.0f alpha:1.0];
	calibration1Button.titleLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
    [self addSubview:calibration1Button];
    
    // set up Calibrate2 button
	buttonFrame = CGRectMake(x, 100.0 * scale + yOffset, imageNormal.size.width * scale, imageNormal.size.height * scale);
	calibration2Button = [self buttonWithTitle:NSLocalizedString(@"Calibrate 2", nil)
										target:self 
									  selector:@selector(calibrate2Action:) 
										 frame:buttonFrame 
										 image:imageNormal];
    calibration2Button.enabled = NO; 
	calibration2Button.layer.transform = landscapeTransform;
	calibration2Button.titleLabel.shadowColor = [UIColor colorWithRed:64.0f/255.0f green:35.0f/255.0f blue:0.0f alpha:1.0];
	calibration2Button.titleLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
    [self addSubview:calibration2Button];
	
	UIFont *font = TEXT_LABEL_FONT;
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(110.0 * scale, 300.0 * scale + yOffset, 220.0 * scale, 100.0 * scale)];
	if (viewMode == surfaceMode) {
		label1.text = NSLocalizedString(@"CalibrateSurface1Msg", nil);
	} else {
		label1.text = NSLocalizedString(@"Calibrate1Msg", nil);
	}
	label1.textColor = [UIColor whiteColor];
	label1.shadowColor = [UIColor blackColor];
	label1.shadowOffset = CGSizeMake(2.0, 0.0);
	label1.backgroundColor = [UIColor clearColor];
	label1.font = font;
	label1.layer.transform = landscapeTransform;
	label1.numberOfLines = 6;
	[self addSubview:label1];
	
	UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(110.0 * scale, 60.0 * scale + yOffset, 220.0 * scale, 100.0 * scale)];
	if (viewMode == surfaceMode) {
		label2.text = NSLocalizedString(@"CalibrateSurface2Msg", nil);
	} else {
		label2.text = NSLocalizedString(@"Calibrate2Msg", nil);
	}
	label2.textColor = [UIColor whiteColor];
	label2.shadowColor = [UIColor blackColor];
	label2.shadowOffset = CGSizeMake(2.0, 0.0);
	label2.backgroundColor = [UIColor clearColor];
	label2.font = font;
	label2.layer.transform = landscapeTransform;
	label2.numberOfLines = 4;
	[self addSubview:label2];
}

#pragma mark - UIAlertViewDelegate end

- (void)promptRestart {
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Info", nil)
                                                                   message:NSLocalizedString(@"CalibrationDone", nil)
                                                            preferredStyle:UIAlertControllerStyleAlert];

    // Add "Restart" action
    UIAlertAction *restartAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Restart", nil)
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull action) {
        // Handle Restart action here
        [self resetToInitialState:nil];
    }];

    // Add "Done" action
    UIAlertAction *doneAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Done", nil)
                                                         style:UIAlertActionStyleCancel
                                                       handler:^(UIAlertAction * _Nonnull action) {
        // Handle Done action here
        [self->_viewController calibrateDoneAction:nil];
    }];

    // Add actions to the alert
    [alert addAction:restartAction];
    [alert addAction:doneAction];

    // Present the alert controller
    UIViewController *rootViewController = [[UIApplication sharedApplication] getRootViewController];
    [rootViewController presentViewController:alert animated:YES completion:nil];
}

- (void)resetToInitialState:(id)sender {
	calibration1Button.enabled = YES;
    calibration2Button.enabled = NO; 
}

- (void)calibrate1Action:(id)sender {
    [_viewController calibrate1Action:self];
	calibration1Button.enabled = NO;
    calibration2Button.enabled = YES;
}

- (void)calibrate2Action:(id)sender {
    [_viewController calibrate2Action:self];
	calibration2Button.enabled = NO;
	[self promptRestart];
}

@end
