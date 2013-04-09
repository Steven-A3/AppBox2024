//
//  A3SalesCalcQuickDialogViewController.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 11/17/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuickDialog.h"
#import "A3NumberKeyboardViewController_iPad.h"
#import "A3CurrencySelectViewController.h"

@class SalesCalcHistory;

@interface A3SalesCalcQuickDialogViewController : QuickDialogController
		<QuickDialogStyleProvider, QuickDialogEntryElementDelegate, A3NumberKeyboardDelegate, CurrencySelectViewControllerDelegate>
- (void)applyCurrentContentsWithSalesCalcHistory:(SalesCalcHistory *)history;


@end
