//
//  InclinometerSurfaceView.h
//  CalcSuite#3
//
//  Created by Byeong-Kwon Kwak on 12/22/08.
//  Copyright 2008 ALLABOUTAPPS. All rights reserved.
//

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
    if (frame.size.height == 812) {
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
	button.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
	[button setTitle:title forState:UIControlStateNormal & UIControlStateHighlighted & UIControlStateSelected];
	[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[button setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
	[button setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
	button.titleLabel.shadowOffset = CGSizeMake(2.0, 0.0);

	UIImage *newImage = [image stretchableImageWithLeftCapWidth:10 topCapHeight:10];
	[button setBackgroundImage:newImage forState:UIControlStateNormal];
	[button addTarget:target action:inSelector forControlEvents:UIControlEventTouchUpInside];
    button.adjustsImageWhenDisabled = YES;
    button.adjustsImageWhenHighlighted = YES;
	button.titleLabel.font = SMALL_FONT;
	[button setBackgroundColor:[UIColor clearColor]];	// in case the parent view draws with a custom color or gradient, use a transparent color
    return button;
}

- (void)setupSubviews {
	UIImage *backgroundImage;
	if (viewMode == surfaceMode) {
        if (IS_IPHONEX) {
            backgroundImage = [UIImage imageNamed:@"bg_Inclinometer_surface_cal_iPhoneX"];
        } else {
            backgroundImage = [UIImage imageNamed:IS_IPHONE35 ? @"bg_Inclinometer_surface_cal_480" : @"bg_Inclinometer_surface_cal"];
        }
	} else {
        if (IS_IPHONEX) {
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
    if (IS_IPHONEX) {
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

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
#ifdef TRACE_LOG
	NSLog(@"button Index : %d", buttonIndex);
#endif
	if (buttonIndex == 0) // Recalibrate
	{
		[self resetToInitialState:nil];
	}
	else 
	{
		[_viewController calibrateDoneAction:nil];
	}
}

#pragma mark - UIAlertViewDelegate end

- (void)promptRestart {
	[[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft animated:NO];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Info", nil)
													message:NSLocalizedString(@"CalibrationDone", nil)
												   delegate:self 
										  cancelButtonTitle:NSLocalizedString(@"Restart", nil)
										  otherButtonTitles:NSLocalizedString(@"Done", nil), nil];
	[alert show];
	[[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:NO];
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
