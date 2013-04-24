//
//  A3LoanCalcQuickDialogViewController.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 2/16/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuickDialog.h>
#import "A3NumberKeyboardViewController_iPad.h"
#import "A3FrequencyKeyboardViewController.h"
#import "A3DateKeyboardViewController.h"
#import "A3QuickDialogController.h"

@interface A3LoanCalcQuickDialogViewController : A3QuickDialogController <QuickDialogEntryElementDelegate, QuickDialogStyleProvider, A3KeyboardDelegate, A3FrequencyKeyboardDelegate, A3DateKeyboardDelegate>

- (void)reloadContents;
@end
