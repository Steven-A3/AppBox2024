//
//  ClinometerToolbarViewController.m
//  AppBox Pro
//
//  Created by bkk on 11/28/09.
//  Copyright 2009 ALLABOUTAPPS. All rights reserved.
//

#import "ClinometerToolbarViewController.h"

@interface ClinometerToolbarViewController ()

@end

@implementation ClinometerToolbarViewController {
	NSTimer *myTimer;
}

#define NUMBER_OF_INCLINOMETER_TOOL_BUTTON		6
#define INDEX_OF_DEGREE_BUTTON					1
#define INDEX_OF_SLOPE_BUTTON					2
#define INDEX_OF_PITCH_BUTTON					3
#define INDEX_OF_CALIBRATION_BUTTON				4
#define INDEX_OF_LOCK_BUTTON					5

- (void)addToolbuttonWithImageName:(NSString *)imageName atIndex:(NSInteger)index withAction:(SEL)theAction {
	CGFloat scale = [A3UIDevice scaleToOriginalDesignDimension];
	UIButton *theButton = [UIButton buttonWithType:UIButtonTypeCustom];
	UIImage *buttonImage = [UIImage imageNamed:imageName];
	[theButton setImage:buttonImage forState:UIControlStateNormal];
	[theButton addTarget:self action:theAction forControlEvents:UIControlEventTouchUpInside];
	[theButton setTag:index];
	[theButton setFrame:CGRectMake(30.0 + (ceil((self.view.bounds.size.width - 60.0)/ (NUMBER_OF_INCLINOMETER_TOOL_BUTTON - 1)) * index) - 20.0, 0.0, 40.0 * scale, 41.0 * scale)];
	[self.view addSubview:theButton];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

	CGFloat scale = [A3UIDevice scaleToOriginalDesignDimension];
	self.view.backgroundColor = [UIColor clearColor];
	CGRect frame = CGRectMake(0.0, 0.0, self.view.bounds.size.width, 41.0 * scale);
	self.view.frame = frame;
	UIImage *toolbarBackgroundImage = [UIImage imageNamed:@"bg_Inclinometer_toolbar"];
	UIImageView *mainView = [[UIImageView alloc] initWithImage:toolbarBackgroundImage];
	[mainView setFrame:frame];
	[mainView setUserInteractionEnabled:YES];
	mainView.backgroundColor = [UIColor clearColor];
	[self.view addSubview:mainView];
	
	[self addToolbuttonWithImageName:@"bt_clinometer_exit" atIndex:0 withAction:@selector(exitToHome)];
	[self addToolbuttonWithImageName:@"bt_clinometer_degree_on" atIndex:1 withAction:@selector(setToDegree)];
	[self addToolbuttonWithImageName:@"bt_clinometer_slope" atIndex:2 withAction:@selector(setToSlope)];
	[self addToolbuttonWithImageName:@"bt_clinometer_pitch" atIndex:3 withAction:@selector(setToPitch)];
	[self addToolbuttonWithImageName:@"bt_clinometer_calibrate" atIndex:4 withAction:@selector(calibration)];
	[self addToolbuttonWithImageName:@"bt_clinometer_unlock" atIndex:5 withAction:@selector(lockUnlock)];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)exitToHome {
	if ([_delegate respondsToSelector:@selector(exitToHome)]) {
		[_delegate exitToHome];
	}
}

- (void)setButtonImageToButton:(UIButton *)theButton withImageName:(NSString *)imageName {
	UIImage *buttonImage = [UIImage imageNamed:imageName];
	[theButton setImage:buttonImage forState:UIControlStateNormal];
}

- (void)setToDegree {
	UIButton *button = (UIButton *)[self.view viewWithTag:INDEX_OF_DEGREE_BUTTON];
	[self setButtonImageToButton:button withImageName:@"bt_clinometer_degree_on"];

	button = (UIButton *)[self.view viewWithTag:INDEX_OF_SLOPE_BUTTON];
	[self setButtonImageToButton:button withImageName:@"bt_clinometer_slope"];
	
	button = (UIButton *)[self.view viewWithTag:INDEX_OF_PITCH_BUTTON];
	[self setButtonImageToButton:button withImageName:@"bt_clinometer_pitch"];
	
	if ([_delegate respondsToSelector:@selector(setToDegree)]) {
		[_delegate setToDegree];
	}
	[self updateTimer];
}

