//
//  InclinometerSurfaceView.h
//  CalcSuite#3
//
//  Created by Byeong-Kwon Kwak on 12/22/08.
//  Copyright 2008 ALLABOUTAPPS. All rights reserved.
//

@class InclinometerViewController;

@interface CalibrationView : UIView

@property (nonatomic, weak) InclinometerViewController *viewController;

- (id)initWithMode:(int)mode viewController:(InclinometerViewController *)aController;
- (void)resetToInitialState:(id)sender;

@end
