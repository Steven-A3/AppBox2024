//
//  A3LoanCalcQuickDialogViewController.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 2/16/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuickDialog.h>
#import "A3NumberKeyboardViewController.h"
#import "A3FrequencyKeyboardViewController.h"
#import "A3DateKeyboardViewController.h"

@interface A3LoanCalcQuickDialogViewController : QuickDialogController <QuickDialogEntryElementDelegate, QuickDialogStyleProvider, A3NumberKeyboardDelegate, A3FrequencyKeyboardDelegate, A3DateKeyboardDelegate>

@end
