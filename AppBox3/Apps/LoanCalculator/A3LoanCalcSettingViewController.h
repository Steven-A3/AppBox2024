//
//  A3LoanCalcSettingViewController.h
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 12. 6..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface A3LoanCalcSettingViewController : UITableViewController
//@property (strong, nonatomic) int (^settingViewChangedBlock) ();    // KJH
//@property (strong, nonatomic) int (^settingViewDismissBlock) ();    // KJH


- (void)setSettingChangedCompletionBlock:(void (^)(void))changedBlock;
- (void)setSettingDismissCompletionBlock:(void (^)(void))dismissBlock;
@end
