//
//  InclinometerViewController.h
//  CalcSuite#3
//
//  Created by Byeong-Kwon Kwak on 12/22/08.
//  Copyright 2008 ALLABOUTAPPS. All rights reserved.
//

#import "ClinometerToolbarViewController.h"

#define SMALL_FONT							[UIFont boldSystemFontOfSize:14]					// Unit
#define TEXT_LABEL_FONT						[UIFont systemFontOfSize:13.0]					// CalibrationView

enum InclinometerUnits {
	degrees = 0,
	slope,
	pitch
};

enum InclinometerMode {
	surfaceMode = 0,
	bubbleMode,
	calibrationMode
};

#define kTransitionDuration	0.75

@class InclinometerView, CalibrationView;

@interface InclinometerViewController : UIViewController 

@property (nonatomic, readonly) NSUInteger unit;

- (void)calibrate1Action:(id)sender;
- (void)calibrate2Action:(id)sender;
- (void)calibrateDoneAction:(id)sender;

@end
