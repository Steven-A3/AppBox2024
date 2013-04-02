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

@property (nonatomic, weak)	id<A3FrequencyKeyboardDelegate> delegate;
@property (nonatomic, weak) QEntryElement *element;
@property (nonatomic, weak) QEntryTableViewCell *entryTableViewCell;
@property (nonatomic, strong)	NSNumber *selectedFrequency;

- (void)reloadPrevNextButtons;

- (void)rotateToInterfaceOrientation:(UIInterfaceOrientation)toOrientation;
@end
