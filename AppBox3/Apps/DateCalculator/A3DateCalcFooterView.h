//
//  A3DateCalcFooterView.h
//  A3TeamWork
//
//  Created by jeonghwan kim on 13. 10. 12..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "A3DateCalcAddSubButton.h"

@interface A3DateCalcFooterView : UIView

@property (weak, nonatomic) IBOutlet A3DateCalcAddSubButton *addModeButton;
@property (weak, nonatomic) IBOutlet A3DateCalcAddSubButton *subModeButton;

@property (weak, nonatomic) IBOutlet UITextField *yearTextField;
@property (weak, nonatomic) IBOutlet UITextField *monthTextField;
@property (weak, nonatomic) IBOutlet UITextField *dayTextField;

@property (weak, nonatomic) IBOutlet UILabel *yearLabel;
@property (weak, nonatomic) IBOutlet UILabel *monthLabel;
@property (weak, nonatomic) IBOutlet UILabel *dayLabel;

-(void)setOffsetDate:(NSDate *)aDate;
-(void)setOffsetDateComp:(NSDateComponents *)aDateComp;
@end
