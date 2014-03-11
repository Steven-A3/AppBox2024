//
//  A3LoanCalcSelectModeViewController.h
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 12. 9..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoanCalcMode.h"

@protocol LoanCalcSelectCalcForDelegate <NSObject>

@required
- (void)didSelectCalculationFor:(A3LoanCalcCalculationMode) calculationFor;

@end

@interface A3LoanCalcSelectModeViewController : UITableViewController

@property (nonatomic, assign) id<LoanCalcSelectCalcForDelegate> delegate;
@property (readwrite) A3LoanCalcCalculationMode currentCalcFor;

@end
