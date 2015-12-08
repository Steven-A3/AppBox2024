//
//  ClinometerToolbarViewController.h
//  AppBox Pro
//
//  Created by bkk on 11/28/09.
//  Copyright 2009 ALLABOUTAPPS. All rights reserved.
//

@protocol ClinometerToolbarViewControllerDelegate<NSObject>
@optional

- (void)exitToHome;
- (void)setToDegree;
- (void)setToSlope;
- (void)setToPitch;
- (void)gotoSurface;
- (void)gotoBubble;
- (void)calibration;
- (void)lockUnlock;

@end

@interface ClinometerToolbarViewController : UIViewController 

@property (nonatomic, weak) id<ClinometerToolbarViewControllerDelegate> delegate;

- (void)exitToHome;
- (void)setToDegree;
- (void)setToSlope;
- (void)setToPitch;
- (void)gotoSurface;
- (void)gotoBubble;
- (void)calibration;
- (void)lockUnlock;
- (void)setUnlockImage;
- (void)setLockImage;
- (void)updateTimer;
- (void)toggleViewWithMode:(NSUInteger) viewMode;

@end
