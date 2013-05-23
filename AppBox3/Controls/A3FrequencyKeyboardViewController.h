//
//  A3FrequencyKeyboardViewController.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 2/22/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuickDialog.h"

@class A3FrequencyKeyboardViewController;

@protocol A3FrequencyKeyboardDelegate <NSObject>
@optional
- (void)frequencySelected:(NSNumber *)frequencyObject cell:(QEntryTableViewCell *)cell;
- (BOOL)prevAvailableForElement:(QEntryElement *)element;
- (BOOL)nextAvailableForElement:(QEntryElement *)element;
- (void)prevButtonPressedWithElement:(QEntryElement *)element;
- (void)nextButtonPressedWithElement:(QEntryElement *)element;
- (void)A3KeyboardViewControllerDoneButtonPressed;

@end

@interface A3FrequencyKeyboardViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIButton *weeklyButton;
@property (nonatomic, strong) IBOutlet UIButton *fortnightlyButton;
@property (nonatomic, strong) IBOutlet UIButton *monthlyButton;
@property (nonatomic, strong) IBOutlet UIButton *bimonthlyButton;
@property (nonatomic, strong) IBOutlet UIButton *quarterlyButton;
@property (nonatomic, strong) IBOutlet UIButton *semiAnnuallyButton;
@property (nonatomic, strong) IBOutlet UIButton *annuallyButton;
@property (nonatomic, strong) IBOutlet UIButton *blankButton;
@property (nonatomic, strong) IBOutlet UIButton *prevButton;
@property (nonatomic, strong) IBOutlet UIButton *nextButton;
@property (nonatomic, strong) IBOutlet UIButton *doneButton;

@property (nonatomic, weak)	id<A3FrequencyKeyboardDelegate> delegate;
@property (nonatomic, weak) QEntryElement *element;
@property (nonatomic, weak) QEntryTableViewCell *entryTableViewCell;
@property (nonatomic, strong)	NSNumber *selectedFrequency;

- (void)reloadPrevNextButtons;

- (IBAction)frequencyButtonTouchUpInside:(UIButton *)button;

- (IBAction)prevButtonTouchUpInside:(UIButton *)button;

- (IBAction)nextButtonTouchUpInside:(UIButton *)button;

- (IBAction)doneButtonTouchUpInside:(UIButton *)button;

- (void)rotateToInterfaceOrientation:(UIInterfaceOrientation)toOrientation;

@end