- (void)setToSlope {
	UIButton *button = (UIButton *)[self.view viewWithTag:INDEX_OF_DEGREE_BUTTON];
	[self setButtonImageToButton:button withImageName:@"bt_clinometer_degree"];
	
	button = (UIButton *)[self.view viewWithTag:INDEX_OF_SLOPE_BUTTON];
	[self setButtonImageToButton:button withImageName:@"bt_clinometer_slope_on"];
	
	button = (UIButton *)[self.view viewWithTag:INDEX_OF_PITCH_BUTTON];
	[self setButtonImageToButton:button withImageName:@"bt_clinometer_pitch"];
	
	if ([_delegate respondsToSelector:@selector(setToSlope)]) {
		[_delegate setToSlope];
	}
	[self updateTimer];
}

- (void)setToPitch {
	UIButton *button = (UIButton *)[self.view viewWithTag:INDEX_OF_DEGREE_BUTTON];
	[self setButtonImageToButton:button withImageName:@"bt_clinometer_degree"];
	
	button = (UIButton *)[self.view viewWithTag:INDEX_OF_SLOPE_BUTTON];
	[self setButtonImageToButton:button withImageName:@"bt_clinometer_slope"];
	
	button = (UIButton *)[self.view viewWithTag:INDEX_OF_PITCH_BUTTON];
	[self setButtonImageToButton:button withImageName:@"bt_clinometer_pitch_on"];
	
	if ([_delegate respondsToSelector:@selector(setToPitch)]) {
		[_delegate setToPitch];
	}
	[self updateTimer];
}

- (void)gotoSurface {
	if ([_delegate respondsToSelector:@selector(gotoSurface)]) {
		[_delegate gotoSurface];
	}
	[self updateTimer];
}

- (void)gotoBubble {
	if ([_delegate respondsToSelector:@selector(gotoBubble)]) {
		[_delegate gotoBubble];
	}
	[self updateTimer];
}

- (void)calibration {
	if ([_delegate respondsToSelector:@selector(calibration)]) {
		[_delegate calibration];
	}
	[self updateTimer];
}

- (void)lockUnlock {
	if ([_delegate respondsToSelector:@selector(lockUnlock)]) {
		[_delegate lockUnlock];
	}
	[self updateTimer];
}

- (void)setUnlockImage {
	UIButton *button = (UIButton *)[self.view viewWithTag:INDEX_OF_LOCK_BUTTON];
	[button setImage:[UIImage imageNamed:@"bt_clinometer_unlock"] forState:UIControlStateNormal];
}

- (void)setLockImage {
	UIButton *button = (UIButton *)[self.view viewWithTag:INDEX_OF_LOCK_BUTTON];
	[button setImage:[UIImage imageNamed:@"bt_clinometer_lock_on"] forState:UIControlStateNormal];
}

- (void)clearTimer{
	if (myTimer) {
		[myTimer invalidate];
		myTimer = nil;
	}
}

- (void)updateTimer {
	[self clearTimer];
	NSDate *fireDate = [NSDate dateWithTimeIntervalSinceNow:3.0];
	myTimer = [[NSTimer alloc] initWithFireDate:fireDate
										  interval:0.0
											target:self
										  selector:@selector(hideView)
										  userInfo:nil
										   repeats:NO];
	
	NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
	[runLoop addTimer:myTimer forMode:NSDefaultRunLoopMode];
}

- (void)toggleViewWithMode:(NSUInteger) viewMode {
	BOOL hidden = !self.view.hidden;
	self.view.hidden = hidden;
	if (!hidden) {
		[self updateTimer];
	} else {
		[self clearTimer];
	}
}

- (void)hideView {
	[self clearTimer];
	self.view.hidden = YES;
}

@end
